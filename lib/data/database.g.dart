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
  static const VerificationMeta _replyClearedAtMeta = const VerificationMeta(
    'replyClearedAt',
  );
  @override
  late final GeneratedColumn<DateTime> replyClearedAt =
      GeneratedColumn<DateTime>(
        'reply_cleared_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoMeta = const VerificationMeta('photo');
  @override
  late final GeneratedColumn<String> photo = GeneratedColumn<String>(
    'photo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    replyClearedAt,
    nickname,
    photo,
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
    if (data.containsKey('reply_cleared_at')) {
      context.handle(
        _replyClearedAtMeta,
        replyClearedAt.isAcceptableOrUnknown(
          data['reply_cleared_at']!,
          _replyClearedAtMeta,
        ),
      );
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    }
    if (data.containsKey('photo')) {
      context.handle(
        _photoMeta,
        photo.isAcceptableOrUnknown(data['photo']!, _photoMeta),
      );
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
      replyClearedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reply_cleared_at'],
      ),
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      ),
      photo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo'],
      ),
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

  /// When the user last said an owed reply to this person is settled
  /// Added in schema version 4.
  final DateTime? replyClearedAt;

  /// What the user calls the person, if not by their name. Added in schema
  /// version 5.
  final String? nickname;

  /// The person's picture: a file name inside the app's avatar folder
  /// (platform/photo_store.dart). null = the drawn avatar. Added in schema
  /// version 5.
  final String? photo;
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
    this.replyClearedAt,
    this.nickname,
    this.photo,
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
    if (!nullToAbsent || replyClearedAt != null) {
      map['reply_cleared_at'] = Variable<DateTime>(replyClearedAt);
    }
    if (!nullToAbsent || nickname != null) {
      map['nickname'] = Variable<String>(nickname);
    }
    if (!nullToAbsent || photo != null) {
      map['photo'] = Variable<String>(photo);
    }
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
      replyClearedAt: replyClearedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(replyClearedAt),
      nickname: nickname == null && nullToAbsent
          ? const Value.absent()
          : Value(nickname),
      photo: photo == null && nullToAbsent
          ? const Value.absent()
          : Value(photo),
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
      replyClearedAt: serializer.fromJson<DateTime?>(json['replyClearedAt']),
      nickname: serializer.fromJson<String?>(json['nickname']),
      photo: serializer.fromJson<String?>(json['photo']),
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
      'replyClearedAt': serializer.toJson<DateTime?>(replyClearedAt),
      'nickname': serializer.toJson<String?>(nickname),
      'photo': serializer.toJson<String?>(photo),
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
    Value<DateTime?> replyClearedAt = const Value.absent(),
    Value<String?> nickname = const Value.absent(),
    Value<String?> photo = const Value.absent(),
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
    replyClearedAt: replyClearedAt.present
        ? replyClearedAt.value
        : this.replyClearedAt,
    nickname: nickname.present ? nickname.value : this.nickname,
    photo: photo.present ? photo.value : this.photo,
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
      replyClearedAt: data.replyClearedAt.present
          ? data.replyClearedAt.value
          : this.replyClearedAt,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      photo: data.photo.present ? data.photo.value : this.photo,
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
          ..write('createdAt: $createdAt, ')
          ..write('replyClearedAt: $replyClearedAt, ')
          ..write('nickname: $nickname, ')
          ..write('photo: $photo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
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
    replyClearedAt,
    nickname,
    photo,
  ]);
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
          other.createdAt == this.createdAt &&
          other.replyClearedAt == this.replyClearedAt &&
          other.nickname == this.nickname &&
          other.photo == this.photo);
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
  final Value<DateTime?> replyClearedAt;
  final Value<String?> nickname;
  final Value<String?> photo;
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
    this.replyClearedAt = const Value.absent(),
    this.nickname = const Value.absent(),
    this.photo = const Value.absent(),
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
    this.replyClearedAt = const Value.absent(),
    this.nickname = const Value.absent(),
    this.photo = const Value.absent(),
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
    Expression<DateTime>? replyClearedAt,
    Expression<String>? nickname,
    Expression<String>? photo,
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
      if (replyClearedAt != null) 'reply_cleared_at': replyClearedAt,
      if (nickname != null) 'nickname': nickname,
      if (photo != null) 'photo': photo,
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
    Value<DateTime?>? replyClearedAt,
    Value<String?>? nickname,
    Value<String?>? photo,
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
      replyClearedAt: replyClearedAt ?? this.replyClearedAt,
      nickname: nickname ?? this.nickname,
      photo: photo ?? this.photo,
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
    if (replyClearedAt.present) {
      map['reply_cleared_at'] = Variable<DateTime>(replyClearedAt.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (photo.present) {
      map['photo'] = Variable<String>(photo.value);
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
          ..write('replyClearedAt: $replyClearedAt, ')
          ..write('nickname: $nickname, ')
          ..write('photo: $photo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupsTable extends Groups with TableInfo<$GroupsTable, PersonGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<GroupKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<GroupKind>($GroupsTable.$converterkind);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
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
  List<GeneratedColumn> get $columns => [id, kind, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonGroup> instance, {
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
  PersonGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: $GroupsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GroupsTable createAlias(String alias) {
    return $GroupsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<GroupKind, String, String> $converterkind =
      const EnumNameConverter<GroupKind>(GroupKind.values);
}

class PersonGroup extends DataClass implements Insertable<PersonGroup> {
  /// UUID v4, made by GroupsRepository.
  final String id;
  final GroupKind kind;

  /// The group's own name. null = show the members' names.
  final String? name;
  final DateTime createdAt;
  const PersonGroup({
    required this.id,
    required this.kind,
    this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['kind'] = Variable<String>($GroupsTable.$converterkind.toSql(kind));
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GroupsCompanion toCompanion(bool nullToAbsent) {
    return GroupsCompanion(
      id: Value(id),
      kind: Value(kind),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory PersonGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonGroup(
      id: serializer.fromJson<String>(json['id']),
      kind: $GroupsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      name: serializer.fromJson<String?>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(
        $GroupsTable.$converterkind.toJson(kind),
      ),
      'name': serializer.toJson<String?>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PersonGroup copyWith({
    String? id,
    GroupKind? kind,
    Value<String?> name = const Value.absent(),
    DateTime? createdAt,
  }) => PersonGroup(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    name: name.present ? name.value : this.name,
    createdAt: createdAt ?? this.createdAt,
  );
  PersonGroup copyWithCompanion(GroupsCompanion data) {
    return PersonGroup(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonGroup(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonGroup &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class GroupsCompanion extends UpdateCompanion<PersonGroup> {
  final Value<String> id;
  final Value<GroupKind> kind;
  final Value<String?> name;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const GroupsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupsCompanion.insert({
    required String id,
    required GroupKind kind,
    this.name = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       createdAt = Value(createdAt);
  static Insertable<PersonGroup> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupsCompanion copyWith({
    Value<String>? id,
    Value<GroupKind>? kind,
    Value<String?>? name,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return GroupsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      name: name ?? this.name,
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
    if (kind.present) {
      map['kind'] = Variable<String>(
        $GroupsTable.$converterkind.toSql(kind.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
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
    return (StringBuffer('GroupsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupMembersTable extends GroupMembers
    with TableInfo<$GroupMembersTable, GroupMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES "groups" (id) ON DELETE CASCADE',
    ),
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
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [groupId, personId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId, personId};
  @override
  GroupMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupMember(
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $GroupMembersTable createAlias(String alias) {
    return $GroupMembersTable(attachedDatabase, alias);
  }
}

class GroupMember extends DataClass implements Insertable<GroupMember> {
  final String groupId;
  final String personId;

  /// The order of the members, from 0.
  final int position;
  const GroupMember({
    required this.groupId,
    required this.personId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group_id'] = Variable<String>(groupId);
    map['person_id'] = Variable<String>(personId);
    map['position'] = Variable<int>(position);
    return map;
  }

  GroupMembersCompanion toCompanion(bool nullToAbsent) {
    return GroupMembersCompanion(
      groupId: Value(groupId),
      personId: Value(personId),
      position: Value(position),
    );
  }

  factory GroupMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupMember(
      groupId: serializer.fromJson<String>(json['groupId']),
      personId: serializer.fromJson<String>(json['personId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupId': serializer.toJson<String>(groupId),
      'personId': serializer.toJson<String>(personId),
      'position': serializer.toJson<int>(position),
    };
  }

  GroupMember copyWith({String? groupId, String? personId, int? position}) =>
      GroupMember(
        groupId: groupId ?? this.groupId,
        personId: personId ?? this.personId,
        position: position ?? this.position,
      );
  GroupMember copyWithCompanion(GroupMembersCompanion data) {
    return GroupMember(
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      personId: data.personId.present ? data.personId.value : this.personId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupMember(')
          ..write('groupId: $groupId, ')
          ..write('personId: $personId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(groupId, personId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupMember &&
          other.groupId == this.groupId &&
          other.personId == this.personId &&
          other.position == this.position);
}

class GroupMembersCompanion extends UpdateCompanion<GroupMember> {
  final Value<String> groupId;
  final Value<String> personId;
  final Value<int> position;
  final Value<int> rowid;
  const GroupMembersCompanion({
    this.groupId = const Value.absent(),
    this.personId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupMembersCompanion.insert({
    required String groupId,
    required String personId,
    required int position,
    this.rowid = const Value.absent(),
  }) : groupId = Value(groupId),
       personId = Value(personId),
       position = Value(position);
  static Insertable<GroupMember> custom({
    Expression<String>? groupId,
    Expression<String>? personId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (personId != null) 'person_id': personId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupMembersCompanion copyWith({
    Value<String>? groupId,
    Value<String>? personId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return GroupMembersCompanion(
      groupId: groupId ?? this.groupId,
      personId: personId ?? this.personId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupMembersCompanion(')
          ..write('groupId: $groupId, ')
          ..write('personId: $personId, ')
          ..write('position: $position, ')
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES people (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES "groups" (id) ON DELETE CASCADE',
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
    groupId,
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
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
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
      ),
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
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

  /// The person the intention is for, or null when it is for a group
  /// ([groupId]); exactly one of the two is set (the CHECK below, and
  /// IntentionsRepository). Deleting the person deletes their intentions.
  /// Needs `PRAGMA foreign_keys = ON` (AppDatabase.migration, beforeOpen).
  /// Nullable since schema version 5.
  final String? personId;

  /// The group (a couple) the intention is for. GroupsRepository moves the
  /// intentions to a member before it deletes a group; the cascade is only
  /// a safety net. Added in schema version 5.
  final String? groupId;

  /// What came to mind ("saw a bouldering video"). May be empty.
  final String note;
  final IntentionKind kind;
  final IntentionState state;

  /// An attached link.
  final String? link;

  /// When: a date, or a horizon (with [condition] for "when ..."), or
  /// nothing.
  final DateTime? date;
  final Horizon? horizon;
  final String? condition;
  final DateTime createdAt;

  /// Set when the intention leaves `open`; cleared when it is reopened.
  final DateTime? closedAt;
  const Intention({
    required this.id,
    this.personId,
    this.groupId,
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
    if (!nullToAbsent || personId != null) {
      map['person_id'] = Variable<String>(personId);
    }
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
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
      personId: personId == null && nullToAbsent
          ? const Value.absent()
          : Value(personId),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
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
      personId: serializer.fromJson<String?>(json['personId']),
      groupId: serializer.fromJson<String?>(json['groupId']),
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
      'personId': serializer.toJson<String?>(personId),
      'groupId': serializer.toJson<String?>(groupId),
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
    Value<String?> personId = const Value.absent(),
    Value<String?> groupId = const Value.absent(),
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
    personId: personId.present ? personId.value : this.personId,
    groupId: groupId.present ? groupId.value : this.groupId,
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
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
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
          ..write('groupId: $groupId, ')
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
    groupId,
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
          other.groupId == this.groupId &&
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
  final Value<String?> personId;
  final Value<String?> groupId;
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
    this.groupId = const Value.absent(),
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
    this.personId = const Value.absent(),
    this.groupId = const Value.absent(),
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
       createdAt = Value(createdAt);
  static Insertable<Intention> custom({
    Expression<String>? id,
    Expression<String>? personId,
    Expression<String>? groupId,
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
      if (groupId != null) 'group_id': groupId,
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
    Value<String?>? personId,
    Value<String?>? groupId,
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
      groupId: groupId ?? this.groupId,
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
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
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
          ..write('groupId: $groupId, ')
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

class $ContactEventsTable extends ContactEvents
    with TableInfo<$ContactEventsTable, ContactEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ContactKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ContactKind>($ContactEventsTable.$converterkind);
  @override
  late final GeneratedColumnWithTypeConverter<ContactDirection, String>
  direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ContactDirection>($ContactEventsTable.$converterdirection);
  @override
  late final GeneratedColumnWithTypeConverter<ContactSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ContactSource>($ContactEventsTable.$convertersource);
  static const VerificationMeta _activityMeta = const VerificationMeta(
    'activity',
  );
  @override
  late final GeneratedColumn<String> activity = GeneratedColumn<String>(
    'activity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intentionIdMeta = const VerificationMeta(
    'intentionId',
  );
  @override
  late final GeneratedColumn<String> intentionId = GeneratedColumn<String>(
    'intention_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES intentions (id) ON DELETE SET NULL',
    ),
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
  static const VerificationMeta _activityIconMeta = const VerificationMeta(
    'activityIcon',
  );
  @override
  late final GeneratedColumn<String> activityIcon = GeneratedColumn<String>(
    'activity_icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES "groups" (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _sharedIdMeta = const VerificationMeta(
    'sharedId',
  );
  @override
  late final GeneratedColumn<String> sharedId = GeneratedColumn<String>(
    'shared_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    personId,
    at,
    kind,
    direction,
    source,
    activity,
    note,
    intentionId,
    createdAt,
    activityIcon,
    groupId,
    sharedId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contact_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContactEvent> instance, {
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
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('activity')) {
      context.handle(
        _activityMeta,
        activity.isAcceptableOrUnknown(data['activity']!, _activityMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('intention_id')) {
      context.handle(
        _intentionIdMeta,
        intentionId.isAcceptableOrUnknown(
          data['intention_id']!,
          _intentionIdMeta,
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
    if (data.containsKey('activity_icon')) {
      context.handle(
        _activityIconMeta,
        activityIcon.isAcceptableOrUnknown(
          data['activity_icon']!,
          _activityIconMeta,
        ),
      );
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('shared_id')) {
      context.handle(
        _sharedIdMeta,
        sharedId.isAcceptableOrUnknown(data['shared_id']!, _sharedIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContactEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
      kind: $ContactEventsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      direction: $ContactEventsTable.$converterdirection.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}direction'],
        )!,
      ),
      source: $ContactEventsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      activity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      intentionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}intention_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      activityIcon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_icon'],
      ),
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
      sharedId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shared_id'],
      ),
    );
  }

  @override
  $ContactEventsTable createAlias(String alias) {
    return $ContactEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ContactKind, String, String> $converterkind =
      const EnumNameConverter<ContactKind>(ContactKind.values);
  static JsonTypeConverter2<ContactDirection, String, String>
  $converterdirection = const EnumNameConverter<ContactDirection>(
    ContactDirection.values,
  );
  static JsonTypeConverter2<ContactSource, String, String> $convertersource =
      const EnumNameConverter<ContactSource>(ContactSource.values);
}

class ContactEvent extends DataClass implements Insertable<ContactEvent> {
  /// UUID v4, made by ContactEventsRepository.
  final String id;

  /// Deleting the person deletes their events (foreign keys are on, see
  /// AppDatabase.migration).
  final String personId;

  /// When the contact happened.
  final DateTime at;
  final ContactKind kind;
  final ContactDirection direction;
  final ContactSource source;

  /// What they did together ("bouldering", a game's name, a restaurant).
  final String? activity;

  /// The one line for next time ("new job in March").
  final String? note;

  /// The intention this contact closed. Deleting the intention keeps the
  /// event and clears the link.
  final String? intentionId;
  final DateTime createdAt;

  /// The name of an icon for the activity (a later feature). Added in
  /// schema version 4.
  final String? activityIcon;

  /// The couple that was met, when the contact was with a group. Cleared
  /// when the group is dissolved; the rows stay. Added in schema version 5.
  final String? groupId;

  /// Ties the rows of one shared contact together: meeting a couple is one
  /// row per member (so each timeline and stamp works as for one person),
  /// all with the same [sharedId]. Editing or deleting one edits or deletes
  /// all (ContactEventsRepository). null = a contact with one person. Added
  /// in schema version 5.
  final String? sharedId;
  const ContactEvent({
    required this.id,
    required this.personId,
    required this.at,
    required this.kind,
    required this.direction,
    required this.source,
    this.activity,
    this.note,
    this.intentionId,
    required this.createdAt,
    this.activityIcon,
    this.groupId,
    this.sharedId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['person_id'] = Variable<String>(personId);
    map['at'] = Variable<DateTime>(at);
    {
      map['kind'] = Variable<String>(
        $ContactEventsTable.$converterkind.toSql(kind),
      );
    }
    {
      map['direction'] = Variable<String>(
        $ContactEventsTable.$converterdirection.toSql(direction),
      );
    }
    {
      map['source'] = Variable<String>(
        $ContactEventsTable.$convertersource.toSql(source),
      );
    }
    if (!nullToAbsent || activity != null) {
      map['activity'] = Variable<String>(activity);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || intentionId != null) {
      map['intention_id'] = Variable<String>(intentionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || activityIcon != null) {
      map['activity_icon'] = Variable<String>(activityIcon);
    }
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    if (!nullToAbsent || sharedId != null) {
      map['shared_id'] = Variable<String>(sharedId);
    }
    return map;
  }

  ContactEventsCompanion toCompanion(bool nullToAbsent) {
    return ContactEventsCompanion(
      id: Value(id),
      personId: Value(personId),
      at: Value(at),
      kind: Value(kind),
      direction: Value(direction),
      source: Value(source),
      activity: activity == null && nullToAbsent
          ? const Value.absent()
          : Value(activity),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      intentionId: intentionId == null && nullToAbsent
          ? const Value.absent()
          : Value(intentionId),
      createdAt: Value(createdAt),
      activityIcon: activityIcon == null && nullToAbsent
          ? const Value.absent()
          : Value(activityIcon),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      sharedId: sharedId == null && nullToAbsent
          ? const Value.absent()
          : Value(sharedId),
    );
  }

  factory ContactEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactEvent(
      id: serializer.fromJson<String>(json['id']),
      personId: serializer.fromJson<String>(json['personId']),
      at: serializer.fromJson<DateTime>(json['at']),
      kind: $ContactEventsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      direction: $ContactEventsTable.$converterdirection.fromJson(
        serializer.fromJson<String>(json['direction']),
      ),
      source: $ContactEventsTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      activity: serializer.fromJson<String?>(json['activity']),
      note: serializer.fromJson<String?>(json['note']),
      intentionId: serializer.fromJson<String?>(json['intentionId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      activityIcon: serializer.fromJson<String?>(json['activityIcon']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      sharedId: serializer.fromJson<String?>(json['sharedId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'personId': serializer.toJson<String>(personId),
      'at': serializer.toJson<DateTime>(at),
      'kind': serializer.toJson<String>(
        $ContactEventsTable.$converterkind.toJson(kind),
      ),
      'direction': serializer.toJson<String>(
        $ContactEventsTable.$converterdirection.toJson(direction),
      ),
      'source': serializer.toJson<String>(
        $ContactEventsTable.$convertersource.toJson(source),
      ),
      'activity': serializer.toJson<String?>(activity),
      'note': serializer.toJson<String?>(note),
      'intentionId': serializer.toJson<String?>(intentionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'activityIcon': serializer.toJson<String?>(activityIcon),
      'groupId': serializer.toJson<String?>(groupId),
      'sharedId': serializer.toJson<String?>(sharedId),
    };
  }

  ContactEvent copyWith({
    String? id,
    String? personId,
    DateTime? at,
    ContactKind? kind,
    ContactDirection? direction,
    ContactSource? source,
    Value<String?> activity = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> intentionId = const Value.absent(),
    DateTime? createdAt,
    Value<String?> activityIcon = const Value.absent(),
    Value<String?> groupId = const Value.absent(),
    Value<String?> sharedId = const Value.absent(),
  }) => ContactEvent(
    id: id ?? this.id,
    personId: personId ?? this.personId,
    at: at ?? this.at,
    kind: kind ?? this.kind,
    direction: direction ?? this.direction,
    source: source ?? this.source,
    activity: activity.present ? activity.value : this.activity,
    note: note.present ? note.value : this.note,
    intentionId: intentionId.present ? intentionId.value : this.intentionId,
    createdAt: createdAt ?? this.createdAt,
    activityIcon: activityIcon.present ? activityIcon.value : this.activityIcon,
    groupId: groupId.present ? groupId.value : this.groupId,
    sharedId: sharedId.present ? sharedId.value : this.sharedId,
  );
  ContactEvent copyWithCompanion(ContactEventsCompanion data) {
    return ContactEvent(
      id: data.id.present ? data.id.value : this.id,
      personId: data.personId.present ? data.personId.value : this.personId,
      at: data.at.present ? data.at.value : this.at,
      kind: data.kind.present ? data.kind.value : this.kind,
      direction: data.direction.present ? data.direction.value : this.direction,
      source: data.source.present ? data.source.value : this.source,
      activity: data.activity.present ? data.activity.value : this.activity,
      note: data.note.present ? data.note.value : this.note,
      intentionId: data.intentionId.present
          ? data.intentionId.value
          : this.intentionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      activityIcon: data.activityIcon.present
          ? data.activityIcon.value
          : this.activityIcon,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      sharedId: data.sharedId.present ? data.sharedId.value : this.sharedId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactEvent(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('at: $at, ')
          ..write('kind: $kind, ')
          ..write('direction: $direction, ')
          ..write('source: $source, ')
          ..write('activity: $activity, ')
          ..write('note: $note, ')
          ..write('intentionId: $intentionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('activityIcon: $activityIcon, ')
          ..write('groupId: $groupId, ')
          ..write('sharedId: $sharedId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    personId,
    at,
    kind,
    direction,
    source,
    activity,
    note,
    intentionId,
    createdAt,
    activityIcon,
    groupId,
    sharedId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactEvent &&
          other.id == this.id &&
          other.personId == this.personId &&
          other.at == this.at &&
          other.kind == this.kind &&
          other.direction == this.direction &&
          other.source == this.source &&
          other.activity == this.activity &&
          other.note == this.note &&
          other.intentionId == this.intentionId &&
          other.createdAt == this.createdAt &&
          other.activityIcon == this.activityIcon &&
          other.groupId == this.groupId &&
          other.sharedId == this.sharedId);
}

class ContactEventsCompanion extends UpdateCompanion<ContactEvent> {
  final Value<String> id;
  final Value<String> personId;
  final Value<DateTime> at;
  final Value<ContactKind> kind;
  final Value<ContactDirection> direction;
  final Value<ContactSource> source;
  final Value<String?> activity;
  final Value<String?> note;
  final Value<String?> intentionId;
  final Value<DateTime> createdAt;
  final Value<String?> activityIcon;
  final Value<String?> groupId;
  final Value<String?> sharedId;
  final Value<int> rowid;
  const ContactEventsCompanion({
    this.id = const Value.absent(),
    this.personId = const Value.absent(),
    this.at = const Value.absent(),
    this.kind = const Value.absent(),
    this.direction = const Value.absent(),
    this.source = const Value.absent(),
    this.activity = const Value.absent(),
    this.note = const Value.absent(),
    this.intentionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.activityIcon = const Value.absent(),
    this.groupId = const Value.absent(),
    this.sharedId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContactEventsCompanion.insert({
    required String id,
    required String personId,
    required DateTime at,
    required ContactKind kind,
    required ContactDirection direction,
    required ContactSource source,
    this.activity = const Value.absent(),
    this.note = const Value.absent(),
    this.intentionId = const Value.absent(),
    required DateTime createdAt,
    this.activityIcon = const Value.absent(),
    this.groupId = const Value.absent(),
    this.sharedId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       personId = Value(personId),
       at = Value(at),
       kind = Value(kind),
       direction = Value(direction),
       source = Value(source),
       createdAt = Value(createdAt);
  static Insertable<ContactEvent> custom({
    Expression<String>? id,
    Expression<String>? personId,
    Expression<DateTime>? at,
    Expression<String>? kind,
    Expression<String>? direction,
    Expression<String>? source,
    Expression<String>? activity,
    Expression<String>? note,
    Expression<String>? intentionId,
    Expression<DateTime>? createdAt,
    Expression<String>? activityIcon,
    Expression<String>? groupId,
    Expression<String>? sharedId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personId != null) 'person_id': personId,
      if (at != null) 'at': at,
      if (kind != null) 'kind': kind,
      if (direction != null) 'direction': direction,
      if (source != null) 'source': source,
      if (activity != null) 'activity': activity,
      if (note != null) 'note': note,
      if (intentionId != null) 'intention_id': intentionId,
      if (createdAt != null) 'created_at': createdAt,
      if (activityIcon != null) 'activity_icon': activityIcon,
      if (groupId != null) 'group_id': groupId,
      if (sharedId != null) 'shared_id': sharedId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContactEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? personId,
    Value<DateTime>? at,
    Value<ContactKind>? kind,
    Value<ContactDirection>? direction,
    Value<ContactSource>? source,
    Value<String?>? activity,
    Value<String?>? note,
    Value<String?>? intentionId,
    Value<DateTime>? createdAt,
    Value<String?>? activityIcon,
    Value<String?>? groupId,
    Value<String?>? sharedId,
    Value<int>? rowid,
  }) {
    return ContactEventsCompanion(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      at: at ?? this.at,
      kind: kind ?? this.kind,
      direction: direction ?? this.direction,
      source: source ?? this.source,
      activity: activity ?? this.activity,
      note: note ?? this.note,
      intentionId: intentionId ?? this.intentionId,
      createdAt: createdAt ?? this.createdAt,
      activityIcon: activityIcon ?? this.activityIcon,
      groupId: groupId ?? this.groupId,
      sharedId: sharedId ?? this.sharedId,
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
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $ContactEventsTable.$converterkind.toSql(kind.value),
      );
    }
    if (direction.present) {
      map['direction'] = Variable<String>(
        $ContactEventsTable.$converterdirection.toSql(direction.value),
      );
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $ContactEventsTable.$convertersource.toSql(source.value),
      );
    }
    if (activity.present) {
      map['activity'] = Variable<String>(activity.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (intentionId.present) {
      map['intention_id'] = Variable<String>(intentionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (activityIcon.present) {
      map['activity_icon'] = Variable<String>(activityIcon.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (sharedId.present) {
      map['shared_id'] = Variable<String>(sharedId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactEventsCompanion(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('at: $at, ')
          ..write('kind: $kind, ')
          ..write('direction: $direction, ')
          ..write('source: $source, ')
          ..write('activity: $activity, ')
          ..write('note: $note, ')
          ..write('intentionId: $intentionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('activityIcon: $activityIcon, ')
          ..write('groupId: $groupId, ')
          ..write('sharedId: $sharedId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DayAnswersTable extends DayAnswers
    with TableInfo<$DayAnswersTable, DayAnswer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayAnswersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DayAnswerValue, String> answer =
      GeneratedColumn<String>(
        'answer',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DayAnswerValue>($DayAnswersTable.$converteranswer);
  static const VerificationMeta _answeredAtMeta = const VerificationMeta(
    'answeredAt',
  );
  @override
  late final GeneratedColumn<DateTime> answeredAt = GeneratedColumn<DateTime>(
    'answered_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [day, answer, answeredAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_answers';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayAnswer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('answered_at')) {
      context.handle(
        _answeredAtMeta,
        answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  DayAnswer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayAnswer(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      answer: $DayAnswersTable.$converteranswer.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}answer'],
        )!,
      ),
      answeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}answered_at'],
      ),
    );
  }

  @override
  $DayAnswersTable createAlias(String alias) {
    return $DayAnswersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DayAnswerValue, String, String> $converteranswer =
      const EnumNameConverter<DayAnswerValue>(DayAnswerValue.values);
}

class DayAnswer extends DataClass implements Insertable<DayAnswer> {
  /// The local day as `YYYY-MM-DD`.
  final String day;
  final DayAnswerValue answer;
  final DateTime? answeredAt;
  const DayAnswer({required this.day, required this.answer, this.answeredAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    {
      map['answer'] = Variable<String>(
        $DayAnswersTable.$converteranswer.toSql(answer),
      );
    }
    if (!nullToAbsent || answeredAt != null) {
      map['answered_at'] = Variable<DateTime>(answeredAt);
    }
    return map;
  }

  DayAnswersCompanion toCompanion(bool nullToAbsent) {
    return DayAnswersCompanion(
      day: Value(day),
      answer: Value(answer),
      answeredAt: answeredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(answeredAt),
    );
  }

  factory DayAnswer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayAnswer(
      day: serializer.fromJson<String>(json['day']),
      answer: $DayAnswersTable.$converteranswer.fromJson(
        serializer.fromJson<String>(json['answer']),
      ),
      answeredAt: serializer.fromJson<DateTime?>(json['answeredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'answer': serializer.toJson<String>(
        $DayAnswersTable.$converteranswer.toJson(answer),
      ),
      'answeredAt': serializer.toJson<DateTime?>(answeredAt),
    };
  }

  DayAnswer copyWith({
    String? day,
    DayAnswerValue? answer,
    Value<DateTime?> answeredAt = const Value.absent(),
  }) => DayAnswer(
    day: day ?? this.day,
    answer: answer ?? this.answer,
    answeredAt: answeredAt.present ? answeredAt.value : this.answeredAt,
  );
  DayAnswer copyWithCompanion(DayAnswersCompanion data) {
    return DayAnswer(
      day: data.day.present ? data.day.value : this.day,
      answer: data.answer.present ? data.answer.value : this.answer,
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayAnswer(')
          ..write('day: $day, ')
          ..write('answer: $answer, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, answer, answeredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayAnswer &&
          other.day == this.day &&
          other.answer == this.answer &&
          other.answeredAt == this.answeredAt);
}

class DayAnswersCompanion extends UpdateCompanion<DayAnswer> {
  final Value<String> day;
  final Value<DayAnswerValue> answer;
  final Value<DateTime?> answeredAt;
  final Value<int> rowid;
  const DayAnswersCompanion({
    this.day = const Value.absent(),
    this.answer = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayAnswersCompanion.insert({
    required String day,
    required DayAnswerValue answer,
    this.answeredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : day = Value(day),
       answer = Value(answer);
  static Insertable<DayAnswer> custom({
    Expression<String>? day,
    Expression<String>? answer,
    Expression<DateTime>? answeredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (answer != null) 'answer': answer,
      if (answeredAt != null) 'answered_at': answeredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayAnswersCompanion copyWith({
    Value<String>? day,
    Value<DayAnswerValue>? answer,
    Value<DateTime?>? answeredAt,
    Value<int>? rowid,
  }) {
    return DayAnswersCompanion(
      day: day ?? this.day,
      answer: answer ?? this.answer,
      answeredAt: answeredAt ?? this.answeredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (answer.present) {
      map['answer'] = Variable<String>(
        $DayAnswersTable.$converteranswer.toSql(answer.value),
      );
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<DateTime>(answeredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayAnswersCompanion(')
          ..write('day: $day, ')
          ..write('answer: $answer, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TreatsTable extends Treats with TableInfo<$TreatsTable, Treat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TreatsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _stampsNeededMeta = const VerificationMeta(
    'stampsNeeded',
  );
  @override
  late final GeneratedColumn<int> stampsNeeded = GeneratedColumn<int>(
    'stamps_needed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TreatState, String> state =
      GeneratedColumn<String>(
        'state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TreatState>($TreatsTable.$converterstate);
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _earnedAtMeta = const VerificationMeta(
    'earnedAt',
  );
  @override
  late final GeneratedColumn<DateTime> earnedAt = GeneratedColumn<DateTime>(
    'earned_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enjoyedAtMeta = const VerificationMeta(
    'enjoyedAt',
  );
  @override
  late final GeneratedColumn<DateTime> enjoyedAt = GeneratedColumn<DateTime>(
    'enjoyed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    stampsNeeded,
    state,
    position,
    createdAt,
    earnedAt,
    enjoyedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'treats';
  @override
  VerificationContext validateIntegrity(
    Insertable<Treat> instance, {
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
    if (data.containsKey('stamps_needed')) {
      context.handle(
        _stampsNeededMeta,
        stampsNeeded.isAcceptableOrUnknown(
          data['stamps_needed']!,
          _stampsNeededMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stampsNeededMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('earned_at')) {
      context.handle(
        _earnedAtMeta,
        earnedAt.isAcceptableOrUnknown(data['earned_at']!, _earnedAtMeta),
      );
    }
    if (data.containsKey('enjoyed_at')) {
      context.handle(
        _enjoyedAtMeta,
        enjoyedAt.isAcceptableOrUnknown(data['enjoyed_at']!, _enjoyedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Treat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Treat(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      stampsNeeded: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stamps_needed'],
      )!,
      state: $TreatsTable.$converterstate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}state'],
        )!,
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      earnedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}earned_at'],
      ),
      enjoyedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}enjoyed_at'],
      ),
    );
  }

  @override
  $TreatsTable createAlias(String alias) {
    return $TreatsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TreatState, String, String> $converterstate =
      const EnumNameConverter<TreatState>(TreatState.values);
}

class Treat extends DataClass implements Insertable<Treat> {
  /// UUID v4, made by a repository.
  final String id;
  final String name;

  /// How many stamps fill the card.
  final int stampsNeeded;
  final TreatState state;

  /// The order among the waiting treats.
  final int position;
  final DateTime createdAt;
  final DateTime? earnedAt;
  final DateTime? enjoyedAt;
  const Treat({
    required this.id,
    required this.name,
    required this.stampsNeeded,
    required this.state,
    required this.position,
    required this.createdAt,
    this.earnedAt,
    this.enjoyedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['stamps_needed'] = Variable<int>(stampsNeeded);
    {
      map['state'] = Variable<String>(
        $TreatsTable.$converterstate.toSql(state),
      );
    }
    map['position'] = Variable<int>(position);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || earnedAt != null) {
      map['earned_at'] = Variable<DateTime>(earnedAt);
    }
    if (!nullToAbsent || enjoyedAt != null) {
      map['enjoyed_at'] = Variable<DateTime>(enjoyedAt);
    }
    return map;
  }

  TreatsCompanion toCompanion(bool nullToAbsent) {
    return TreatsCompanion(
      id: Value(id),
      name: Value(name),
      stampsNeeded: Value(stampsNeeded),
      state: Value(state),
      position: Value(position),
      createdAt: Value(createdAt),
      earnedAt: earnedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(earnedAt),
      enjoyedAt: enjoyedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(enjoyedAt),
    );
  }

  factory Treat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Treat(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      stampsNeeded: serializer.fromJson<int>(json['stampsNeeded']),
      state: $TreatsTable.$converterstate.fromJson(
        serializer.fromJson<String>(json['state']),
      ),
      position: serializer.fromJson<int>(json['position']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      earnedAt: serializer.fromJson<DateTime?>(json['earnedAt']),
      enjoyedAt: serializer.fromJson<DateTime?>(json['enjoyedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'stampsNeeded': serializer.toJson<int>(stampsNeeded),
      'state': serializer.toJson<String>(
        $TreatsTable.$converterstate.toJson(state),
      ),
      'position': serializer.toJson<int>(position),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'earnedAt': serializer.toJson<DateTime?>(earnedAt),
      'enjoyedAt': serializer.toJson<DateTime?>(enjoyedAt),
    };
  }

  Treat copyWith({
    String? id,
    String? name,
    int? stampsNeeded,
    TreatState? state,
    int? position,
    DateTime? createdAt,
    Value<DateTime?> earnedAt = const Value.absent(),
    Value<DateTime?> enjoyedAt = const Value.absent(),
  }) => Treat(
    id: id ?? this.id,
    name: name ?? this.name,
    stampsNeeded: stampsNeeded ?? this.stampsNeeded,
    state: state ?? this.state,
    position: position ?? this.position,
    createdAt: createdAt ?? this.createdAt,
    earnedAt: earnedAt.present ? earnedAt.value : this.earnedAt,
    enjoyedAt: enjoyedAt.present ? enjoyedAt.value : this.enjoyedAt,
  );
  Treat copyWithCompanion(TreatsCompanion data) {
    return Treat(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      stampsNeeded: data.stampsNeeded.present
          ? data.stampsNeeded.value
          : this.stampsNeeded,
      state: data.state.present ? data.state.value : this.state,
      position: data.position.present ? data.position.value : this.position,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      earnedAt: data.earnedAt.present ? data.earnedAt.value : this.earnedAt,
      enjoyedAt: data.enjoyedAt.present ? data.enjoyedAt.value : this.enjoyedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Treat(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('stampsNeeded: $stampsNeeded, ')
          ..write('state: $state, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('earnedAt: $earnedAt, ')
          ..write('enjoyedAt: $enjoyedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    stampsNeeded,
    state,
    position,
    createdAt,
    earnedAt,
    enjoyedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Treat &&
          other.id == this.id &&
          other.name == this.name &&
          other.stampsNeeded == this.stampsNeeded &&
          other.state == this.state &&
          other.position == this.position &&
          other.createdAt == this.createdAt &&
          other.earnedAt == this.earnedAt &&
          other.enjoyedAt == this.enjoyedAt);
}

class TreatsCompanion extends UpdateCompanion<Treat> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> stampsNeeded;
  final Value<TreatState> state;
  final Value<int> position;
  final Value<DateTime> createdAt;
  final Value<DateTime?> earnedAt;
  final Value<DateTime?> enjoyedAt;
  final Value<int> rowid;
  const TreatsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.stampsNeeded = const Value.absent(),
    this.state = const Value.absent(),
    this.position = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.earnedAt = const Value.absent(),
    this.enjoyedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TreatsCompanion.insert({
    required String id,
    required String name,
    required int stampsNeeded,
    required TreatState state,
    required int position,
    required DateTime createdAt,
    this.earnedAt = const Value.absent(),
    this.enjoyedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       stampsNeeded = Value(stampsNeeded),
       state = Value(state),
       position = Value(position),
       createdAt = Value(createdAt);
  static Insertable<Treat> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? stampsNeeded,
    Expression<String>? state,
    Expression<int>? position,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? earnedAt,
    Expression<DateTime>? enjoyedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (stampsNeeded != null) 'stamps_needed': stampsNeeded,
      if (state != null) 'state': state,
      if (position != null) 'position': position,
      if (createdAt != null) 'created_at': createdAt,
      if (earnedAt != null) 'earned_at': earnedAt,
      if (enjoyedAt != null) 'enjoyed_at': enjoyedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TreatsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? stampsNeeded,
    Value<TreatState>? state,
    Value<int>? position,
    Value<DateTime>? createdAt,
    Value<DateTime?>? earnedAt,
    Value<DateTime?>? enjoyedAt,
    Value<int>? rowid,
  }) {
    return TreatsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      stampsNeeded: stampsNeeded ?? this.stampsNeeded,
      state: state ?? this.state,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      earnedAt: earnedAt ?? this.earnedAt,
      enjoyedAt: enjoyedAt ?? this.enjoyedAt,
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
    if (stampsNeeded.present) {
      map['stamps_needed'] = Variable<int>(stampsNeeded.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(
        $TreatsTable.$converterstate.toSql(state.value),
      );
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (earnedAt.present) {
      map['earned_at'] = Variable<DateTime>(earnedAt.value);
    }
    if (enjoyedAt.present) {
      map['enjoyed_at'] = Variable<DateTime>(enjoyedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TreatsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('stampsNeeded: $stampsNeeded, ')
          ..write('state: $state, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('earnedAt: $earnedAt, ')
          ..write('enjoyedAt: $enjoyedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StampsTable extends Stamps with TableInfo<$StampsTable, Stamp> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StampsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES people (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _contactEventIdMeta = const VerificationMeta(
    'contactEventId',
  );
  @override
  late final GeneratedColumn<String> contactEventId = GeneratedColumn<String>(
    'contact_event_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contact_events (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _treatIdMeta = const VerificationMeta(
    'treatId',
  );
  @override
  late final GeneratedColumn<String> treatId = GeneratedColumn<String>(
    'treat_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES treats (id) ON DELETE SET NULL',
    ),
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
    at,
    value,
    personId,
    contactEventId,
    treatId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stamps';
  @override
  VerificationContext validateIntegrity(
    Insertable<Stamp> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    }
    if (data.containsKey('contact_event_id')) {
      context.handle(
        _contactEventIdMeta,
        contactEventId.isAcceptableOrUnknown(
          data['contact_event_id']!,
          _contactEventIdMeta,
        ),
      );
    }
    if (data.containsKey('treat_id')) {
      context.handle(
        _treatIdMeta,
        treatId.isAcceptableOrUnknown(data['treat_id']!, _treatIdMeta),
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
  Stamp map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Stamp(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      ),
      contactEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_event_id'],
      ),
      treatId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}treat_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StampsTable createAlias(String alias) {
    return $StampsTable(attachedDatabase, alias);
  }
}

class Stamp extends DataClass implements Insertable<Stamp> {
  /// UUID v4, made by a repository.
  final String id;

  /// When it was earned.
  final DateTime at;
  final int value;
  final String? personId;
  final String? contactEventId;

  /// The card it went onto.
  final String? treatId;
  final DateTime createdAt;
  const Stamp({
    required this.id,
    required this.at,
    required this.value,
    this.personId,
    this.contactEventId,
    this.treatId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['at'] = Variable<DateTime>(at);
    map['value'] = Variable<int>(value);
    if (!nullToAbsent || personId != null) {
      map['person_id'] = Variable<String>(personId);
    }
    if (!nullToAbsent || contactEventId != null) {
      map['contact_event_id'] = Variable<String>(contactEventId);
    }
    if (!nullToAbsent || treatId != null) {
      map['treat_id'] = Variable<String>(treatId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StampsCompanion toCompanion(bool nullToAbsent) {
    return StampsCompanion(
      id: Value(id),
      at: Value(at),
      value: Value(value),
      personId: personId == null && nullToAbsent
          ? const Value.absent()
          : Value(personId),
      contactEventId: contactEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(contactEventId),
      treatId: treatId == null && nullToAbsent
          ? const Value.absent()
          : Value(treatId),
      createdAt: Value(createdAt),
    );
  }

  factory Stamp.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Stamp(
      id: serializer.fromJson<String>(json['id']),
      at: serializer.fromJson<DateTime>(json['at']),
      value: serializer.fromJson<int>(json['value']),
      personId: serializer.fromJson<String?>(json['personId']),
      contactEventId: serializer.fromJson<String?>(json['contactEventId']),
      treatId: serializer.fromJson<String?>(json['treatId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'at': serializer.toJson<DateTime>(at),
      'value': serializer.toJson<int>(value),
      'personId': serializer.toJson<String?>(personId),
      'contactEventId': serializer.toJson<String?>(contactEventId),
      'treatId': serializer.toJson<String?>(treatId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Stamp copyWith({
    String? id,
    DateTime? at,
    int? value,
    Value<String?> personId = const Value.absent(),
    Value<String?> contactEventId = const Value.absent(),
    Value<String?> treatId = const Value.absent(),
    DateTime? createdAt,
  }) => Stamp(
    id: id ?? this.id,
    at: at ?? this.at,
    value: value ?? this.value,
    personId: personId.present ? personId.value : this.personId,
    contactEventId: contactEventId.present
        ? contactEventId.value
        : this.contactEventId,
    treatId: treatId.present ? treatId.value : this.treatId,
    createdAt: createdAt ?? this.createdAt,
  );
  Stamp copyWithCompanion(StampsCompanion data) {
    return Stamp(
      id: data.id.present ? data.id.value : this.id,
      at: data.at.present ? data.at.value : this.at,
      value: data.value.present ? data.value.value : this.value,
      personId: data.personId.present ? data.personId.value : this.personId,
      contactEventId: data.contactEventId.present
          ? data.contactEventId.value
          : this.contactEventId,
      treatId: data.treatId.present ? data.treatId.value : this.treatId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Stamp(')
          ..write('id: $id, ')
          ..write('at: $at, ')
          ..write('value: $value, ')
          ..write('personId: $personId, ')
          ..write('contactEventId: $contactEventId, ')
          ..write('treatId: $treatId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, at, value, personId, contactEventId, treatId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Stamp &&
          other.id == this.id &&
          other.at == this.at &&
          other.value == this.value &&
          other.personId == this.personId &&
          other.contactEventId == this.contactEventId &&
          other.treatId == this.treatId &&
          other.createdAt == this.createdAt);
}

class StampsCompanion extends UpdateCompanion<Stamp> {
  final Value<String> id;
  final Value<DateTime> at;
  final Value<int> value;
  final Value<String?> personId;
  final Value<String?> contactEventId;
  final Value<String?> treatId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StampsCompanion({
    this.id = const Value.absent(),
    this.at = const Value.absent(),
    this.value = const Value.absent(),
    this.personId = const Value.absent(),
    this.contactEventId = const Value.absent(),
    this.treatId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StampsCompanion.insert({
    required String id,
    required DateTime at,
    required int value,
    this.personId = const Value.absent(),
    this.contactEventId = const Value.absent(),
    this.treatId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       at = Value(at),
       value = Value(value),
       createdAt = Value(createdAt);
  static Insertable<Stamp> custom({
    Expression<String>? id,
    Expression<DateTime>? at,
    Expression<int>? value,
    Expression<String>? personId,
    Expression<String>? contactEventId,
    Expression<String>? treatId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (at != null) 'at': at,
      if (value != null) 'value': value,
      if (personId != null) 'person_id': personId,
      if (contactEventId != null) 'contact_event_id': contactEventId,
      if (treatId != null) 'treat_id': treatId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StampsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? at,
    Value<int>? value,
    Value<String?>? personId,
    Value<String?>? contactEventId,
    Value<String?>? treatId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return StampsCompanion(
      id: id ?? this.id,
      at: at ?? this.at,
      value: value ?? this.value,
      personId: personId ?? this.personId,
      contactEventId: contactEventId ?? this.contactEventId,
      treatId: treatId ?? this.treatId,
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
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (contactEventId.present) {
      map['contact_event_id'] = Variable<String>(contactEventId.value);
    }
    if (treatId.present) {
      map['treat_id'] = Variable<String>(treatId.value);
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
    return (StringBuffer('StampsCompanion(')
          ..write('id: $id, ')
          ..write('at: $at, ')
          ..write('value: $value, ')
          ..write('personId: $personId, ')
          ..write('contactEventId: $contactEventId, ')
          ..write('treatId: $treatId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IdeasTable extends Ideas with TableInfo<$IdeasTable, Idea> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IdeasTable(this.attachedDatabase, [this._alias]);
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
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<IdeaKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<IdeaKind>($IdeasTable.$converterkind);
  static const VerificationMeta _linkMeta = const VerificationMeta('link');
  @override
  late final GeneratedColumn<String> link = GeneratedColumn<String>(
    'link',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
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
  static const VerificationMeta _doneAtMeta = const VerificationMeta('doneAt');
  @override
  late final GeneratedColumn<DateTime> doneAt = GeneratedColumn<DateTime>(
    'done_at',
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
    link,
    imagePath,
    createdAt,
    doneAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ideas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Idea> instance, {
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
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('link')) {
      context.handle(
        _linkMeta,
        link.isAcceptableOrUnknown(data['link']!, _linkMeta),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
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
    if (data.containsKey('done_at')) {
      context.handle(
        _doneAtMeta,
        doneAt.isAcceptableOrUnknown(data['done_at']!, _doneAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Idea map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Idea(
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
      kind: $IdeasTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      link: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}link'],
      ),
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      doneAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}done_at'],
      ),
    );
  }

  @override
  $IdeasTable createAlias(String alias) {
    return $IdeasTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<IdeaKind, String, String> $converterkind =
      const EnumNameConverter<IdeaKind>(IdeaKind.values);
}

class Idea extends DataClass implements Insertable<Idea> {
  /// UUID v4, made by a repository.
  final String id;

  /// Deleting the person deletes their ideas.
  final String personId;
  final String note;
  final IdeaKind kind;
  final String? link;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime? doneAt;
  const Idea({
    required this.id,
    required this.personId,
    required this.note,
    required this.kind,
    this.link,
    this.imagePath,
    required this.createdAt,
    this.doneAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['person_id'] = Variable<String>(personId);
    map['note'] = Variable<String>(note);
    {
      map['kind'] = Variable<String>($IdeasTable.$converterkind.toSql(kind));
    }
    if (!nullToAbsent || link != null) {
      map['link'] = Variable<String>(link);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || doneAt != null) {
      map['done_at'] = Variable<DateTime>(doneAt);
    }
    return map;
  }

  IdeasCompanion toCompanion(bool nullToAbsent) {
    return IdeasCompanion(
      id: Value(id),
      personId: Value(personId),
      note: Value(note),
      kind: Value(kind),
      link: link == null && nullToAbsent ? const Value.absent() : Value(link),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      createdAt: Value(createdAt),
      doneAt: doneAt == null && nullToAbsent
          ? const Value.absent()
          : Value(doneAt),
    );
  }

  factory Idea.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Idea(
      id: serializer.fromJson<String>(json['id']),
      personId: serializer.fromJson<String>(json['personId']),
      note: serializer.fromJson<String>(json['note']),
      kind: $IdeasTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      link: serializer.fromJson<String?>(json['link']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      doneAt: serializer.fromJson<DateTime?>(json['doneAt']),
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
        $IdeasTable.$converterkind.toJson(kind),
      ),
      'link': serializer.toJson<String?>(link),
      'imagePath': serializer.toJson<String?>(imagePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'doneAt': serializer.toJson<DateTime?>(doneAt),
    };
  }

  Idea copyWith({
    String? id,
    String? personId,
    String? note,
    IdeaKind? kind,
    Value<String?> link = const Value.absent(),
    Value<String?> imagePath = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> doneAt = const Value.absent(),
  }) => Idea(
    id: id ?? this.id,
    personId: personId ?? this.personId,
    note: note ?? this.note,
    kind: kind ?? this.kind,
    link: link.present ? link.value : this.link,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    createdAt: createdAt ?? this.createdAt,
    doneAt: doneAt.present ? doneAt.value : this.doneAt,
  );
  Idea copyWithCompanion(IdeasCompanion data) {
    return Idea(
      id: data.id.present ? data.id.value : this.id,
      personId: data.personId.present ? data.personId.value : this.personId,
      note: data.note.present ? data.note.value : this.note,
      kind: data.kind.present ? data.kind.value : this.kind,
      link: data.link.present ? data.link.value : this.link,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      doneAt: data.doneAt.present ? data.doneAt.value : this.doneAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Idea(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('note: $note, ')
          ..write('kind: $kind, ')
          ..write('link: $link, ')
          ..write('imagePath: $imagePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('doneAt: $doneAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, personId, note, kind, link, imagePath, createdAt, doneAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Idea &&
          other.id == this.id &&
          other.personId == this.personId &&
          other.note == this.note &&
          other.kind == this.kind &&
          other.link == this.link &&
          other.imagePath == this.imagePath &&
          other.createdAt == this.createdAt &&
          other.doneAt == this.doneAt);
}

class IdeasCompanion extends UpdateCompanion<Idea> {
  final Value<String> id;
  final Value<String> personId;
  final Value<String> note;
  final Value<IdeaKind> kind;
  final Value<String?> link;
  final Value<String?> imagePath;
  final Value<DateTime> createdAt;
  final Value<DateTime?> doneAt;
  final Value<int> rowid;
  const IdeasCompanion({
    this.id = const Value.absent(),
    this.personId = const Value.absent(),
    this.note = const Value.absent(),
    this.kind = const Value.absent(),
    this.link = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IdeasCompanion.insert({
    required String id,
    required String personId,
    required String note,
    required IdeaKind kind,
    this.link = const Value.absent(),
    this.imagePath = const Value.absent(),
    required DateTime createdAt,
    this.doneAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       personId = Value(personId),
       note = Value(note),
       kind = Value(kind),
       createdAt = Value(createdAt);
  static Insertable<Idea> custom({
    Expression<String>? id,
    Expression<String>? personId,
    Expression<String>? note,
    Expression<String>? kind,
    Expression<String>? link,
    Expression<String>? imagePath,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? doneAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personId != null) 'person_id': personId,
      if (note != null) 'note': note,
      if (kind != null) 'kind': kind,
      if (link != null) 'link': link,
      if (imagePath != null) 'image_path': imagePath,
      if (createdAt != null) 'created_at': createdAt,
      if (doneAt != null) 'done_at': doneAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IdeasCompanion copyWith({
    Value<String>? id,
    Value<String>? personId,
    Value<String>? note,
    Value<IdeaKind>? kind,
    Value<String?>? link,
    Value<String?>? imagePath,
    Value<DateTime>? createdAt,
    Value<DateTime?>? doneAt,
    Value<int>? rowid,
  }) {
    return IdeasCompanion(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      note: note ?? this.note,
      kind: kind ?? this.kind,
      link: link ?? this.link,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      doneAt: doneAt ?? this.doneAt,
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
        $IdeasTable.$converterkind.toSql(kind.value),
      );
    }
    if (link.present) {
      map['link'] = Variable<String>(link.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (doneAt.present) {
      map['done_at'] = Variable<DateTime>(doneAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IdeasCompanion(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('note: $note, ')
          ..write('kind: $kind, ')
          ..write('link: $link, ')
          ..write('imagePath: $imagePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('doneAt: $doneAt, ')
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
  late final $GroupsTable groups = $GroupsTable(this);
  late final $GroupMembersTable groupMembers = $GroupMembersTable(this);
  late final $IntentionsTable intentions = $IntentionsTable(this);
  late final $ContactEventsTable contactEvents = $ContactEventsTable(this);
  late final $DayAnswersTable dayAnswers = $DayAnswersTable(this);
  late final $TreatsTable treats = $TreatsTable(this);
  late final $StampsTable stamps = $StampsTable(this);
  late final $IdeasTable ideas = $IdeasTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    settings,
    people,
    groups,
    groupMembers,
    intentions,
    contactEvents,
    dayAnswers,
    treats,
    stamps,
    ideas,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('group_members', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'people',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('group_members', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'people',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('intentions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('intentions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'people',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('contact_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'intentions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('contact_events', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('contact_events', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'people',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('stamps', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'contact_events',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('stamps', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'treats',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('stamps', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'people',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('ideas', kind: UpdateKind.delete)],
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
  Value<DateTime?> replyClearedAt,
  Value<String?> nickname,
  Value<String?> photo,
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
  Value<DateTime?> replyClearedAt,
  Value<String?> nickname,
  Value<String?> photo,
  Value<int> rowid,
});

final class $$PeopleTableReferences
    extends BaseReferences<_$AppDatabase, $PeopleTable, Person> {
  $$PeopleTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GroupMembersTable, List<GroupMember>>
  _groupMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.groupMembers,
    aliasName: 'people__id__group_members__person_id',
  );

  $$GroupMembersTableProcessedTableManager get groupMembersRefs {
    final manager = $$GroupMembersTableTableManager(
      $_db,
      $_db.groupMembers,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_groupMembersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

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

  static MultiTypedResultKey<$ContactEventsTable, List<ContactEvent>>
  _contactEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.contactEvents,
    aliasName: 'people__id__contact_events__person_id',
  );

  $$ContactEventsTableProcessedTableManager get contactEventsRefs {
    final manager = $$ContactEventsTableTableManager(
      $_db,
      $_db.contactEvents,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_contactEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StampsTable, List<Stamp>> _stampsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.stamps,
    aliasName: 'people__id__stamps__person_id',
  );

  $$StampsTableProcessedTableManager get stampsRefs {
    final manager = $$StampsTableTableManager(
      $_db,
      $_db.stamps,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_stampsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$IdeasTable, List<Idea>> _ideasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.ideas,
    aliasName: 'people__id__ideas__person_id',
  );

  $$IdeasTableProcessedTableManager get ideasRefs {
    final manager = $$IdeasTableTableManager(
      $_db,
      $_db.ideas,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ideasRefsTable($_db));
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

  ColumnFilters<DateTime> get replyClearedAt => $composableBuilder(
    column: $table.replyClearedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photo => $composableBuilder(
    column: $table.photo,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> groupMembersRefs(
    Expression<bool> Function($$GroupMembersTableFilterComposer f) f,
  ) {
    final $$GroupMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupMembers,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersTableFilterComposer(
            $db: $db,
            $table: $db.groupMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

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

  Expression<bool> contactEventsRefs(
    Expression<bool> Function($$ContactEventsTableFilterComposer f) f,
  ) {
    final $$ContactEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contactEvents,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactEventsTableFilterComposer(
            $db: $db,
            $table: $db.contactEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> stampsRefs(
    Expression<bool> Function($$StampsTableFilterComposer f) f,
  ) {
    final $$StampsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stamps,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StampsTableFilterComposer(
            $db: $db,
            $table: $db.stamps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ideasRefs(
    Expression<bool> Function($$IdeasTableFilterComposer f) f,
  ) {
    final $$IdeasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ideas,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IdeasTableFilterComposer(
            $db: $db,
            $table: $db.ideas,
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

  ColumnOrderings<DateTime> get replyClearedAt => $composableBuilder(
    column: $table.replyClearedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photo => $composableBuilder(
    column: $table.photo,
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

  GeneratedColumn<DateTime> get replyClearedAt => $composableBuilder(
    column: $table.replyClearedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get photo =>
      $composableBuilder(column: $table.photo, builder: (column) => column);

  Expression<T> groupMembersRefs<T extends Object>(
    Expression<T> Function($$GroupMembersTableAnnotationComposer a) f,
  ) {
    final $$GroupMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupMembers,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.groupMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

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

  Expression<T> contactEventsRefs<T extends Object>(
    Expression<T> Function($$ContactEventsTableAnnotationComposer a) f,
  ) {
    final $$ContactEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contactEvents,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.contactEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> stampsRefs<T extends Object>(
    Expression<T> Function($$StampsTableAnnotationComposer a) f,
  ) {
    final $$StampsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stamps,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StampsTableAnnotationComposer(
            $db: $db,
            $table: $db.stamps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ideasRefs<T extends Object>(
    Expression<T> Function($$IdeasTableAnnotationComposer a) f,
  ) {
    final $$IdeasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ideas,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IdeasTableAnnotationComposer(
            $db: $db,
            $table: $db.ideas,
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
          PrefetchHooks Function({
            bool groupMembersRefs,
            bool intentionsRefs,
            bool contactEventsRefs,
            bool stampsRefs,
            bool ideasRefs,
          })
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
                Value<DateTime?> replyClearedAt = const Value.absent(),
                Value<String?> nickname = const Value.absent(),
                Value<String?> photo = const Value.absent(),
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
                replyClearedAt: replyClearedAt,
                nickname: nickname,
                photo: photo,
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
                Value<DateTime?> replyClearedAt = const Value.absent(),
                Value<String?> nickname = const Value.absent(),
                Value<String?> photo = const Value.absent(),
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
                replyClearedAt: replyClearedAt,
                nickname: nickname,
                photo: photo,
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
          prefetchHooksCallback:
              ({
                groupMembersRefs = false,
                intentionsRefs = false,
                contactEventsRefs = false,
                stampsRefs = false,
                ideasRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (groupMembersRefs) db.groupMembers,
                    if (intentionsRefs) db.intentions,
                    if (contactEventsRefs) db.contactEvents,
                    if (stampsRefs) db.stamps,
                    if (ideasRefs) db.ideas,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (groupMembersRefs)
                        await $_getPrefetchedDataByColumns<
                          Person,
                          $PeopleTable,
                          GroupMember,
                          $GroupMembersTable
                        >(
                          currentTable: table,
                          referencedTable: $$PeopleTableReferences
                              ._groupMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PeopleTableReferences(
                                db,
                                table,
                                p0,
                              ).groupMembersRefs,
                          currentColumn: 'id',
                          referencedColumn: 'person_id',
                          typedResults: items,
                        ),
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
                              $$PeopleTableReferences(
                                db,
                                table,
                                p0,
                              ).intentionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'person_id',
                          typedResults: items,
                        ),
                      if (contactEventsRefs)
                        await $_getPrefetchedDataByColumns<
                          Person,
                          $PeopleTable,
                          ContactEvent,
                          $ContactEventsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PeopleTableReferences
                              ._contactEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PeopleTableReferences(
                                db,
                                table,
                                p0,
                              ).contactEventsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'person_id',
                          typedResults: items,
                        ),
                      if (stampsRefs)
                        await $_getPrefetchedDataByColumns<
                          Person,
                          $PeopleTable,
                          Stamp,
                          $StampsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PeopleTableReferences
                              ._stampsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PeopleTableReferences(db, table, p0).stampsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'person_id',
                          typedResults: items,
                        ),
                      if (ideasRefs)
                        await $_getPrefetchedDataByColumns<
                          Person,
                          $PeopleTable,
                          Idea,
                          $IdeasTable
                        >(
                          currentTable: table,
                          referencedTable: $$PeopleTableReferences
                              ._ideasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PeopleTableReferences(db, table, p0).ideasRefs,
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
      PrefetchHooks Function({
        bool groupMembersRefs,
        bool intentionsRefs,
        bool contactEventsRefs,
        bool stampsRefs,
        bool ideasRefs,
      })
    >;
typedef $$GroupsTableCreateCompanionBuilder = GroupsCompanion Function({
  required String id,
  required GroupKind kind,
  Value<String?> name,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$GroupsTableUpdateCompanionBuilder = GroupsCompanion Function({
  Value<String> id,
  Value<GroupKind> kind,
  Value<String?> name,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$GroupsTableReferences
    extends BaseReferences<_$AppDatabase, $GroupsTable, PersonGroup> {
  $$GroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GroupMembersTable, List<GroupMember>>
  _groupMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.groupMembers,
    aliasName: 'groups__id__group_members__group_id',
  );

  $$GroupMembersTableProcessedTableManager get groupMembersRefs {
    final manager = $$GroupMembersTableTableManager(
      $_db,
      $_db.groupMembers,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_groupMembersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$IntentionsTable, List<Intention>>
  _intentionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.intentions,
    aliasName: 'groups__id__intentions__group_id',
  );

  $$IntentionsTableProcessedTableManager get intentionsRefs {
    final manager = $$IntentionsTableTableManager(
      $_db,
      $_db.intentions,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_intentionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ContactEventsTable, List<ContactEvent>>
  _contactEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.contactEvents,
    aliasName: 'groups__id__contact_events__group_id',
  );

  $$ContactEventsTableProcessedTableManager get contactEventsRefs {
    final manager = $$ContactEventsTableTableManager(
      $_db,
      $_db.contactEvents,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_contactEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GroupsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<GroupKind, GroupKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> groupMembersRefs(
    Expression<bool> Function($$GroupMembersTableFilterComposer f) f,
  ) {
    final $$GroupMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupMembers,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersTableFilterComposer(
            $db: $db,
            $table: $db.groupMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> intentionsRefs(
    Expression<bool> Function($$IntentionsTableFilterComposer f) f,
  ) {
    final $$IntentionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.intentions,
      getReferencedColumn: (t) => t.groupId,
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

  Expression<bool> contactEventsRefs(
    Expression<bool> Function($$ContactEventsTableFilterComposer f) f,
  ) {
    final $$ContactEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contactEvents,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactEventsTableFilterComposer(
            $db: $db,
            $table: $db.contactEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<GroupKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> groupMembersRefs<T extends Object>(
    Expression<T> Function($$GroupMembersTableAnnotationComposer a) f,
  ) {
    final $$GroupMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupMembers,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.groupMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> intentionsRefs<T extends Object>(
    Expression<T> Function($$IntentionsTableAnnotationComposer a) f,
  ) {
    final $$IntentionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.intentions,
      getReferencedColumn: (t) => t.groupId,
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

  Expression<T> contactEventsRefs<T extends Object>(
    Expression<T> Function($$ContactEventsTableAnnotationComposer a) f,
  ) {
    final $$ContactEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contactEvents,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.contactEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupsTable,
          PersonGroup,
          $$GroupsTableFilterComposer,
          $$GroupsTableOrderingComposer,
          $$GroupsTableAnnotationComposer,
          $$GroupsTableCreateCompanionBuilder,
          $$GroupsTableUpdateCompanionBuilder,
          (PersonGroup, $$GroupsTableReferences),
          PersonGroup,
          PrefetchHooks Function({
            bool groupMembersRefs,
            bool intentionsRefs,
            bool contactEventsRefs,
          })
        > {
  $$GroupsTableTableManager(_$AppDatabase db, $GroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<GroupKind> kind = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupsCompanion(
                id: id,
                kind: kind,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required GroupKind kind,
                Value<String?> name = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => GroupsCompanion.insert(
                id: id,
                kind: kind,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GroupsTable, PersonGroup>(table),
                  $$GroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                groupMembersRefs = false,
                intentionsRefs = false,
                contactEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (groupMembersRefs) db.groupMembers,
                    if (intentionsRefs) db.intentions,
                    if (contactEventsRefs) db.contactEvents,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (groupMembersRefs)
                        await $_getPrefetchedDataByColumns<
                          PersonGroup,
                          $GroupsTable,
                          GroupMember,
                          $GroupMembersTable
                        >(
                          currentTable: table,
                          referencedTable: $$GroupsTableReferences
                              ._groupMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).groupMembersRefs,
                          currentColumn: 'id',
                          referencedColumn: 'group_id',
                          typedResults: items,
                        ),
                      if (intentionsRefs)
                        await $_getPrefetchedDataByColumns<
                          PersonGroup,
                          $GroupsTable,
                          Intention,
                          $IntentionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$GroupsTableReferences
                              ._intentionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).intentionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'group_id',
                          typedResults: items,
                        ),
                      if (contactEventsRefs)
                        await $_getPrefetchedDataByColumns<
                          PersonGroup,
                          $GroupsTable,
                          ContactEvent,
                          $ContactEventsTable
                        >(
                          currentTable: table,
                          referencedTable: $$GroupsTableReferences
                              ._contactEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).contactEventsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'group_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupsTable,
      PersonGroup,
      $$GroupsTableFilterComposer,
      $$GroupsTableOrderingComposer,
      $$GroupsTableAnnotationComposer,
      $$GroupsTableCreateCompanionBuilder,
      $$GroupsTableUpdateCompanionBuilder,
      (PersonGroup, $$GroupsTableReferences),
      PersonGroup,
      PrefetchHooks Function({
        bool groupMembersRefs,
        bool intentionsRefs,
        bool contactEventsRefs,
      })
    >;
typedef $$GroupMembersTableCreateCompanionBuilder =
    GroupMembersCompanion Function({
      required String groupId,
      required String personId,
      required int position,
      Value<int> rowid,
    });
typedef $$GroupMembersTableUpdateCompanionBuilder =
    GroupMembersCompanion Function({
      Value<String> groupId,
      Value<String> personId,
      Value<int> position,
      Value<int> rowid,
    });

final class $$GroupMembersTableReferences
    extends BaseReferences<_$AppDatabase, $GroupMembersTable, GroupMember> {
  $$GroupMembersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GroupsTable _groupIdTable(_$AppDatabase db) =>
      db.groups.createAlias('group_members__group_id__groups__id');

  $$GroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<String>('group_id')!;

    final manager = $$GroupsTableTableManager(
      $_db,
      $_db.groups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PeopleTable _personIdTable(_$AppDatabase db) =>
      db.people.createAlias('group_members__person_id__people__id');

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

class $$GroupMembersTableFilterComposer
    extends Composer<_$AppDatabase, $GroupMembersTable> {
  $$GroupMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableFilterComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

class $$GroupMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupMembersTable> {
  $$GroupMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableOrderingComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

class $$GroupMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupMembersTable> {
  $$GroupMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

class $$GroupMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupMembersTable,
          GroupMember,
          $$GroupMembersTableFilterComposer,
          $$GroupMembersTableOrderingComposer,
          $$GroupMembersTableAnnotationComposer,
          $$GroupMembersTableCreateCompanionBuilder,
          $$GroupMembersTableUpdateCompanionBuilder,
          (GroupMember, $$GroupMembersTableReferences),
          GroupMember,
          PrefetchHooks Function({bool groupId, bool personId})
        > {
  $$GroupMembersTableTableManager(_$AppDatabase db, $GroupMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> groupId = const Value.absent(),
                Value<String> personId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupMembersCompanion(
                groupId: groupId,
                personId: personId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String groupId,
                required String personId,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => GroupMembersCompanion.insert(
                groupId: groupId,
                personId: personId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GroupMembersTable, GroupMember>(table),
                  $$GroupMembersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({groupId = false, personId = false}) {
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
                    if (groupId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.groupId,
                        referencedTable: $$GroupMembersTableReferences
                            ._groupIdTable(db),
                        referencedColumn: $$GroupMembersTableReferences
                            ._groupIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (personId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.personId,
                        referencedTable: $$GroupMembersTableReferences
                            ._personIdTable(db),
                        referencedColumn: $$GroupMembersTableReferences
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

typedef $$GroupMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupMembersTable,
      GroupMember,
      $$GroupMembersTableFilterComposer,
      $$GroupMembersTableOrderingComposer,
      $$GroupMembersTableAnnotationComposer,
      $$GroupMembersTableCreateCompanionBuilder,
      $$GroupMembersTableUpdateCompanionBuilder,
      (GroupMember, $$GroupMembersTableReferences),
      GroupMember,
      PrefetchHooks Function({bool groupId, bool personId})
    >;
typedef $$IntentionsTableCreateCompanionBuilder = IntentionsCompanion Function({
  required String id,
  Value<String?> personId,
  Value<String?> groupId,
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
  Value<String?> personId,
  Value<String?> groupId,
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

  $$PeopleTableProcessedTableManager? get personId {
    final $_column = $_itemColumn<String>('person_id');
    if ($_column == null) return null;
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

  static $GroupsTable _groupIdTable(_$AppDatabase db) =>
      db.groups.createAlias('intentions__group_id__groups__id');

  $$GroupsTableProcessedTableManager? get groupId {
    final $_column = $_itemColumn<String>('group_id');
    if ($_column == null) return null;
    final manager = $$GroupsTableTableManager(
      $_db,
      $_db.groups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ContactEventsTable, List<ContactEvent>>
  _contactEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.contactEvents,
    aliasName: 'intentions__id__contact_events__intention_id',
  );

  $$ContactEventsTableProcessedTableManager get contactEventsRefs {
    final manager = $$ContactEventsTableTableManager(
      $_db,
      $_db.contactEvents,
    ).filter((f) => f.intentionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_contactEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
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

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableFilterComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> contactEventsRefs(
    Expression<bool> Function($$ContactEventsTableFilterComposer f) f,
  ) {
    final $$ContactEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contactEvents,
      getReferencedColumn: (t) => t.intentionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactEventsTableFilterComposer(
            $db: $db,
            $table: $db.contactEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableOrderingComposer(
            $db: $db,
            $table: $db.groups,
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

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> contactEventsRefs<T extends Object>(
    Expression<T> Function($$ContactEventsTableAnnotationComposer a) f,
  ) {
    final $$ContactEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contactEvents,
      getReferencedColumn: (t) => t.intentionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.contactEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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
          PrefetchHooks Function({
            bool personId,
            bool groupId,
            bool contactEventsRefs,
          })
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
                Value<String?> personId = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
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
                groupId: groupId,
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
                Value<String?> personId = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
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
                groupId: groupId,
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
          prefetchHooksCallback:
              ({personId = false, groupId = false, contactEventsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (contactEventsRefs) db.contactEvents,
                  ],
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
                        if (groupId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.groupId,
                            referencedTable: $$IntentionsTableReferences
                                ._groupIdTable(db),
                            referencedColumn: $$IntentionsTableReferences
                                ._groupIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (contactEventsRefs)
                        await $_getPrefetchedDataByColumns<
                          Intention,
                          $IntentionsTable,
                          ContactEvent,
                          $ContactEventsTable
                        >(
                          currentTable: table,
                          referencedTable: $$IntentionsTableReferences
                              ._contactEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$IntentionsTableReferences(
                                db,
                                table,
                                p0,
                              ).contactEventsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'intention_id',
                          typedResults: items,
                        ),
                    ];
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
      PrefetchHooks Function({
        bool personId,
        bool groupId,
        bool contactEventsRefs,
      })
    >;
typedef $$ContactEventsTableCreateCompanionBuilder =
    ContactEventsCompanion Function({
      required String id,
      required String personId,
      required DateTime at,
      required ContactKind kind,
      required ContactDirection direction,
      required ContactSource source,
      Value<String?> activity,
      Value<String?> note,
      Value<String?> intentionId,
      required DateTime createdAt,
      Value<String?> activityIcon,
      Value<String?> groupId,
      Value<String?> sharedId,
      Value<int> rowid,
    });
typedef $$ContactEventsTableUpdateCompanionBuilder =
    ContactEventsCompanion Function({
      Value<String> id,
      Value<String> personId,
      Value<DateTime> at,
      Value<ContactKind> kind,
      Value<ContactDirection> direction,
      Value<ContactSource> source,
      Value<String?> activity,
      Value<String?> note,
      Value<String?> intentionId,
      Value<DateTime> createdAt,
      Value<String?> activityIcon,
      Value<String?> groupId,
      Value<String?> sharedId,
      Value<int> rowid,
    });

final class $$ContactEventsTableReferences
    extends BaseReferences<_$AppDatabase, $ContactEventsTable, ContactEvent> {
  $$ContactEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PeopleTable _personIdTable(_$AppDatabase db) =>
      db.people.createAlias('contact_events__person_id__people__id');

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

  static $IntentionsTable _intentionIdTable(_$AppDatabase db) =>
      db.intentions.createAlias('contact_events__intention_id__intentions__id');

  $$IntentionsTableProcessedTableManager? get intentionId {
    final $_column = $_itemColumn<String>('intention_id');
    if ($_column == null) return null;
    final manager = $$IntentionsTableTableManager(
      $_db,
      $_db.intentions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_intentionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GroupsTable _groupIdTable(_$AppDatabase db) =>
      db.groups.createAlias('contact_events__group_id__groups__id');

  $$GroupsTableProcessedTableManager? get groupId {
    final $_column = $_itemColumn<String>('group_id');
    if ($_column == null) return null;
    final manager = $$GroupsTableTableManager(
      $_db,
      $_db.groups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$StampsTable, List<Stamp>> _stampsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.stamps,
    aliasName: 'contact_events__id__stamps__contact_event_id',
  );

  $$StampsTableProcessedTableManager get stampsRefs {
    final manager = $$StampsTableTableManager(
      $_db,
      $_db.stamps,
    ).filter((f) => f.contactEventId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_stampsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ContactEventsTableFilterComposer
    extends Composer<_$AppDatabase, $ContactEventsTable> {
  $$ContactEventsTableFilterComposer({
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

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ContactKind, ContactKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<ContactDirection, ContactDirection, String>
  get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<ContactSource, ContactSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityIcon => $composableBuilder(
    column: $table.activityIcon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sharedId => $composableBuilder(
    column: $table.sharedId,
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

  $$IntentionsTableFilterComposer get intentionId {
    final $$IntentionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.intentionId,
      referencedTable: $db.intentions,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableFilterComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> stampsRefs(
    Expression<bool> Function($$StampsTableFilterComposer f) f,
  ) {
    final $$StampsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stamps,
      getReferencedColumn: (t) => t.contactEventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StampsTableFilterComposer(
            $db: $db,
            $table: $db.stamps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ContactEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactEventsTable> {
  $$ContactEventsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityIcon => $composableBuilder(
    column: $table.activityIcon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sharedId => $composableBuilder(
    column: $table.sharedId,
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

  $$IntentionsTableOrderingComposer get intentionId {
    final $$IntentionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.intentionId,
      referencedTable: $db.intentions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntentionsTableOrderingComposer(
            $db: $db,
            $table: $db.intentions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableOrderingComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContactEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactEventsTable> {
  $$ContactEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ContactKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ContactDirection, String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ContactSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get activity =>
      $composableBuilder(column: $table.activity, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get activityIcon => $composableBuilder(
    column: $table.activityIcon,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sharedId =>
      $composableBuilder(column: $table.sharedId, builder: (column) => column);

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

  $$IntentionsTableAnnotationComposer get intentionId {
    final $$IntentionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.intentionId,
      referencedTable: $db.intentions,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> stampsRefs<T extends Object>(
    Expression<T> Function($$StampsTableAnnotationComposer a) f,
  ) {
    final $$StampsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stamps,
      getReferencedColumn: (t) => t.contactEventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StampsTableAnnotationComposer(
            $db: $db,
            $table: $db.stamps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ContactEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContactEventsTable,
          ContactEvent,
          $$ContactEventsTableFilterComposer,
          $$ContactEventsTableOrderingComposer,
          $$ContactEventsTableAnnotationComposer,
          $$ContactEventsTableCreateCompanionBuilder,
          $$ContactEventsTableUpdateCompanionBuilder,
          (ContactEvent, $$ContactEventsTableReferences),
          ContactEvent,
          PrefetchHooks Function({
            bool personId,
            bool intentionId,
            bool groupId,
            bool stampsRefs,
          })
        > {
  $$ContactEventsTableTableManager(_$AppDatabase db, $ContactEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> personId = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<ContactKind> kind = const Value.absent(),
                Value<ContactDirection> direction = const Value.absent(),
                Value<ContactSource> source = const Value.absent(),
                Value<String?> activity = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> intentionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> activityIcon = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<String?> sharedId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContactEventsCompanion(
                id: id,
                personId: personId,
                at: at,
                kind: kind,
                direction: direction,
                source: source,
                activity: activity,
                note: note,
                intentionId: intentionId,
                createdAt: createdAt,
                activityIcon: activityIcon,
                groupId: groupId,
                sharedId: sharedId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String personId,
                required DateTime at,
                required ContactKind kind,
                required ContactDirection direction,
                required ContactSource source,
                Value<String?> activity = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> intentionId = const Value.absent(),
                required DateTime createdAt,
                Value<String?> activityIcon = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<String?> sharedId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContactEventsCompanion.insert(
                id: id,
                personId: personId,
                at: at,
                kind: kind,
                direction: direction,
                source: source,
                activity: activity,
                note: note,
                intentionId: intentionId,
                createdAt: createdAt,
                activityIcon: activityIcon,
                groupId: groupId,
                sharedId: sharedId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ContactEventsTable, ContactEvent>(table),
                  $$ContactEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                personId = false,
                intentionId = false,
                groupId = false,
                stampsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (stampsRefs) db.stamps],
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
                            referencedTable: $$ContactEventsTableReferences
                                ._personIdTable(db),
                            referencedColumn: $$ContactEventsTableReferences
                                ._personIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (intentionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.intentionId,
                            referencedTable: $$ContactEventsTableReferences
                                ._intentionIdTable(db),
                            referencedColumn: $$ContactEventsTableReferences
                                ._intentionIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (groupId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.groupId,
                            referencedTable: $$ContactEventsTableReferences
                                ._groupIdTable(db),
                            referencedColumn: $$ContactEventsTableReferences
                                ._groupIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (stampsRefs)
                        await $_getPrefetchedDataByColumns<
                          ContactEvent,
                          $ContactEventsTable,
                          Stamp,
                          $StampsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ContactEventsTableReferences
                              ._stampsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ContactEventsTableReferences(
                                db,
                                table,
                                p0,
                              ).stampsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'contact_event_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ContactEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContactEventsTable,
      ContactEvent,
      $$ContactEventsTableFilterComposer,
      $$ContactEventsTableOrderingComposer,
      $$ContactEventsTableAnnotationComposer,
      $$ContactEventsTableCreateCompanionBuilder,
      $$ContactEventsTableUpdateCompanionBuilder,
      (ContactEvent, $$ContactEventsTableReferences),
      ContactEvent,
      PrefetchHooks Function({
        bool personId,
        bool intentionId,
        bool groupId,
        bool stampsRefs,
      })
    >;
typedef $$DayAnswersTableCreateCompanionBuilder = DayAnswersCompanion Function({
  required String day,
  required DayAnswerValue answer,
  Value<DateTime?> answeredAt,
  Value<int> rowid,
});
typedef $$DayAnswersTableUpdateCompanionBuilder = DayAnswersCompanion Function({
  Value<String> day,
  Value<DayAnswerValue> answer,
  Value<DateTime?> answeredAt,
  Value<int> rowid,
});

class $$DayAnswersTableFilterComposer
    extends Composer<_$AppDatabase, $DayAnswersTable> {
  $$DayAnswersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DayAnswerValue, DayAnswerValue, String>
  get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DayAnswersTableOrderingComposer
    extends Composer<_$AppDatabase, $DayAnswersTable> {
  $$DayAnswersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayAnswersTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayAnswersTable> {
  $$DayAnswersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DayAnswerValue, String> get answer =>
      $composableBuilder(column: $table.answer, builder: (column) => column);

  GeneratedColumn<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => column,
  );
}

class $$DayAnswersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayAnswersTable,
          DayAnswer,
          $$DayAnswersTableFilterComposer,
          $$DayAnswersTableOrderingComposer,
          $$DayAnswersTableAnnotationComposer,
          $$DayAnswersTableCreateCompanionBuilder,
          $$DayAnswersTableUpdateCompanionBuilder,
          (
            DayAnswer,
            BaseReferences<_$AppDatabase, $DayAnswersTable, DayAnswer>,
          ),
          DayAnswer,
          PrefetchHooks Function()
        > {
  $$DayAnswersTableTableManager(_$AppDatabase db, $DayAnswersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayAnswersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayAnswersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayAnswersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> day = const Value.absent(),
                Value<DayAnswerValue> answer = const Value.absent(),
                Value<DateTime?> answeredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayAnswersCompanion(
                day: day,
                answer: answer,
                answeredAt: answeredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String day,
                required DayAnswerValue answer,
                Value<DateTime?> answeredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayAnswersCompanion.insert(
                day: day,
                answer: answer,
                answeredAt: answeredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DayAnswersTable, DayAnswer>(table),
                  BaseReferences<_$AppDatabase, $DayAnswersTable, DayAnswer>(
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

typedef $$DayAnswersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayAnswersTable,
      DayAnswer,
      $$DayAnswersTableFilterComposer,
      $$DayAnswersTableOrderingComposer,
      $$DayAnswersTableAnnotationComposer,
      $$DayAnswersTableCreateCompanionBuilder,
      $$DayAnswersTableUpdateCompanionBuilder,
      (DayAnswer, BaseReferences<_$AppDatabase, $DayAnswersTable, DayAnswer>),
      DayAnswer,
      PrefetchHooks Function()
    >;
typedef $$TreatsTableCreateCompanionBuilder = TreatsCompanion Function({
  required String id,
  required String name,
  required int stampsNeeded,
  required TreatState state,
  required int position,
  required DateTime createdAt,
  Value<DateTime?> earnedAt,
  Value<DateTime?> enjoyedAt,
  Value<int> rowid,
});
typedef $$TreatsTableUpdateCompanionBuilder = TreatsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> stampsNeeded,
  Value<TreatState> state,
  Value<int> position,
  Value<DateTime> createdAt,
  Value<DateTime?> earnedAt,
  Value<DateTime?> enjoyedAt,
  Value<int> rowid,
});

final class $$TreatsTableReferences
    extends BaseReferences<_$AppDatabase, $TreatsTable, Treat> {
  $$TreatsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StampsTable, List<Stamp>> _stampsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.stamps,
    aliasName: 'treats__id__stamps__treat_id',
  );

  $$StampsTableProcessedTableManager get stampsRefs {
    final manager = $$StampsTableTableManager(
      $_db,
      $_db.stamps,
    ).filter((f) => f.treatId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_stampsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TreatsTableFilterComposer
    extends Composer<_$AppDatabase, $TreatsTable> {
  $$TreatsTableFilterComposer({
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

  ColumnFilters<int> get stampsNeeded => $composableBuilder(
    column: $table.stampsNeeded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TreatState, TreatState, String> get state =>
      $composableBuilder(
        column: $table.state,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get earnedAt => $composableBuilder(
    column: $table.earnedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get enjoyedAt => $composableBuilder(
    column: $table.enjoyedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> stampsRefs(
    Expression<bool> Function($$StampsTableFilterComposer f) f,
  ) {
    final $$StampsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stamps,
      getReferencedColumn: (t) => t.treatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StampsTableFilterComposer(
            $db: $db,
            $table: $db.stamps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TreatsTableOrderingComposer
    extends Composer<_$AppDatabase, $TreatsTable> {
  $$TreatsTableOrderingComposer({
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

  ColumnOrderings<int> get stampsNeeded => $composableBuilder(
    column: $table.stampsNeeded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get earnedAt => $composableBuilder(
    column: $table.earnedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get enjoyedAt => $composableBuilder(
    column: $table.enjoyedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TreatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TreatsTable> {
  $$TreatsTableAnnotationComposer({
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

  GeneratedColumn<int> get stampsNeeded => $composableBuilder(
    column: $table.stampsNeeded,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TreatState, String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get earnedAt =>
      $composableBuilder(column: $table.earnedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get enjoyedAt =>
      $composableBuilder(column: $table.enjoyedAt, builder: (column) => column);

  Expression<T> stampsRefs<T extends Object>(
    Expression<T> Function($$StampsTableAnnotationComposer a) f,
  ) {
    final $$StampsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stamps,
      getReferencedColumn: (t) => t.treatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StampsTableAnnotationComposer(
            $db: $db,
            $table: $db.stamps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TreatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TreatsTable,
          Treat,
          $$TreatsTableFilterComposer,
          $$TreatsTableOrderingComposer,
          $$TreatsTableAnnotationComposer,
          $$TreatsTableCreateCompanionBuilder,
          $$TreatsTableUpdateCompanionBuilder,
          (Treat, $$TreatsTableReferences),
          Treat,
          PrefetchHooks Function({bool stampsRefs})
        > {
  $$TreatsTableTableManager(_$AppDatabase db, $TreatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TreatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TreatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TreatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> stampsNeeded = const Value.absent(),
                Value<TreatState> state = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> earnedAt = const Value.absent(),
                Value<DateTime?> enjoyedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TreatsCompanion(
                id: id,
                name: name,
                stampsNeeded: stampsNeeded,
                state: state,
                position: position,
                createdAt: createdAt,
                earnedAt: earnedAt,
                enjoyedAt: enjoyedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int stampsNeeded,
                required TreatState state,
                required int position,
                required DateTime createdAt,
                Value<DateTime?> earnedAt = const Value.absent(),
                Value<DateTime?> enjoyedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TreatsCompanion.insert(
                id: id,
                name: name,
                stampsNeeded: stampsNeeded,
                state: state,
                position: position,
                createdAt: createdAt,
                earnedAt: earnedAt,
                enjoyedAt: enjoyedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TreatsTable, Treat>(table),
                  $$TreatsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({stampsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (stampsRefs) db.stamps],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (stampsRefs)
                    await $_getPrefetchedDataByColumns<
                      Treat,
                      $TreatsTable,
                      Stamp,
                      $StampsTable
                    >(
                      currentTable: table,
                      referencedTable: $$TreatsTableReferences._stampsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$TreatsTableReferences(db, table, p0).stampsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'treat_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TreatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TreatsTable,
      Treat,
      $$TreatsTableFilterComposer,
      $$TreatsTableOrderingComposer,
      $$TreatsTableAnnotationComposer,
      $$TreatsTableCreateCompanionBuilder,
      $$TreatsTableUpdateCompanionBuilder,
      (Treat, $$TreatsTableReferences),
      Treat,
      PrefetchHooks Function({bool stampsRefs})
    >;
typedef $$StampsTableCreateCompanionBuilder = StampsCompanion Function({
  required String id,
  required DateTime at,
  required int value,
  Value<String?> personId,
  Value<String?> contactEventId,
  Value<String?> treatId,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$StampsTableUpdateCompanionBuilder = StampsCompanion Function({
  Value<String> id,
  Value<DateTime> at,
  Value<int> value,
  Value<String?> personId,
  Value<String?> contactEventId,
  Value<String?> treatId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$StampsTableReferences
    extends BaseReferences<_$AppDatabase, $StampsTable, Stamp> {
  $$StampsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PeopleTable _personIdTable(_$AppDatabase db) =>
      db.people.createAlias('stamps__person_id__people__id');

  $$PeopleTableProcessedTableManager? get personId {
    final $_column = $_itemColumn<String>('person_id');
    if ($_column == null) return null;
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

  static $ContactEventsTable _contactEventIdTable(_$AppDatabase db) => db
      .contactEvents
      .createAlias('stamps__contact_event_id__contact_events__id');

  $$ContactEventsTableProcessedTableManager? get contactEventId {
    final $_column = $_itemColumn<String>('contact_event_id');
    if ($_column == null) return null;
    final manager = $$ContactEventsTableTableManager(
      $_db,
      $_db.contactEvents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contactEventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TreatsTable _treatIdTable(_$AppDatabase db) =>
      db.treats.createAlias('stamps__treat_id__treats__id');

  $$TreatsTableProcessedTableManager? get treatId {
    final $_column = $_itemColumn<String>('treat_id');
    if ($_column == null) return null;
    final manager = $$TreatsTableTableManager(
      $_db,
      $_db.treats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_treatIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StampsTableFilterComposer
    extends Composer<_$AppDatabase, $StampsTable> {
  $$StampsTableFilterComposer({
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

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  $$ContactEventsTableFilterComposer get contactEventId {
    final $$ContactEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactEventId,
      referencedTable: $db.contactEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactEventsTableFilterComposer(
            $db: $db,
            $table: $db.contactEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TreatsTableFilterComposer get treatId {
    final $$TreatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.treatId,
      referencedTable: $db.treats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreatsTableFilterComposer(
            $db: $db,
            $table: $db.treats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StampsTableOrderingComposer
    extends Composer<_$AppDatabase, $StampsTable> {
  $$StampsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  $$ContactEventsTableOrderingComposer get contactEventId {
    final $$ContactEventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactEventId,
      referencedTable: $db.contactEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactEventsTableOrderingComposer(
            $db: $db,
            $table: $db.contactEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TreatsTableOrderingComposer get treatId {
    final $$TreatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.treatId,
      referencedTable: $db.treats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreatsTableOrderingComposer(
            $db: $db,
            $table: $db.treats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StampsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StampsTable> {
  $$StampsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

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

  $$ContactEventsTableAnnotationComposer get contactEventId {
    final $$ContactEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactEventId,
      referencedTable: $db.contactEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.contactEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TreatsTableAnnotationComposer get treatId {
    final $$TreatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.treatId,
      referencedTable: $db.treats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreatsTableAnnotationComposer(
            $db: $db,
            $table: $db.treats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StampsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StampsTable,
          Stamp,
          $$StampsTableFilterComposer,
          $$StampsTableOrderingComposer,
          $$StampsTableAnnotationComposer,
          $$StampsTableCreateCompanionBuilder,
          $$StampsTableUpdateCompanionBuilder,
          (Stamp, $$StampsTableReferences),
          Stamp,
          PrefetchHooks Function({
            bool personId,
            bool contactEventId,
            bool treatId,
          })
        > {
  $$StampsTableTableManager(_$AppDatabase db, $StampsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StampsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StampsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StampsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<int> value = const Value.absent(),
                Value<String?> personId = const Value.absent(),
                Value<String?> contactEventId = const Value.absent(),
                Value<String?> treatId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StampsCompanion(
                id: id,
                at: at,
                value: value,
                personId: personId,
                contactEventId: contactEventId,
                treatId: treatId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime at,
                required int value,
                Value<String?> personId = const Value.absent(),
                Value<String?> contactEventId = const Value.absent(),
                Value<String?> treatId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => StampsCompanion.insert(
                id: id,
                at: at,
                value: value,
                personId: personId,
                contactEventId: contactEventId,
                treatId: treatId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StampsTable, Stamp>(table),
                  $$StampsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({personId = false, contactEventId = false, treatId = false}) {
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
                            referencedTable: $$StampsTableReferences
                                ._personIdTable(db),
                            referencedColumn: $$StampsTableReferences
                                ._personIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (contactEventId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.contactEventId,
                            referencedTable: $$StampsTableReferences
                                ._contactEventIdTable(db),
                            referencedColumn: $$StampsTableReferences
                                ._contactEventIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (treatId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.treatId,
                            referencedTable: $$StampsTableReferences
                                ._treatIdTable(db),
                            referencedColumn: $$StampsTableReferences
                                ._treatIdTable(db)
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

typedef $$StampsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StampsTable,
      Stamp,
      $$StampsTableFilterComposer,
      $$StampsTableOrderingComposer,
      $$StampsTableAnnotationComposer,
      $$StampsTableCreateCompanionBuilder,
      $$StampsTableUpdateCompanionBuilder,
      (Stamp, $$StampsTableReferences),
      Stamp,
      PrefetchHooks Function({bool personId, bool contactEventId, bool treatId})
    >;
typedef $$IdeasTableCreateCompanionBuilder = IdeasCompanion Function({
  required String id,
  required String personId,
  required String note,
  required IdeaKind kind,
  Value<String?> link,
  Value<String?> imagePath,
  required DateTime createdAt,
  Value<DateTime?> doneAt,
  Value<int> rowid,
});
typedef $$IdeasTableUpdateCompanionBuilder = IdeasCompanion Function({
  Value<String> id,
  Value<String> personId,
  Value<String> note,
  Value<IdeaKind> kind,
  Value<String?> link,
  Value<String?> imagePath,
  Value<DateTime> createdAt,
  Value<DateTime?> doneAt,
  Value<int> rowid,
});

final class $$IdeasTableReferences
    extends BaseReferences<_$AppDatabase, $IdeasTable, Idea> {
  $$IdeasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PeopleTable _personIdTable(_$AppDatabase db) =>
      db.people.createAlias('ideas__person_id__people__id');

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

class $$IdeasTableFilterComposer extends Composer<_$AppDatabase, $IdeasTable> {
  $$IdeasTableFilterComposer({
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

  ColumnWithTypeConverterFilters<IdeaKind, IdeaKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get doneAt => $composableBuilder(
    column: $table.doneAt,
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

class $$IdeasTableOrderingComposer
    extends Composer<_$AppDatabase, $IdeasTable> {
  $$IdeasTableOrderingComposer({
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

  ColumnOrderings<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get doneAt => $composableBuilder(
    column: $table.doneAt,
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

class $$IdeasTableAnnotationComposer
    extends Composer<_$AppDatabase, $IdeasTable> {
  $$IdeasTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<IdeaKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get link =>
      $composableBuilder(column: $table.link, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get doneAt =>
      $composableBuilder(column: $table.doneAt, builder: (column) => column);

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

class $$IdeasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IdeasTable,
          Idea,
          $$IdeasTableFilterComposer,
          $$IdeasTableOrderingComposer,
          $$IdeasTableAnnotationComposer,
          $$IdeasTableCreateCompanionBuilder,
          $$IdeasTableUpdateCompanionBuilder,
          (Idea, $$IdeasTableReferences),
          Idea,
          PrefetchHooks Function({bool personId})
        > {
  $$IdeasTableTableManager(_$AppDatabase db, $IdeasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IdeasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IdeasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IdeasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> personId = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<IdeaKind> kind = const Value.absent(),
                Value<String?> link = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> doneAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IdeasCompanion(
                id: id,
                personId: personId,
                note: note,
                kind: kind,
                link: link,
                imagePath: imagePath,
                createdAt: createdAt,
                doneAt: doneAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String personId,
                required String note,
                required IdeaKind kind,
                Value<String?> link = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> doneAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IdeasCompanion.insert(
                id: id,
                personId: personId,
                note: note,
                kind: kind,
                link: link,
                imagePath: imagePath,
                createdAt: createdAt,
                doneAt: doneAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IdeasTable, Idea>(table),
                  $$IdeasTableReferences(db, table, e),
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
                        referencedTable: $$IdeasTableReferences._personIdTable(
                          db,
                        ),
                        referencedColumn: $$IdeasTableReferences
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

typedef $$IdeasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IdeasTable,
      Idea,
      $$IdeasTableFilterComposer,
      $$IdeasTableOrderingComposer,
      $$IdeasTableAnnotationComposer,
      $$IdeasTableCreateCompanionBuilder,
      $$IdeasTableUpdateCompanionBuilder,
      (Idea, $$IdeasTableReferences),
      Idea,
      PrefetchHooks Function({bool personId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$PeopleTableTableManager get people =>
      $$PeopleTableTableManager(_db, _db.people);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db, _db.groups);
  $$GroupMembersTableTableManager get groupMembers =>
      $$GroupMembersTableTableManager(_db, _db.groupMembers);
  $$IntentionsTableTableManager get intentions =>
      $$IntentionsTableTableManager(_db, _db.intentions);
  $$ContactEventsTableTableManager get contactEvents =>
      $$ContactEventsTableTableManager(_db, _db.contactEvents);
  $$DayAnswersTableTableManager get dayAnswers =>
      $$DayAnswersTableTableManager(_db, _db.dayAnswers);
  $$TreatsTableTableManager get treats =>
      $$TreatsTableTableManager(_db, _db.treats);
  $$StampsTableTableManager get stamps =>
      $$StampsTableTableManager(_db, _db.stamps);
  $$IdeasTableTableManager get ideas =>
      $$IdeasTableTableManager(_db, _db.ideas);
}
