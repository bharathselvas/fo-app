import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:terranex_fo/core/database/database.dart';
import 'package:terranex_fo/core/network/api_client.dart';
import 'package:terranex_fo/core/network/connectivity_service.dart';
import 'package:terranex_fo/core/network/health_service.dart';
import 'package:terranex_fo/core/sync/sync_engine.dart';
import 'package:terranex_fo/core/utils/ids.dart';
import 'package:terranex_fo/features/field_visit/field_visit_controller.dart';
import 'support/memory_file_store.dart';

class FakeConnectivity extends ConnectivityService {
  FakeConnectivity() : super(HealthService());

  @override
  ConnectionStatus get status => ConnectionStatus.online;

  @override
  Future<void> refresh() async {}

  @override
  void markSyncing() {}

  @override
  Stream<ConnectionStatus> get statusStream => const Stream<ConnectionStatus>.empty();

  @override
  void dispose() {}
}

class FakeApiClient implements ApiClient {
  final List<String> postLog = [];
  final List<String> multipartLog = [];
  final Map<String, String> verificationByClientId = {};
  final Map<String, String> structureByClientId = {};
  final Map<String, String> vegetationByClientId = {};
  final Map<String, String> evidenceByClientId = {};
  final Map<String, String> submitByClientId = {};

  bool failVegetationOnce = false;
  bool failEvidenceOnce = false;
  int _verificationSeq = 0;
  int _structureSeq = 0;
  int _vegetationSeq = 0;
  int _evidenceSeq = 0;

  @override
  void setToken(String? token) {}

  @override
  String? get token => 'test-token';

  @override
  Future<Map<String, dynamic>> get(String path) async => {};

  @override
  Future<Map<String, dynamic>> post(String path, {Object? body}) async {
    final map = body is Map<String, dynamic> ? body : <String, dynamic>{};
    postLog.add(path);

    if (path.endsWith('/field-verifications') && !path.endsWith('/field-verification')) {
      final clientId = map['clientId'] as String;
      return {
        'verification': {
          'id': verificationByClientId.putIfAbsent(clientId, () {
            _verificationSeq += 1;
            return 'srv-verification-$_verificationSeq';
          }),
        },
      };
    }

    if (path.contains('/structures')) {
      final clientId = map['clientId'] as String? ?? '';
      return {
        'structure': {
          'id': structureByClientId.putIfAbsent(clientId, () {
            _structureSeq += 1;
            return 'srv-structure-$_structureSeq';
          }),
        },
      };
    }

    if (path.contains('/vegetation')) {
      if (failVegetationOnce) {
        failVegetationOnce = false;
        throw ApiException(500, 'ERR', 'vegetation unavailable');
      }
      final clientId = map['clientId'] as String? ?? '';
      return {
        'vegetation': {
          'id': vegetationByClientId.putIfAbsent(clientId, () {
            _vegetationSeq += 1;
            return 'srv-vegetation-$_vegetationSeq';
          }),
        },
      };
    }

    if (path.endsWith('/field-verification')) {
      final clientId = map['clientId'] as String;
      return {
        'verification': {
          'id': submitByClientId.putIfAbsent(clientId, () {
            _verificationSeq += 1;
            return 'srv-submit-$_verificationSeq';
          }),
        },
      };
    }

    return {};
  }

  @override
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, String> fields,
    String? fileField,
    String? filename,
    dynamic bytes,
    String? contentType,
  }) async {
    multipartLog.add(path);
    if (path.contains('/evidence')) {
      if (failEvidenceOnce) {
        failEvidenceOnce = false;
        throw ApiException(500, 'ERR', 'evidence unavailable');
      }
      final clientId = fields['clientId'] ?? '';
      return {
        'evidence': {
          'id': evidenceByClientId.putIfAbsent(clientId, () {
            _evidenceSeq += 1;
            return 'srv-evidence-$_evidenceSeq';
          }),
        },
      };
    }
    if (path.contains('/documents')) {
      return {
        'document': {'id': 'srv-document-1'},
      };
    }
    return {};
  }
}

