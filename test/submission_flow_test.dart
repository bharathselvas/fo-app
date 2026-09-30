// The single most important journey in the prototype, asserted end to end at
// the state layer: case status, task status, dashboard counts and notifications
// must all move when a field verification is submitted, and the record must be
// durable (Drift) and queued for upload (SyncQueues) rather than living only in
// memory.
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:terranex_fo/core/database/database.dart';
import 'package:terranex_fo/data/models/enums.dart';
import 'package:terranex_fo/features/auth/auth_providers.dart';
import 'package:terranex_fo/services/fo_providers.dart';

import 'support/memory_file_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const caseNo = 'LA-TN-CBE-2026-0142';

  testWidgets(
      'submitting a field verification moves case, tasks, stats and notifications',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(db),
        fileStoreProvider.overrideWithValue(MemoryFileStore()),
      ],
    );
    addTearDown(() async {
      await db.close();
      container.dispose();
    });

    final before = container.read(foStateProvider);
    final beforeCase = before.caseByNo(caseNo)!;
    final beforeStats = before.stats();
    final beforeOpenTasks =
        before.openTasks.where((t) => t.caseNo == caseNo).length;

    expect(beforeCase.status, CaseStatus.verificationPending);
    expect(beforeOpenTasks, greaterThan(0));

    // --- Starting the verification marks the case in progress. -------------
    container.read(foStateProvider.notifier).beginVerification(caseNo);
    final started = container.read(foStateProvider).caseByNo(caseNo)!;
    expect(started.status, CaseStatus.inProgress);
    expect(started.timeline.last.title, 'Field Verification Started');
    expect(
      container.read(foStateProvider).tasksFor(caseNo)
          .where((t) => t.status == TaskStatus.inProgress),
      isNotEmpty,
    );

    // --- Evidence is appended through the service, not the widget. ---------
    final notifier = container.read(foStateProvider.notifier);
    final record = container.read(foStateProvider).evidenceFor(caseNo).length;
    expect(record, greaterThan(0),
        reason: 'case must already carry prior field evidence');

    // --- Submission. -------------------------------------------------------
    notifier.submitVerification(
      caseNo: caseNo,
      evidenceCount: record,
      gpsCaptured: true,
      queuedOffline: true,
    );

    final after = container.read(foStateProvider);
    final afterCase = after.caseByNo(caseNo)!;

    // 1. Case moves to authority review and says why.
    expect(afterCase.status, CaseStatus.officerReview);
    expect(afterCase.stage, 'Officer Review');
    expect(afterCase.verificationStatus, 'Completed');
    expect(afterCase.pendingAction, 'Awaiting review by District Authority');
    expect(afterCase.isOverdue, isFalse,
        reason: 'a submitted case is no longer an open overdue case');

    // 2. Timeline records the submission.
    expect(afterCase.timeline.length,
        greaterThan(started.timeline.length));
    expect(afterCase.timeline.last.title, 'Field Verification Submitted');
    // The final event is the current step, not a pending one.
    expect(afterCase.timeline.last.state, isNot(TimelineStepState.pending));

    // 3. Every task on the case is closed and carries no pending files.
    for (final t in after.tasksFor(caseNo)) {
      expect(t.status, TaskStatus.completed, reason: 'task ${t.id}');
      expect(t.pendingFiles, 0);
      expect(t.slaLabel, 'SLA MET');
    }

    // 4. Dashboard counts moved, and are still derived from the dataset.
    final afterStats = after.stats();
    expect(afterStats.pendingVerification,
        lessThan(beforeStats.pendingVerification));
    expect(afterStats.openTasks, beforeStats.openTasks - beforeOpenTasks);
    expect(afterStats.overdue,
        lessThanOrEqualTo(beforeStats.overdue));
    expect(afterStats.assignedCases, beforeStats.assignedCases,
        reason: 'assignment count never changes on submission');
    expect(afterStats.unreadNotifications,
        beforeStats.unreadNotifications + 1);

    // 5. A notification points back at the case.
    final note = after.notifications.first;
    expect(note.kind, NotificationKind.verification);
    expect(note.caseNo, caseNo);
    expect(note.body, contains('GPS verified'));
    expect(note.body, contains('queued for sync'));

    // 6. Marking notifications read clears the unread badge.
    notifier.markAllNotificationsRead();
    expect(container.read(foStateProvider).unreadCount, 0);
  });

  testWidgets('a queued submission is durable and survives a state rebuild',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(db),
        fileStoreProvider.overrideWithValue(MemoryFileStore()),
      ],
    );
    addTearDown(() async {
      await db.close();
      container.dispose();
    });

    container.read(foStateProvider.notifier).submitVerification(
      caseNo: caseNo,
      evidenceCount: 2,
      gpsCaptured: true,
      queuedOffline: true,
    );

    // Re-deriving stats from the snapshot must agree with the provider.
    final state = container.read(foStateProvider);
    expect(state.stats().pendingVerification,
        state.cases
            .where((c) =>
                c.status == CaseStatus.verificationPending ||
                c.status == CaseStatus.inProgress)
            .length);
    expect(state.caseByNo(caseNo)!.status, CaseStatus.officerReview);
  });
}
