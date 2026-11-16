import 'package:drift/drift.dart';

import '../domain/contact_event.dart';
import '../domain/idea.dart';
import '../domain/intention.dart';
import '../domain/person.dart';
import '../domain/treat.dart';
import 'database.steps.dart';

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

  /// When the user last said an owed reply to this person is settled
  /// (milestone M7). Added in schema version 4.
  DateTimeColumn get replyClearedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Something the user wants to do with a person: a thought caught at
/// capture (02-design.md §2.1, §3). Added in schema version 2.
@DataClassName('Intention')
class Intentions extends Table {
  /// UUID v4, made by IntentionsRepository.
  TextColumn get id => text()();

  /// Deleting the person deletes their intentions. Needs
  /// `PRAGMA foreign_keys = ON` (AppDatabase.migration, beforeOpen).
  TextColumn get personId =>
      text().references(People, #id, onDelete: KeyAction.cascade)();

  /// What came to mind ("saw a bouldering video"). May be empty.
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get kind => textEnum<IntentionKind>().withDefault(
    Constant(IntentionKind.write.name),
  )();
  TextColumn get state => textEnum<IntentionState>().withDefault(
    Constant(IntentionState.open.name),
  )();

  /// An attached link (a later milestone).
  TextColumn get link => text().nullable()();

  /// When: a date, or a horizon (with [condition] for "when ..."), or
  /// nothing. Used from milestone M5; here now to spare a migration.
  DateTimeColumn get date => dateTime().nullable()();
  TextColumn get horizon => textEnum<Horizon>().nullable()();
  TextColumn get condition => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  /// Set when the intention leaves `open`; cleared when it is reopened.
  DateTimeColumn get closedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A contact that happened with a person: written, called, met, gamed or
/// a birthday wish (02-design.md §3). Added in schema version 3.
@DataClassName('ContactEvent')
class ContactEvents extends Table {
  /// UUID v4, made by ContactEventsRepository.
  TextColumn get id => text()();

  /// Deleting the person deletes their events (foreign keys are on, see
  /// AppDatabase.migration).
  TextColumn get personId =>
      text().references(People, #id, onDelete: KeyAction.cascade)();

  /// When the contact happened.
  DateTimeColumn get at => dateTime()();
  TextColumn get kind => textEnum<ContactKind>()();
  TextColumn get direction => textEnum<ContactDirection>()();
  TextColumn get source => textEnum<ContactSource>()();

  /// What they did together ("bouldering", a game's name, a restaurant).
  TextColumn get activity => text().nullable()();

  /// The one line for next time ("new job in March").
  TextColumn get note => text().nullable()();

  /// The intention this contact closed. Deleting the intention keeps the
  /// event and clears the link.
  TextColumn get intentionId => text().nullable().references(
    Intentions,
    #id,
    onDelete: KeyAction.setNull,
  )();

  DateTimeColumn get createdAt => dateTime()();

  /// The name of an icon for the activity (a later feature). Added in
  /// schema version 4.
  TextColumn get activityIcon => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The user's answer for one local day. Added in schema version 3.
@DataClassName('DayAnswer')
class DayAnswers extends Table {
  /// The local day as `YYYY-MM-DD`.
  TextColumn get day => text()();
  TextColumn get answer => textEnum<DayAnswerValue>()();
  DateTimeColumn get answeredAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {day};
}

/// A treat the user collects stamps for. Added in schema version 4.
@DataClassName('Treat')
class Treats extends Table {
  /// UUID v4, made by a repository.
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// How many stamps fill the card.
  IntColumn get stampsNeeded => integer()();
  TextColumn get state => textEnum<TreatState>()();

  /// The order among the waiting treats.
  IntColumn get position => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get earnedAt => dateTime().nullable()();
  DateTimeColumn get enjoyedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A stamp the user earned. The user's count only grows, so a stamp
/// survives the deletion of its person, event or treat: the link is
/// cleared. Added in schema version 4.
@DataClassName('Stamp')
class Stamps extends Table {
  /// UUID v4, made by a repository.
  TextColumn get id => text()();

  /// When it was earned.
  DateTimeColumn get at => dateTime()();
  IntColumn get value => integer()();
  TextColumn get personId =>
      text().nullable().references(People, #id, onDelete: KeyAction.setNull)();
  TextColumn get contactEventId => text().nullable().references(
    ContactEvents,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// The card it went onto.
  TextColumn get treatId =>
      text().nullable().references(Treats, #id, onDelete: KeyAction.setNull)();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// An idea for a person: something to do or to talk about. Added in
/// schema version 4.
@DataClassName('Idea')
class Ideas extends Table {
  /// UUID v4, made by a repository.
  TextColumn get id => text()();

  /// Deleting the person deletes their ideas.
  TextColumn get personId =>
      text().references(People, #id, onDelete: KeyAction.cascade)();
  TextColumn get note => text()();
  TextColumn get kind => textEnum<IdeaKind>()();
  TextColumn get link => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get doneAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One schema for both files: the real database (settings and the user's
/// people) and the demo database (invented people only).
@DriftDatabase(
  tables: [
    Settings,
    People,
    Intentions,
    ContactEvents,
    DayAnswers,
    Treats,
    Stamps,
    Ideas,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// [executor]: a file database (`database_connection.dart`) or an
  /// in-memory one in tests. Opening the file lives elsewhere so drift's
  /// schema export can run this file without Flutter.
  AppDatabase(super.executor);

  /// Raise this and add a migration step for every schema change. Only add
  /// tables or nullable columns; never rename or reuse a column. Then run
  /// `dart run drift_dev make-migrations`: it saves a snapshot in
  /// `drift_schemas/`, updates `database.steps.dart` and the schema test
  /// helpers in `test/drift/` (as in akai-timetrack).
  @override
  int get schemaVersion => 4;

  /// Steps come from the snapshots in `drift_schemas/`; each one only adds.
  /// The real database on the developer's phone holds people from version
  /// 1, so a step must never drop or rebuild a table with data.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        // Intentions (M2, capture).
        await m.createTable(schema.intentions);
      },
      from2To3: (m, schema) async {
        // Contact events and day answers (M3).
        await m.createTable(schema.contactEvents);
        await m.createTable(schema.dayAnswers);
      },
      from3To4: (m, schema) async {
        // One step for M7 to M10: two nullable columns, three new tables.
        await m.addColumn(schema.people, schema.people.replyClearedAt);
        await m.addColumn(
          schema.contactEvents,
          schema.contactEvents.activityIcon,
        );
        await m.createTable(schema.treats);
        await m.createTable(schema.stamps);
        await m.createTable(schema.ideas);
      },
    ),
    beforeOpen: (details) async {
      // SQLite leaves foreign keys off per connection; the cascade from
      // people to intentions needs them.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
