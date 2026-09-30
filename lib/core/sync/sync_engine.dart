import 'dart:convert';

import 'package:drift/drift.dart';

import '../config/api_config.dart';
import '../database/database.dart';
import '../network/api_client.dart';
import '../network/connectivity_service.dart';
import '../storage/file_store.dart';
import 'retry_policy.dart';

/// Sync operations in dependency order (locked).
enum SyncOperation {
  createFieldVisit,
  createStructure,
  createVegetation,
  uploadDocument,
  uploadEvidence,
  submitFieldVisit,
}

class SyncQueueService {
  SyncQueueService(this._db);

  final AppDatabase _db;

  Future<void> enqueue({
    required String entityType,
    required String entityId,
    required SyncOperation operation,
    required Map<String, dynamic> payload,
  }) async {
    final now = DateTime.now().toUtc();
    await _db.into(_db.syncQueues).insertOnConflictUpdate(
          SyncQueuesCompanion.insert(
            id: '${operation.name}:$entityId',
            entityType: entityType,
            entityId: entityId,
            operation: operation.name,
            payload: jsonEncode(payload),
            retryCount: const Value(0),
            status: 'PENDING',
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  /// Queue rows eligible to be attempted right now.
  ///
  /// [respectBackoff] holds back rows still inside their retry window. It is
  /// off by default so a deliberate SYNC NOW always makes progress, and the
  /// background auto-run in `wiring.dart` opts in to keep a flaky network
  /// from turning into a tight retry loop.
  Future<List<SyncQueue>> pending({DateTime? now, bool respectBackoff = false}) async {
    final at = (now ?? DateTime.now()).toUtc();
    final rows = await (_db.select(_db.syncQueues)
          ..where((t) => t.status.isIn(['PENDING', 'FAILED']))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    if (!respectBackoff) return rows;
    return [
      for (final r in rows)
        if (isRetryDue(
          retryCount: r.retryCount,
          lastAttemptAt: r.updatedAt,
          now: at,
        ))
          r,
    ];
  }

  Future<int> pendingCount() async {
    final q = _db.selectOnly(_db.syncQueues)
      ..addColumns([_db.syncQueues.id.count()])
      ..where(_db.syncQueues.status.isIn(['PENDING', 'FAILED']));
    final row = await q.getSingle();
    return row.read(_db.syncQueues.id.count()) ?? 0;
  }

  Future<void> markDone(String id) async {
    await (_db.update(_db.syncQueues)..where((t) => t.id.equals(id))).write(
      SyncQueuesCompanion(
        status: const Value('DONE'),
        updatedAt: Value(DateTime.now().toUtc()),
        lastError: const Value(null),
      ),
    );
  }

  Future<void> markFailed(String id, String error) async {
    final row =
        await (_db.select(_db.syncQueues)..where((t) => t.id.equals(id))).getSingleOrNull();
    final retries = (row?.retryCount ?? 0) + 1;
    await (_db.update(_db.syncQueues)..where((t) => t.id.equals(id))).write(
      SyncQueuesCompanion(
        status: Value(retries >= kMaxRetries ? 'FAILED' : 'PENDING'),
        retryCount: Value(retries),
        lastError: Value(error),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }
}

/// Dependency-aware sync engine.
class SyncEngine {
  SyncEngine(this._db, this._api, this._queue, this._files, this._connectivity);

  final AppDatabase _db;
  final ApiClient _api;
  final SyncQueueService _queue;
  final FileStore _files;
  final ConnectivityService _connectivity;

  bool _running = false;
  bool get isRunning => _running;

  /// Runs one sync pass. [respectBackoff] is true only for the automatic
  /// background run; the officer's SYNC NOW always attempts every row so a
  /// manual retry makes immediate progress.
  Future<SyncResult> runNow({bool respectBackoff = false}) async {
    if (_running) return SyncResult.inProgress();
    _running = true;
    try {
      if (ApiConfig.devForceOffline) return SyncResult.offline();
      await _connectivity.refresh();
      if (_connectivity.status != ConnectionStatus.online) {
        return SyncResult.offline();
      }

      final pending = await _queue.pending(respectBackoff: respectBackoff);
      if (pending.isEmpty) {
        // Nothing to do — never flip the connection status for an idle run,
        // otherwise the status listener re-triggers us in a loop.
        return SyncResult(success: true, synced: 0, failed: 0);
      }

      _connectivity.markSyncing();
      final ordered = _order(pending);

      var synced = 0;
      var failed = 0;
      for (final item in ordered) {
        try {
          await _process(item);
          await _queue.markDone(item.id);
          synced++;
        } catch (e) {
          await _queue.markFailed(item.id, e.toString());
          failed++;
          await _recordVisitFailure(item, e.toString());
        }
      }
      await _markExhaustedVisitsFailed();
      return SyncResult(
        success: failed == 0 && synced > 0 || pending.isEmpty,
        synced: synced,
        failed: failed,
      );
    } finally {
      _running = false;
      await _connectivity.refresh();
    }
  }

  /// Mirrors a queue failure onto the owning visit so the Sync Center's visit
  /// cards and the "Failed" counter reflect reality instead of staying at 0.
  Future<void> _recordVisitFailure(SyncQueue item, String error) async {
    final visitId = await _visitIdFor(item);
    if (visitId == null) return;
    await (_db.update(_db.fieldVisits)..where((t) => t.id.equals(visitId))).write(
      FieldVisitsCompanion(
        status: const Value('SYNC_FAILED'),
        lastError: Value(error),
        retryCount: Value(await _retryCountFor(item)),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// A visit whose every queue row has exhausted its retries is permanently
  /// failed. Until this existed, a dead visit stayed "Waiting" forever.
  Future<void> _markExhaustedVisitsFailed() async {
    final parked = await (_db.select(_db.syncQueues)
          ..where((t) => t.status.equals('FAILED')))
        .get();
    if (parked.isEmpty) return;

    final visits = await (_db.select(_db.fieldVisits)
          ..where((t) => t.status.isNotIn(['SYNCED', 'SYNC_FAILED'])))
        .get();
    for (final v in visits) {
      final rows = parked.where((q) => q.entityId == v.id || q.payload.contains(v.id));
      if (rows.isEmpty) continue;
      final attempts = rows.fold<int>(0, (sum, q) => sum + q.retryCount);
      if (attempts < kMaxRetries) continue;
      await (_db.update(_db.fieldVisits)..where((t) => t.id.equals(v.id))).write(
        FieldVisitsCompanion(
          status: const Value('SYNC_FAILED'),
          lastError: Value('Upload parked after $kMaxRetries attempts. '
              'Data is safe on this device — retry when online.'),
          retryCount: Value(attempts),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
    }
  }

  /// Resolves the visit an entity belongs to, reusing the entity→visit
  /// mapping the upload operations already need.
  Future<String?> _visitIdFor(SyncQueue item) async {
    if (item.entityType == 'field_visit') return item.entityId;
    try {
      return await _resolveVisitId(item, jsonDecode(item.payload) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<int> _retryCountFor(SyncQueue item) async {
    final row =
        await (_db.select(_db.syncQueues)..where((t) => t.id.equals(item.id))).getSingleOrNull();
    return row?.retryCount ?? 1;
  }

  List<SyncQueue> _order(List<SyncQueue> rows) {
    final rank = {
      SyncOperation.createFieldVisit.name: 0,
      SyncOperation.createStructure.name: 1,
      SyncOperation.createVegetation.name: 2,
      SyncOperation.uploadDocument.name: 3,
      SyncOperation.uploadEvidence.name: 4,
      SyncOperation.submitFieldVisit.name: 5,
    };
    final sorted = List<SyncQueue>.from(rows);
    sorted.sort((a, b) {
      final ra = rank[a.operation] ?? 99;
      final rb = rank[b.operation] ?? 99;
      if (ra != rb) return ra.compareTo(rb);
      return a.createdAt.compareTo(b.createdAt);
    });
    return sorted;
  }

  Future<void> _process(SyncQueue item) async {
    final payload = jsonDecode(item.payload) as Map<String, dynamic>;
    switch (item.operation) {
      case 'createFieldVisit':
        await _createFieldVisit(item, payload);
      case 'createStructure':
        await _createStructure(item, payload);
      case 'createVegetation':
        await _createVegetation(item, payload);
      case 'uploadDocument':
        await _uploadDocument(item, payload);
      case 'uploadEvidence':
        await _uploadEvidence(item, payload);
      case 'submitFieldVisit':
        await _submitFieldVisit(item, payload);
      default:
        throw StateError('Unknown operation ${item.operation}');
    }
  }

  /// Processes one queue row (used by tests to assert parent-id resolution).
  Future<void> processForTest(SyncQueue item) => _process(item);

  Future<void> _createFieldVisit(SyncQueue item, Map<String, dynamic> p) async {
    final parcelId = p['parcelId'] as String;
    final clientId = p['clientId'] as String;
    final res = await _api.post(
      '/parcels/$parcelId/field-verifications',
      body: {'clientId': clientId},
    );
    final verification = res['verification'] as Map<String, dynamic>;
    await (_db.update(_db.fieldVisits)..where((t) => t.id.equals(item.entityId))).write(
      FieldVisitsCompanion(
        verificationServerId: Value(verification['id'] as String?),
        syncStatus: const Value('SYNCED'),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// Resolve parent verification server id from Drift at processing time.
  /// Never trust a verificationId frozen into the queue payload at enqueue.
  Future<String> _requireVerificationId(String visitId) async {
    final visit =
        await (_db.select(_db.fieldVisits)..where((t) => t.id.equals(visitId))).getSingleOrNull();
    final vid = visit?.verificationServerId;
    if (vid == null || vid.isEmpty) {
      throw StateError('Missing verificationId — parent not synced');
    }
    return vid;
  }

  Future<String> _resolveVisitId(SyncQueue item, Map<String, dynamic> p) async {
    final fromPayload = p['visitId'] as String?;
    if (fromPayload != null && fromPayload.isNotEmpty) return fromPayload;
    switch (item.entityType) {
      case 'structure':
        final row =
            await (_db.select(_db.structures)..where((t) => t.id.equals(item.entityId)))
                .getSingleOrNull();
        if (row != null) return row.visitId;
      case 'vegetation':
        final row =
            await (_db.select(_db.vegetations)..where((t) => t.id.equals(item.entityId)))
                .getSingleOrNull();
        if (row != null) return row.visitId;
      case 'evidence':
        final row =
            await (_db.select(_db.evidences)..where((t) => t.id.equals(item.entityId)))
                .getSingleOrNull();
        if (row != null) return row.visitId;
    }
    throw StateError('Cannot resolve visitId for ${item.entityType}:${item.entityId}');
  }

  Map<String, dynamic> _childBody(Map<String, dynamic> p) {
    final body = Map<String, dynamic>.from(p);
    body.remove('verificationId');
    body.remove('visitId');
    return body;
  }

  Future<void> _createStructure(SyncQueue item, Map<String, dynamic> p) async {
    final visitId = await _resolveVisitId(item, p);
    final verificationId = await _requireVerificationId(visitId);
    final res =
        await _api.post('/field-verifications/$verificationId/structures', body: _childBody(p));
    final structure = res['structure'] as Map<String, dynamic>;
    await (_db.update(_db.structures)..where((t) => t.id.equals(item.entityId))).write(
      StructuresCompanion(
        serverId: Value(structure['id'] as String?),
        syncStatus: const Value('SYNCED'),
      ),
    );
  }

  Future<void> _createVegetation(SyncQueue item, Map<String, dynamic> p) async {
    final visitId = await _resolveVisitId(item, p);
    final verificationId = await _requireVerificationId(visitId);
    final res =
        await _api.post('/field-verifications/$verificationId/vegetation', body: _childBody(p));
    final vegetation = res['vegetation'] as Map<String, dynamic>;
    await (_db.update(_db.vegetations)..where((t) => t.id.equals(item.entityId))).write(
      VegetationsCompanion(
        serverId: Value(vegetation['id'] as String?),
        syncStatus: const Value('SYNCED'),
      ),
    );
  }

  Future<void> _uploadDocument(SyncQueue item, Map<String, dynamic> p) async {
    final path = p['localFilePath'] as String;
    if (!await _files.exists(path)) throw StateError('Local document missing: $path');
    final bytes = Uint8List.fromList(await _files.readBytes(path));
    final res = await _api.postMultipart(
      '/cases/${p['caseId']}/documents',
      fields: {
        'documentType': (p['type'] as String?) ?? 'other',
        'clientId': p['clientId'] as String,
        if (p['stage'] != null) 'stage': p['stage'] as String,
      },
      fileField: 'file',
      filename: p['filename'] as String? ?? 'document.pdf',
      bytes: bytes,
      contentType: p['mimeType'] as String? ?? 'application/pdf',
    );
    final doc = res['document'] as Map<String, dynamic>;
    await (_db.update(_db.localDocuments)..where((t) => t.id.equals(item.entityId))).write(
      LocalDocumentsCompanion(
        serverId: Value(doc['id'] as String?),
        syncStatus: const Value('SYNCED'),
      ),
    );
  }

  Future<void> _uploadEvidence(SyncQueue item, Map<String, dynamic> p) async {
    final path = p['localFilePath'] as String;
    if (!await _files.exists(path)) throw StateError('Local evidence missing: $path');
    final visitId = await _resolveVisitId(item, p);
    final verificationId = await _requireVerificationId(visitId);
    final bytes = Uint8List.fromList(await _files.readBytes(path));
    final res = await _api.postMultipart(
      '/field-verifications/$verificationId/evidence',
      fields: {
        'type': (p['type'] as String?) ?? 'photo',
        'caseId': p['caseId'] as String,
        'parcelId': p['parcelId'] as String,
        'clientId': p['clientId'] as String,
        if (p['description'] != null) 'notes': p['description'] as String,
        if (p['latitude'] != null) 'gpsLat': p['latitude'] as String,
        if (p['longitude'] != null) 'gpsLng': p['longitude'] as String,
      },
      fileField: 'file',
      filename: p['filename'] as String? ?? 'evidence.jpg',
      bytes: bytes,
      contentType: p['mimeType'] as String? ?? 'image/jpeg',
    );
    final evidence = res['evidence'] as Map<String, dynamic>;
    await (_db.update(_db.evidences)..where((t) => t.id.equals(item.entityId))).write(
      EvidencesCompanion(
        serverId: Value(evidence['id'] as String?),
        syncStatus: const Value('SYNCED'),
      ),
    );
    // Keep local file after sync (cleanup only under explicit safe policy)
  }

  Future<void> _submitFieldVisit(SyncQueue item, Map<String, dynamic> p) async {
    final visitId = item.entityId;
    final evidenceLeft = await (_db.select(_db.evidences)
          ..where((t) => t.visitId.equals(visitId) & t.syncStatus.isNotIn(['SYNCED'])))
        .get();
    final structuresLeft = await (_db.select(_db.structures)
          ..where((t) => t.visitId.equals(visitId) & t.syncStatus.isNotIn(['SYNCED'])))
        .get();
    final vegetationLeft = await (_db.select(_db.vegetations)
          ..where((t) => t.visitId.equals(visitId) & t.syncStatus.isNotIn(['SYNCED'])))
        .get();
    final docsLeft = await (_db.select(_db.localDocuments)
          ..where((t) => t.visitId.equals(visitId) & t.syncStatus.isNotIn(['SYNCED'])))
        .get();
    if (evidenceLeft.isNotEmpty ||
        structuresLeft.isNotEmpty ||
        vegetationLeft.isNotEmpty ||
        docsLeft.isNotEmpty) {
      throw StateError('Child records not yet synced — submit deferred');
    }

    final res = await _api.post(
      '/parcels/${p['parcelId']}/field-verification',
      body: {
        'caseId': p['caseId'],
        'notes': p['notes'] ?? 'Field verification completed',
        'clientId': p['clientId'],
        if (p['metadata'] != null) 'metadata': p['metadata'],
      },
    );
    final verification = res['verification'] as Map<String, dynamic>;
    await (_db.update(_db.fieldVisits)..where((t) => t.id.equals(visitId))).write(
      FieldVisitsCompanion(
        status: const Value('SYNCED'),
        syncStatus: const Value('SYNCED'),
        verificationServerId: Value(verification['id'] as String?),
        lastError: const Value(null),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }
}

class SyncResult {
  SyncResult({
    required this.success,
    required this.synced,
    required this.failed,
  });

  final bool success;
  final int synced;
  final int failed;

  SyncResult.offline()
      : success = false,
        synced = 0,
        failed = 0;

  SyncResult.inProgress()
      : success = false,
        synced = 0,
        failed = 0;
}
