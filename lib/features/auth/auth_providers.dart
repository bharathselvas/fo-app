import 'package:drift/drift.dart' show OrderingTerm, QueryExecutor;
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';
import '../../core/network/api_client.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/storage/file_store.dart';
import '../../data/models/field_officer.dart';
import '../../services/fo_providers.dart';

export '../../data/models/field_officer.dart' show FieldOfficer;

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(openDatabase());
  ref.onDispose(db.close);
  return db;
});

// Helper so tests can override; drift_flutter open path
QueryExecutor openDatabase() => driftDatabase(name: 'terranex_fo');

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final fileStoreProvider = Provider<FileStore>((ref) => FileStore());

final connectionProvider = StreamProvider<ConnectionStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  service.start();
  return service.statusStream;
});

/// Queue rows still waiting to be uploaded (PENDING / FAILED), watched live.
final pendingQueueRowsProvider = StreamProvider<List<SyncQueue>>((ref) {
  final db = ref.watch(dbProvider);
  final query = db.select(db.syncQueues)
    ..where((t) => t.status.isIn(['PENDING', 'FAILED']))
    ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
  return query.watch();
});

/// How many records are still on the device waiting for a connection.
final pendingSyncCountProvider = Provider<int>(
  (ref) => ref.watch(pendingQueueRowsProvider).valueOrNull?.length ?? 0,
);

/// Signed-in officer (always populated for the prototype).
final currentUserProvider = Provider<FieldOfficer>(
  (ref) => ref.watch(foStateProvider).officer,
);

/// Documents the officer picked during a field visit, watched live so the
/// Documents screen reflects uploads the moment they are added.
final visitDocumentsProvider = StreamProvider.family<List<LocalDocument>, String>(
  (ref, caseNo) => ref.watch(dbProvider).watchVisitDocumentsForCase(caseNo),
);

/// Prototype sign-in gate: no server, no credentials check — the officer
/// simply enters the app (see `login_screen.dart`).
final signedInProvider = StateProvider<bool>((_) => false);
