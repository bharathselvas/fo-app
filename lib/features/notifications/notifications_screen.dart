import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_routes.dart';
import '../../core/theme/tokens.dart';
import '../../data/models/enums.dart';
import '../../data/models/notification_item.dart';
import '../../services/fo_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';
import '../cases/case_detail_screen.dart';

/// Full notification inbox, reachable from the dashboard bell.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(AppRoutes.fadeUp(const NotificationsScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(foStateProvider);
    final notifications = state.notifications;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: () =>
                  ref.read(foStateProvider.notifier).markAllNotificationsRead(),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: Text('MARK ALL READ (${state.unreadCount})'),
            ),
          const SizedBox(width: Insets.sm),
        ],
      ),
      body: notifications.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_none,
              title: 'No Notifications',
              message: 'Updates about your cases, tasks and sync status appear here.',
            )
          : ListView.builder(
              key: const PageStorageKey('notifications-list'),
              padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.lg, Insets.xxl),
              itemCount: notifications.length,
              itemBuilder: (_, i) => Padding(
                key: ValueKey(notifications[i].id),
                padding: const EdgeInsets.only(bottom: Insets.sm),
                child: _NotificationTile(notification: notifications[i]),
              ),
            ),
      bottomNavigationBar: state.unreadCount > 0
          ? Material(
              color: AppColors.surface,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Insets.lg,
                    vertical: Insets.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${state.unreadCount} UNREAD',
                        style: theme.textTheme.labelSmall,
                      ),
                      Text(
                        '${notifications.length} TOTAL',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  static final _timeFmt = DateFormat('d MMM, h:mm a');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = notification;
    final theme = Theme.of(context);

    return TappableCard(
      onTap: () {
        if (!n.read) ref.read(foStateProvider.notifier).markNotificationRead(n.id);
        if (n.caseNo != null) CaseDetailScreen.open(context, caseNo: n.caseNo!);
      },
      color: n.read ? AppColors.surface : AppColors.successSoft,
      borderColor: n.read ? null : AppColors.success.withValues(alpha: 0.24),
      padding: const EdgeInsets.all(Insets.md + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: n.kind.color.withValues(alpha: 0.14),
              borderRadius: Radii.smAll,
            ),
            child: Icon(_iconFor(n), size: 18, color: n.kind.color),
          ),
          const Gap(Insets.md, horizontal: true),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(n.title, style: theme.textTheme.titleMedium!.copyWith(fontSize: 14)),
                    ),
                    if (!n.read) ...[
                      const Gap(Insets.sm, horizontal: true),
                      const Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: StatusDot(color: AppColors.brand, size: 8),
                      ),
                    ],
                  ],
                ),
                const Gap(2),
                Text(n.body, style: theme.textTheme.bodySmall),
                const Gap(Insets.sm),
                Wrap(
                  spacing: Insets.sm,
                  runSpacing: Insets.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppChip(
                      label: n.kind.label,
                      color: n.kind.color,
                      dense: true,
                    ),
                    Text(
                      _timeFmt.format(n.createdAt),
                      style: theme.textTheme.bodySmall!.copyWith(fontSize: 11.5),
                    ),
                    if (n.caseNo != null)
                      Text(
                        n.caseNo!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall!.copyWith(fontSize: 11.5),
                      ),
                  ],
                ),
                if (n.caseNo != null) ...[
                  const Gap(Insets.sm),
                  Row(
                    children: [
                      Text(
                        'OPEN CASE',
                        style: theme.textTheme.labelSmall!.copyWith(color: AppColors.brand),
                      ),
                      const Icon(Icons.chevron_right, size: 14, color: AppColors.brand),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(AppNotification n) => switch (n.kind) {
        NotificationKind.priority => Icons.priority_high,
        NotificationKind.taskAssigned => Icons.assignment_outlined,
        NotificationKind.syncComplete => Icons.cloud_done,
        NotificationKind.slaAlert => Icons.timer_outlined,
        NotificationKind.documentUpdate => Icons.description_outlined,
        NotificationKind.verification => Icons.fact_check_outlined,
      };
}
