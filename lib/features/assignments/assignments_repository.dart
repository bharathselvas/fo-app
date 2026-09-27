import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';
import '../../core/network/api_client.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/utils/ids.dart';
import '../auth/auth_providers.dart';

export '../../core/database/database.dart' show AssignedTask;

/// Loads assignments using existing authorized GET /api/cases
/// (server district-scopes field_officer) + client filter stage == field_verification.
/// Then fetches parcels and caches geometry_wkt locally for offline map.
class AssignmentsRepository {
  AssignmentsRepository(this._db, this._api);

  final AppDatabase _db;
  final ApiClient _api;

  Future<List<AssignedTask>> syncAndCache({required String officerId}) async {
    final casesRes = await _api.get('/cases');
    final cases = (casesRes['cases'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .where((c) => c['currentStage'] == 'field_verification')
        .toList();

    final cached = <AssignedTask>[];
    for (final c in cases) {
      final caseId = c['id'] as String;
      final projectId = c['projectId'] as String?;
      if (projectId == null) continue;

      final parcelsRes = await _api.get('/projects/$projectId/parcels');
      final parcels =
          (parcelsRes['parcels'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
      final parcelId = c['parcelId'] as String?;
      Map<String, dynamic>? parcel;
      if (parcelId != null) {
        for (final p in parcels) {
          if (p['id'] == parcelId) {
            parcel = p;
            break;
          }
        }
      } else if (parcels.isNotEmpty) {
        parcel = parcels.first;
      }
      if (parcel == null) continue;

      final row = AssignedTask(
        id: parcel['id'] as String,
        clientId: newClientId(),
        caseId: caseId,
        parcelId: parcel['id'] as String,
        projectId: projectId,
        caseNo: (c['caseNo'] as String?) ?? caseId,
        surveyNo: (parcel['surveyNo'] as String?) ?? '',
        village: (parcel['village'] as String?) ?? '',
        tehsil: (parcel['tehsil'] as String?) ?? '',
        district: (parcel['district'] as String?) ?? '',
        state: (parcel['state'] as String?) ?? '',
        areaHa: (parcel['areaHa'] as String?) ?? '',
        stage: (c['currentStage'] as String?) ?? '',
        status: (c['status'] as String?) ?? 'active',
        ownerName: parcel['ownerName'] as String?,
        landType: parcel['landType'] as String?,
        geometryWkt: parcel['geometryWkt'] as String?,
        centroidLat: parcel['centroidLat'] as String?,
        centroidLng: parcel['centroidLng'] as String?,
        officerId: officerId,
        rawJson: jsonEncodeSafe(c),
        cachedAt: DateTime.now().toUtc(),
      );

      await _db.into(_db.assignedTasks).insertOnConflictUpdate(row);
      cached.add(row);
    }
    return cached;
  }

  Future<List<AssignedTask>> cachedTasks() => _db.select(_db.assignedTasks).get();

  Future<AssignedTask?> byId(String id) =>
      (_db.select(_db.assignedTasks)..where((t) => t.id.equals(id))).getSingleOrNull();
}

String jsonEncodeSafe(Map<String, dynamic> m) {
  // Avoid importing dart:convert at top if unused elsewhere — used here.
  return _encode(m);
}

String _encode(Object? o) {
  // Simple recursive JSON encode without dart:convert import cycle issues
  if (o == null) return 'null';
  if (o is String) return '"${o.replaceAll('"', r'\"')}"';
  if (o is num || o is bool) return o.toString();
  if (o is Map) {
    final entries = o.entries.map((e) => '${_encode(e.key)}:${_encode(e.value)}');
    return '{${entries.join(',')}}';
  }
  if (o is List) return '[${o.map(_encode).join(',')}]';
  return '"$o"';
}

final assignmentsRepositoryProvider = Provider<AssignmentsRepository>((ref) {
  return AssignmentsRepository(ref.watch(dbProvider), ref.watch(apiClientProvider));
});

final assignmentsProvider = FutureProvider.autoDispose<List<AssignedTask>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final repo = ref.watch(assignmentsRepositoryProvider);
  final conn = ref.watch(connectionProvider).valueOrNull;

  final online = conn == ConnectionStatus.online;
  if (online && user != null) {
    try {
      final tasks = await repo.syncAndCache(officerId: user.id);
      if (tasks.isNotEmpty) return tasks;
    } catch (_) {
      // fall through to cache
    }
  }
  return repo.cachedTasks();
});
