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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $PeopleTable people = $PeopleTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [settings, people];
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
          (Person, BaseReferences<_$AppDatabase, $PeopleTable, Person>),
          Person,
          PrefetchHooks Function()
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
                  BaseReferences<_$AppDatabase, $PeopleTable, Person>(
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
      (Person, BaseReferences<_$AppDatabase, $PeopleTable, Person>),
      Person,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$PeopleTableTableManager get people =>
      $$PeopleTableTableManager(_db, _db.people);
}
