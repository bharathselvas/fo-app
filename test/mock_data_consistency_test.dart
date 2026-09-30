// Locks the demo dataset to the scenario the SIH prototype must demonstrate,
// and — more importantly — locks its internal consistency. Every case, task,
// document, evidence row and notification is keyed off `caseNo`; if any of
// them ever drifts apart, this test fails instead of the judges noticing.
import 'package:flutter_test/flutter_test.dart';

import 'package:terranex_fo/data/models/enums.dart';
import 'package:terranex_fo/services/mock_data_service.dart';

void main() {
  late FoState s;

  setUp(() => s = FoState.initial());

  int withStatus(CaseStatus status) =>
      s.cases.where((c) => c.status == status).length;

  test('dataset volume covers the required demo scenario', () {
    expect(s.cases.length, greaterThanOrEqualTo(10));
    expect(s.tasks.length, greaterThanOrEqualTo(10));
    expect(s.evidence.length, greaterThanOrEqualTo(15));
    expect(s.documents.length, greaterThanOrEqualTo(10));
    expect(s.notifications.length, greaterThanOrEqualTo(8));
    expect(
      s.cases.fold<int>(0, (a, c) => a + c.timeline.length),
      greaterThanOrEqualTo(15),
      reason: 'timeline events across all cases',
    );
  });

  test('status and priority mix demonstrates every branch', () {
    expect(s.cases.where((c) => c.priority == CasePriority.high).length,
        greaterThanOrEqualTo(2));
    expect(s.cases.where((c) => c.isOverdue).length, greaterThanOrEqualTo(2));
    expect(withStatus(CaseStatus.verificationPending), greaterThanOrEqualTo(3));
    expect(withStatus(CaseStatus.inProgress), greaterThanOrEqualTo(2));
    expect(withStatus(CaseStatus.completed), greaterThanOrEqualTo(2));
    expect(withStatus(CaseStatus.compensationPending), greaterThanOrEqualTo(1));
    expect(withStatus(CaseStatus.awaitingDocuments), greaterThanOrEqualTo(1));
    expect(withStatus(CaseStatus.rrVerification), greaterThanOrEqualTo(1));
    expect(withStatus(CaseStatus.possessionPending), greaterThanOrEqualTo(1));
  });

  test('every relation resolves to a real case', () {
    final caseNos = s.cases.map((c) => c.caseNo).toSet();
    final taskIds = s.tasks.map((t) => t.id).toSet();

    expect(s.tasks.map((t) => t.caseNo).toSet().difference(caseNos), isEmpty,
        reason: 'every task points at a real case');
    expect(s.documents.map((d) => d.caseNo).toSet().difference(caseNos), isEmpty,
        reason: 'every document points at a real case');
    expect(s.evidence.map((e) => e.caseNo).toSet().difference(caseNos), isEmpty,
        reason: 'every evidence row points at a real case');

    for (final n in s.notifications) {
      if (n.caseNo != null) {
        expect(caseNos, contains(n.caseNo), reason: 'notification ${n.id} case link');
      }
      if (n.taskId != null) {
        expect(taskIds, contains(n.taskId), reason: 'notification ${n.id} task link');
      }
    }
  });

  test('each case carries a parcel, an owner, a task and a timeline', () {
    for (final c in s.cases) {
      expect(c.parcelId, isNotEmpty, reason: '${c.caseNo} parcel');
      expect(c.surveyNo, isNotEmpty, reason: '${c.caseNo} survey number');
      expect(c.latitude, isNot(0), reason: '${c.caseNo} latitude');
      expect(c.longitude, isNot(0), reason: '${c.caseNo} longitude');
      expect(c.geometryWkt, startsWith('POLYGON'), reason: '${c.caseNo} geometry');
      expect(c.landOwner.name, isNotEmpty, reason: '${c.caseNo} landowner');
      expect(c.timeline, isNotEmpty, reason: '${c.caseNo} timeline');
      expect(s.tasksFor(c.caseNo), isNotEmpty, reason: '${c.caseNo} task');
    }
    expect(s.cases.map((c) => c.parcelId).toSet().length, s.cases.length,
        reason: 'parcel ids are unique');
    expect(s.cases.map((c) => c.caseNo).toSet().length, s.cases.length,
        reason: 'case numbers are unique');
  });

  test("dashboard numbers are derived, and Today's Work is never empty", () {
    final stats = s.stats();
    expect(stats.assignedCases, s.cases.length);
    expect(stats.overdue, s.cases.where((c) => c.isOverdue).length);
    expect(stats.unreadNotifications, s.notifications.where((n) => !n.read).length);
    expect(stats.openTasks, s.openTasks.length);
    expect(stats.dueToday, s.dueTodayTasks.length);

    // A task due today must be counted as due today, never as overdue.
    expect(s.dueTodayTasks, isNotEmpty,
        reason: "the officer's Today's Work list must have work on it");
  });

  test('a case due today is not counted as overdue', () {
    // Boundary: same-day due date must read "Due today", never overdue.
    for (final c in s.cases.where((c) => c.daysUntilDue == 0)) {
      expect(c.isOverdue, isFalse, reason: '${c.caseNo} due today');
      expect(c.dueLabel, 'Due today');
    }
    for (final t in s.openTasks.where((t) => t.daysUntilDue == 0)) {
      expect(t.isOverdue, isFalse, reason: '${t.id} due today');
      expect(t.slaLabel, 'DUE TODAY');
    }
    // And a genuinely past date on an open case is still overdue. Completed
    // cases are exempt by design regardless of their due date.
    for (final c in s.cases.where(
        (c) => c.daysUntilDue < 0 && c.status != CaseStatus.completed)) {
      expect(c.isOverdue, isTrue, reason: '${c.caseNo} past due');
    }
    for (final c in s.cases.where((c) => c.status == CaseStatus.completed)) {
      expect(c.isOverdue, isFalse, reason: '${c.caseNo} completed');
      expect(c.dueLabel, 'Completed');
    }
  });

  test('submitting a verification moves case, task, stats and notifications', () {
    const caseNo = 'LA-TN-CBE-2026-0142';
    final before = s.stats();

    final after = const MockDataService().submitVerification(
      s,
      caseNo: caseNo,
      evidenceCount: 3,
      gpsCaptured: true,
      queuedOffline: true,
    );

    final updated = after.caseByNo(caseNo)!;
    expect(updated.verificationStatus, 'Completed');
    expect(updated.stage, 'Officer Review');
    expect(updated.pendingAction, contains('District Authority'));
    expect(updated.timeline.last.title, 'Field Verification Submitted');

    // Every open task on that case is closed out.
    for (final t in after.tasksFor(caseNo)) {
      expect(t.status, TaskStatus.completed, reason: 'task ${t.id}');
      expect(t.pendingFiles, 0);
    }

    // And the dashboard moves with it.
    final stats = after.stats();
    expect(stats.pendingVerification, lessThan(before.pendingVerification));
    expect(stats.openTasks, lessThan(before.openTasks));
    expect(stats.unreadNotifications, before.unreadNotifications + 1);
    expect(after.notifications.first.caseNo, caseNo);
  });

  test('sync completion flips pending evidence and tasks', () {
    final pendingBefore =
        s.evidence.where((e) => e.uploadStatus == UploadStatus.pending).length;
    expect(pendingBefore, greaterThan(0));

    final after = const MockDataService().markUploadsComplete(s);
    expect(
      after.evidence.where((e) => e.uploadStatus == UploadStatus.pending),
      isEmpty,
    );
    expect(after.tasks.where((t) => t.pendingFiles > 0), isEmpty);
    expect(after.notifications.first.kind, NotificationKind.syncComplete);
  });

  test('search and filters actually narrow the dataset', () {
    final all = applyCaseQuery(s.cases,
        query: '', sort: CaseSort.dueDate);
    expect(all.length, s.cases.length);

    final byId = applyCaseQuery(s.cases, query: '0142', sort: CaseSort.dueDate);
    expect(byId, isNotEmpty);
    expect(byId.every((c) => c.caseNo.contains('0142')), isTrue);

    final byOwner = applyCaseQuery(s.cases,
        query: 'subramanian', sort: CaseSort.dueDate);
    expect(byOwner, isNotEmpty,
        reason: 'search must match the landowner name too');

    final highOnly = applyCaseQuery(s.cases,
        query: '', priority: CasePriority.high, sort: CaseSort.dueDate);
    expect(highOnly, isNotEmpty);
    expect(highOnly.length, lessThan(all.length));
    expect(highOnly.every((c) => c.priority == CasePriority.high), isTrue);

    final completedOnly = applyCaseQuery(s.cases,
        query: '', status: CaseStatus.completed, sort: CaseSort.dueDate);
    expect(completedOnly.every((c) => c.status == CaseStatus.completed), isTrue);

    // Sorting must actually reorder.
    final byPriority = applyCaseQuery(s.cases, query: '', sort: CaseSort.priority);
    final ranks = byPriority.map((c) => c.priority.rank).toList();
    expect(ranks, orderedEquals([...ranks]..sort()));
  });
}
