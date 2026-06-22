// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TrackedAppsTable extends TrackedApps
    with TableInfo<$TrackedAppsTable, TrackedAppRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackedAppsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _packageIdMeta = const VerificationMeta(
    'packageId',
  );
  @override
  late final GeneratedColumn<String> packageId = GeneratedColumn<String>(
    'package_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AppStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<AppStatus>($TrackedAppsTable.$converterstatus);
  static const VerificationMeta _freedAtMeta = const VerificationMeta(
    'freedAt',
  );
  @override
  late final GeneratedColumn<DateTime> freedAt = GeneratedColumn<DateTime>(
    'freed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    packageId,
    displayName,
    addedAt,
    status,
    freedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracked_apps';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackedAppRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('package_id')) {
      context.handle(
        _packageIdMeta,
        packageId.isAcceptableOrUnknown(data['package_id']!, _packageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packageIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('freed_at')) {
      context.handle(
        _freedAtMeta,
        freedAt.isAcceptableOrUnknown(data['freed_at']!, _freedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {packageId};
  @override
  TrackedAppRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackedAppRow(
      packageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      status: $TrackedAppsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      freedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}freed_at'],
      ),
    );
  }

  @override
  $TrackedAppsTable createAlias(String alias) {
    return $TrackedAppsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AppStatus, int, int> $converterstatus =
      const EnumIndexConverter<AppStatus>(AppStatus.values);
}

class TrackedAppRow extends DataClass implements Insertable<TrackedAppRow> {
  final String packageId;
  final String displayName;
  final DateTime addedAt;
  final AppStatus status;
  final DateTime? freedAt;
  const TrackedAppRow({
    required this.packageId,
    required this.displayName,
    required this.addedAt,
    required this.status,
    this.freedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['package_id'] = Variable<String>(packageId);
    map['display_name'] = Variable<String>(displayName);
    map['added_at'] = Variable<DateTime>(addedAt);
    {
      map['status'] = Variable<int>(
        $TrackedAppsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || freedAt != null) {
      map['freed_at'] = Variable<DateTime>(freedAt);
    }
    return map;
  }

  TrackedAppsCompanion toCompanion(bool nullToAbsent) {
    return TrackedAppsCompanion(
      packageId: Value(packageId),
      displayName: Value(displayName),
      addedAt: Value(addedAt),
      status: Value(status),
      freedAt: freedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(freedAt),
    );
  }

  factory TrackedAppRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackedAppRow(
      packageId: serializer.fromJson<String>(json['packageId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      status: $TrackedAppsTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      freedAt: serializer.fromJson<DateTime?>(json['freedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'packageId': serializer.toJson<String>(packageId),
      'displayName': serializer.toJson<String>(displayName),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'status': serializer.toJson<int>(
        $TrackedAppsTable.$converterstatus.toJson(status),
      ),
      'freedAt': serializer.toJson<DateTime?>(freedAt),
    };
  }

  TrackedAppRow copyWith({
    String? packageId,
    String? displayName,
    DateTime? addedAt,
    AppStatus? status,
    Value<DateTime?> freedAt = const Value.absent(),
  }) => TrackedAppRow(
    packageId: packageId ?? this.packageId,
    displayName: displayName ?? this.displayName,
    addedAt: addedAt ?? this.addedAt,
    status: status ?? this.status,
    freedAt: freedAt.present ? freedAt.value : this.freedAt,
  );
  TrackedAppRow copyWithCompanion(TrackedAppsCompanion data) {
    return TrackedAppRow(
      packageId: data.packageId.present ? data.packageId.value : this.packageId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      status: data.status.present ? data.status.value : this.status,
      freedAt: data.freedAt.present ? data.freedAt.value : this.freedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackedAppRow(')
          ..write('packageId: $packageId, ')
          ..write('displayName: $displayName, ')
          ..write('addedAt: $addedAt, ')
          ..write('status: $status, ')
          ..write('freedAt: $freedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(packageId, displayName, addedAt, status, freedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackedAppRow &&
          other.packageId == this.packageId &&
          other.displayName == this.displayName &&
          other.addedAt == this.addedAt &&
          other.status == this.status &&
          other.freedAt == this.freedAt);
}

class TrackedAppsCompanion extends UpdateCompanion<TrackedAppRow> {
  final Value<String> packageId;
  final Value<String> displayName;
  final Value<DateTime> addedAt;
  final Value<AppStatus> status;
  final Value<DateTime?> freedAt;
  final Value<int> rowid;
  const TrackedAppsCompanion({
    this.packageId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.freedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackedAppsCompanion.insert({
    required String packageId,
    required String displayName,
    required DateTime addedAt,
    required AppStatus status,
    this.freedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : packageId = Value(packageId),
       displayName = Value(displayName),
       addedAt = Value(addedAt),
       status = Value(status);
  static Insertable<TrackedAppRow> custom({
    Expression<String>? packageId,
    Expression<String>? displayName,
    Expression<DateTime>? addedAt,
    Expression<int>? status,
    Expression<DateTime>? freedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (packageId != null) 'package_id': packageId,
      if (displayName != null) 'display_name': displayName,
      if (addedAt != null) 'added_at': addedAt,
      if (status != null) 'status': status,
      if (freedAt != null) 'freed_at': freedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackedAppsCompanion copyWith({
    Value<String>? packageId,
    Value<String>? displayName,
    Value<DateTime>? addedAt,
    Value<AppStatus>? status,
    Value<DateTime?>? freedAt,
    Value<int>? rowid,
  }) {
    return TrackedAppsCompanion(
      packageId: packageId ?? this.packageId,
      displayName: displayName ?? this.displayName,
      addedAt: addedAt ?? this.addedAt,
      status: status ?? this.status,
      freedAt: freedAt ?? this.freedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (packageId.present) {
      map['package_id'] = Variable<String>(packageId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $TrackedAppsTable.$converterstatus.toSql(status.value),
      );
    }
    if (freedAt.present) {
      map['freed_at'] = Variable<DateTime>(freedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackedAppsCompanion(')
          ..write('packageId: $packageId, ')
          ..write('displayName: $displayName, ')
          ..write('addedAt: $addedAt, ')
          ..write('status: $status, ')
          ..write('freedAt: $freedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DayRecordsTable extends DayRecords
    with TableInfo<$DayRecordsTable, DayRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _packageIdMeta = const VerificationMeta(
    'packageId',
  );
  @override
  late final GeneratedColumn<String> packageId = GeneratedColumn<String>(
    'package_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayStartMillisMeta = const VerificationMeta(
    'dayStartMillis',
  );
  @override
  late final GeneratedColumn<int> dayStartMillis = GeneratedColumn<int>(
    'day_start_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DayState, int> state =
      GeneratedColumn<int>(
        'state',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DayState>($DayRecordsTable.$converterstate);
  static const VerificationMeta _finalizedAtMeta = const VerificationMeta(
    'finalizedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finalizedAt = GeneratedColumn<DateTime>(
    'finalized_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    packageId,
    dayStartMillis,
    state,
    finalizedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('package_id')) {
      context.handle(
        _packageIdMeta,
        packageId.isAcceptableOrUnknown(data['package_id']!, _packageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packageIdMeta);
    }
    if (data.containsKey('day_start_millis')) {
      context.handle(
        _dayStartMillisMeta,
        dayStartMillis.isAcceptableOrUnknown(
          data['day_start_millis']!,
          _dayStartMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dayStartMillisMeta);
    }
    if (data.containsKey('finalized_at')) {
      context.handle(
        _finalizedAtMeta,
        finalizedAt.isAcceptableOrUnknown(
          data['finalized_at']!,
          _finalizedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_finalizedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {packageId, dayStartMillis};
  @override
  DayRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayRecordRow(
      packageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_id'],
      )!,
      dayStartMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_start_millis'],
      )!,
      state: $DayRecordsTable.$converterstate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}state'],
        )!,
      ),
      finalizedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finalized_at'],
      )!,
    );
  }

  @override
  $DayRecordsTable createAlias(String alias) {
    return $DayRecordsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DayState, int, int> $converterstate =
      const EnumIndexConverter<DayState>(DayState.values);
}

class DayRecordRow extends DataClass implements Insertable<DayRecordRow> {
  final String packageId;

  /// Epoch millis of the local reset-hour boundary that opens the day window.
  final int dayStartMillis;
  final DayState state;
  final DateTime finalizedAt;
  const DayRecordRow({
    required this.packageId,
    required this.dayStartMillis,
    required this.state,
    required this.finalizedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['package_id'] = Variable<String>(packageId);
    map['day_start_millis'] = Variable<int>(dayStartMillis);
    {
      map['state'] = Variable<int>(
        $DayRecordsTable.$converterstate.toSql(state),
      );
    }
    map['finalized_at'] = Variable<DateTime>(finalizedAt);
    return map;
  }

  DayRecordsCompanion toCompanion(bool nullToAbsent) {
    return DayRecordsCompanion(
      packageId: Value(packageId),
      dayStartMillis: Value(dayStartMillis),
      state: Value(state),
      finalizedAt: Value(finalizedAt),
    );
  }

  factory DayRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayRecordRow(
      packageId: serializer.fromJson<String>(json['packageId']),
      dayStartMillis: serializer.fromJson<int>(json['dayStartMillis']),
      state: $DayRecordsTable.$converterstate.fromJson(
        serializer.fromJson<int>(json['state']),
      ),
      finalizedAt: serializer.fromJson<DateTime>(json['finalizedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'packageId': serializer.toJson<String>(packageId),
      'dayStartMillis': serializer.toJson<int>(dayStartMillis),
      'state': serializer.toJson<int>(
        $DayRecordsTable.$converterstate.toJson(state),
      ),
      'finalizedAt': serializer.toJson<DateTime>(finalizedAt),
    };
  }

  DayRecordRow copyWith({
    String? packageId,
    int? dayStartMillis,
    DayState? state,
    DateTime? finalizedAt,
  }) => DayRecordRow(
    packageId: packageId ?? this.packageId,
    dayStartMillis: dayStartMillis ?? this.dayStartMillis,
    state: state ?? this.state,
    finalizedAt: finalizedAt ?? this.finalizedAt,
  );
  DayRecordRow copyWithCompanion(DayRecordsCompanion data) {
    return DayRecordRow(
      packageId: data.packageId.present ? data.packageId.value : this.packageId,
      dayStartMillis: data.dayStartMillis.present
          ? data.dayStartMillis.value
          : this.dayStartMillis,
      state: data.state.present ? data.state.value : this.state,
      finalizedAt: data.finalizedAt.present
          ? data.finalizedAt.value
          : this.finalizedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayRecordRow(')
          ..write('packageId: $packageId, ')
          ..write('dayStartMillis: $dayStartMillis, ')
          ..write('state: $state, ')
          ..write('finalizedAt: $finalizedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(packageId, dayStartMillis, state, finalizedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayRecordRow &&
          other.packageId == this.packageId &&
          other.dayStartMillis == this.dayStartMillis &&
          other.state == this.state &&
          other.finalizedAt == this.finalizedAt);
}

class DayRecordsCompanion extends UpdateCompanion<DayRecordRow> {
  final Value<String> packageId;
  final Value<int> dayStartMillis;
  final Value<DayState> state;
  final Value<DateTime> finalizedAt;
  final Value<int> rowid;
  const DayRecordsCompanion({
    this.packageId = const Value.absent(),
    this.dayStartMillis = const Value.absent(),
    this.state = const Value.absent(),
    this.finalizedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayRecordsCompanion.insert({
    required String packageId,
    required int dayStartMillis,
    required DayState state,
    required DateTime finalizedAt,
    this.rowid = const Value.absent(),
  }) : packageId = Value(packageId),
       dayStartMillis = Value(dayStartMillis),
       state = Value(state),
       finalizedAt = Value(finalizedAt);
  static Insertable<DayRecordRow> custom({
    Expression<String>? packageId,
    Expression<int>? dayStartMillis,
    Expression<int>? state,
    Expression<DateTime>? finalizedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (packageId != null) 'package_id': packageId,
      if (dayStartMillis != null) 'day_start_millis': dayStartMillis,
      if (state != null) 'state': state,
      if (finalizedAt != null) 'finalized_at': finalizedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayRecordsCompanion copyWith({
    Value<String>? packageId,
    Value<int>? dayStartMillis,
    Value<DayState>? state,
    Value<DateTime>? finalizedAt,
    Value<int>? rowid,
  }) {
    return DayRecordsCompanion(
      packageId: packageId ?? this.packageId,
      dayStartMillis: dayStartMillis ?? this.dayStartMillis,
      state: state ?? this.state,
      finalizedAt: finalizedAt ?? this.finalizedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (packageId.present) {
      map['package_id'] = Variable<String>(packageId.value);
    }
    if (dayStartMillis.present) {
      map['day_start_millis'] = Variable<int>(dayStartMillis.value);
    }
    if (state.present) {
      map['state'] = Variable<int>(
        $DayRecordsTable.$converterstate.toSql(state.value),
      );
    }
    if (finalizedAt.present) {
      map['finalized_at'] = Variable<DateTime>(finalizedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayRecordsCompanion(')
          ..write('packageId: $packageId, ')
          ..write('dayStartMillis: $dayStartMillis, ')
          ..write('state: $state, ')
          ..write('finalizedAt: $finalizedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppStreakStatesTable extends AppStreakStates
    with TableInfo<$AppStreakStatesTable, AppStreakStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppStreakStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _packageIdMeta = const VerificationMeta(
    'packageId',
  );
  @override
  late final GeneratedColumn<String> packageId = GeneratedColumn<String>(
    'package_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentStreakMeta = const VerificationMeta(
    'currentStreak',
  );
  @override
  late final GeneratedColumn<int> currentStreak = GeneratedColumn<int>(
    'current_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bestStreakMeta = const VerificationMeta(
    'bestStreak',
  );
  @override
  late final GeneratedColumn<int> bestStreak = GeneratedColumn<int>(
    'best_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lifetimeCleanDaysMeta = const VerificationMeta(
    'lifetimeCleanDays',
  );
  @override
  late final GeneratedColumn<int> lifetimeCleanDays = GeneratedColumn<int>(
    'lifetime_clean_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastFinalizedDayMillisMeta =
      const VerificationMeta('lastFinalizedDayMillis');
  @override
  late final GeneratedColumn<int> lastFinalizedDayMillis = GeneratedColumn<int>(
    'last_finalized_day_millis',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    packageId,
    currentStreak,
    bestStreak,
    lifetimeCleanDays,
    lastFinalizedDayMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_streak_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppStreakStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('package_id')) {
      context.handle(
        _packageIdMeta,
        packageId.isAcceptableOrUnknown(data['package_id']!, _packageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packageIdMeta);
    }
    if (data.containsKey('current_streak')) {
      context.handle(
        _currentStreakMeta,
        currentStreak.isAcceptableOrUnknown(
          data['current_streak']!,
          _currentStreakMeta,
        ),
      );
    }
    if (data.containsKey('best_streak')) {
      context.handle(
        _bestStreakMeta,
        bestStreak.isAcceptableOrUnknown(data['best_streak']!, _bestStreakMeta),
      );
    }
    if (data.containsKey('lifetime_clean_days')) {
      context.handle(
        _lifetimeCleanDaysMeta,
        lifetimeCleanDays.isAcceptableOrUnknown(
          data['lifetime_clean_days']!,
          _lifetimeCleanDaysMeta,
        ),
      );
    }
    if (data.containsKey('last_finalized_day_millis')) {
      context.handle(
        _lastFinalizedDayMillisMeta,
        lastFinalizedDayMillis.isAcceptableOrUnknown(
          data['last_finalized_day_millis']!,
          _lastFinalizedDayMillisMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {packageId};
  @override
  AppStreakStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppStreakStateRow(
      packageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_id'],
      )!,
      currentStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_streak'],
      )!,
      bestStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_streak'],
      )!,
      lifetimeCleanDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lifetime_clean_days'],
      )!,
      lastFinalizedDayMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_finalized_day_millis'],
      ),
    );
  }

  @override
  $AppStreakStatesTable createAlias(String alias) {
    return $AppStreakStatesTable(attachedDatabase, alias);
  }
}

class AppStreakStateRow extends DataClass
    implements Insertable<AppStreakStateRow> {
  final String packageId;
  final int currentStreak;
  final int bestStreak;
  final int lifetimeCleanDays;
  final int? lastFinalizedDayMillis;
  const AppStreakStateRow({
    required this.packageId,
    required this.currentStreak,
    required this.bestStreak,
    required this.lifetimeCleanDays,
    this.lastFinalizedDayMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['package_id'] = Variable<String>(packageId);
    map['current_streak'] = Variable<int>(currentStreak);
    map['best_streak'] = Variable<int>(bestStreak);
    map['lifetime_clean_days'] = Variable<int>(lifetimeCleanDays);
    if (!nullToAbsent || lastFinalizedDayMillis != null) {
      map['last_finalized_day_millis'] = Variable<int>(lastFinalizedDayMillis);
    }
    return map;
  }

  AppStreakStatesCompanion toCompanion(bool nullToAbsent) {
    return AppStreakStatesCompanion(
      packageId: Value(packageId),
      currentStreak: Value(currentStreak),
      bestStreak: Value(bestStreak),
      lifetimeCleanDays: Value(lifetimeCleanDays),
      lastFinalizedDayMillis: lastFinalizedDayMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFinalizedDayMillis),
    );
  }

  factory AppStreakStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppStreakStateRow(
      packageId: serializer.fromJson<String>(json['packageId']),
      currentStreak: serializer.fromJson<int>(json['currentStreak']),
      bestStreak: serializer.fromJson<int>(json['bestStreak']),
      lifetimeCleanDays: serializer.fromJson<int>(json['lifetimeCleanDays']),
      lastFinalizedDayMillis: serializer.fromJson<int?>(
        json['lastFinalizedDayMillis'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'packageId': serializer.toJson<String>(packageId),
      'currentStreak': serializer.toJson<int>(currentStreak),
      'bestStreak': serializer.toJson<int>(bestStreak),
      'lifetimeCleanDays': serializer.toJson<int>(lifetimeCleanDays),
      'lastFinalizedDayMillis': serializer.toJson<int?>(lastFinalizedDayMillis),
    };
  }

  AppStreakStateRow copyWith({
    String? packageId,
    int? currentStreak,
    int? bestStreak,
    int? lifetimeCleanDays,
    Value<int?> lastFinalizedDayMillis = const Value.absent(),
  }) => AppStreakStateRow(
    packageId: packageId ?? this.packageId,
    currentStreak: currentStreak ?? this.currentStreak,
    bestStreak: bestStreak ?? this.bestStreak,
    lifetimeCleanDays: lifetimeCleanDays ?? this.lifetimeCleanDays,
    lastFinalizedDayMillis: lastFinalizedDayMillis.present
        ? lastFinalizedDayMillis.value
        : this.lastFinalizedDayMillis,
  );
  AppStreakStateRow copyWithCompanion(AppStreakStatesCompanion data) {
    return AppStreakStateRow(
      packageId: data.packageId.present ? data.packageId.value : this.packageId,
      currentStreak: data.currentStreak.present
          ? data.currentStreak.value
          : this.currentStreak,
      bestStreak: data.bestStreak.present
          ? data.bestStreak.value
          : this.bestStreak,
      lifetimeCleanDays: data.lifetimeCleanDays.present
          ? data.lifetimeCleanDays.value
          : this.lifetimeCleanDays,
      lastFinalizedDayMillis: data.lastFinalizedDayMillis.present
          ? data.lastFinalizedDayMillis.value
          : this.lastFinalizedDayMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppStreakStateRow(')
          ..write('packageId: $packageId, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('bestStreak: $bestStreak, ')
          ..write('lifetimeCleanDays: $lifetimeCleanDays, ')
          ..write('lastFinalizedDayMillis: $lastFinalizedDayMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    packageId,
    currentStreak,
    bestStreak,
    lifetimeCleanDays,
    lastFinalizedDayMillis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppStreakStateRow &&
          other.packageId == this.packageId &&
          other.currentStreak == this.currentStreak &&
          other.bestStreak == this.bestStreak &&
          other.lifetimeCleanDays == this.lifetimeCleanDays &&
          other.lastFinalizedDayMillis == this.lastFinalizedDayMillis);
}

class AppStreakStatesCompanion extends UpdateCompanion<AppStreakStateRow> {
  final Value<String> packageId;
  final Value<int> currentStreak;
  final Value<int> bestStreak;
  final Value<int> lifetimeCleanDays;
  final Value<int?> lastFinalizedDayMillis;
  final Value<int> rowid;
  const AppStreakStatesCompanion({
    this.packageId = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.bestStreak = const Value.absent(),
    this.lifetimeCleanDays = const Value.absent(),
    this.lastFinalizedDayMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppStreakStatesCompanion.insert({
    required String packageId,
    this.currentStreak = const Value.absent(),
    this.bestStreak = const Value.absent(),
    this.lifetimeCleanDays = const Value.absent(),
    this.lastFinalizedDayMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : packageId = Value(packageId);
  static Insertable<AppStreakStateRow> custom({
    Expression<String>? packageId,
    Expression<int>? currentStreak,
    Expression<int>? bestStreak,
    Expression<int>? lifetimeCleanDays,
    Expression<int>? lastFinalizedDayMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (packageId != null) 'package_id': packageId,
      if (currentStreak != null) 'current_streak': currentStreak,
      if (bestStreak != null) 'best_streak': bestStreak,
      if (lifetimeCleanDays != null) 'lifetime_clean_days': lifetimeCleanDays,
      if (lastFinalizedDayMillis != null)
        'last_finalized_day_millis': lastFinalizedDayMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppStreakStatesCompanion copyWith({
    Value<String>? packageId,
    Value<int>? currentStreak,
    Value<int>? bestStreak,
    Value<int>? lifetimeCleanDays,
    Value<int?>? lastFinalizedDayMillis,
    Value<int>? rowid,
  }) {
    return AppStreakStatesCompanion(
      packageId: packageId ?? this.packageId,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lifetimeCleanDays: lifetimeCleanDays ?? this.lifetimeCleanDays,
      lastFinalizedDayMillis:
          lastFinalizedDayMillis ?? this.lastFinalizedDayMillis,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (packageId.present) {
      map['package_id'] = Variable<String>(packageId.value);
    }
    if (currentStreak.present) {
      map['current_streak'] = Variable<int>(currentStreak.value);
    }
    if (bestStreak.present) {
      map['best_streak'] = Variable<int>(bestStreak.value);
    }
    if (lifetimeCleanDays.present) {
      map['lifetime_clean_days'] = Variable<int>(lifetimeCleanDays.value);
    }
    if (lastFinalizedDayMillis.present) {
      map['last_finalized_day_millis'] = Variable<int>(
        lastFinalizedDayMillis.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppStreakStatesCompanion(')
          ..write('packageId: $packageId, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('bestStreak: $bestStreak, ')
          ..write('lifetimeCleanDays: $lifetimeCleanDays, ')
          ..write('lastFinalizedDayMillis: $lastFinalizedDayMillis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MetaStatesTable extends MetaStates
    with TableInfo<$MetaStatesTable, MetaStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetaStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currentMetaStreakMeta = const VerificationMeta(
    'currentMetaStreak',
  );
  @override
  late final GeneratedColumn<int> currentMetaStreak = GeneratedColumn<int>(
    'current_meta_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bestMetaStreakMeta = const VerificationMeta(
    'bestMetaStreak',
  );
  @override
  late final GeneratedColumn<int> bestMetaStreak = GeneratedColumn<int>(
    'best_meta_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lifetimePerfectDaysMeta =
      const VerificationMeta('lifetimePerfectDays');
  @override
  late final GeneratedColumn<int> lifetimePerfectDays = GeneratedColumn<int>(
    'lifetime_perfect_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    currentMetaStreak,
    bestMetaStreak,
    lifetimePerfectDays,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meta_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetaStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('current_meta_streak')) {
      context.handle(
        _currentMetaStreakMeta,
        currentMetaStreak.isAcceptableOrUnknown(
          data['current_meta_streak']!,
          _currentMetaStreakMeta,
        ),
      );
    }
    if (data.containsKey('best_meta_streak')) {
      context.handle(
        _bestMetaStreakMeta,
        bestMetaStreak.isAcceptableOrUnknown(
          data['best_meta_streak']!,
          _bestMetaStreakMeta,
        ),
      );
    }
    if (data.containsKey('lifetime_perfect_days')) {
      context.handle(
        _lifetimePerfectDaysMeta,
        lifetimePerfectDays.isAcceptableOrUnknown(
          data['lifetime_perfect_days']!,
          _lifetimePerfectDaysMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MetaStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaStateRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      currentMetaStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_meta_streak'],
      )!,
      bestMetaStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_meta_streak'],
      )!,
      lifetimePerfectDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lifetime_perfect_days'],
      )!,
    );
  }

  @override
  $MetaStatesTable createAlias(String alias) {
    return $MetaStatesTable(attachedDatabase, alias);
  }
}

class MetaStateRow extends DataClass implements Insertable<MetaStateRow> {
  final int id;
  final int currentMetaStreak;
  final int bestMetaStreak;
  final int lifetimePerfectDays;
  const MetaStateRow({
    required this.id,
    required this.currentMetaStreak,
    required this.bestMetaStreak,
    required this.lifetimePerfectDays,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['current_meta_streak'] = Variable<int>(currentMetaStreak);
    map['best_meta_streak'] = Variable<int>(bestMetaStreak);
    map['lifetime_perfect_days'] = Variable<int>(lifetimePerfectDays);
    return map;
  }

  MetaStatesCompanion toCompanion(bool nullToAbsent) {
    return MetaStatesCompanion(
      id: Value(id),
      currentMetaStreak: Value(currentMetaStreak),
      bestMetaStreak: Value(bestMetaStreak),
      lifetimePerfectDays: Value(lifetimePerfectDays),
    );
  }

  factory MetaStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaStateRow(
      id: serializer.fromJson<int>(json['id']),
      currentMetaStreak: serializer.fromJson<int>(json['currentMetaStreak']),
      bestMetaStreak: serializer.fromJson<int>(json['bestMetaStreak']),
      lifetimePerfectDays: serializer.fromJson<int>(
        json['lifetimePerfectDays'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'currentMetaStreak': serializer.toJson<int>(currentMetaStreak),
      'bestMetaStreak': serializer.toJson<int>(bestMetaStreak),
      'lifetimePerfectDays': serializer.toJson<int>(lifetimePerfectDays),
    };
  }

  MetaStateRow copyWith({
    int? id,
    int? currentMetaStreak,
    int? bestMetaStreak,
    int? lifetimePerfectDays,
  }) => MetaStateRow(
    id: id ?? this.id,
    currentMetaStreak: currentMetaStreak ?? this.currentMetaStreak,
    bestMetaStreak: bestMetaStreak ?? this.bestMetaStreak,
    lifetimePerfectDays: lifetimePerfectDays ?? this.lifetimePerfectDays,
  );
  MetaStateRow copyWithCompanion(MetaStatesCompanion data) {
    return MetaStateRow(
      id: data.id.present ? data.id.value : this.id,
      currentMetaStreak: data.currentMetaStreak.present
          ? data.currentMetaStreak.value
          : this.currentMetaStreak,
      bestMetaStreak: data.bestMetaStreak.present
          ? data.bestMetaStreak.value
          : this.bestMetaStreak,
      lifetimePerfectDays: data.lifetimePerfectDays.present
          ? data.lifetimePerfectDays.value
          : this.lifetimePerfectDays,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaStateRow(')
          ..write('id: $id, ')
          ..write('currentMetaStreak: $currentMetaStreak, ')
          ..write('bestMetaStreak: $bestMetaStreak, ')
          ..write('lifetimePerfectDays: $lifetimePerfectDays')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, currentMetaStreak, bestMetaStreak, lifetimePerfectDays);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetaStateRow &&
          other.id == this.id &&
          other.currentMetaStreak == this.currentMetaStreak &&
          other.bestMetaStreak == this.bestMetaStreak &&
          other.lifetimePerfectDays == this.lifetimePerfectDays);
}

class MetaStatesCompanion extends UpdateCompanion<MetaStateRow> {
  final Value<int> id;
  final Value<int> currentMetaStreak;
  final Value<int> bestMetaStreak;
  final Value<int> lifetimePerfectDays;
  const MetaStatesCompanion({
    this.id = const Value.absent(),
    this.currentMetaStreak = const Value.absent(),
    this.bestMetaStreak = const Value.absent(),
    this.lifetimePerfectDays = const Value.absent(),
  });
  MetaStatesCompanion.insert({
    this.id = const Value.absent(),
    this.currentMetaStreak = const Value.absent(),
    this.bestMetaStreak = const Value.absent(),
    this.lifetimePerfectDays = const Value.absent(),
  });
  static Insertable<MetaStateRow> custom({
    Expression<int>? id,
    Expression<int>? currentMetaStreak,
    Expression<int>? bestMetaStreak,
    Expression<int>? lifetimePerfectDays,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currentMetaStreak != null) 'current_meta_streak': currentMetaStreak,
      if (bestMetaStreak != null) 'best_meta_streak': bestMetaStreak,
      if (lifetimePerfectDays != null)
        'lifetime_perfect_days': lifetimePerfectDays,
    });
  }

  MetaStatesCompanion copyWith({
    Value<int>? id,
    Value<int>? currentMetaStreak,
    Value<int>? bestMetaStreak,
    Value<int>? lifetimePerfectDays,
  }) {
    return MetaStatesCompanion(
      id: id ?? this.id,
      currentMetaStreak: currentMetaStreak ?? this.currentMetaStreak,
      bestMetaStreak: bestMetaStreak ?? this.bestMetaStreak,
      lifetimePerfectDays: lifetimePerfectDays ?? this.lifetimePerfectDays,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (currentMetaStreak.present) {
      map['current_meta_streak'] = Variable<int>(currentMetaStreak.value);
    }
    if (bestMetaStreak.present) {
      map['best_meta_streak'] = Variable<int>(bestMetaStreak.value);
    }
    if (lifetimePerfectDays.present) {
      map['lifetime_perfect_days'] = Variable<int>(lifetimePerfectDays.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetaStatesCompanion(')
          ..write('id: $id, ')
          ..write('currentMetaStreak: $currentMetaStreak, ')
          ..write('bestMetaStreak: $bestMetaStreak, ')
          ..write('lifetimePerfectDays: $lifetimePerfectDays')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dayResetHourMeta = const VerificationMeta(
    'dayResetHour',
  );
  @override
  late final GeneratedColumn<int> dayResetHour = GeneratedColumn<int>(
    'day_reset_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
  );
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
    'notifications_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notifications_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _dailySummaryMinutesMeta =
      const VerificationMeta('dailySummaryMinutes');
  @override
  late final GeneratedColumn<int> dailySummaryMinutes = GeneratedColumn<int>(
    'daily_summary_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(540),
  );
  static const VerificationMeta _milestonesEnabledMeta = const VerificationMeta(
    'milestonesEnabled',
  );
  @override
  late final GeneratedColumn<bool> milestonesEnabled = GeneratedColumn<bool>(
    'milestones_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("milestones_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _analyticsOptInMeta = const VerificationMeta(
    'analyticsOptIn',
  );
  @override
  late final GeneratedColumn<bool> analyticsOptIn = GeneratedColumn<bool>(
    'analytics_opt_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("analytics_opt_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _onboardingCompleteMeta =
      const VerificationMeta('onboardingComplete');
  @override
  late final GeneratedColumn<bool> onboardingComplete = GeneratedColumn<bool>(
    'onboarding_complete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_complete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _speedBumpEnabledMeta = const VerificationMeta(
    'speedBumpEnabled',
  );
  @override
  late final GeneratedColumn<bool> speedBumpEnabled = GeneratedColumn<bool>(
    'speed_bump_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("speed_bump_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _speedBumpEnabledAtMillisMeta =
      const VerificationMeta('speedBumpEnabledAtMillis');
  @override
  late final GeneratedColumn<int> speedBumpEnabledAtMillis =
      GeneratedColumn<int>(
        'speed_bump_enabled_at_millis',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dayResetHour,
    notificationsEnabled,
    dailySummaryMinutes,
    milestonesEnabled,
    analyticsOptIn,
    onboardingComplete,
    speedBumpEnabled,
    speedBumpEnabledAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day_reset_hour')) {
      context.handle(
        _dayResetHourMeta,
        dayResetHour.isAcceptableOrUnknown(
          data['day_reset_hour']!,
          _dayResetHourMeta,
        ),
      );
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
        _notificationsEnabledMeta,
        notificationsEnabled.isAcceptableOrUnknown(
          data['notifications_enabled']!,
          _notificationsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('daily_summary_minutes')) {
      context.handle(
        _dailySummaryMinutesMeta,
        dailySummaryMinutes.isAcceptableOrUnknown(
          data['daily_summary_minutes']!,
          _dailySummaryMinutesMeta,
        ),
      );
    }
    if (data.containsKey('milestones_enabled')) {
      context.handle(
        _milestonesEnabledMeta,
        milestonesEnabled.isAcceptableOrUnknown(
          data['milestones_enabled']!,
          _milestonesEnabledMeta,
        ),
      );
    }
    if (data.containsKey('analytics_opt_in')) {
      context.handle(
        _analyticsOptInMeta,
        analyticsOptIn.isAcceptableOrUnknown(
          data['analytics_opt_in']!,
          _analyticsOptInMeta,
        ),
      );
    }
    if (data.containsKey('onboarding_complete')) {
      context.handle(
        _onboardingCompleteMeta,
        onboardingComplete.isAcceptableOrUnknown(
          data['onboarding_complete']!,
          _onboardingCompleteMeta,
        ),
      );
    }
    if (data.containsKey('speed_bump_enabled')) {
      context.handle(
        _speedBumpEnabledMeta,
        speedBumpEnabled.isAcceptableOrUnknown(
          data['speed_bump_enabled']!,
          _speedBumpEnabledMeta,
        ),
      );
    }
    if (data.containsKey('speed_bump_enabled_at_millis')) {
      context.handle(
        _speedBumpEnabledAtMillisMeta,
        speedBumpEnabledAtMillis.isAcceptableOrUnknown(
          data['speed_bump_enabled_at_millis']!,
          _speedBumpEnabledAtMillisMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dayResetHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_reset_hour'],
      )!,
      notificationsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifications_enabled'],
      )!,
      dailySummaryMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_summary_minutes'],
      )!,
      milestonesEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}milestones_enabled'],
      )!,
      analyticsOptIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}analytics_opt_in'],
      )!,
      onboardingComplete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_complete'],
      )!,
      speedBumpEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}speed_bump_enabled'],
      )!,
      speedBumpEnabledAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}speed_bump_enabled_at_millis'],
      ),
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingsRow extends DataClass implements Insertable<AppSettingsRow> {
  final int id;
  final int dayResetHour;
  final bool notificationsEnabled;
  final int dailySummaryMinutes;
  final bool milestonesEnabled;
  final bool analyticsOptIn;

  /// True once the first-run flow (welcome → permission → pick → all set) is done.
  final bool onboardingComplete;

  /// True when the (post-v1) intervention speed bump is on. Default off: it is an
  /// explicit opt-in that also needs the overlay permission.
  final bool speedBumpEnabled;

  /// Epoch millis of the first-ever speed-bump enable, set once and never cleared.
  /// Days whose window ends before this stay on the legacy verdict path; days at or
  /// after it use the interception-aware path. Null until first enabled.
  final int? speedBumpEnabledAtMillis;
  const AppSettingsRow({
    required this.id,
    required this.dayResetHour,
    required this.notificationsEnabled,
    required this.dailySummaryMinutes,
    required this.milestonesEnabled,
    required this.analyticsOptIn,
    required this.onboardingComplete,
    required this.speedBumpEnabled,
    this.speedBumpEnabledAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day_reset_hour'] = Variable<int>(dayResetHour);
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    map['daily_summary_minutes'] = Variable<int>(dailySummaryMinutes);
    map['milestones_enabled'] = Variable<bool>(milestonesEnabled);
    map['analytics_opt_in'] = Variable<bool>(analyticsOptIn);
    map['onboarding_complete'] = Variable<bool>(onboardingComplete);
    map['speed_bump_enabled'] = Variable<bool>(speedBumpEnabled);
    if (!nullToAbsent || speedBumpEnabledAtMillis != null) {
      map['speed_bump_enabled_at_millis'] = Variable<int>(
        speedBumpEnabledAtMillis,
      );
    }
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      dayResetHour: Value(dayResetHour),
      notificationsEnabled: Value(notificationsEnabled),
      dailySummaryMinutes: Value(dailySummaryMinutes),
      milestonesEnabled: Value(milestonesEnabled),
      analyticsOptIn: Value(analyticsOptIn),
      onboardingComplete: Value(onboardingComplete),
      speedBumpEnabled: Value(speedBumpEnabled),
      speedBumpEnabledAtMillis: speedBumpEnabledAtMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(speedBumpEnabledAtMillis),
    );
  }

  factory AppSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsRow(
      id: serializer.fromJson<int>(json['id']),
      dayResetHour: serializer.fromJson<int>(json['dayResetHour']),
      notificationsEnabled: serializer.fromJson<bool>(
        json['notificationsEnabled'],
      ),
      dailySummaryMinutes: serializer.fromJson<int>(
        json['dailySummaryMinutes'],
      ),
      milestonesEnabled: serializer.fromJson<bool>(json['milestonesEnabled']),
      analyticsOptIn: serializer.fromJson<bool>(json['analyticsOptIn']),
      onboardingComplete: serializer.fromJson<bool>(json['onboardingComplete']),
      speedBumpEnabled: serializer.fromJson<bool>(json['speedBumpEnabled']),
      speedBumpEnabledAtMillis: serializer.fromJson<int?>(
        json['speedBumpEnabledAtMillis'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dayResetHour': serializer.toJson<int>(dayResetHour),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'dailySummaryMinutes': serializer.toJson<int>(dailySummaryMinutes),
      'milestonesEnabled': serializer.toJson<bool>(milestonesEnabled),
      'analyticsOptIn': serializer.toJson<bool>(analyticsOptIn),
      'onboardingComplete': serializer.toJson<bool>(onboardingComplete),
      'speedBumpEnabled': serializer.toJson<bool>(speedBumpEnabled),
      'speedBumpEnabledAtMillis': serializer.toJson<int?>(
        speedBumpEnabledAtMillis,
      ),
    };
  }

  AppSettingsRow copyWith({
    int? id,
    int? dayResetHour,
    bool? notificationsEnabled,
    int? dailySummaryMinutes,
    bool? milestonesEnabled,
    bool? analyticsOptIn,
    bool? onboardingComplete,
    bool? speedBumpEnabled,
    Value<int?> speedBumpEnabledAtMillis = const Value.absent(),
  }) => AppSettingsRow(
    id: id ?? this.id,
    dayResetHour: dayResetHour ?? this.dayResetHour,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    dailySummaryMinutes: dailySummaryMinutes ?? this.dailySummaryMinutes,
    milestonesEnabled: milestonesEnabled ?? this.milestonesEnabled,
    analyticsOptIn: analyticsOptIn ?? this.analyticsOptIn,
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    speedBumpEnabled: speedBumpEnabled ?? this.speedBumpEnabled,
    speedBumpEnabledAtMillis: speedBumpEnabledAtMillis.present
        ? speedBumpEnabledAtMillis.value
        : this.speedBumpEnabledAtMillis,
  );
  AppSettingsRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      dayResetHour: data.dayResetHour.present
          ? data.dayResetHour.value
          : this.dayResetHour,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
      dailySummaryMinutes: data.dailySummaryMinutes.present
          ? data.dailySummaryMinutes.value
          : this.dailySummaryMinutes,
      milestonesEnabled: data.milestonesEnabled.present
          ? data.milestonesEnabled.value
          : this.milestonesEnabled,
      analyticsOptIn: data.analyticsOptIn.present
          ? data.analyticsOptIn.value
          : this.analyticsOptIn,
      onboardingComplete: data.onboardingComplete.present
          ? data.onboardingComplete.value
          : this.onboardingComplete,
      speedBumpEnabled: data.speedBumpEnabled.present
          ? data.speedBumpEnabled.value
          : this.speedBumpEnabled,
      speedBumpEnabledAtMillis: data.speedBumpEnabledAtMillis.present
          ? data.speedBumpEnabledAtMillis.value
          : this.speedBumpEnabledAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsRow(')
          ..write('id: $id, ')
          ..write('dayResetHour: $dayResetHour, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('dailySummaryMinutes: $dailySummaryMinutes, ')
          ..write('milestonesEnabled: $milestonesEnabled, ')
          ..write('analyticsOptIn: $analyticsOptIn, ')
          ..write('onboardingComplete: $onboardingComplete, ')
          ..write('speedBumpEnabled: $speedBumpEnabled, ')
          ..write('speedBumpEnabledAtMillis: $speedBumpEnabledAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dayResetHour,
    notificationsEnabled,
    dailySummaryMinutes,
    milestonesEnabled,
    analyticsOptIn,
    onboardingComplete,
    speedBumpEnabled,
    speedBumpEnabledAtMillis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsRow &&
          other.id == this.id &&
          other.dayResetHour == this.dayResetHour &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.dailySummaryMinutes == this.dailySummaryMinutes &&
          other.milestonesEnabled == this.milestonesEnabled &&
          other.analyticsOptIn == this.analyticsOptIn &&
          other.onboardingComplete == this.onboardingComplete &&
          other.speedBumpEnabled == this.speedBumpEnabled &&
          other.speedBumpEnabledAtMillis == this.speedBumpEnabledAtMillis);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingsRow> {
  final Value<int> id;
  final Value<int> dayResetHour;
  final Value<bool> notificationsEnabled;
  final Value<int> dailySummaryMinutes;
  final Value<bool> milestonesEnabled;
  final Value<bool> analyticsOptIn;
  final Value<bool> onboardingComplete;
  final Value<bool> speedBumpEnabled;
  final Value<int?> speedBumpEnabledAtMillis;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.dayResetHour = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.dailySummaryMinutes = const Value.absent(),
    this.milestonesEnabled = const Value.absent(),
    this.analyticsOptIn = const Value.absent(),
    this.onboardingComplete = const Value.absent(),
    this.speedBumpEnabled = const Value.absent(),
    this.speedBumpEnabledAtMillis = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.dayResetHour = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.dailySummaryMinutes = const Value.absent(),
    this.milestonesEnabled = const Value.absent(),
    this.analyticsOptIn = const Value.absent(),
    this.onboardingComplete = const Value.absent(),
    this.speedBumpEnabled = const Value.absent(),
    this.speedBumpEnabledAtMillis = const Value.absent(),
  });
  static Insertable<AppSettingsRow> custom({
    Expression<int>? id,
    Expression<int>? dayResetHour,
    Expression<bool>? notificationsEnabled,
    Expression<int>? dailySummaryMinutes,
    Expression<bool>? milestonesEnabled,
    Expression<bool>? analyticsOptIn,
    Expression<bool>? onboardingComplete,
    Expression<bool>? speedBumpEnabled,
    Expression<int>? speedBumpEnabledAtMillis,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayResetHour != null) 'day_reset_hour': dayResetHour,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (dailySummaryMinutes != null)
        'daily_summary_minutes': dailySummaryMinutes,
      if (milestonesEnabled != null) 'milestones_enabled': milestonesEnabled,
      if (analyticsOptIn != null) 'analytics_opt_in': analyticsOptIn,
      if (onboardingComplete != null) 'onboarding_complete': onboardingComplete,
      if (speedBumpEnabled != null) 'speed_bump_enabled': speedBumpEnabled,
      if (speedBumpEnabledAtMillis != null)
        'speed_bump_enabled_at_millis': speedBumpEnabledAtMillis,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<int>? dayResetHour,
    Value<bool>? notificationsEnabled,
    Value<int>? dailySummaryMinutes,
    Value<bool>? milestonesEnabled,
    Value<bool>? analyticsOptIn,
    Value<bool>? onboardingComplete,
    Value<bool>? speedBumpEnabled,
    Value<int?>? speedBumpEnabledAtMillis,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      dayResetHour: dayResetHour ?? this.dayResetHour,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailySummaryMinutes: dailySummaryMinutes ?? this.dailySummaryMinutes,
      milestonesEnabled: milestonesEnabled ?? this.milestonesEnabled,
      analyticsOptIn: analyticsOptIn ?? this.analyticsOptIn,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      speedBumpEnabled: speedBumpEnabled ?? this.speedBumpEnabled,
      speedBumpEnabledAtMillis:
          speedBumpEnabledAtMillis ?? this.speedBumpEnabledAtMillis,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dayResetHour.present) {
      map['day_reset_hour'] = Variable<int>(dayResetHour.value);
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    if (dailySummaryMinutes.present) {
      map['daily_summary_minutes'] = Variable<int>(dailySummaryMinutes.value);
    }
    if (milestonesEnabled.present) {
      map['milestones_enabled'] = Variable<bool>(milestonesEnabled.value);
    }
    if (analyticsOptIn.present) {
      map['analytics_opt_in'] = Variable<bool>(analyticsOptIn.value);
    }
    if (onboardingComplete.present) {
      map['onboarding_complete'] = Variable<bool>(onboardingComplete.value);
    }
    if (speedBumpEnabled.present) {
      map['speed_bump_enabled'] = Variable<bool>(speedBumpEnabled.value);
    }
    if (speedBumpEnabledAtMillis.present) {
      map['speed_bump_enabled_at_millis'] = Variable<int>(
        speedBumpEnabledAtMillis.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('dayResetHour: $dayResetHour, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('dailySummaryMinutes: $dailySummaryMinutes, ')
          ..write('milestonesEnabled: $milestonesEnabled, ')
          ..write('analyticsOptIn: $analyticsOptIn, ')
          ..write('onboardingComplete: $onboardingComplete, ')
          ..write('speedBumpEnabled: $speedBumpEnabled, ')
          ..write('speedBumpEnabledAtMillis: $speedBumpEnabledAtMillis')
          ..write(')'))
        .toString();
  }
}

class $InterceptionEventsTable extends InterceptionEvents
    with TableInfo<$InterceptionEventsTable, InterceptionEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InterceptionEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _packageIdMeta = const VerificationMeta(
    'packageId',
  );
  @override
  late final GeneratedColumn<String> packageId = GeneratedColumn<String>(
    'package_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foregroundAtMillisMeta =
      const VerificationMeta('foregroundAtMillis');
  @override
  late final GeneratedColumn<int> foregroundAtMillis = GeneratedColumn<int>(
    'foreground_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayStartMillisMeta = const VerificationMeta(
    'dayStartMillis',
  );
  @override
  late final GeneratedColumn<int> dayStartMillis = GeneratedColumn<int>(
    'day_start_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<InterceptionOutcome, int>
  outcome =
      GeneratedColumn<int>(
        'outcome',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<InterceptionOutcome>(
        $InterceptionEventsTable.$converteroutcome,
      );
  static const VerificationMeta _recordedAtMillisMeta = const VerificationMeta(
    'recordedAtMillis',
  );
  @override
  late final GeneratedColumn<int> recordedAtMillis = GeneratedColumn<int>(
    'recorded_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    packageId,
    foregroundAtMillis,
    dayStartMillis,
    outcome,
    recordedAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'interception_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<InterceptionEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('package_id')) {
      context.handle(
        _packageIdMeta,
        packageId.isAcceptableOrUnknown(data['package_id']!, _packageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packageIdMeta);
    }
    if (data.containsKey('foreground_at_millis')) {
      context.handle(
        _foregroundAtMillisMeta,
        foregroundAtMillis.isAcceptableOrUnknown(
          data['foreground_at_millis']!,
          _foregroundAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_foregroundAtMillisMeta);
    }
    if (data.containsKey('day_start_millis')) {
      context.handle(
        _dayStartMillisMeta,
        dayStartMillis.isAcceptableOrUnknown(
          data['day_start_millis']!,
          _dayStartMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dayStartMillisMeta);
    }
    if (data.containsKey('recorded_at_millis')) {
      context.handle(
        _recordedAtMillisMeta,
        recordedAtMillis.isAcceptableOrUnknown(
          data['recorded_at_millis']!,
          _recordedAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMillisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {packageId, foregroundAtMillis};
  @override
  InterceptionEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InterceptionEventRow(
      packageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_id'],
      )!,
      foregroundAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}foreground_at_millis'],
      )!,
      dayStartMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_start_millis'],
      )!,
      outcome: $InterceptionEventsTable.$converteroutcome.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}outcome'],
        )!,
      ),
      recordedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recorded_at_millis'],
      )!,
    );
  }

  @override
  $InterceptionEventsTable createAlias(String alias) {
    return $InterceptionEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<InterceptionOutcome, int, int> $converteroutcome =
      const EnumIndexConverter<InterceptionOutcome>(InterceptionOutcome.values);
}

class InterceptionEventRow extends DataClass
    implements Insertable<InterceptionEventRow> {
  final String packageId;
  final int foregroundAtMillis;
  final int dayStartMillis;
  final InterceptionOutcome outcome;
  final int recordedAtMillis;
  const InterceptionEventRow({
    required this.packageId,
    required this.foregroundAtMillis,
    required this.dayStartMillis,
    required this.outcome,
    required this.recordedAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['package_id'] = Variable<String>(packageId);
    map['foreground_at_millis'] = Variable<int>(foregroundAtMillis);
    map['day_start_millis'] = Variable<int>(dayStartMillis);
    {
      map['outcome'] = Variable<int>(
        $InterceptionEventsTable.$converteroutcome.toSql(outcome),
      );
    }
    map['recorded_at_millis'] = Variable<int>(recordedAtMillis);
    return map;
  }

  InterceptionEventsCompanion toCompanion(bool nullToAbsent) {
    return InterceptionEventsCompanion(
      packageId: Value(packageId),
      foregroundAtMillis: Value(foregroundAtMillis),
      dayStartMillis: Value(dayStartMillis),
      outcome: Value(outcome),
      recordedAtMillis: Value(recordedAtMillis),
    );
  }

  factory InterceptionEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InterceptionEventRow(
      packageId: serializer.fromJson<String>(json['packageId']),
      foregroundAtMillis: serializer.fromJson<int>(json['foregroundAtMillis']),
      dayStartMillis: serializer.fromJson<int>(json['dayStartMillis']),
      outcome: $InterceptionEventsTable.$converteroutcome.fromJson(
        serializer.fromJson<int>(json['outcome']),
      ),
      recordedAtMillis: serializer.fromJson<int>(json['recordedAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'packageId': serializer.toJson<String>(packageId),
      'foregroundAtMillis': serializer.toJson<int>(foregroundAtMillis),
      'dayStartMillis': serializer.toJson<int>(dayStartMillis),
      'outcome': serializer.toJson<int>(
        $InterceptionEventsTable.$converteroutcome.toJson(outcome),
      ),
      'recordedAtMillis': serializer.toJson<int>(recordedAtMillis),
    };
  }

  InterceptionEventRow copyWith({
    String? packageId,
    int? foregroundAtMillis,
    int? dayStartMillis,
    InterceptionOutcome? outcome,
    int? recordedAtMillis,
  }) => InterceptionEventRow(
    packageId: packageId ?? this.packageId,
    foregroundAtMillis: foregroundAtMillis ?? this.foregroundAtMillis,
    dayStartMillis: dayStartMillis ?? this.dayStartMillis,
    outcome: outcome ?? this.outcome,
    recordedAtMillis: recordedAtMillis ?? this.recordedAtMillis,
  );
  InterceptionEventRow copyWithCompanion(InterceptionEventsCompanion data) {
    return InterceptionEventRow(
      packageId: data.packageId.present ? data.packageId.value : this.packageId,
      foregroundAtMillis: data.foregroundAtMillis.present
          ? data.foregroundAtMillis.value
          : this.foregroundAtMillis,
      dayStartMillis: data.dayStartMillis.present
          ? data.dayStartMillis.value
          : this.dayStartMillis,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      recordedAtMillis: data.recordedAtMillis.present
          ? data.recordedAtMillis.value
          : this.recordedAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InterceptionEventRow(')
          ..write('packageId: $packageId, ')
          ..write('foregroundAtMillis: $foregroundAtMillis, ')
          ..write('dayStartMillis: $dayStartMillis, ')
          ..write('outcome: $outcome, ')
          ..write('recordedAtMillis: $recordedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    packageId,
    foregroundAtMillis,
    dayStartMillis,
    outcome,
    recordedAtMillis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InterceptionEventRow &&
          other.packageId == this.packageId &&
          other.foregroundAtMillis == this.foregroundAtMillis &&
          other.dayStartMillis == this.dayStartMillis &&
          other.outcome == this.outcome &&
          other.recordedAtMillis == this.recordedAtMillis);
}

class InterceptionEventsCompanion
    extends UpdateCompanion<InterceptionEventRow> {
  final Value<String> packageId;
  final Value<int> foregroundAtMillis;
  final Value<int> dayStartMillis;
  final Value<InterceptionOutcome> outcome;
  final Value<int> recordedAtMillis;
  final Value<int> rowid;
  const InterceptionEventsCompanion({
    this.packageId = const Value.absent(),
    this.foregroundAtMillis = const Value.absent(),
    this.dayStartMillis = const Value.absent(),
    this.outcome = const Value.absent(),
    this.recordedAtMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InterceptionEventsCompanion.insert({
    required String packageId,
    required int foregroundAtMillis,
    required int dayStartMillis,
    required InterceptionOutcome outcome,
    required int recordedAtMillis,
    this.rowid = const Value.absent(),
  }) : packageId = Value(packageId),
       foregroundAtMillis = Value(foregroundAtMillis),
       dayStartMillis = Value(dayStartMillis),
       outcome = Value(outcome),
       recordedAtMillis = Value(recordedAtMillis);
  static Insertable<InterceptionEventRow> custom({
    Expression<String>? packageId,
    Expression<int>? foregroundAtMillis,
    Expression<int>? dayStartMillis,
    Expression<int>? outcome,
    Expression<int>? recordedAtMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (packageId != null) 'package_id': packageId,
      if (foregroundAtMillis != null)
        'foreground_at_millis': foregroundAtMillis,
      if (dayStartMillis != null) 'day_start_millis': dayStartMillis,
      if (outcome != null) 'outcome': outcome,
      if (recordedAtMillis != null) 'recorded_at_millis': recordedAtMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InterceptionEventsCompanion copyWith({
    Value<String>? packageId,
    Value<int>? foregroundAtMillis,
    Value<int>? dayStartMillis,
    Value<InterceptionOutcome>? outcome,
    Value<int>? recordedAtMillis,
    Value<int>? rowid,
  }) {
    return InterceptionEventsCompanion(
      packageId: packageId ?? this.packageId,
      foregroundAtMillis: foregroundAtMillis ?? this.foregroundAtMillis,
      dayStartMillis: dayStartMillis ?? this.dayStartMillis,
      outcome: outcome ?? this.outcome,
      recordedAtMillis: recordedAtMillis ?? this.recordedAtMillis,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (packageId.present) {
      map['package_id'] = Variable<String>(packageId.value);
    }
    if (foregroundAtMillis.present) {
      map['foreground_at_millis'] = Variable<int>(foregroundAtMillis.value);
    }
    if (dayStartMillis.present) {
      map['day_start_millis'] = Variable<int>(dayStartMillis.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<int>(
        $InterceptionEventsTable.$converteroutcome.toSql(outcome.value),
      );
    }
    if (recordedAtMillis.present) {
      map['recorded_at_millis'] = Variable<int>(recordedAtMillis.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InterceptionEventsCompanion(')
          ..write('packageId: $packageId, ')
          ..write('foregroundAtMillis: $foregroundAtMillis, ')
          ..write('dayStartMillis: $dayStartMillis, ')
          ..write('outcome: $outcome, ')
          ..write('recordedAtMillis: $recordedAtMillis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$CairnDatabase extends GeneratedDatabase {
  _$CairnDatabase(QueryExecutor e) : super(e);
  $CairnDatabaseManager get managers => $CairnDatabaseManager(this);
  late final $TrackedAppsTable trackedApps = $TrackedAppsTable(this);
  late final $DayRecordsTable dayRecords = $DayRecordsTable(this);
  late final $AppStreakStatesTable appStreakStates = $AppStreakStatesTable(
    this,
  );
  late final $MetaStatesTable metaStates = $MetaStatesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $InterceptionEventsTable interceptionEvents =
      $InterceptionEventsTable(this);
  late final TrackedAppsDao trackedAppsDao = TrackedAppsDao(
    this as CairnDatabase,
  );
  late final DayRecordsDao dayRecordsDao = DayRecordsDao(this as CairnDatabase);
  late final StreakCacheDao streakCacheDao = StreakCacheDao(
    this as CairnDatabase,
  );
  late final SettingsDao settingsDao = SettingsDao(this as CairnDatabase);
  late final InterceptionDao interceptionDao = InterceptionDao(
    this as CairnDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    trackedApps,
    dayRecords,
    appStreakStates,
    metaStates,
    appSettings,
    interceptionEvents,
  ];
}

typedef $$TrackedAppsTableCreateCompanionBuilder =
    TrackedAppsCompanion Function({
      required String packageId,
      required String displayName,
      required DateTime addedAt,
      required AppStatus status,
      Value<DateTime?> freedAt,
      Value<int> rowid,
    });
typedef $$TrackedAppsTableUpdateCompanionBuilder =
    TrackedAppsCompanion Function({
      Value<String> packageId,
      Value<String> displayName,
      Value<DateTime> addedAt,
      Value<AppStatus> status,
      Value<DateTime?> freedAt,
      Value<int> rowid,
    });

class $$TrackedAppsTableFilterComposer
    extends Composer<_$CairnDatabase, $TrackedAppsTable> {
  $$TrackedAppsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get packageId => $composableBuilder(
    column: $table.packageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AppStatus, AppStatus, int> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get freedAt => $composableBuilder(
    column: $table.freedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrackedAppsTableOrderingComposer
    extends Composer<_$CairnDatabase, $TrackedAppsTable> {
  $$TrackedAppsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get packageId => $composableBuilder(
    column: $table.packageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get freedAt => $composableBuilder(
    column: $table.freedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrackedAppsTableAnnotationComposer
    extends Composer<_$CairnDatabase, $TrackedAppsTable> {
  $$TrackedAppsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get packageId =>
      $composableBuilder(column: $table.packageId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AppStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get freedAt =>
      $composableBuilder(column: $table.freedAt, builder: (column) => column);
}

class $$TrackedAppsTableTableManager
    extends
        RootTableManager<
          _$CairnDatabase,
          $TrackedAppsTable,
          TrackedAppRow,
          $$TrackedAppsTableFilterComposer,
          $$TrackedAppsTableOrderingComposer,
          $$TrackedAppsTableAnnotationComposer,
          $$TrackedAppsTableCreateCompanionBuilder,
          $$TrackedAppsTableUpdateCompanionBuilder,
          (
            TrackedAppRow,
            BaseReferences<_$CairnDatabase, $TrackedAppsTable, TrackedAppRow>,
          ),
          TrackedAppRow,
          PrefetchHooks Function()
        > {
  $$TrackedAppsTableTableManager(_$CairnDatabase db, $TrackedAppsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackedAppsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackedAppsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackedAppsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> packageId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<AppStatus> status = const Value.absent(),
                Value<DateTime?> freedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackedAppsCompanion(
                packageId: packageId,
                displayName: displayName,
                addedAt: addedAt,
                status: status,
                freedAt: freedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String packageId,
                required String displayName,
                required DateTime addedAt,
                required AppStatus status,
                Value<DateTime?> freedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackedAppsCompanion.insert(
                packageId: packageId,
                displayName: displayName,
                addedAt: addedAt,
                status: status,
                freedAt: freedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrackedAppsTableProcessedTableManager =
    ProcessedTableManager<
      _$CairnDatabase,
      $TrackedAppsTable,
      TrackedAppRow,
      $$TrackedAppsTableFilterComposer,
      $$TrackedAppsTableOrderingComposer,
      $$TrackedAppsTableAnnotationComposer,
      $$TrackedAppsTableCreateCompanionBuilder,
      $$TrackedAppsTableUpdateCompanionBuilder,
      (
        TrackedAppRow,
        BaseReferences<_$CairnDatabase, $TrackedAppsTable, TrackedAppRow>,
      ),
      TrackedAppRow,
      PrefetchHooks Function()
    >;
typedef $$DayRecordsTableCreateCompanionBuilder =
    DayRecordsCompanion Function({
      required String packageId,
      required int dayStartMillis,
      required DayState state,
      required DateTime finalizedAt,
      Value<int> rowid,
    });
typedef $$DayRecordsTableUpdateCompanionBuilder =
    DayRecordsCompanion Function({
      Value<String> packageId,
      Value<int> dayStartMillis,
      Value<DayState> state,
      Value<DateTime> finalizedAt,
      Value<int> rowid,
    });

class $$DayRecordsTableFilterComposer
    extends Composer<_$CairnDatabase, $DayRecordsTable> {
  $$DayRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get packageId => $composableBuilder(
    column: $table.packageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayStartMillis => $composableBuilder(
    column: $table.dayStartMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DayState, DayState, int> get state =>
      $composableBuilder(
        column: $table.state,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get finalizedAt => $composableBuilder(
    column: $table.finalizedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DayRecordsTableOrderingComposer
    extends Composer<_$CairnDatabase, $DayRecordsTable> {
  $$DayRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get packageId => $composableBuilder(
    column: $table.packageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayStartMillis => $composableBuilder(
    column: $table.dayStartMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finalizedAt => $composableBuilder(
    column: $table.finalizedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayRecordsTableAnnotationComposer
    extends Composer<_$CairnDatabase, $DayRecordsTable> {
  $$DayRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get packageId =>
      $composableBuilder(column: $table.packageId, builder: (column) => column);

  GeneratedColumn<int> get dayStartMillis => $composableBuilder(
    column: $table.dayStartMillis,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DayState, int> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get finalizedAt => $composableBuilder(
    column: $table.finalizedAt,
    builder: (column) => column,
  );
}

class $$DayRecordsTableTableManager
    extends
        RootTableManager<
          _$CairnDatabase,
          $DayRecordsTable,
          DayRecordRow,
          $$DayRecordsTableFilterComposer,
          $$DayRecordsTableOrderingComposer,
          $$DayRecordsTableAnnotationComposer,
          $$DayRecordsTableCreateCompanionBuilder,
          $$DayRecordsTableUpdateCompanionBuilder,
          (
            DayRecordRow,
            BaseReferences<_$CairnDatabase, $DayRecordsTable, DayRecordRow>,
          ),
          DayRecordRow,
          PrefetchHooks Function()
        > {
  $$DayRecordsTableTableManager(_$CairnDatabase db, $DayRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> packageId = const Value.absent(),
                Value<int> dayStartMillis = const Value.absent(),
                Value<DayState> state = const Value.absent(),
                Value<DateTime> finalizedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayRecordsCompanion(
                packageId: packageId,
                dayStartMillis: dayStartMillis,
                state: state,
                finalizedAt: finalizedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String packageId,
                required int dayStartMillis,
                required DayState state,
                required DateTime finalizedAt,
                Value<int> rowid = const Value.absent(),
              }) => DayRecordsCompanion.insert(
                packageId: packageId,
                dayStartMillis: dayStartMillis,
                state: state,
                finalizedAt: finalizedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$CairnDatabase,
      $DayRecordsTable,
      DayRecordRow,
      $$DayRecordsTableFilterComposer,
      $$DayRecordsTableOrderingComposer,
      $$DayRecordsTableAnnotationComposer,
      $$DayRecordsTableCreateCompanionBuilder,
      $$DayRecordsTableUpdateCompanionBuilder,
      (
        DayRecordRow,
        BaseReferences<_$CairnDatabase, $DayRecordsTable, DayRecordRow>,
      ),
      DayRecordRow,
      PrefetchHooks Function()
    >;
typedef $$AppStreakStatesTableCreateCompanionBuilder =
    AppStreakStatesCompanion Function({
      required String packageId,
      Value<int> currentStreak,
      Value<int> bestStreak,
      Value<int> lifetimeCleanDays,
      Value<int?> lastFinalizedDayMillis,
      Value<int> rowid,
    });
typedef $$AppStreakStatesTableUpdateCompanionBuilder =
    AppStreakStatesCompanion Function({
      Value<String> packageId,
      Value<int> currentStreak,
      Value<int> bestStreak,
      Value<int> lifetimeCleanDays,
      Value<int?> lastFinalizedDayMillis,
      Value<int> rowid,
    });

class $$AppStreakStatesTableFilterComposer
    extends Composer<_$CairnDatabase, $AppStreakStatesTable> {
  $$AppStreakStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get packageId => $composableBuilder(
    column: $table.packageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestStreak => $composableBuilder(
    column: $table.bestStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lifetimeCleanDays => $composableBuilder(
    column: $table.lifetimeCleanDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastFinalizedDayMillis => $composableBuilder(
    column: $table.lastFinalizedDayMillis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppStreakStatesTableOrderingComposer
    extends Composer<_$CairnDatabase, $AppStreakStatesTable> {
  $$AppStreakStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get packageId => $composableBuilder(
    column: $table.packageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestStreak => $composableBuilder(
    column: $table.bestStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lifetimeCleanDays => $composableBuilder(
    column: $table.lifetimeCleanDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastFinalizedDayMillis => $composableBuilder(
    column: $table.lastFinalizedDayMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppStreakStatesTableAnnotationComposer
    extends Composer<_$CairnDatabase, $AppStreakStatesTable> {
  $$AppStreakStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get packageId =>
      $composableBuilder(column: $table.packageId, builder: (column) => column);

  GeneratedColumn<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bestStreak => $composableBuilder(
    column: $table.bestStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lifetimeCleanDays => $composableBuilder(
    column: $table.lifetimeCleanDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastFinalizedDayMillis => $composableBuilder(
    column: $table.lastFinalizedDayMillis,
    builder: (column) => column,
  );
}

class $$AppStreakStatesTableTableManager
    extends
        RootTableManager<
          _$CairnDatabase,
          $AppStreakStatesTable,
          AppStreakStateRow,
          $$AppStreakStatesTableFilterComposer,
          $$AppStreakStatesTableOrderingComposer,
          $$AppStreakStatesTableAnnotationComposer,
          $$AppStreakStatesTableCreateCompanionBuilder,
          $$AppStreakStatesTableUpdateCompanionBuilder,
          (
            AppStreakStateRow,
            BaseReferences<
              _$CairnDatabase,
              $AppStreakStatesTable,
              AppStreakStateRow
            >,
          ),
          AppStreakStateRow,
          PrefetchHooks Function()
        > {
  $$AppStreakStatesTableTableManager(
    _$CairnDatabase db,
    $AppStreakStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppStreakStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppStreakStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppStreakStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> packageId = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<int> bestStreak = const Value.absent(),
                Value<int> lifetimeCleanDays = const Value.absent(),
                Value<int?> lastFinalizedDayMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppStreakStatesCompanion(
                packageId: packageId,
                currentStreak: currentStreak,
                bestStreak: bestStreak,
                lifetimeCleanDays: lifetimeCleanDays,
                lastFinalizedDayMillis: lastFinalizedDayMillis,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String packageId,
                Value<int> currentStreak = const Value.absent(),
                Value<int> bestStreak = const Value.absent(),
                Value<int> lifetimeCleanDays = const Value.absent(),
                Value<int?> lastFinalizedDayMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppStreakStatesCompanion.insert(
                packageId: packageId,
                currentStreak: currentStreak,
                bestStreak: bestStreak,
                lifetimeCleanDays: lifetimeCleanDays,
                lastFinalizedDayMillis: lastFinalizedDayMillis,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppStreakStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$CairnDatabase,
      $AppStreakStatesTable,
      AppStreakStateRow,
      $$AppStreakStatesTableFilterComposer,
      $$AppStreakStatesTableOrderingComposer,
      $$AppStreakStatesTableAnnotationComposer,
      $$AppStreakStatesTableCreateCompanionBuilder,
      $$AppStreakStatesTableUpdateCompanionBuilder,
      (
        AppStreakStateRow,
        BaseReferences<
          _$CairnDatabase,
          $AppStreakStatesTable,
          AppStreakStateRow
        >,
      ),
      AppStreakStateRow,
      PrefetchHooks Function()
    >;
typedef $$MetaStatesTableCreateCompanionBuilder =
    MetaStatesCompanion Function({
      Value<int> id,
      Value<int> currentMetaStreak,
      Value<int> bestMetaStreak,
      Value<int> lifetimePerfectDays,
    });
typedef $$MetaStatesTableUpdateCompanionBuilder =
    MetaStatesCompanion Function({
      Value<int> id,
      Value<int> currentMetaStreak,
      Value<int> bestMetaStreak,
      Value<int> lifetimePerfectDays,
    });

class $$MetaStatesTableFilterComposer
    extends Composer<_$CairnDatabase, $MetaStatesTable> {
  $$MetaStatesTableFilterComposer({
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

  ColumnFilters<int> get currentMetaStreak => $composableBuilder(
    column: $table.currentMetaStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestMetaStreak => $composableBuilder(
    column: $table.bestMetaStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lifetimePerfectDays => $composableBuilder(
    column: $table.lifetimePerfectDays,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetaStatesTableOrderingComposer
    extends Composer<_$CairnDatabase, $MetaStatesTable> {
  $$MetaStatesTableOrderingComposer({
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

  ColumnOrderings<int> get currentMetaStreak => $composableBuilder(
    column: $table.currentMetaStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestMetaStreak => $composableBuilder(
    column: $table.bestMetaStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lifetimePerfectDays => $composableBuilder(
    column: $table.lifetimePerfectDays,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetaStatesTableAnnotationComposer
    extends Composer<_$CairnDatabase, $MetaStatesTable> {
  $$MetaStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get currentMetaStreak => $composableBuilder(
    column: $table.currentMetaStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bestMetaStreak => $composableBuilder(
    column: $table.bestMetaStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lifetimePerfectDays => $composableBuilder(
    column: $table.lifetimePerfectDays,
    builder: (column) => column,
  );
}

class $$MetaStatesTableTableManager
    extends
        RootTableManager<
          _$CairnDatabase,
          $MetaStatesTable,
          MetaStateRow,
          $$MetaStatesTableFilterComposer,
          $$MetaStatesTableOrderingComposer,
          $$MetaStatesTableAnnotationComposer,
          $$MetaStatesTableCreateCompanionBuilder,
          $$MetaStatesTableUpdateCompanionBuilder,
          (
            MetaStateRow,
            BaseReferences<_$CairnDatabase, $MetaStatesTable, MetaStateRow>,
          ),
          MetaStateRow,
          PrefetchHooks Function()
        > {
  $$MetaStatesTableTableManager(_$CairnDatabase db, $MetaStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetaStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetaStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetaStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> currentMetaStreak = const Value.absent(),
                Value<int> bestMetaStreak = const Value.absent(),
                Value<int> lifetimePerfectDays = const Value.absent(),
              }) => MetaStatesCompanion(
                id: id,
                currentMetaStreak: currentMetaStreak,
                bestMetaStreak: bestMetaStreak,
                lifetimePerfectDays: lifetimePerfectDays,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> currentMetaStreak = const Value.absent(),
                Value<int> bestMetaStreak = const Value.absent(),
                Value<int> lifetimePerfectDays = const Value.absent(),
              }) => MetaStatesCompanion.insert(
                id: id,
                currentMetaStreak: currentMetaStreak,
                bestMetaStreak: bestMetaStreak,
                lifetimePerfectDays: lifetimePerfectDays,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetaStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$CairnDatabase,
      $MetaStatesTable,
      MetaStateRow,
      $$MetaStatesTableFilterComposer,
      $$MetaStatesTableOrderingComposer,
      $$MetaStatesTableAnnotationComposer,
      $$MetaStatesTableCreateCompanionBuilder,
      $$MetaStatesTableUpdateCompanionBuilder,
      (
        MetaStateRow,
        BaseReferences<_$CairnDatabase, $MetaStatesTable, MetaStateRow>,
      ),
      MetaStateRow,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<int> dayResetHour,
      Value<bool> notificationsEnabled,
      Value<int> dailySummaryMinutes,
      Value<bool> milestonesEnabled,
      Value<bool> analyticsOptIn,
      Value<bool> onboardingComplete,
      Value<bool> speedBumpEnabled,
      Value<int?> speedBumpEnabledAtMillis,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<int> dayResetHour,
      Value<bool> notificationsEnabled,
      Value<int> dailySummaryMinutes,
      Value<bool> milestonesEnabled,
      Value<bool> analyticsOptIn,
      Value<bool> onboardingComplete,
      Value<bool> speedBumpEnabled,
      Value<int?> speedBumpEnabledAtMillis,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$CairnDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
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

  ColumnFilters<int> get dayResetHour => $composableBuilder(
    column: $table.dayResetHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailySummaryMinutes => $composableBuilder(
    column: $table.dailySummaryMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get milestonesEnabled => $composableBuilder(
    column: $table.milestonesEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get analyticsOptIn => $composableBuilder(
    column: $table.analyticsOptIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboardingComplete => $composableBuilder(
    column: $table.onboardingComplete,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get speedBumpEnabled => $composableBuilder(
    column: $table.speedBumpEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speedBumpEnabledAtMillis => $composableBuilder(
    column: $table.speedBumpEnabledAtMillis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$CairnDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
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

  ColumnOrderings<int> get dayResetHour => $composableBuilder(
    column: $table.dayResetHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailySummaryMinutes => $composableBuilder(
    column: $table.dailySummaryMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get milestonesEnabled => $composableBuilder(
    column: $table.milestonesEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get analyticsOptIn => $composableBuilder(
    column: $table.analyticsOptIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingComplete => $composableBuilder(
    column: $table.onboardingComplete,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get speedBumpEnabled => $composableBuilder(
    column: $table.speedBumpEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speedBumpEnabledAtMillis => $composableBuilder(
    column: $table.speedBumpEnabledAtMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$CairnDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dayResetHour => $composableBuilder(
    column: $table.dayResetHour,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailySummaryMinutes => $composableBuilder(
    column: $table.dailySummaryMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get milestonesEnabled => $composableBuilder(
    column: $table.milestonesEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get analyticsOptIn => $composableBuilder(
    column: $table.analyticsOptIn,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get onboardingComplete => $composableBuilder(
    column: $table.onboardingComplete,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get speedBumpEnabled => $composableBuilder(
    column: $table.speedBumpEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get speedBumpEnabledAtMillis => $composableBuilder(
    column: $table.speedBumpEnabledAtMillis,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$CairnDatabase,
          $AppSettingsTable,
          AppSettingsRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingsRow,
            BaseReferences<_$CairnDatabase, $AppSettingsTable, AppSettingsRow>,
          ),
          AppSettingsRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$CairnDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> dayResetHour = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<int> dailySummaryMinutes = const Value.absent(),
                Value<bool> milestonesEnabled = const Value.absent(),
                Value<bool> analyticsOptIn = const Value.absent(),
                Value<bool> onboardingComplete = const Value.absent(),
                Value<bool> speedBumpEnabled = const Value.absent(),
                Value<int?> speedBumpEnabledAtMillis = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                dayResetHour: dayResetHour,
                notificationsEnabled: notificationsEnabled,
                dailySummaryMinutes: dailySummaryMinutes,
                milestonesEnabled: milestonesEnabled,
                analyticsOptIn: analyticsOptIn,
                onboardingComplete: onboardingComplete,
                speedBumpEnabled: speedBumpEnabled,
                speedBumpEnabledAtMillis: speedBumpEnabledAtMillis,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> dayResetHour = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<int> dailySummaryMinutes = const Value.absent(),
                Value<bool> milestonesEnabled = const Value.absent(),
                Value<bool> analyticsOptIn = const Value.absent(),
                Value<bool> onboardingComplete = const Value.absent(),
                Value<bool> speedBumpEnabled = const Value.absent(),
                Value<int?> speedBumpEnabledAtMillis = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                dayResetHour: dayResetHour,
                notificationsEnabled: notificationsEnabled,
                dailySummaryMinutes: dailySummaryMinutes,
                milestonesEnabled: milestonesEnabled,
                analyticsOptIn: analyticsOptIn,
                onboardingComplete: onboardingComplete,
                speedBumpEnabled: speedBumpEnabled,
                speedBumpEnabledAtMillis: speedBumpEnabledAtMillis,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$CairnDatabase,
      $AppSettingsTable,
      AppSettingsRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingsRow,
        BaseReferences<_$CairnDatabase, $AppSettingsTable, AppSettingsRow>,
      ),
      AppSettingsRow,
      PrefetchHooks Function()
    >;
typedef $$InterceptionEventsTableCreateCompanionBuilder =
    InterceptionEventsCompanion Function({
      required String packageId,
      required int foregroundAtMillis,
      required int dayStartMillis,
      required InterceptionOutcome outcome,
      required int recordedAtMillis,
      Value<int> rowid,
    });
typedef $$InterceptionEventsTableUpdateCompanionBuilder =
    InterceptionEventsCompanion Function({
      Value<String> packageId,
      Value<int> foregroundAtMillis,
      Value<int> dayStartMillis,
      Value<InterceptionOutcome> outcome,
      Value<int> recordedAtMillis,
      Value<int> rowid,
    });

class $$InterceptionEventsTableFilterComposer
    extends Composer<_$CairnDatabase, $InterceptionEventsTable> {
  $$InterceptionEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get packageId => $composableBuilder(
    column: $table.packageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get foregroundAtMillis => $composableBuilder(
    column: $table.foregroundAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayStartMillis => $composableBuilder(
    column: $table.dayStartMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<InterceptionOutcome, InterceptionOutcome, int>
  get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get recordedAtMillis => $composableBuilder(
    column: $table.recordedAtMillis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InterceptionEventsTableOrderingComposer
    extends Composer<_$CairnDatabase, $InterceptionEventsTable> {
  $$InterceptionEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get packageId => $composableBuilder(
    column: $table.packageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get foregroundAtMillis => $composableBuilder(
    column: $table.foregroundAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayStartMillis => $composableBuilder(
    column: $table.dayStartMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordedAtMillis => $composableBuilder(
    column: $table.recordedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InterceptionEventsTableAnnotationComposer
    extends Composer<_$CairnDatabase, $InterceptionEventsTable> {
  $$InterceptionEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get packageId =>
      $composableBuilder(column: $table.packageId, builder: (column) => column);

  GeneratedColumn<int> get foregroundAtMillis => $composableBuilder(
    column: $table.foregroundAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayStartMillis => $composableBuilder(
    column: $table.dayStartMillis,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<InterceptionOutcome, int> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<int> get recordedAtMillis => $composableBuilder(
    column: $table.recordedAtMillis,
    builder: (column) => column,
  );
}

class $$InterceptionEventsTableTableManager
    extends
        RootTableManager<
          _$CairnDatabase,
          $InterceptionEventsTable,
          InterceptionEventRow,
          $$InterceptionEventsTableFilterComposer,
          $$InterceptionEventsTableOrderingComposer,
          $$InterceptionEventsTableAnnotationComposer,
          $$InterceptionEventsTableCreateCompanionBuilder,
          $$InterceptionEventsTableUpdateCompanionBuilder,
          (
            InterceptionEventRow,
            BaseReferences<
              _$CairnDatabase,
              $InterceptionEventsTable,
              InterceptionEventRow
            >,
          ),
          InterceptionEventRow,
          PrefetchHooks Function()
        > {
  $$InterceptionEventsTableTableManager(
    _$CairnDatabase db,
    $InterceptionEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InterceptionEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InterceptionEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InterceptionEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> packageId = const Value.absent(),
                Value<int> foregroundAtMillis = const Value.absent(),
                Value<int> dayStartMillis = const Value.absent(),
                Value<InterceptionOutcome> outcome = const Value.absent(),
                Value<int> recordedAtMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InterceptionEventsCompanion(
                packageId: packageId,
                foregroundAtMillis: foregroundAtMillis,
                dayStartMillis: dayStartMillis,
                outcome: outcome,
                recordedAtMillis: recordedAtMillis,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String packageId,
                required int foregroundAtMillis,
                required int dayStartMillis,
                required InterceptionOutcome outcome,
                required int recordedAtMillis,
                Value<int> rowid = const Value.absent(),
              }) => InterceptionEventsCompanion.insert(
                packageId: packageId,
                foregroundAtMillis: foregroundAtMillis,
                dayStartMillis: dayStartMillis,
                outcome: outcome,
                recordedAtMillis: recordedAtMillis,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InterceptionEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$CairnDatabase,
      $InterceptionEventsTable,
      InterceptionEventRow,
      $$InterceptionEventsTableFilterComposer,
      $$InterceptionEventsTableOrderingComposer,
      $$InterceptionEventsTableAnnotationComposer,
      $$InterceptionEventsTableCreateCompanionBuilder,
      $$InterceptionEventsTableUpdateCompanionBuilder,
      (
        InterceptionEventRow,
        BaseReferences<
          _$CairnDatabase,
          $InterceptionEventsTable,
          InterceptionEventRow
        >,
      ),
      InterceptionEventRow,
      PrefetchHooks Function()
    >;

class $CairnDatabaseManager {
  final _$CairnDatabase _db;
  $CairnDatabaseManager(this._db);
  $$TrackedAppsTableTableManager get trackedApps =>
      $$TrackedAppsTableTableManager(_db, _db.trackedApps);
  $$DayRecordsTableTableManager get dayRecords =>
      $$DayRecordsTableTableManager(_db, _db.dayRecords);
  $$AppStreakStatesTableTableManager get appStreakStates =>
      $$AppStreakStatesTableTableManager(_db, _db.appStreakStates);
  $$MetaStatesTableTableManager get metaStates =>
      $$MetaStatesTableTableManager(_db, _db.metaStates);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$InterceptionEventsTableTableManager get interceptionEvents =>
      $$InterceptionEventsTableTableManager(_db, _db.interceptionEvents);
}
