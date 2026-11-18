import 'package:drift/drift.dart';

import '../domain/contact_event.dart';
import '../domain/group.dart';
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

  /// What "Open chat" uses. null = no messenger chosen. The column keeps
  /// its old name `main_messenger`: schema 5 stored the four old
  /// messengers under the same names (02-design.md §8, 2026-11-18).
  TextColumn get chatApp =>
      textEnum<ChatApp>().named('main_messenger').nullable()();

  /// International form. Serves WhatsApp, Signal, Telegram, Viber and SMS
  /// by number.
  TextColumn get phone => text().nullable()();

  /// The chat link, username or ID for [chatApp] (domain/chat_app.dart).
  /// Schema 6; replaces the three handles of schema 1 to 5.
  TextColumn get chatTarget => text().nullable()();

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
  /// Added in schema version 4.
  DateTimeColumn get replyClearedAt => dateTime().nullable()();

  /// What the user calls the person, if not by their name. Added in schema
  /// version 5.
  TextColumn get nickname => text().nullable()();

  /// The person's picture: a file name inside the app's avatar folder
  /// (platform/photo_store.dart). null = the drawn avatar. Added in schema
  /// version 5.
  TextColumn get photo => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A group of people; for now only couples (GroupKind). Added in schema
/// version 5.
@DataClassName('PersonGroup')
class Groups extends Table {
  /// UUID v4, made by GroupsRepository.
  TextColumn get id => text()();
  TextColumn get kind => textEnum<GroupKind>()();

