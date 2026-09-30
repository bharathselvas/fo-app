import 'enums.dart';

/// An in-app notification for the field officer.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    this.caseNo,
    this.taskId,
    this.read = false,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? caseNo;
  final String? taskId;
  final bool read;

  bool get actionable => caseNo != null;

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        kind: kind,
        title: title,
        body: body,
        createdAt: createdAt,
        caseNo: caseNo,
        taskId: taskId,
        read: read ?? this.read,
      );
}
