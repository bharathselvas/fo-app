import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/enums.dart';
import '../../data/models/notification_item.dart';
import '../../services/fo_providers.dart';
import '../../widgets/common.dart';
import '../cases/case_detail_screen.dart';

/// Full notification inbox, reachable from the dashboard bell.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const NotificationsScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(foStateProvider);
    final notifications = state.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(foStateProvider.notifier).markAllNotificationsRead(),
              child: const Text('MARK ALL READ'),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_none,
              title: 'No Notifications',
              message: 'Updates about your cases, tasks and sync status appear here.',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: notifications.length,
              itemBuilder: (_, i) => _NotificationTile(notification: notifications[i]),
            ),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: n.read ? null : const Color(0xFFE8F5E9),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (!n.read) ref.read(foStateProvider.notifier).markNotificationRead(n.id);
          if (n.caseNo != null) CaseDetailScreen.open(context, caseNo: n.caseNo!);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: n.kind.color.withValues(alpha: 0.14),
                child: Icon(_iconFor(n), size: 18, color: n.kind.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                          ),
                        ),
                        if (!n.read)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(n.body, style: const TextStyle(fontSize: 13, height: 1.4)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          n.kind.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: n.kind.color,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _timeFmt.format(n.createdAt),
                          style: TextStyle(fontSize: 11.5, color: Colors.grey[600]),
                        ),
                        if (n.caseNo != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            n.caseNo!,
                            style: TextStyle(fontSize: 11.5, color: Colors.grey[600]),
                          ),
                        ],
                      ],
                    ),
                    if (n.caseNo != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'OPEN CASE ›',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