AssignedTask _task() => AssignedTask(
      id: 'parcel-1',
      clientId: newClientId(),
      caseId: 'case-1',
      parcelId: 'parcel-1',
      projectId: 'proj-1',
      caseNo: 'CASE-1',
      surveyNo: 'S-1',
      village: 'V1',
      tehsil: 'T1',
      district: 'D1',
      state: 'S1',
      areaHa: '1.0',
      stage: 'field_verification',
      status: 'active',
      officerId: 'officer-1',
      rawJson: '{}',
      cachedAt: DateTime.now().toUtc(),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('P0 Test 1 — Parent ID resolution at process time', () {
    test('verificationServerId starts null, parent sync writes it, child reads it', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final queue = SyncQueueService(db);
      final api = FakeApiClient();
      final files = MemoryFileStore();
      final engine = SyncEngine(db, api, queue, files, FakeConnectivity());
      final controller = FieldVisitController(db, queue, files);

      final visit = await controller.startVisit(task: _task(), officerId: 'officer-1');
      expect(visit.verificationServerId, isNull);

      final structure = await controller.addStructure(visitId: visit.id, type: 'house');
      await controller.submitVisit(visit.id);

      // Enqueue must not require a frozen verificationId on child payloads.
      final structureQueue = await (db.select(db.syncQueues)
            ..where((t) => t.operation.equals(SyncOperation.createStructure.name)))
          .getSingle();
      final payload =
          (structureQueue.payload.isEmpty ? null : structureQueue.payload) as String;
      expect(payload.contains('verificationId'), isFalse);

      // Before parent sync, child cannot resolve parent id.
      await expectLater(
        engine.processForTest(structureQueue),
        throwsA(isA<StateError>()),
      );

      final visitQueue = await (db.select(db.syncQueues)
            ..where((t) => t.operation.equals(SyncOperation.createFieldVisit.name)))
          .getSingle();
      await engine.processForTest(visitQueue);

      final reloaded =
          await (db.select(db.fieldVisits)..where((t) => t.id.equals(visit.id))).getSingle();
      expect(reloaded.verificationServerId, isNotNull);
      expect(reloaded.verificationServerId, 'srv-verification-1');

      // Child now succeeds by reading the updated ID from Drift.
      await engine.processForTest(structureQueue);
      final structureAfter =
          await (db.select(db.structures)..where((t) => t.id.equals(structure.id))).getSingle();
      expect(structureAfter.syncStatus, 'SYNCED');
      expect(structureAfter.serverId, 'srv-structure-1');

      await db.close();
    });
  });

  group('P0 Test 2 — First sync succeeds end-to-end', () {
    test('fresh visit fully syncs on first run with no second submission', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final queue = SyncQueueService(db);
      final api = FakeApiClient();
      final files = MemoryFileStore();
      final engine = SyncEngine(db, api, queue, files, FakeConnectivity());
      final controller = FieldVisitController(db, queue, files);

      final visit = await controller.startVisit(task: _task(), officerId: 'officer-1');
      await controller.addStructure(visitId: visit.id, type: 'barn', areaValue: 120);
      await controller.addVegetation(visitId: visit.id, species: 'Neem', count: 3);
      await controller.addEvidence(
        visitId: visit.id,
        parcelId: visit.parcelId,
        officerId: 'officer-1',
        type: 'photo',
        bytes: [1, 2, 3],
        latitude: 12.5,
        longitude: 77.5,
      );

      await controller.submitVisit(visit.id);

      final before = await queue.pending();
      // createFieldVisit, createStructure, createVegetation, uploadEvidence, submitFieldVisit
      expect(before, hasLength(5));

      final result = await engine.runNow();
      expect(result.failed, 0);
      expect(result.synced, 5);
      expect(result.success, isTrue);

      final visitAfter =
          await (db.select(db.fieldVisits)..where((t) => t.id.equals(visit.id))).getSingle();
      expect(visitAfter.status, 'SYNCED');
      expect(visitAfter.syncStatus, 'SYNCED');
      expect(visitAfter.verificationServerId, isNotNull);

      final structures = await db.select(db.structures).get();
      final vegetation = await db.select(db.vegetations).get();
      final evidence = await db.select(db.evidences).get();
      expect(structures.single.syncStatus, 'SYNCED');
      expect(vegetation.single.syncStatus, 'SYNCED');
      expect(evidence.single.syncStatus, 'SYNCED');

      expect(await queue.pending(), isEmpty);

      await db.close();
    });
  });

  group('P0 Test 3 — Retry after partial failure preserves clientId', () {
    test('completed ops not duplicated; failed ops resume with same clientId', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final queue = SyncQueueService(db);
      final api = FakeApiClient()
        ..failVegetationOnce = true
        ..failEvidenceOnce = true;
      final files = MemoryFileStore();
      final engine = SyncEngine(db, api, queue, files, FakeConnectivity());
      final controller = FieldVisitController(db, queue, files);

      final visit = await controller.startVisit(task: _task(), officerId: 'officer-1');
      await controller.addStructure(visitId: visit.id, type: 'shed');
      await controller.addVegetation(visitId: visit.id, species: 'Mango', count: 2);
      await controller.addEvidence(
        visitId: visit.id,
        parcelId: visit.parcelId,
        officerId: 'officer-1',
        type: 'photo',
        bytes: [9, 9, 9],
      );
      await controller.submitVisit(visit.id);

      final first = await engine.runNow();
      expect(first.failed, greaterThan(0));

      // Parent + structure succeeded; vegetation + evidence failed; submit deferred.
      final visitRow =
          await (db.select(db.fieldVisits)..where((t) => t.id.equals(visit.id))).getSingle();
      expect(visitRow.verificationServerId, isNotNull);
      expect((await db.select(db.structures).get()).single.syncStatus, 'SYNCED');
      expect((await db.select(db.vegetations).get()).single.syncStatus, isNot('SYNCED'));
      expect((await db.select(db.evidences).get()).single.syncStatus, isNot('SYNCED'));

      final postsAfterFirst = List<String>.from(api.postLog);
      final mimesAfterFirst = List<String>.from(api.multipartLog);

      final second = await engine.runNow();
      expect(second.failed, 0);
      expect(second.success, isTrue);

      // visit create and structure create are not re-posted.
      final createVisitPosts = api.postLog.where((p) => p.endsWith('/field-verifications')).length;
      final createStructurePosts = api.postLog.where((p) => p.contains('/structures')).length;
      expect(createVisitPosts, 1);
      expect(createStructurePosts, 1);

      // Failed ops resumed (at least once more than after first run).
      expect(
        api.postLog.where((p) => p.contains('/vegetation')).length,
        greaterThanOrEqualTo(postsAfterFirst.where((p) => p.contains('/vegetation')).length),
      );
      expect(
        api.multipartLog.where((p) => p.contains('/evidence')).length,
        greaterThanOrEqualTo(mimesAfterFirst.where((p) => p.contains('/evidence')).length + 1),
      );

      // Same clientIds used for retried entities (idempotency).
      final vegClientId = (await db.select(db.vegetations).get()).single.clientId;
      final evClientId = (await db.select(db.evidences).get()).single.clientId;
      expect(api.vegetationByClientId.keys, contains(vegClientId));
      expect(api.evidenceByClientId.keys, contains(evClientId));
      expect(api.vegetationByClientId[vegClientId], 'srv-vegetation-1');
      expect(api.evidenceByClientId[evClientId], 'srv-evidence-1');

      final visitFinal =
          await (db.select(db.fieldVisits)..where((t) => t.id.equals(visit.id))).getSingle();
      expect(visitFinal.status, 'SYNCED');
      expect(await queue.pending(), isEmpty);

      await db.close();
    });
  });

  group('P0 Test 4 — App restart resumes queue', () {
    test('queue and visit survive close/reopen without second submit', () async {
      final dir = await Directory.systemTemp.createTemp('p0_restart');
      final dbPath = '${dir.path}/app.db';

      final db1 = AppDatabase(NativeDatabase(File(dbPath)));
      final queue1 = SyncQueueService(db1);
      final files = MemoryFileStore();
      // Preserve file bytes across "restart" by using the same store instance.
      final controller1 = FieldVisitController(db1, queue1, files);

      final visit = await controller1.startVisit(task: _task(), officerId: 'officer-1');
      await controller1.addStructure(visitId: visit.id, type: 'wall');
      await controller1.addEvidence(
        visitId: visit.id,
        parcelId: visit.parcelId,
        officerId: 'officer-1',
        type: 'photo',
        bytes: [7, 7, 7],
      );
      await controller1.submitVisit(visit.id);

      final pendingBefore = await queue1.pendingCount();
      expect(pendingBefore, 4);

      await db1.close();

      // Simulated app restart: new DB handle on same file, queue still intact.
      final db2 = AppDatabase(NativeDatabase(File(dbPath)));
      final queue2 = SyncQueueService(db2);
      final api = FakeApiClient();
      final engine = SyncEngine(db2, api, queue2, files, FakeConnectivity());

      final visitAfterRestart =
          await (db2.select(db2.fieldVisits)..where((t) => t.id.equals(visit.id))).getSingle();
      expect(visitAfterRestart.id, visit.id);
      expect(visitAfterRestart.status, 'PENDING_SYNC');
      expect(await queue2.pendingCount(), pendingBefore);

      final result = await engine.runNow();
      expect(result.failed, 0);
      expect(result.success, isTrue);

      final visitSynced =
          await (db2.select(db2.fieldVisits)..where((t) => t.id.equals(visit.id))).getSingle();
      expect(visitSynced.status, 'SYNCED');
      expect(await queue2.pendingCount(), 0);

      await db2.close();
      await dir.delete(recursive: true);
    });
  });
}
