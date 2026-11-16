// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:kept/data/contact_events_repository.dart';
import 'package:kept/data/database.dart';
import 'package:kept/data/day_answers_repository.dart';
import 'package:kept/data/intentions_repository.dart';
import 'package:kept/data/people_repository.dart';
import 'package:kept/domain/contact_event.dart';
import 'package:kept/domain/intention.dart';
import 'package:kept/domain/person.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;

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
}
