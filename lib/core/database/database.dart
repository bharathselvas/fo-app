import 'package:drift/drift.dart';

part 'database.g.dart';

class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get token => text()();
  TextColumn get userJson => text()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class AssignedTasks extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  TextColumn get caseId => text()();
  TextColumn get parcelId => text()();
  TextColumn get projectId => text()();
  TextColumn get caseNo => text()();
  TextColumn get surveyNo => text()();
  TextColumn get village => text()();
  TextColumn get tehsil => text()();
  TextColumn get district => text()();
  TextColumn get state => text()();
  TextColumn get areaHa => text()();
  TextColumn get stage => text()();
  TextColumn get status => text()();
  TextColumn get ownerName => text().nullable()();
  TextColumn get landType => text().nullable()();
  TextColumn get geometryWkt => text().nullable()();
  TextColumn get centroidLat => text().nullable()();
  TextColumn get centroidLng => text().nullable()();
  TextColumn get officerId => text()();
  TextColumn get rawJson => text()();
  DateTimeColumn get cachedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class FieldVisits extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  TextColumn get taskId => text()();
  TextColumn get parcelId => text()();
  TextColumn get caseId => text()();
  TextColumn get officerId => text()();
  TextColumn get status => text()();
  TextColumn get syncStatus => text()();
  TextColumn get landUse => text().nullable()();
  TextColumn get irrigation => text().nullable()();
  BoolColumn get boundaryConfirmed => boolean().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get verificationServerId => text().nullable()();
  TextColumn get lastError => text().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get gpsLat => text().nullable()();
  TextColumn get gpsLng => text().nullable()();
  TextColumn get gpsAccuracy => text().nullable()();
  TextColumn get gpsTimestamp => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get submittedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class Structures extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  TextColumn get visitId => text()();
  TextColumn get type => text()();
  RealColumn get areaValue => real().nullable()();
  TextColumn get areaUnit => text().withDefault(const Constant('sq_ft'))();
  TextColumn get constructionType => text().nullable()();
  TextColumn get condition => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get syncStatus => text()();
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class Vegetations extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  TextColumn get visitId => text()();
  TextColumn get species => text()();
  IntColumn get count => integer()();
  TextColumn get cropType => text().nullable()();
  RealColumn get areaHa => real().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get syncStatus => text()();
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class LocalDocuments extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  TextColumn get visitId => text()();
  TextColumn get type => text()();
  TextColumn get localFilePath => text()();
  TextColumn get mimeType => text().nullable()();
  TextColumn get syncStatus => text()();
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class Evidences extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  TextColumn get visitId => text()();
  TextColumn get parcelId => text()();
  TextColumn get officerId => text()();
  TextColumn get type => text()();
  TextColumn get localFilePath => text()();
  TextColumn get latitude => text().nullable()();
  TextColumn get longitude => text().nullable()();
  TextColumn get gpsAccuracy => text().nullable()();
  BoolColumn get locationAvailable => boolean().withDefault(const Constant(true))();
  DateTimeColumn get capturedAt => dateTime()();
  TextColumn get description => text().nullable()();
  TextColumn get syncStatus => text()();
  TextColumn get serverId => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class SyncQueues extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  Sessions,
  AssignedTasks,
  FieldVisits,
  Structures,
  Vegetations,
  LocalDocuments,
  Evidences,
  SyncQueues,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => await m.createAll(),
      );
}
