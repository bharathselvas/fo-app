// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
    'token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userJsonMeta = const VerificationMeta(
    'userJson',
  );
  @override
  late final GeneratedColumn<String> userJson = GeneratedColumn<String>(
    'user_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, token, userJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('token')) {
      context.handle(
        _tokenMeta,
        token.isAcceptableOrUnknown(data['token']!, _tokenMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenMeta);
    }
    if (data.containsKey('user_json')) {
      context.handle(
        _userJsonMeta,
        userJson.isAcceptableOrUnknown(data['user_json']!, _userJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_userJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      token: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token'],
      )!,
      userJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final String id;
  final String token;
  final String userJson;
  final DateTime updatedAt;
  const Session({
    required this.id,
    required this.token,
    required this.userJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['token'] = Variable<String>(token);
    map['user_json'] = Variable<String>(userJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      token: Value(token),
      userJson: Value(userJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<String>(json['id']),
      token: serializer.fromJson<String>(json['token']),
      userJson: serializer.fromJson<String>(json['userJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'token': serializer.toJson<String>(token),
      'userJson': serializer.toJson<String>(userJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Session copyWith({
    String? id,
    String? token,
    String? userJson,
    DateTime? updatedAt,
  }) => Session(
    id: id ?? this.id,
    token: token ?? this.token,
    userJson: userJson ?? this.userJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      token: data.token.present ? data.token.value : this.token,
      userJson: data.userJson.present ? data.userJson.value : this.userJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('token: $token, ')
          ..write('userJson: $userJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, token, userJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.token == this.token &&
          other.userJson == this.userJson &&
          other.updatedAt == this.updatedAt);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<String> id;
  final Value<String> token;
  final Value<String> userJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.token = const Value.absent(),
    this.userJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    required String token,
    required String userJson,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       token = Value(token),
       userJson = Value(userJson),
       updatedAt = Value(updatedAt);
  static Insertable<Session> custom({
    Expression<String>? id,
    Expression<String>? token,
    Expression<String>? userJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (token != null) 'token': token,
      if (userJson != null) 'user_json': userJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? token,
    Value<String>? userJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      token: token ?? this.token,
      userJson: userJson ?? this.userJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (userJson.present) {
      map['user_json'] = Variable<String>(userJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('token: $token, ')
          ..write('userJson: $userJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssignedTasksTable extends AssignedTasks
    with TableInfo<$AssignedTasksTable, AssignedTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssignedTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caseIdMeta = const VerificationMeta('caseId');
  @override
  late final GeneratedColumn<String> caseId = GeneratedColumn<String>(
    'case_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parcelIdMeta = const VerificationMeta(
    'parcelId',
  );
  @override
  late final GeneratedColumn<String> parcelId = GeneratedColumn<String>(
    'parcel_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caseNoMeta = const VerificationMeta('caseNo');
  @override
  late final GeneratedColumn<String> caseNo = GeneratedColumn<String>(
    'case_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _surveyNoMeta = const VerificationMeta(
    'surveyNo',
  );
  @override
  late final GeneratedColumn<String> surveyNo = GeneratedColumn<String>(
    'survey_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _villageMeta = const VerificationMeta(
    'village',
  );
  @override
  late final GeneratedColumn<String> village = GeneratedColumn<String>(
    'village',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tehsilMeta = const VerificationMeta('tehsil');
  @override
  late final GeneratedColumn<String> tehsil = GeneratedColumn<String>(
    'tehsil',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _districtMeta = const VerificationMeta(
    'district',
  );
  @override
  late final GeneratedColumn<String> district = GeneratedColumn<String>(
    'district',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaHaMeta = const VerificationMeta('areaHa');
  @override
  late final GeneratedColumn<String> areaHa = GeneratedColumn<String>(
    'area_ha',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
    'stage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerNameMeta = const VerificationMeta(
    'ownerName',
  );
  @override
  late final GeneratedColumn<String> ownerName = GeneratedColumn<String>(
    'owner_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _landTypeMeta = const VerificationMeta(
    'landType',
  );
  @override
  late final GeneratedColumn<String> landType = GeneratedColumn<String>(
    'land_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _geometryWktMeta = const VerificationMeta(
    'geometryWkt',
  );
  @override
  late final GeneratedColumn<String> geometryWkt = GeneratedColumn<String>(
    'geometry_wkt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _centroidLatMeta = const VerificationMeta(
    'centroidLat',
  );
  @override
  late final GeneratedColumn<String> centroidLat = GeneratedColumn<String>(
    'centroid_lat',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _centroidLngMeta = const VerificationMeta(
    'centroidLng',
  );
  @override
  late final GeneratedColumn<String> centroidLng = GeneratedColumn<String>(
    'centroid_lng',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _officerIdMeta = const VerificationMeta(
    'officerId',
  );
  @override
  late final GeneratedColumn<String> officerId = GeneratedColumn<String>(
    'officer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    caseId,
    parcelId,
    projectId,
    caseNo,
    surveyNo,
    village,
    tehsil,
    district,
    state,
    areaHa,
    stage,
    status,
    ownerName,
    landType,
    geometryWkt,
    centroidLat,
    centroidLng,
    officerId,
    rawJson,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assigned_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssignedTask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('case_id')) {
      context.handle(
        _caseIdMeta,
        caseId.isAcceptableOrUnknown(data['case_id']!, _caseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caseIdMeta);
    }
    if (data.containsKey('parcel_id')) {
      context.handle(
        _parcelIdMeta,
        parcelId.isAcceptableOrUnknown(data['parcel_id']!, _parcelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_parcelIdMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('case_no')) {
      context.handle(
        _caseNoMeta,
        caseNo.isAcceptableOrUnknown(data['case_no']!, _caseNoMeta),
      );
    } else if (isInserting) {
      context.missing(_caseNoMeta);
    }
    if (data.containsKey('survey_no')) {
      context.handle(
        _surveyNoMeta,
        surveyNo.isAcceptableOrUnknown(data['survey_no']!, _surveyNoMeta),
      );
    } else if (isInserting) {
      context.missing(_surveyNoMeta);
    }
    if (data.containsKey('village')) {
      context.handle(
        _villageMeta,
        village.isAcceptableOrUnknown(data['village']!, _villageMeta),
      );
    } else if (isInserting) {
      context.missing(_villageMeta);
    }
    if (data.containsKey('tehsil')) {
      context.handle(
        _tehsilMeta,
        tehsil.isAcceptableOrUnknown(data['tehsil']!, _tehsilMeta),
      );
    } else if (isInserting) {
      context.missing(_tehsilMeta);
    }
    if (data.containsKey('district')) {
      context.handle(
        _districtMeta,
        district.isAcceptableOrUnknown(data['district']!, _districtMeta),
      );
    } else if (isInserting) {
      context.missing(_districtMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('area_ha')) {
      context.handle(
        _areaHaMeta,
        areaHa.isAcceptableOrUnknown(data['area_ha']!, _areaHaMeta),
      );
    } else if (isInserting) {
      context.missing(_areaHaMeta);
    }
    if (data.containsKey('stage')) {
      context.handle(
        _stageMeta,
        stage.isAcceptableOrUnknown(data['stage']!, _stageMeta),
      );
    } else if (isInserting) {
      context.missing(_stageMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('owner_name')) {
      context.handle(
        _ownerNameMeta,
        ownerName.isAcceptableOrUnknown(data['owner_name']!, _ownerNameMeta),
      );
    }
    if (data.containsKey('land_type')) {
      context.handle(
        _landTypeMeta,
        landType.isAcceptableOrUnknown(data['land_type']!, _landTypeMeta),
      );
    }
    if (data.containsKey('geometry_wkt')) {
      context.handle(
        _geometryWktMeta,
        geometryWkt.isAcceptableOrUnknown(
          data['geometry_wkt']!,
          _geometryWktMeta,
        ),
      );
    }
    if (data.containsKey('centroid_lat')) {
      context.handle(
        _centroidLatMeta,
        centroidLat.isAcceptableOrUnknown(
          data['centroid_lat']!,
          _centroidLatMeta,
        ),
      );
    }
    if (data.containsKey('centroid_lng')) {
      context.handle(
        _centroidLngMeta,
        centroidLng.isAcceptableOrUnknown(
          data['centroid_lng']!,
          _centroidLngMeta,
        ),
      );
    }
    if (data.containsKey('officer_id')) {
      context.handle(
        _officerIdMeta,
        officerId.isAcceptableOrUnknown(data['officer_id']!, _officerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_officerIdMeta);
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssignedTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssignedTask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      caseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}case_id'],
      )!,
      parcelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parcel_id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      caseNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}case_no'],
      )!,
      surveyNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}survey_no'],
      )!,
      village: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}village'],
      )!,
      tehsil: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tehsil'],
      )!,
      district: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}district'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      areaHa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_ha'],
      )!,
      stage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      ownerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_name'],
      ),
      landType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}land_type'],
      ),
      geometryWkt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}geometry_wkt'],
      ),
      centroidLat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}centroid_lat'],
      ),
      centroidLng: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}centroid_lng'],
      ),
      officerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}officer_id'],
      )!,
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $AssignedTasksTable createAlias(String alias) {
    return $AssignedTasksTable(attachedDatabase, alias);
  }
}

class AssignedTask extends DataClass implements Insertable<AssignedTask> {
  final String id;
  final String clientId;
  final String caseId;
  final String parcelId;
  final String projectId;
  final String caseNo;
  final String surveyNo;
  final String village;
  final String tehsil;
  final String district;
  final String state;
  final String areaHa;
  final String stage;
  final String status;
  final String? ownerName;
  final String? landType;
  final String? geometryWkt;
  final String? centroidLat;
  final String? centroidLng;
  final String officerId;
  final String rawJson;
  final DateTime cachedAt;
  const AssignedTask({
    required this.id,
    required this.clientId,
    required this.caseId,
    required this.parcelId,
    required this.projectId,
    required this.caseNo,
    required this.surveyNo,
    required this.village,
    required this.tehsil,
    required this.district,
    required this.state,
    required this.areaHa,
    required this.stage,
    required this.status,
    this.ownerName,
    this.landType,
    this.geometryWkt,
    this.centroidLat,
    this.centroidLng,
    required this.officerId,
    required this.rawJson,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_id'] = Variable<String>(clientId);
    map['case_id'] = Variable<String>(caseId);
    map['parcel_id'] = Variable<String>(parcelId);
    map['project_id'] = Variable<String>(projectId);
    map['case_no'] = Variable<String>(caseNo);
    map['survey_no'] = Variable<String>(surveyNo);
    map['village'] = Variable<String>(village);
    map['tehsil'] = Variable<String>(tehsil);
    map['district'] = Variable<String>(district);
    map['state'] = Variable<String>(state);
    map['area_ha'] = Variable<String>(areaHa);
    map['stage'] = Variable<String>(stage);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || ownerName != null) {
      map['owner_name'] = Variable<String>(ownerName);
    }
    if (!nullToAbsent || landType != null) {
      map['land_type'] = Variable<String>(landType);
    }
    if (!nullToAbsent || geometryWkt != null) {
      map['geometry_wkt'] = Variable<String>(geometryWkt);
    }
    if (!nullToAbsent || centroidLat != null) {
      map['centroid_lat'] = Variable<String>(centroidLat);
    }
    if (!nullToAbsent || centroidLng != null) {
      map['centroid_lng'] = Variable<String>(centroidLng);
    }
    map['officer_id'] = Variable<String>(officerId);
    map['raw_json'] = Variable<String>(rawJson);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  AssignedTasksCompanion toCompanion(bool nullToAbsent) {
    return AssignedTasksCompanion(
      id: Value(id),
      clientId: Value(clientId),
      caseId: Value(caseId),
      parcelId: Value(parcelId),
      projectId: Value(projectId),
      caseNo: Value(caseNo),
      surveyNo: Value(surveyNo),
      village: Value(village),
      tehsil: Value(tehsil),
      district: Value(district),
      state: Value(state),
      areaHa: Value(areaHa),
      stage: Value(stage),
      status: Value(status),
      ownerName: ownerName == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerName),
      landType: landType == null && nullToAbsent
          ? const Value.absent()
          : Value(landType),
      geometryWkt: geometryWkt == null && nullToAbsent
          ? const Value.absent()
          : Value(geometryWkt),
      centroidLat: centroidLat == null && nullToAbsent
          ? const Value.absent()
          : Value(centroidLat),
      centroidLng: centroidLng == null && nullToAbsent
          ? const Value.absent()
          : Value(centroidLng),
      officerId: Value(officerId),
      rawJson: Value(rawJson),
      cachedAt: Value(cachedAt),
    );
  }

  factory AssignedTask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssignedTask(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      caseId: serializer.fromJson<String>(json['caseId']),
      parcelId: serializer.fromJson<String>(json['parcelId']),
      projectId: serializer.fromJson<String>(json['projectId']),
      caseNo: serializer.fromJson<String>(json['caseNo']),
      surveyNo: serializer.fromJson<String>(json['surveyNo']),
      village: serializer.fromJson<String>(json['village']),
      tehsil: serializer.fromJson<String>(json['tehsil']),
      district: serializer.fromJson<String>(json['district']),
      state: serializer.fromJson<String>(json['state']),
      areaHa: serializer.fromJson<String>(json['areaHa']),
      stage: serializer.fromJson<String>(json['stage']),
      status: serializer.fromJson<String>(json['status']),
      ownerName: serializer.fromJson<String?>(json['ownerName']),
      landType: serializer.fromJson<String?>(json['landType']),
      geometryWkt: serializer.fromJson<String?>(json['geometryWkt']),
      centroidLat: serializer.fromJson<String?>(json['centroidLat']),
      centroidLng: serializer.fromJson<String?>(json['centroidLng']),
      officerId: serializer.fromJson<String>(json['officerId']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String>(clientId),
      'caseId': serializer.toJson<String>(caseId),
      'parcelId': serializer.toJson<String>(parcelId),
      'projectId': serializer.toJson<String>(projectId),
      'caseNo': serializer.toJson<String>(caseNo),
      'surveyNo': serializer.toJson<String>(surveyNo),
      'village': serializer.toJson<String>(village),
      'tehsil': serializer.toJson<String>(tehsil),
      'district': serializer.toJson<String>(district),
      'state': serializer.toJson<String>(state),
      'areaHa': serializer.toJson<String>(areaHa),
      'stage': serializer.toJson<String>(stage),
      'status': serializer.toJson<String>(status),
      'ownerName': serializer.toJson<String?>(ownerName),
      'landType': serializer.toJson<String?>(landType),
      'geometryWkt': serializer.toJson<String?>(geometryWkt),
      'centroidLat': serializer.toJson<String?>(centroidLat),
      'centroidLng': serializer.toJson<String?>(centroidLng),
      'officerId': serializer.toJson<String>(officerId),
      'rawJson': serializer.toJson<String>(rawJson),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  AssignedTask copyWith({
    String? id,
    String? clientId,
    String? caseId,
    String? parcelId,
    String? projectId,
    String? caseNo,
    String? surveyNo,
    String? village,
    String? tehsil,
    String? district,
    String? state,
    String? areaHa,
    String? stage,
    String? status,
    Value<String?> ownerName = const Value.absent(),
    Value<String?> landType = const Value.absent(),
    Value<String?> geometryWkt = const Value.absent(),
    Value<String?> centroidLat = const Value.absent(),
    Value<String?> centroidLng = const Value.absent(),
    String? officerId,
    String? rawJson,
    DateTime? cachedAt,
  }) => AssignedTask(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    caseId: caseId ?? this.caseId,
    parcelId: parcelId ?? this.parcelId,
    projectId: projectId ?? this.projectId,
    caseNo: caseNo ?? this.caseNo,
    surveyNo: surveyNo ?? this.surveyNo,
    village: village ?? this.village,
    tehsil: tehsil ?? this.tehsil,
    district: district ?? this.district,
    state: state ?? this.state,
    areaHa: areaHa ?? this.areaHa,
    stage: stage ?? this.stage,
    status: status ?? this.status,
    ownerName: ownerName.present ? ownerName.value : this.ownerName,
    landType: landType.present ? landType.value : this.landType,
    geometryWkt: geometryWkt.present ? geometryWkt.value : this.geometryWkt,
    centroidLat: centroidLat.present ? centroidLat.value : this.centroidLat,
    centroidLng: centroidLng.present ? centroidLng.value : this.centroidLng,
    officerId: officerId ?? this.officerId,
    rawJson: rawJson ?? this.rawJson,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  AssignedTask copyWithCompanion(AssignedTasksCompanion data) {
    return AssignedTask(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      caseId: data.caseId.present ? data.caseId.value : this.caseId,
      parcelId: data.parcelId.present ? data.parcelId.value : this.parcelId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      caseNo: data.caseNo.present ? data.caseNo.value : this.caseNo,
      surveyNo: data.surveyNo.present ? data.surveyNo.value : this.surveyNo,
      village: data.village.present ? data.village.value : this.village,
      tehsil: data.tehsil.present ? data.tehsil.value : this.tehsil,
      district: data.district.present ? data.district.value : this.district,
      state: data.state.present ? data.state.value : this.state,
      areaHa: data.areaHa.present ? data.areaHa.value : this.areaHa,
      stage: data.stage.present ? data.stage.value : this.stage,
      status: data.status.present ? data.status.value : this.status,
      ownerName: data.ownerName.present ? data.ownerName.value : this.ownerName,
      landType: data.landType.present ? data.landType.value : this.landType,
      geometryWkt: data.geometryWkt.present
          ? data.geometryWkt.value
          : this.geometryWkt,
      centroidLat: data.centroidLat.present
          ? data.centroidLat.value
          : this.centroidLat,
      centroidLng: data.centroidLng.present
          ? data.centroidLng.value
          : this.centroidLng,
      officerId: data.officerId.present ? data.officerId.value : this.officerId,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssignedTask(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('caseId: $caseId, ')
          ..write('parcelId: $parcelId, ')
          ..write('projectId: $projectId, ')
          ..write('caseNo: $caseNo, ')
          ..write('surveyNo: $surveyNo, ')
          ..write('village: $village, ')
          ..write('tehsil: $tehsil, ')
          ..write('district: $district, ')
          ..write('state: $state, ')
          ..write('areaHa: $areaHa, ')
          ..write('stage: $stage, ')
          ..write('status: $status, ')
          ..write('ownerName: $ownerName, ')
          ..write('landType: $landType, ')
          ..write('geometryWkt: $geometryWkt, ')
          ..write('centroidLat: $centroidLat, ')
          ..write('centroidLng: $centroidLng, ')
          ..write('officerId: $officerId, ')
          ..write('rawJson: $rawJson, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    clientId,
    caseId,
    parcelId,
    projectId,
    caseNo,
    surveyNo,
    village,
    tehsil,
    district,
    state,
    areaHa,
    stage,
    status,
    ownerName,
    landType,
    geometryWkt,
    centroidLat,
    centroidLng,
    officerId,
    rawJson,
    cachedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssignedTask &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.caseId == this.caseId &&
          other.parcelId == this.parcelId &&
          other.projectId == this.projectId &&
          other.caseNo == this.caseNo &&
          other.surveyNo == this.surveyNo &&
          other.village == this.village &&
          other.tehsil == this.tehsil &&
          other.district == this.district &&
          other.state == this.state &&
          other.areaHa == this.areaHa &&
          other.stage == this.stage &&
          other.status == this.status &&
          other.ownerName == this.ownerName &&
          other.landType == this.landType &&
          other.geometryWkt == this.geometryWkt &&
          other.centroidLat == this.centroidLat &&
          other.centroidLng == this.centroidLng &&
          other.officerId == this.officerId &&
          other.rawJson == this.rawJson &&
          other.cachedAt == this.cachedAt);
}

class AssignedTasksCompanion extends UpdateCompanion<AssignedTask> {
  final Value<String> id;
  final Value<String> clientId;
  final Value<String> caseId;
  final Value<String> parcelId;
  final Value<String> projectId;
  final Value<String> caseNo;
  final Value<String> surveyNo;
  final Value<String> village;
  final Value<String> tehsil;
  final Value<String> district;
  final Value<String> state;
  final Value<String> areaHa;
  final Value<String> stage;
  final Value<String> status;
  final Value<String?> ownerName;
  final Value<String?> landType;
  final Value<String?> geometryWkt;
  final Value<String?> centroidLat;
  final Value<String?> centroidLng;
  final Value<String> officerId;
  final Value<String> rawJson;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const AssignedTasksCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.caseId = const Value.absent(),
    this.parcelId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.caseNo = const Value.absent(),
    this.surveyNo = const Value.absent(),
    this.village = const Value.absent(),
    this.tehsil = const Value.absent(),
    this.district = const Value.absent(),
    this.state = const Value.absent(),
    this.areaHa = const Value.absent(),
    this.stage = const Value.absent(),
    this.status = const Value.absent(),
    this.ownerName = const Value.absent(),
    this.landType = const Value.absent(),
    this.geometryWkt = const Value.absent(),
    this.centroidLat = const Value.absent(),
    this.centroidLng = const Value.absent(),
    this.officerId = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssignedTasksCompanion.insert({
    required String id,
    required String clientId,
    required String caseId,
    required String parcelId,
    required String projectId,
    required String caseNo,
    required String surveyNo,
    required String village,
    required String tehsil,
    required String district,
    required String state,
    required String areaHa,
    required String stage,
    required String status,
    this.ownerName = const Value.absent(),
    this.landType = const Value.absent(),
    this.geometryWkt = const Value.absent(),
    this.centroidLat = const Value.absent(),
    this.centroidLng = const Value.absent(),
    required String officerId,
    required String rawJson,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clientId = Value(clientId),
       caseId = Value(caseId),
       parcelId = Value(parcelId),
       projectId = Value(projectId),
       caseNo = Value(caseNo),
       surveyNo = Value(surveyNo),
       village = Value(village),
       tehsil = Value(tehsil),
       district = Value(district),
       state = Value(state),
       areaHa = Value(areaHa),
       stage = Value(stage),
       status = Value(status),
       officerId = Value(officerId),
       rawJson = Value(rawJson),
       cachedAt = Value(cachedAt);
  static Insertable<AssignedTask> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<String>? caseId,
    Expression<String>? parcelId,
    Expression<String>? projectId,
    Expression<String>? caseNo,
    Expression<String>? surveyNo,
    Expression<String>? village,
    Expression<String>? tehsil,
    Expression<String>? district,
    Expression<String>? state,
    Expression<String>? areaHa,
    Expression<String>? stage,
    Expression<String>? status,
    Expression<String>? ownerName,
    Expression<String>? landType,
    Expression<String>? geometryWkt,
    Expression<String>? centroidLat,
    Expression<String>? centroidLng,
    Expression<String>? officerId,
    Expression<String>? rawJson,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (caseId != null) 'case_id': caseId,
      if (parcelId != null) 'parcel_id': parcelId,
      if (projectId != null) 'project_id': projectId,
      if (caseNo != null) 'case_no': caseNo,
      if (surveyNo != null) 'survey_no': surveyNo,
      if (village != null) 'village': village,
      if (tehsil != null) 'tehsil': tehsil,
      if (district != null) 'district': district,
      if (state != null) 'state': state,
      if (areaHa != null) 'area_ha': areaHa,
      if (stage != null) 'stage': stage,
      if (status != null) 'status': status,
      if (ownerName != null) 'owner_name': ownerName,
      if (landType != null) 'land_type': landType,
      if (geometryWkt != null) 'geometry_wkt': geometryWkt,
      if (centroidLat != null) 'centroid_lat': centroidLat,
      if (centroidLng != null) 'centroid_lng': centroidLng,
      if (officerId != null) 'officer_id': officerId,
      if (rawJson != null) 'raw_json': rawJson,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssignedTasksCompanion copyWith({
    Value<String>? id,
    Value<String>? clientId,
    Value<String>? caseId,
    Value<String>? parcelId,
    Value<String>? projectId,
    Value<String>? caseNo,
    Value<String>? surveyNo,
    Value<String>? village,
    Value<String>? tehsil,
    Value<String>? district,
    Value<String>? state,
    Value<String>? areaHa,
    Value<String>? stage,
    Value<String>? status,
    Value<String?>? ownerName,
    Value<String?>? landType,
    Value<String?>? geometryWkt,
    Value<String?>? centroidLat,
    Value<String?>? centroidLng,
    Value<String>? officerId,
    Value<String>? rawJson,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return AssignedTasksCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      caseId: caseId ?? this.caseId,
      parcelId: parcelId ?? this.parcelId,
      projectId: projectId ?? this.projectId,
      caseNo: caseNo ?? this.caseNo,
      surveyNo: surveyNo ?? this.surveyNo,
      village: village ?? this.village,
      tehsil: tehsil ?? this.tehsil,
      district: district ?? this.district,
      state: state ?? this.state,
      areaHa: areaHa ?? this.areaHa,
      stage: stage ?? this.stage,
      status: status ?? this.status,
      ownerName: ownerName ?? this.ownerName,
      landType: landType ?? this.landType,
      geometryWkt: geometryWkt ?? this.geometryWkt,
      centroidLat: centroidLat ?? this.centroidLat,
      centroidLng: centroidLng ?? this.centroidLng,
      officerId: officerId ?? this.officerId,
      rawJson: rawJson ?? this.rawJson,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (caseId.present) {
      map['case_id'] = Variable<String>(caseId.value);
    }
    if (parcelId.present) {
      map['parcel_id'] = Variable<String>(parcelId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (caseNo.present) {
      map['case_no'] = Variable<String>(caseNo.value);
    }
    if (surveyNo.present) {
      map['survey_no'] = Variable<String>(surveyNo.value);
    }
    if (village.present) {
      map['village'] = Variable<String>(village.value);
    }
    if (tehsil.present) {
      map['tehsil'] = Variable<String>(tehsil.value);
    }
    if (district.present) {
      map['district'] = Variable<String>(district.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (areaHa.present) {
      map['area_ha'] = Variable<String>(areaHa.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (ownerName.present) {
      map['owner_name'] = Variable<String>(ownerName.value);
    }
    if (landType.present) {
      map['land_type'] = Variable<String>(landType.value);
    }
    if (geometryWkt.present) {
      map['geometry_wkt'] = Variable<String>(geometryWkt.value);
    }
    if (centroidLat.present) {
      map['centroid_lat'] = Variable<String>(centroidLat.value);
    }
    if (centroidLng.present) {
      map['centroid_lng'] = Variable<String>(centroidLng.value);
    }
    if (officerId.present) {
      map['officer_id'] = Variable<String>(officerId.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssignedTasksCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('caseId: $caseId, ')
          ..write('parcelId: $parcelId, ')
          ..write('projectId: $projectId, ')
          ..write('caseNo: $caseNo, ')
          ..write('surveyNo: $surveyNo, ')
          ..write('village: $village, ')
          ..write('tehsil: $tehsil, ')
          ..write('district: $district, ')
          ..write('state: $state, ')
          ..write('areaHa: $areaHa, ')
          ..write('stage: $stage, ')
          ..write('status: $status, ')
          ..write('ownerName: $ownerName, ')
          ..write('landType: $landType, ')
          ..write('geometryWkt: $geometryWkt, ')
          ..write('centroidLat: $centroidLat, ')
          ..write('centroidLng: $centroidLng, ')
          ..write('officerId: $officerId, ')
          ..write('rawJson: $rawJson, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FieldVisitsTable extends FieldVisits
    with TableInfo<$FieldVisitsTable, FieldVisit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FieldVisitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parcelIdMeta = const VerificationMeta(
    'parcelId',
  );
  @override
  late final GeneratedColumn<String> parcelId = GeneratedColumn<String>(
    'parcel_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caseIdMeta = const VerificationMeta('caseId');
  @override
  late final GeneratedColumn<String> caseId = GeneratedColumn<String>(
    'case_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _officerIdMeta = const VerificationMeta(
    'officerId',
  );
  @override
  late final GeneratedColumn<String> officerId = GeneratedColumn<String>(
    'officer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _landUseMeta = const VerificationMeta(
    'landUse',
  );
  @override
  late final GeneratedColumn<String> landUse = GeneratedColumn<String>(
    'land_use',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _irrigationMeta = const VerificationMeta(
    'irrigation',
  );
  @override
  late final GeneratedColumn<String> irrigation = GeneratedColumn<String>(
    'irrigation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _boundaryConfirmedMeta = const VerificationMeta(
    'boundaryConfirmed',
  );
  @override
  late final GeneratedColumn<bool> boundaryConfirmed = GeneratedColumn<bool>(
    'boundary_confirmed',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("boundary_confirmed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _verificationServerIdMeta =
      const VerificationMeta('verificationServerId');
  @override
  late final GeneratedColumn<String> verificationServerId =
      GeneratedColumn<String>(
        'verification_server_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _gpsLatMeta = const VerificationMeta('gpsLat');
  @override
  late final GeneratedColumn<String> gpsLat = GeneratedColumn<String>(
    'gps_lat',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gpsLngMeta = const VerificationMeta('gpsLng');
  @override
  late final GeneratedColumn<String> gpsLng = GeneratedColumn<String>(
    'gps_lng',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gpsAccuracyMeta = const VerificationMeta(
    'gpsAccuracy',
  );
  @override
  late final GeneratedColumn<String> gpsAccuracy = GeneratedColumn<String>(
    'gps_accuracy',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gpsTimestampMeta = const VerificationMeta(
    'gpsTimestamp',
  );
  @override
  late final GeneratedColumn<String> gpsTimestamp = GeneratedColumn<String>(
    'gps_timestamp',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _submittedAtMeta = const VerificationMeta(
    'submittedAt',
  );
  @override
  late final GeneratedColumn<DateTime> submittedAt = GeneratedColumn<DateTime>(
    'submitted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    taskId,
    parcelId,
    caseId,
    officerId,
    status,
    syncStatus,
    landUse,
    irrigation,
    boundaryConfirmed,
    notes,
    verificationServerId,
    lastError,
    retryCount,
    gpsLat,
    gpsLng,
    gpsAccuracy,
    gpsTimestamp,
    createdAt,
    updatedAt,
    submittedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'field_visits';
  @override
  VerificationContext validateIntegrity(
    Insertable<FieldVisit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('parcel_id')) {
      context.handle(
        _parcelIdMeta,
        parcelId.isAcceptableOrUnknown(data['parcel_id']!, _parcelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_parcelIdMeta);
    }
    if (data.containsKey('case_id')) {
      context.handle(
        _caseIdMeta,
        caseId.isAcceptableOrUnknown(data['case_id']!, _caseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caseIdMeta);
    }
    if (data.containsKey('officer_id')) {
      context.handle(
        _officerIdMeta,
        officerId.isAcceptableOrUnknown(data['officer_id']!, _officerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_officerIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    if (data.containsKey('land_use')) {
      context.handle(
        _landUseMeta,
        landUse.isAcceptableOrUnknown(data['land_use']!, _landUseMeta),
      );
    }
    if (data.containsKey('irrigation')) {
      context.handle(
        _irrigationMeta,
        irrigation.isAcceptableOrUnknown(data['irrigation']!, _irrigationMeta),
      );
    }
    if (data.containsKey('boundary_confirmed')) {
      context.handle(
        _boundaryConfirmedMeta,
        boundaryConfirmed.isAcceptableOrUnknown(
          data['boundary_confirmed']!,
          _boundaryConfirmedMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('verification_server_id')) {
      context.handle(
        _verificationServerIdMeta,
        verificationServerId.isAcceptableOrUnknown(
          data['verification_server_id']!,
          _verificationServerIdMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('gps_lat')) {
      context.handle(
        _gpsLatMeta,
        gpsLat.isAcceptableOrUnknown(data['gps_lat']!, _gpsLatMeta),
      );
    }
    if (data.containsKey('gps_lng')) {
      context.handle(
        _gpsLngMeta,
        gpsLng.isAcceptableOrUnknown(data['gps_lng']!, _gpsLngMeta),
      );
    }
    if (data.containsKey('gps_accuracy')) {
      context.handle(
        _gpsAccuracyMeta,
        gpsAccuracy.isAcceptableOrUnknown(
          data['gps_accuracy']!,
          _gpsAccuracyMeta,
        ),
      );
    }
    if (data.containsKey('gps_timestamp')) {
      context.handle(
        _gpsTimestampMeta,
        gpsTimestamp.isAcceptableOrUnknown(
          data['gps_timestamp']!,
          _gpsTimestampMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('submitted_at')) {
      context.handle(
        _submittedAtMeta,
        submittedAt.isAcceptableOrUnknown(
          data['submitted_at']!,
          _submittedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FieldVisit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FieldVisit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      parcelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parcel_id'],
      )!,
      caseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}case_id'],
      )!,
      officerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}officer_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      landUse: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}land_use'],
      ),
      irrigation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}irrigation'],
      ),
      boundaryConfirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}boundary_confirmed'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      verificationServerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verification_server_id'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      gpsLat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gps_lat'],
      ),
      gpsLng: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gps_lng'],
      ),
      gpsAccuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gps_accuracy'],
      ),
      gpsTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gps_timestamp'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      submittedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}submitted_at'],
      ),
    );
  }

  @override
  $FieldVisitsTable createAlias(String alias) {
    return $FieldVisitsTable(attachedDatabase, alias);
  }
}

class FieldVisit extends DataClass implements Insertable<FieldVisit> {
  final String id;
  final String clientId;
  final String taskId;
  final String parcelId;
  final String caseId;
  final String officerId;
  final String status;
  final String syncStatus;
  final String? landUse;
  final String? irrigation;
  final bool? boundaryConfirmed;
  final String? notes;
  final String? verificationServerId;
  final String? lastError;
  final int retryCount;
  final String? gpsLat;
  final String? gpsLng;
  final String? gpsAccuracy;
  final String? gpsTimestamp;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? submittedAt;
  const FieldVisit({
    required this.id,
    required this.clientId,
    required this.taskId,
    required this.parcelId,
    required this.caseId,
    required this.officerId,
    required this.status,
    required this.syncStatus,
    this.landUse,
    this.irrigation,
    this.boundaryConfirmed,
    this.notes,
    this.verificationServerId,
    this.lastError,
    required this.retryCount,
    this.gpsLat,
    this.gpsLng,
    this.gpsAccuracy,
    this.gpsTimestamp,
    required this.createdAt,
    required this.updatedAt,
    this.submittedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_id'] = Variable<String>(clientId);
    map['task_id'] = Variable<String>(taskId);
    map['parcel_id'] = Variable<String>(parcelId);
    map['case_id'] = Variable<String>(caseId);
    map['officer_id'] = Variable<String>(officerId);
    map['status'] = Variable<String>(status);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || landUse != null) {
      map['land_use'] = Variable<String>(landUse);
    }
    if (!nullToAbsent || irrigation != null) {
      map['irrigation'] = Variable<String>(irrigation);
    }
    if (!nullToAbsent || boundaryConfirmed != null) {
      map['boundary_confirmed'] = Variable<bool>(boundaryConfirmed);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || verificationServerId != null) {
      map['verification_server_id'] = Variable<String>(verificationServerId);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || gpsLat != null) {
      map['gps_lat'] = Variable<String>(gpsLat);
    }
    if (!nullToAbsent || gpsLng != null) {
      map['gps_lng'] = Variable<String>(gpsLng);
    }
    if (!nullToAbsent || gpsAccuracy != null) {
      map['gps_accuracy'] = Variable<String>(gpsAccuracy);
    }
    if (!nullToAbsent || gpsTimestamp != null) {
      map['gps_timestamp'] = Variable<String>(gpsTimestamp);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || submittedAt != null) {
      map['submitted_at'] = Variable<DateTime>(submittedAt);
    }
    return map;
  }

  FieldVisitsCompanion toCompanion(bool nullToAbsent) {
    return FieldVisitsCompanion(
      id: Value(id),
      clientId: Value(clientId),
      taskId: Value(taskId),
      parcelId: Value(parcelId),
      caseId: Value(caseId),
      officerId: Value(officerId),
      status: Value(status),
      syncStatus: Value(syncStatus),
      landUse: landUse == null && nullToAbsent
          ? const Value.absent()
          : Value(landUse),
      irrigation: irrigation == null && nullToAbsent
          ? const Value.absent()
          : Value(irrigation),
      boundaryConfirmed: boundaryConfirmed == null && nullToAbsent
          ? const Value.absent()
          : Value(boundaryConfirmed),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      verificationServerId: verificationServerId == null && nullToAbsent
          ? const Value.absent()
          : Value(verificationServerId),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      retryCount: Value(retryCount),
      gpsLat: gpsLat == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsLat),
      gpsLng: gpsLng == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsLng),
      gpsAccuracy: gpsAccuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsAccuracy),
      gpsTimestamp: gpsTimestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsTimestamp),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      submittedAt: submittedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(submittedAt),
    );
  }

  factory FieldVisit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FieldVisit(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      taskId: serializer.fromJson<String>(json['taskId']),
      parcelId: serializer.fromJson<String>(json['parcelId']),
      caseId: serializer.fromJson<String>(json['caseId']),
      officerId: serializer.fromJson<String>(json['officerId']),
      status: serializer.fromJson<String>(json['status']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      landUse: serializer.fromJson<String?>(json['landUse']),
      irrigation: serializer.fromJson<String?>(json['irrigation']),
      boundaryConfirmed: serializer.fromJson<bool?>(json['boundaryConfirmed']),
      notes: serializer.fromJson<String?>(json['notes']),
      verificationServerId: serializer.fromJson<String?>(
        json['verificationServerId'],
      ),
      lastError: serializer.fromJson<String?>(json['lastError']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      gpsLat: serializer.fromJson<String?>(json['gpsLat']),
      gpsLng: serializer.fromJson<String?>(json['gpsLng']),
      gpsAccuracy: serializer.fromJson<String?>(json['gpsAccuracy']),
      gpsTimestamp: serializer.fromJson<String?>(json['gpsTimestamp']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      submittedAt: serializer.fromJson<DateTime?>(json['submittedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String>(clientId),
      'taskId': serializer.toJson<String>(taskId),
      'parcelId': serializer.toJson<String>(parcelId),
      'caseId': serializer.toJson<String>(caseId),
      'officerId': serializer.toJson<String>(officerId),
      'status': serializer.toJson<String>(status),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'landUse': serializer.toJson<String?>(landUse),
      'irrigation': serializer.toJson<String?>(irrigation),
      'boundaryConfirmed': serializer.toJson<bool?>(boundaryConfirmed),
      'notes': serializer.toJson<String?>(notes),
      'verificationServerId': serializer.toJson<String?>(verificationServerId),
      'lastError': serializer.toJson<String?>(lastError),
      'retryCount': serializer.toJson<int>(retryCount),
      'gpsLat': serializer.toJson<String?>(gpsLat),
      'gpsLng': serializer.toJson<String?>(gpsLng),
      'gpsAccuracy': serializer.toJson<String?>(gpsAccuracy),
      'gpsTimestamp': serializer.toJson<String?>(gpsTimestamp),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'submittedAt': serializer.toJson<DateTime?>(submittedAt),
    };
  }

  FieldVisit copyWith({
    String? id,
    String? clientId,
    String? taskId,
    String? parcelId,
    String? caseId,
    String? officerId,
    String? status,
    String? syncStatus,
    Value<String?> landUse = const Value.absent(),
    Value<String?> irrigation = const Value.absent(),
    Value<bool?> boundaryConfirmed = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> verificationServerId = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    int? retryCount,
    Value<String?> gpsLat = const Value.absent(),
    Value<String?> gpsLng = const Value.absent(),
    Value<String?> gpsAccuracy = const Value.absent(),
    Value<String?> gpsTimestamp = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> submittedAt = const Value.absent(),
  }) => FieldVisit(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    taskId: taskId ?? this.taskId,
    parcelId: parcelId ?? this.parcelId,
    caseId: caseId ?? this.caseId,
    officerId: officerId ?? this.officerId,
    status: status ?? this.status,
    syncStatus: syncStatus ?? this.syncStatus,
    landUse: landUse.present ? landUse.value : this.landUse,
    irrigation: irrigation.present ? irrigation.value : this.irrigation,
    boundaryConfirmed: boundaryConfirmed.present
        ? boundaryConfirmed.value
        : this.boundaryConfirmed,
    notes: notes.present ? notes.value : this.notes,
    verificationServerId: verificationServerId.present
        ? verificationServerId.value
        : this.verificationServerId,
    lastError: lastError.present ? lastError.value : this.lastError,
    retryCount: retryCount ?? this.retryCount,
    gpsLat: gpsLat.present ? gpsLat.value : this.gpsLat,
    gpsLng: gpsLng.present ? gpsLng.value : this.gpsLng,
    gpsAccuracy: gpsAccuracy.present ? gpsAccuracy.value : this.gpsAccuracy,
    gpsTimestamp: gpsTimestamp.present ? gpsTimestamp.value : this.gpsTimestamp,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    submittedAt: submittedAt.present ? submittedAt.value : this.submittedAt,
  );
  FieldVisit copyWithCompanion(FieldVisitsCompanion data) {
    return FieldVisit(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      parcelId: data.parcelId.present ? data.parcelId.value : this.parcelId,
      caseId: data.caseId.present ? data.caseId.value : this.caseId,
      officerId: data.officerId.present ? data.officerId.value : this.officerId,
      status: data.status.present ? data.status.value : this.status,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      landUse: data.landUse.present ? data.landUse.value : this.landUse,
      irrigation: data.irrigation.present
          ? data.irrigation.value
          : this.irrigation,
      boundaryConfirmed: data.boundaryConfirmed.present
          ? data.boundaryConfirmed.value
          : this.boundaryConfirmed,
      notes: data.notes.present ? data.notes.value : this.notes,
      verificationServerId: data.verificationServerId.present
          ? data.verificationServerId.value
          : this.verificationServerId,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      gpsLat: data.gpsLat.present ? data.gpsLat.value : this.gpsLat,
      gpsLng: data.gpsLng.present ? data.gpsLng.value : this.gpsLng,
      gpsAccuracy: data.gpsAccuracy.present
          ? data.gpsAccuracy.value
          : this.gpsAccuracy,
      gpsTimestamp: data.gpsTimestamp.present
          ? data.gpsTimestamp.value
          : this.gpsTimestamp,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      submittedAt: data.submittedAt.present
          ? data.submittedAt.value
          : this.submittedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FieldVisit(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('taskId: $taskId, ')
          ..write('parcelId: $parcelId, ')
          ..write('caseId: $caseId, ')
          ..write('officerId: $officerId, ')
          ..write('status: $status, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('landUse: $landUse, ')
          ..write('irrigation: $irrigation, ')
          ..write('boundaryConfirmed: $boundaryConfirmed, ')
          ..write('notes: $notes, ')
          ..write('verificationServerId: $verificationServerId, ')
          ..write('lastError: $lastError, ')
          ..write('retryCount: $retryCount, ')
          ..write('gpsLat: $gpsLat, ')
          ..write('gpsLng: $gpsLng, ')
          ..write('gpsAccuracy: $gpsAccuracy, ')
          ..write('gpsTimestamp: $gpsTimestamp, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('submittedAt: $submittedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    clientId,
    taskId,
    parcelId,
    caseId,
    officerId,
    status,
    syncStatus,
    landUse,
    irrigation,
    boundaryConfirmed,
    notes,
    verificationServerId,
    lastError,
    retryCount,
    gpsLat,
    gpsLng,
    gpsAccuracy,
    gpsTimestamp,
    createdAt,
    updatedAt,
    submittedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FieldVisit &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.taskId == this.taskId &&
          other.parcelId == this.parcelId &&
          other.caseId == this.caseId &&
          other.officerId == this.officerId &&
          other.status == this.status &&
          other.syncStatus == this.syncStatus &&
          other.landUse == this.landUse &&
          other.irrigation == this.irrigation &&
          other.boundaryConfirmed == this.boundaryConfirmed &&
          other.notes == this.notes &&
          other.verificationServerId == this.verificationServerId &&
          other.lastError == this.lastError &&
          other.retryCount == this.retryCount &&
          other.gpsLat == this.gpsLat &&
          other.gpsLng == this.gpsLng &&
          other.gpsAccuracy == this.gpsAccuracy &&
          other.gpsTimestamp == this.gpsTimestamp &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.submittedAt == this.submittedAt);
}

class FieldVisitsCompanion extends UpdateCompanion<FieldVisit> {
  final Value<String> id;
  final Value<String> clientId;
  final Value<String> taskId;
  final Value<String> parcelId;
  final Value<String> caseId;
  final Value<String> officerId;
  final Value<String> status;
  final Value<String> syncStatus;
  final Value<String?> landUse;
  final Value<String?> irrigation;
  final Value<bool?> boundaryConfirmed;
  final Value<String?> notes;
  final Value<String?> verificationServerId;
  final Value<String?> lastError;
  final Value<int> retryCount;
  final Value<String?> gpsLat;
  final Value<String?> gpsLng;
  final Value<String?> gpsAccuracy;
  final Value<String?> gpsTimestamp;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> submittedAt;
  final Value<int> rowid;
  const FieldVisitsCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.parcelId = const Value.absent(),
    this.caseId = const Value.absent(),
    this.officerId = const Value.absent(),
    this.status = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.landUse = const Value.absent(),
    this.irrigation = const Value.absent(),
    this.boundaryConfirmed = const Value.absent(),
    this.notes = const Value.absent(),
    this.verificationServerId = const Value.absent(),
    this.lastError = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.gpsLat = const Value.absent(),
    this.gpsLng = const Value.absent(),
    this.gpsAccuracy = const Value.absent(),
    this.gpsTimestamp = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FieldVisitsCompanion.insert({
    required String id,
    required String clientId,
    required String taskId,
    required String parcelId,
    required String caseId,
    required String officerId,
    required String status,
    required String syncStatus,
    this.landUse = const Value.absent(),
    this.irrigation = const Value.absent(),
    this.boundaryConfirmed = const Value.absent(),
    this.notes = const Value.absent(),
    this.verificationServerId = const Value.absent(),
    this.lastError = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.gpsLat = const Value.absent(),
    this.gpsLng = const Value.absent(),
    this.gpsAccuracy = const Value.absent(),
    this.gpsTimestamp = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.submittedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clientId = Value(clientId),
       taskId = Value(taskId),
       parcelId = Value(parcelId),
       caseId = Value(caseId),
       officerId = Value(officerId),
       status = Value(status),
       syncStatus = Value(syncStatus),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FieldVisit> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<String>? taskId,
    Expression<String>? parcelId,
    Expression<String>? caseId,
    Expression<String>? officerId,
    Expression<String>? status,
    Expression<String>? syncStatus,
    Expression<String>? landUse,
    Expression<String>? irrigation,
    Expression<bool>? boundaryConfirmed,
    Expression<String>? notes,
    Expression<String>? verificationServerId,
    Expression<String>? lastError,
    Expression<int>? retryCount,
    Expression<String>? gpsLat,
    Expression<String>? gpsLng,
    Expression<String>? gpsAccuracy,
    Expression<String>? gpsTimestamp,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? submittedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (taskId != null) 'task_id': taskId,
      if (parcelId != null) 'parcel_id': parcelId,
      if (caseId != null) 'case_id': caseId,
      if (officerId != null) 'officer_id': officerId,
      if (status != null) 'status': status,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (landUse != null) 'land_use': landUse,
      if (irrigation != null) 'irrigation': irrigation,
      if (boundaryConfirmed != null) 'boundary_confirmed': boundaryConfirmed,
      if (notes != null) 'notes': notes,
      if (verificationServerId != null)
        'verification_server_id': verificationServerId,
      if (lastError != null) 'last_error': lastError,
      if (retryCount != null) 'retry_count': retryCount,
      if (gpsLat != null) 'gps_lat': gpsLat,
      if (gpsLng != null) 'gps_lng': gpsLng,
      if (gpsAccuracy != null) 'gps_accuracy': gpsAccuracy,
      if (gpsTimestamp != null) 'gps_timestamp': gpsTimestamp,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (submittedAt != null) 'submitted_at': submittedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FieldVisitsCompanion copyWith({
    Value<String>? id,
    Value<String>? clientId,
    Value<String>? taskId,
    Value<String>? parcelId,
    Value<String>? caseId,
    Value<String>? officerId,
    Value<String>? status,
    Value<String>? syncStatus,
    Value<String?>? landUse,
    Value<String?>? irrigation,
    Value<bool?>? boundaryConfirmed,
    Value<String?>? notes,
    Value<String?>? verificationServerId,
    Value<String?>? lastError,
    Value<int>? retryCount,
    Value<String?>? gpsLat,
    Value<String?>? gpsLng,
    Value<String?>? gpsAccuracy,
    Value<String?>? gpsTimestamp,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? submittedAt,
    Value<int>? rowid,
  }) {
    return FieldVisitsCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      taskId: taskId ?? this.taskId,
      parcelId: parcelId ?? this.parcelId,
      caseId: caseId ?? this.caseId,
      officerId: officerId ?? this.officerId,
      status: status ?? this.status,
      syncStatus: syncStatus ?? this.syncStatus,
      landUse: landUse ?? this.landUse,
      irrigation: irrigation ?? this.irrigation,
      boundaryConfirmed: boundaryConfirmed ?? this.boundaryConfirmed,
      notes: notes ?? this.notes,
      verificationServerId: verificationServerId ?? this.verificationServerId,
      lastError: lastError ?? this.lastError,
      retryCount: retryCount ?? this.retryCount,
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLng: gpsLng ?? this.gpsLng,
      gpsAccuracy: gpsAccuracy ?? this.gpsAccuracy,
      gpsTimestamp: gpsTimestamp ?? this.gpsTimestamp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (parcelId.present) {
      map['parcel_id'] = Variable<String>(parcelId.value);
    }
    if (caseId.present) {
      map['case_id'] = Variable<String>(caseId.value);
    }
    if (officerId.present) {
      map['officer_id'] = Variable<String>(officerId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (landUse.present) {
      map['land_use'] = Variable<String>(landUse.value);
    }
    if (irrigation.present) {
      map['irrigation'] = Variable<String>(irrigation.value);
    }
    if (boundaryConfirmed.present) {
      map['boundary_confirmed'] = Variable<bool>(boundaryConfirmed.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (verificationServerId.present) {
      map['verification_server_id'] = Variable<String>(
        verificationServerId.value,
      );
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (gpsLat.present) {
      map['gps_lat'] = Variable<String>(gpsLat.value);
    }
    if (gpsLng.present) {
      map['gps_lng'] = Variable<String>(gpsLng.value);
    }
    if (gpsAccuracy.present) {
      map['gps_accuracy'] = Variable<String>(gpsAccuracy.value);
    }
    if (gpsTimestamp.present) {
      map['gps_timestamp'] = Variable<String>(gpsTimestamp.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (submittedAt.present) {
      map['submitted_at'] = Variable<DateTime>(submittedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FieldVisitsCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('taskId: $taskId, ')
          ..write('parcelId: $parcelId, ')
          ..write('caseId: $caseId, ')
          ..write('officerId: $officerId, ')
          ..write('status: $status, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('landUse: $landUse, ')
          ..write('irrigation: $irrigation, ')
          ..write('boundaryConfirmed: $boundaryConfirmed, ')
          ..write('notes: $notes, ')
          ..write('verificationServerId: $verificationServerId, ')
          ..write('lastError: $lastError, ')
          ..write('retryCount: $retryCount, ')
          ..write('gpsLat: $gpsLat, ')
          ..write('gpsLng: $gpsLng, ')
          ..write('gpsAccuracy: $gpsAccuracy, ')
          ..write('gpsTimestamp: $gpsTimestamp, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StructuresTable extends Structures
    with TableInfo<$StructuresTable, Structure> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StructuresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visitIdMeta = const VerificationMeta(
    'visitId',
  );
  @override
  late final GeneratedColumn<String> visitId = GeneratedColumn<String>(
    'visit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaValueMeta = const VerificationMeta(
    'areaValue',
  );
  @override
  late final GeneratedColumn<double> areaValue = GeneratedColumn<double>(
    'area_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _areaUnitMeta = const VerificationMeta(
    'areaUnit',
  );
  @override
  late final GeneratedColumn<String> areaUnit = GeneratedColumn<String>(
    'area_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('sq_ft'),
  );
  static const VerificationMeta _constructionTypeMeta = const VerificationMeta(
    'constructionType',
  );
  @override
  late final GeneratedColumn<String> constructionType = GeneratedColumn<String>(
    'construction_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conditionMeta = const VerificationMeta(
    'condition',
  );
  @override
  late final GeneratedColumn<String> condition = GeneratedColumn<String>(
    'condition',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    visitId,
    type,
    areaValue,
    areaUnit,
    constructionType,
    condition,
    notes,
    syncStatus,
    serverId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'structures';
  @override
  VerificationContext validateIntegrity(
    Insertable<Structure> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('visit_id')) {
      context.handle(
        _visitIdMeta,
        visitId.isAcceptableOrUnknown(data['visit_id']!, _visitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_visitIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('area_value')) {
      context.handle(
        _areaValueMeta,
        areaValue.isAcceptableOrUnknown(data['area_value']!, _areaValueMeta),
      );
    }
    if (data.containsKey('area_unit')) {
      context.handle(
        _areaUnitMeta,
        areaUnit.isAcceptableOrUnknown(data['area_unit']!, _areaUnitMeta),
      );
    }
    if (data.containsKey('construction_type')) {
      context.handle(
        _constructionTypeMeta,
        constructionType.isAcceptableOrUnknown(
          data['construction_type']!,
          _constructionTypeMeta,
        ),
      );
    }
    if (data.containsKey('condition')) {
      context.handle(
        _conditionMeta,
        condition.isAcceptableOrUnknown(data['condition']!, _conditionMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Structure map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Structure(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      visitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      areaValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}area_value'],
      ),
      areaUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_unit'],
      )!,
      constructionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}construction_type'],
      ),
      condition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StructuresTable createAlias(String alias) {
    return $StructuresTable(attachedDatabase, alias);
  }
}

class Structure extends DataClass implements Insertable<Structure> {
  final String id;
  final String clientId;
  final String visitId;
  final String type;
  final double? areaValue;
  final String areaUnit;
  final String? constructionType;
  final String? condition;
  final String? notes;
  final String syncStatus;
  final String? serverId;
  final DateTime createdAt;
  const Structure({
    required this.id,
    required this.clientId,
    required this.visitId,
    required this.type,
    this.areaValue,
    required this.areaUnit,
    this.constructionType,
    this.condition,
    this.notes,
    required this.syncStatus,
    this.serverId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_id'] = Variable<String>(clientId);
    map['visit_id'] = Variable<String>(visitId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || areaValue != null) {
      map['area_value'] = Variable<double>(areaValue);
    }
    map['area_unit'] = Variable<String>(areaUnit);
    if (!nullToAbsent || constructionType != null) {
      map['construction_type'] = Variable<String>(constructionType);
    }
    if (!nullToAbsent || condition != null) {
      map['condition'] = Variable<String>(condition);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StructuresCompanion toCompanion(bool nullToAbsent) {
    return StructuresCompanion(
      id: Value(id),
      clientId: Value(clientId),
      visitId: Value(visitId),
      type: Value(type),
      areaValue: areaValue == null && nullToAbsent
          ? const Value.absent()
          : Value(areaValue),
      areaUnit: Value(areaUnit),
      constructionType: constructionType == null && nullToAbsent
          ? const Value.absent()
          : Value(constructionType),
      condition: condition == null && nullToAbsent
          ? const Value.absent()
          : Value(condition),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      syncStatus: Value(syncStatus),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      createdAt: Value(createdAt),
    );
  }

  factory Structure.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Structure(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      visitId: serializer.fromJson<String>(json['visitId']),
      type: serializer.fromJson<String>(json['type']),
      areaValue: serializer.fromJson<double?>(json['areaValue']),
      areaUnit: serializer.fromJson<String>(json['areaUnit']),
      constructionType: serializer.fromJson<String?>(json['constructionType']),
      condition: serializer.fromJson<String?>(json['condition']),
      notes: serializer.fromJson<String?>(json['notes']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String>(clientId),
      'visitId': serializer.toJson<String>(visitId),
      'type': serializer.toJson<String>(type),
      'areaValue': serializer.toJson<double?>(areaValue),
      'areaUnit': serializer.toJson<String>(areaUnit),
      'constructionType': serializer.toJson<String?>(constructionType),
      'condition': serializer.toJson<String?>(condition),
      'notes': serializer.toJson<String?>(notes),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'serverId': serializer.toJson<String?>(serverId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Structure copyWith({
    String? id,
    String? clientId,
    String? visitId,
    String? type,
    Value<double?> areaValue = const Value.absent(),
    String? areaUnit,
    Value<String?> constructionType = const Value.absent(),
    Value<String?> condition = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? syncStatus,
    Value<String?> serverId = const Value.absent(),
    DateTime? createdAt,
  }) => Structure(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    visitId: visitId ?? this.visitId,
    type: type ?? this.type,
    areaValue: areaValue.present ? areaValue.value : this.areaValue,
    areaUnit: areaUnit ?? this.areaUnit,
    constructionType: constructionType.present
        ? constructionType.value
        : this.constructionType,
    condition: condition.present ? condition.value : this.condition,
    notes: notes.present ? notes.value : this.notes,
    syncStatus: syncStatus ?? this.syncStatus,
    serverId: serverId.present ? serverId.value : this.serverId,
    createdAt: createdAt ?? this.createdAt,
  );
  Structure copyWithCompanion(StructuresCompanion data) {
    return Structure(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      visitId: data.visitId.present ? data.visitId.value : this.visitId,
      type: data.type.present ? data.type.value : this.type,
      areaValue: data.areaValue.present ? data.areaValue.value : this.areaValue,
      areaUnit: data.areaUnit.present ? data.areaUnit.value : this.areaUnit,
      constructionType: data.constructionType.present
          ? data.constructionType.value
          : this.constructionType,
      condition: data.condition.present ? data.condition.value : this.condition,
      notes: data.notes.present ? data.notes.value : this.notes,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Structure(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('visitId: $visitId, ')
          ..write('type: $type, ')
          ..write('areaValue: $areaValue, ')
          ..write('areaUnit: $areaUnit, ')
          ..write('constructionType: $constructionType, ')
          ..write('condition: $condition, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverId: $serverId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    visitId,
    type,
    areaValue,
    areaUnit,
    constructionType,
    condition,
    notes,
    syncStatus,
    serverId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Structure &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.visitId == this.visitId &&
          other.type == this.type &&
          other.areaValue == this.areaValue &&
          other.areaUnit == this.areaUnit &&
          other.constructionType == this.constructionType &&
          other.condition == this.condition &&
          other.notes == this.notes &&
          other.syncStatus == this.syncStatus &&
          other.serverId == this.serverId &&
          other.createdAt == this.createdAt);
}

class StructuresCompanion extends UpdateCompanion<Structure> {
  final Value<String> id;
  final Value<String> clientId;
  final Value<String> visitId;
  final Value<String> type;
  final Value<double?> areaValue;
  final Value<String> areaUnit;
  final Value<String?> constructionType;
  final Value<String?> condition;
  final Value<String?> notes;
  final Value<String> syncStatus;
  final Value<String?> serverId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StructuresCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.visitId = const Value.absent(),
    this.type = const Value.absent(),
    this.areaValue = const Value.absent(),
    this.areaUnit = const Value.absent(),
    this.constructionType = const Value.absent(),
    this.condition = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.serverId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StructuresCompanion.insert({
    required String id,
    required String clientId,
    required String visitId,
    required String type,
    this.areaValue = const Value.absent(),
    this.areaUnit = const Value.absent(),
    this.constructionType = const Value.absent(),
    this.condition = const Value.absent(),
    this.notes = const Value.absent(),
    required String syncStatus,
    this.serverId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clientId = Value(clientId),
       visitId = Value(visitId),
       type = Value(type),
       syncStatus = Value(syncStatus),
       createdAt = Value(createdAt);
  static Insertable<Structure> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<String>? visitId,
    Expression<String>? type,
    Expression<double>? areaValue,
    Expression<String>? areaUnit,
    Expression<String>? constructionType,
    Expression<String>? condition,
    Expression<String>? notes,
    Expression<String>? syncStatus,
    Expression<String>? serverId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (visitId != null) 'visit_id': visitId,
      if (type != null) 'type': type,
      if (areaValue != null) 'area_value': areaValue,
      if (areaUnit != null) 'area_unit': areaUnit,
      if (constructionType != null) 'construction_type': constructionType,
      if (condition != null) 'condition': condition,
      if (notes != null) 'notes': notes,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (serverId != null) 'server_id': serverId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StructuresCompanion copyWith({
    Value<String>? id,
    Value<String>? clientId,
    Value<String>? visitId,
    Value<String>? type,
    Value<double?>? areaValue,
    Value<String>? areaUnit,
    Value<String?>? constructionType,
    Value<String?>? condition,
    Value<String?>? notes,
    Value<String>? syncStatus,
    Value<String?>? serverId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return StructuresCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      visitId: visitId ?? this.visitId,
      type: type ?? this.type,
      areaValue: areaValue ?? this.areaValue,
      areaUnit: areaUnit ?? this.areaUnit,
      constructionType: constructionType ?? this.constructionType,
      condition: condition ?? this.condition,
      notes: notes ?? this.notes,
      syncStatus: syncStatus ?? this.syncStatus,
      serverId: serverId ?? this.serverId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (visitId.present) {
      map['visit_id'] = Variable<String>(visitId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (areaValue.present) {
      map['area_value'] = Variable<double>(areaValue.value);
    }
    if (areaUnit.present) {
      map['area_unit'] = Variable<String>(areaUnit.value);
    }
    if (constructionType.present) {
      map['construction_type'] = Variable<String>(constructionType.value);
    }
    if (condition.present) {
      map['condition'] = Variable<String>(condition.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StructuresCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('visitId: $visitId, ')
          ..write('type: $type, ')
          ..write('areaValue: $areaValue, ')
          ..write('areaUnit: $areaUnit, ')
          ..write('constructionType: $constructionType, ')
          ..write('condition: $condition, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverId: $serverId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VegetationsTable extends Vegetations
    with TableInfo<$VegetationsTable, Vegetation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VegetationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visitIdMeta = const VerificationMeta(
    'visitId',
  );
  @override
  late final GeneratedColumn<String> visitId = GeneratedColumn<String>(
    'visit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speciesMeta = const VerificationMeta(
    'species',
  );
  @override
  late final GeneratedColumn<String> species = GeneratedColumn<String>(
    'species',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cropTypeMeta = const VerificationMeta(
    'cropType',
  );
  @override
  late final GeneratedColumn<String> cropType = GeneratedColumn<String>(
    'crop_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _areaHaMeta = const VerificationMeta('areaHa');
  @override
  late final GeneratedColumn<double> areaHa = GeneratedColumn<double>(
    'area_ha',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    visitId,
    species,
    count,
    cropType,
    areaHa,
    notes,
    syncStatus,
    serverId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vegetations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vegetation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('visit_id')) {
      context.handle(
        _visitIdMeta,
        visitId.isAcceptableOrUnknown(data['visit_id']!, _visitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_visitIdMeta);
    }
    if (data.containsKey('species')) {
      context.handle(
        _speciesMeta,
        species.isAcceptableOrUnknown(data['species']!, _speciesMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    if (data.containsKey('crop_type')) {
      context.handle(
        _cropTypeMeta,
        cropType.isAcceptableOrUnknown(data['crop_type']!, _cropTypeMeta),
      );
    }
    if (data.containsKey('area_ha')) {
      context.handle(
        _areaHaMeta,
        areaHa.isAcceptableOrUnknown(data['area_ha']!, _areaHaMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vegetation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vegetation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      visitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_id'],
      )!,
      species: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      cropType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}crop_type'],
      ),
      areaHa: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}area_ha'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VegetationsTable createAlias(String alias) {
    return $VegetationsTable(attachedDatabase, alias);
  }
}

class Vegetation extends DataClass implements Insertable<Vegetation> {
  final String id;
  final String clientId;
  final String visitId;
  final String species;
  final int count;
  final String? cropType;
  final double? areaHa;
  final String? notes;
  final String syncStatus;
  final String? serverId;
  final DateTime createdAt;
  const Vegetation({
    required this.id,
    required this.clientId,
    required this.visitId,
    required this.species,
    required this.count,
    this.cropType,
    this.areaHa,
    this.notes,
    required this.syncStatus,
    this.serverId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_id'] = Variable<String>(clientId);
    map['visit_id'] = Variable<String>(visitId);
    map['species'] = Variable<String>(species);
    map['count'] = Variable<int>(count);
    if (!nullToAbsent || cropType != null) {
      map['crop_type'] = Variable<String>(cropType);
    }
    if (!nullToAbsent || areaHa != null) {
      map['area_ha'] = Variable<double>(areaHa);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VegetationsCompanion toCompanion(bool nullToAbsent) {
    return VegetationsCompanion(
      id: Value(id),
      clientId: Value(clientId),
      visitId: Value(visitId),
      species: Value(species),
      count: Value(count),
      cropType: cropType == null && nullToAbsent
          ? const Value.absent()
          : Value(cropType),
      areaHa: areaHa == null && nullToAbsent
          ? const Value.absent()
          : Value(areaHa),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      syncStatus: Value(syncStatus),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      createdAt: Value(createdAt),
    );
  }

  factory Vegetation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vegetation(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      visitId: serializer.fromJson<String>(json['visitId']),
      species: serializer.fromJson<String>(json['species']),
      count: serializer.fromJson<int>(json['count']),
      cropType: serializer.fromJson<String?>(json['cropType']),
      areaHa: serializer.fromJson<double?>(json['areaHa']),
      notes: serializer.fromJson<String?>(json['notes']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String>(clientId),
      'visitId': serializer.toJson<String>(visitId),
      'species': serializer.toJson<String>(species),
      'count': serializer.toJson<int>(count),
      'cropType': serializer.toJson<String?>(cropType),
      'areaHa': serializer.toJson<double?>(areaHa),
      'notes': serializer.toJson<String?>(notes),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'serverId': serializer.toJson<String?>(serverId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Vegetation copyWith({
    String? id,
    String? clientId,
    String? visitId,
    String? species,
    int? count,
    Value<String?> cropType = const Value.absent(),
    Value<double?> areaHa = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? syncStatus,
    Value<String?> serverId = const Value.absent(),
    DateTime? createdAt,
  }) => Vegetation(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    visitId: visitId ?? this.visitId,
    species: species ?? this.species,
    count: count ?? this.count,
    cropType: cropType.present ? cropType.value : this.cropType,
    areaHa: areaHa.present ? areaHa.value : this.areaHa,
    notes: notes.present ? notes.value : this.notes,
    syncStatus: syncStatus ?? this.syncStatus,
    serverId: serverId.present ? serverId.value : this.serverId,
    createdAt: createdAt ?? this.createdAt,
  );
  Vegetation copyWithCompanion(VegetationsCompanion data) {
    return Vegetation(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      visitId: data.visitId.present ? data.visitId.value : this.visitId,
      species: data.species.present ? data.species.value : this.species,
      count: data.count.present ? data.count.value : this.count,
      cropType: data.cropType.present ? data.cropType.value : this.cropType,
      areaHa: data.areaHa.present ? data.areaHa.value : this.areaHa,
      notes: data.notes.present ? data.notes.value : this.notes,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vegetation(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('visitId: $visitId, ')
          ..write('species: $species, ')
          ..write('count: $count, ')
          ..write('cropType: $cropType, ')
          ..write('areaHa: $areaHa, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverId: $serverId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    visitId,
    species,
    count,
    cropType,
    areaHa,
    notes,
    syncStatus,
    serverId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vegetation &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.visitId == this.visitId &&
          other.species == this.species &&
          other.count == this.count &&
          other.cropType == this.cropType &&
          other.areaHa == this.areaHa &&
          other.notes == this.notes &&
          other.syncStatus == this.syncStatus &&
          other.serverId == this.serverId &&
          other.createdAt == this.createdAt);
}

class VegetationsCompanion extends UpdateCompanion<Vegetation> {
  final Value<String> id;
  final Value<String> clientId;
  final Value<String> visitId;
  final Value<String> species;
  final Value<int> count;
  final Value<String?> cropType;
  final Value<double?> areaHa;
  final Value<String?> notes;
  final Value<String> syncStatus;
  final Value<String?> serverId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const VegetationsCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.visitId = const Value.absent(),
    this.species = const Value.absent(),
    this.count = const Value.absent(),
    this.cropType = const Value.absent(),
    this.areaHa = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.serverId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VegetationsCompanion.insert({
    required String id,
    required String clientId,
    required String visitId,
    required String species,
    required int count,
    this.cropType = const Value.absent(),
    this.areaHa = const Value.absent(),
    this.notes = const Value.absent(),
    required String syncStatus,
    this.serverId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clientId = Value(clientId),
       visitId = Value(visitId),
       species = Value(species),
       count = Value(count),
       syncStatus = Value(syncStatus),
       createdAt = Value(createdAt);
  static Insertable<Vegetation> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<String>? visitId,
    Expression<String>? species,
    Expression<int>? count,
    Expression<String>? cropType,
    Expression<double>? areaHa,
    Expression<String>? notes,
    Expression<String>? syncStatus,
    Expression<String>? serverId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (visitId != null) 'visit_id': visitId,
      if (species != null) 'species': species,
      if (count != null) 'count': count,
      if (cropType != null) 'crop_type': cropType,
      if (areaHa != null) 'area_ha': areaHa,
      if (notes != null) 'notes': notes,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (serverId != null) 'server_id': serverId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VegetationsCompanion copyWith({
    Value<String>? id,
    Value<String>? clientId,
    Value<String>? visitId,
    Value<String>? species,
    Value<int>? count,
    Value<String?>? cropType,
    Value<double?>? areaHa,
    Value<String?>? notes,
    Value<String>? syncStatus,
    Value<String?>? serverId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return VegetationsCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      visitId: visitId ?? this.visitId,
      species: species ?? this.species,
      count: count ?? this.count,
      cropType: cropType ?? this.cropType,
      areaHa: areaHa ?? this.areaHa,
      notes: notes ?? this.notes,
      syncStatus: syncStatus ?? this.syncStatus,
      serverId: serverId ?? this.serverId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (visitId.present) {
      map['visit_id'] = Variable<String>(visitId.value);
    }
    if (species.present) {
      map['species'] = Variable<String>(species.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (cropType.present) {
      map['crop_type'] = Variable<String>(cropType.value);
    }
    if (areaHa.present) {
      map['area_ha'] = Variable<double>(areaHa.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VegetationsCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('visitId: $visitId, ')
          ..write('species: $species, ')
          ..write('count: $count, ')
          ..write('cropType: $cropType, ')
          ..write('areaHa: $areaHa, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverId: $serverId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalDocumentsTable extends LocalDocuments
    with TableInfo<$LocalDocumentsTable, LocalDocument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalDocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visitIdMeta = const VerificationMeta(
    'visitId',
  );
  @override
  late final GeneratedColumn<String> visitId = GeneratedColumn<String>(
    'visit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localFilePathMeta = const VerificationMeta(
    'localFilePath',
  );
  @override
  late final GeneratedColumn<String> localFilePath = GeneratedColumn<String>(
    'local_file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    visitId,
    type,
    localFilePath,
    mimeType,
    syncStatus,
    serverId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalDocument> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('visit_id')) {
      context.handle(
        _visitIdMeta,
        visitId.isAcceptableOrUnknown(data['visit_id']!, _visitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_visitIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('local_file_path')) {
      context.handle(
        _localFilePathMeta,
        localFilePath.isAcceptableOrUnknown(
          data['local_file_path']!,
          _localFilePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localFilePathMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalDocument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalDocument(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      visitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      localFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_file_path'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalDocumentsTable createAlias(String alias) {
    return $LocalDocumentsTable(attachedDatabase, alias);
  }
}

class LocalDocument extends DataClass implements Insertable<LocalDocument> {
  final String id;
  final String clientId;
  final String visitId;
  final String type;
  final String localFilePath;
  final String? mimeType;
  final String syncStatus;
  final String? serverId;
  final DateTime createdAt;
  const LocalDocument({
    required this.id,
    required this.clientId,
    required this.visitId,
    required this.type,
    required this.localFilePath,
    this.mimeType,
    required this.syncStatus,
    this.serverId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_id'] = Variable<String>(clientId);
    map['visit_id'] = Variable<String>(visitId);
    map['type'] = Variable<String>(type);
    map['local_file_path'] = Variable<String>(localFilePath);
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalDocumentsCompanion toCompanion(bool nullToAbsent) {
    return LocalDocumentsCompanion(
      id: Value(id),
      clientId: Value(clientId),
      visitId: Value(visitId),
      type: Value(type),
      localFilePath: Value(localFilePath),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      syncStatus: Value(syncStatus),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      createdAt: Value(createdAt),
    );
  }

  factory LocalDocument.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalDocument(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      visitId: serializer.fromJson<String>(json['visitId']),
      type: serializer.fromJson<String>(json['type']),
      localFilePath: serializer.fromJson<String>(json['localFilePath']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String>(clientId),
      'visitId': serializer.toJson<String>(visitId),
      'type': serializer.toJson<String>(type),
      'localFilePath': serializer.toJson<String>(localFilePath),
      'mimeType': serializer.toJson<String?>(mimeType),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'serverId': serializer.toJson<String?>(serverId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalDocument copyWith({
    String? id,
    String? clientId,
    String? visitId,
    String? type,
    String? localFilePath,
    Value<String?> mimeType = const Value.absent(),
    String? syncStatus,
    Value<String?> serverId = const Value.absent(),
    DateTime? createdAt,
  }) => LocalDocument(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    visitId: visitId ?? this.visitId,
    type: type ?? this.type,
    localFilePath: localFilePath ?? this.localFilePath,
    mimeType: mimeType.present ? mimeType.value : this.mimeType,
    syncStatus: syncStatus ?? this.syncStatus,
    serverId: serverId.present ? serverId.value : this.serverId,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalDocument copyWithCompanion(LocalDocumentsCompanion data) {
    return LocalDocument(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      visitId: data.visitId.present ? data.visitId.value : this.visitId,
      type: data.type.present ? data.type.value : this.type,
      localFilePath: data.localFilePath.present
          ? data.localFilePath.value
          : this.localFilePath,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalDocument(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('visitId: $visitId, ')
          ..write('type: $type, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('mimeType: $mimeType, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverId: $serverId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    visitId,
    type,
    localFilePath,
    mimeType,
    syncStatus,
    serverId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalDocument &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.visitId == this.visitId &&
          other.type == this.type &&
          other.localFilePath == this.localFilePath &&
          other.mimeType == this.mimeType &&
          other.syncStatus == this.syncStatus &&
          other.serverId == this.serverId &&
          other.createdAt == this.createdAt);
}

class LocalDocumentsCompanion extends UpdateCompanion<LocalDocument> {
  final Value<String> id;
  final Value<String> clientId;
  final Value<String> visitId;
  final Value<String> type;
  final Value<String> localFilePath;
  final Value<String?> mimeType;
  final Value<String> syncStatus;
  final Value<String?> serverId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalDocumentsCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.visitId = const Value.absent(),
    this.type = const Value.absent(),
    this.localFilePath = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.serverId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalDocumentsCompanion.insert({
    required String id,
    required String clientId,
    required String visitId,
    required String type,
    required String localFilePath,
    this.mimeType = const Value.absent(),
    required String syncStatus,
    this.serverId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clientId = Value(clientId),
       visitId = Value(visitId),
       type = Value(type),
       localFilePath = Value(localFilePath),
       syncStatus = Value(syncStatus),
       createdAt = Value(createdAt);
  static Insertable<LocalDocument> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<String>? visitId,
    Expression<String>? type,
    Expression<String>? localFilePath,
    Expression<String>? mimeType,
    Expression<String>? syncStatus,
    Expression<String>? serverId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (visitId != null) 'visit_id': visitId,
      if (type != null) 'type': type,
      if (localFilePath != null) 'local_file_path': localFilePath,
      if (mimeType != null) 'mime_type': mimeType,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (serverId != null) 'server_id': serverId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalDocumentsCompanion copyWith({
    Value<String>? id,
    Value<String>? clientId,
    Value<String>? visitId,
    Value<String>? type,
    Value<String>? localFilePath,
    Value<String?>? mimeType,
    Value<String>? syncStatus,
    Value<String?>? serverId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalDocumentsCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      visitId: visitId ?? this.visitId,
      type: type ?? this.type,
      localFilePath: localFilePath ?? this.localFilePath,
      mimeType: mimeType ?? this.mimeType,
      syncStatus: syncStatus ?? this.syncStatus,
      serverId: serverId ?? this.serverId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (visitId.present) {
      map['visit_id'] = Variable<String>(visitId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (localFilePath.present) {
      map['local_file_path'] = Variable<String>(localFilePath.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalDocumentsCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('visitId: $visitId, ')
          ..write('type: $type, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('mimeType: $mimeType, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverId: $serverId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EvidencesTable extends Evidences
    with TableInfo<$EvidencesTable, Evidence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EvidencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visitIdMeta = const VerificationMeta(
    'visitId',
  );
  @override
  late final GeneratedColumn<String> visitId = GeneratedColumn<String>(
    'visit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parcelIdMeta = const VerificationMeta(
    'parcelId',
  );
  @override
  late final GeneratedColumn<String> parcelId = GeneratedColumn<String>(
    'parcel_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _officerIdMeta = const VerificationMeta(
    'officerId',
  );
  @override
  late final GeneratedColumn<String> officerId = GeneratedColumn<String>(
    'officer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localFilePathMeta = const VerificationMeta(
    'localFilePath',
  );
  @override
  late final GeneratedColumn<String> localFilePath = GeneratedColumn<String>(
    'local_file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<String> latitude = GeneratedColumn<String>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<String> longitude = GeneratedColumn<String>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gpsAccuracyMeta = const VerificationMeta(
    'gpsAccuracy',
  );
  @override
  late final GeneratedColumn<String> gpsAccuracy = GeneratedColumn<String>(
    'gps_accuracy',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationAvailableMeta = const VerificationMeta(
    'locationAvailable',
  );
  @override
  late final GeneratedColumn<bool> locationAvailable = GeneratedColumn<bool>(
    'location_available',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("location_available" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    visitId,
    parcelId,
    officerId,
    type,
    localFilePath,
    latitude,
    longitude,
    gpsAccuracy,
    locationAvailable,
    capturedAt,
    description,
    syncStatus,
    serverId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'evidences';
  @override
  VerificationContext validateIntegrity(
    Insertable<Evidence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('visit_id')) {
      context.handle(
        _visitIdMeta,
        visitId.isAcceptableOrUnknown(data['visit_id']!, _visitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_visitIdMeta);
    }
    if (data.containsKey('parcel_id')) {
      context.handle(
        _parcelIdMeta,
        parcelId.isAcceptableOrUnknown(data['parcel_id']!, _parcelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_parcelIdMeta);
    }
    if (data.containsKey('officer_id')) {
      context.handle(
        _officerIdMeta,
        officerId.isAcceptableOrUnknown(data['officer_id']!, _officerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_officerIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('local_file_path')) {
      context.handle(
        _localFilePathMeta,
        localFilePath.isAcceptableOrUnknown(
          data['local_file_path']!,
          _localFilePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localFilePathMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('gps_accuracy')) {
      context.handle(
        _gpsAccuracyMeta,
        gpsAccuracy.isAcceptableOrUnknown(
          data['gps_accuracy']!,
          _gpsAccuracyMeta,
        ),
      );
    }
    if (data.containsKey('location_available')) {
      context.handle(
        _locationAvailableMeta,
        locationAvailable.isAcceptableOrUnknown(
          data['location_available']!,
          _locationAvailableMeta,
        ),
      );
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Evidence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Evidence(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      visitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_id'],
      )!,
      parcelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parcel_id'],
      )!,
      officerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}officer_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      localFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_file_path'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}longitude'],
      ),
      gpsAccuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gps_accuracy'],
      ),
      locationAvailable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}location_available'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
    );
  }

  @override
  $EvidencesTable createAlias(String alias) {
    return $EvidencesTable(attachedDatabase, alias);
  }
}

class Evidence extends DataClass implements Insertable<Evidence> {
  final String id;
  final String clientId;
  final String visitId;
  final String parcelId;
  final String officerId;
  final String type;
  final String localFilePath;
  final String? latitude;
  final String? longitude;
  final String? gpsAccuracy;
  final bool locationAvailable;
  final DateTime capturedAt;
  final String? description;
  final String syncStatus;
  final String? serverId;
  const Evidence({
    required this.id,
    required this.clientId,
    required this.visitId,
    required this.parcelId,
    required this.officerId,
    required this.type,
    required this.localFilePath,
    this.latitude,
    this.longitude,
    this.gpsAccuracy,
    required this.locationAvailable,
    required this.capturedAt,
    this.description,
    required this.syncStatus,
    this.serverId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_id'] = Variable<String>(clientId);
    map['visit_id'] = Variable<String>(visitId);
    map['parcel_id'] = Variable<String>(parcelId);
    map['officer_id'] = Variable<String>(officerId);
    map['type'] = Variable<String>(type);
    map['local_file_path'] = Variable<String>(localFilePath);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<String>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<String>(longitude);
    }
    if (!nullToAbsent || gpsAccuracy != null) {
      map['gps_accuracy'] = Variable<String>(gpsAccuracy);
    }
    map['location_available'] = Variable<bool>(locationAvailable);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    return map;
  }

  EvidencesCompanion toCompanion(bool nullToAbsent) {
    return EvidencesCompanion(
      id: Value(id),
      clientId: Value(clientId),
      visitId: Value(visitId),
      parcelId: Value(parcelId),
      officerId: Value(officerId),
      type: Value(type),
      localFilePath: Value(localFilePath),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      gpsAccuracy: gpsAccuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsAccuracy),
      locationAvailable: Value(locationAvailable),
      capturedAt: Value(capturedAt),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      syncStatus: Value(syncStatus),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
    );
  }

  factory Evidence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Evidence(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      visitId: serializer.fromJson<String>(json['visitId']),
      parcelId: serializer.fromJson<String>(json['parcelId']),
      officerId: serializer.fromJson<String>(json['officerId']),
      type: serializer.fromJson<String>(json['type']),
      localFilePath: serializer.fromJson<String>(json['localFilePath']),
      latitude: serializer.fromJson<String?>(json['latitude']),
      longitude: serializer.fromJson<String?>(json['longitude']),
      gpsAccuracy: serializer.fromJson<String?>(json['gpsAccuracy']),
      locationAvailable: serializer.fromJson<bool>(json['locationAvailable']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      description: serializer.fromJson<String?>(json['description']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      serverId: serializer.fromJson<String?>(json['serverId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String>(clientId),
      'visitId': serializer.toJson<String>(visitId),
      'parcelId': serializer.toJson<String>(parcelId),
      'officerId': serializer.toJson<String>(officerId),
      'type': serializer.toJson<String>(type),
      'localFilePath': serializer.toJson<String>(localFilePath),
      'latitude': serializer.toJson<String?>(latitude),
      'longitude': serializer.toJson<String?>(longitude),
      'gpsAccuracy': serializer.toJson<String?>(gpsAccuracy),
      'locationAvailable': serializer.toJson<bool>(locationAvailable),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'description': serializer.toJson<String?>(description),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'serverId': serializer.toJson<String?>(serverId),
    };
  }

  Evidence copyWith({
    String? id,
    String? clientId,
    String? visitId,
    String? parcelId,
    String? officerId,
    String? type,
    String? localFilePath,
    Value<String?> latitude = const Value.absent(),
    Value<String?> longitude = const Value.absent(),
    Value<String?> gpsAccuracy = const Value.absent(),
    bool? locationAvailable,
    DateTime? capturedAt,
    Value<String?> description = const Value.absent(),
    String? syncStatus,
    Value<String?> serverId = const Value.absent(),
  }) => Evidence(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    visitId: visitId ?? this.visitId,
    parcelId: parcelId ?? this.parcelId,
    officerId: officerId ?? this.officerId,
    type: type ?? this.type,
    localFilePath: localFilePath ?? this.localFilePath,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    gpsAccuracy: gpsAccuracy.present ? gpsAccuracy.value : this.gpsAccuracy,
    locationAvailable: locationAvailable ?? this.locationAvailable,
    capturedAt: capturedAt ?? this.capturedAt,
    description: description.present ? description.value : this.description,
    syncStatus: syncStatus ?? this.syncStatus,
    serverId: serverId.present ? serverId.value : this.serverId,
  );
  Evidence copyWithCompanion(EvidencesCompanion data) {
    return Evidence(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      visitId: data.visitId.present ? data.visitId.value : this.visitId,
      parcelId: data.parcelId.present ? data.parcelId.value : this.parcelId,
      officerId: data.officerId.present ? data.officerId.value : this.officerId,
      type: data.type.present ? data.type.value : this.type,
      localFilePath: data.localFilePath.present
          ? data.localFilePath.value
          : this.localFilePath,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      gpsAccuracy: data.gpsAccuracy.present
          ? data.gpsAccuracy.value
          : this.gpsAccuracy,
      locationAvailable: data.locationAvailable.present
          ? data.locationAvailable.value
          : this.locationAvailable,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      description: data.description.present
          ? data.description.value
          : this.description,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Evidence(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('visitId: $visitId, ')
          ..write('parcelId: $parcelId, ')
          ..write('officerId: $officerId, ')
          ..write('type: $type, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('gpsAccuracy: $gpsAccuracy, ')
          ..write('locationAvailable: $locationAvailable, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('description: $description, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverId: $serverId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    visitId,
    parcelId,
    officerId,
    type,
    localFilePath,
    latitude,
    longitude,
    gpsAccuracy,
    locationAvailable,
    capturedAt,
    description,
    syncStatus,
    serverId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Evidence &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.visitId == this.visitId &&
          other.parcelId == this.parcelId &&
          other.officerId == this.officerId &&
          other.type == this.type &&
          other.localFilePath == this.localFilePath &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.gpsAccuracy == this.gpsAccuracy &&
          other.locationAvailable == this.locationAvailable &&
          other.capturedAt == this.capturedAt &&
          other.description == this.description &&
          other.syncStatus == this.syncStatus &&
          other.serverId == this.serverId);
}

class EvidencesCompanion extends UpdateCompanion<Evidence> {
  final Value<String> id;
  final Value<String> clientId;
  final Value<String> visitId;
  final Value<String> parcelId;
  final Value<String> officerId;
  final Value<String> type;
  final Value<String> localFilePath;
  final Value<String?> latitude;
  final Value<String?> longitude;
  final Value<String?> gpsAccuracy;
  final Value<bool> locationAvailable;
  final Value<DateTime> capturedAt;
  final Value<String?> description;
  final Value<String> syncStatus;
  final Value<String?> serverId;
  final Value<int> rowid;
  const EvidencesCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.visitId = const Value.absent(),
    this.parcelId = const Value.absent(),
    this.officerId = const Value.absent(),
    this.type = const Value.absent(),
    this.localFilePath = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.gpsAccuracy = const Value.absent(),
    this.locationAvailable = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.description = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.serverId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EvidencesCompanion.insert({
    required String id,
    required String clientId,
    required String visitId,
    required String parcelId,
    required String officerId,
    required String type,
    required String localFilePath,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.gpsAccuracy = const Value.absent(),
    this.locationAvailable = const Value.absent(),
    required DateTime capturedAt,
    this.description = const Value.absent(),
    required String syncStatus,
    this.serverId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clientId = Value(clientId),
       visitId = Value(visitId),
       parcelId = Value(parcelId),
       officerId = Value(officerId),
       type = Value(type),
       localFilePath = Value(localFilePath),
       capturedAt = Value(capturedAt),
       syncStatus = Value(syncStatus);
  static Insertable<Evidence> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<String>? visitId,
    Expression<String>? parcelId,
    Expression<String>? officerId,
    Expression<String>? type,
    Expression<String>? localFilePath,
    Expression<String>? latitude,
    Expression<String>? longitude,
    Expression<String>? gpsAccuracy,
    Expression<bool>? locationAvailable,
    Expression<DateTime>? capturedAt,
    Expression<String>? description,
    Expression<String>? syncStatus,
    Expression<String>? serverId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (visitId != null) 'visit_id': visitId,
      if (parcelId != null) 'parcel_id': parcelId,
      if (officerId != null) 'officer_id': officerId,
      if (type != null) 'type': type,
      if (localFilePath != null) 'local_file_path': localFilePath,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (gpsAccuracy != null) 'gps_accuracy': gpsAccuracy,
      if (locationAvailable != null) 'location_available': locationAvailable,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (description != null) 'description': description,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (serverId != null) 'server_id': serverId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EvidencesCompanion copyWith({
    Value<String>? id,
    Value<String>? clientId,
    Value<String>? visitId,
    Value<String>? parcelId,
    Value<String>? officerId,
    Value<String>? type,
    Value<String>? localFilePath,
    Value<String?>? latitude,
    Value<String?>? longitude,
    Value<String?>? gpsAccuracy,
    Value<bool>? locationAvailable,
    Value<DateTime>? capturedAt,
    Value<String?>? description,
    Value<String>? syncStatus,
    Value<String?>? serverId,
    Value<int>? rowid,
  }) {
    return EvidencesCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      visitId: visitId ?? this.visitId,
      parcelId: parcelId ?? this.parcelId,
      officerId: officerId ?? this.officerId,
      type: type ?? this.type,
      localFilePath: localFilePath ?? this.localFilePath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      gpsAccuracy: gpsAccuracy ?? this.gpsAccuracy,
      locationAvailable: locationAvailable ?? this.locationAvailable,
      capturedAt: capturedAt ?? this.capturedAt,
      description: description ?? this.description,
      syncStatus: syncStatus ?? this.syncStatus,
      serverId: serverId ?? this.serverId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (visitId.present) {
      map['visit_id'] = Variable<String>(visitId.value);
    }
    if (parcelId.present) {
      map['parcel_id'] = Variable<String>(parcelId.value);
    }
    if (officerId.present) {
      map['officer_id'] = Variable<String>(officerId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (localFilePath.present) {
      map['local_file_path'] = Variable<String>(localFilePath.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<String>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<String>(longitude.value);
    }
    if (gpsAccuracy.present) {
      map['gps_accuracy'] = Variable<String>(gpsAccuracy.value);
    }
    if (locationAvailable.present) {
      map['location_available'] = Variable<bool>(locationAvailable.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EvidencesCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('visitId: $visitId, ')
          ..write('parcelId: $parcelId, ')
          ..write('officerId: $officerId, ')
          ..write('type: $type, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('gpsAccuracy: $gpsAccuracy, ')
          ..write('locationAvailable: $locationAvailable, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('description: $description, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverId: $serverId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueuesTable extends SyncQueues
    with TableInfo<$SyncQueuesTable, SyncQueue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    operation,
    payload,
    retryCount,
    status,
    lastError,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queues';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueue(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SyncQueuesTable createAlias(String alias) {
    return $SyncQueuesTable(attachedDatabase, alias);
  }
}

class SyncQueue extends DataClass implements Insertable<SyncQueue> {
  final String id;
  final String entityType;
  final String entityId;
  final String operation;
  final String payload;
  final int retryCount;
  final String status;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SyncQueue({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.retryCount,
    required this.status,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['retry_count'] = Variable<int>(retryCount);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncQueuesCompanion toCompanion(bool nullToAbsent) {
    return SyncQueuesCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payload: Value(payload),
      retryCount: Value(retryCount),
      status: Value(status),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncQueue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueue(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      status: serializer.fromJson<String>(json['status']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'retryCount': serializer.toJson<int>(retryCount),
      'status': serializer.toJson<String>(status),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncQueue copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? operation,
    String? payload,
    int? retryCount,
    String? status,
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SyncQueue(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    retryCount: retryCount ?? this.retryCount,
    status: status ?? this.status,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SyncQueue copyWithCompanion(SyncQueuesCompanion data) {
    return SyncQueue(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      status: data.status.present ? data.status.value : this.status,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueue(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    operation,
    payload,
    retryCount,
    status,
    lastError,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueue &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.retryCount == this.retryCount &&
          other.status == this.status &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SyncQueuesCompanion extends UpdateCompanion<SyncQueue> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<int> retryCount;
  final Value<String> status;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncQueuesCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.status = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueuesCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
    this.retryCount = const Value.absent(),
    required String status,
    this.lastError = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operation = Value(operation),
       payload = Value(payload),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SyncQueue> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<int>? retryCount,
    Expression<String>? status,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (retryCount != null) 'retry_count': retryCount,
      if (status != null) 'status': status,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueuesCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String>? payload,
    Value<int>? retryCount,
    Value<String>? status,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SyncQueuesCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueuesCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $AssignedTasksTable assignedTasks = $AssignedTasksTable(this);
  late final $FieldVisitsTable fieldVisits = $FieldVisitsTable(this);
  late final $StructuresTable structures = $StructuresTable(this);
  late final $VegetationsTable vegetations = $VegetationsTable(this);
  late final $LocalDocumentsTable localDocuments = $LocalDocumentsTable(this);
  late final $EvidencesTable evidences = $EvidencesTable(this);
  late final $SyncQueuesTable syncQueues = $SyncQueuesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sessions,
    assignedTasks,
    fieldVisits,
    structures,
    vegetations,
    localDocuments,
    evidences,
    syncQueues,
  ];
}

typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      required String id,
      required String token,
      required String userJson,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<String> id,
      Value<String> token,
      Value<String> userJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userJson => $composableBuilder(
    column: $table.userJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userJson => $composableBuilder(
    column: $table.userJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<String> get userJson =>
      $composableBuilder(column: $table.userJson, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
          Session,
          PrefetchHooks Function()
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> token = const Value.absent(),
                Value<String> userJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                token: token,
                userJson: userJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String token,
                required String userJson,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                token: token,
                userJson: userJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
      Session,
      PrefetchHooks Function()
    >;
typedef $$AssignedTasksTableCreateCompanionBuilder =
    AssignedTasksCompanion Function({
      required String id,
      required String clientId,
      required String caseId,
      required String parcelId,
      required String projectId,
      required String caseNo,
      required String surveyNo,
      required String village,
      required String tehsil,
      required String district,
      required String state,
      required String areaHa,
      required String stage,
      required String status,
      Value<String?> ownerName,
      Value<String?> landType,
      Value<String?> geometryWkt,
      Value<String?> centroidLat,
      Value<String?> centroidLng,
      required String officerId,
      required String rawJson,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$AssignedTasksTableUpdateCompanionBuilder =
    AssignedTasksCompanion Function({
      Value<String> id,
      Value<String> clientId,
      Value<String> caseId,
      Value<String> parcelId,
      Value<String> projectId,
      Value<String> caseNo,
      Value<String> surveyNo,
      Value<String> village,
      Value<String> tehsil,
      Value<String> district,
      Value<String> state,
      Value<String> areaHa,
      Value<String> stage,
      Value<String> status,
      Value<String?> ownerName,
      Value<String?> landType,
      Value<String?> geometryWkt,
      Value<String?> centroidLat,
      Value<String?> centroidLng,
      Value<String> officerId,
      Value<String> rawJson,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$AssignedTasksTableFilterComposer
    extends Composer<_$AppDatabase, $AssignedTasksTable> {
  $$AssignedTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caseId => $composableBuilder(
    column: $table.caseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parcelId => $composableBuilder(
    column: $table.parcelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caseNo => $composableBuilder(
    column: $table.caseNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surveyNo => $composableBuilder(
    column: $table.surveyNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get village => $composableBuilder(
    column: $table.village,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tehsil => $composableBuilder(
    column: $table.tehsil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get areaHa => $composableBuilder(
    column: $table.areaHa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerName => $composableBuilder(
    column: $table.ownerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get landType => $composableBuilder(
    column: $table.landType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get geometryWkt => $composableBuilder(
    column: $table.geometryWkt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get centroidLat => $composableBuilder(
    column: $table.centroidLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get centroidLng => $composableBuilder(
    column: $table.centroidLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get officerId => $composableBuilder(
    column: $table.officerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AssignedTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $AssignedTasksTable> {
  $$AssignedTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caseId => $composableBuilder(
    column: $table.caseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parcelId => $composableBuilder(
    column: $table.parcelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caseNo => $composableBuilder(
    column: $table.caseNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surveyNo => $composableBuilder(
    column: $table.surveyNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get village => $composableBuilder(
    column: $table.village,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tehsil => $composableBuilder(
    column: $table.tehsil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get areaHa => $composableBuilder(
    column: $table.areaHa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerName => $composableBuilder(
    column: $table.ownerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get landType => $composableBuilder(
    column: $table.landType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get geometryWkt => $composableBuilder(
    column: $table.geometryWkt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get centroidLat => $composableBuilder(
    column: $table.centroidLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get centroidLng => $composableBuilder(
    column: $table.centroidLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get officerId => $composableBuilder(
    column: $table.officerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssignedTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssignedTasksTable> {
  $$AssignedTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get caseId =>
      $composableBuilder(column: $table.caseId, builder: (column) => column);

  GeneratedColumn<String> get parcelId =>
      $composableBuilder(column: $table.parcelId, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get caseNo =>
      $composableBuilder(column: $table.caseNo, builder: (column) => column);

  GeneratedColumn<String> get surveyNo =>
      $composableBuilder(column: $table.surveyNo, builder: (column) => column);

  GeneratedColumn<String> get village =>
      $composableBuilder(column: $table.village, builder: (column) => column);

  GeneratedColumn<String> get tehsil =>
      $composableBuilder(column: $table.tehsil, builder: (column) => column);

  GeneratedColumn<String> get district =>
      $composableBuilder(column: $table.district, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get areaHa =>
      $composableBuilder(column: $table.areaHa, builder: (column) => column);

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get ownerName =>
      $composableBuilder(column: $table.ownerName, builder: (column) => column);

  GeneratedColumn<String> get landType =>
      $composableBuilder(column: $table.landType, builder: (column) => column);

  GeneratedColumn<String> get geometryWkt => $composableBuilder(
    column: $table.geometryWkt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get centroidLat => $composableBuilder(
    column: $table.centroidLat,
    builder: (column) => column,
  );

  GeneratedColumn<String> get centroidLng => $composableBuilder(
    column: $table.centroidLng,
    builder: (column) => column,
  );

  GeneratedColumn<String> get officerId =>
      $composableBuilder(column: $table.officerId, builder: (column) => column);

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$AssignedTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssignedTasksTable,
          AssignedTask,
          $$AssignedTasksTableFilterComposer,
          $$AssignedTasksTableOrderingComposer,
          $$AssignedTasksTableAnnotationComposer,
          $$AssignedTasksTableCreateCompanionBuilder,
          $$AssignedTasksTableUpdateCompanionBuilder,
          (
            AssignedTask,
            BaseReferences<_$AppDatabase, $AssignedTasksTable, AssignedTask>,
          ),
          AssignedTask,
          PrefetchHooks Function()
        > {
  $$AssignedTasksTableTableManager(_$AppDatabase db, $AssignedTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssignedTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssignedTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssignedTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String> caseId = const Value.absent(),
                Value<String> parcelId = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> caseNo = const Value.absent(),
                Value<String> surveyNo = const Value.absent(),
                Value<String> village = const Value.absent(),
                Value<String> tehsil = const Value.absent(),
                Value<String> district = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> areaHa = const Value.absent(),
                Value<String> stage = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> ownerName = const Value.absent(),
                Value<String?> landType = const Value.absent(),
                Value<String?> geometryWkt = const Value.absent(),
                Value<String?> centroidLat = const Value.absent(),
                Value<String?> centroidLng = const Value.absent(),
                Value<String> officerId = const Value.absent(),
                Value<String> rawJson = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssignedTasksCompanion(
                id: id,
                clientId: clientId,
                caseId: caseId,
                parcelId: parcelId,
                projectId: projectId,
                caseNo: caseNo,
                surveyNo: surveyNo,
                village: village,
                tehsil: tehsil,
                district: district,
                state: state,
                areaHa: areaHa,
                stage: stage,
                status: status,
                ownerName: ownerName,
                landType: landType,
                geometryWkt: geometryWkt,
                centroidLat: centroidLat,
                centroidLng: centroidLng,
                officerId: officerId,
                rawJson: rawJson,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String clientId,
                required String caseId,
                required String parcelId,
                required String projectId,
                required String caseNo,
                required String surveyNo,
                required String village,
                required String tehsil,
                required String district,
                required String state,
                required String areaHa,
                required String stage,
                required String status,
                Value<String?> ownerName = const Value.absent(),
                Value<String?> landType = const Value.absent(),
                Value<String?> geometryWkt = const Value.absent(),
                Value<String?> centroidLat = const Value.absent(),
                Value<String?> centroidLng = const Value.absent(),
                required String officerId,
                required String rawJson,
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => AssignedTasksCompanion.insert(
                id: id,
                clientId: clientId,
                caseId: caseId,
                parcelId: parcelId,
                projectId: projectId,
                caseNo: caseNo,
                surveyNo: surveyNo,
                village: village,
                tehsil: tehsil,
                district: district,
                state: state,
                areaHa: areaHa,
                stage: stage,
                status: status,
                ownerName: ownerName,
                landType: landType,
                geometryWkt: geometryWkt,
                centroidLat: centroidLat,
                centroidLng: centroidLng,
                officerId: officerId,
                rawJson: rawJson,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssignedTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssignedTasksTable,
      AssignedTask,
      $$AssignedTasksTableFilterComposer,
      $$AssignedTasksTableOrderingComposer,
      $$AssignedTasksTableAnnotationComposer,
      $$AssignedTasksTableCreateCompanionBuilder,
      $$AssignedTasksTableUpdateCompanionBuilder,
      (
        AssignedTask,
        BaseReferences<_$AppDatabase, $AssignedTasksTable, AssignedTask>,
      ),
      AssignedTask,
      PrefetchHooks Function()
    >;
typedef $$FieldVisitsTableCreateCompanionBuilder =
    FieldVisitsCompanion Function({
      required String id,
      required String clientId,
      required String taskId,
      required String parcelId,
      required String caseId,
      required String officerId,
      required String status,
      required String syncStatus,
      Value<String?> landUse,
      Value<String?> irrigation,
      Value<bool?> boundaryConfirmed,
      Value<String?> notes,
      Value<String?> verificationServerId,
      Value<String?> lastError,
      Value<int> retryCount,
      Value<String?> gpsLat,
      Value<String?> gpsLng,
      Value<String?> gpsAccuracy,
      Value<String?> gpsTimestamp,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> submittedAt,
      Value<int> rowid,
    });
typedef $$FieldVisitsTableUpdateCompanionBuilder =
    FieldVisitsCompanion Function({
      Value<String> id,
      Value<String> clientId,
      Value<String> taskId,
      Value<String> parcelId,
      Value<String> caseId,
      Value<String> officerId,
      Value<String> status,
      Value<String> syncStatus,
      Value<String?> landUse,
      Value<String?> irrigation,
      Value<bool?> boundaryConfirmed,
      Value<String?> notes,
      Value<String?> verificationServerId,
      Value<String?> lastError,
      Value<int> retryCount,
      Value<String?> gpsLat,
      Value<String?> gpsLng,
      Value<String?> gpsAccuracy,
      Value<String?> gpsTimestamp,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> submittedAt,
      Value<int> rowid,
    });

class $$FieldVisitsTableFilterComposer
    extends Composer<_$AppDatabase, $FieldVisitsTable> {
  $$FieldVisitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parcelId => $composableBuilder(
    column: $table.parcelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caseId => $composableBuilder(
    column: $table.caseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get officerId => $composableBuilder(
    column: $table.officerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get landUse => $composableBuilder(
    column: $table.landUse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get irrigation => $composableBuilder(
    column: $table.irrigation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get boundaryConfirmed => $composableBuilder(
    column: $table.boundaryConfirmed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verificationServerId => $composableBuilder(
    column: $table.verificationServerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gpsLat => $composableBuilder(
    column: $table.gpsLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gpsLng => $composableBuilder(
    column: $table.gpsLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gpsAccuracy => $composableBuilder(
    column: $table.gpsAccuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gpsTimestamp => $composableBuilder(
    column: $table.gpsTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FieldVisitsTableOrderingComposer
    extends Composer<_$AppDatabase, $FieldVisitsTable> {
  $$FieldVisitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parcelId => $composableBuilder(
    column: $table.parcelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caseId => $composableBuilder(
    column: $table.caseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get officerId => $composableBuilder(
    column: $table.officerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get landUse => $composableBuilder(
    column: $table.landUse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get irrigation => $composableBuilder(
    column: $table.irrigation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get boundaryConfirmed => $composableBuilder(
    column: $table.boundaryConfirmed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verificationServerId => $composableBuilder(
    column: $table.verificationServerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gpsLat => $composableBuilder(
    column: $table.gpsLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gpsLng => $composableBuilder(
    column: $table.gpsLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gpsAccuracy => $composableBuilder(
    column: $table.gpsAccuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gpsTimestamp => $composableBuilder(
    column: $table.gpsTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FieldVisitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FieldVisitsTable> {
  $$FieldVisitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get parcelId =>
      $composableBuilder(column: $table.parcelId, builder: (column) => column);

  GeneratedColumn<String> get caseId =>
      $composableBuilder(column: $table.caseId, builder: (column) => column);

  GeneratedColumn<String> get officerId =>
      $composableBuilder(column: $table.officerId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get landUse =>
      $composableBuilder(column: $table.landUse, builder: (column) => column);

  GeneratedColumn<String> get irrigation => $composableBuilder(
    column: $table.irrigation,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get boundaryConfirmed => $composableBuilder(
    column: $table.boundaryConfirmed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get verificationServerId => $composableBuilder(
    column: $table.verificationServerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gpsLat =>
      $composableBuilder(column: $table.gpsLat, builder: (column) => column);

  GeneratedColumn<String> get gpsLng =>
      $composableBuilder(column: $table.gpsLng, builder: (column) => column);

  GeneratedColumn<String> get gpsAccuracy => $composableBuilder(
    column: $table.gpsAccuracy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gpsTimestamp => $composableBuilder(
    column: $table.gpsTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => column,
  );
}

class $$FieldVisitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FieldVisitsTable,
          FieldVisit,
          $$FieldVisitsTableFilterComposer,
          $$FieldVisitsTableOrderingComposer,
          $$FieldVisitsTableAnnotationComposer,
          $$FieldVisitsTableCreateCompanionBuilder,
          $$FieldVisitsTableUpdateCompanionBuilder,
          (
            FieldVisit,
            BaseReferences<_$AppDatabase, $FieldVisitsTable, FieldVisit>,
          ),
          FieldVisit,
          PrefetchHooks Function()
        > {
  $$FieldVisitsTableTableManager(_$AppDatabase db, $FieldVisitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FieldVisitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FieldVisitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FieldVisitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> parcelId = const Value.absent(),
                Value<String> caseId = const Value.absent(),
                Value<String> officerId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> landUse = const Value.absent(),
                Value<String?> irrigation = const Value.absent(),
                Value<bool?> boundaryConfirmed = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> verificationServerId = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> gpsLat = const Value.absent(),
                Value<String?> gpsLng = const Value.absent(),
                Value<String?> gpsAccuracy = const Value.absent(),
                Value<String?> gpsTimestamp = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> submittedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FieldVisitsCompanion(
                id: id,
                clientId: clientId,
                taskId: taskId,
                parcelId: parcelId,
                caseId: caseId,
                officerId: officerId,
                status: status,
                syncStatus: syncStatus,
                landUse: landUse,
                irrigation: irrigation,
                boundaryConfirmed: boundaryConfirmed,
                notes: notes,
                verificationServerId: verificationServerId,
                lastError: lastError,
                retryCount: retryCount,
                gpsLat: gpsLat,
                gpsLng: gpsLng,
                gpsAccuracy: gpsAccuracy,
                gpsTimestamp: gpsTimestamp,
                createdAt: createdAt,
                updatedAt: updatedAt,
                submittedAt: submittedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String clientId,
                required String taskId,
                required String parcelId,
                required String caseId,
                required String officerId,
                required String status,
                required String syncStatus,
                Value<String?> landUse = const Value.absent(),
                Value<String?> irrigation = const Value.absent(),
                Value<bool?> boundaryConfirmed = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> verificationServerId = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> gpsLat = const Value.absent(),
                Value<String?> gpsLng = const Value.absent(),
                Value<String?> gpsAccuracy = const Value.absent(),
                Value<String?> gpsTimestamp = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> submittedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FieldVisitsCompanion.insert(
                id: id,
                clientId: clientId,
                taskId: taskId,
                parcelId: parcelId,
                caseId: caseId,
                officerId: officerId,
                status: status,
                syncStatus: syncStatus,
                landUse: landUse,
                irrigation: irrigation,
                boundaryConfirmed: boundaryConfirmed,
                notes: notes,
                verificationServerId: verificationServerId,
                lastError: lastError,
                retryCount: retryCount,
                gpsLat: gpsLat,
                gpsLng: gpsLng,
                gpsAccuracy: gpsAccuracy,
                gpsTimestamp: gpsTimestamp,
                createdAt: createdAt,
                updatedAt: updatedAt,
                submittedAt: submittedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FieldVisitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FieldVisitsTable,
      FieldVisit,
      $$FieldVisitsTableFilterComposer,
      $$FieldVisitsTableOrderingComposer,
      $$FieldVisitsTableAnnotationComposer,
      $$FieldVisitsTableCreateCompanionBuilder,
      $$FieldVisitsTableUpdateCompanionBuilder,
      (
        FieldVisit,
        BaseReferences<_$AppDatabase, $FieldVisitsTable, FieldVisit>,
      ),
      FieldVisit,
      PrefetchHooks Function()
    >;
typedef $$StructuresTableCreateCompanionBuilder =
    StructuresCompanion Function({
      required String id,
      required String clientId,
      required String visitId,
      required String type,
      Value<double?> areaValue,
      Value<String> areaUnit,
      Value<String?> constructionType,
      Value<String?> condition,
      Value<String?> notes,
      required String syncStatus,
      Value<String?> serverId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$StructuresTableUpdateCompanionBuilder =
    StructuresCompanion Function({
      Value<String> id,
      Value<String> clientId,
      Value<String> visitId,
      Value<String> type,
      Value<double?> areaValue,
      Value<String> areaUnit,
      Value<String?> constructionType,
      Value<String?> condition,
      Value<String?> notes,
      Value<String> syncStatus,
      Value<String?> serverId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$StructuresTableFilterComposer
    extends Composer<_$AppDatabase, $StructuresTable> {
  $$StructuresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visitId => $composableBuilder(
    column: $table.visitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get areaValue => $composableBuilder(
    column: $table.areaValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get areaUnit => $composableBuilder(
    column: $table.areaUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get constructionType => $composableBuilder(
    column: $table.constructionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StructuresTableOrderingComposer
    extends Composer<_$AppDatabase, $StructuresTable> {
  $$StructuresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visitId => $composableBuilder(
    column: $table.visitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get areaValue => $composableBuilder(
    column: $table.areaValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get areaUnit => $composableBuilder(
    column: $table.areaUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get constructionType => $composableBuilder(
    column: $table.constructionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StructuresTableAnnotationComposer
    extends Composer<_$AppDatabase, $StructuresTable> {
  $$StructuresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get visitId =>
      $composableBuilder(column: $table.visitId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get areaValue =>
      $composableBuilder(column: $table.areaValue, builder: (column) => column);

  GeneratedColumn<String> get areaUnit =>
      $composableBuilder(column: $table.areaUnit, builder: (column) => column);

  GeneratedColumn<String> get constructionType => $composableBuilder(
    column: $table.constructionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$StructuresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StructuresTable,
          Structure,
          $$StructuresTableFilterComposer,
          $$StructuresTableOrderingComposer,
          $$StructuresTableAnnotationComposer,
          $$StructuresTableCreateCompanionBuilder,
          $$StructuresTableUpdateCompanionBuilder,
          (
            Structure,
            BaseReferences<_$AppDatabase, $StructuresTable, Structure>,
          ),
          Structure,
          PrefetchHooks Function()
        > {
  $$StructuresTableTableManager(_$AppDatabase db, $StructuresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StructuresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StructuresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StructuresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String> visitId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double?> areaValue = const Value.absent(),
                Value<String> areaUnit = const Value.absent(),
                Value<String?> constructionType = const Value.absent(),
                Value<String?> condition = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StructuresCompanion(
                id: id,
                clientId: clientId,
                visitId: visitId,
                type: type,
                areaValue: areaValue,
                areaUnit: areaUnit,
                constructionType: constructionType,
                condition: condition,
                notes: notes,
                syncStatus: syncStatus,
                serverId: serverId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String clientId,
                required String visitId,
                required String type,
                Value<double?> areaValue = const Value.absent(),
                Value<String> areaUnit = const Value.absent(),
                Value<String?> constructionType = const Value.absent(),
                Value<String?> condition = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String syncStatus,
                Value<String?> serverId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => StructuresCompanion.insert(
                id: id,
                clientId: clientId,
                visitId: visitId,
                type: type,
                areaValue: areaValue,
                areaUnit: areaUnit,
                constructionType: constructionType,
                condition: condition,
                notes: notes,
                syncStatus: syncStatus,
                serverId: serverId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StructuresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StructuresTable,
      Structure,
      $$StructuresTableFilterComposer,
      $$StructuresTableOrderingComposer,
      $$StructuresTableAnnotationComposer,
      $$StructuresTableCreateCompanionBuilder,
      $$StructuresTableUpdateCompanionBuilder,
      (Structure, BaseReferences<_$AppDatabase, $StructuresTable, Structure>),
      Structure,
      PrefetchHooks Function()
    >;
typedef $$VegetationsTableCreateCompanionBuilder =
    VegetationsCompanion Function({
      required String id,
      required String clientId,
      required String visitId,
      required String species,
      required int count,
      Value<String?> cropType,
      Value<double?> areaHa,
      Value<String?> notes,
      required String syncStatus,
      Value<String?> serverId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$VegetationsTableUpdateCompanionBuilder =
    VegetationsCompanion Function({
      Value<String> id,
      Value<String> clientId,
      Value<String> visitId,
      Value<String> species,
      Value<int> count,
      Value<String?> cropType,
      Value<double?> areaHa,
      Value<String?> notes,
      Value<String> syncStatus,
      Value<String?> serverId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$VegetationsTableFilterComposer
    extends Composer<_$AppDatabase, $VegetationsTable> {
  $$VegetationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visitId => $composableBuilder(
    column: $table.visitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cropType => $composableBuilder(
    column: $table.cropType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get areaHa => $composableBuilder(
    column: $table.areaHa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VegetationsTableOrderingComposer
    extends Composer<_$AppDatabase, $VegetationsTable> {
  $$VegetationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visitId => $composableBuilder(
    column: $table.visitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cropType => $composableBuilder(
    column: $table.cropType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get areaHa => $composableBuilder(
    column: $table.areaHa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VegetationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VegetationsTable> {
  $$VegetationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get visitId =>
      $composableBuilder(column: $table.visitId, builder: (column) => column);

  GeneratedColumn<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<String> get cropType =>
      $composableBuilder(column: $table.cropType, builder: (column) => column);

  GeneratedColumn<double> get areaHa =>
      $composableBuilder(column: $table.areaHa, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$VegetationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VegetationsTable,
          Vegetation,
          $$VegetationsTableFilterComposer,
          $$VegetationsTableOrderingComposer,
          $$VegetationsTableAnnotationComposer,
          $$VegetationsTableCreateCompanionBuilder,
          $$VegetationsTableUpdateCompanionBuilder,
          (
            Vegetation,
            BaseReferences<_$AppDatabase, $VegetationsTable, Vegetation>,
          ),
          Vegetation,
          PrefetchHooks Function()
        > {
  $$VegetationsTableTableManager(_$AppDatabase db, $VegetationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VegetationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VegetationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VegetationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String> visitId = const Value.absent(),
                Value<String> species = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<String?> cropType = const Value.absent(),
                Value<double?> areaHa = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VegetationsCompanion(
                id: id,
                clientId: clientId,
                visitId: visitId,
                species: species,
                count: count,
                cropType: cropType,
                areaHa: areaHa,
                notes: notes,
                syncStatus: syncStatus,
                serverId: serverId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String clientId,
                required String visitId,
                required String species,
                required int count,
                Value<String?> cropType = const Value.absent(),
                Value<double?> areaHa = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String syncStatus,
                Value<String?> serverId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => VegetationsCompanion.insert(
                id: id,
                clientId: clientId,
                visitId: visitId,
                species: species,
                count: count,
                cropType: cropType,
                areaHa: areaHa,
                notes: notes,
                syncStatus: syncStatus,
                serverId: serverId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VegetationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VegetationsTable,
      Vegetation,
      $$VegetationsTableFilterComposer,
      $$VegetationsTableOrderingComposer,
      $$VegetationsTableAnnotationComposer,
      $$VegetationsTableCreateCompanionBuilder,
      $$VegetationsTableUpdateCompanionBuilder,
      (
        Vegetation,
        BaseReferences<_$AppDatabase, $VegetationsTable, Vegetation>,
      ),
      Vegetation,
      PrefetchHooks Function()
    >;
typedef $$LocalDocumentsTableCreateCompanionBuilder =
    LocalDocumentsCompanion Function({
      required String id,
      required String clientId,
      required String visitId,
      required String type,
      required String localFilePath,
      Value<String?> mimeType,
      required String syncStatus,
      Value<String?> serverId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LocalDocumentsTableUpdateCompanionBuilder =
    LocalDocumentsCompanion Function({
      Value<String> id,
      Value<String> clientId,
      Value<String> visitId,
      Value<String> type,
      Value<String> localFilePath,
      Value<String?> mimeType,
      Value<String> syncStatus,
      Value<String?> serverId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LocalDocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalDocumentsTable> {
  $$LocalDocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visitId => $composableBuilder(
    column: $table.visitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalDocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalDocumentsTable> {
  $$LocalDocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visitId => $composableBuilder(
    column: $table.visitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalDocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalDocumentsTable> {
  $$LocalDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get visitId =>
      $composableBuilder(column: $table.visitId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalDocumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalDocumentsTable,
          LocalDocument,
          $$LocalDocumentsTableFilterComposer,
          $$LocalDocumentsTableOrderingComposer,
          $$LocalDocumentsTableAnnotationComposer,
          $$LocalDocumentsTableCreateCompanionBuilder,
          $$LocalDocumentsTableUpdateCompanionBuilder,
          (
            LocalDocument,
            BaseReferences<_$AppDatabase, $LocalDocumentsTable, LocalDocument>,
          ),
          LocalDocument,
          PrefetchHooks Function()
        > {
  $$LocalDocumentsTableTableManager(
    _$AppDatabase db,
    $LocalDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalDocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String> visitId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> localFilePath = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalDocumentsCompanion(
                id: id,
                clientId: clientId,
                visitId: visitId,
                type: type,
                localFilePath: localFilePath,
                mimeType: mimeType,
                syncStatus: syncStatus,
                serverId: serverId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String clientId,
                required String visitId,
                required String type,
                required String localFilePath,
                Value<String?> mimeType = const Value.absent(),
                required String syncStatus,
                Value<String?> serverId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalDocumentsCompanion.insert(
                id: id,
                clientId: clientId,
                visitId: visitId,
                type: type,
                localFilePath: localFilePath,
                mimeType: mimeType,
                syncStatus: syncStatus,
                serverId: serverId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalDocumentsTable,
      LocalDocument,
      $$LocalDocumentsTableFilterComposer,
      $$LocalDocumentsTableOrderingComposer,
      $$LocalDocumentsTableAnnotationComposer,
      $$LocalDocumentsTableCreateCompanionBuilder,
      $$LocalDocumentsTableUpdateCompanionBuilder,
      (
        LocalDocument,
        BaseReferences<_$AppDatabase, $LocalDocumentsTable, LocalDocument>,
      ),
      LocalDocument,
      PrefetchHooks Function()
    >;
typedef $$EvidencesTableCreateCompanionBuilder =
    EvidencesCompanion Function({
      required String id,
      required String clientId,
      required String visitId,
      required String parcelId,
      required String officerId,
      required String type,
      required String localFilePath,
      Value<String?> latitude,
      Value<String?> longitude,
      Value<String?> gpsAccuracy,
      Value<bool> locationAvailable,
      required DateTime capturedAt,
      Value<String?> description,
      required String syncStatus,
      Value<String?> serverId,
      Value<int> rowid,
    });
typedef $$EvidencesTableUpdateCompanionBuilder =
    EvidencesCompanion Function({
      Value<String> id,
      Value<String> clientId,
      Value<String> visitId,
      Value<String> parcelId,
      Value<String> officerId,
      Value<String> type,
      Value<String> localFilePath,
      Value<String?> latitude,
      Value<String?> longitude,
      Value<String?> gpsAccuracy,
      Value<bool> locationAvailable,
      Value<DateTime> capturedAt,
      Value<String?> description,
      Value<String> syncStatus,
      Value<String?> serverId,
      Value<int> rowid,
    });

class $$EvidencesTableFilterComposer
    extends Composer<_$AppDatabase, $EvidencesTable> {
  $$EvidencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visitId => $composableBuilder(
    column: $table.visitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parcelId => $composableBuilder(
    column: $table.parcelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get officerId => $composableBuilder(
    column: $table.officerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gpsAccuracy => $composableBuilder(
    column: $table.gpsAccuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get locationAvailable => $composableBuilder(
    column: $table.locationAvailable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EvidencesTableOrderingComposer
    extends Composer<_$AppDatabase, $EvidencesTable> {
  $$EvidencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visitId => $composableBuilder(
    column: $table.visitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parcelId => $composableBuilder(
    column: $table.parcelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get officerId => $composableBuilder(
    column: $table.officerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gpsAccuracy => $composableBuilder(
    column: $table.gpsAccuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get locationAvailable => $composableBuilder(
    column: $table.locationAvailable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EvidencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EvidencesTable> {
  $$EvidencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get visitId =>
      $composableBuilder(column: $table.visitId, builder: (column) => column);

  GeneratedColumn<String> get parcelId =>
      $composableBuilder(column: $table.parcelId, builder: (column) => column);

  GeneratedColumn<String> get officerId =>
      $composableBuilder(column: $table.officerId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<String> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get gpsAccuracy => $composableBuilder(
    column: $table.gpsAccuracy,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get locationAvailable => $composableBuilder(
    column: $table.locationAvailable,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);
}

class $$EvidencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EvidencesTable,
          Evidence,
          $$EvidencesTableFilterComposer,
          $$EvidencesTableOrderingComposer,
          $$EvidencesTableAnnotationComposer,
          $$EvidencesTableCreateCompanionBuilder,
          $$EvidencesTableUpdateCompanionBuilder,
          (Evidence, BaseReferences<_$AppDatabase, $EvidencesTable, Evidence>),
          Evidence,
          PrefetchHooks Function()
        > {
  $$EvidencesTableTableManager(_$AppDatabase db, $EvidencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EvidencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EvidencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EvidencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String> visitId = const Value.absent(),
                Value<String> parcelId = const Value.absent(),
                Value<String> officerId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> localFilePath = const Value.absent(),
                Value<String?> latitude = const Value.absent(),
                Value<String?> longitude = const Value.absent(),
                Value<String?> gpsAccuracy = const Value.absent(),
                Value<bool> locationAvailable = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EvidencesCompanion(
                id: id,
                clientId: clientId,
                visitId: visitId,
                parcelId: parcelId,
                officerId: officerId,
                type: type,
                localFilePath: localFilePath,
                latitude: latitude,
                longitude: longitude,
                gpsAccuracy: gpsAccuracy,
                locationAvailable: locationAvailable,
                capturedAt: capturedAt,
                description: description,
                syncStatus: syncStatus,
                serverId: serverId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String clientId,
                required String visitId,
                required String parcelId,
                required String officerId,
                required String type,
                required String localFilePath,
                Value<String?> latitude = const Value.absent(),
                Value<String?> longitude = const Value.absent(),
                Value<String?> gpsAccuracy = const Value.absent(),
                Value<bool> locationAvailable = const Value.absent(),
                required DateTime capturedAt,
                Value<String?> description = const Value.absent(),
                required String syncStatus,
                Value<String?> serverId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EvidencesCompanion.insert(
                id: id,
                clientId: clientId,
                visitId: visitId,
                parcelId: parcelId,
                officerId: officerId,
                type: type,
                localFilePath: localFilePath,
                latitude: latitude,
                longitude: longitude,
                gpsAccuracy: gpsAccuracy,
                locationAvailable: locationAvailable,
                capturedAt: capturedAt,
                description: description,
                syncStatus: syncStatus,
                serverId: serverId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EvidencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EvidencesTable,
      Evidence,
      $$EvidencesTableFilterComposer,
      $$EvidencesTableOrderingComposer,
      $$EvidencesTableAnnotationComposer,
      $$EvidencesTableCreateCompanionBuilder,
      $$EvidencesTableUpdateCompanionBuilder,
      (Evidence, BaseReferences<_$AppDatabase, $EvidencesTable, Evidence>),
      Evidence,
      PrefetchHooks Function()
    >;
typedef $$SyncQueuesTableCreateCompanionBuilder =
    SyncQueuesCompanion Function({
      required String id,
      required String entityType,
      required String entityId,
      required String operation,
      required String payload,
      Value<int> retryCount,
      required String status,
      Value<String?> lastError,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SyncQueuesTableUpdateCompanionBuilder =
    SyncQueuesCompanion Function({
      Value<String> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> operation,
      Value<String> payload,
      Value<int> retryCount,
      Value<String> status,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SyncQueuesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueuesTable> {
  $$SyncQueuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueuesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueuesTable> {
  $$SyncQueuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueuesTable> {
  $$SyncQueuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncQueuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueuesTable,
          SyncQueue,
          $$SyncQueuesTableFilterComposer,
          $$SyncQueuesTableOrderingComposer,
          $$SyncQueuesTableAnnotationComposer,
          $$SyncQueuesTableCreateCompanionBuilder,
          $$SyncQueuesTableUpdateCompanionBuilder,
          (
            SyncQueue,
            BaseReferences<_$AppDatabase, $SyncQueuesTable, SyncQueue>,
          ),
          SyncQueue,
          PrefetchHooks Function()
        > {
  $$SyncQueuesTableTableManager(_$AppDatabase db, $SyncQueuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueuesCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payload: payload,
                retryCount: retryCount,
                status: status,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityType,
                required String entityId,
                required String operation,
                required String payload,
                Value<int> retryCount = const Value.absent(),
                required String status,
                Value<String?> lastError = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncQueuesCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payload: payload,
                retryCount: retryCount,
                status: status,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueuesTable,
      SyncQueue,
      $$SyncQueuesTableFilterComposer,
      $$SyncQueuesTableOrderingComposer,
      $$SyncQueuesTableAnnotationComposer,
      $$SyncQueuesTableCreateCompanionBuilder,
      $$SyncQueuesTableUpdateCompanionBuilder,
      (SyncQueue, BaseReferences<_$AppDatabase, $SyncQueuesTable, SyncQueue>),
      SyncQueue,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$AssignedTasksTableTableManager get assignedTasks =>
      $$AssignedTasksTableTableManager(_db, _db.assignedTasks);
  $$FieldVisitsTableTableManager get fieldVisits =>
      $$FieldVisitsTableTableManager(_db, _db.fieldVisits);
  $$StructuresTableTableManager get structures =>
      $$StructuresTableTableManager(_db, _db.structures);
  $$VegetationsTableTableManager get vegetations =>
      $$VegetationsTableTableManager(_db, _db.vegetations);
  $$LocalDocumentsTableTableManager get localDocuments =>
      $$LocalDocumentsTableTableManager(_db, _db.localDocuments);
  $$EvidencesTableTableManager get evidences =>
      $$EvidencesTableTableManager(_db, _db.evidences);
  $$SyncQueuesTableTableManager get syncQueues =>
      $$SyncQueuesTableTableManager(_db, _db.syncQueues);
}
