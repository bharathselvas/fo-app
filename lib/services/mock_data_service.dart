import '../data/mock/mock_cases.dart';
import '../data/mock/mock_documents.dart';
import '../data/mock/mock_evidence.dart';
import '../data/mock/mock_notifications.dart';
import '../data/mock/mock_officer.dart';
import '../data/mock/mock_tasks.dart';
import '../data/models/case_document.dart';
import '../data/models/case_task.dart';
import '../data/models/enums.dart';
import '../data/models/evidence_record.dart';
import '../data/models/field_officer.dart';
import '../data/models/land_case.dart';
import '../data/models/notification_item.dart';

/// Immutable snapshot of everything the Field Officer app renders.
///
/// Screens never read mock data directly — they read this state through
/// `foStateProvider`, so a real API service can be dropped in behind the same
/// shape without touching a single widget.
class FoState {
  const FoState({
    required this.officer,
    required this.cases,
    required this.tasks,
    required this.documents,
    required this.evidence,
    required this.notifications,
  });

  final FieldOfficer officer;
  final List<LandCase> cases;
  final List<CaseTask> tasks;
  final List<CaseDocument> documents;
  final List<EvidenceRecord> evidence;
  final List<AppNotification> notifications;

  factory FoState.initial() => FoState(
        officer: kMockFieldOfficer,
        cases: buildMockCases(),
        tasks: buildMockTasks(),
        documents: buildMockDocuments(),
        evidence: buildMockEvidence(),
        notifications: buildMockNotifications(),
      );

  LandCase? caseByNo(String? caseNo) {
    if (caseNo == null) return null;
    for (final c in cases) {
      if (c.caseNo == caseNo) return c;
    }
    return null;
  }

  List<CaseTask> tasksFor(String caseNo) =>
      tasks.where((t) => t.caseNo == caseNo).toList();

  List<CaseTask> get openTasks =>
      tasks.where((t) => t.status != TaskStatus.completed).toList();

  List<CaseTask> get dueTodayTasks => openTasks
      .where((t) => !t.isOverdue && t.daysUntilDue <= 0)
      .toList()
    ..sort((a, b) => a.priority.rank.compareTo(b.priority.rank));

  List<CaseDocument> documentsFor(String caseNo) =>
      documents.where((d) => d.caseNo == caseNo).toList();

  List<EvidenceRecord> evidenceFor(String caseNo) =>
      evidence.where((e) => e.caseNo == caseNo).toList()
        ..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));

  List<AppNotification> get unreadNotifications =>
      notifications.where((n) => !n.read).toList();

  int get unreadCount => unreadNotifications.length;

  DashboardStats stats() {
    final pendingVerification = cases
        .where((c) =>
            c.status == CaseStatus.verificationPending ||
            c.status == CaseStatus.inProgress)
        .length;
    final completed = cases
        .where((c) =>
            c.status == CaseStatus.completed ||
            c.verificationStatus.toLowerCase() == 'completed')
        .length;
    return DashboardStats(
      assignedCases: cases.length,
      pendingVerification: pendingVerification,
      completed: completed,
      overdue: cases.where((c) => c.isOverdue).length,
      openTasks: openTasks.length,
      dueToday: dueTodayTasks.length,
      unreadNotifications: unreadCount,
    );
  }
}

class DashboardStats {
  const DashboardStats({
    required this.assignedCases,
    required this.pendingVerification,
    required this.completed,
    required this.overdue,
    required this.openTasks,
    required this.dueToday,
    required this.unreadNotifications,
  });

  final int assignedCases;
  final int pendingVerification;
  final int completed;
  final int overdue;
  final int openTasks;
  final int dueToday;
  final int unreadNotifications;
}

enum CaseSort { dueDate, priority, updated, caseNo }

/// All state transitions of the prototype. Pure functions: state in, new state
/// out — no Flutter, no I/O, trivially replaceable by an API client.
class MockDataService {
  const MockDataService();

  /// Marks the case as under field verification and starts its open tasks.
  FoState beginVerification(FoState current, String caseNo) {
    final before = current.caseByNo(caseNo);
    if (before == null || before.status == CaseStatus.completed) return current;

    final updated = before.copyWith(
      status: CaseStatus.inProgress,
      verificationStatus: 'In Progress',
      pendingAction: 'Complete field verification checklist',
      lastUpdated: DateTime.now(),
      timeline: before.timelineWithAppended('Field Verification Started'),
    );

    return FoState(
      officer: current.officer,
      cases: _replace(current.cases, updated),
      tasks: [
        for (final t in current.tasks)
          t.caseNo == caseNo && t.status == TaskStatus.pending
              ? t.copyWith(status: TaskStatus.inProgress)
              : t,
      ],
      documents: current.documents,
      evidence: current.evidence,
      notifications: current.notifications,
    );
  }

  /// Records one piece of evidence captured during verification.
  FoState addCaseEvidence(FoState current, EvidenceRecord record) => FoState(
        officer: current.officer,
        cases: current.cases,
        tasks: current.tasks,
        documents: current.documents,
        evidence: [...current.evidence, record],
        notifications: current.notifications,
      );

