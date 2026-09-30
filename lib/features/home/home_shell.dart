import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/tokens.dart';
import '../../data/models/enums.dart';
import '../../data/models/notification_item.dart';
import '../../services/fo_providers.dart';
import '../../services/mock_data_service.dart' show CaseSort, DashboardStats;
import '../../widgets/common.dart';
import '../../widgets/lazy_tab_stack.dart';
import '../../widgets/motion.dart';
import '../../widgets/screen_header.dart';
import '../auth/auth_providers.dart';
import '../cases/case_card.dart';
import '../cases/case_detail_screen.dart';
import '../map/parcel_map_screen.dart';
import '../more/more_screen.dart';
import '../more/profile_screen.dart';
import '../notifications/notifications_screen.dart';
import '../sync/sync_center_screen.dart';
import '../tasks/task_card.dart';
import '../tasks/tasks_screen.dart';

final _tabIndexProvider = StateProvider<int>((_) => 0);

/// Root shell: Home · Cases · Map · Sync · More.
///
/// The five tabs live in an [IndexedStack]. Previously they were a plain list
/// literal rebuilt inside `build()`, so every tap disposed and recreated all
/// five subtrees: scroll positions reset, list state was lost, and the Map tab
/// re-fired a GPS probe on each switch. [IndexedStack] keeps every tab alive and
/// only repaints the selected one.
///
/// The shell owns the only [Scaffold]. Each tab renders a [ScreenHeader] plus
/// its content — the previous three-nested-`Scaffold` layout double-applied
/// safe-area insets and put the connection banner underneath the app bar.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  static const _destinations = <_TabSpec>[
    _TabSpec('Home', Icons.home_outlined, Icons.home),
    _TabSpec('Cases', Icons.folder_outlined, Icons.folder),
    _TabSpec('Map', Icons.map_outlined, Icons.map),
    _TabSpec('Sync', Icons.sync_outlined, Icons.sync),
    _TabSpec('More', Icons.more_horiz, Icons.more_horiz),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(_tabIndexProvider);
    final pending = ref.watch(pendingSyncCountProvider);

    void go(int i) => ref.read(_tabIndexProvider.notifier).state = i;

    return Scaffold(
      body: LazyTabStack(
        index: tab,
        builder: (_, i) => switch (i) {
          0 => HomeDashboard(onOpenTab: go),
          1 => const CasesTab(),
          2 => const MapTab(),
          3 => const SyncCenterScreen(),
          _ => const MoreScreen(),
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: go,
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: d.label == 'Sync' && pending > 0
                  ? Badge(label: Text('$pending'), child: Icon(d.icon))
                  : Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

// ---------------------------------------------------------------- Dashboard

class HomeDashboard extends ConsumerWidget {
  const HomeDashboard({super.key, required this.onOpenTab});

  final void Function(int) onOpenTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final officer = ref.watch(currentUserProvider);
    final stats = ref.watch(dashboardStatsProvider);
    final state = ref.watch(foStateProvider);
    final pending = ref.watch(pendingSyncCountProvider);
    final conn = ref.watch(connectionProvider).valueOrNull ?? ConnectionStatus.offline;
    final theme = Theme.of(context);

    final seen = {...state.dueTodayTasks.map((t) => t.id)};
    final todayTasks = [...state.dueTodayTasks, ...state.openTasks.where((t) => seen.add(t.id))]
      ..sort((a, b) {
        final byDue = a.dueDate.compareTo(b.dueDate);
        return byDue != 0 ? byDue : a.priority.rank.compareTo(b.priority.rank);
      });
    final showTasks = todayTasks.take(3).toList();

    return Column(
      children: [
        BrandHeader(
          actions: [
            IconButton(
              tooltip: 'Notifications',
              onPressed: () => NotificationsScreen.open(context),
              icon: Badge(
                isLabelVisible: stats.unreadNotifications > 0,
                label: Text('${stats.unreadNotifications}'),
                child: const Icon(Icons.notifications_outlined),
              ),
            ),
          ],
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(connectivityServiceProvider).refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.lg, Insets.lg, Insets.xxl),
              children: [
                _greetingCard(context, officer),
                const Gap(Insets.lg),
                _statsBlock(context, stats, pending, ref),
                const Gap(Insets.xxl),
                _sectionHeader(
                  context,
                  "TODAY'S TASKS",
                  actionLabel: 'VIEW ALL',
                  onAction: () => TasksScreen.open(context),
                ),
                const Gap(Insets.md),
                if (showTasks.isEmpty)
                  const EmptyState(
                    icon: Icons.task_alt,
                    title: 'No Tasks Due Today',
                    message: 'You are clear for today. Check the case list for upcoming work.',
                  )
                else
                  for (var i = 0; i < showTasks.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Insets.md),
                      child: TaskCard(task: showTasks[i]),
                    ),
                const Gap(Insets.sm),
                _syncCard(context, onOpenTab, pending, conn),
                const Gap(Insets.xxl),
                _sectionHeader(
                  context,
                  'NOTIFICATIONS',
                  actionLabel: 'VIEW ALL',
                  onAction: () => NotificationsScreen.open(context),
                ),
                const Gap(Insets.md),
                if (state.notifications.isEmpty)
                  const EmptyState(
                    icon: Icons.notifications_none,
                    title: 'No Notifications',
                    message: 'Case, task and sync updates will appear here.',
                  )
                else
                  for (var i = 0; i < state.notifications.take(3).length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Insets.sm),
                      child: _notificationRow(context, state.notifications[i]),
                    ),
                const Gap(Insets.lg),
                Center(
                  child: TextButton.icon(
                    onPressed: () => ProfileScreen.open(context),
                    icon: const Icon(Icons.badge_outlined, size: 18),
                    label: const Text('MY PROFILE'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.textTheme.titleSmall?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _notificationRow(BuildContext context, AppNotification n) {
    final theme = Theme.of(context);

    return TappableCard(
      onTap: () => NotificationsScreen.open(context),
      padding: const EdgeInsets.symmetric(horizontal: Insets.md, vertical: Insets.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: n.kind.color.withValues(alpha: 0.12),
              borderRadius: Radii.smAll,
            ),
            child: Icon(Icons.notifications_none, size: 17, color: n.kind.color),
          ),
          const Gap(Insets.md, horizontal: true),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  n.title,
                  style: theme.textTheme.titleMedium!.copyWith(fontSize: 14),
                ),
                const Gap(2),
                Text(
                  n.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall!.copyWith(fontSize: 12.5),
                ),
              ],
            ),
          ),
          if (!n.read) ...[
            const Gap(Insets.sm, horizontal: true),
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: StatusDot(color: AppColors.brand, size: 8),
            ),
          ],
        ],
      ),
    );
  }

  Widget _greetingCard(BuildContext context, FieldOfficer officer) {
    final theme = Theme.of(context);
    final initials = officer.name.isEmpty
        ? '?'
        : officer.name
            .split(' ')
            .where((p) => p.isNotEmpty)
            .take(2)
            .map((p) => p[0])
            .join();

    return Container(
      decoration: BoxDecoration(
        borderRadius: Radii.lgAll,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandShadow, AppColors.brand, AppColors.brandBright],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(Insets.lg),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: theme.textTheme.titleLarge!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Gap(Insets.md, horizontal: true),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greetingWord()}, ${officer.name.split(' ').first}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge!.copyWith(color: Colors.white),
                ),
                const Gap(2),
                Text(
                  officer.designation,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
                const Gap(1),
                Text(
                  officer.assignedArea,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall!.copyWith(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.68),
                  ),
                ),
              ],
            ),
          ),
          const Gap(Insets.sm, horizontal: true),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Insets.sm, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: Radii.smAll,
            ),
            child: Text(
              officer.officerId,
              style: theme.textTheme.labelSmall!.copyWith(
                color: Colors.white,
                fontSize: 10.5,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greetingWord() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _statsBlock(BuildContext context, DashboardStats stats, int pending, WidgetRef ref) {
    final emphasise = stats.overdue > 0;

    return Column(
      children: [
        Row(
          children: [
            StatTile(
              value: '${stats.assignedCases}',
              label: 'Cases',
              color: AppColors.info,
              onTap: () => ref.read(_tabIndexProvider.notifier).state = 1,
            ),
            const Gap(Insets.sm, horizontal: true),
            StatTile(
              value: '${stats.pendingVerification}',
              label: 'Pending',
              color: AppColors.warning,
              onTap: () => ref.read(_tabIndexProvider.notifier).state = 1,
            ),
            const Gap(Insets.sm, horizontal: true),
            StatTile(
              value: '${stats.completed}',
              label: 'Completed',
              color: AppColors.success,
              onTap: () => ref.read(_tabIndexProvider.notifier).state = 1,
            ),
          ],
        ),
        const Gap(Insets.sm),
        Row(
          children: [
            StatTile(
              value: '${stats.overdue}',
              label: 'Overdue',
              color: AppColors.danger,
              emphasise: emphasise,
              onTap: () => ref.read(_tabIndexProvider.notifier).state = 1,
            ),
            const Gap(Insets.sm, horizontal: true),
            StatTile(
              value: '${stats.dueToday}',
              label: 'Due today',
              color: AppColors.violet,
              onTap: () => TasksScreen.open(context),
            ),
            const Gap(Insets.sm, horizontal: true),
            StatTile(
              value: '$pending',
              label: 'Queued',
              color: AppColors.teal,
              onTap: () => ref.read(_tabIndexProvider.notifier).state = 3,
            ),
          ],
        ),
      ],
    );
  }

  Widget _syncCard(
    BuildContext context,
    void Function(int) onOpenTab,
    int pending,
    ConnectionStatus conn,
  ) {
    final theme = Theme.of(context);
    final (label, color, icon) = switch (conn) {
      ConnectionStatus.online => pending == 0
          ? ('ONLINE — SYNCED', AppColors.success, Icons.cloud_done_outlined)
          : ('ONLINE — $pending PENDING', AppColors.warning, Icons.cloud_upload_outlined),
      ConnectionStatus.offline => (
          'OFFLINE — $pending PENDING',
          AppColors.danger,
          Icons.cloud_off_outlined
        ),
      ConnectionStatus.syncing => ('SYNCING…', AppColors.warning, Icons.cloud_sync_outlined),
      ConnectionStatus.serverUnavailable => (
          'SERVER UNAVAILABLE',
          AppColors.serverDown,
          Icons.cloud_off_outlined
        ),
    };

    return TappableCard(
      onTap: () => onOpenTab(3),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: Radii.mdAll,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const Gap(Insets.md, horizontal: true),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium!.copyWith(color: color, letterSpacing: 0.6),
                ),
                const Gap(2),
                Text(
                  pending == 0
                      ? 'All field records are uploaded.'
                      : '$pending record${pending == 1 ? '' : 's'} waiting to upload from this device.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Gap(Insets.sm, horizontal: true),
          const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
    );
  }

  Widget _sectionHeader(
    BuildContext context,
    String title, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Row(
      children: [
        // Flexible so a large text scale cannot push the action off-screen.
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: Insets.sm),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(actionLabel),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------- Cases tab

class CasesTab extends ConsumerWidget {
  const CasesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cases = ref.watch(filteredCasesProvider);
    final query = ref.watch(caseSearchQueryProvider);
    final status = ref.watch(caseStatusFilterProvider);
    final priority = ref.watch(casePriorityFilterProvider);
    final sort = ref.watch(caseSortProvider);
    final theme = Theme.of(context);

    final filtering = query.isNotEmpty || status != null || priority != null;

    return Column(
      children: [
        ScreenHeader(
          title: 'Cases',
          subtitle: cases.isEmpty ? null : '${cases.length} in your jurisdiction',
          actions: [
            PopupMenuButton<CaseSort>(
              tooltip: 'Sort',
              icon: const Icon(Icons.sort),
              initialValue: sort,
              onSelected: (s) => ref.read(caseSortProvider.notifier).state = s,
              itemBuilder: (_) => const [
                PopupMenuItem(value: CaseSort.dueDate, child: Text('Due date')),
                PopupMenuItem(value: CaseSort.priority, child: Text('Priority')),
                PopupMenuItem(value: CaseSort.updated, child: Text('Last updated')),
                PopupMenuItem(value: CaseSort.caseNo, child: Text('Case number')),
              ],
            ),
          ],
        ),
        _searchField(context, ref, query),
        _statusStrip(context, ref, status, priority),
        Padding(
          padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.xs, Insets.lg, 0),
          child: Row(
            children: [
              Text('${cases.length} CASE${cases.length == 1 ? '' : 'S'}', style: theme.textTheme.labelSmall),
              const Spacer(),
              if (filtering)
                TextButton(
                  onPressed: () {
                    ref.read(caseSearchQueryProvider.notifier).state = '';
                    ref.read(caseStatusFilterProvider.notifier).state = null;
                    ref.read(casePriorityFilterProvider.notifier).state = null;
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: Insets.sm),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('RESET'),
                ),
            ],
          ),
        ),
        Expanded(
          child: cases.isEmpty
              ? EmptyState(
                  icon: filtering ? Icons.search_off : Icons.folder_open,
                  title: filtering ? 'No Matching Cases' : 'No Cases Assigned',
                  message: filtering
                      ? 'Try a different search term or clear the filters.'
                      : 'Assigned land acquisition cases will appear here.',
                )
              : ListView.builder(
                  key: const PageStorageKey('cases-list'),
                  padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.sm, Insets.lg, Insets.xxl),
                  itemCount: cases.length,
                  itemBuilder: (_, i) => Padding(
                    key: ValueKey(cases[i].caseNo),
                    padding: const EdgeInsets.only(bottom: Insets.md),
                    child: CaseCard(caseData: cases[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _searchField(BuildContext context, WidgetRef ref, String query) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.lg, Insets.sm),
      child: TextField(
        onChanged: (v) => ref.read(caseSearchQueryProvider.notifier).state = v,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search case, village, survey no, owner…',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear',
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => ref.read(caseSearchQueryProvider.notifier).state = '',
                ),
          contentPadding: const EdgeInsets.symmetric(horizontal: Insets.lg, vertical: 14),
        ),
      ),
    );
  }

  Widget _statusStrip(
    BuildContext context,
    WidgetRef ref,
    CaseStatus? status,
    CasePriority? priority,
  ) {
    const statuses = [
      CaseStatus.verificationPending,
      CaseStatus.inProgress,
      CaseStatus.overdue,
      CaseStatus.compensationPending,
      CaseStatus.awaitingDocuments,
      CaseStatus.rrVerification,
      CaseStatus.possessionPending,
      CaseStatus.completed,
    ];

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Insets.md),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: Insets.sm),
            child: ChoiceChip(
              label: const Text('ALL'),
              selected: status == null && priority == null,
              onSelected: (_) {
                ref.read(caseStatusFilterProvider.notifier).state = null;
                ref.read(casePriorityFilterProvider.notifier).state = null;
              },
            ),
          ),
          for (final s in statuses)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: Insets.sm),
              child: ChoiceChip(
                label: Text(s.label),
                selected: status == s,
                avatar: status == s
                    ? StatusDot(color: s.color, size: 6)
                    : StatusDot(color: s.color.withValues(alpha: 0.4), size: 6),
                onSelected: (on) =>
                    ref.read(caseStatusFilterProvider.notifier).state = on ? s : null,
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: Insets.sm),
            child: ChoiceChip(
              label: const Text('HIGH PRIORITY'),
              selected: priority == CasePriority.high,
              onSelected: (on) =>
                  ref.read(casePriorityFilterProvider.notifier).state =
                      on ? CasePriority.high : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------- Map tab

class MapTab extends ConsumerStatefulWidget {
  const MapTab({super.key});

  @override
  ConsumerState<MapTab> createState() => _MapTabState();
}

class _MapTabState extends ConsumerState<MapTab> {
  String? _caseNo;

  @override
  Widget build(BuildContext context) {
    final cases = ref.watch(foStateProvider).cases;
    final theme = Theme.of(context);

    if (cases.isEmpty) {
      return const Column(
        children: [
          ScreenHeader(title: 'Map'),
          Expanded(
            child: EmptyState(
              icon: Icons.map_outlined,
              title: 'No Parcels',
              message: 'No parcels are available to display on the map.',
            ),
          ),
        ],
      );
    }

    final selected = cases.firstWhere(
      (c) => c.caseNo == _caseNo,
      orElse: () => cases.first,
    );

    return Column(
      children: [
        ScreenHeader(
          title: 'Map',
          subtitle: '${cases.length} parcel${cases.length == 1 ? '' : 's'}',
        ),
        SizedBox(
          height: 52,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Insets.md, vertical: Insets.sm),
            itemCount: cases.length,
            itemBuilder: (_, i) {
              final c = cases[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(c.parcelId),
                  selected: c.caseNo == selected.caseNo,
                  onSelected: (_) => setState(() => _caseNo = c.caseNo),
                ),
              );
            },
          ),
        ),
        // Keyed so switching parcels rebuilds the map with the new geometry
        // instead of mutating a controller that may already be attached.
        Expanded(
          child: ParcelMapScreen(
            key: ValueKey(selected.caseNo),
            caseData: selected,
            embedded: true,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.lg, Insets.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selected.caseNo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                        const Gap(2),
                        Text(
                          '${selected.village} · Survey ${selected.surveyNo}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Gap(Insets.md, horizontal: true),
                  FilledButton.icon(
                    onPressed: () => CaseDetailScreen.open(context, caseNo: selected.caseNo),
                    icon: const Icon(Icons.folder_open, size: 18),
                    label: const Text('OPEN CASE'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 46),
                      padding: const EdgeInsets.symmetric(horizontal: Insets.lg),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
