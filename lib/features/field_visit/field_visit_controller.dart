import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';
import '../../core/storage/file_store.dart';
import '../../core/sync/sync_engine.dart';
import '../../core/utils/ids.dart';

class FieldVisitController {
  FieldVisitController(this._db, this._queue, this._files);

  final AppDatabase _db;
  final SyncQueueService _queue;
  final FileStore _files;

  Future<FieldVisit> startVisit({required AssignedTask task, required String officerId}) async {
    final existing = await (_db.select(_db.fieldVisits)
          ..where((t) => t.caseId.equals(task.caseId) & t.status.isNotIn(['SYNCED'])))
        .getSingleOrNull();
    if (existing != null) return existing;

    final now = DateTime.now().toUtc();
    final visit = FieldVisit(
      id: newClientId(),
      clientId: newClientId(),
      taskId: task.id,
      parcelId: task.parcelId,
      caseId: task.caseId,
      officerId: officerId,
      status: 'IN_PROGRESS',
      syncStatus: 'PENDING',
      retryCount: 0,
      createdAt: now,
      updatedAt: now,
    );
    await _db.into(_db.fieldVisits).insert(visit);
    return visit;
  }

  Future<void> updateVisit(
    String visitId, {
    String? landUse,
    String? irrigation,
    bool? boundaryConfirmed,
    String? notes,
    String? gpsLat,
    String? gpsLng,
    String? gpsAccuracy,
    String? gpsTimestamp,
    String? status,
  }) async {
    await (_db.update(_db.fieldVisits)..where((t) => t.id.equals(visitId))).write(
      FieldVisitsCompanion(
        landUse: landUse != null ? Value(landUse) : const Value.absent(),
        irrigation: irrigation != null ? Value(irrigation) : const Value.absent(),
        boundaryConfirmed:
            boundaryConfirmed != null ? Value(boundaryConfirmed) : const Value.absent(),
        notes: notes != null ? Value(notes) : const Value.absent(),
        gpsLat: gpsLat != null ? Value(gpsLat) : const Value.absent(),
        gpsLng: gpsLng != null ? Value(gpsLng) : const Value.absent(),
        gpsAccuracy: gpsAccuracy != null ? Value(gpsAccuracy) : const Value.absent(),
        gpsTimestamp: gpsTimestamp != null ? Value(gpsTimestamp) : const Value.absent(),
        status: status != null ? Value(status) : const Value.absent(),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<Structure> addStructure({
    required String visitId,
    required String type,
    double? areaValue,
    String areaUnit = 'sq_ft',
    String? constructionType,
    String? condition,
    String? notes,
  }) async {
    final row = Structure(
      id: newClientId(),
      clientId: newClientId(),
      visitId: visitId,
      type: type,
      areaValue: areaValue,
      areaUnit: areaUnit,
      constructionType: constructionType,
      condition: condition,
      notes: notes,
      syncStatus: 'PENDING',
      createdAt: DateTime.now().toUtc(),
    );
    await _db.into(_db.structures).insert(row);
    return row;
  }

  Future<Vegetation> addVegetation({
    required String visitId,
    required String species,
    required int count,
    String? cropType,
    double? areaHa,
    String? notes,
  }) async {
    final row = Vegetation(
      id: newClientId(),
      clientId: newClientId(),
      visitId: visitId,
      species: species,
      count: count,
      cropType: cropType,
      areaHa: areaHa,
      notes: notes,
      syncStatus: 'PENDING',
      createdAt: DateTime.now().toUtc(),
    );
    await _db.into(_db.vegetations).insert(row);
    return row;
  }

  Future<LocalDocument> addDocument({
    required String visitId,
    required String caseId,
    required String type,
    required List<int> bytes,
    required String filename,
    String? mimeType,
    String extension = 'pdf',
  }) async {
    final id = newClientId();
    final path = await _files.saveDocument(
      visitId: visitId,
      documentId: id,
      bytes: bytes,
      extension: extension,
    );
    final row = LocalDocument(
      id: id,
      clientId: newClientId(),
      visitId: visitId,
      type: type,
      localFilePath: path,
      mimeType: mimeType,
      syncStatus: 'PENDING',
      createdAt: DateTime.now().toUtc(),
    );
    await _db.into(_db.localDocuments).insert(row);
    return row;
  }

  Future<Evidence> addEvidence({
    required String visitId,
    required String parcelId,
    required String officerId,
    required String type,
    required List<int> bytes,
    String? description,
    double? latitude,
    double? longitude,
    double? gpsAccuracy,
    bool locationAvailable = true,
    String extension = 'jpg',
  }) async {
    final id = newClientId();
    final path = await _files.saveEvidence(
      visitId: visitId,
      evidenceId: id,
      bytes: bytes,
      extension: extension,
    );
    final row = Evidence(
      id: id,
      clientId: newClientId(),
      visitId: visitId,
      parcelId: parcelId,
      officerId: officerId,
      type: type,
      localFilePath: path,
      latitude: latitude?.toStringAsFixed(7),
      longitude: longitude?.toStringAsFixed(7),
      gpsAccuracy: gpsAccuracy?.toStringAsFixed(1),
      locationAvailable: locationAvailable,
      capturedAt: DateTime.now().toUtc(),
      description: description,
      syncStatus: 'PENDING',
    );
    await _db.into(_db.evidences).insert(row);
    return row;
  }

  Future<void> submitVisit(String visitId) async {
    final visit = await (_db.select(_db.fieldVisits)..where((t) => t.id.equals(visitId)))
        .getSingleOrNull();
    if (visit == null) throw StateError('Visit not found');

    await (_db.update(_db.fieldVisits)..where((t) => t.id.equals(visitId))).write(
      FieldVisitsCompanion(
        status: const Value('PENDING_SYNC'),
        syncStatus: const Value('PENDING'),
        submittedAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );

    await _queue.enqueue(
      entityType: 'field_visit',
      entityId: visitId,
      operation: SyncOperation.createFieldVisit,
      payload: {
        'visitId': visitId,
        'parcelId': visit.parcelId,
        'caseId': visit.caseId,
        'clientId': visit.clientId,
      },
    );

    for (final s in await (_db.select(_db.structures)..where((t) => t.visitId.equals(visitId))).get()) {
      await _queue.enqueue(
        entityType: 'structure',
        entityId: s.id,
        operation: SyncOperation.createStructure,
        payload: {
          'visitId': visitId,
          'clientId': s.clientId,
          'type': s.type,
          'areaValue': s.areaValue,
          'areaUnit': s.areaUnit,
          'constructionType': s.constructionType,
          'condition': s.condition,
          'notes': s.notes,
        },
      );
    }

    for (final v in await (_db.select(_db.vegetations)..where((t) => t.visitId.equals(visitId))).get()) {
      await _queue.enqueue(
        entityType: 'vegetation',
        entityId: v.id,
        operation: SyncOperation.createVegetation,
        payload: {
          'visitId': visitId,
          'clientId': v.clientId,
          'species': v.species,
          'count': v.count,
          'cropType': v.cropType,
          'areaHa': v.areaHa,
          'notes': v.notes,
        },
      );
    }

    for (final d in await (_db.select(_db.localDocuments)..where((t) => t.visitId.equals(visitId))).get()) {
      await _queue.enqueue(
        entityType: 'document',
        entityId: d.id,
        operation: SyncOperation.uploadDocument,
        payload: {
          'clientId': d.clientId,
          'caseId': visit.caseId,
          'type': d.type,
          'localFilePath': d.localFilePath,
          'mimeType': d.mimeType,
          'filename': d.localFilePath.split('/').last,
        },
      );
    }

    for (final e in await (_db.select(_db.evidences)..where((t) => t.visitId.equals(visitId))).get()) {
      await _queue.enqueue(
        entityType: 'evidence',
        entityId: e.id,
        operation: SyncOperation.uploadEvidence,
        payload: {
          'visitId': visitId,
          'clientId': e.clientId,
          'caseId': visit.caseId,
          'parcelId': visit.parcelId,
          'type': e.type,
          'localFilePath': e.localFilePath,
          'mimeType': 'image/jpeg',
          'filename': e.localFilePath.split('/').last,
          'description': e.description,
          'latitude': e.latitude,
          'longitude': e.longitude,
        },
      );
    }

    await _queue.enqueue(
      entityType: 'field_visit',
      entityId: visitId,
      operation: SyncOperation.submitFieldVisit,
      payload: {
        'clientId': '${visit.clientId}:submit',
        'parcelId': visit.parcelId,
        'caseId': visit.caseId,
        'notes': visit.notes ?? 'Field verification completed',
        'metadata': {
          'landUse': visit.landUse,
          'irrigation': visit.irrigation,
          'boundaryConfirmed': visit.boundaryConfirmed,
          'gpsLat': visit.gpsLat,
          'gpsLng': visit.gpsLng,
        },
      },
    );
  }
}

/// Mutable holders wired once at app start (avoids circular provider imports).
final fieldVisitControllerHolder = StateProvider<FieldVisitController?>((_) => null);
final syncEngineHolder = StateProvider<SyncEngine?>((_) => null);

final fieldVisitControllerProvider = Provider<FieldVisitController>((ref) {
  final c = ref.watch(fieldVisitControllerHolder);
  if (c == null) throw StateError('FieldVisitController not initialized');
  return c;
});

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final e = ref.watch(syncEngineHolder);
  if (e == null) throw StateError('SyncEngine not initialized');
  return e;
});
