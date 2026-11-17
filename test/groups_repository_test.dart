import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/data/contact_events_repository.dart';
import 'package:kept/data/database.dart';
import 'package:kept/data/groups_repository.dart';
import 'package:kept/data/intentions_repository.dart';
import 'package:kept/data/people_repository.dart';
import 'package:kept/data/settings_repository.dart';
import 'package:kept/domain/contact_event.dart';
import 'package:kept/domain/group.dart';
import 'package:kept/domain/intention.dart';
import 'package:kept/domain/person.dart';

/// Couples (schema 5): GroupsRepository, couple thoughts and shared
/// contact events.
void main() {
  late AppDatabase db;
  late PeopleRepository people;
  late GroupsRepository groups;
  late IntentionsRepository intentions;
  late ContactEventsRepository events;
  late Person anna;
  late Person ben;
  late Person cleo;
  final t = DateTime(2026, 11, 16, 18);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    people = PeopleRepository(db);
    groups = GroupsRepository(db);
    intentions = IntentionsRepository(db);
    events = ContactEventsRepository(db);
    anna = await people.add(name: 'Anna', closeness: Closeness.close);
    ben = await people.add(name: 'Ben', closeness: Closeness.nowAndThen);
    cleo = await people.add(name: 'Cleo', closeness: Closeness.family);
  });
  tearDown(() => db.close());

  Future<List<ContactEvent>> meet(String groupId, {String? note}) =>
      events.addForGroup(
        groupId: groupId,
        at: t,
        kind: ContactKind.met,
        direction: ContactDirection.together,
        source: ContactSource.manual,
        activity: 'dinner',
        note: note,
        now: t,
      );

  group('couples', () {
    test('a couple of two people, in order', () async {
      final couple = await groups.createCouple(ben.id, anna.id, now: t);
      expect(couple.kind, GroupKind.couple);
      expect(couple.name, isNull);
      expect((await groups.members(couple.id)).map((p) => p.name), [
        'Ben',
        'Anna',
      ]);
      final all = await groups.watchCouples().first;
      expect(all.single.group, couple);
      expect(all.single.label(const {}), 'Ben & Anna');
      expect((await groups.coupleOf(anna.id))?.group.id, couple.id);
      expect(await groups.coupleOf(cleo.id), isNull);
      expect((await groups.watchCoupleOf(ben.id).first)?.group.id, couple.id);
    });

    test('a person is in at most one couple', () async {
      final couple = await groups.createCouple(anna.id, ben.id, now: t);
      await expectLater(
        groups.createCouple(cleo.id, ben.id),
        throwsA(
          isA<AlreadyInCoupleException>()
              .having((e) => e.personId, 'personId', ben.id)
              .having((e) => e.groupId, 'groupId', couple.id),
        ),
      );
      expect(() => groups.createCouple(cleo.id, cleo.id), throwsArgumentError);
      // Nothing half-made was left behind.
      expect(await groups.watchCouples().first, hasLength(1));
      expect(await db.select(db.groupMembers).get(), hasLength(2));
    });

    test('dissolving gives the open thoughts to both members and keeps the '
        'shared contact', () async {
      final couple = await groups.createCouple(anna.id, ben.id, now: t);
      final thought = await intentions.add(groupId: couple.id, note: 'dinner');
      final rows = await meet(couple.id);

      await groups.dissolve(couple.id);

      expect(await groups.watchCouples().first, isEmpty);
      expect(await db.select(db.groupMembers).get(), isEmpty);
      final moved = (await intentions.watchForPerson(anna.id).first).single;
      expect(moved.id, thought.id);
      expect(moved.groupId, isNull);
      final copy = (await intentions.watchForPerson(ben.id).first).single;
      expect(copy.id, isNot(thought.id));
      expect(copy.note, 'dinner');
      expect(copy.kind, thought.kind);
      expect(copy.createdAt, thought.createdAt);
      expect(copy.groupId, isNull);
      final after = await db.select(db.contactEvents).get();
      expect(after.map((e) => e.id).toSet(), rows.map((e) => e.id).toSet());
      expect(after.map((e) => e.groupId), everyElement(isNull));
      expect(after.map((e) => e.sharedId).toSet(), {rows.first.sharedId});
      // Free again for a new couple.
      await groups.createCouple(ben.id, cleo.id);
    });

    test('deleting a member dissolves the couple in the same step', () async {
      final couple = await groups.createCouple(anna.id, ben.id, now: t);
      final thought = await intentions.add(groupId: couple.id, note: 'dinner');
      await intentions.add(personId: anna.id, note: 'only Anna');

      await people.delete(anna.id);

      expect(await groups.watchCouples().first, isEmpty);
      expect(await groups.coupleOf(ben.id), isNull);
      final bens = (await intentions.watchForPerson(ben.id).first).single;
      expect(bens.id, thought.id);
      expect(await intentions.watchOpen().first, hasLength(1));
    });

    test('a couple can be named', () async {
      final couple = await groups.createCouple(
        anna.id,
        ben.id,
        name: 'The neighbours',
      );
      expect(couple.name, 'The neighbours');
      expect(
        (await groups.watchCouples().first).single.label(const {}),
        'The neighbours',
      );
    });
  });

  group('couple thoughts', () {
    test('a thought is for a person or a couple, never both', () async {
      final couple = await groups.createCouple(anna.id, ben.id);
      final thought = await intentions.add(
        groupId: couple.id,
        kind: IntentionKind.meet,
      );
      expect(thought.personId, isNull);
      expect(thought.groupId, couple.id);
      expect((await intentions.watchForGroup(couple.id).first).single, thought);
      expect(await intentions.watchForPerson(anna.id).first, isEmpty);

      await expectLater(intentions.add(), throwsArgumentError);
      await expectLater(
        intentions.add(personId: anna.id, groupId: couple.id),
        throwsArgumentError,
      );
      // The table says the same, for writes that skip the repository.
      await expectLater(
        db
            .into(db.intentions)
            .insert(
              IntentionsCompanion.insert(
                id: 'raw',
                personId: Value(anna.id),
                groupId: Value(couple.id),
                createdAt: t,
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });

    test('Done on a couple thought stores the meeting for both', () async {
      final couple = await groups.createCouple(anna.id, ben.id);
      final thought = await intentions.add(
        groupId: couple.id,
        kind: IntentionKind.meet,
      );
      final event = await events.completeIntention(thought.id, now: t);
      expect(event.personId, anna.id);
      expect(await intentions.watchOpen().first, isEmpty);
      final all = await db.select(db.contactEvents).get();
      expect(all.map((e) => e.personId).toSet(), {anna.id, ben.id});
      expect(all.map((e) => e.intentionId), everyElement(thought.id));
      expect(all.map((e) => e.kind), everyElement(ContactKind.met));
    });
  });

  group('shared contact events', () {
    test('one row per member with a stamp each', () async {
      final couple = await groups.createCouple(anna.id, ben.id);
      final rows = await meet(couple.id, note: 'new flat');
      expect(rows.map((e) => e.personId), [anna.id, ben.id]);
      expect(rows.map((e) => e.groupId), everyElement(couple.id));
      expect(rows.map((e) => e.at), everyElement(t));
      expect(rows.map((e) => e.note), everyElement('new flat'));
      expect(rows.map((e) => e.activity), everyElement('dinner'));
      expect(rows.first.sharedId, isNotNull);
      expect(rows.last.sharedId, rows.first.sharedId);
      expect(await events.watchForPerson(anna.id).first, [rows.first]);
      expect(await events.watchForPerson(ben.id).first, [rows.last]);

      final stamps = await db.select(db.stamps).get();
      expect(stamps.map((s) => s.personId).toSet(), {anna.id, ben.id});
      for (final row in rows) {
        expect(stamps.where((s) => s.contactEventId == row.id), hasLength(1));
      }
    });

    test(
      'all rows or none: a failure on the second member keeps nothing',
      () async {
        final couple = await groups.createCouple(anna.id, ben.id);
        var calls = 0;
        final settings = SettingsRepository(db);
        final failing = ContactEventsRepository(
          db,
          loadSettings: () {
            if (++calls == 2) throw StateError('settings gone');
            return settings.load();
          },
        );
        await expectLater(
          failing.addForGroup(
            groupId: couple.id,
            at: t,
            kind: ContactKind.met,
            direction: ContactDirection.together,
            source: ContactSource.manual,
          ),
          throwsStateError,
        );
        expect(calls, 2);
        expect(await db.select(db.contactEvents).get(), isEmpty);
        expect(await db.select(db.stamps).get(), isEmpty);
      },
    );

    test('a group without members stores nothing', () async {
      final couple = await groups.createCouple(anna.id, ben.id);
      await db.delete(db.groupMembers).go();
      await expectLater(meet(couple.id), throwsStateError);
      expect(await db.select(db.contactEvents).get(), isEmpty);
    });

    test('editing one row edits the whole shared event', () async {
      final couple = await groups.createCouple(anna.id, ben.id);
      final rows = await meet(couple.id, note: 'old');
      final single = await events.add(
        personId: anna.id,
        at: t,
        kind: ContactKind.wrote,
        direction: ContactDirection.byUser,
        source: ContactSource.manual,
        note: 'alone',
      );

      await events.update(rows.last.id, activity: 'cinema', note: 'new');

      final all = await db.select(db.contactEvents).get();
      for (final e in all.where((e) => e.sharedId != null)) {
        expect(e.activity, 'cinema');
        expect(e.note, 'new');
      }
      expect(all.firstWhere((e) => e.id == single.id).note, 'alone');
      expect(await events.sharedRowIds(single.id), [single.id]);
    });

    test(
      'deleting one row deletes the whole shared event, stamps stay',
      () async {
        final couple = await groups.createCouple(anna.id, ben.id);
        final rows = await meet(couple.id);
        final single = await events.add(
          personId: ben.id,
          at: t,
          kind: ContactKind.wrote,
          direction: ContactDirection.byUser,
          source: ContactSource.manual,
        );
        final stampCount = (await db.select(db.stamps).get()).length;

        await events.delete(rows.first.id);

        final left = await db.select(db.contactEvents).get();
        expect(left.map((e) => e.id), [single.id]);
        expect(await db.select(db.stamps).get(), hasLength(stampCount));
      },
    );
  });
}
