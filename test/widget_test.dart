import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bhoomi_setu_fo/features/auth/auth_providers.dart';
import 'package:bhoomi_setu_fo/services/fo_providers.dart';

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

    expect(state.cases.length, 10);
    expect(state.tasks, isNotEmpty);
    expect(state.documents, isNotEmpty);
    expect(state.evidence, isNotEmpty);
    expect(state.notifications, isNotEmpty);

    final caseNos = state.cases.map((c) => c.caseNo).toSet();
    final taskIds = state.tasks.map((t) => t.id).toSet();

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
