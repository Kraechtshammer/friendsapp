// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:kept/data/database.dart';
import 'package:kept/data/intentions_repository.dart';
import 'package:kept/data/people_repository.dart';
import 'package:kept/domain/person.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

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
}
