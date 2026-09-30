import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/sync/sync_engine.dart';
import '../../features/auth/auth_providers.dart';
import '../../features/field_visit/field_visit_controller.dart';

/// Call once after providers are ready to wire sync engine + controllers
/// and start auto-sync on connectivity regain.
void wireDependencies(ProviderContainer container) {
  final db = container.read(dbProvider);
  final queue = SyncQueueService(db);
  final engine = SyncEngine(
    db,
    container.read(apiClientProvider),
    queue,
    container.read(fileStoreProvider),
    container.read(connectivityServiceProvider),
  );
  container.read(syncEngineHolder.notifier).state = engine;
  container.read(fieldVisitControllerHolder.notifier).state =
      FieldVisitController(db, queue, container.read(fileStoreProvider));

  // Cooldown so the engine's own syncing -> online transition cannot re-trigger
  // an endless run() loop (the historic UI flicker).
  var lastAutoRun = DateTime.fromMillisecondsSinceEpoch(0);
  final connectivity = container.read(connectivityServiceProvider);
  connectivity.statusStream.listen((status) {
    if (status != ConnectionStatus.online) return;
    final now = DateTime.now();
    if (now.difference(lastAutoRun) < const Duration(seconds: 10)) return;
    lastAutoRun = now;
    engine.runNow(respectBackoff: true);
  });
  // Start the connectivity watcher here, where the stream is actually
  // subscribed. `start()` is idempotent, so this is safe even when
  // `connectionProvider` has already kicked it off.
  connectivity.start();
}
