import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/sync/sync_engine.dart';
import '../../features/auth/auth_providers.dart';
import '../../features/field_visit/field_visit_controller.dart';

/// Call once after providers are ready to wire sync engine + controllers
/// and start auto-sync on connectivity regain.
void wireDependencies(WidgetRef ref) {
  final db = ref.read(dbProvider);
  final queue = SyncQueueService(db);
  final engine = SyncEngine(
    db,
    ref.read(apiClientProvider),
    queue,
    ref.read(fileStoreProvider),
    ref.read(connectivityServiceProvider),
  );
  ref.read(syncEngineHolder.notifier).state = engine;
  ref.read(fieldVisitControllerHolder.notifier).state =
      FieldVisitController(db, queue, ref.read(fileStoreProvider));

  ref.read(connectivityServiceProvider).statusStream.listen((status) {
    if (status == ConnectionStatus.online) {
      engine.runNow();
    }
  });
}
