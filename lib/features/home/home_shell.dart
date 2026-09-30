import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/connectivity_service.dart';
import '../../data/models/enums.dart';
import '../../data/models/land_case.dart';
import '../../services/fo_providers.dart';
import '../../services/mock_data_service.dart' show CaseSort;
import '../../widgets/common.dart';
import '../../widgets/status_widgets.dart';
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
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(_tabIndexProvider);
    final pending = ref.watch(pendingSyncCountProvider);

    final screens = [
      HomeDashboard(onOpenTab: (i) => ref.read(_tabIndexProvider.notifier).state = i),
      const CasesTab(),
      const MapTab(),
      const SyncCenterScreen(),
      const MoreScreen(),
    ];

    return Scaffold(
      body: Column(
        children: [
          ConnectionBanner(pendingCount: pending),
          Expanded(child: screens[tab]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tab,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => ref.read(_tabIndexProvider.notifier).state = i,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), label: 'Cases'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.sync_outlined), label: 'Sync'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
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

    final todayTasks = [...state.dueTodayTasks, ...state.openTasks]
        .where((t) => !state.dueTodayTasks.contains(t))
        .toList()
      ..sort((a, b) {
        final byDue = a.dueDate.compareTo(b.dueDate);
        return byDue != 0 ? byDue : a.priority.rank.compareTo(b.priority.rank);
      });
    final showTasks = todayTasks.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('BHOOMI SETU'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: StatusChip(
                label: _connLabel(conn),
                color: _connColor(conn),
                icon: Icons.circle,
              ),
            ),
          ),
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
      body: RefreshIndicator(
        onRefresh: () => ref.read(connectivityServiceProvider).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _greetingCard(context, officer.name, officer.designation, officer.department, officer.assignedArea, officer.officerId),
            const SizedBox(height: 16),
            _statsBlock(context, stats, pending, ref),
            const SizedBox(height: 20),
            _sectionHeader(
              context,
              "TODAY'S TASKS",
              actionLabel: 'VIEW ALL',
              onAction: () => TasksScreen.open(context),
            ),
            const SizedBox(height: 4),
            if (showTasks.isEmpty)
              const EmptyState(
                icon: Icons.task_alt,
                title: 'No Tasks Due Today',
                message: 'You are clear for today. Check the case list for upcoming work.',
              )
            else
              ...showTasks.map((t) => TaskCard(task: t)),
            const SizedBox(height: 12),
            _syncCard(context, onOpenTab, pending, conn),
            const SizedBox(height: 20),
            _sectionHeader(
              context,
              'NOTIFICATIONS',
              actionLabel: 'VIEW ALL',
              onAction: () => NotificationsScreen.open(context),
            ),
            const SizedBox(height: 4),
            if (state.notifications.isEmpty)
              const EmptyState(
                icon: Icons.notifications_none,
                title: 'No Notifications',
                message: 'Case, task and sync updates will appear here.',
              )
            else
              ...state.notifications.take(3).map(
                    (n) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: n.kind.color.withValues(alpha: 0.14),
                          child: Icon(Icons.notifications, size: 16, color: n.kind.color),
                        ),
                        title: Text(n.title,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: Text(n.body,
                            maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5)),
                        trailing: n.read ? null : const Icon(Icons.fiber_manual_record, size: 10, color: Color(0xFF2E7D32)),
                        onTap: () => NotificationsScreen.open(context),
                      ),
                    ),
                  ),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: () => ProfileScreen.open(context),
                icon: const Icon(Icons.badge_outlined),
                label: const Text('MY PROFILE'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _greetingCard(
    BuildContext context,
    String name,
    String designation,
    String department,
    String area,
    String officerId,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFF1B5E20),
              child: Text(
                name.isEmpty
                    ? '?'
                    : name.split(' ').map((p) => p.isEmpty ? '' : p[0]).take(2).join(),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_greetingWord()}, ${name.split(' ').first}',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '$designation · $department',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Jurisdiction: $area',
                    style: TextStyle(fontSize: 12.5, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            StatusChip(label: officerId, color: Colors.indigo, icon: Icons.badge_outlined),
          ],
        ),
      ),
    );
  }

  String _greetingWord() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _statsBlock(BuildContext context, dynamic stats, int pending, WidgetRef ref) {
    return Column(
      children: [
        Row(
          children: [
            StatTile(
              value: '${stats.assignedCases}',
              label: 'Cases',
              color: Colors.indigo,
              onTap: () => ref.read(_tabIndexProvider.notifier).state = 1,
            ),
            const SizedBox(width: 8),
            StatTile(
              value: '${stats.pendingVerification}',
              label: 'Pending',
              color: const Color(0xFFF57F17),
              onTap: () => ref.read(_tabIndexProvider.notifier).state = 1,
            ),
            const SizedBox(width: 8),
            StatTile(
              value: '${stats.completed}',
              label: 'Completed',
              color: const Color(0xFF2E7D32),
              onTap: () => ref.read(_tabIndexProvider.notifier).state = 1,
            ),
            const SizedBox(width: 8),
            StatTile(
              value: '${stats.overdue}',
              label: 'Overdue',
              color: const Color(0xFFB71C1C),
              onTap: () => ref.read(_tabIndexProvider.notifier).state = 1,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            StatTile(
              value: '${stats.openTasks}',
              label: 'Open tasks',
              color: Colors.blueGrey,
              onTap: () => TasksScreen.open(context),
            ),
            const SizedBox(width: 8),
            StatTile(
              value: '${stats.dueToday}',
              label: 'Due today',
              color: Colors.deepOrange,
              onTap: () => TasksScreen.open(context),
            ),
            const SizedBox(width: 8),
            StatTile(
              value: '${stats.unreadNotifications}',
              label: 'Alerts',
              color: Colors.purple,
              onTap: () => NotificationsScreen.open(context),
            ),
            const SizedBox(width: 8),
            StatTile(
              value: '$pending',
              label: 'Queued',
              color: Colors.teal,
              onTap: () => ref.read(_tabIndexProvider.notifier).state = 3,
            ),
          ],
        ),
      ],
    );
  }

  Widget _syncCard(BuildContext context, void Function(int) onOpenTab, int pending, ConnectionStatus conn) {
    final (label, color) = switch (conn) {
      ConnectionStatus.online => pending == 0
          ? ('ONLINE — SYNCED', Color(0xFF2E7D32))
          : ('ONLINE — $pending ITEMS PENDING', Color(0xFF1565C0)),
      ConnectionStatus.offline => ('OFFLINE — $pending ITEMS PENDING', Color(0xFFB71C1C)),
      ConnectionStatus.syncing => ('SYNCING…', Color(0xFFF57F17)),
      ConnectionStatus.serverUnavailable => ('SERVER UNAVAILABLE — OFFLINE MODE', Color(0xFFE65100)),
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              conn == ConnectionStatus.online ? Icons.cloud_done : Icons.cloud_off,
              color: color,
              size: 30,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: color)),
                  const SizedBox(height: 4),
                  Text(
                    pending == 0
                        ? 'All field records are uploaded.'
                        : '$pending record${pending == 1 ? '' : 's'} waiting to upload from this device.',
                    style: TextStyle(fontSize: 12.5, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            FilledButton.tonal(
              onPressed: () => onOpenTab(3),
              child: const Text('SYNC'),
            ),
          ],
        ),
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
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: Colors.grey[800],
              ),
        ),
        const Spacer(),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }

  String _connLabel(ConnectionStatus s) => switch (s) {
        ConnectionStatus.online => 'ONLINE',
        ConnectionStatus.offline => 'OFFLINE',
        ConnectionStatus.syncing => 'SYNCING',
        ConnectionStatus.serverUnavailable => 'SERVER DOWN',
      };

  Color _connColor(ConnectionStatus s) => switch (s) {
        ConnectionStatus.online => Colors.green.shade700,
        ConnectionStatus.offline => Colors.red.shade700,
        ConnectionStatus.syncing => Colors.orange.shade800,
        ConnectionStatus.serverUnavailable => Colors.deepOrange.shade800,
      };
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cases'),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              onChanged: (v) => ref.read(caseSearchQueryProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Search case, village, survey no, owner…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => ref.read(caseSearchQueryProvider.notifier).state = '',
                      ),
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: ChoiceChip(
                    label: const Text('ALL'),
                    selected: status == null && priority == null,
                    onSelected: (_) {
                      ref.read(caseStatusFilterProvider.notifier).state = null;
                      ref.read(casePriorityFilterProvider.notifier).state = null;
                    },
                  ),
                ),
                for (final s in const [
                  CaseStatus.verificationPending,
                  CaseStatus.inProgress,
                  CaseStatus.overdue,
                  CaseStatus.completed,
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: ChoiceChip(
                      label: Text(s.label.toUpperCase()),
                      selected: status == s,
                      onSelected: (on) =>
                          ref.read(caseStatusFilterProvider.notifier).state = on ? s : null,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${cases.length} CASE${cases.length == 1 ? '' : 'S'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                if (query.isNotEmpty || status != null || priority != null)
                  TextButton(
                    onPressed: () {
                      ref.read(caseSearchQueryProvider.notifier).state = '';
                      ref.read(caseStatusFilterProvider.notifier).state = null;
                      ref.read(casePriorityFilterProvider.notifier).state = null;
                    },
                    child: const Text('RESET'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: cases.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off,
                    title: 'No Matching Cases',
                    message: 'Try a different search term or clear the filters.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: cases.length,
                    itemBuilder: (_, i) => CaseCard(caseData: cases[i]),
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
    if (cases.isEmpty) {
      return const Scaffold(body: EmptyState(icon: Icons.map, title: 'No Parcels', message: 'No parcels to display.'));
    }
    LandCase selected = cases.firstWhere(
      (c) => c.caseNo == _caseNo,
      orElse: () => cases.first,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final c in cases)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(c.parcelId, style: const TextStyle(fontSize: 12.5)),
                      selected: c.caseNo == selected.caseNo,
                      onSelected: (_) => setState(() => _caseNo = c.caseNo),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ParcelMapScreen(caseData: selected, embedded: true),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(selected.caseNo,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        Text(
                          '${selected.village} · Survey ${selected.surveyNo}',
                          style: TextStyle(fontSize: 12.5, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => CaseDetailScreen.open(context, caseNo: selected.caseNo),
                    icon: const Icon(Icons.folder_open),
                    label: const Text('OPEN CASE'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
