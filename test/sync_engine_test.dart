import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:bhoomi_setu_fo/core/database/database.dart';
import 'package:bhoomi_setu_fo/core/utils/ids.dart';
import 'package:bhoomi_setu_fo/core/sync/retry_policy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Retry policy', () {
    test('exponential backoff schedule locked: 2,5,15,30,60', () {
      expect(kRetryBackoffSeconds, [2, 5, 15, 30, 60]);
      expect(retryDelaySeconds(0), 2);
      expect(retryDelaySeconds(1), 5);
      expect(retryDelaySeconds(2), 15);
      expect(retryDelaySeconds(3), 30);
      expect(retryDelaySeconds(4), 60);
      expect(retryDelaySeconds(99), 60);
      expect(kMaxRetries, 5);
    });
  });

  group('Partial sync recovery', () {
    test('synced evidence is not re-uploaded; failed one retries', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final visitId = newClientId();
      final now = DateTime.now().toUtc();

      await db.into(db.fieldVisits).insert(
            FieldVisit(
              id: visitId,
              clientId: visitId,
              taskId: 't',
              parcelId: 'p',
              caseId: 'c',
              officerId: 'o',
              status: 'PENDING_SYNC',
              syncStatus: 'PENDING',
              retryCount: 0,
              createdAt: now,
              updatedAt: now,
            ),
          );

      final ev1 = newClientId();
      final ev2 = newClientId();
      await db.into(db.evidences).insert(
            Evidence(
              id: ev1,
              clientId: ev1,
              visitId: visitId,
              parcelId: 'p',
              officerId: 'o',
              type: 'photo',
              localFilePath: '/tmp/a.jpg',
              locationAvailable: true,
              capturedAt: now,
              syncStatus: 'SYNCED',
              serverId: 'server-ev1',
            ),
          );
      await db.into(db.evidences).insert(
            Evidence(
              id: ev2,
              clientId: ev2,
              visitId: visitId,
              parcelId: 'p',
              officerId: 'o',
              type: 'photo',
              localFilePath: '/tmp/b.jpg',
              locationAvailable: true,
              capturedAt: now,
              syncStatus: 'PENDING',
            ),
          );

      // Queue only non-synced
      final toSync = await (db.select(db.evidences)
            ..where((t) => t.visitId.equals(visitId) & t.syncStatus.isNotIn(['SYNCED'])))
          .get();
      expect(toSync, hasLength(1));
      expect(toSync.first.id, ev2);

      // After app reopen simulation: same query
      final again = await (db.select(db.evidences)
            ..where((t) => t.visitId.equals(visitId) & t.syncStatus.isNotIn(['SYNCED'])))
          .get();
      expect(again.first.id, ev2);

      await db.close();
    });
  });

  group('GPS unavailable handling', () {
    test('evidence can be flagged location unavailable', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final now = DateTime.now().toUtc();
      final id = newClientId();
      await db.into(db.evidences).insert(
            Evidence(
              id: id,
              clientId: id,
              visitId: 'v',
              parcelId: 'p',
              officerId: 'o',
              type: 'photo',
              localFilePath: '/tmp/x.jpg',
              locationAvailable: false,
              capturedAt: now,
              syncStatus: 'PENDING',
            ),
          );
      final row = await db.select(db.evidences).getSingle();
      expect(row.locationAvailable, isFalse);
      expect(row.latitude, isNull);
      await db.close();
    });
  });
}
