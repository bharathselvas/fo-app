import '../models/enums.dart';
import '../models/notification_item.dart';
import 'mock_dates.dart';

/// Notifications waiting for the officer in the app.
List<AppNotification> buildMockNotifications() {
  final seeds = <_NoteSeed>[
    _NoteSeed('N-001', NotificationKind.priority, 'Verification due tomorrow',
        'Case LA-TN-CBE-2026-0138 must be verified before the SLA closes.',
        caseNo: 'LA-TN-CBE-2026-0138', taskId: 'TASK-0138', dayOffset: 0, hour: 8, minute: 15),
    _NoteSeed('N-002', NotificationKind.taskAssigned, 'New parcel verification assigned',
        'TASK-0142 — Parcel Boundary Verification at Kittampalayam.',
        caseNo: 'LA-TN-CBE-2026-0142', taskId: 'TASK-0142', dayOffset: -2, hour: 9, minute: 5),
    _NoteSeed('N-003', NotificationKind.slaAlert, 'Task TASK-0115 is overdue',
        'Boundary dispute follow-up is past its due date. Escalate if blocked.',
        caseNo: 'LA-TN-CBE-2026-0115', taskId: 'TASK-0115', dayOffset: -5, hour: 10, minute: 30),
    _NoteSeed('N-004', NotificationKind.priority, 'Evidence upload overdue',
        'Two field photographs are still pending on LA-TN-CBE-2026-0119.',
        caseNo: 'LA-TN-CBE-2026-0119', taskId: 'TASK-0119', dayOffset: -3, hour: 17, minute: 2),
    _NoteSeed('N-005', NotificationKind.documentUpdate, 'New survey document added',
        'Survey Sketch (PDF) added to case LA-TN-CBE-2026-0142.',
        caseNo: 'LA-TN-CBE-2026-0142', dayOffset: -8, hour: 12, minute: 44, read: true),
    _NoteSeed('N-006', NotificationKind.documentUpdate, 'Award document not available',
        'Award Document has not been published yet for LA-TN-CBE-2026-0142.',
        caseNo: 'LA-TN-CBE-2026-0142', dayOffset: -7, hour: 14, minute: 10, read: true),
    _NoteSeed('N-007', NotificationKind.taskAssigned, 'Possession site inspection assigned',
        'TASK-0127 at Vellalore is now in progress.',
        caseNo: 'LA-TN-CBE-2026-0127', taskId: 'TASK-0127', dayOffset: -2, hour: 9, minute: 40, read: true),
    _NoteSeed('N-008', NotificationKind.syncComplete, '4 field records uploaded successfully',
        'Field visits and evidence from the last online session are now on the server.',
        dayOffset: -1, hour: 18, minute: 25, read: true),
    _NoteSeed('N-009', NotificationKind.slaAlert, 'Case LA-TN-CBE-2026-0119 is overdue',
        'Verification was due 3 days ago. Update the case or request an extension.',
        caseNo: 'LA-TN-CBE-2026-0119', dayOffset: -3, hour: 9, minute: 12),
  ];

  return [
    for (final s in seeds)
      AppNotification(
        id: s.id,
        kind: s.kind,
        title: s.title,
        body: s.body,
        createdAt: day(s.dayOffset).add(Duration(hours: s.hour, minutes: s.minute)),
        caseNo: s.caseNo,
        taskId: s.taskId,
        read: s.read,
      ),
  ];
}

class _NoteSeed {
  const _NoteSeed(
    this.id,
    this.kind,
    this.title,
    this.body, {
    this.caseNo,
    this.taskId,
    required this.dayOffset,
    required this.hour,
    required this.minute,
    this.read = false,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final String? caseNo;
  final String? taskId;
  final int dayOffset;
  final int hour;
  final int minute;
  final bool read;
}
