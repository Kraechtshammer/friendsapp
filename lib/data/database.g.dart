// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingEntry extends DataClass implements Insertable<SettingEntry> {
  final String key;
  final String value;
  const SettingEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingEntry copyWith({String? key, String? value}) =>
      SettingEntry(key: key ?? this.key, value: value ?? this.value);
  SettingEntry copyWithCompanion(SettingsCompanion data) {
    return SettingEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<SettingEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PeopleTable extends People with TableInfo<$PeopleTable, Person> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeopleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactIdMeta = const VerificationMeta(
    'contactId',
  );
  @override
  late final GeneratedColumn<String> contactId = GeneratedColumn<String>(
    'contact_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Closeness, String> closeness =
      GeneratedColumn<String>(
        'closeness',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Closeness>($PeopleTable.$convertercloseness);
  static const VerificationMeta _reconnectingMeta = const VerificationMeta(
    'reconnecting',
  );
  @override
  late final GeneratedColumn<bool> reconnecting = GeneratedColumn<bool>(
    'reconnecting',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reconnecting" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _rhythmDaysMeta = const VerificationMeta(
    'rhythmDays',
  );
  @override
  late final GeneratedColumn<int> rhythmDays = GeneratedColumn<int>(
    'rhythm_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Messenger?, String>
  mainMessenger = GeneratedColumn<String>(
    'main_messenger',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<Messenger?>($PeopleTable.$convertermainMessengern);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _telegramUsernameMeta = const VerificationMeta(
    'telegramUsername',
  );
  @override
  late final GeneratedColumn<String> telegramUsername = GeneratedColumn<String>(
    'telegram_username',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _signalLinkMeta = const VerificationMeta(
    'signalLink',
  );
  @override
  late final GeneratedColumn<String> signalLink = GeneratedColumn<String>(
    'signal_link',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discordUserIdMeta = const VerificationMeta(
    'discordUserId',
  );
  @override
  late final GeneratedColumn<String> discordUserId = GeneratedColumn<String>(
    'discord_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthdayMonthMeta = const VerificationMeta(
    'birthdayMonth',
  );
  @override
  late final GeneratedColumn<int> birthdayMonth = GeneratedColumn<int>(
    'birthday_month',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthdayDayMeta = const VerificationMeta(
    'birthdayDay',
  );
  @override
  late final GeneratedColumn<int> birthdayDay = GeneratedColumn<int>(
    'birthday_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthdayYearMeta = const VerificationMeta(
    'birthdayYear',
  );
  @override
  late final GeneratedColumn<int> birthdayYear = GeneratedColumn<int>(
    'birthday_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AvatarShape, String> avatarShape =
      GeneratedColumn<String>(
        'avatar_shape',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AvatarShape>($PeopleTable.$converteravatarShape);
  @override
  late final GeneratedColumnWithTypeConverter<AvatarColor, String> avatarColor =
      GeneratedColumn<String>(
        'avatar_color',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AvatarColor>($PeopleTable.$converteravatarColor);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    name,
    contactId,
    closeness,
    reconnecting,
    rhythmDays,
    mainMessenger,
    phone,
    telegramUsername,
    signalLink,
    discordUserId,
    birthdayMonth,
    birthdayDay,
    birthdayYear,
    avatarShape,
    avatarColor,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'people';
  @override
  VerificationContext validateIntegrity(
    Insertable<Person> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('contact_id')) {
      context.handle(
        _contactIdMeta,
        contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta),
      );
    }
    if (data.containsKey('reconnecting')) {
      context.handle(
        _reconnectingMeta,
        reconnecting.isAcceptableOrUnknown(
          data['reconnecting']!,
          _reconnectingMeta,
        ),
      );
    }
    if (data.containsKey('rhythm_days')) {
      context.handle(
        _rhythmDaysMeta,
        rhythmDays.isAcceptableOrUnknown(data['rhythm_days']!, _rhythmDaysMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('telegram_username')) {
      context.handle(
        _telegramUsernameMeta,
        telegramUsername.isAcceptableOrUnknown(
          data['telegram_username']!,
          _telegramUsernameMeta,
        ),
      );
    }
    if (data.containsKey('signal_link')) {
      context.handle(
        _signalLinkMeta,
        signalLink.isAcceptableOrUnknown(data['signal_link']!, _signalLinkMeta),
      );
    }
    if (data.containsKey('discord_user_id')) {
      context.handle(
        _discordUserIdMeta,
        discordUserId.isAcceptableOrUnknown(
          data['discord_user_id']!,
          _discordUserIdMeta,
        ),
      );
    }
    if (data.containsKey('birthday_month')) {
      context.handle(
        _birthdayMonthMeta,
        birthdayMonth.isAcceptableOrUnknown(
          data['birthday_month']!,
          _birthdayMonthMeta,
        ),
      );
    }
    if (data.containsKey('birthday_day')) {
      context.handle(
        _birthdayDayMeta,
        birthdayDay.isAcceptableOrUnknown(
          data['birthday_day']!,
          _birthdayDayMeta,
        ),
      );
    }
    if (data.containsKey('birthday_year')) {
      context.handle(
        _birthdayYearMeta,
        birthdayYear.isAcceptableOrUnknown(
          data['birthday_year']!,
          _birthdayYearMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
  Person map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Person(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      contactId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_id'],
      ),
      closeness: $PeopleTable.$convertercloseness.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}closeness'],
        )!,
      ),
      reconnecting: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reconnecting'],
      )!,
      rhythmDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rhythm_days'],
      ),
      mainMessenger: $PeopleTable.$convertermainMessengern.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}main_messenger'],
        ),
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      telegramUsername: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telegram_username'],
      ),
      signalLink: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signal_link'],
      ),
      discordUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discord_user_id'],
      ),
      birthdayMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birthday_month'],
      ),
      birthdayDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birthday_day'],
      ),
      birthdayYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birthday_year'],
      ),
      avatarShape: $PeopleTable.$converteravatarShape.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}avatar_shape'],
        )!,
      ),
      avatarColor: $PeopleTable.$converteravatarColor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}avatar_color'],
        )!,
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PeopleTable createAlias(String alias) {
    return $PeopleTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Closeness, String, String> $convertercloseness =
      const EnumNameConverter<Closeness>(Closeness.values);
  static JsonTypeConverter2<Messenger, String, String> $convertermainMessenger =
      const EnumNameConverter<Messenger>(Messenger.values);
  static JsonTypeConverter2<Messenger?, String?, String?>
  $convertermainMessengern = JsonTypeConverter2.asNullable(
    $convertermainMessenger,
  );
  static JsonTypeConverter2<AvatarShape, String, String> $converteravatarShape =
      const EnumNameConverter<AvatarShape>(AvatarShape.values);
  static JsonTypeConverter2<AvatarColor, String, String> $converteravatarColor =
      const EnumNameConverter<AvatarColor>(AvatarColor.values);
}

