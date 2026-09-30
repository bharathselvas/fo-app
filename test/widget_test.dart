import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:terranex_fo/data/models/enums.dart';
import 'package:terranex_fo/data/models/evidence_record.dart';
import 'package:terranex_fo/features/auth/auth_providers.dart';
import 'package:terranex_fo/services/fo_providers.dart';

void main() {
  test('test harness runs', () {
    expect(true, isTrue);
  });

  test('offline demo session starts with a signed-in field officer', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final user = container.read(currentUserProvider);
    expect(user.id, isNotEmpty);
    expect(user.name, isNotEmpty);
    expect(user.district, isNotEmpty);
  });

  test('mock dataset is internally consistent', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(foStateProvider);

    // Ten core demo cases plus the three status-coverage cases.
    expect(state.cases.length, 13);
    expect(state.tasks.length, greaterThanOrEqualTo(10));
    expect(state.evidence.length, greaterThanOrEqualTo(15));
    expect(state.documents.length, greaterThanOrEqualTo(10));
    expect(state.notifications.length, greaterThanOrEqualTo(8));
    expect(
      state.cases.fold<int>(0, (n, c) => n + c.timeline.length),
      greaterThanOrEqualTo(15),
      reason: 'timeline events across all cases',
    );

    final caseNos = state.cases.map((c) => c.caseNo).toSet();
    final taskIds = state.tasks.map((t) => t.id).toSet();

    // Case numbers must be unique — they key every cross-screen relationship.
    expect(caseNos.length, state.cases.length, reason: 'duplicate case number');
    expect(taskIds.length, state.tasks.length, reason: 'duplicate task id');

    for (final t in state.tasks) {
      expect(caseNos.contains(t.caseNo), isTrue, reason: 'task ${t.id} → ${t.caseNo}');
    }
    for (final d in state.documents) {
      expect(caseNos.contains(d.caseNo), isTrue, reason: 'document ${d.name}');
    }
    for (final e in state.evidence) {
      expect(caseNos.contains(e.caseNo), isTrue, reason: 'evidence ${e.id}');
    }
    for (final n in state.notifications) {
      if (n.caseNo != null) {
        expect(caseNos.contains(n.caseNo), isTrue, reason: 'notification ${n.title}');
      }
      if (n.taskId != null) {
        expect(taskIds.contains(n.taskId), isTrue, reason: 'notification ${n.title}');
      }
    }
  });

  test('every acquisition status is represented and reachable by a filter', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final cases = container.read(foStateProvider).cases;
    final present = cases.map((c) => c.status).toSet();

    for (final s in CaseStatus.values) {
      // `officerReview` is a post-submission status — no case starts in it,
      // which is why it is deliberately not a case-list filter chip.
      if (s == CaseStatus.officerReview) {
        expect(present.contains(s), isFalse);
        continue;
      }
      expect(present.contains(s), isTrue,
          reason: 'no case carries status "${s.label}" — its filter chip would '
              'return an empty list');
    }
  });

  test('every non-closed case has at least one pending timeline step', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    for (final c in container.read(foStateProvider).cases) {
      if (c.status == CaseStatus.completed) continue;
      expect(
        c.timeline.any((e) => e.state == TimelineStepState.pending),
        isTrue,
        reason: '${c.caseNo} has no pending step, so the timeline cannot show '
            'the completed/current/pending distinction',
      );
      expect(c.timeline.any((e) => e.state == TimelineStepState.current), isTrue,
          reason: '${c.caseNo} has no current step');
    }
  });

  test('submitting a verification updates case, tasks, dashboard and inbox', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    const caseNo = 'LA-TN-CBE-2026-0142';
    final before = container.read(foStateProvider);
    expect(before.caseByNo(caseNo)!.status, CaseStatus.verificationPending);
    const otherCaseNo = 'LA-TN-CBE-2026-0108';
    final otherStatusBefore = before.caseByNo(otherCaseNo)!.status;
    final notesBefore = before.notifications.length;
    final statsBefore = container.read(dashboardStatsProvider);
    final openTasksBefore = before.tasksFor(caseNo)
        .where((t) => t.status != TaskStatus.completed)
        .length;
    expect(openTasksBefore, greaterThan(0));

    // Step 1 — opening the wizard flips the case to in progress.
    container.read(foStateProvider.notifier).beginVerification(caseNo);
    final during = container.read(foStateProvider).caseByNo(caseNo)!;
    expect(during.status, CaseStatus.inProgress);
    expect(during.verificationStatus, 'In Progress');
    expect(during.timeline.last.title, 'Field Verification Started');

    // Step 2 — evidence lands on the same case.
    final notifier = container.read(foStateProvider.notifier);
    final id = notifier.nextEvidenceId();
    notifier.addEvidence(
      EvidenceRecord(
        id: id,
        caseNo: caseNo,
        type: kEvidenceTypes.first,
        caption: 'test capture',
        capturedAt: DateTime.now(),
        latitude: 11.0456,
        longitude: 77.1234,
        gpsTagged: true,
        uploadStatus: UploadStatus.pending,
      ),
    );
    expect(
      container.read(foStateProvider).evidenceFor(caseNo).any((e) => e.id == id),
      isTrue,
    );

    // Step 3 — submission.
    notifier.submitVerification(
      caseNo: caseNo,
      evidenceCount: 1,
      gpsCaptured: true,
      queuedOffline: false,
    );
    final after = container.read(foStateProvider);
    final caseAfter = after.caseByNo(caseNo)!;

    expect(caseAfter.status, CaseStatus.officerReview);
    expect(caseAfter.stage, 'Officer Review');
    expect(caseAfter.verificationStatus, 'Completed');
    expect(caseAfter.pendingAction, contains('District Authority'));
    expect(caseAfter.timeline.last.title, 'Field Verification Submitted');

    expect(
      after.tasksFor(caseNo).every((t) => t.status == TaskStatus.completed),
      isTrue,
      reason: 'all tasks for the submitted case must be closed',
    );
    expect(after.notifications.length, notesBefore + 1);
    expect(after.notifications.first.caseNo, caseNo);
    expect(after.notifications.first.kind, NotificationKind.verification);

    // Dashboard numbers follow the data rather than staying stale.
    final statsAfter = container.read(dashboardStatsProvider);
    expect(statsAfter.completed, statsBefore.completed + 1);
    expect(statsAfter.pendingVerification, statsBefore.pendingVerification - 1);
    expect(statsAfter.openTasks, statsBefore.openTasks - openTasksBefore);
    expect(statsAfter.unreadNotifications, statsBefore.unreadNotifications + 1);

    // And an unrelated case is untouched.
    expect(after.caseByNo(otherCaseNo)!.status, otherStatusBefore);
  });

  test('evidence ids stay unique as records are added', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(foStateProvider.notifier);
    final seen = <String>{};
    for (var i = 0; i < 5; i++) {
      final id = notifier.nextEvidenceId();
      expect(seen.add(id), isTrue, reason: 'duplicate evidence id $id');
      notifier.addEvidence(
        EvidenceRecord(
          id: id,
          caseNo: 'LA-TN-CBE-2026-0142',
          type: kEvidenceTypes.first,
          caption: 'capture $i',
          capturedAt: DateTime.now(),
          latitude: 11.0456,
          longitude: 77.1234,
          gpsTagged: true,
          uploadStatus: UploadStatus.pending,
        ),
      );
    }
  });

  test('dashboard stats are derived from data, never hardcoded', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(foStateProvider);
    final stats = container.read(dashboardStatsProvider);

    expect(stats.assignedCases, state.cases.length);
    expect(stats.openTasks, state.openTasks.length);
    expect(stats.unreadNotifications, state.unreadCount);
  });
}
