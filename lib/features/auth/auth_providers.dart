import 'package:drift/drift.dart' show QueryExecutor;
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';
import '../../core/network/api_client.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/storage/file_store.dart';
import 'session_service.dart';

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(openDatabase());
  ref.onDispose(db.close);
  return db;
});

// Helper so tests can override; drift_flutter open path
QueryExecutor openDatabase() => driftDatabase(name: 'bhoomi_setu_fo');

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final sessionServiceProvider = Provider<SessionService>((ref) {
  return SessionService(ref.watch(dbProvider), ref.watch(apiClientProvider));
});

final fileStoreProvider = Provider<FileStore>((ref) => FileStore());

final connectionProvider = StreamProvider<ConnectionStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  service.start();
  return service.statusStream;
});

/// Current authenticated user (null = logged out).
final currentUserProvider = StateProvider<AppUser?>((ref) => null);

/// Boot: restore offline session if present.
final bootProvider = FutureProvider<AppUser?>((ref) async {
  final session = ref.watch(sessionServiceProvider);
  final restored = await session.restore();
  if (restored == null) return null;
  // Silent online refresh — ignore failures to keep offline session
  final refreshed = await session.refreshMe();
  final user = refreshed ?? restored.user;
  ref.read(currentUserProvider.notifier).state = user;
  return user;
});