class Person extends DataClass implements Insertable<Person> {
  /// UUID v4, made by PeopleRepository, so backups can be merged later.
  final String id;
  final String name;

  /// The phone contact the person was imported from. Name, number and
  /// birthday are copied once; the link stays for a later refresh.
  final String? contactId;
  final Closeness closeness;

  /// "Getting back in touch", on top of the class.
  final bool reconnecting;

  /// The person's own rhythm in days. null = the class default.
  final int? rhythmDays;

  /// What "Open chat" uses. null = no messenger chosen.
  final Messenger? mainMessenger;

  /// International form. Serves WhatsApp, Signal and Telegram by number.
  final String? phone;

  /// One handle per messenger besides the phone number.
  final String? telegramUsername;
  final String? signalLink;
  final String? discordUserId;

  /// The birthday. The year is often unknown.
  final int? birthdayMonth;
  final int? birthdayDay;
  final int? birthdayYear;

  /// Picked when the person is added (domain/avatar_pick.dart).
  final AvatarShape avatarShape;
  final AvatarColor avatarColor;
  final String notes;
  final DateTime createdAt;
  const Person({
    required this.id,
    required this.name,
    this.contactId,
    required this.closeness,
    required this.reconnecting,
    this.rhythmDays,
    this.mainMessenger,
    this.phone,
    this.telegramUsername,
    this.signalLink,
    this.discordUserId,
    this.birthdayMonth,
    this.birthdayDay,
    this.birthdayYear,
    required this.avatarShape,
    required this.avatarColor,
    required this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || contactId != null) {
      map['contact_id'] = Variable<String>(contactId);
    }
    {
      map['closeness'] = Variable<String>(
        $PeopleTable.$convertercloseness.toSql(closeness),
      );
    }
    map['reconnecting'] = Variable<bool>(reconnecting);
    if (!nullToAbsent || rhythmDays != null) {
      map['rhythm_days'] = Variable<int>(rhythmDays);
    }
    if (!nullToAbsent || mainMessenger != null) {
      map['main_messenger'] = Variable<String>(
        $PeopleTable.$convertermainMessengern.toSql(mainMessenger),
      );
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || telegramUsername != null) {
      map['telegram_username'] = Variable<String>(telegramUsername);
    }
    if (!nullToAbsent || signalLink != null) {
      map['signal_link'] = Variable<String>(signalLink);
    }
    if (!nullToAbsent || discordUserId != null) {
      map['discord_user_id'] = Variable<String>(discordUserId);
    }
    if (!nullToAbsent || birthdayMonth != null) {
      map['birthday_month'] = Variable<int>(birthdayMonth);
    }
    if (!nullToAbsent || birthdayDay != null) {
      map['birthday_day'] = Variable<int>(birthdayDay);
    }
    if (!nullToAbsent || birthdayYear != null) {
      map['birthday_year'] = Variable<int>(birthdayYear);
    }
    {
      map['avatar_shape'] = Variable<String>(
        $PeopleTable.$converteravatarShape.toSql(avatarShape),
      );
    }
    {
      map['avatar_color'] = Variable<String>(
        $PeopleTable.$converteravatarColor.toSql(avatarColor),
      );
    }
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PeopleCompanion toCompanion(bool nullToAbsent) {
    return PeopleCompanion(
      id: Value(id),
      name: Value(name),
      contactId: contactId == null && nullToAbsent
          ? const Value.absent()
          : Value(contactId),
      closeness: Value(closeness),
      reconnecting: Value(reconnecting),
      rhythmDays: rhythmDays == null && nullToAbsent
          ? const Value.absent()
          : Value(rhythmDays),
      mainMessenger: mainMessenger == null && nullToAbsent
          ? const Value.absent()
          : Value(mainMessenger),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      telegramUsername: telegramUsername == null && nullToAbsent
          ? const Value.absent()
          : Value(telegramUsername),
      signalLink: signalLink == null && nullToAbsent
          ? const Value.absent()
          : Value(signalLink),
      discordUserId: discordUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(discordUserId),
      birthdayMonth: birthdayMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(birthdayMonth),
      birthdayDay: birthdayDay == null && nullToAbsent
          ? const Value.absent()
          : Value(birthdayDay),
      birthdayYear: birthdayYear == null && nullToAbsent
          ? const Value.absent()
          : Value(birthdayYear),
      avatarShape: Value(avatarShape),
      avatarColor: Value(avatarColor),
      notes: Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Person.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Person(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      contactId: serializer.fromJson<String?>(json['contactId']),
      closeness: $PeopleTable.$convertercloseness.fromJson(
        serializer.fromJson<String>(json['closeness']),
      ),
      reconnecting: serializer.fromJson<bool>(json['reconnecting']),
      rhythmDays: serializer.fromJson<int?>(json['rhythmDays']),
      mainMessenger: $PeopleTable.$convertermainMessengern.fromJson(
        serializer.fromJson<String?>(json['mainMessenger']),
      ),
      phone: serializer.fromJson<String?>(json['phone']),
      telegramUsername: serializer.fromJson<String?>(json['telegramUsername']),
      signalLink: serializer.fromJson<String?>(json['signalLink']),
      discordUserId: serializer.fromJson<String?>(json['discordUserId']),
      birthdayMonth: serializer.fromJson<int?>(json['birthdayMonth']),
      birthdayDay: serializer.fromJson<int?>(json['birthdayDay']),
      birthdayYear: serializer.fromJson<int?>(json['birthdayYear']),
      avatarShape: $PeopleTable.$converteravatarShape.fromJson(
        serializer.fromJson<String>(json['avatarShape']),
      ),
      avatarColor: $PeopleTable.$converteravatarColor.fromJson(
        serializer.fromJson<String>(json['avatarColor']),
      ),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'contactId': serializer.toJson<String?>(contactId),
      'closeness': serializer.toJson<String>(
        $PeopleTable.$convertercloseness.toJson(closeness),
      ),
      'reconnecting': serializer.toJson<bool>(reconnecting),
      'rhythmDays': serializer.toJson<int?>(rhythmDays),
      'mainMessenger': serializer.toJson<String?>(
        $PeopleTable.$convertermainMessengern.toJson(mainMessenger),
      ),
      'phone': serializer.toJson<String?>(phone),
      'telegramUsername': serializer.toJson<String?>(telegramUsername),
      'signalLink': serializer.toJson<String?>(signalLink),
      'discordUserId': serializer.toJson<String?>(discordUserId),
      'birthdayMonth': serializer.toJson<int?>(birthdayMonth),
      'birthdayDay': serializer.toJson<int?>(birthdayDay),
      'birthdayYear': serializer.toJson<int?>(birthdayYear),
      'avatarShape': serializer.toJson<String>(
        $PeopleTable.$converteravatarShape.toJson(avatarShape),
      ),
      'avatarColor': serializer.toJson<String>(
        $PeopleTable.$converteravatarColor.toJson(avatarColor),
      ),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Person copyWith({
    String? id,
    String? name,
    Value<String?> contactId = const Value.absent(),
    Closeness? closeness,
    bool? reconnecting,
    Value<int?> rhythmDays = const Value.absent(),
    Value<Messenger?> mainMessenger = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> telegramUsername = const Value.absent(),
    Value<String?> signalLink = const Value.absent(),
    Value<String?> discordUserId = const Value.absent(),
    Value<int?> birthdayMonth = const Value.absent(),
    Value<int?> birthdayDay = const Value.absent(),
    Value<int?> birthdayYear = const Value.absent(),
    AvatarShape? avatarShape,
    AvatarColor? avatarColor,
    String? notes,
    DateTime? createdAt,
  }) => Person(
    id: id ?? this.id,
    name: name ?? this.name,
    contactId: contactId.present ? contactId.value : this.contactId,
    closeness: closeness ?? this.closeness,
    reconnecting: reconnecting ?? this.reconnecting,
    rhythmDays: rhythmDays.present ? rhythmDays.value : this.rhythmDays,
    mainMessenger: mainMessenger.present
        ? mainMessenger.value
        : this.mainMessenger,
    phone: phone.present ? phone.value : this.phone,
    telegramUsername: telegramUsername.present
        ? telegramUsername.value
        : this.telegramUsername,
    signalLink: signalLink.present ? signalLink.value : this.signalLink,
    discordUserId: discordUserId.present
        ? discordUserId.value
        : this.discordUserId,
    birthdayMonth: birthdayMonth.present
        ? birthdayMonth.value
        : this.birthdayMonth,
    birthdayDay: birthdayDay.present ? birthdayDay.value : this.birthdayDay,
    birthdayYear: birthdayYear.present ? birthdayYear.value : this.birthdayYear,
    avatarShape: avatarShape ?? this.avatarShape,
    avatarColor: avatarColor ?? this.avatarColor,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  Person copyWithCompanion(PeopleCompanion data) {
    return Person(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      closeness: data.closeness.present ? data.closeness.value : this.closeness,
      reconnecting: data.reconnecting.present
          ? data.reconnecting.value
          : this.reconnecting,
      rhythmDays: data.rhythmDays.present
          ? data.rhythmDays.value
          : this.rhythmDays,
      mainMessenger: data.mainMessenger.present
          ? data.mainMessenger.value
          : this.mainMessenger,
      phone: data.phone.present ? data.phone.value : this.phone,
      telegramUsername: data.telegramUsername.present
          ? data.telegramUsername.value
          : this.telegramUsername,
      signalLink: data.signalLink.present
          ? data.signalLink.value
          : this.signalLink,
      discordUserId: data.discordUserId.present
          ? data.discordUserId.value
          : this.discordUserId,
      birthdayMonth: data.birthdayMonth.present
          ? data.birthdayMonth.value
          : this.birthdayMonth,
      birthdayDay: data.birthdayDay.present
          ? data.birthdayDay.value
          : this.birthdayDay,
      birthdayYear: data.birthdayYear.present
          ? data.birthdayYear.value
          : this.birthdayYear,
      avatarShape: data.avatarShape.present
          ? data.avatarShape.value
          : this.avatarShape,
      avatarColor: data.avatarColor.present
          ? data.avatarColor.value
          : this.avatarColor,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Person(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contactId: $contactId, ')
          ..write('closeness: $closeness, ')
          ..write('reconnecting: $reconnecting, ')
          ..write('rhythmDays: $rhythmDays, ')
          ..write('mainMessenger: $mainMessenger, ')
          ..write('phone: $phone, ')
          ..write('telegramUsername: $telegramUsername, ')
          ..write('signalLink: $signalLink, ')
          ..write('discordUserId: $discordUserId, ')
          ..write('birthdayMonth: $birthdayMonth, ')
          ..write('birthdayDay: $birthdayDay, ')
          ..write('birthdayYear: $birthdayYear, ')
          ..write('avatarShape: $avatarShape, ')
          ..write('avatarColor: $avatarColor, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    contactId,
    closeness,
    reconnecting,
    rhythmDays,
    mainMessenger,
    phone,
    telegramUsername,
    signalLink,
    discordUserId,
    birthdayMonth,
    birthdayDay,
    birthdayYear,
    avatarShape,
    avatarColor,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Person &&
          other.id == this.id &&
          other.name == this.name &&
          other.contactId == this.contactId &&
          other.closeness == this.closeness &&
          other.reconnecting == this.reconnecting &&
          other.rhythmDays == this.rhythmDays &&
          other.mainMessenger == this.mainMessenger &&
          other.phone == this.phone &&
          other.telegramUsername == this.telegramUsername &&
          other.signalLink == this.signalLink &&
          other.discordUserId == this.discordUserId &&
          other.birthdayMonth == this.birthdayMonth &&
          other.birthdayDay == this.birthdayDay &&
          other.birthdayYear == this.birthdayYear &&
          other.avatarShape == this.avatarShape &&
          other.avatarColor == this.avatarColor &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class PeopleCompanion extends UpdateCompanion<Person> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> contactId;
  final Value<Closeness> closeness;
  final Value<bool> reconnecting;
  final Value<int?> rhythmDays;
  final Value<Messenger?> mainMessenger;
  final Value<String?> phone;
  final Value<String?> telegramUsername;
  final Value<String?> signalLink;
  final Value<String?> discordUserId;
  final Value<int?> birthdayMonth;
  final Value<int?> birthdayDay;
  final Value<int?> birthdayYear;
  final Value<AvatarShape> avatarShape;
  final Value<AvatarColor> avatarColor;
  final Value<String> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PeopleCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.contactId = const Value.absent(),
    this.closeness = const Value.absent(),
    this.reconnecting = const Value.absent(),
    this.rhythmDays = const Value.absent(),
    this.mainMessenger = const Value.absent(),
    this.phone = const Value.absent(),
    this.telegramUsername = const Value.absent(),
    this.signalLink = const Value.absent(),
    this.discordUserId = const Value.absent(),
    this.birthdayMonth = const Value.absent(),
    this.birthdayDay = const Value.absent(),
    this.birthdayYear = const Value.absent(),
    this.avatarShape = const Value.absent(),
    this.avatarColor = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PeopleCompanion.insert({
    required String id,
    required String name,
    this.contactId = const Value.absent(),
    required Closeness closeness,
    this.reconnecting = const Value.absent(),
    this.rhythmDays = const Value.absent(),
    this.mainMessenger = const Value.absent(),
    this.phone = const Value.absent(),
    this.telegramUsername = const Value.absent(),
    this.signalLink = const Value.absent(),
    this.discordUserId = const Value.absent(),
    this.birthdayMonth = const Value.absent(),
    this.birthdayDay = const Value.absent(),
    this.birthdayYear = const Value.absent(),
    required AvatarShape avatarShape,
    required AvatarColor avatarColor,
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       closeness = Value(closeness),
       avatarShape = Value(avatarShape),
       avatarColor = Value(avatarColor),
       createdAt = Value(createdAt);
  static Insertable<Person> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? contactId,
    Expression<String>? closeness,
    Expression<bool>? reconnecting,
    Expression<int>? rhythmDays,
    Expression<String>? mainMessenger,
    Expression<String>? phone,
    Expression<String>? telegramUsername,
    Expression<String>? signalLink,
    Expression<String>? discordUserId,
    Expression<int>? birthdayMonth,
    Expression<int>? birthdayDay,
    Expression<int>? birthdayYear,
    Expression<String>? avatarShape,
    Expression<String>? avatarColor,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (contactId != null) 'contact_id': contactId,
      if (closeness != null) 'closeness': closeness,
      if (reconnecting != null) 'reconnecting': reconnecting,
      if (rhythmDays != null) 'rhythm_days': rhythmDays,
      if (mainMessenger != null) 'main_messenger': mainMessenger,
      if (phone != null) 'phone': phone,
      if (telegramUsername != null) 'telegram_username': telegramUsername,
      if (signalLink != null) 'signal_link': signalLink,
      if (discordUserId != null) 'discord_user_id': discordUserId,
      if (birthdayMonth != null) 'birthday_month': birthdayMonth,
      if (birthdayDay != null) 'birthday_day': birthdayDay,
      if (birthdayYear != null) 'birthday_year': birthdayYear,
      if (avatarShape != null) 'avatar_shape': avatarShape,
      if (avatarColor != null) 'avatar_color': avatarColor,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PeopleCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? contactId,
    Value<Closeness>? closeness,
    Value<bool>? reconnecting,
    Value<int?>? rhythmDays,
    Value<Messenger?>? mainMessenger,
    Value<String?>? phone,
    Value<String?>? telegramUsername,
    Value<String?>? signalLink,
    Value<String?>? discordUserId,
    Value<int?>? birthdayMonth,
    Value<int?>? birthdayDay,
    Value<int?>? birthdayYear,
    Value<AvatarShape>? avatarShape,
    Value<AvatarColor>? avatarColor,
    Value<String>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PeopleCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      contactId: contactId ?? this.contactId,
      closeness: closeness ?? this.closeness,
      reconnecting: reconnecting ?? this.reconnecting,
      rhythmDays: rhythmDays ?? this.rhythmDays,
      mainMessenger: mainMessenger ?? this.mainMessenger,
      phone: phone ?? this.phone,
      telegramUsername: telegramUsername ?? this.telegramUsername,
      signalLink: signalLink ?? this.signalLink,
      discordUserId: discordUserId ?? this.discordUserId,
      birthdayMonth: birthdayMonth ?? this.birthdayMonth,
      birthdayDay: birthdayDay ?? this.birthdayDay,
      birthdayYear: birthdayYear ?? this.birthdayYear,
      avatarShape: avatarShape ?? this.avatarShape,
      avatarColor: avatarColor ?? this.avatarColor,
      notes: notes ?? this.notes,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<String>(contactId.value);
    }
    if (closeness.present) {
      map['closeness'] = Variable<String>(
        $PeopleTable.$convertercloseness.toSql(closeness.value),
      );
    }
    if (reconnecting.present) {
      map['reconnecting'] = Variable<bool>(reconnecting.value);
    }
    if (rhythmDays.present) {
      map['rhythm_days'] = Variable<int>(rhythmDays.value);
    }
    if (mainMessenger.present) {
      map['main_messenger'] = Variable<String>(
        $PeopleTable.$convertermainMessengern.toSql(mainMessenger.value),
      );
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (telegramUsername.present) {
      map['telegram_username'] = Variable<String>(telegramUsername.value);
    }
    if (signalLink.present) {
      map['signal_link'] = Variable<String>(signalLink.value);
    }
    if (discordUserId.present) {
      map['discord_user_id'] = Variable<String>(discordUserId.value);
    }
    if (birthdayMonth.present) {
      map['birthday_month'] = Variable<int>(birthdayMonth.value);
    }
    if (birthdayDay.present) {
      map['birthday_day'] = Variable<int>(birthdayDay.value);
    }
    if (birthdayYear.present) {
      map['birthday_year'] = Variable<int>(birthdayYear.value);
    }
    if (avatarShape.present) {
      map['avatar_shape'] = Variable<String>(
        $PeopleTable.$converteravatarShape.toSql(avatarShape.value),
      );
    }
    if (avatarColor.present) {
      map['avatar_color'] = Variable<String>(
        $PeopleTable.$converteravatarColor.toSql(avatarColor.value),
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
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
    return (StringBuffer('PeopleCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contactId: $contactId, ')
          ..write('closeness: $closeness, ')
          ..write('reconnecting: $reconnecting, ')
          ..write('rhythmDays: $rhythmDays, ')
          ..write('mainMessenger: $mainMessenger, ')
          ..write('phone: $phone, ')
          ..write('telegramUsername: $telegramUsername, ')
          ..write('signalLink: $signalLink, ')
          ..write('discordUserId: $discordUserId, ')
          ..write('birthdayMonth: $birthdayMonth, ')
          ..write('birthdayDay: $birthdayDay, ')
          ..write('birthdayYear: $birthdayYear, ')
          ..write('avatarShape: $avatarShape, ')
          ..write('avatarColor: $avatarColor, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IntentionsTable extends Intentions
    with TableInfo<$IntentionsTable, Intention> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IntentionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES people (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<IntentionKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(IntentionKind.write.name),
      ).withConverter<IntentionKind>($IntentionsTable.$converterkind);
  @override
  late final GeneratedColumnWithTypeConverter<IntentionState, String> state =
      GeneratedColumn<String>(
        'state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(IntentionState.open.name),
      ).withConverter<IntentionState>($IntentionsTable.$converterstate);
  static const VerificationMeta _linkMeta = const VerificationMeta('link');
  @override
  late final GeneratedColumn<String> link = GeneratedColumn<String>(
    'link',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Horizon?, String> horizon =
      GeneratedColumn<String>(
        'horizon',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Horizon?>($IntentionsTable.$converterhorizonn);
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
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    personId,
    note,
    kind,
    state,
    link,
    date,
    horizon,
    condition,
    createdAt,
    closedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'intentions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Intention> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('link')) {
      context.handle(
        _linkMeta,
        link.isAcceptableOrUnknown(data['link']!, _linkMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('condition')) {
      context.handle(
        _conditionMeta,
        condition.isAcceptableOrUnknown(data['condition']!, _conditionMeta),
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
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Intention map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Intention(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      kind: $IntentionsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      state: $IntentionsTable.$converterstate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}state'],
        )!,
      ),
      link: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}link'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      ),
      horizon: $IntentionsTable.$converterhorizonn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}horizon'],
        ),
      ),
      condition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      ),
    );
  }

  @override
  $IntentionsTable createAlias(String alias) {
    return $IntentionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<IntentionKind, String, String> $converterkind =
      const EnumNameConverter<IntentionKind>(IntentionKind.values);
  static JsonTypeConverter2<IntentionState, String, String> $converterstate =
      const EnumNameConverter<IntentionState>(IntentionState.values);
  static JsonTypeConverter2<Horizon, String, String> $converterhorizon =
      const EnumNameConverter<Horizon>(Horizon.values);
  static JsonTypeConverter2<Horizon?, String?, String?> $converterhorizonn =
      JsonTypeConverter2.asNullable($converterhorizon);
}

class Intention extends DataClass implements Insertable<Intention> {
  /// UUID v4, made by IntentionsRepository.
  final String id;

  /// Deleting the person deletes their intentions. Needs
  /// `PRAGMA foreign_keys = ON` (AppDatabase.migration, beforeOpen).
  final String personId;

  /// What came to mind ("saw a bouldering video"). May be empty.
  final String note;
  final IntentionKind kind;
  final IntentionState state;

  /// An attached link (a later milestone).
  final String? link;

  /// When: a date, or a horizon (with [condition] for "when ..."), or
  /// nothing. Used from milestone M5; here now to spare a migration.
  final DateTime? date;
  final Horizon? horizon;
  final String? condition;
  final DateTime createdAt;

  /// Set when the intention leaves `open`; cleared when it is reopened.
  final DateTime? closedAt;
  const Intention({
    required this.id,
    required this.personId,
    required this.note,
    required this.kind,
    required this.state,
    this.link,
    this.date,
    this.horizon,
    this.condition,
    required this.createdAt,
    this.closedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['person_id'] = Variable<String>(personId);
    map['note'] = Variable<String>(note);
    {
      map['kind'] = Variable<String>(
        $IntentionsTable.$converterkind.toSql(kind),
      );
    }
    {
      map['state'] = Variable<String>(
        $IntentionsTable.$converterstate.toSql(state),
      );
    }
    if (!nullToAbsent || link != null) {
      map['link'] = Variable<String>(link);
    }
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<DateTime>(date);
    }
    if (!nullToAbsent || horizon != null) {
      map['horizon'] = Variable<String>(
        $IntentionsTable.$converterhorizonn.toSql(horizon),
      );
    }
    if (!nullToAbsent || condition != null) {
      map['condition'] = Variable<String>(condition);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    return map;
  }

  IntentionsCompanion toCompanion(bool nullToAbsent) {
    return IntentionsCompanion(
      id: Value(id),
      personId: Value(personId),
      note: Value(note),
      kind: Value(kind),
      state: Value(state),
      link: link == null && nullToAbsent ? const Value.absent() : Value(link),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      horizon: horizon == null && nullToAbsent
          ? const Value.absent()
          : Value(horizon),
      condition: condition == null && nullToAbsent
          ? const Value.absent()
          : Value(condition),
      createdAt: Value(createdAt),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
    );
  }

  factory Intention.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Intention(
      id: serializer.fromJson<String>(json['id']),
      personId: serializer.fromJson<String>(json['personId']),
      note: serializer.fromJson<String>(json['note']),
      kind: $IntentionsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      state: $IntentionsTable.$converterstate.fromJson(
        serializer.fromJson<String>(json['state']),
      ),
      link: serializer.fromJson<String?>(json['link']),
      date: serializer.fromJson<DateTime?>(json['date']),
      horizon: $IntentionsTable.$converterhorizonn.fromJson(
        serializer.fromJson<String?>(json['horizon']),
      ),
      condition: serializer.fromJson<String?>(json['condition']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'personId': serializer.toJson<String>(personId),
      'note': serializer.toJson<String>(note),
      'kind': serializer.toJson<String>(
        $IntentionsTable.$converterkind.toJson(kind),
      ),
      'state': serializer.toJson<String>(
        $IntentionsTable.$converterstate.toJson(state),
      ),
      'link': serializer.toJson<String?>(link),
      'date': serializer.toJson<DateTime?>(date),
      'horizon': serializer.toJson<String?>(
        $IntentionsTable.$converterhorizonn.toJson(horizon),
      ),
      'condition': serializer.toJson<String?>(condition),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
    };
  }

  Intention copyWith({
    String? id,
    String? personId,
    String? note,
    IntentionKind? kind,
    IntentionState? state,
    Value<String?> link = const Value.absent(),
    Value<DateTime?> date = const Value.absent(),
    Value<Horizon?> horizon = const Value.absent(),
    Value<String?> condition = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> closedAt = const Value.absent(),
  }) => Intention(
    id: id ?? this.id,
    personId: personId ?? this.personId,
    note: note ?? this.note,
    kind: kind ?? this.kind,
    state: state ?? this.state,
    link: link.present ? link.value : this.link,
    date: date.present ? date.value : this.date,
    horizon: horizon.present ? horizon.value : this.horizon,
    condition: condition.present ? condition.value : this.condition,
    createdAt: createdAt ?? this.createdAt,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
  );
  Intention copyWithCompanion(IntentionsCompanion data) {
    return Intention(
      id: data.id.present ? data.id.value : this.id,
      personId: data.personId.present ? data.personId.value : this.personId,
      note: data.note.present ? data.note.value : this.note,
      kind: data.kind.present ? data.kind.value : this.kind,
      state: data.state.present ? data.state.value : this.state,
      link: data.link.present ? data.link.value : this.link,
      date: data.date.present ? data.date.value : this.date,
      horizon: data.horizon.present ? data.horizon.value : this.horizon,
      condition: data.condition.present ? data.condition.value : this.condition,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Intention(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('note: $note, ')
          ..write('kind: $kind, ')
          ..write('state: $state, ')
          ..write('link: $link, ')
          ..write('date: $date, ')
          ..write('horizon: $horizon, ')
          ..write('condition: $condition, ')
          ..write('createdAt: $createdAt, ')
          ..write('closedAt: $closedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    personId,
    note,
    kind,
    state,
    link,
    date,
    horizon,
    condition,
    createdAt,
    closedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Intention &&
          other.id == this.id &&
          other.personId == this.personId &&
          other.note == this.note &&
          other.kind == this.kind &&
          other.state == this.state &&
          other.link == this.link &&
          other.date == this.date &&
          other.horizon == this.horizon &&
          other.condition == this.condition &&
          other.createdAt == this.createdAt &&
          other.closedAt == this.closedAt);
}

class IntentionsCompanion extends UpdateCompanion<Intention> {
  final Value<String> id;
  final Value<String> personId;
  final Value<String> note;
  final Value<IntentionKind> kind;
  final Value<IntentionState> state;
  final Value<String?> link;
  final Value<DateTime?> date;
  final Value<Horizon?> horizon;
  final Value<String?> condition;
  final Value<DateTime> createdAt;
  final Value<DateTime?> closedAt;
  final Value<int> rowid;
  const IntentionsCompanion({
    this.id = const Value.absent(),
    this.personId = const Value.absent(),
    this.note = const Value.absent(),
    this.kind = const Value.absent(),
    this.state = const Value.absent(),
    this.link = const Value.absent(),
    this.date = const Value.absent(),
    this.horizon = const Value.absent(),
    this.condition = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IntentionsCompanion.insert({
    required String id,
    required String personId,
    this.note = const Value.absent(),
    this.kind = const Value.absent(),
    this.state = const Value.absent(),
    this.link = const Value.absent(),
    this.date = const Value.absent(),
    this.horizon = const Value.absent(),
    this.condition = const Value.absent(),
    required DateTime createdAt,
    this.closedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       personId = Value(personId),
       createdAt = Value(createdAt);
  static Insertable<Intention> custom({
    Expression<String>? id,
    Expression<String>? personId,
    Expression<String>? note,
    Expression<String>? kind,
    Expression<String>? state,
    Expression<String>? link,
    Expression<DateTime>? date,
    Expression<String>? horizon,
    Expression<String>? condition,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? closedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personId != null) 'person_id': personId,
      if (note != null) 'note': note,
      if (kind != null) 'kind': kind,
      if (state != null) 'state': state,
      if (link != null) 'link': link,
      if (date != null) 'date': date,
      if (horizon != null) 'horizon': horizon,
      if (condition != null) 'condition': condition,
      if (createdAt != null) 'created_at': createdAt,
      if (closedAt != null) 'closed_at': closedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IntentionsCompanion copyWith({
    Value<String>? id,
    Value<String>? personId,
    Value<String>? note,
    Value<IntentionKind>? kind,
    Value<IntentionState>? state,
    Value<String?>? link,
    Value<DateTime?>? date,
    Value<Horizon?>? horizon,
    Value<String?>? condition,
    Value<DateTime>? createdAt,
    Value<DateTime?>? closedAt,
    Value<int>? rowid,
  }) {
    return IntentionsCompanion(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      note: note ?? this.note,
      kind: kind ?? this.kind,
      state: state ?? this.state,
      link: link ?? this.link,
      date: date ?? this.date,
      horizon: horizon ?? this.horizon,
      condition: condition ?? this.condition,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt ?? this.closedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $IntentionsTable.$converterkind.toSql(kind.value),
      );
    }
    if (state.present) {
      map['state'] = Variable<String>(
        $IntentionsTable.$converterstate.toSql(state.value),
      );
    }
    if (link.present) {
      map['link'] = Variable<String>(link.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (horizon.present) {
      map['horizon'] = Variable<String>(
        $IntentionsTable.$converterhorizonn.toSql(horizon.value),
      );
    }
    if (condition.present) {
      map['condition'] = Variable<String>(condition.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IntentionsCompanion(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('note: $note, ')
          ..write('kind: $kind, ')
          ..write('state: $state, ')
          ..write('link: $link, ')
          ..write('date: $date, ')
          ..write('horizon: $horizon, ')
          ..write('condition: $condition, ')
          ..write('createdAt: $createdAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $PeopleTable people = $PeopleTable(this);
  late final $IntentionsTable intentions = $IntentionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    settings,
    people,
    intentions,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'people',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('intentions', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingEntry,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingEntry,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingEntry>,
          ),
          SettingEntry,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, SettingEntry>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, SettingEntry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingEntry,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (
        SettingEntry,
        BaseReferences<_$AppDatabase, $SettingsTable, SettingEntry>,
      ),
      SettingEntry,
      PrefetchHooks Function()
    >;
typedef $$PeopleTableCreateCompanionBuilder = PeopleCompanion Function({
  required String id,
  required String name,
  Value<String?> contactId,
  required Closeness closeness,
  Value<bool> reconnecting,
  Value<int?> rhythmDays,
  Value<Messenger?> mainMessenger,
  Value<String?> phone,
  Value<String?> telegramUsername,
  Value<String?> signalLink,
  Value<String?> discordUserId,
  Value<int?> birthdayMonth,
  Value<int?> birthdayDay,
  Value<int?> birthdayYear,
  required AvatarShape avatarShape,
  required AvatarColor avatarColor,
  Value<String> notes,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$PeopleTableUpdateCompanionBuilder = PeopleCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> contactId,
  Value<Closeness> closeness,
  Value<bool> reconnecting,
  Value<int?> rhythmDays,
  Value<Messenger?> mainMessenger,
  Value<String?> phone,
  Value<String?> telegramUsername,
  Value<String?> signalLink,
  Value<String?> discordUserId,
  Value<int?> birthdayMonth,
  Value<int?> birthdayDay,
  Value<int?> birthdayYear,
  Value<AvatarShape> avatarShape,
  Value<AvatarColor> avatarColor,
  Value<String> notes,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$PeopleTableReferences
    extends BaseReferences<_$AppDatabase, $PeopleTable, Person> {
  $$PeopleTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$IntentionsTable, List<Intention>>
  _intentionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.intentions,
    aliasName: 'people__id__intentions__person_id',
  );

  $$IntentionsTableProcessedTableManager get intentionsRefs {
    final manager = $$IntentionsTableTableManager(
      $_db,
      $_db.intentions,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_intentionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PeopleTableFilterComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactId => $composableBuilder(
    column: $table.contactId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Closeness, Closeness, String> get closeness =>
      $composableBuilder(
        column: $table.closeness,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get reconnecting => $composableBuilder(
    column: $table.reconnecting,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rhythmDays => $composableBuilder(
    column: $table.rhythmDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Messenger?, Messenger, String>
  get mainMessenger => $composableBuilder(
    column: $table.mainMessenger,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telegramUsername => $composableBuilder(
    column: $table.telegramUsername,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get signalLink => $composableBuilder(
    column: $table.signalLink,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discordUserId => $composableBuilder(
    column: $table.discordUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get birthdayMonth => $composableBuilder(
    column: $table.birthdayMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get birthdayDay => $composableBuilder(
    column: $table.birthdayDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get birthdayYear => $composableBuilder(
    column: $table.birthdayYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AvatarShape, AvatarShape, String>
  get avatarShape => $composableBuilder(
    column: $table.avatarShape,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<AvatarColor, AvatarColor, String>
  get avatarColor => $composableBuilder(
    column: $table.avatarColor,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> intentionsRefs(
    Expression<bool> Function($$IntentionsTableFilterComposer f) f,
  ) {
    final $$IntentionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.intentions,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntentionsTableFilterComposer(
            $db: $db,
            $table: $db.intentions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PeopleTableOrderingComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactId => $composableBuilder(
    column: $table.contactId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closeness => $composableBuilder(
    column: $table.closeness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reconnecting => $composableBuilder(
    column: $table.reconnecting,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rhythmDays => $composableBuilder(
    column: $table.rhythmDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mainMessenger => $composableBuilder(
    column: $table.mainMessenger,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telegramUsername => $composableBuilder(
    column: $table.telegramUsername,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get signalLink => $composableBuilder(
    column: $table.signalLink,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discordUserId => $composableBuilder(
    column: $table.discordUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get birthdayMonth => $composableBuilder(
    column: $table.birthdayMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get birthdayDay => $composableBuilder(
    column: $table.birthdayDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get birthdayYear => $composableBuilder(
    column: $table.birthdayYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarShape => $composableBuilder(
    column: $table.avatarShape,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarColor => $composableBuilder(
    column: $table.avatarColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PeopleTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get contactId =>
      $composableBuilder(column: $table.contactId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Closeness, String> get closeness =>
      $composableBuilder(column: $table.closeness, builder: (column) => column);

  GeneratedColumn<bool> get reconnecting => $composableBuilder(
    column: $table.reconnecting,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rhythmDays => $composableBuilder(
    column: $table.rhythmDays,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Messenger?, String> get mainMessenger =>
      $composableBuilder(
        column: $table.mainMessenger,
        builder: (column) => column,
      );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get telegramUsername => $composableBuilder(
    column: $table.telegramUsername,
    builder: (column) => column,
  );

  GeneratedColumn<String> get signalLink => $composableBuilder(
    column: $table.signalLink,
    builder: (column) => column,
  );

  GeneratedColumn<String> get discordUserId => $composableBuilder(
    column: $table.discordUserId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get birthdayMonth => $composableBuilder(
    column: $table.birthdayMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get birthdayDay => $composableBuilder(
    column: $table.birthdayDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get birthdayYear => $composableBuilder(
    column: $table.birthdayYear,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<AvatarShape, String> get avatarShape =>
      $composableBuilder(
        column: $table.avatarShape,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<AvatarColor, String> get avatarColor =>
      $composableBuilder(
        column: $table.avatarColor,
        builder: (column) => column,
      );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> intentionsRefs<T extends Object>(
    Expression<T> Function($$IntentionsTableAnnotationComposer a) f,
  ) {
    final $$IntentionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.intentions,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntentionsTableAnnotationComposer(
            $db: $db,
            $table: $db.intentions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PeopleTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PeopleTable,
          Person,
          $$PeopleTableFilterComposer,
          $$PeopleTableOrderingComposer,
          $$PeopleTableAnnotationComposer,
          $$PeopleTableCreateCompanionBuilder,
          $$PeopleTableUpdateCompanionBuilder,
          (Person, $$PeopleTableReferences),
          Person,
          PrefetchHooks Function({bool intentionsRefs})
        > {
  $$PeopleTableTableManager(_$AppDatabase db, $PeopleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeopleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeopleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeopleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> contactId = const Value.absent(),
                Value<Closeness> closeness = const Value.absent(),
                Value<bool> reconnecting = const Value.absent(),
                Value<int?> rhythmDays = const Value.absent(),
                Value<Messenger?> mainMessenger = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> telegramUsername = const Value.absent(),
                Value<String?> signalLink = const Value.absent(),
                Value<String?> discordUserId = const Value.absent(),
                Value<int?> birthdayMonth = const Value.absent(),
                Value<int?> birthdayDay = const Value.absent(),
                Value<int?> birthdayYear = const Value.absent(),
                Value<AvatarShape> avatarShape = const Value.absent(),
                Value<AvatarColor> avatarColor = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeopleCompanion(
                id: id,
                name: name,
                contactId: contactId,
                closeness: closeness,
                reconnecting: reconnecting,
                rhythmDays: rhythmDays,
                mainMessenger: mainMessenger,
                phone: phone,
                telegramUsername: telegramUsername,
                signalLink: signalLink,
                discordUserId: discordUserId,
                birthdayMonth: birthdayMonth,
                birthdayDay: birthdayDay,
                birthdayYear: birthdayYear,
                avatarShape: avatarShape,
                avatarColor: avatarColor,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> contactId = const Value.absent(),
                required Closeness closeness,
                Value<bool> reconnecting = const Value.absent(),
                Value<int?> rhythmDays = const Value.absent(),
                Value<Messenger?> mainMessenger = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> telegramUsername = const Value.absent(),
                Value<String?> signalLink = const Value.absent(),
                Value<String?> discordUserId = const Value.absent(),
                Value<int?> birthdayMonth = const Value.absent(),
                Value<int?> birthdayDay = const Value.absent(),
                Value<int?> birthdayYear = const Value.absent(),
                required AvatarShape avatarShape,
                required AvatarColor avatarColor,
                Value<String> notes = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PeopleCompanion.insert(
                id: id,
                name: name,
                contactId: contactId,
                closeness: closeness,
                reconnecting: reconnecting,
                rhythmDays: rhythmDays,
                mainMessenger: mainMessenger,
                phone: phone,
                telegramUsername: telegramUsername,
                signalLink: signalLink,
                discordUserId: discordUserId,
                birthdayMonth: birthdayMonth,
                birthdayDay: birthdayDay,
                birthdayYear: birthdayYear,
                avatarShape: avatarShape,
                avatarColor: avatarColor,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PeopleTable, Person>(table),
                  $$PeopleTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({intentionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (intentionsRefs) db.intentions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (intentionsRefs)
                    await $_getPrefetchedDataByColumns<
                      Person,
                      $PeopleTable,
                      Intention,
                      $IntentionsTable
                    >(
                      currentTable: table,
                      referencedTable: $$PeopleTableReferences
                          ._intentionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PeopleTableReferences(db, table, p0).intentionsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'person_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PeopleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PeopleTable,
      Person,
      $$PeopleTableFilterComposer,
      $$PeopleTableOrderingComposer,
      $$PeopleTableAnnotationComposer,
      $$PeopleTableCreateCompanionBuilder,
      $$PeopleTableUpdateCompanionBuilder,
      (Person, $$PeopleTableReferences),
      Person,
      PrefetchHooks Function({bool intentionsRefs})
    >;
typedef $$IntentionsTableCreateCompanionBuilder = IntentionsCompanion Function({
  required String id,
  required String personId,
  Value<String> note,
  Value<IntentionKind> kind,
  Value<IntentionState> state,
  Value<String?> link,
  Value<DateTime?> date,
  Value<Horizon?> horizon,
  Value<String?> condition,
  required DateTime createdAt,
  Value<DateTime?> closedAt,
  Value<int> rowid,
});
typedef $$IntentionsTableUpdateCompanionBuilder = IntentionsCompanion Function({
  Value<String> id,
  Value<String> personId,
  Value<String> note,
  Value<IntentionKind> kind,
  Value<IntentionState> state,
  Value<String?> link,
  Value<DateTime?> date,
  Value<Horizon?> horizon,
  Value<String?> condition,
  Value<DateTime> createdAt,
  Value<DateTime?> closedAt,
  Value<int> rowid,
});

final class $$IntentionsTableReferences
    extends BaseReferences<_$AppDatabase, $IntentionsTable, Intention> {
  $$IntentionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PeopleTable _personIdTable(_$AppDatabase db) =>
      db.people.createAlias('intentions__person_id__people__id');

  $$PeopleTableProcessedTableManager get personId {
    final $_column = $_itemColumn<String>('person_id')!;

    final manager = $$PeopleTableTableManager(
      $_db,
      $_db.people,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IntentionsTableFilterComposer
    extends Composer<_$AppDatabase, $IntentionsTable> {
  $$IntentionsTableFilterComposer({
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

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<IntentionKind, IntentionKind, String>
  get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<IntentionState, IntentionState, String>
  get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Horizon?, Horizon, String> get horizon =>
      $composableBuilder(
        column: $table.horizon,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PeopleTableFilterComposer get personId {
    final $$PeopleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableFilterComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IntentionsTableOrderingComposer
    extends Composer<_$AppDatabase, $IntentionsTable> {
  $$IntentionsTableOrderingComposer({
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

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get horizon => $composableBuilder(
    column: $table.horizon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PeopleTableOrderingComposer get personId {
    final $$PeopleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableOrderingComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IntentionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IntentionsTable> {
  $$IntentionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<IntentionKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumnWithTypeConverter<IntentionState, String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get link =>
      $composableBuilder(column: $table.link, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Horizon?, String> get horizon =>
      $composableBuilder(column: $table.horizon, builder: (column) => column);

  GeneratedColumn<String> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  $$PeopleTableAnnotationComposer get personId {
    final $$PeopleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableAnnotationComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IntentionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IntentionsTable,
          Intention,
          $$IntentionsTableFilterComposer,
          $$IntentionsTableOrderingComposer,
          $$IntentionsTableAnnotationComposer,
          $$IntentionsTableCreateCompanionBuilder,
          $$IntentionsTableUpdateCompanionBuilder,
          (Intention, $$IntentionsTableReferences),
          Intention,
          PrefetchHooks Function({bool personId})
        > {
  $$IntentionsTableTableManager(_$AppDatabase db, $IntentionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IntentionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IntentionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IntentionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> personId = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<IntentionKind> kind = const Value.absent(),
                Value<IntentionState> state = const Value.absent(),
                Value<String?> link = const Value.absent(),
                Value<DateTime?> date = const Value.absent(),
                Value<Horizon?> horizon = const Value.absent(),
                Value<String?> condition = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IntentionsCompanion(
                id: id,
                personId: personId,
                note: note,
                kind: kind,
                state: state,
                link: link,
                date: date,
                horizon: horizon,
                condition: condition,
                createdAt: createdAt,
                closedAt: closedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String personId,
                Value<String> note = const Value.absent(),
                Value<IntentionKind> kind = const Value.absent(),
                Value<IntentionState> state = const Value.absent(),
                Value<String?> link = const Value.absent(),
                Value<DateTime?> date = const Value.absent(),
                Value<Horizon?> horizon = const Value.absent(),
                Value<String?> condition = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> closedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IntentionsCompanion.insert(
                id: id,
                personId: personId,
                note: note,
                kind: kind,
                state: state,
                link: link,
                date: date,
                horizon: horizon,
                condition: condition,
                createdAt: createdAt,
                closedAt: closedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IntentionsTable, Intention>(table),
                  $$IntentionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({personId = false}) {
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
                    if (personId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.personId,
                        referencedTable: $$IntentionsTableReferences
                            ._personIdTable(db),
                        referencedColumn: $$IntentionsTableReferences
                            ._personIdTable(db)
                            .id,
                      ) as T;
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

typedef $$IntentionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IntentionsTable,
      Intention,
      $$IntentionsTableFilterComposer,
      $$IntentionsTableOrderingComposer,
      $$IntentionsTableAnnotationComposer,
      $$IntentionsTableCreateCompanionBuilder,
      $$IntentionsTableUpdateCompanionBuilder,
      (Intention, $$IntentionsTableReferences),
      Intention,
      PrefetchHooks Function({bool personId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$PeopleTableTableManager get people =>
      $$PeopleTableTableManager(_db, _db.people);
  $$IntentionsTableTableManager get intentions =>
      $$IntentionsTableTableManager(_db, _db.intentions);
}