  /// Called when the officer submits the field verification form.
  FoState submitVerification(
    FoState current, {
    required String caseNo,
    required int evidenceCount,
    required bool gpsCaptured,
    required bool queuedOffline,
  }) {
    final before = current.caseByNo(caseNo);
    if (before == null) return current;

    final updated = before.copyWith(
      status: CaseStatus.officerReview,
      stage: 'Officer Review',
      verificationStatus: 'Completed',
      pendingAction: 'Awaiting review by District Authority',
      lastUpdated: DateTime.now(),
      timeline: before.timelineWithAppended('Field Verification Submitted'),
    );

    final note = AppNotification(
      id: 'N-${DateTime.now().millisecondsSinceEpoch}',
      kind: NotificationKind.verification,
      title: 'Field verification submitted',
      body:
          '$caseNo submitted with $evidenceCount evidence file${evidenceCount == 1 ? '' : 's'} · '
          '${gpsCaptured ? 'GPS verified' : 'GPS unavailable'} · '
          '${queuedOffline ? 'queued for sync' : 'synced'}.',
      createdAt: DateTime.now(),
      caseNo: caseNo,
    );

    return FoState(
      officer: current.officer,
      cases: _replace(current.cases, updated),
      tasks: [
        for (final t in current.tasks)
          t.caseNo == caseNo && t.status != TaskStatus.completed
              ? t.copyWith(status: TaskStatus.completed, pendingFiles: 0)
              : t,
      ],
      documents: current.documents,
      evidence: current.evidence,
      notifications: [note, ...current.notifications],
    );
  }

  FoState markNotificationRead(FoState current, String id) => FoState(
        officer: current.officer,
        cases: current.cases,
        tasks: current.tasks,
        documents: current.documents,
        evidence: current.evidence,
        notifications: [
          for (final n in current.notifications)
            n.id == id && !n.read ? n.copyWith(read: true) : n,
        ],
      );

  FoState markAllNotificationsRead(FoState current) => FoState(
        officer: current.officer,
        cases: current.cases,
        tasks: current.tasks,
        documents: current.documents,
        evidence: current.evidence,
        notifications: [for (final n in current.notifications) n.copyWith(read: true)],
      );

  /// Flips every locally-held record to SYNCED once the queue drains.
  FoState markUploadsComplete(FoState current) {
    final hadPending = current.evidence.any((e) => e.uploadStatus == UploadStatus.pending) ||
        current.tasks.any((t) => t.pendingFiles > 0);
    if (!hadPending) return current;

    final note = AppNotification(
      id: 'N-${DateTime.now().millisecondsSinceEpoch}',
      kind: NotificationKind.syncComplete,
      title: 'SYNC COMPLETE',
      body:
          '${current.evidence.where((e) => e.uploadStatus == UploadStatus.pending).length + current.tasks.where((t) => t.pendingFiles > 0).length} field records uploaded successfully.',
      createdAt: DateTime.now(),
    );

    return FoState(
      officer: current.officer,
      cases: current.cases,
      tasks: [
        for (final t in current.tasks)
          t.pendingFiles > 0 ? t.copyWith(pendingFiles: 0) : t,
      ],
      documents: current.documents,
      evidence: [
        for (final e in current.evidence)
          e.uploadStatus == UploadStatus.pending
              ? e.copyWith(uploadStatus: UploadStatus.synced)
              : e,
      ],
      notifications: [note, ...current.notifications],
    );
  }

  /// Document review action taken from the document preview screen.
  FoState setDocumentStatus(FoState current, String docId, DocumentStatus status) =>
      FoState(
        officer: current.officer,
        cases: current.cases,
        tasks: current.tasks,
        documents: [
          for (final d in current.documents)
            d.id == docId ? d.copyWith(status: status) : d,
        ],
        evidence: current.evidence,
        notifications: current.notifications,
      );

  List<LandCase> _replace(List<LandCase> all, LandCase updated) => [
        for (final c in all) c.caseNo == updated.caseNo ? updated : c,
      ];
}

/// Applies the case-list search box, status/priority filters and sort order.
List<LandCase> applyCaseQuery(
  List<LandCase> cases, {
  required String query,
  CaseStatus? status,
  CasePriority? priority,
  required CaseSort sort,
}) {
  final q = query.trim().toLowerCase();
  var result = cases.where((c) {
    if (status != null && c.status != status) return false;
    if (priority != null && c.priority != priority) return false;
    if (q.isEmpty) return true;
    return c.caseNo.toLowerCase().contains(q) ||
        c.projectName.toLowerCase().contains(q) ||
        c.village.toLowerCase().contains(q) ||
        c.taluk.toLowerCase().contains(q) ||
        c.surveyNo.toLowerCase().contains(q) ||
        c.landOwner.name.toLowerCase().contains(q) ||
        c.parcelId.toLowerCase().contains(q);
  }).toList();

  result.sort((a, b) {
    switch (sort) {
      case CaseSort.dueDate:
        return a.dueDate.compareTo(b.dueDate);
      case CaseSort.priority:
        final byPriority = a.priority.rank.compareTo(b.priority.rank);
        return byPriority != 0 ? byPriority : a.dueDate.compareTo(b.dueDate);
      case CaseSort.updated:
        return b.lastUpdated.compareTo(a.lastUpdated);
      case CaseSort.caseNo:
        return b.caseNo.compareTo(a.caseNo);
    }
  });
  return result;
}
