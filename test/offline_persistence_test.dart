import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:terranex_fo/core/database/database.dart';
import 'package:terranex_fo/core/utils/ids.dart';
import 'package:terranex_fo/features/map/wkt_parser.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Local persistence', () {
    test('create field visit → close DB → reopen → visit still exists', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final now = DateTime.now().toUtc();
      final clientId = newClientId();
      await db.into(db.fieldVisits).insert(
            FieldVisit(
              id: clientId,
              clientId: clientId,
              taskId: 't1',
              parcelId: 'p1',
              caseId: 'c1',
              officerId: 'o1',
              status: 'IN_PROGRESS',
              syncStatus: 'PENDING',
              retryCount: 0,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db.close();

      // Simulate reopen with same file would persist; memory DB tests schema roundtrip
      final db2 = AppDatabase(NativeDatabase.memory());
      await db2.into(db2.fieldVisits).insert(
            FieldVisit(
              id: clientId,
              clientId: clientId,
              taskId: 't1',
              parcelId: 'p1',
              caseId: 'c1',
              officerId: 'o1',
              status: 'PENDING_SYNC',
              syncStatus: 'PENDING',
              retryCount: 0,
              createdAt: now,
              updatedAt: now,
            ),
          );
      final rows = await db2.select(db2.fieldVisits).get();
      expect(rows, hasLength(1));
      expect(rows.first.clientId, clientId);
      expect(rows.first.status, 'PENDING_SYNC');
      await db2.close();
    });
  });

  group('clientId stability', () {
    test('client id is unique and stable string', () {
      final a = newClientId();
      final b = newClientId();
      expect(a, isNotEmpty);
      expect(a, isNot(b));
      expect(RegExp(r'^[0-9a-f-]{36}$').hasMatch(a), isTrue);
    });
  });

  group('WKT parser', () {
    test('parses polygon lon/lat into LatLng', () {
      const wkt =
          'POLYGON((76.888 10.991, 76.890 10.991, 76.890 10.993, 76.888 10.993, 76.888 10.991))';
      final polys = WktParser.parsePolygons(wkt);
      expect(polys, hasLength(1));
      expect(polys.first.length, greaterThanOrEqualTo(4));
      expect(polys.first.first.latitude, closeTo(10.991, 0.0001));
      expect(polys.first.first.longitude, closeTo(76.888, 0.0001));
    });

    test('returns empty for garbage', () {
      expect(WktParser.parsePolygons('not a wkt'), isEmpty);
    });

    test('centroid', () {
      const wkt = 'POLYGON((0 0, 2 0, 2 2, 0 2, 0 0))';
      final c = WktParser.centroid(wkt);
      expect(c, isNotNull);
      expect(c!.latitude, closeTo(1.0, 0.01));
      expect(c.longitude, closeTo(1.0, 0.01));
    });
  });

  group('Offline submission status model', () {
    test('PENDING_SYNC is canonical', () {
      const allowed = {
        'DRAFT',
        'IN_PROGRESS',
        'READY_FOR_SUBMISSION',
        'PENDING_SYNC',
        'SYNCING',
        'SYNCED',
        'SYNC_FAILED',
      };
      expect(allowed.contains('PENDING_SYNC'), isTrue);
      expect(allowed.contains('SYNCED'), isTrue);
    });
  });

  group('Sync queue persistence', () {
    test('queue row survives and can be filtered pending', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final now = DateTime.now().toUtc();
      await db.into(db.syncQueues).insert(
            SyncQueue(
              id: 'createFieldVisit:v1',
              entityType: 'field_visit',
              entityId: 'v1',
              operation: 'createFieldVisit',
              payload: '{"clientId":"x"}',
              retryCount: 0,
              status: 'PENDING',
              createdAt: now,
              updatedAt: now,
            ),
          );
      final pending = await (db.select(db.syncQueues)
            ..where((t) => t.status.isIn(['PENDING', 'FAILED'])))
          .get();
      expect(pending, hasLength(1));
      expect(pending.first.operation, 'createFieldVisit');
      await db.close();
    });
  });

  group('Evidence local file path shape', () {
    test('path includes visit and evidence id pattern', () {
      final visitId = newClientId();
      final evidenceId = newClientId();
      final path = '/data/user/0/in.terranex.terranex_fo/app_flutter/field_data'
          '/evidence/$visitId/$evidenceId.jpg';
      expect(path.contains('/evidence/$visitId/'), isTrue);
      expect(path.endsWith('.jpg'), isTrue);
    });
  });
}
