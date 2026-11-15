import 'package:drift/drift.dart';

import '../domain/person.dart';

part 'database.g.dart';

/// Key-value settings, read through SettingsRepository. Used only in the
/// real database; the demo database has the table but leaves it empty.
@DataClassName('SettingEntry')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// A friend or family member. See docs/02-design.md §3 and §8.
@DataClassName('Person')
class People extends Table {
  /// UUID v4, made by PeopleRepository, so backups can be merged later.
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// The phone contact the person was imported from. Name, number and
  /// birthday are copied once; the link stays for a later refresh.
  TextColumn get contactId => text().nullable()();
  TextColumn get closeness => textEnum<Closeness>()();

  /// "Getting back in touch", on top of the class.
  BoolColumn get reconnecting => boolean().withDefault(const Constant(false))();

  /// The person's own rhythm in days. null = the class default.
  IntColumn get rhythmDays => integer().nullable()();

  /// What "Open chat" uses. null = no messenger chosen.
  TextColumn get mainMessenger => textEnum<Messenger>().nullable()();

  /// International form. Serves WhatsApp, Signal and Telegram by number.
  TextColumn get phone => text().nullable()();

  /// One handle per messenger besides the phone number.
  TextColumn get telegramUsername => text().nullable()();
  TextColumn get signalLink => text().nullable()();
  TextColumn get discordUserId => text().nullable()();

  /// The birthday. The year is often unknown.
  IntColumn get birthdayMonth => integer().nullable()();
  IntColumn get birthdayDay => integer().nullable()();
  IntColumn get birthdayYear => integer().nullable()();

  /// Picked when the person is added (domain/avatar_pick.dart).
  TextColumn get avatarShape => textEnum<AvatarShape>()();
  TextColumn get avatarColor => textEnum<AvatarColor>()();

  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One schema for both files: the real database (settings and the user's
/// people) and the demo database (invented people only).
@DriftDatabase(tables: [Settings, People])
class AppDatabase extends _$AppDatabase {
  /// [executor]: a file database (`database_connection.dart`) or an
  /// in-memory one in tests. Opening the file lives elsewhere so drift's
  /// schema export can run this file without Flutter.
  AppDatabase(super.executor);

  /// Raise this and add a migration step for every schema change. Only add
  /// tables or nullable columns; never rename or reuse a column. The
  /// snapshot of version 1 is in `drift_schemas/`; with version 2, run
  /// `dart run drift_dev make-migrations` and use `stepByStep` as
  /// akai-timetrack does.
  @override
  int get schemaVersion => 1;
}
