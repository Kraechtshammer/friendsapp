// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:kept/data/contact_events_repository.dart';
import 'package:kept/data/database.dart';
import 'package:kept/data/day_answers_repository.dart';
import 'package:kept/data/groups_repository.dart';
import 'package:kept/data/intentions_repository.dart';
import 'package:kept/data/people_repository.dart';
import 'package:kept/domain/contact_event.dart';
import 'package:kept/domain/group.dart';
import 'package:kept/domain/intention.dart';
import 'package:kept/domain/person.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v4.dart' as v4;
import 'generated/schema_v5.dart' as v5;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // v1 -> v2 only adds the intentions table. The developer's phone holds
  // real people in version 1; they and the settings must survive as they
  // are, and the new table must take a row for one of them.
  test('migration from v1 to v2 keeps people and settings', () async {
    final created =
        DateTime.utc(2026, 11, 10, 9).millisecondsSinceEpoch ~/ 1000;
    final oldSettingsData = [
      const v1.SettingsData(key: 'themeMode', value: 'dark'),
    ];
    final expectedNewSettingsData = [
      const v2.SettingsData(key: 'themeMode', value: 'dark'),
    ];

    final oldPeopleData = [
      v1.PeopleData(
        id: 'p1',
        name: 'Anna Example',
        contactId: '17',
        closeness: 'close',
        reconnecting: 0,
        rhythmDays: 9,
        mainMessenger: 'whatsapp',
        phone: '+490000000101',
        birthdayMonth: 2,
        birthdayDay: 29,
        birthdayYear: 1992,
        avatarShape: 'scallop',
        avatarColor: 'coral',
        notes: 'Likes calls.',
        createdAt: created,
      ),
      v1.PeopleData(
        id: 'p2',
        name: 'Ben Example',
        closeness: 'fewTimesAYear',
        reconnecting: 1,
        telegramUsername: 'demo_ben',
        avatarShape: 'leaf',
        avatarColor: 'mint',
        notes: '',
        createdAt: created + 60,
      ),
    ];
    final expectedNewPeopleData = [
      v2.PeopleData(
        id: 'p1',
        name: 'Anna Example',
        contactId: '17',
        closeness: 'close',
        reconnecting: 0,
        rhythmDays: 9,
        mainMessenger: 'whatsapp',
        phone: '+490000000101',
        birthdayMonth: 2,
        birthdayDay: 29,
        birthdayYear: 1992,
        avatarShape: 'scallop',
        avatarColor: 'coral',
        notes: 'Likes calls.',
        createdAt: created,
      ),
      v2.PeopleData(
        id: 'p2',
        name: 'Ben Example',
        closeness: 'fewTimesAYear',
        reconnecting: 1,
        telegramUsername: 'demo_ben',
        avatarShape: 'leaf',
        avatarColor: 'mint',
        notes: '',
        createdAt: created + 60,
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.settings, oldSettingsData);
        batch.insertAll(oldDb.people, oldPeopleData);
      },
      validateItems: (newDb) async {
        expect(
          expectedNewSettingsData,
          await newDb.select(newDb.settings).get(),
        );
        expect(expectedNewPeopleData, await newDb.select(newDb.people).get());
        expect(await newDb.select(newDb.intentions).get(), isEmpty);

        await newDb
            .into(newDb.intentions)
            .insert(
              v2.IntentionsCompanion.insert(
                id: 'i1',
                personId: 'p1',
                createdAt: created + 120,
              ),
            );
        final row = await newDb.select(newDb.intentions).getSingle();
        expect(row.personId, 'p1');
        expect(row.note, '');
        expect(row.kind, 'write');
        expect(row.state, 'open');
        expect(row.closedAt, isNull);
      },
    );
  });

  // The app's own code on a migrated file: people are read as before and an
  // intention can be added and is removed with its person.
  test('the app works on a database upgraded from v1', () async {
    final schema = await verifier.schemaAt(1);
    final created = DateTime(2026, 11, 10, 9);
    final old = v1.DatabaseAtV1(schema.newConnection());
    await old
        .into(old.people)
        .insert(
          v1.PeopleData(
            id: 'p1',
            name: 'Anna Example',
            closeness: 'close',
            reconnecting: 0,
            avatarShape: 'scallop',
            avatarColor: 'coral',
            notes: '',
            createdAt: created.millisecondsSinceEpoch ~/ 1000,
          ),
        );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    final people = PeopleRepository(db);
    final intentions = IntentionsRepository(db);
    final anna = (await people.watchAll().first).single;
    expect(anna.name, 'Anna Example');
    expect(anna.closeness, Closeness.close);
    expect(anna.createdAt, created);

    await intentions.add(personId: 'p1', note: 'ask about the new job');
    expect(await intentions.watchForPerson('p1').first, hasLength(1));
    await people.delete('p1');
    expect(await intentions.watchOpen().first, isEmpty);
    await db.close();
  });

  // v2 -> v3 only adds contact_events and day_answers. The developer's
  // phone holds real people, intentions and settings in version 2; every
  // row must come through unchanged, and the new tables must take rows
  // that point at the old ones.
  test(
    'migration from v2 to v3 keeps people, intentions and settings',
    () async {
      final created =
          DateTime.utc(2026, 11, 16, 9).millisecondsSinceEpoch ~/ 1000;
      final oldSettings = [
        const v2.SettingsData(key: 'themeMode', value: 'dark'),
        const v2.SettingsData(key: 'demoMode', value: 'false'),
      ];
      final oldPeople = [
        v2.PeopleData(
          id: 'p1',
          name: 'Anna Example',
          contactId: '17',
          closeness: 'close',
          reconnecting: 0,
          rhythmDays: 9,
          mainMessenger: 'whatsapp',
          phone: '+490000000101',
          telegramUsername: 'anna_t',
          signalLink: 'https://signal.me/#p/x',
          discordUserId: '123',
          birthdayMonth: 2,
          birthdayDay: 29,
          birthdayYear: 1992,
          avatarShape: 'scallop',
          avatarColor: 'coral',
          notes: 'Likes calls.',
          createdAt: created,
        ),
        v2.PeopleData(
          id: 'p2',
          name: 'Ben Example',
          closeness: 'fewTimesAYear',
          reconnecting: 1,
          avatarShape: 'leaf',
          avatarColor: 'mint',
          notes: '',
          createdAt: created + 60,
        ),
      ];
      final oldIntentions = [
        v2.IntentionsData(
          id: 'i1',
          personId: 'p1',
          note: 'saw a bouldering video',
          kind: 'meet',
          state: 'open',
          createdAt: created + 120,
        ),
        v2.IntentionsData(
          id: 'i2',
          personId: 'p2',
          note: 'how was the trip',
          kind: 'call',
          state: 'done',
          link: 'https://example.org',
          date: created + 86400,
          horizon: 'whenCondition',
          condition: 'when he is back',
          createdAt: created + 180,
          closedAt: created + 240,
        ),
      ];

      await verifier.testWithDataIntegrity(
        oldVersion: 2,
        newVersion: 3,
        createOld: v2.DatabaseAtV2.new,
        createNew: v3.DatabaseAtV3.new,
        openTestedDatabase: AppDatabase.new,
        createItems: (batch, oldDb) {
          batch.insertAll(oldDb.settings, oldSettings);
          batch.insertAll(oldDb.people, oldPeople);
          batch.insertAll(oldDb.intentions, oldIntentions);
        },
        validateItems: (newDb) async {
          // Same columns in v2 and v3, so each old row read back through
          // JSON is the row expected after the upgrade, field by field.
          expect(await newDb.select(newDb.settings).get(), [
            for (final r in oldSettings) v3.SettingsData.fromJson(r.toJson()),
          ]);
          expect(await newDb.select(newDb.people).get(), [
            for (final r in oldPeople) v3.PeopleData.fromJson(r.toJson()),
          ]);
          expect(await newDb.select(newDb.intentions).get(), [
            for (final r in oldIntentions)
              v3.IntentionsData.fromJson(r.toJson()),
          ]);
          expect(await newDb.select(newDb.contactEvents).get(), isEmpty);
          expect(await newDb.select(newDb.dayAnswers).get(), isEmpty);

          await newDb
              .into(newDb.contactEvents)
              .insert(
                v3.ContactEventsCompanion.insert(
                  id: 'e1',
                  personId: 'p1',
                  at: created + 300,
                  kind: 'met',
                  direction: 'together',
                  source: 'manual',
                  intentionId: const Value('i1'),
                  createdAt: created + 300,
                ),
              );
          await newDb
              .into(newDb.dayAnswers)
              .insert(
                v3.DayAnswersCompanion.insert(day: '2026-11-16', answer: 'yes'),
              );
          final event = await newDb.select(newDb.contactEvents).getSingle();
          expect(event.personId, 'p1');
          expect(event.intentionId, 'i1');
          expect(event.activity, isNull);
          expect(event.note, isNull);
          final answer = await newDb.select(newDb.dayAnswers).getSingle();
          expect(answer.answer, 'yes');
          expect(answer.answeredAt, isNull);
        },
      );
    },
  );

  // The app's own code on a file upgraded from v2: old people and
  // intentions read as before, an intention can be completed with a
  // contact event, and the foreign keys work on the new table.
  test('the app works on a database upgraded from v2', () async {
    final schema = await verifier.schemaAt(2);
    final created = DateTime(2026, 11, 16, 9);
    final secs = created.millisecondsSinceEpoch ~/ 1000;
    final old = v2.DatabaseAtV2(schema.newConnection());
    await old
        .into(old.people)
        .insert(
          v2.PeopleData(
            id: 'p1',
            name: 'Anna Example',
            closeness: 'close',
            reconnecting: 0,
            avatarShape: 'scallop',
            avatarColor: 'coral',
            notes: '',
            createdAt: secs,
          ),
        );
    await old
        .into(old.intentions)
        .insert(
          v2.IntentionsData(
            id: 'i1',
            personId: 'p1',
            note: 'ask about the new job',
            kind: 'call',
            state: 'open',
            createdAt: secs,
          ),
        );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    final people = PeopleRepository(db);
    final intentions = IntentionsRepository(db);
    final events = ContactEventsRepository(db);
    final days = DayAnswersRepository(db);
    final anna = (await people.watchAll().first).single;
    expect(anna.name, 'Anna Example');
    final open = (await intentions.watchOpen().first).single;
    expect(open.kind, IntentionKind.call);
    expect(open.createdAt, created);

    final done = created.add(const Duration(hours: 2));
    final event = await events.completeIntention(
      'i1',
      note: 'new job in March',
      now: done,
    );
    expect(event.kind, ContactKind.called);
    expect(await intentions.watchOpen().first, isEmpty);
    expect(await events.watchLatestNote('p1').first, 'new job in March');
    await days.setToday(DayAnswerValue.yes, now: done);
    expect((await days.forDay(done))?.answer, DayAnswerValue.yes);

    await people.delete('p1');
    expect(await events.watchForPerson('p1').first, isEmpty);
    await db.close();
  });

  // v3 -> v4 adds two nullable columns (people.reply_cleared_at,
  // contact_events.activity_icon) and the tables treats, stamps and ideas.
  // The developer's phone holds real data in version 3: every old row must
  // come through unchanged, the new columns must be null on it, and the new
  // tables must take rows that point at the old ones.
  test('migration from v3 to v4 keeps every old row', () async {
    final created =
        DateTime.utc(2026, 11, 16, 9).millisecondsSinceEpoch ~/ 1000;
    final oldSettings = [
      const v3.SettingsData(key: 'themeMode', value: 'dark'),
      const v3.SettingsData(key: 'eveningTime', value: '20:30'),
    ];
    final oldPeople = [
      v3.PeopleData(
        id: 'p1',
        name: 'Anna Example',
        contactId: '17',
        closeness: 'close',
        reconnecting: 1,
        rhythmDays: 9,
        mainMessenger: 'whatsapp',
        phone: '+490000000101',
        telegramUsername: 'anna_t',
        signalLink: 'https://signal.me/#p/x',
        discordUserId: '123',
        birthdayMonth: 2,
        birthdayDay: 29,
        birthdayYear: 1992,
        avatarShape: 'scallop',
        avatarColor: 'coral',
        notes: 'Likes calls.',
        createdAt: created,
      ),
      v3.PeopleData(
        id: 'p2',
        name: 'Ben Example',
        closeness: 'fewTimesAYear',
        reconnecting: 0,
        avatarShape: 'leaf',
        avatarColor: 'mint',
        notes: '',
        createdAt: created + 60,
      ),
    ];
    final oldIntentions = [
      v3.IntentionsData(
        id: 'i1',
        personId: 'p1',
        note: 'saw a bouldering video',
        kind: 'meet',
        state: 'done',
        link: 'https://example.org',
        date: created + 86400,
        horizon: 'whenCondition',
        condition: 'when she is back',
        createdAt: created + 120,
        closedAt: created + 240,
      ),
      v3.IntentionsData(
        id: 'i2',
        personId: 'p2',
        note: '',
        kind: 'write',
        state: 'open',
        createdAt: created + 180,
      ),
    ];
    final oldEvents = [
      v3.ContactEventsData(
        id: 'e1',
        personId: 'p1',
        at: created + 240,
        kind: 'met',
        direction: 'together',
        source: 'confirmed',
        activity: 'bouldering',
        note: 'new job in March',
        intentionId: 'i1',
        createdAt: created + 240,
      ),
      v3.ContactEventsData(
        id: 'e2',
        personId: 'p2',
        at: created + 300,
        kind: 'wrote',
        direction: 'byThem',
        source: 'manual',
        createdAt: created + 300,
      ),
    ];
    final oldDayAnswers = [
      v3.DayAnswersData(
        day: '2026-11-15',
        answer: 'notToday',
        answeredAt: created - 3600,
      ),
      const v3.DayAnswersData(day: '2026-11-16', answer: 'yes'),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 3,
      newVersion: 4,
      createOld: v3.DatabaseAtV3.new,
      createNew: v4.DatabaseAtV4.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.settings, oldSettings);
        batch.insertAll(oldDb.people, oldPeople);
        batch.insertAll(oldDb.intentions, oldIntentions);
        batch.insertAll(oldDb.contactEvents, oldEvents);
        batch.insertAll(oldDb.dayAnswers, oldDayAnswers);
      },
      validateItems: (newDb) async {
        // Each old row read back through JSON is the row expected after the
        // upgrade, field by field; the new columns are missing from the old
        // JSON and so must be null.
        expect(await newDb.select(newDb.settings).get(), [
          for (final r in oldSettings) v4.SettingsData.fromJson(r.toJson()),
        ]);
        final people = await newDb.select(newDb.people).get();
        expect(people, [
          for (final r in oldPeople) v4.PeopleData.fromJson(r.toJson()),
        ]);
        expect(people.map((p) => p.replyClearedAt), everyElement(isNull));
        expect(await newDb.select(newDb.intentions).get(), [
          for (final r in oldIntentions) v4.IntentionsData.fromJson(r.toJson()),
        ]);
        final events = await newDb.select(newDb.contactEvents).get();
        expect(events, [
          for (final r in oldEvents) v4.ContactEventsData.fromJson(r.toJson()),
        ]);
        expect(events.map((e) => e.activityIcon), everyElement(isNull));
        expect(await newDb.select(newDb.dayAnswers).get(), [
          for (final r in oldDayAnswers) v4.DayAnswersData.fromJson(r.toJson()),
        ]);
        expect(await newDb.select(newDb.treats).get(), isEmpty);
        expect(await newDb.select(newDb.stamps).get(), isEmpty);
        expect(await newDb.select(newDb.ideas).get(), isEmpty);

        // The generated v4 class has no beforeOpen; switch foreign keys on
        // as AppDatabase does.
        await newDb.customStatement('PRAGMA foreign_keys = ON');

        // The new columns take values on old rows.
        await (newDb.update(newDb.people)..where((p) => p.id.equals('p2')))
            .write(v4.PeopleCompanion(replyClearedAt: Value(created + 400)));
        await (newDb.update(
          newDb.contactEvents,
        )..where((e) => e.id.equals('e1'))).write(
          const v4.ContactEventsCompanion(activityIcon: Value('climbing')),
        );

        await newDb
            .into(newDb.treats)
            .insert(
              v4.TreatsCompanion.insert(
                id: 't1',
                name: 'Ice cream',
                stampsNeeded: 5,
                state: 'current',
                position: 0,
                createdAt: created + 500,
              ),
            );
        await newDb.batch((b) {
          b.insertAll(newDb.stamps, [
            // On Anna's event e1 (deleted with Anna below).
            v4.StampsCompanion.insert(
              id: 's1',
              at: created + 510,
              value: 1,
              personId: const Value('p1'),
              contactEventId: const Value('e1'),
              treatId: const Value('t1'),
              createdAt: created + 510,
            ),
            // On Ben's event e2 (the event alone is deleted below).
            v4.StampsCompanion.insert(
              id: 's2',
              at: created + 520,
              value: 2,
              personId: const Value('p2'),
              contactEventId: const Value('e2'),
              treatId: const Value('t1'),
              createdAt: created + 520,
            ),
          ]);
          b.insertAll(newDb.ideas, [
            v4.IdeasCompanion.insert(
              id: 'd1',
              personId: 'p1',
              note: 'climbing hall in town',
              kind: 'toDo',
              link: const Value('https://example.org/hall'),
              createdAt: created + 530,
            ),
            v4.IdeasCompanion.insert(
              id: 'd2',
              personId: 'p2',
              note: 'his trip',
              kind: 'toTalk',
              createdAt: created + 540,
            ),
          ]);
        });

        Future<v4.StampsData> stamp(String id) => (newDb.select(
          newDb.stamps,
        )..where((s) => s.id.equals(id))).getSingle();

        // Deleting an event keeps its stamp and clears the link.
        await (newDb.delete(
          newDb.contactEvents,
        )..where((e) => e.id.equals('e2'))).go();
        expect((await stamp('s2')).contactEventId, isNull);
        expect((await stamp('s2')).personId, 'p2');

        // Deleting a treat keeps its stamps and clears the card.
        await (newDb.delete(
          newDb.treats,
        )..where((t) => t.id.equals('t1'))).go();
        expect((await stamp('s1')).treatId, isNull);
        expect((await stamp('s2')).treatId, isNull);

        // Deleting a person keeps their stamps, deletes their ideas and
        // events (and so clears the stamp's event link too).
        await (newDb.delete(
          newDb.people,
        )..where((p) => p.id.equals('p1'))).go();
        final s1 = await stamp('s1');
        expect(s1.personId, isNull);
        expect(s1.contactEventId, isNull);
        expect(s1.value, 1);
        expect(await newDb.select(newDb.stamps).get(), hasLength(2));
        final ideas = await newDb.select(newDb.ideas).get();
        expect(ideas.map((i) => i.id), ['d2']);
      },
    );
  });

  // The whole path from the first schema: version 1 people and settings
  // reach version 4 unchanged.
  test('migration from v1 to v4 keeps people and settings', () async {
    final created =
        DateTime.utc(2026, 11, 10, 9).millisecondsSinceEpoch ~/ 1000;
    final oldSettings = [
      const v1.SettingsData(key: 'themeMode', value: 'dark'),
    ];
    final oldPeople = [
      v1.PeopleData(
        id: 'p1',
        name: 'Anna Example',
        contactId: '17',
        closeness: 'close',
        reconnecting: 0,
        rhythmDays: 9,
        mainMessenger: 'whatsapp',
        phone: '+490000000101',
        telegramUsername: 'anna_t',
        signalLink: 'https://signal.me/#p/x',
        discordUserId: '123',
        birthdayMonth: 2,
        birthdayDay: 29,
        birthdayYear: 1992,
        avatarShape: 'scallop',
        avatarColor: 'coral',
        notes: 'Likes calls.',
        createdAt: created,
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 4,
      createOld: v1.DatabaseAtV1.new,
      createNew: v4.DatabaseAtV4.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.settings, oldSettings);
        batch.insertAll(oldDb.people, oldPeople);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.settings).get(), [
          for (final r in oldSettings) v4.SettingsData.fromJson(r.toJson()),
        ]);
        expect(await newDb.select(newDb.people).get(), [
          for (final r in oldPeople) v4.PeopleData.fromJson(r.toJson()),
        ]);
        expect(await newDb.select(newDb.intentions).get(), isEmpty);
        expect(await newDb.select(newDb.contactEvents).get(), isEmpty);
        expect(await newDb.select(newDb.stamps).get(), isEmpty);
      },
    );
  });
  // v4 -> v5 adds people.nickname and people.photo, the tables groups and
  // group_members, contact_events.group_id and shared_id, and rebuilds
  // intentions (person_id nullable, new group_id, a CHECK). The rebuild
  // drops and re-creates the table, so this checks every row of every
  // table, and that the links into intentions (contact_events.intention_id)
  // and from stamps survive it.
  test('migration from v4 to v5 keeps every old row', () async {
    final created =
        DateTime.utc(2026, 11, 16, 9).millisecondsSinceEpoch ~/ 1000;
    final oldSettings = [
      const v4.SettingsData(key: 'themeMode', value: 'dark'),
      const v4.SettingsData(key: 'eveningTime', value: '20:30'),
      const v4.SettingsData(key: 'defaultTreatsInserted', value: 'true'),
    ];
    final oldPeople = [
      v4.PeopleData(
        id: 'p1',
        name: 'Anna Example',
        contactId: '17',
        closeness: 'close',
        reconnecting: 1,
        rhythmDays: 9,
        mainMessenger: 'whatsapp',
        phone: '+490000000101',
        telegramUsername: 'anna_t',
        signalLink: 'https://signal.me/#p/x',
        discordUserId: '123',
        birthdayMonth: 2,
        birthdayDay: 29,
        birthdayYear: 1992,
        avatarShape: 'scallop',
        avatarColor: 'coral',
        notes: 'Likes calls.',
        createdAt: created,
        replyClearedAt: created + 30,
      ),
      v4.PeopleData(
        id: 'p2',
        name: 'Ben Example',
        closeness: 'fewTimesAYear',
        reconnecting: 0,
        avatarShape: 'leaf',
        avatarColor: 'mint',
        notes: '',
        createdAt: created + 60,
      ),
    ];
    final oldIntentions = [
      v4.IntentionsData(
        id: 'i1',
        personId: 'p1',
        note: 'saw a bouldering video',
        kind: 'meet',
        state: 'done',
        link: 'https://example.org',
        date: created + 86400,
        horizon: 'whenCondition',
        condition: 'when she is back',
        createdAt: created + 120,
        closedAt: created + 240,
      ),
      v4.IntentionsData(
        id: 'i2',
        personId: 'p2',
        note: '',
        kind: 'write',
        state: 'open',
        createdAt: created + 180,
      ),
    ];
    final oldEvents = [
      v4.ContactEventsData(
        id: 'e1',
        personId: 'p1',
        at: created + 240,
        kind: 'met',
        direction: 'together',
        source: 'confirmed',
        activity: 'bouldering',
        note: 'new job in March',
        intentionId: 'i1',
        createdAt: created + 240,
        activityIcon: 'climbing',
      ),
      v4.ContactEventsData(
        id: 'e2',
        personId: 'p2',
        at: created + 300,
        kind: 'wrote',
        direction: 'byThem',
        source: 'manual',
        createdAt: created + 300,
      ),
    ];
    final oldDayAnswers = [
      v4.DayAnswersData(
        day: '2026-11-15',
        answer: 'notToday',
        answeredAt: created - 3600,
      ),
      const v4.DayAnswersData(day: '2026-11-16', answer: 'yes'),
    ];
    final oldTreats = [
      v4.TreatsData(
        id: 't1',
        name: 'Ice cream',
        stampsNeeded: 5,
        state: 'earned',
        position: 0,
        createdAt: created,
        earnedAt: created + 400,
      ),
      v4.TreatsData(
        id: 't2',
        name: 'Day trip',
        stampsNeeded: 12,
        state: 'current',
        position: 1,
        createdAt: created + 1,
      ),
    ];
    final oldStamps = [
      v4.StampsData(
        id: 's1',
        at: created + 240,
        value: 3,
        personId: 'p1',
        contactEventId: 'e1',
        treatId: 't1',
        createdAt: created + 240,
      ),
      // A loose piece whose person, event and card are gone.
      v4.StampsData(id: 's2', at: created + 250, value: 1, createdAt: 0),
    ];
    final oldIdeas = [
      v4.IdeasData(
        id: 'd1',
        personId: 'p1',
        note: 'climbing hall in town',
        kind: 'toDo',
        link: 'https://example.org/hall',
        imagePath: 'shared/a.jpg',
        createdAt: created + 530,
        doneAt: created + 600,
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 4,
      newVersion: 5,
      createOld: v4.DatabaseAtV4.new,
      createNew: v5.DatabaseAtV5.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.settings, oldSettings);
        batch.insertAll(oldDb.people, oldPeople);
        batch.insertAll(oldDb.intentions, oldIntentions);
        batch.insertAll(oldDb.contactEvents, oldEvents);
        batch.insertAll(oldDb.dayAnswers, oldDayAnswers);
        batch.insertAll(oldDb.treats, oldTreats);
        batch.insertAll(oldDb.stamps, oldStamps);
        batch.insertAll(oldDb.ideas, oldIdeas);
      },
      validateItems: (newDb) async {
        // Each old row read back through JSON is the row expected after the
        // upgrade, field by field; the new columns are missing from the old
        // JSON and so must be null.
        expect(await newDb.select(newDb.settings).get(), [
          for (final r in oldSettings) v5.SettingsData.fromJson(r.toJson()),
        ]);
        final people = await newDb.select(newDb.people).get();
        expect(people, [
          for (final r in oldPeople) v5.PeopleData.fromJson(r.toJson()),
        ]);
        expect(people.map((p) => p.nickname), everyElement(isNull));
        expect(people.map((p) => p.photo), everyElement(isNull));
        final intentions = await newDb.select(newDb.intentions).get();
        expect(intentions, [
          for (final r in oldIntentions) v5.IntentionsData.fromJson(r.toJson()),
        ]);
        expect(intentions.map((i) => i.personId), ['p1', 'p2']);
        expect(intentions.map((i) => i.groupId), everyElement(isNull));
        final events = await newDb.select(newDb.contactEvents).get();
        expect(events, [
          for (final r in oldEvents) v5.ContactEventsData.fromJson(r.toJson()),
        ]);
        expect(events.first.intentionId, 'i1');
        expect(events.map((e) => e.groupId), everyElement(isNull));
        expect(events.map((e) => e.sharedId), everyElement(isNull));
        expect(await newDb.select(newDb.dayAnswers).get(), [
          for (final r in oldDayAnswers) v5.DayAnswersData.fromJson(r.toJson()),
        ]);
        expect(await newDb.select(newDb.treats).get(), [
          for (final r in oldTreats) v5.TreatsData.fromJson(r.toJson()),
        ]);
        expect(await newDb.select(newDb.stamps).get(), [
          for (final r in oldStamps) v5.StampsData.fromJson(r.toJson()),
        ]);
        expect(await newDb.select(newDb.ideas).get(), [
          for (final r in oldIdeas) v5.IdeasData.fromJson(r.toJson()),
        ]);
        expect(await newDb.select(newDb.groups).get(), isEmpty);
        expect(await newDb.select(newDb.groupMembers).get(), isEmpty);
        expect(
          await newDb.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );

        // The rebuilt table has the CHECK: a person or a group, not both,
        // not neither.
        await newDb.customStatement('PRAGMA foreign_keys = ON');
        await expectLater(
          newDb
              .into(newDb.intentions)
              .insert(
                v5.IntentionsCompanion.insert(id: 'bad', createdAt: created),
              ),
          throwsA(isA<Exception>()),
        );
        await newDb
            .into(newDb.groups)
            .insert(
              v5.GroupsCompanion.insert(
                id: 'g1',
                kind: 'couple',
                createdAt: created + 700,
              ),
            );
        await expectLater(
          newDb
              .into(newDb.intentions)
              .insert(
                v5.IntentionsCompanion.insert(
                  id: 'bad',
                  personId: const Value('p1'),
                  groupId: const Value('g1'),
                  createdAt: created,
                ),
              ),
          throwsA(isA<Exception>()),
        );
        await newDb
            .into(newDb.intentions)
            .insert(
              v5.IntentionsCompanion.insert(
                id: 'i3',
                groupId: const Value('g1'),
                createdAt: created + 710,
              ),
            );

        // The foreign keys of the rebuilt table still work: deleting the
        // intention clears the event's link, deleting the person deletes
        // their intentions.
        await (newDb.delete(
          newDb.intentions,
        )..where((i) => i.id.equals('i1'))).go();
        final e1 = await (newDb.select(
          newDb.contactEvents,
        )..where((e) => e.id.equals('e1'))).getSingle();
        expect(e1.intentionId, isNull);
        await (newDb.delete(
          newDb.people,
        )..where((p) => p.id.equals('p2'))).go();
        final left = await newDb.select(newDb.intentions).get();
        expect(left.map((i) => i.id), ['i3']);
      },
    );
  });

  // The app's own code on a file upgraded from v4: a couple of two old
  // people, a thought for the couple, and meeting them as one shared entry
  // with a stamp each.
  test('the app works on a database upgraded from v4', () async {
    final schema = await verifier.schemaAt(4);
    final created = DateTime(2026, 11, 16, 9);
    final secs = created.millisecondsSinceEpoch ~/ 1000;
    final old = v4.DatabaseAtV4(schema.newConnection());
    for (final (id, name) in [('p1', 'Anna Example'), ('p2', 'Ben Example')]) {
      await old
          .into(old.people)
          .insert(
            v4.PeopleData(
              id: id,
              name: name,
              closeness: 'close',
              reconnecting: 0,
              avatarShape: 'scallop',
              avatarColor: 'coral',
              notes: '',
              createdAt: secs,
            ),
          );
    }
    await old.close();

    final db = AppDatabase(schema.newConnection());
    final groups = GroupsRepository(db);
    final intentions = IntentionsRepository(db);
    final events = ContactEventsRepository(db);
    final couple = await groups.createCouple('p1', 'p2', now: created);
    expect((await groups.coupleOf('p2'))?.group.id, couple.id);
    final thought = await intentions.add(
      groupId: couple.id,
      note: 'dinner',
      kind: IntentionKind.meet,
    );
    final met = await events.completeIntention(thought.id, now: created);
    expect(met.groupId, couple.id);
    expect(await events.watchForPerson('p1').first, hasLength(1));
    expect(await events.watchForPerson('p2').first, hasLength(1));
    final stamps = await db.select(db.stamps).get();
    expect(stamps.map((s) => s.personId).toSet(), {'p1', 'p2'});
    expect(couple.kind, GroupKind.couple);
    await db.close();
  });
}
