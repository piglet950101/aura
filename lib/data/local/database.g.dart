// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthYearMeta = const VerificationMeta('birthYear');
  @override
  late final GeneratedColumn<int> birthYear = GeneratedColumn<int>(
    'birth_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pt-PT'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    birthYear,
    sex,
    locale,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(Insertable<Profile> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(data['display_name']!, _displayNameMeta),
      );
    }
    if (data.containsKey('birth_year')) {
      context.handle(
        _birthYearMeta,
        birthYear.isAcceptableOrUnknown(data['birth_year']!, _birthYearMeta),
      );
    }
    if (data.containsKey('sex')) {
      context.handle(_sexMeta, sex.isAcceptableOrUnknown(data['sex']!, _sexMeta));
    }
    if (data.containsKey('locale')) {
      context.handle(_localeMeta, locale.isAcceptableOrUnknown(data['locale']!, _localeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      birthYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birth_year'],
      ),
      sex: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}sex']),
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
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
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final String id;
  final String? displayName;
  final int? birthYear;
  final String? sex;
  final String locale;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Profile({
    required this.id,
    this.displayName,
    this.birthYear,
    this.sex,
    required this.locale,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || birthYear != null) {
      map['birth_year'] = Variable<int>(birthYear);
    }
    if (!nullToAbsent || sex != null) {
      map['sex'] = Variable<String>(sex);
    }
    map['locale'] = Variable<String>(locale);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      displayName: displayName == null && nullToAbsent ? const Value.absent() : Value(displayName),
      birthYear: birthYear == null && nullToAbsent ? const Value.absent() : Value(birthYear),
      sex: sex == null && nullToAbsent ? const Value.absent() : Value(sex),
      locale: Value(locale),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      birthYear: serializer.fromJson<int?>(json['birthYear']),
      sex: serializer.fromJson<String?>(json['sex']),
      locale: serializer.fromJson<String>(json['locale']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String?>(displayName),
      'birthYear': serializer.toJson<int?>(birthYear),
      'sex': serializer.toJson<String?>(sex),
      'locale': serializer.toJson<String>(locale),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Profile copyWith({
    String? id,
    Value<String?> displayName = const Value.absent(),
    Value<int?> birthYear = const Value.absent(),
    Value<String?> sex = const Value.absent(),
    String? locale,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Profile(
    id: id ?? this.id,
    displayName: displayName.present ? displayName.value : this.displayName,
    birthYear: birthYear.present ? birthYear.value : this.birthYear,
    sex: sex.present ? sex.value : this.sex,
    locale: locale ?? this.locale,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present ? data.displayName.value : this.displayName,
      birthYear: data.birthYear.present ? data.birthYear.value : this.birthYear,
      sex: data.sex.present ? data.sex.value : this.sex,
      locale: data.locale.present ? data.locale.value : this.locale,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('birthYear: $birthYear, ')
          ..write('sex: $sex, ')
          ..write('locale: $locale, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, displayName, birthYear, sex, locale, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.birthYear == this.birthYear &&
          other.sex == this.sex &&
          other.locale == this.locale &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<String> id;
  final Value<String?> displayName;
  final Value<int?> birthYear;
  final Value<String?> sex;
  final Value<String> locale;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.birthYear = const Value.absent(),
    this.sex = const Value.absent(),
    this.locale = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String id,
    this.displayName = const Value.absent(),
    this.birthYear = const Value.absent(),
    this.sex = const Value.absent(),
    this.locale = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Profile> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<int>? birthYear,
    Expression<String>? sex,
    Expression<String>? locale,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (birthYear != null) 'birth_year': birthYear,
      if (sex != null) 'sex': sex,
      if (locale != null) 'locale': locale,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? id,
    Value<String?>? displayName,
    Value<int?>? birthYear,
    Value<String?>? sex,
    Value<String>? locale,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      birthYear: birthYear ?? this.birthYear,
      sex: sex ?? this.sex,
      locale: locale ?? this.locale,
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
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (birthYear.present) {
      map['birth_year'] = Variable<int>(birthYear.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
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
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('birthYear: $birthYear, ')
          ..write('sex: $sex, ')
          ..write('locale: $locale, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationsTable extends Medications with TableInfo<$MedicationsTable, Medication> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 80),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doseMgMeta = const VerificationMeta('doseMg');
  @override
  late final GeneratedColumn<double> doseMg = GeneratedColumn<double>(
    'dose_mg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta('archived');
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("archived" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    doseMg,
    isDefault,
    archived,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medications';
  @override
  VerificationContext validateIntegrity(
    Insertable<Medication> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('dose_mg')) {
      context.handle(_doseMgMeta, doseMg.isAcceptableOrUnknown(data['dose_mg']!, _doseMgMeta));
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medication map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medication(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      doseMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dose_mg'],
      ),
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
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
  $MedicationsTable createAlias(String alias) {
    return $MedicationsTable(attachedDatabase, alias);
  }
}

class Medication extends DataClass implements Insertable<Medication> {
  final String id;
  final String userId;
  final String name;
  final double? doseMg;
  final bool isDefault;
  final bool archived;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Medication({
    required this.id,
    required this.userId,
    required this.name,
    this.doseMg,
    required this.isDefault,
    required this.archived,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || doseMg != null) {
      map['dose_mg'] = Variable<double>(doseMg);
    }
    map['is_default'] = Variable<bool>(isDefault);
    map['archived'] = Variable<bool>(archived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MedicationsCompanion toCompanion(bool nullToAbsent) {
    return MedicationsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      doseMg: doseMg == null && nullToAbsent ? const Value.absent() : Value(doseMg),
      isDefault: Value(isDefault),
      archived: Value(archived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Medication.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medication(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      doseMg: serializer.fromJson<double?>(json['doseMg']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      archived: serializer.fromJson<bool>(json['archived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'doseMg': serializer.toJson<double?>(doseMg),
      'isDefault': serializer.toJson<bool>(isDefault),
      'archived': serializer.toJson<bool>(archived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Medication copyWith({
    String? id,
    String? userId,
    String? name,
    Value<double?> doseMg = const Value.absent(),
    bool? isDefault,
    bool? archived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Medication(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    doseMg: doseMg.present ? doseMg.value : this.doseMg,
    isDefault: isDefault ?? this.isDefault,
    archived: archived ?? this.archived,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Medication copyWithCompanion(MedicationsCompanion data) {
    return Medication(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      doseMg: data.doseMg.present ? data.doseMg.value : this.doseMg,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      archived: data.archived.present ? data.archived.value : this.archived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medication(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('doseMg: $doseMg, ')
          ..write('isDefault: $isDefault, ')
          ..write('archived: $archived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, name, doseMg, isDefault, archived, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medication &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.doseMg == this.doseMg &&
          other.isDefault == this.isDefault &&
          other.archived == this.archived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MedicationsCompanion extends UpdateCompanion<Medication> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<double?> doseMg;
  final Value<bool> isDefault;
  final Value<bool> archived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MedicationsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.doseMg = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.archived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationsCompanion.insert({
    required String id,
    required String userId,
    required String name,
    this.doseMg = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.archived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name);
  static Insertable<Medication> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<double>? doseMg,
    Expression<bool>? isDefault,
    Expression<bool>? archived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (doseMg != null) 'dose_mg': doseMg,
      if (isDefault != null) 'is_default': isDefault,
      if (archived != null) 'archived': archived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<double?>? doseMg,
    Value<bool>? isDefault,
    Value<bool>? archived,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MedicationsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      doseMg: doseMg ?? this.doseMg,
      isDefault: isDefault ?? this.isDefault,
      archived: archived ?? this.archived,
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (doseMg.present) {
      map['dose_mg'] = Variable<double>(doseMg.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
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
    return (StringBuffer('MedicationsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('doseMg: $doseMg, ')
          ..write('isDefault: $isDefault, ')
          ..write('archived: $archived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CrisesTable extends Crises with TableInfo<$CrisesTable, Crisis> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CrisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta('occurredAt');
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intensityMeta = const VerificationMeta('intensity');
  @override
  late final GeneratedColumn<int> intensity = GeneratedColumn<int>(
    'intensity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
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
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta('resolvedAt');
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    occurredAt,
    intensity,
    location,
    notes,
    resolvedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'crises';
  @override
  VerificationContext validateIntegrity(Insertable<Crisis> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('intensity')) {
      context.handle(
        _intensityMeta,
        intensity.isAcceptableOrUnknown(data['intensity']!, _intensityMeta),
      );
    } else if (isInserting) {
      context.missing(_intensityMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Crisis map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Crisis(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      intensity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intensity'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
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
  $CrisesTable createAlias(String alias) {
    return $CrisesTable(attachedDatabase, alias);
  }
}

class Crisis extends DataClass implements Insertable<Crisis> {
  final String id;
  final String userId;
  final DateTime occurredAt;
  final int intensity;
  final String? location;
  final String? notes;
  final DateTime? resolvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Crisis({
    required this.id,
    required this.userId,
    required this.occurredAt,
    required this.intensity,
    this.location,
    this.notes,
    this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['intensity'] = Variable<int>(intensity);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CrisesCompanion toCompanion(bool nullToAbsent) {
    return CrisesCompanion(
      id: Value(id),
      userId: Value(userId),
      occurredAt: Value(occurredAt),
      intensity: Value(intensity),
      location: location == null && nullToAbsent ? const Value.absent() : Value(location),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      resolvedAt: resolvedAt == null && nullToAbsent ? const Value.absent() : Value(resolvedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Crisis.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Crisis(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      intensity: serializer.fromJson<int>(json['intensity']),
      location: serializer.fromJson<String?>(json['location']),
      notes: serializer.fromJson<String?>(json['notes']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'intensity': serializer.toJson<int>(intensity),
      'location': serializer.toJson<String?>(location),
      'notes': serializer.toJson<String?>(notes),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Crisis copyWith({
    String? id,
    String? userId,
    DateTime? occurredAt,
    int? intensity,
    Value<String?> location = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> resolvedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Crisis(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    occurredAt: occurredAt ?? this.occurredAt,
    intensity: intensity ?? this.intensity,
    location: location.present ? location.value : this.location,
    notes: notes.present ? notes.value : this.notes,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Crisis copyWithCompanion(CrisesCompanion data) {
    return Crisis(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      occurredAt: data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
      intensity: data.intensity.present ? data.intensity.value : this.intensity,
      location: data.location.present ? data.location.value : this.location,
      notes: data.notes.present ? data.notes.value : this.notes,
      resolvedAt: data.resolvedAt.present ? data.resolvedAt.value : this.resolvedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Crisis(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('intensity: $intensity, ')
          ..write('location: $location, ')
          ..write('notes: $notes, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    occurredAt,
    intensity,
    location,
    notes,
    resolvedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Crisis &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.occurredAt == this.occurredAt &&
          other.intensity == this.intensity &&
          other.location == this.location &&
          other.notes == this.notes &&
          other.resolvedAt == this.resolvedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CrisesCompanion extends UpdateCompanion<Crisis> {
  final Value<String> id;
  final Value<String> userId;
  final Value<DateTime> occurredAt;
  final Value<int> intensity;
  final Value<String?> location;
  final Value<String?> notes;
  final Value<DateTime?> resolvedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CrisesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.intensity = const Value.absent(),
    this.location = const Value.absent(),
    this.notes = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CrisesCompanion.insert({
    required String id,
    required String userId,
    required DateTime occurredAt,
    required int intensity,
    this.location = const Value.absent(),
    this.notes = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       occurredAt = Value(occurredAt),
       intensity = Value(intensity);
  static Insertable<Crisis> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? occurredAt,
    Expression<int>? intensity,
    Expression<String>? location,
    Expression<String>? notes,
    Expression<DateTime>? resolvedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (intensity != null) 'intensity': intensity,
      if (location != null) 'location': location,
      if (notes != null) 'notes': notes,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CrisesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<DateTime>? occurredAt,
    Value<int>? intensity,
    Value<String?>? location,
    Value<String?>? notes,
    Value<DateTime?>? resolvedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CrisesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      occurredAt: occurredAt ?? this.occurredAt,
      intensity: intensity ?? this.intensity,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      resolvedAt: resolvedAt ?? this.resolvedAt,
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (intensity.present) {
      map['intensity'] = Variable<int>(intensity.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
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
    return (StringBuffer('CrisesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('intensity: $intensity, ')
          ..write('location: $location, ')
          ..write('notes: $notes, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CrisisSymptomsTable extends CrisisSymptoms
    with TableInfo<$CrisisSymptomsTable, CrisisSymptom> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CrisisSymptomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _crisisIdMeta = const VerificationMeta('crisisId');
  @override
  late final GeneratedColumn<String> crisisId = GeneratedColumn<String>(
    'crisis_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES crises (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _symptomMeta = const VerificationMeta('symptom');
  @override
  late final GeneratedColumn<String> symptom = GeneratedColumn<String>(
    'symptom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [crisisId, symptom];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'crisis_symptoms';
  @override
  VerificationContext validateIntegrity(
    Insertable<CrisisSymptom> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('crisis_id')) {
      context.handle(
        _crisisIdMeta,
        crisisId.isAcceptableOrUnknown(data['crisis_id']!, _crisisIdMeta),
      );
    } else if (isInserting) {
      context.missing(_crisisIdMeta);
    }
    if (data.containsKey('symptom')) {
      context.handle(_symptomMeta, symptom.isAcceptableOrUnknown(data['symptom']!, _symptomMeta));
    } else if (isInserting) {
      context.missing(_symptomMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {crisisId, symptom};
  @override
  CrisisSymptom map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CrisisSymptom(
      crisisId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}crisis_id'],
      )!,
      symptom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symptom'],
      )!,
    );
  }

  @override
  $CrisisSymptomsTable createAlias(String alias) {
    return $CrisisSymptomsTable(attachedDatabase, alias);
  }
}

class CrisisSymptom extends DataClass implements Insertable<CrisisSymptom> {
  final String crisisId;
  final String symptom;
  const CrisisSymptom({required this.crisisId, required this.symptom});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['crisis_id'] = Variable<String>(crisisId);
    map['symptom'] = Variable<String>(symptom);
    return map;
  }

  CrisisSymptomsCompanion toCompanion(bool nullToAbsent) {
    return CrisisSymptomsCompanion(crisisId: Value(crisisId), symptom: Value(symptom));
  }

  factory CrisisSymptom.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CrisisSymptom(
      crisisId: serializer.fromJson<String>(json['crisisId']),
      symptom: serializer.fromJson<String>(json['symptom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'crisisId': serializer.toJson<String>(crisisId),
      'symptom': serializer.toJson<String>(symptom),
    };
  }

  CrisisSymptom copyWith({String? crisisId, String? symptom}) =>
      CrisisSymptom(crisisId: crisisId ?? this.crisisId, symptom: symptom ?? this.symptom);
  CrisisSymptom copyWithCompanion(CrisisSymptomsCompanion data) {
    return CrisisSymptom(
      crisisId: data.crisisId.present ? data.crisisId.value : this.crisisId,
      symptom: data.symptom.present ? data.symptom.value : this.symptom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CrisisSymptom(')
          ..write('crisisId: $crisisId, ')
          ..write('symptom: $symptom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(crisisId, symptom);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CrisisSymptom && other.crisisId == this.crisisId && other.symptom == this.symptom);
}

class CrisisSymptomsCompanion extends UpdateCompanion<CrisisSymptom> {
  final Value<String> crisisId;
  final Value<String> symptom;
  final Value<int> rowid;
  const CrisisSymptomsCompanion({
    this.crisisId = const Value.absent(),
    this.symptom = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CrisisSymptomsCompanion.insert({
    required String crisisId,
    required String symptom,
    this.rowid = const Value.absent(),
  }) : crisisId = Value(crisisId),
       symptom = Value(symptom);
  static Insertable<CrisisSymptom> custom({
    Expression<String>? crisisId,
    Expression<String>? symptom,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (crisisId != null) 'crisis_id': crisisId,
      if (symptom != null) 'symptom': symptom,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CrisisSymptomsCompanion copyWith({
    Value<String>? crisisId,
    Value<String>? symptom,
    Value<int>? rowid,
  }) {
    return CrisisSymptomsCompanion(
      crisisId: crisisId ?? this.crisisId,
      symptom: symptom ?? this.symptom,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (crisisId.present) {
      map['crisis_id'] = Variable<String>(crisisId.value);
    }
    if (symptom.present) {
      map['symptom'] = Variable<String>(symptom.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CrisisSymptomsCompanion(')
          ..write('crisisId: $crisisId, ')
          ..write('symptom: $symptom, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CrisisTriggersTable extends CrisisTriggers
    with TableInfo<$CrisisTriggersTable, CrisisTrigger> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CrisisTriggersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _crisisIdMeta = const VerificationMeta('crisisId');
  @override
  late final GeneratedColumn<String> crisisId = GeneratedColumn<String>(
    'crisis_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES crises (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _triggerMeta = const VerificationMeta('trigger');
  @override
  late final GeneratedColumn<String> trigger = GeneratedColumn<String>(
    'trigger',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [crisisId, trigger];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'crisis_triggers';
  @override
  VerificationContext validateIntegrity(
    Insertable<CrisisTrigger> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('crisis_id')) {
      context.handle(
        _crisisIdMeta,
        crisisId.isAcceptableOrUnknown(data['crisis_id']!, _crisisIdMeta),
      );
    } else if (isInserting) {
      context.missing(_crisisIdMeta);
    }
    if (data.containsKey('trigger')) {
      context.handle(_triggerMeta, trigger.isAcceptableOrUnknown(data['trigger']!, _triggerMeta));
    } else if (isInserting) {
      context.missing(_triggerMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {crisisId, trigger};
  @override
  CrisisTrigger map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CrisisTrigger(
      crisisId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}crisis_id'],
      )!,
      trigger: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger'],
      )!,
    );
  }

  @override
  $CrisisTriggersTable createAlias(String alias) {
    return $CrisisTriggersTable(attachedDatabase, alias);
  }
}

class CrisisTrigger extends DataClass implements Insertable<CrisisTrigger> {
  final String crisisId;
  final String trigger;
  const CrisisTrigger({required this.crisisId, required this.trigger});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['crisis_id'] = Variable<String>(crisisId);
    map['trigger'] = Variable<String>(trigger);
    return map;
  }

  CrisisTriggersCompanion toCompanion(bool nullToAbsent) {
    return CrisisTriggersCompanion(crisisId: Value(crisisId), trigger: Value(trigger));
  }

  factory CrisisTrigger.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CrisisTrigger(
      crisisId: serializer.fromJson<String>(json['crisisId']),
      trigger: serializer.fromJson<String>(json['trigger']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'crisisId': serializer.toJson<String>(crisisId),
      'trigger': serializer.toJson<String>(trigger),
    };
  }

  CrisisTrigger copyWith({String? crisisId, String? trigger}) =>
      CrisisTrigger(crisisId: crisisId ?? this.crisisId, trigger: trigger ?? this.trigger);
  CrisisTrigger copyWithCompanion(CrisisTriggersCompanion data) {
    return CrisisTrigger(
      crisisId: data.crisisId.present ? data.crisisId.value : this.crisisId,
      trigger: data.trigger.present ? data.trigger.value : this.trigger,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CrisisTrigger(')
          ..write('crisisId: $crisisId, ')
          ..write('trigger: $trigger')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(crisisId, trigger);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CrisisTrigger && other.crisisId == this.crisisId && other.trigger == this.trigger);
}

class CrisisTriggersCompanion extends UpdateCompanion<CrisisTrigger> {
  final Value<String> crisisId;
  final Value<String> trigger;
  final Value<int> rowid;
  const CrisisTriggersCompanion({
    this.crisisId = const Value.absent(),
    this.trigger = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CrisisTriggersCompanion.insert({
    required String crisisId,
    required String trigger,
    this.rowid = const Value.absent(),
  }) : crisisId = Value(crisisId),
       trigger = Value(trigger);
  static Insertable<CrisisTrigger> custom({
    Expression<String>? crisisId,
    Expression<String>? trigger,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (crisisId != null) 'crisis_id': crisisId,
      if (trigger != null) 'trigger': trigger,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CrisisTriggersCompanion copyWith({
    Value<String>? crisisId,
    Value<String>? trigger,
    Value<int>? rowid,
  }) {
    return CrisisTriggersCompanion(
      crisisId: crisisId ?? this.crisisId,
      trigger: trigger ?? this.trigger,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (crisisId.present) {
      map['crisis_id'] = Variable<String>(crisisId.value);
    }
    if (trigger.present) {
      map['trigger'] = Variable<String>(trigger.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CrisisTriggersCompanion(')
          ..write('crisisId: $crisisId, ')
          ..write('trigger: $trigger, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CrisisMedicationsTable extends CrisisMedications
    with TableInfo<$CrisisMedicationsTable, CrisisMedication> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CrisisMedicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _crisisIdMeta = const VerificationMeta('crisisId');
  @override
  late final GeneratedColumn<String> crisisId = GeneratedColumn<String>(
    'crisis_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES crises (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _medicationIdMeta = const VerificationMeta('medicationId');
  @override
  late final GeneratedColumn<String> medicationId = GeneratedColumn<String>(
    'medication_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medications (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _medicationNameSnapshotMeta = const VerificationMeta(
    'medicationNameSnapshot',
  );
  @override
  late final GeneratedColumn<String> medicationNameSnapshot = GeneratedColumn<String>(
    'medication_name_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doseMgMeta = const VerificationMeta('doseMg');
  @override
  late final GeneratedColumn<double> doseMg = GeneratedColumn<double>(
    'dose_mg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta('takenAt');
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reliefAtMeta = const VerificationMeta('reliefAt');
  @override
  late final GeneratedColumn<DateTime> reliefAt = GeneratedColumn<DateTime>(
    'relief_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _effectiveMeta = const VerificationMeta('effective');
  @override
  late final GeneratedColumn<bool> effective = GeneratedColumn<bool>(
    'effective',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("effective" IN (0, 1))'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    crisisId,
    medicationId,
    medicationNameSnapshot,
    doseMg,
    takenAt,
    reliefAt,
    effective,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'crisis_medications';
  @override
  VerificationContext validateIntegrity(
    Insertable<CrisisMedication> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('crisis_id')) {
      context.handle(
        _crisisIdMeta,
        crisisId.isAcceptableOrUnknown(data['crisis_id']!, _crisisIdMeta),
      );
    } else if (isInserting) {
      context.missing(_crisisIdMeta);
    }
    if (data.containsKey('medication_id')) {
      context.handle(
        _medicationIdMeta,
        medicationId.isAcceptableOrUnknown(data['medication_id']!, _medicationIdMeta),
      );
    }
    if (data.containsKey('medication_name_snapshot')) {
      context.handle(
        _medicationNameSnapshotMeta,
        medicationNameSnapshot.isAcceptableOrUnknown(
          data['medication_name_snapshot']!,
          _medicationNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationNameSnapshotMeta);
    }
    if (data.containsKey('dose_mg')) {
      context.handle(_doseMgMeta, doseMg.isAcceptableOrUnknown(data['dose_mg']!, _doseMgMeta));
    }
    if (data.containsKey('taken_at')) {
      context.handle(_takenAtMeta, takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta));
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    if (data.containsKey('relief_at')) {
      context.handle(
        _reliefAtMeta,
        reliefAt.isAcceptableOrUnknown(data['relief_at']!, _reliefAtMeta),
      );
    }
    if (data.containsKey('effective')) {
      context.handle(
        _effectiveMeta,
        effective.isAcceptableOrUnknown(data['effective']!, _effectiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CrisisMedication map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CrisisMedication(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      crisisId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}crisis_id'],
      )!,
      medicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medication_id'],
      ),
      medicationNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medication_name_snapshot'],
      )!,
      doseMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dose_mg'],
      ),
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_at'],
      )!,
      reliefAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}relief_at'],
      ),
      effective: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}effective'],
      ),
    );
  }

  @override
  $CrisisMedicationsTable createAlias(String alias) {
    return $CrisisMedicationsTable(attachedDatabase, alias);
  }
}

class CrisisMedication extends DataClass implements Insertable<CrisisMedication> {
  final String id;
  final String crisisId;
  final String? medicationId;
  final String medicationNameSnapshot;
  final double? doseMg;
  final DateTime takenAt;
  final DateTime? reliefAt;
  final bool? effective;
  const CrisisMedication({
    required this.id,
    required this.crisisId,
    this.medicationId,
    required this.medicationNameSnapshot,
    this.doseMg,
    required this.takenAt,
    this.reliefAt,
    this.effective,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['crisis_id'] = Variable<String>(crisisId);
    if (!nullToAbsent || medicationId != null) {
      map['medication_id'] = Variable<String>(medicationId);
    }
    map['medication_name_snapshot'] = Variable<String>(medicationNameSnapshot);
    if (!nullToAbsent || doseMg != null) {
      map['dose_mg'] = Variable<double>(doseMg);
    }
    map['taken_at'] = Variable<DateTime>(takenAt);
    if (!nullToAbsent || reliefAt != null) {
      map['relief_at'] = Variable<DateTime>(reliefAt);
    }
    if (!nullToAbsent || effective != null) {
      map['effective'] = Variable<bool>(effective);
    }
    return map;
  }

  CrisisMedicationsCompanion toCompanion(bool nullToAbsent) {
    return CrisisMedicationsCompanion(
      id: Value(id),
      crisisId: Value(crisisId),
      medicationId: medicationId == null && nullToAbsent
          ? const Value.absent()
          : Value(medicationId),
      medicationNameSnapshot: Value(medicationNameSnapshot),
      doseMg: doseMg == null && nullToAbsent ? const Value.absent() : Value(doseMg),
      takenAt: Value(takenAt),
      reliefAt: reliefAt == null && nullToAbsent ? const Value.absent() : Value(reliefAt),
      effective: effective == null && nullToAbsent ? const Value.absent() : Value(effective),
    );
  }

  factory CrisisMedication.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CrisisMedication(
      id: serializer.fromJson<String>(json['id']),
      crisisId: serializer.fromJson<String>(json['crisisId']),
      medicationId: serializer.fromJson<String?>(json['medicationId']),
      medicationNameSnapshot: serializer.fromJson<String>(json['medicationNameSnapshot']),
      doseMg: serializer.fromJson<double?>(json['doseMg']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
      reliefAt: serializer.fromJson<DateTime?>(json['reliefAt']),
      effective: serializer.fromJson<bool?>(json['effective']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'crisisId': serializer.toJson<String>(crisisId),
      'medicationId': serializer.toJson<String?>(medicationId),
      'medicationNameSnapshot': serializer.toJson<String>(medicationNameSnapshot),
      'doseMg': serializer.toJson<double?>(doseMg),
      'takenAt': serializer.toJson<DateTime>(takenAt),
      'reliefAt': serializer.toJson<DateTime?>(reliefAt),
      'effective': serializer.toJson<bool?>(effective),
    };
  }

  CrisisMedication copyWith({
    String? id,
    String? crisisId,
    Value<String?> medicationId = const Value.absent(),
    String? medicationNameSnapshot,
    Value<double?> doseMg = const Value.absent(),
    DateTime? takenAt,
    Value<DateTime?> reliefAt = const Value.absent(),
    Value<bool?> effective = const Value.absent(),
  }) => CrisisMedication(
    id: id ?? this.id,
    crisisId: crisisId ?? this.crisisId,
    medicationId: medicationId.present ? medicationId.value : this.medicationId,
    medicationNameSnapshot: medicationNameSnapshot ?? this.medicationNameSnapshot,
    doseMg: doseMg.present ? doseMg.value : this.doseMg,
    takenAt: takenAt ?? this.takenAt,
    reliefAt: reliefAt.present ? reliefAt.value : this.reliefAt,
    effective: effective.present ? effective.value : this.effective,
  );
  CrisisMedication copyWithCompanion(CrisisMedicationsCompanion data) {
    return CrisisMedication(
      id: data.id.present ? data.id.value : this.id,
      crisisId: data.crisisId.present ? data.crisisId.value : this.crisisId,
      medicationId: data.medicationId.present ? data.medicationId.value : this.medicationId,
      medicationNameSnapshot: data.medicationNameSnapshot.present
          ? data.medicationNameSnapshot.value
          : this.medicationNameSnapshot,
      doseMg: data.doseMg.present ? data.doseMg.value : this.doseMg,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      reliefAt: data.reliefAt.present ? data.reliefAt.value : this.reliefAt,
      effective: data.effective.present ? data.effective.value : this.effective,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CrisisMedication(')
          ..write('id: $id, ')
          ..write('crisisId: $crisisId, ')
          ..write('medicationId: $medicationId, ')
          ..write('medicationNameSnapshot: $medicationNameSnapshot, ')
          ..write('doseMg: $doseMg, ')
          ..write('takenAt: $takenAt, ')
          ..write('reliefAt: $reliefAt, ')
          ..write('effective: $effective')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    crisisId,
    medicationId,
    medicationNameSnapshot,
    doseMg,
    takenAt,
    reliefAt,
    effective,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CrisisMedication &&
          other.id == this.id &&
          other.crisisId == this.crisisId &&
          other.medicationId == this.medicationId &&
          other.medicationNameSnapshot == this.medicationNameSnapshot &&
          other.doseMg == this.doseMg &&
          other.takenAt == this.takenAt &&
          other.reliefAt == this.reliefAt &&
          other.effective == this.effective);
}

class CrisisMedicationsCompanion extends UpdateCompanion<CrisisMedication> {
  final Value<String> id;
  final Value<String> crisisId;
  final Value<String?> medicationId;
  final Value<String> medicationNameSnapshot;
  final Value<double?> doseMg;
  final Value<DateTime> takenAt;
  final Value<DateTime?> reliefAt;
  final Value<bool?> effective;
  final Value<int> rowid;
  const CrisisMedicationsCompanion({
    this.id = const Value.absent(),
    this.crisisId = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.medicationNameSnapshot = const Value.absent(),
    this.doseMg = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.reliefAt = const Value.absent(),
    this.effective = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CrisisMedicationsCompanion.insert({
    required String id,
    required String crisisId,
    this.medicationId = const Value.absent(),
    required String medicationNameSnapshot,
    this.doseMg = const Value.absent(),
    required DateTime takenAt,
    this.reliefAt = const Value.absent(),
    this.effective = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       crisisId = Value(crisisId),
       medicationNameSnapshot = Value(medicationNameSnapshot),
       takenAt = Value(takenAt);
  static Insertable<CrisisMedication> custom({
    Expression<String>? id,
    Expression<String>? crisisId,
    Expression<String>? medicationId,
    Expression<String>? medicationNameSnapshot,
    Expression<double>? doseMg,
    Expression<DateTime>? takenAt,
    Expression<DateTime>? reliefAt,
    Expression<bool>? effective,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (crisisId != null) 'crisis_id': crisisId,
      if (medicationId != null) 'medication_id': medicationId,
      if (medicationNameSnapshot != null) 'medication_name_snapshot': medicationNameSnapshot,
      if (doseMg != null) 'dose_mg': doseMg,
      if (takenAt != null) 'taken_at': takenAt,
      if (reliefAt != null) 'relief_at': reliefAt,
      if (effective != null) 'effective': effective,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CrisisMedicationsCompanion copyWith({
    Value<String>? id,
    Value<String>? crisisId,
    Value<String?>? medicationId,
    Value<String>? medicationNameSnapshot,
    Value<double?>? doseMg,
    Value<DateTime>? takenAt,
    Value<DateTime?>? reliefAt,
    Value<bool?>? effective,
    Value<int>? rowid,
  }) {
    return CrisisMedicationsCompanion(
      id: id ?? this.id,
      crisisId: crisisId ?? this.crisisId,
      medicationId: medicationId ?? this.medicationId,
      medicationNameSnapshot: medicationNameSnapshot ?? this.medicationNameSnapshot,
      doseMg: doseMg ?? this.doseMg,
      takenAt: takenAt ?? this.takenAt,
      reliefAt: reliefAt ?? this.reliefAt,
      effective: effective ?? this.effective,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (crisisId.present) {
      map['crisis_id'] = Variable<String>(crisisId.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<String>(medicationId.value);
    }
    if (medicationNameSnapshot.present) {
      map['medication_name_snapshot'] = Variable<String>(medicationNameSnapshot.value);
    }
    if (doseMg.present) {
      map['dose_mg'] = Variable<double>(doseMg.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (reliefAt.present) {
      map['relief_at'] = Variable<DateTime>(reliefAt.value);
    }
    if (effective.present) {
      map['effective'] = Variable<bool>(effective.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CrisisMedicationsCompanion(')
          ..write('id: $id, ')
          ..write('crisisId: $crisisId, ')
          ..write('medicationId: $medicationId, ')
          ..write('medicationNameSnapshot: $medicationNameSnapshot, ')
          ..write('doseMg: $doseMg, ')
          ..write('takenAt: $takenAt, ')
          ..write('reliefAt: $reliefAt, ')
          ..write('effective: $effective, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxEntriesTable extends OutboxEntries with TableInfo<$OutboxEntriesTable, OutboxEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextRetryAtMeta = const VerificationMeta('nextRetryAt');
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
    'next_retry_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    operation,
    attempts,
    lastError,
    nextRetryAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
        _nextRetryAtMeta,
        nextRetryAt.isAcceptableOrUnknown(data['next_retry_at']!, _nextRetryAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxEntry(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
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
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      nextRetryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_retry_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OutboxEntriesTable createAlias(String alias) {
    return $OutboxEntriesTable(attachedDatabase, alias);
  }
}

class OutboxEntry extends DataClass implements Insertable<OutboxEntry> {
  final int id;
  final String entityType;
  final String entityId;
  final String operation;
  final int attempts;
  final String? lastError;
  final DateTime nextRetryAt;
  final DateTime createdAt;
  const OutboxEntry({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.attempts,
    this.lastError,
    required this.nextRetryAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OutboxEntriesCompanion toCompanion(bool nullToAbsent) {
    return OutboxEntriesCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent ? const Value.absent() : Value(lastError),
      nextRetryAt: Value(nextRetryAt),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxEntry.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxEntry(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      nextRetryAt: serializer.fromJson<DateTime>(json['nextRetryAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
      'nextRetryAt': serializer.toJson<DateTime>(nextRetryAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OutboxEntry copyWith({
    int? id,
    String? entityType,
    String? entityId,
    String? operation,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
    DateTime? nextRetryAt,
    DateTime? createdAt,
  }) => OutboxEntry(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
    nextRetryAt: nextRetryAt ?? this.nextRetryAt,
    createdAt: createdAt ?? this.createdAt,
  );
  OutboxEntry copyWithCompanion(OutboxEntriesCompanion data) {
    return OutboxEntry(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      nextRetryAt: data.nextRetryAt.present ? data.nextRetryAt.value : this.nextRetryAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntry(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, entityType, entityId, operation, attempts, lastError, nextRetryAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxEntry &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError &&
          other.nextRetryAt == this.nextRetryAt &&
          other.createdAt == this.createdAt);
}

class OutboxEntriesCompanion extends UpdateCompanion<OutboxEntry> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<DateTime> nextRetryAt;
  final Value<DateTime> createdAt;
  const OutboxEntriesCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OutboxEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String entityId,
    required String operation,
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       operation = Value(operation);
  static Insertable<OutboxEntry> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<DateTime>? nextRetryAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OutboxEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operation,
    Value<int>? attempts,
    Value<String?>? lastError,
    Value<DateTime>? nextRetryAt,
    Value<DateTime>? createdAt,
  }) {
    return OutboxEntriesCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
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
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntriesCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AuraDatabase extends GeneratedDatabase {
  _$AuraDatabase(QueryExecutor e) : super(e);
  $AuraDatabaseManager get managers => $AuraDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $MedicationsTable medications = $MedicationsTable(this);
  late final $CrisesTable crises = $CrisesTable(this);
  late final $CrisisSymptomsTable crisisSymptoms = $CrisisSymptomsTable(this);
  late final $CrisisTriggersTable crisisTriggers = $CrisisTriggersTable(this);
  late final $CrisisMedicationsTable crisisMedications = $CrisisMedicationsTable(this);
  late final $OutboxEntriesTable outboxEntries = $OutboxEntriesTable(this);
  late final Index crisesUserRecentIdx = Index(
    'crises_user_recent_idx',
    'CREATE INDEX crises_user_recent_idx ON crises (user_id, occurred_at)',
  );
  late final Index outboxReadyIdx = Index(
    'outbox_ready_idx',
    'CREATE INDEX outbox_ready_idx ON outbox_entries (next_retry_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    medications,
    crises,
    crisisSymptoms,
    crisisTriggers,
    crisisMedications,
    outboxEntries,
    crisesUserRecentIdx,
    outboxReadyIdx,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName('crises', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('crisis_symptoms', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('crises', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('crisis_triggers', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('crises', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('crisis_medications', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('medications', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('crisis_medications', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      required String id,
      Value<String?> displayName,
      Value<int?> birthYear,
      Value<String?> sex,
      Value<String> locale,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<String> id,
      Value<String?> displayName,
      Value<int?> birthYear,
      Value<String?> sex,
      Value<String> locale,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ProfilesTableFilterComposer extends Composer<_$AuraDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName =>
      $composableBuilder(column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get birthYear =>
      $composableBuilder(column: $table.birthYear, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ProfilesTableOrderingComposer extends Composer<_$AuraDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName =>
      $composableBuilder(column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get birthYear =>
      $composableBuilder(column: $table.birthYear, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ProfilesTableAnnotationComposer extends Composer<_$AuraDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName =>
      $composableBuilder(column: $table.displayName, builder: (column) => column);

  GeneratedColumn<int> get birthYear =>
      $composableBuilder(column: $table.birthYear, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AuraDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, BaseReferences<_$AuraDatabase, $ProfilesTable, Profile>),
          Profile,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AuraDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<int?> birthYear = const Value.absent(),
                Value<String?> sex = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                displayName: displayName,
                birthYear: birthYear,
                sex: sex,
                locale: locale,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> displayName = const Value.absent(),
                Value<int?> birthYear = const Value.absent(),
                Value<String?> sex = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                displayName: displayName,
                birthYear: birthYear,
                sex: sex,
                locale: locale,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AuraDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, BaseReferences<_$AuraDatabase, $ProfilesTable, Profile>),
      Profile,
      PrefetchHooks Function()
    >;
typedef $$MedicationsTableCreateCompanionBuilder =
    MedicationsCompanion Function({
      required String id,
      required String userId,
      required String name,
      Value<double?> doseMg,
      Value<bool> isDefault,
      Value<bool> archived,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$MedicationsTableUpdateCompanionBuilder =
    MedicationsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<double?> doseMg,
      Value<bool> isDefault,
      Value<bool> archived,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$MedicationsTableReferences
    extends BaseReferences<_$AuraDatabase, $MedicationsTable, Medication> {
  $$MedicationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CrisisMedicationsTable, List<CrisisMedication>>
  _crisisMedicationsRefsTable(_$AuraDatabase db) => MultiTypedResultKey.fromTable(
    db.crisisMedications,
    aliasName: $_aliasNameGenerator(db.medications.id, db.crisisMedications.medicationId),
  );

  $$CrisisMedicationsTableProcessedTableManager get crisisMedicationsRefs {
    final manager = $$CrisisMedicationsTableTableManager(
      $_db,
      $_db.crisisMedications,
    ).filter((f) => f.medicationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_crisisMedicationsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MedicationsTableFilterComposer extends Composer<_$AuraDatabase, $MedicationsTable> {
  $$MedicationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get doseMg =>
      $composableBuilder(column: $table.doseMg, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> crisisMedicationsRefs(
    Expression<bool> Function($$CrisisMedicationsTableFilterComposer f) f,
  ) {
    final $$CrisisMedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.crisisMedications,
      getReferencedColumn: (t) => t.medicationId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$CrisisMedicationsTableFilterComposer(
            $db: $db,
            $table: $db.crisisMedications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicationsTableOrderingComposer extends Composer<_$AuraDatabase, $MedicationsTable> {
  $$MedicationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get doseMg =>
      $composableBuilder(column: $table.doseMg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$MedicationsTableAnnotationComposer extends Composer<_$AuraDatabase, $MedicationsTable> {
  $$MedicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get doseMg =>
      $composableBuilder(column: $table.doseMg, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> crisisMedicationsRefs<T extends Object>(
    Expression<T> Function($$CrisisMedicationsTableAnnotationComposer a) f,
  ) {
    final $$CrisisMedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.crisisMedications,
      getReferencedColumn: (t) => t.medicationId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$CrisisMedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.crisisMedications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicationsTableTableManager
    extends
        RootTableManager<
          _$AuraDatabase,
          $MedicationsTable,
          Medication,
          $$MedicationsTableFilterComposer,
          $$MedicationsTableOrderingComposer,
          $$MedicationsTableAnnotationComposer,
          $$MedicationsTableCreateCompanionBuilder,
          $$MedicationsTableUpdateCompanionBuilder,
          (Medication, $$MedicationsTableReferences),
          Medication,
          PrefetchHooks Function({bool crisisMedicationsRefs})
        > {
  $$MedicationsTableTableManager(_$AuraDatabase db, $MedicationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$MedicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$MedicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double?> doseMg = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationsCompanion(
                id: id,
                userId: userId,
                name: name,
                doseMg: doseMg,
                isDefault: isDefault,
                archived: archived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                Value<double?> doseMg = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationsCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                doseMg: doseMg,
                isDefault: isDefault,
                archived: archived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $$MedicationsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({crisisMedicationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (crisisMedicationsRefs) db.crisisMedications],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (crisisMedicationsRefs)
                    await $_getPrefetchedData<Medication, $MedicationsTable, CrisisMedication>(
                      currentTable: table,
                      referencedTable: $$MedicationsTableReferences._crisisMedicationsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MedicationsTableReferences(db, table, p0).crisisMedicationsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.medicationId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MedicationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AuraDatabase,
      $MedicationsTable,
      Medication,
      $$MedicationsTableFilterComposer,
      $$MedicationsTableOrderingComposer,
      $$MedicationsTableAnnotationComposer,
      $$MedicationsTableCreateCompanionBuilder,
      $$MedicationsTableUpdateCompanionBuilder,
      (Medication, $$MedicationsTableReferences),
      Medication,
      PrefetchHooks Function({bool crisisMedicationsRefs})
    >;
typedef $$CrisesTableCreateCompanionBuilder =
    CrisesCompanion Function({
      required String id,
      required String userId,
      required DateTime occurredAt,
      required int intensity,
      Value<String?> location,
      Value<String?> notes,
      Value<DateTime?> resolvedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$CrisesTableUpdateCompanionBuilder =
    CrisesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<DateTime> occurredAt,
      Value<int> intensity,
      Value<String?> location,
      Value<String?> notes,
      Value<DateTime?> resolvedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CrisesTableReferences extends BaseReferences<_$AuraDatabase, $CrisesTable, Crisis> {
  $$CrisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CrisisSymptomsTable, List<CrisisSymptom>> _crisisSymptomsRefsTable(
    _$AuraDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.crisisSymptoms,
    aliasName: $_aliasNameGenerator(db.crises.id, db.crisisSymptoms.crisisId),
  );

  $$CrisisSymptomsTableProcessedTableManager get crisisSymptomsRefs {
    final manager = $$CrisisSymptomsTableTableManager(
      $_db,
      $_db.crisisSymptoms,
    ).filter((f) => f.crisisId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_crisisSymptomsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$CrisisTriggersTable, List<CrisisTrigger>> _crisisTriggersRefsTable(
    _$AuraDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.crisisTriggers,
    aliasName: $_aliasNameGenerator(db.crises.id, db.crisisTriggers.crisisId),
  );

  $$CrisisTriggersTableProcessedTableManager get crisisTriggersRefs {
    final manager = $$CrisisTriggersTableTableManager(
      $_db,
      $_db.crisisTriggers,
    ).filter((f) => f.crisisId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_crisisTriggersRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$CrisisMedicationsTable, List<CrisisMedication>>
  _crisisMedicationsRefsTable(_$AuraDatabase db) => MultiTypedResultKey.fromTable(
    db.crisisMedications,
    aliasName: $_aliasNameGenerator(db.crises.id, db.crisisMedications.crisisId),
  );

  $$CrisisMedicationsTableProcessedTableManager get crisisMedicationsRefs {
    final manager = $$CrisisMedicationsTableTableManager(
      $_db,
      $_db.crisisMedications,
    ).filter((f) => f.crisisId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_crisisMedicationsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CrisesTableFilterComposer extends Composer<_$AuraDatabase, $CrisesTable> {
  $$CrisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get intensity =>
      $composableBuilder(column: $table.intensity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get resolvedAt =>
      $composableBuilder(column: $table.resolvedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> crisisSymptomsRefs(
    Expression<bool> Function($$CrisisSymptomsTableFilterComposer f) f,
  ) {
    final $$CrisisSymptomsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.crisisSymptoms,
      getReferencedColumn: (t) => t.crisisId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$CrisisSymptomsTableFilterComposer(
            $db: $db,
            $table: $db.crisisSymptoms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> crisisTriggersRefs(
    Expression<bool> Function($$CrisisTriggersTableFilterComposer f) f,
  ) {
    final $$CrisisTriggersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.crisisTriggers,
      getReferencedColumn: (t) => t.crisisId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$CrisisTriggersTableFilterComposer(
            $db: $db,
            $table: $db.crisisTriggers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> crisisMedicationsRefs(
    Expression<bool> Function($$CrisisMedicationsTableFilterComposer f) f,
  ) {
    final $$CrisisMedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.crisisMedications,
      getReferencedColumn: (t) => t.crisisId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$CrisisMedicationsTableFilterComposer(
            $db: $db,
            $table: $db.crisisMedications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CrisesTableOrderingComposer extends Composer<_$AuraDatabase, $CrisesTable> {
  $$CrisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get intensity =>
      $composableBuilder(column: $table.intensity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get resolvedAt =>
      $composableBuilder(column: $table.resolvedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CrisesTableAnnotationComposer extends Composer<_$AuraDatabase, $CrisesTable> {
  $$CrisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => column);

  GeneratedColumn<int> get intensity =>
      $composableBuilder(column: $table.intensity, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt =>
      $composableBuilder(column: $table.resolvedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> crisisSymptomsRefs<T extends Object>(
    Expression<T> Function($$CrisisSymptomsTableAnnotationComposer a) f,
  ) {
    final $$CrisisSymptomsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.crisisSymptoms,
      getReferencedColumn: (t) => t.crisisId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$CrisisSymptomsTableAnnotationComposer(
            $db: $db,
            $table: $db.crisisSymptoms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> crisisTriggersRefs<T extends Object>(
    Expression<T> Function($$CrisisTriggersTableAnnotationComposer a) f,
  ) {
    final $$CrisisTriggersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.crisisTriggers,
      getReferencedColumn: (t) => t.crisisId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$CrisisTriggersTableAnnotationComposer(
            $db: $db,
            $table: $db.crisisTriggers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> crisisMedicationsRefs<T extends Object>(
    Expression<T> Function($$CrisisMedicationsTableAnnotationComposer a) f,
  ) {
    final $$CrisisMedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.crisisMedications,
      getReferencedColumn: (t) => t.crisisId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$CrisisMedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.crisisMedications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CrisesTableTableManager
    extends
        RootTableManager<
          _$AuraDatabase,
          $CrisesTable,
          Crisis,
          $$CrisesTableFilterComposer,
          $$CrisesTableOrderingComposer,
          $$CrisesTableAnnotationComposer,
          $$CrisesTableCreateCompanionBuilder,
          $$CrisesTableUpdateCompanionBuilder,
          (Crisis, $$CrisesTableReferences),
          Crisis,
          PrefetchHooks Function({
            bool crisisSymptomsRefs,
            bool crisisTriggersRefs,
            bool crisisMedicationsRefs,
          })
        > {
  $$CrisesTableTableManager(_$AuraDatabase db, $CrisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$CrisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$CrisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CrisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<int> intensity = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CrisesCompanion(
                id: id,
                userId: userId,
                occurredAt: occurredAt,
                intensity: intensity,
                location: location,
                notes: notes,
                resolvedAt: resolvedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required DateTime occurredAt,
                required int intensity,
                Value<String?> location = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CrisesCompanion.insert(
                id: id,
                userId: userId,
                occurredAt: occurredAt,
                intensity: intensity,
                location: location,
                notes: notes,
                resolvedAt: resolvedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$CrisesTableReferences(db, table, e))).toList(),
          prefetchHooksCallback:
              ({
                crisisSymptomsRefs = false,
                crisisTriggersRefs = false,
                crisisMedicationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (crisisSymptomsRefs) db.crisisSymptoms,
                    if (crisisTriggersRefs) db.crisisTriggers,
                    if (crisisMedicationsRefs) db.crisisMedications,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (crisisSymptomsRefs)
                        await $_getPrefetchedData<Crisis, $CrisesTable, CrisisSymptom>(
                          currentTable: table,
                          referencedTable: $$CrisesTableReferences._crisisSymptomsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CrisesTableReferences(db, table, p0).crisisSymptomsRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where((e) => e.crisisId == item.id),
                          typedResults: items,
                        ),
                      if (crisisTriggersRefs)
                        await $_getPrefetchedData<Crisis, $CrisesTable, CrisisTrigger>(
                          currentTable: table,
                          referencedTable: $$CrisesTableReferences._crisisTriggersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CrisesTableReferences(db, table, p0).crisisTriggersRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where((e) => e.crisisId == item.id),
                          typedResults: items,
                        ),
                      if (crisisMedicationsRefs)
                        await $_getPrefetchedData<Crisis, $CrisesTable, CrisisMedication>(
                          currentTable: table,
                          referencedTable: $$CrisesTableReferences._crisisMedicationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CrisesTableReferences(db, table, p0).crisisMedicationsRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where((e) => e.crisisId == item.id),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CrisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AuraDatabase,
      $CrisesTable,
      Crisis,
      $$CrisesTableFilterComposer,
      $$CrisesTableOrderingComposer,
      $$CrisesTableAnnotationComposer,
      $$CrisesTableCreateCompanionBuilder,
      $$CrisesTableUpdateCompanionBuilder,
      (Crisis, $$CrisesTableReferences),
      Crisis,
      PrefetchHooks Function({
        bool crisisSymptomsRefs,
        bool crisisTriggersRefs,
        bool crisisMedicationsRefs,
      })
    >;
typedef $$CrisisSymptomsTableCreateCompanionBuilder =
    CrisisSymptomsCompanion Function({
      required String crisisId,
      required String symptom,
      Value<int> rowid,
    });
typedef $$CrisisSymptomsTableUpdateCompanionBuilder =
    CrisisSymptomsCompanion Function({
      Value<String> crisisId,
      Value<String> symptom,
      Value<int> rowid,
    });

final class $$CrisisSymptomsTableReferences
    extends BaseReferences<_$AuraDatabase, $CrisisSymptomsTable, CrisisSymptom> {
  $$CrisisSymptomsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CrisesTable _crisisIdTable(_$AuraDatabase db) =>
      db.crises.createAlias($_aliasNameGenerator(db.crisisSymptoms.crisisId, db.crises.id));

  $$CrisesTableProcessedTableManager get crisisId {
    final $_column = $_itemColumn<String>('crisis_id')!;

    final manager = $$CrisesTableTableManager(
      $_db,
      $_db.crises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_crisisIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CrisisSymptomsTableFilterComposer extends Composer<_$AuraDatabase, $CrisisSymptomsTable> {
  $$CrisisSymptomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get symptom =>
      $composableBuilder(column: $table.symptom, builder: (column) => ColumnFilters(column));

  $$CrisesTableFilterComposer get crisisId {
    final $$CrisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.crisisId,
      referencedTable: $db.crises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$CrisesTableFilterComposer(
            $db: $db,
            $table: $db.crises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CrisisSymptomsTableOrderingComposer extends Composer<_$AuraDatabase, $CrisisSymptomsTable> {
  $$CrisisSymptomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get symptom =>
      $composableBuilder(column: $table.symptom, builder: (column) => ColumnOrderings(column));

  $$CrisesTableOrderingComposer get crisisId {
    final $$CrisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.crisisId,
      referencedTable: $db.crises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$CrisesTableOrderingComposer(
            $db: $db,
            $table: $db.crises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CrisisSymptomsTableAnnotationComposer
    extends Composer<_$AuraDatabase, $CrisisSymptomsTable> {
  $$CrisisSymptomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get symptom =>
      $composableBuilder(column: $table.symptom, builder: (column) => column);

  $$CrisesTableAnnotationComposer get crisisId {
    final $$CrisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.crisisId,
      referencedTable: $db.crises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$CrisesTableAnnotationComposer(
            $db: $db,
            $table: $db.crises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CrisisSymptomsTableTableManager
    extends
        RootTableManager<
          _$AuraDatabase,
          $CrisisSymptomsTable,
          CrisisSymptom,
          $$CrisisSymptomsTableFilterComposer,
          $$CrisisSymptomsTableOrderingComposer,
          $$CrisisSymptomsTableAnnotationComposer,
          $$CrisisSymptomsTableCreateCompanionBuilder,
          $$CrisisSymptomsTableUpdateCompanionBuilder,
          (CrisisSymptom, $$CrisisSymptomsTableReferences),
          CrisisSymptom,
          PrefetchHooks Function({bool crisisId})
        > {
  $$CrisisSymptomsTableTableManager(_$AuraDatabase db, $CrisisSymptomsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CrisisSymptomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CrisisSymptomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CrisisSymptomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> crisisId = const Value.absent(),
                Value<String> symptom = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CrisisSymptomsCompanion(crisisId: crisisId, symptom: symptom, rowid: rowid),
          createCompanionCallback:
              ({
                required String crisisId,
                required String symptom,
                Value<int> rowid = const Value.absent(),
              }) => CrisisSymptomsCompanion.insert(
                crisisId: crisisId,
                symptom: symptom,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $$CrisisSymptomsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({crisisId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (crisisId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.crisisId,
                                referencedTable: $$CrisisSymptomsTableReferences._crisisIdTable(db),
                                referencedColumn: $$CrisisSymptomsTableReferences
                                    ._crisisIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CrisisSymptomsTableProcessedTableManager =
    ProcessedTableManager<
      _$AuraDatabase,
      $CrisisSymptomsTable,
      CrisisSymptom,
      $$CrisisSymptomsTableFilterComposer,
      $$CrisisSymptomsTableOrderingComposer,
      $$CrisisSymptomsTableAnnotationComposer,
      $$CrisisSymptomsTableCreateCompanionBuilder,
      $$CrisisSymptomsTableUpdateCompanionBuilder,
      (CrisisSymptom, $$CrisisSymptomsTableReferences),
      CrisisSymptom,
      PrefetchHooks Function({bool crisisId})
    >;
typedef $$CrisisTriggersTableCreateCompanionBuilder =
    CrisisTriggersCompanion Function({
      required String crisisId,
      required String trigger,
      Value<int> rowid,
    });
typedef $$CrisisTriggersTableUpdateCompanionBuilder =
    CrisisTriggersCompanion Function({
      Value<String> crisisId,
      Value<String> trigger,
      Value<int> rowid,
    });

final class $$CrisisTriggersTableReferences
    extends BaseReferences<_$AuraDatabase, $CrisisTriggersTable, CrisisTrigger> {
  $$CrisisTriggersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CrisesTable _crisisIdTable(_$AuraDatabase db) =>
      db.crises.createAlias($_aliasNameGenerator(db.crisisTriggers.crisisId, db.crises.id));

  $$CrisesTableProcessedTableManager get crisisId {
    final $_column = $_itemColumn<String>('crisis_id')!;

    final manager = $$CrisesTableTableManager(
      $_db,
      $_db.crises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_crisisIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CrisisTriggersTableFilterComposer extends Composer<_$AuraDatabase, $CrisisTriggersTable> {
  $$CrisisTriggersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get trigger =>
      $composableBuilder(column: $table.trigger, builder: (column) => ColumnFilters(column));

  $$CrisesTableFilterComposer get crisisId {
    final $$CrisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.crisisId,
      referencedTable: $db.crises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$CrisesTableFilterComposer(
            $db: $db,
            $table: $db.crises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CrisisTriggersTableOrderingComposer extends Composer<_$AuraDatabase, $CrisisTriggersTable> {
  $$CrisisTriggersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get trigger =>
      $composableBuilder(column: $table.trigger, builder: (column) => ColumnOrderings(column));

  $$CrisesTableOrderingComposer get crisisId {
    final $$CrisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.crisisId,
      referencedTable: $db.crises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$CrisesTableOrderingComposer(
            $db: $db,
            $table: $db.crises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CrisisTriggersTableAnnotationComposer
    extends Composer<_$AuraDatabase, $CrisisTriggersTable> {
  $$CrisisTriggersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get trigger =>
      $composableBuilder(column: $table.trigger, builder: (column) => column);

  $$CrisesTableAnnotationComposer get crisisId {
    final $$CrisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.crisisId,
      referencedTable: $db.crises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$CrisesTableAnnotationComposer(
            $db: $db,
            $table: $db.crises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CrisisTriggersTableTableManager
    extends
        RootTableManager<
          _$AuraDatabase,
          $CrisisTriggersTable,
          CrisisTrigger,
          $$CrisisTriggersTableFilterComposer,
          $$CrisisTriggersTableOrderingComposer,
          $$CrisisTriggersTableAnnotationComposer,
          $$CrisisTriggersTableCreateCompanionBuilder,
          $$CrisisTriggersTableUpdateCompanionBuilder,
          (CrisisTrigger, $$CrisisTriggersTableReferences),
          CrisisTrigger,
          PrefetchHooks Function({bool crisisId})
        > {
  $$CrisisTriggersTableTableManager(_$AuraDatabase db, $CrisisTriggersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CrisisTriggersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CrisisTriggersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CrisisTriggersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> crisisId = const Value.absent(),
                Value<String> trigger = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CrisisTriggersCompanion(crisisId: crisisId, trigger: trigger, rowid: rowid),
          createCompanionCallback:
              ({
                required String crisisId,
                required String trigger,
                Value<int> rowid = const Value.absent(),
              }) => CrisisTriggersCompanion.insert(
                crisisId: crisisId,
                trigger: trigger,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $$CrisisTriggersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({crisisId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (crisisId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.crisisId,
                                referencedTable: $$CrisisTriggersTableReferences._crisisIdTable(db),
                                referencedColumn: $$CrisisTriggersTableReferences
                                    ._crisisIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CrisisTriggersTableProcessedTableManager =
    ProcessedTableManager<
      _$AuraDatabase,
      $CrisisTriggersTable,
      CrisisTrigger,
      $$CrisisTriggersTableFilterComposer,
      $$CrisisTriggersTableOrderingComposer,
      $$CrisisTriggersTableAnnotationComposer,
      $$CrisisTriggersTableCreateCompanionBuilder,
      $$CrisisTriggersTableUpdateCompanionBuilder,
      (CrisisTrigger, $$CrisisTriggersTableReferences),
      CrisisTrigger,
      PrefetchHooks Function({bool crisisId})
    >;
typedef $$CrisisMedicationsTableCreateCompanionBuilder =
    CrisisMedicationsCompanion Function({
      required String id,
      required String crisisId,
      Value<String?> medicationId,
      required String medicationNameSnapshot,
      Value<double?> doseMg,
      required DateTime takenAt,
      Value<DateTime?> reliefAt,
      Value<bool?> effective,
      Value<int> rowid,
    });
typedef $$CrisisMedicationsTableUpdateCompanionBuilder =
    CrisisMedicationsCompanion Function({
      Value<String> id,
      Value<String> crisisId,
      Value<String?> medicationId,
      Value<String> medicationNameSnapshot,
      Value<double?> doseMg,
      Value<DateTime> takenAt,
      Value<DateTime?> reliefAt,
      Value<bool?> effective,
      Value<int> rowid,
    });

final class $$CrisisMedicationsTableReferences
    extends BaseReferences<_$AuraDatabase, $CrisisMedicationsTable, CrisisMedication> {
  $$CrisisMedicationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CrisesTable _crisisIdTable(_$AuraDatabase db) =>
      db.crises.createAlias($_aliasNameGenerator(db.crisisMedications.crisisId, db.crises.id));

  $$CrisesTableProcessedTableManager get crisisId {
    final $_column = $_itemColumn<String>('crisis_id')!;

    final manager = $$CrisesTableTableManager(
      $_db,
      $_db.crises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_crisisIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $MedicationsTable _medicationIdTable(_$AuraDatabase db) => db.medications.createAlias(
    $_aliasNameGenerator(db.crisisMedications.medicationId, db.medications.id),
  );

  $$MedicationsTableProcessedTableManager? get medicationId {
    final $_column = $_itemColumn<String>('medication_id');
    if ($_column == null) return null;
    final manager = $$MedicationsTableTableManager(
      $_db,
      $_db.medications,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CrisisMedicationsTableFilterComposer
    extends Composer<_$AuraDatabase, $CrisisMedicationsTable> {
  $$CrisisMedicationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get medicationNameSnapshot => $composableBuilder(
    column: $table.medicationNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get doseMg =>
      $composableBuilder(column: $table.doseMg, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get reliefAt =>
      $composableBuilder(column: $table.reliefAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get effective =>
      $composableBuilder(column: $table.effective, builder: (column) => ColumnFilters(column));

  $$CrisesTableFilterComposer get crisisId {
    final $$CrisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.crisisId,
      referencedTable: $db.crises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$CrisesTableFilterComposer(
            $db: $db,
            $table: $db.crises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MedicationsTableFilterComposer get medicationId {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MedicationsTableFilterComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CrisisMedicationsTableOrderingComposer
    extends Composer<_$AuraDatabase, $CrisisMedicationsTable> {
  $$CrisisMedicationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get medicationNameSnapshot => $composableBuilder(
    column: $table.medicationNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get doseMg =>
      $composableBuilder(column: $table.doseMg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get reliefAt =>
      $composableBuilder(column: $table.reliefAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get effective =>
      $composableBuilder(column: $table.effective, builder: (column) => ColumnOrderings(column));

  $$CrisesTableOrderingComposer get crisisId {
    final $$CrisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.crisisId,
      referencedTable: $db.crises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$CrisesTableOrderingComposer(
            $db: $db,
            $table: $db.crises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MedicationsTableOrderingComposer get medicationId {
    final $$MedicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MedicationsTableOrderingComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CrisisMedicationsTableAnnotationComposer
    extends Composer<_$AuraDatabase, $CrisisMedicationsTable> {
  $$CrisisMedicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get medicationNameSnapshot =>
      $composableBuilder(column: $table.medicationNameSnapshot, builder: (column) => column);

  GeneratedColumn<double> get doseMg =>
      $composableBuilder(column: $table.doseMg, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<DateTime> get reliefAt =>
      $composableBuilder(column: $table.reliefAt, builder: (column) => column);

  GeneratedColumn<bool> get effective =>
      $composableBuilder(column: $table.effective, builder: (column) => column);

  $$CrisesTableAnnotationComposer get crisisId {
    final $$CrisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.crisisId,
      referencedTable: $db.crises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$CrisesTableAnnotationComposer(
            $db: $db,
            $table: $db.crises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MedicationsTableAnnotationComposer get medicationId {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CrisisMedicationsTableTableManager
    extends
        RootTableManager<
          _$AuraDatabase,
          $CrisisMedicationsTable,
          CrisisMedication,
          $$CrisisMedicationsTableFilterComposer,
          $$CrisisMedicationsTableOrderingComposer,
          $$CrisisMedicationsTableAnnotationComposer,
          $$CrisisMedicationsTableCreateCompanionBuilder,
          $$CrisisMedicationsTableUpdateCompanionBuilder,
          (CrisisMedication, $$CrisisMedicationsTableReferences),
          CrisisMedication,
          PrefetchHooks Function({bool crisisId, bool medicationId})
        > {
  $$CrisisMedicationsTableTableManager(_$AuraDatabase db, $CrisisMedicationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CrisisMedicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CrisisMedicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CrisisMedicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> crisisId = const Value.absent(),
                Value<String?> medicationId = const Value.absent(),
                Value<String> medicationNameSnapshot = const Value.absent(),
                Value<double?> doseMg = const Value.absent(),
                Value<DateTime> takenAt = const Value.absent(),
                Value<DateTime?> reliefAt = const Value.absent(),
                Value<bool?> effective = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CrisisMedicationsCompanion(
                id: id,
                crisisId: crisisId,
                medicationId: medicationId,
                medicationNameSnapshot: medicationNameSnapshot,
                doseMg: doseMg,
                takenAt: takenAt,
                reliefAt: reliefAt,
                effective: effective,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String crisisId,
                Value<String?> medicationId = const Value.absent(),
                required String medicationNameSnapshot,
                Value<double?> doseMg = const Value.absent(),
                required DateTime takenAt,
                Value<DateTime?> reliefAt = const Value.absent(),
                Value<bool?> effective = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CrisisMedicationsCompanion.insert(
                id: id,
                crisisId: crisisId,
                medicationId: medicationId,
                medicationNameSnapshot: medicationNameSnapshot,
                doseMg: doseMg,
                takenAt: takenAt,
                reliefAt: reliefAt,
                effective: effective,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $$CrisisMedicationsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({crisisId = false, medicationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (crisisId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.crisisId,
                                referencedTable: $$CrisisMedicationsTableReferences._crisisIdTable(
                                  db,
                                ),
                                referencedColumn: $$CrisisMedicationsTableReferences
                                    ._crisisIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (medicationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.medicationId,
                                referencedTable: $$CrisisMedicationsTableReferences
                                    ._medicationIdTable(db),
                                referencedColumn: $$CrisisMedicationsTableReferences
                                    ._medicationIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CrisisMedicationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AuraDatabase,
      $CrisisMedicationsTable,
      CrisisMedication,
      $$CrisisMedicationsTableFilterComposer,
      $$CrisisMedicationsTableOrderingComposer,
      $$CrisisMedicationsTableAnnotationComposer,
      $$CrisisMedicationsTableCreateCompanionBuilder,
      $$CrisisMedicationsTableUpdateCompanionBuilder,
      (CrisisMedication, $$CrisisMedicationsTableReferences),
      CrisisMedication,
      PrefetchHooks Function({bool crisisId, bool medicationId})
    >;
typedef $$OutboxEntriesTableCreateCompanionBuilder =
    OutboxEntriesCompanion Function({
      Value<int> id,
      required String entityType,
      required String entityId,
      required String operation,
      Value<int> attempts,
      Value<String?> lastError,
      Value<DateTime> nextRetryAt,
      Value<DateTime> createdAt,
    });
typedef $$OutboxEntriesTableUpdateCompanionBuilder =
    OutboxEntriesCompanion Function({
      Value<int> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> operation,
      Value<int> attempts,
      Value<String?> lastError,
      Value<DateTime> nextRetryAt,
      Value<DateTime> createdAt,
    });

class $$OutboxEntriesTableFilterComposer extends Composer<_$AuraDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType =>
      $composableBuilder(column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextRetryAt =>
      $composableBuilder(column: $table.nextRetryAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$OutboxEntriesTableOrderingComposer extends Composer<_$AuraDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType =>
      $composableBuilder(column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextRetryAt =>
      $composableBuilder(column: $table.nextRetryAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$OutboxEntriesTableAnnotationComposer extends Composer<_$AuraDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType =>
      $composableBuilder(column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRetryAt =>
      $composableBuilder(column: $table.nextRetryAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutboxEntriesTableTableManager
    extends
        RootTableManager<
          _$AuraDatabase,
          $OutboxEntriesTable,
          OutboxEntry,
          $$OutboxEntriesTableFilterComposer,
          $$OutboxEntriesTableOrderingComposer,
          $$OutboxEntriesTableAnnotationComposer,
          $$OutboxEntriesTableCreateCompanionBuilder,
          $$OutboxEntriesTableUpdateCompanionBuilder,
          (OutboxEntry, BaseReferences<_$AuraDatabase, $OutboxEntriesTable, OutboxEntry>),
          OutboxEntry,
          PrefetchHooks Function()
        > {
  $$OutboxEntriesTableTableManager(_$AuraDatabase db, $OutboxEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$OutboxEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> nextRetryAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => OutboxEntriesCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                attempts: attempts,
                lastError: lastError,
                nextRetryAt: nextRetryAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityType,
                required String entityId,
                required String operation,
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> nextRetryAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => OutboxEntriesCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                attempts: attempts,
                lastError: lastError,
                nextRetryAt: nextRetryAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AuraDatabase,
      $OutboxEntriesTable,
      OutboxEntry,
      $$OutboxEntriesTableFilterComposer,
      $$OutboxEntriesTableOrderingComposer,
      $$OutboxEntriesTableAnnotationComposer,
      $$OutboxEntriesTableCreateCompanionBuilder,
      $$OutboxEntriesTableUpdateCompanionBuilder,
      (OutboxEntry, BaseReferences<_$AuraDatabase, $OutboxEntriesTable, OutboxEntry>),
      OutboxEntry,
      PrefetchHooks Function()
    >;

class $AuraDatabaseManager {
  final _$AuraDatabase _db;
  $AuraDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles => $$ProfilesTableTableManager(_db, _db.profiles);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db, _db.medications);
  $$CrisesTableTableManager get crises => $$CrisesTableTableManager(_db, _db.crises);
  $$CrisisSymptomsTableTableManager get crisisSymptoms =>
      $$CrisisSymptomsTableTableManager(_db, _db.crisisSymptoms);
  $$CrisisTriggersTableTableManager get crisisTriggers =>
      $$CrisisTriggersTableTableManager(_db, _db.crisisTriggers);
  $$CrisisMedicationsTableTableManager get crisisMedications =>
      $$CrisisMedicationsTableTableManager(_db, _db.crisisMedications);
  $$OutboxEntriesTableTableManager get outboxEntries =>
      $$OutboxEntriesTableTableManager(_db, _db.outboxEntries);
}
