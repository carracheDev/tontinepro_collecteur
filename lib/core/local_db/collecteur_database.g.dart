// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collecteur_database.dart';

// ignore_for_file: type=lint
class $CacheKvTable extends CacheKv with TableInfo<$CacheKvTable, CacheKvData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheKvTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cleMeta = const VerificationMeta('cle');
  @override
  late final GeneratedColumn<String> cle = GeneratedColumn<String>(
    'cle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonDataMeta = const VerificationMeta(
    'jsonData',
  );
  @override
  late final GeneratedColumn<String> jsonData = GeneratedColumn<String>(
    'json_data',
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
  List<GeneratedColumn> get $columns => [cle, jsonData, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_kv';
  @override
  VerificationContext validateIntegrity(
    Insertable<CacheKvData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cle')) {
      context.handle(
        _cleMeta,
        cle.isAcceptableOrUnknown(data['cle']!, _cleMeta),
      );
    } else if (isInserting) {
      context.missing(_cleMeta);
    }
    if (data.containsKey('json_data')) {
      context.handle(
        _jsonDataMeta,
        jsonData.isAcceptableOrUnknown(data['json_data']!, _jsonDataMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonDataMeta);
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
  Set<GeneratedColumn> get $primaryKey => {cle};
  @override
  CacheKvData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheKvData(
      cle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cle'],
      )!,
      jsonData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json_data'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CacheKvTable createAlias(String alias) {
    return $CacheKvTable(attachedDatabase, alias);
  }
}

class CacheKvData extends DataClass implements Insertable<CacheKvData> {
  final String cle;
  final String jsonData;
  final DateTime cachedAt;
  const CacheKvData({
    required this.cle,
    required this.jsonData,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cle'] = Variable<String>(cle);
    map['json_data'] = Variable<String>(jsonData);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CacheKvCompanion toCompanion(bool nullToAbsent) {
    return CacheKvCompanion(
      cle: Value(cle),
      jsonData: Value(jsonData),
      cachedAt: Value(cachedAt),
    );
  }

  factory CacheKvData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheKvData(
      cle: serializer.fromJson<String>(json['cle']),
      jsonData: serializer.fromJson<String>(json['jsonData']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cle': serializer.toJson<String>(cle),
      'jsonData': serializer.toJson<String>(jsonData),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CacheKvData copyWith({String? cle, String? jsonData, DateTime? cachedAt}) =>
      CacheKvData(
        cle: cle ?? this.cle,
        jsonData: jsonData ?? this.jsonData,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CacheKvData copyWithCompanion(CacheKvCompanion data) {
    return CacheKvData(
      cle: data.cle.present ? data.cle.value : this.cle,
      jsonData: data.jsonData.present ? data.jsonData.value : this.jsonData,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheKvData(')
          ..write('cle: $cle, ')
          ..write('jsonData: $jsonData, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cle, jsonData, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheKvData &&
          other.cle == this.cle &&
          other.jsonData == this.jsonData &&
          other.cachedAt == this.cachedAt);
}

class CacheKvCompanion extends UpdateCompanion<CacheKvData> {
  final Value<String> cle;
  final Value<String> jsonData;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CacheKvCompanion({
    this.cle = const Value.absent(),
    this.jsonData = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheKvCompanion.insert({
    required String cle,
    required String jsonData,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : cle = Value(cle),
       jsonData = Value(jsonData),
       cachedAt = Value(cachedAt);
  static Insertable<CacheKvData> custom({
    Expression<String>? cle,
    Expression<String>? jsonData,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cle != null) 'cle': cle,
      if (jsonData != null) 'json_data': jsonData,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheKvCompanion copyWith({
    Value<String>? cle,
    Value<String>? jsonData,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CacheKvCompanion(
      cle: cle ?? this.cle,
      jsonData: jsonData ?? this.jsonData,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cle.present) {
      map['cle'] = Variable<String>(cle.value);
    }
    if (jsonData.present) {
      map['json_data'] = Variable<String>(jsonData.value);
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
    return (StringBuffer('CacheKvCompanion(')
          ..write('cle: $cle, ')
          ..write('jsonData: $jsonData, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OperationsEnAttenteTable extends OperationsEnAttente
    with TableInfo<$OperationsEnAttenteTable, OperationsEnAttenteData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OperationsEnAttenteTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _typeOpMeta = const VerificationMeta('typeOp');
  @override
  late final GeneratedColumn<String> typeOp = GeneratedColumn<String>(
    'type_op',
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
  static const VerificationMeta _endpointMeta = const VerificationMeta(
    'endpoint',
  );
  @override
  late final GeneratedColumn<String> endpoint = GeneratedColumn<String>(
    'endpoint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodeMeta = const VerificationMeta(
    'methode',
  );
  @override
  late final GeneratedColumn<String> methode = GeneratedColumn<String>(
    'methode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('POST'),
  );
  static const VerificationMeta _creeLeMeta = const VerificationMeta('creeLe');
  @override
  late final GeneratedColumn<DateTime> creeLe = GeneratedColumn<DateTime>(
    'cree_le',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _tentativesMeta = const VerificationMeta(
    'tentatives',
  );
  @override
  late final GeneratedColumn<int> tentatives = GeneratedColumn<int>(
    'tentatives',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _erreurDerniereMeta = const VerificationMeta(
    'erreurDerniere',
  );
  @override
  late final GeneratedColumn<String> erreurDerniere = GeneratedColumn<String>(
    'erreur_derniere',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    typeOp,
    payload,
    endpoint,
    methode,
    creeLe,
    tentatives,
    erreurDerniere,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'operations_en_attente';
  @override
  VerificationContext validateIntegrity(
    Insertable<OperationsEnAttenteData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type_op')) {
      context.handle(
        _typeOpMeta,
        typeOp.isAcceptableOrUnknown(data['type_op']!, _typeOpMeta),
      );
    } else if (isInserting) {
      context.missing(_typeOpMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('endpoint')) {
      context.handle(
        _endpointMeta,
        endpoint.isAcceptableOrUnknown(data['endpoint']!, _endpointMeta),
      );
    } else if (isInserting) {
      context.missing(_endpointMeta);
    }
    if (data.containsKey('methode')) {
      context.handle(
        _methodeMeta,
        methode.isAcceptableOrUnknown(data['methode']!, _methodeMeta),
      );
    }
    if (data.containsKey('cree_le')) {
      context.handle(
        _creeLeMeta,
        creeLe.isAcceptableOrUnknown(data['cree_le']!, _creeLeMeta),
      );
    }
    if (data.containsKey('tentatives')) {
      context.handle(
        _tentativesMeta,
        tentatives.isAcceptableOrUnknown(data['tentatives']!, _tentativesMeta),
      );
    }
    if (data.containsKey('erreur_derniere')) {
      context.handle(
        _erreurDerniereMeta,
        erreurDerniere.isAcceptableOrUnknown(
          data['erreur_derniere']!,
          _erreurDerniereMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OperationsEnAttenteData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OperationsEnAttenteData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      typeOp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_op'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      endpoint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endpoint'],
      )!,
      methode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}methode'],
      )!,
      creeLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cree_le'],
      )!,
      tentatives: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tentatives'],
      )!,
      erreurDerniere: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}erreur_derniere'],
      ),
    );
  }

  @override
  $OperationsEnAttenteTable createAlias(String alias) {
    return $OperationsEnAttenteTable(attachedDatabase, alias);
  }
}

class OperationsEnAttenteData extends DataClass
    implements Insertable<OperationsEnAttenteData> {
  final int id;
  final String typeOp;
  final String payload;
  final String endpoint;
  final String methode;
  final DateTime creeLe;
  final int tentatives;
  final String? erreurDerniere;
  const OperationsEnAttenteData({
    required this.id,
    required this.typeOp,
    required this.payload,
    required this.endpoint,
    required this.methode,
    required this.creeLe,
    required this.tentatives,
    this.erreurDerniere,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type_op'] = Variable<String>(typeOp);
    map['payload'] = Variable<String>(payload);
    map['endpoint'] = Variable<String>(endpoint);
    map['methode'] = Variable<String>(methode);
    map['cree_le'] = Variable<DateTime>(creeLe);
    map['tentatives'] = Variable<int>(tentatives);
    if (!nullToAbsent || erreurDerniere != null) {
      map['erreur_derniere'] = Variable<String>(erreurDerniere);
    }
    return map;
  }

  OperationsEnAttenteCompanion toCompanion(bool nullToAbsent) {
    return OperationsEnAttenteCompanion(
      id: Value(id),
      typeOp: Value(typeOp),
      payload: Value(payload),
      endpoint: Value(endpoint),
      methode: Value(methode),
      creeLe: Value(creeLe),
      tentatives: Value(tentatives),
      erreurDerniere: erreurDerniere == null && nullToAbsent
          ? const Value.absent()
          : Value(erreurDerniere),
    );
  }

  factory OperationsEnAttenteData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OperationsEnAttenteData(
      id: serializer.fromJson<int>(json['id']),
      typeOp: serializer.fromJson<String>(json['typeOp']),
      payload: serializer.fromJson<String>(json['payload']),
      endpoint: serializer.fromJson<String>(json['endpoint']),
      methode: serializer.fromJson<String>(json['methode']),
      creeLe: serializer.fromJson<DateTime>(json['creeLe']),
      tentatives: serializer.fromJson<int>(json['tentatives']),
      erreurDerniere: serializer.fromJson<String?>(json['erreurDerniere']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'typeOp': serializer.toJson<String>(typeOp),
      'payload': serializer.toJson<String>(payload),
      'endpoint': serializer.toJson<String>(endpoint),
      'methode': serializer.toJson<String>(methode),
      'creeLe': serializer.toJson<DateTime>(creeLe),
      'tentatives': serializer.toJson<int>(tentatives),
      'erreurDerniere': serializer.toJson<String?>(erreurDerniere),
    };
  }

  OperationsEnAttenteData copyWith({
    int? id,
    String? typeOp,
    String? payload,
    String? endpoint,
    String? methode,
    DateTime? creeLe,
    int? tentatives,
    Value<String?> erreurDerniere = const Value.absent(),
  }) => OperationsEnAttenteData(
    id: id ?? this.id,
    typeOp: typeOp ?? this.typeOp,
    payload: payload ?? this.payload,
    endpoint: endpoint ?? this.endpoint,
    methode: methode ?? this.methode,
    creeLe: creeLe ?? this.creeLe,
    tentatives: tentatives ?? this.tentatives,
    erreurDerniere: erreurDerniere.present
        ? erreurDerniere.value
        : this.erreurDerniere,
  );
  OperationsEnAttenteData copyWithCompanion(OperationsEnAttenteCompanion data) {
    return OperationsEnAttenteData(
      id: data.id.present ? data.id.value : this.id,
      typeOp: data.typeOp.present ? data.typeOp.value : this.typeOp,
      payload: data.payload.present ? data.payload.value : this.payload,
      endpoint: data.endpoint.present ? data.endpoint.value : this.endpoint,
      methode: data.methode.present ? data.methode.value : this.methode,
      creeLe: data.creeLe.present ? data.creeLe.value : this.creeLe,
      tentatives: data.tentatives.present
          ? data.tentatives.value
          : this.tentatives,
      erreurDerniere: data.erreurDerniere.present
          ? data.erreurDerniere.value
          : this.erreurDerniere,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OperationsEnAttenteData(')
          ..write('id: $id, ')
          ..write('typeOp: $typeOp, ')
          ..write('payload: $payload, ')
          ..write('endpoint: $endpoint, ')
          ..write('methode: $methode, ')
          ..write('creeLe: $creeLe, ')
          ..write('tentatives: $tentatives, ')
          ..write('erreurDerniere: $erreurDerniere')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    typeOp,
    payload,
    endpoint,
    methode,
    creeLe,
    tentatives,
    erreurDerniere,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OperationsEnAttenteData &&
          other.id == this.id &&
          other.typeOp == this.typeOp &&
          other.payload == this.payload &&
          other.endpoint == this.endpoint &&
          other.methode == this.methode &&
          other.creeLe == this.creeLe &&
          other.tentatives == this.tentatives &&
          other.erreurDerniere == this.erreurDerniere);
}

class OperationsEnAttenteCompanion
    extends UpdateCompanion<OperationsEnAttenteData> {
  final Value<int> id;
  final Value<String> typeOp;
  final Value<String> payload;
  final Value<String> endpoint;
  final Value<String> methode;
  final Value<DateTime> creeLe;
  final Value<int> tentatives;
  final Value<String?> erreurDerniere;
  const OperationsEnAttenteCompanion({
    this.id = const Value.absent(),
    this.typeOp = const Value.absent(),
    this.payload = const Value.absent(),
    this.endpoint = const Value.absent(),
    this.methode = const Value.absent(),
    this.creeLe = const Value.absent(),
    this.tentatives = const Value.absent(),
    this.erreurDerniere = const Value.absent(),
  });
  OperationsEnAttenteCompanion.insert({
    this.id = const Value.absent(),
    required String typeOp,
    required String payload,
    required String endpoint,
    this.methode = const Value.absent(),
    this.creeLe = const Value.absent(),
    this.tentatives = const Value.absent(),
    this.erreurDerniere = const Value.absent(),
  }) : typeOp = Value(typeOp),
       payload = Value(payload),
       endpoint = Value(endpoint);
  static Insertable<OperationsEnAttenteData> custom({
    Expression<int>? id,
    Expression<String>? typeOp,
    Expression<String>? payload,
    Expression<String>? endpoint,
    Expression<String>? methode,
    Expression<DateTime>? creeLe,
    Expression<int>? tentatives,
    Expression<String>? erreurDerniere,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (typeOp != null) 'type_op': typeOp,
      if (payload != null) 'payload': payload,
      if (endpoint != null) 'endpoint': endpoint,
      if (methode != null) 'methode': methode,
      if (creeLe != null) 'cree_le': creeLe,
      if (tentatives != null) 'tentatives': tentatives,
      if (erreurDerniere != null) 'erreur_derniere': erreurDerniere,
    });
  }

  OperationsEnAttenteCompanion copyWith({
    Value<int>? id,
    Value<String>? typeOp,
    Value<String>? payload,
    Value<String>? endpoint,
    Value<String>? methode,
    Value<DateTime>? creeLe,
    Value<int>? tentatives,
    Value<String?>? erreurDerniere,
  }) {
    return OperationsEnAttenteCompanion(
      id: id ?? this.id,
      typeOp: typeOp ?? this.typeOp,
      payload: payload ?? this.payload,
      endpoint: endpoint ?? this.endpoint,
      methode: methode ?? this.methode,
      creeLe: creeLe ?? this.creeLe,
      tentatives: tentatives ?? this.tentatives,
      erreurDerniere: erreurDerniere ?? this.erreurDerniere,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (typeOp.present) {
      map['type_op'] = Variable<String>(typeOp.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (endpoint.present) {
      map['endpoint'] = Variable<String>(endpoint.value);
    }
    if (methode.present) {
      map['methode'] = Variable<String>(methode.value);
    }
    if (creeLe.present) {
      map['cree_le'] = Variable<DateTime>(creeLe.value);
    }
    if (tentatives.present) {
      map['tentatives'] = Variable<int>(tentatives.value);
    }
    if (erreurDerniere.present) {
      map['erreur_derniere'] = Variable<String>(erreurDerniere.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OperationsEnAttenteCompanion(')
          ..write('id: $id, ')
          ..write('typeOp: $typeOp, ')
          ..write('payload: $payload, ')
          ..write('endpoint: $endpoint, ')
          ..write('methode: $methode, ')
          ..write('creeLe: $creeLe, ')
          ..write('tentatives: $tentatives, ')
          ..write('erreurDerniere: $erreurDerniere')
          ..write(')'))
        .toString();
  }
}

abstract class _$CollecteurDatabase extends GeneratedDatabase {
  _$CollecteurDatabase(QueryExecutor e) : super(e);
  $CollecteurDatabaseManager get managers => $CollecteurDatabaseManager(this);
  late final $CacheKvTable cacheKv = $CacheKvTable(this);
  late final $OperationsEnAttenteTable operationsEnAttente =
      $OperationsEnAttenteTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cacheKv,
    operationsEnAttente,
  ];
}

typedef $$CacheKvTableCreateCompanionBuilder =
    CacheKvCompanion Function({
      required String cle,
      required String jsonData,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$CacheKvTableUpdateCompanionBuilder =
    CacheKvCompanion Function({
      Value<String> cle,
      Value<String> jsonData,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CacheKvTableFilterComposer
    extends Composer<_$CollecteurDatabase, $CacheKvTable> {
  $$CacheKvTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cle => $composableBuilder(
    column: $table.cle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonData => $composableBuilder(
    column: $table.jsonData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CacheKvTableOrderingComposer
    extends Composer<_$CollecteurDatabase, $CacheKvTable> {
  $$CacheKvTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cle => $composableBuilder(
    column: $table.cle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonData => $composableBuilder(
    column: $table.jsonData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CacheKvTableAnnotationComposer
    extends Composer<_$CollecteurDatabase, $CacheKvTable> {
  $$CacheKvTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cle =>
      $composableBuilder(column: $table.cle, builder: (column) => column);

  GeneratedColumn<String> get jsonData =>
      $composableBuilder(column: $table.jsonData, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CacheKvTableTableManager
    extends
        RootTableManager<
          _$CollecteurDatabase,
          $CacheKvTable,
          CacheKvData,
          $$CacheKvTableFilterComposer,
          $$CacheKvTableOrderingComposer,
          $$CacheKvTableAnnotationComposer,
          $$CacheKvTableCreateCompanionBuilder,
          $$CacheKvTableUpdateCompanionBuilder,
          (
            CacheKvData,
            BaseReferences<_$CollecteurDatabase, $CacheKvTable, CacheKvData>,
          ),
          CacheKvData,
          PrefetchHooks Function()
        > {
  $$CacheKvTableTableManager(_$CollecteurDatabase db, $CacheKvTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheKvTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheKvTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CacheKvTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cle = const Value.absent(),
                Value<String> jsonData = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheKvCompanion(
                cle: cle,
                jsonData: jsonData,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cle,
                required String jsonData,
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => CacheKvCompanion.insert(
                cle: cle,
                jsonData: jsonData,
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

typedef $$CacheKvTableProcessedTableManager =
    ProcessedTableManager<
      _$CollecteurDatabase,
      $CacheKvTable,
      CacheKvData,
      $$CacheKvTableFilterComposer,
      $$CacheKvTableOrderingComposer,
      $$CacheKvTableAnnotationComposer,
      $$CacheKvTableCreateCompanionBuilder,
      $$CacheKvTableUpdateCompanionBuilder,
      (
        CacheKvData,
        BaseReferences<_$CollecteurDatabase, $CacheKvTable, CacheKvData>,
      ),
      CacheKvData,
      PrefetchHooks Function()
    >;
typedef $$OperationsEnAttenteTableCreateCompanionBuilder =
    OperationsEnAttenteCompanion Function({
      Value<int> id,
      required String typeOp,
      required String payload,
      required String endpoint,
      Value<String> methode,
      Value<DateTime> creeLe,
      Value<int> tentatives,
      Value<String?> erreurDerniere,
    });
typedef $$OperationsEnAttenteTableUpdateCompanionBuilder =
    OperationsEnAttenteCompanion Function({
      Value<int> id,
      Value<String> typeOp,
      Value<String> payload,
      Value<String> endpoint,
      Value<String> methode,
      Value<DateTime> creeLe,
      Value<int> tentatives,
      Value<String?> erreurDerniere,
    });

class $$OperationsEnAttenteTableFilterComposer
    extends Composer<_$CollecteurDatabase, $OperationsEnAttenteTable> {
  $$OperationsEnAttenteTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeOp => $composableBuilder(
    column: $table.typeOp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get methode => $composableBuilder(
    column: $table.methode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creeLe => $composableBuilder(
    column: $table.creeLe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tentatives => $composableBuilder(
    column: $table.tentatives,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get erreurDerniere => $composableBuilder(
    column: $table.erreurDerniere,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OperationsEnAttenteTableOrderingComposer
    extends Composer<_$CollecteurDatabase, $OperationsEnAttenteTable> {
  $$OperationsEnAttenteTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeOp => $composableBuilder(
    column: $table.typeOp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get methode => $composableBuilder(
    column: $table.methode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creeLe => $composableBuilder(
    column: $table.creeLe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tentatives => $composableBuilder(
    column: $table.tentatives,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get erreurDerniere => $composableBuilder(
    column: $table.erreurDerniere,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OperationsEnAttenteTableAnnotationComposer
    extends Composer<_$CollecteurDatabase, $OperationsEnAttenteTable> {
  $$OperationsEnAttenteTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get typeOp =>
      $composableBuilder(column: $table.typeOp, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get endpoint =>
      $composableBuilder(column: $table.endpoint, builder: (column) => column);

  GeneratedColumn<String> get methode =>
      $composableBuilder(column: $table.methode, builder: (column) => column);

  GeneratedColumn<DateTime> get creeLe =>
      $composableBuilder(column: $table.creeLe, builder: (column) => column);

  GeneratedColumn<int> get tentatives => $composableBuilder(
    column: $table.tentatives,
    builder: (column) => column,
  );

  GeneratedColumn<String> get erreurDerniere => $composableBuilder(
    column: $table.erreurDerniere,
    builder: (column) => column,
  );
}

class $$OperationsEnAttenteTableTableManager
    extends
        RootTableManager<
          _$CollecteurDatabase,
          $OperationsEnAttenteTable,
          OperationsEnAttenteData,
          $$OperationsEnAttenteTableFilterComposer,
          $$OperationsEnAttenteTableOrderingComposer,
          $$OperationsEnAttenteTableAnnotationComposer,
          $$OperationsEnAttenteTableCreateCompanionBuilder,
          $$OperationsEnAttenteTableUpdateCompanionBuilder,
          (
            OperationsEnAttenteData,
            BaseReferences<
              _$CollecteurDatabase,
              $OperationsEnAttenteTable,
              OperationsEnAttenteData
            >,
          ),
          OperationsEnAttenteData,
          PrefetchHooks Function()
        > {
  $$OperationsEnAttenteTableTableManager(
    _$CollecteurDatabase db,
    $OperationsEnAttenteTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OperationsEnAttenteTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OperationsEnAttenteTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$OperationsEnAttenteTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> typeOp = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> endpoint = const Value.absent(),
                Value<String> methode = const Value.absent(),
                Value<DateTime> creeLe = const Value.absent(),
                Value<int> tentatives = const Value.absent(),
                Value<String?> erreurDerniere = const Value.absent(),
              }) => OperationsEnAttenteCompanion(
                id: id,
                typeOp: typeOp,
                payload: payload,
                endpoint: endpoint,
                methode: methode,
                creeLe: creeLe,
                tentatives: tentatives,
                erreurDerniere: erreurDerniere,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String typeOp,
                required String payload,
                required String endpoint,
                Value<String> methode = const Value.absent(),
                Value<DateTime> creeLe = const Value.absent(),
                Value<int> tentatives = const Value.absent(),
                Value<String?> erreurDerniere = const Value.absent(),
              }) => OperationsEnAttenteCompanion.insert(
                id: id,
                typeOp: typeOp,
                payload: payload,
                endpoint: endpoint,
                methode: methode,
                creeLe: creeLe,
                tentatives: tentatives,
                erreurDerniere: erreurDerniere,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OperationsEnAttenteTableProcessedTableManager =
    ProcessedTableManager<
      _$CollecteurDatabase,
      $OperationsEnAttenteTable,
      OperationsEnAttenteData,
      $$OperationsEnAttenteTableFilterComposer,
      $$OperationsEnAttenteTableOrderingComposer,
      $$OperationsEnAttenteTableAnnotationComposer,
      $$OperationsEnAttenteTableCreateCompanionBuilder,
      $$OperationsEnAttenteTableUpdateCompanionBuilder,
      (
        OperationsEnAttenteData,
        BaseReferences<
          _$CollecteurDatabase,
          $OperationsEnAttenteTable,
          OperationsEnAttenteData
        >,
      ),
      OperationsEnAttenteData,
      PrefetchHooks Function()
    >;

class $CollecteurDatabaseManager {
  final _$CollecteurDatabase _db;
  $CollecteurDatabaseManager(this._db);
  $$CacheKvTableTableManager get cacheKv =>
      $$CacheKvTableTableManager(_db, _db.cacheKv);
  $$OperationsEnAttenteTableTableManager get operationsEnAttente =>
      $$OperationsEnAttenteTableTableManager(_db, _db.operationsEnAttente);
}