  /// The group's own name. null = show the members' names.
  TextColumn get name => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Who is in which group. Deleting a person removes their membership;
/// GroupsRepository then dissolves a couple left with one member. Added in
/// schema version 5.
@DataClassName('GroupMember')
class GroupMembers extends Table {
  TextColumn get groupId =>
      text().references(Groups, #id, onDelete: KeyAction.cascade)();
  TextColumn get personId =>
      text().references(People, #id, onDelete: KeyAction.cascade)();

  /// The order of the members, from 0.
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {groupId, personId};
}

/// Something the user wants to do with a person: a thought caught at
/// capture (02-design.md §2.1, §3). Added in schema version 2.
@DataClassName('Intention')
class Intentions extends Table {
  /// UUID v4, made by IntentionsRepository.
  TextColumn get id => text()();

  /// The person the intention is for, or null when it is for a group
  /// ([groupId]); exactly one of the two is set (the CHECK below, and
  /// IntentionsRepository). Deleting the person deletes their intentions.
  /// Needs `PRAGMA foreign_keys = ON` (AppDatabase.migration, beforeOpen).
  /// Nullable since schema version 5.
  TextColumn get personId =>
      text().nullable().references(People, #id, onDelete: KeyAction.cascade)();

  /// The group (a couple) the intention is for. GroupsRepository moves the
  /// intentions to a member before it deletes a group; the cascade is only
  /// a safety net. Added in schema version 5.
  TextColumn get groupId =>
      text().nullable().references(Groups, #id, onDelete: KeyAction.cascade)();

  /// What came to mind ("saw a bouldering video"). May be empty.
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get kind => textEnum<IntentionKind>().withDefault(
    Constant(IntentionKind.write.name),
  )();
  TextColumn get state => textEnum<IntentionState>().withDefault(
    Constant(IntentionState.open.name),
  )();

  /// An attached link.
  TextColumn get link => text().nullable()();

  /// When: a date, or a horizon (with [condition] for "when ..."), or
  /// nothing.
  DateTimeColumn get date => dateTime().nullable()();
  TextColumn get horizon => textEnum<Horizon>().nullable()();
  TextColumn get condition => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  /// Set when the intention leaves `open`; cleared when it is reopened.
  DateTimeColumn get closedAt => dateTime().nullable()();

  /// The name of a KeptIcons icon for what is planned (a meetup or a game);
  /// carried over to the contact when the plan is done. Added in schema
  /// version 7.
  TextColumn get activityIcon => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  /// A person or a group, never both, never neither (schema version 5).
  @override
  List<String> get customConstraints => [
    'CHECK ((person_id IS NULL) <> (group_id IS NULL))',
  ];
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

  /// The couple that was met, when the contact was with a group. Cleared
  /// when the group is dissolved; the rows stay. Added in schema version 5.
  TextColumn get groupId =>
      text().nullable().references(Groups, #id, onDelete: KeyAction.setNull)();

  /// Ties the rows of one shared contact together: meeting a couple is one
  /// row per member (so each timeline and stamp works as for one person),
  /// all with the same [sharedId]. Editing or deleting one edits or deletes
  /// all (ContactEventsRepository). null = a contact with one person. Added
  /// in schema version 5.
  TextColumn get sharedId => text().nullable()();

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
    Groups,
    GroupMembers,
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
  /// tables or nullable columns; never rename or reuse a column. Dropping
  /// a column needs the developer's decision (schema 6, 02-design.md §8). A table
  /// rebuild (schema 5, intentions) goes through `m.alterTable`, which
  /// copies every row. Then run
  /// `dart run drift_dev make-migrations`: it saves a snapshot in
  /// `drift_schemas/`, updates `database.steps.dart` and the schema test
  /// helpers in `test/drift/` (as in akai-timetrack).
  @override
  int get schemaVersion => 7;

  /// Steps come from the snapshots in `drift_schemas/`. The real database
  /// on the developer's phone holds people from version 1, so a step must
  /// never lose a row: it adds, or rebuilds a table with every row copied
  /// (4 to 5), tested in `test/drift/kept/migration_test.dart`.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        // Intentions (capture).
        await m.createTable(schema.intentions);
      },
      from2To3: (m, schema) async {
        // Contact events and day answers.
        await m.createTable(schema.contactEvents);
        await m.createTable(schema.dayAnswers);
      },
      from3To4: (m, schema) async {
        // One step: two nullable columns, three new tables.
        await m.addColumn(schema.people, schema.people.replyClearedAt);
        await m.addColumn(
          schema.contactEvents,
          schema.contactEvents.activityIcon,
        );
        await m.createTable(schema.treats);
        await m.createTable(schema.stamps);
        await m.createTable(schema.ideas);
      },
      from4To5: (m, schema) async {
        // Nicknames and pictures, couples as groups, couple thoughts and
        // shared contacts.
        await m.addColumn(schema.people, schema.people.nickname);
        await m.addColumn(schema.people, schema.people.photo);
        await m.createTable(schema.groups);
        await m.createTable(schema.groupMembers);
        // person_id becomes nullable and the CHECK is added: SQLite cannot
        // change a column, so the table is rebuilt (create, copy every row,
        // drop, rename). alterTable switches foreign keys off for it, so
        // dropping the old table does not clear contact_events.intention_id.
        await m.alterTable(
          TableMigration(
            schema.intentions,
            newColumns: [schema.intentions.groupId],
          ),
        );
        await m.addColumn(schema.contactEvents, schema.contactEvents.groupId);
        await m.addColumn(schema.contactEvents, schema.contactEvents.sharedId);
      },
      from5To6: (m, schema) async {
        // Any messenger, one chat target (02-design.md §8, 2026-11-18). The
        // three old handles go without being carried over (the developer's
        // decision); main_messenger stays as it is.
        await m.addColumn(schema.people, schema.people.chatTarget);
        for (final column in [
          'telegram_username',
          'signal_link',
          'discord_user_id',
        ]) {
          await m.dropColumn(schema.people, column);
        }
      },
      from6To7: (m, schema) async {
        // An icon on a plan (02-design.md §8, 2026-11-18).
        await m.addColumn(schema.intentions, schema.intentions.activityIcon);
      },
    ),
    beforeOpen: (details) async {
      // SQLite leaves foreign keys off per connection; the cascade from
      // people to intentions needs them.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
