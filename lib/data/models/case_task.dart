import 'enums.dart';

/// An assigned field task (Task management section).
class CaseTask {
  const CaseTask({
    required this.id,
    required this.caseNo,
    required this.title,
    required this.priority,
    required this.assignedDate,
    required this.dueDate,
    required this.status,
    this.instructions,
    this.pendingFiles = 0,
  });

  /// e.g. `TASK-0142`.
  final String id;
  final String caseNo;
  final String title;
  final CasePriority priority;
  final DateTime assignedDate;
  final DateTime dueDate;
  final TaskStatus status;
  final String? instructions;

  /// Non-zero for tasks waiting on local files (e.g. evidence upload).
  final int pendingFiles;

  /// Overdue = the due date has passed. A task due *today* is not yet overdue,
  /// it is due today — otherwise it would be hidden from Today's Work.
  bool get isOverdue =>
      status != TaskStatus.completed && _dateOnly(dueDate).isBefore(_dateOnly(DateTime.now()));

  int get daysUntilDue => _dateOnly(dueDate).difference(_dateOnly(DateTime.now())).inDays;

  /// SLA line shown on the task card, e.g. `2 DAYS REMAINING`.
  String get slaLabel {
    if (status == TaskStatus.completed) return 'SLA MET';
    final d = daysUntilDue;
    if (d < 0) return 'OVERDUE BY ${-d} DAY${-d == 1 ? '' : 'S'}';
    if (d == 0) return 'DUE TODAY';
    if (d == 1) return '1 DAY REMAINING';
    return '$d DAYS REMAINING';
  }

  CaseTask copyWith({TaskStatus? status, int? pendingFiles}) => CaseTask(
        id: id,
        caseNo: caseNo,
        title: title,
        priority: priority,
        assignedDate: assignedDate,
        dueDate: dueDate,
        status: status ?? this.status,
        instructions: instructions,
        pendingFiles: pendingFiles ?? this.pendingFiles,
      );
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
