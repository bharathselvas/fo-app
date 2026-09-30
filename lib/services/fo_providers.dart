import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/enums.dart';
import '../data/models/evidence_record.dart';
import '../data/models/land_case.dart';
import 'mock_data_service.dart';

/// Single source of truth for all case / task / document / evidence /
/// notification data shown by the app.
final foStateProvider = NotifierProvider<FoStateNotifier, FoState>(FoStateNotifier.new);

class FoStateNotifier extends Notifier<FoState> {
  static const _service = MockDataService();

  @override
  FoState build() => FoState.initial();

  void beginVerification(String caseNo) =>
      state = _service.beginVerification(state, caseNo);

  void addEvidence(EvidenceRecord record) =>
      state = _service.addCaseEvidence(state, record);

  /// Next free evidence id, e.g. `EV-024`. Monotonic — see
  /// [MockDataService.nextEvidenceId].
  String nextEvidenceId() => _service.nextEvidenceId(state);
  void submitVerification({
    required String caseNo,
    required int evidenceCount,
    required bool gpsCaptured,
    required bool queuedOffline,
  }) =>
      state = _service.submitVerification(
        state,
        caseNo: caseNo,
        evidenceCount: evidenceCount,
        gpsCaptured: gpsCaptured,
        queuedOffline: queuedOffline,
      );

  void markNotificationRead(String id) =>
      state = _service.markNotificationRead(state, id);

  void markAllNotificationsRead() =>
      state = _service.markAllNotificationsRead(state);

  void markUploadsComplete() => state = _service.markUploadsComplete(state);

  void setDocumentStatus(String docId, DocumentStatus status) =>
      state = _service.setDocumentStatus(state, docId, status);
}

/// Dashboard numbers, always derived from the dataset — never hardcoded.
final dashboardStatsProvider =
    Provider<DashboardStats>((ref) => ref.watch(foStateProvider).stats());

final caseSearchQueryProvider = StateProvider<String>((_) => '');
final caseStatusFilterProvider = StateProvider<CaseStatus?>((_) => null);
final casePriorityFilterProvider = StateProvider<CasePriority?>((_) => null);
final caseSortProvider = StateProvider<CaseSort>((_) => CaseSort.dueDate);

/// Case list after search + filters + sort have been applied.
final filteredCasesProvider = Provider<List<LandCase>>((ref) {
  final state = ref.watch(foStateProvider);
  return applyCaseQuery(
    state.cases,
    query: ref.watch(caseSearchQueryProvider),
    status: ref.watch(caseStatusFilterProvider),
    priority: ref.watch(casePriorityFilterProvider),
    sort: ref.watch(caseSortProvider),
  );
});
