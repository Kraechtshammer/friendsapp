import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/data/contact_events_repository.dart';
import 'package:kept/data/database.dart';
import 'package:kept/data/intentions_repository.dart';
import 'package:kept/data/people_repository.dart';
import 'package:kept/data/treats_repository.dart';
import 'package:kept/domain/stamps.dart';
import 'package:kept/domain/contact_event.dart';
import 'package:kept/domain/intention.dart';
import 'package:kept/domain/person.dart';

void main() {
  group('kind mapping', () {
    test('maps every intention kind to a contact kind', () {
      expect(contactKindFor(IntentionKind.write), ContactKind.wrote);
      expect(contactKindFor(IntentionKind.call), ContactKind.called);
      expect(contactKindFor(IntentionKind.meet), ContactKind.met);
      expect(contactKindFor(IntentionKind.game), ContactKind.gamed);
    });

    test('writing and calling are by the user, the rest together', () {
      expect(contactDirectionFor(IntentionKind.write), ContactDirection.byUser);
      expect(contactDirectionFor(IntentionKind.call), ContactDirection.byUser);
      expect(
        contactDirectionFor(IntentionKind.meet),
        ContactDirection.together,
      );
      expect(
        contactDirectionFor(IntentionKind.game),
        ContactDirection.together,
      );
    });
  });

  late AppDatabase db;
  late PeopleRepository people;
  late IntentionsRepository intentions;
  late ContactEventsRepository repo;
  late Person anna;
  late Person ben;
  final t = DateTime(2026, 11, 16, 18);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    people = PeopleRepository(db);
    intentions = IntentionsRepository(db);
    repo = ContactEventsRepository(db);
    anna = await people.add(name: 'Anna', closeness: Closeness.close);
    ben = await people.add(name: 'Ben', closeness: Closeness.family);
  });
  tearDown(() => db.close());

  Future<ContactEvent> add(
    Person p,
    int hour, {
    String? note,
    ContactKind kind = ContactKind.wrote,
  }) => repo.add(
    personId: p.id,
    at: t.add(Duration(hours: hour)),
    kind: kind,
    direction: ContactDirection.byUser,
    source: ContactSource.manual,
    note: note,
    now: t,
  );

  test('adds an event with a new id and whole seconds', () async {
    final added = await repo.add(
      personId: anna.id,
      at: DateTime(2026, 11, 15, 20, 1, 2, 345),
      kind: ContactKind.gamed,
      direction: ContactDirection.together,
      source: ContactSource.confirmed,
      activity: 'Mario Kart',
      now: DateTime(2026, 11, 16, 9, 0, 0, 999),
    );
    expect(added.id, hasLength(36));
    expect(added.at, DateTime(2026, 11, 15, 20, 1, 2));
    expect(added.createdAt, DateTime(2026, 11, 16, 9));
    expect(added.intentionId, isNull);
    expect(await repo.watchForPerson(anna.id).first, [added]);
  });

  test('a contact from last week earns that week\'s stamp', () async {
    final now = DateTime(2026, 11, 18, 10);
    final lastWeek = DateTime(2026, 11, 11, 12);
    await repo.add(
      personId: anna.id,
      at: lastWeek,
      kind: ContactKind.met,
      direction: ContactDirection.together,
      source: ContactSource.manual,
      now: now,
    );
    final stamps = await TreatsRepository(db).watchStamps().first;
    expect(stamps, isNotEmpty);
    for (final s in stamps) {
      expect(weekStart(s.at), weekStart(lastWeek));
      expect(weekStart(s.at), isNot(weekStart(now)));
    }
  });

  test('stores the enums as their names', () async {
    await repo.add(
      personId: anna.id,
      at: t,
      kind: ContactKind.birthdayWish,
      direction: ContactDirection.byThem,
      source: ContactSource.listener,
    );
    final row = await db
        .customSelect('SELECT kind, direction, source FROM contact_events')
        .getSingle();
    expect(row.read<String>('kind'), 'birthdayWish');
    expect(row.read<String>('direction'), 'byThem');
    expect(row.read<String>('source'), 'listener');
  });

  test('refuses an event for an unknown person', () async {
    await expectLater(
      repo.add(
        personId: 'nobody',
        at: t,
        kind: ContactKind.wrote,
        direction: ContactDirection.byUser,
        source: ContactSource.manual,
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('watches one person\'s events newest first', () async {
    final a1 = await add(anna, 1);
    await add(ben, 2);
    final a3 = await add(anna, 3);
    final a0 = await add(anna, 0);
    expect(await repo.watchForPerson(anna.id).first, [a3, a1, a0]);
  });

  test('the latest note skips empty notes and other people', () async {
    expect(await repo.watchLatestNote(anna.id).first, isNull);
    await add(anna, 1, note: 'new job in March');
    await add(anna, 2, note: '  ');
    await add(anna, 3);
    await add(ben, 4, note: 'Ben\'s note');
    expect(await repo.watchLatestNote(anna.id).first, 'new job in March');
    await add(anna, 5, note: 'moving in May');
    expect(await repo.watchLatestNote(anna.id).first, 'moving in May');
  });

  test('completeIntention closes the intention and links the event', () async {
    final i = await intentions.add(
      personId: anna.id,
      note: 'play again',
      kind: IntentionKind.game,
      activityIcon: 'meeple',
    );
    final done = DateTime(2026, 11, 16, 21, 30, 5, 500);
    final event = await repo.completeIntention(
      i.id,
      activity: 'Mario Kart',
      note: 'wants a rematch',
      now: done,
    );
    expect(event.personId, anna.id);
    expect(event.kind, ContactKind.gamed);
    expect(event.direction, ContactDirection.together);
    expect(event.source, ContactSource.confirmed);
    expect(event.intentionId, i.id);
    expect(event.at, DateTime(2026, 11, 16, 21, 30, 5));
    expect(event.activity, 'Mario Kart');
    // The plan's icon goes with it.
    expect(event.activityIcon, 'meeple');

    final stored = (await intentions.watchForPerson(anna.id).first).single;
    expect(stored.state, IntentionState.done);
    expect(stored.closedAt, DateTime(2026, 11, 16, 21, 30, 5));
    expect(await repo.watchForPerson(anna.id).first, [event]);
  });

  test('completeIntention changes nothing for an unknown intention', () async {
    await expectLater(repo.completeIntention('nope'), throwsA(anything));
    expect(await repo.watchForPerson(anna.id).first, isEmpty);
  });

  test('deleting a person deletes their events', () async {
    await add(anna, 1);
    final b = await add(ben, 2);
    await people.delete(anna.id);
    expect(await repo.watchForPerson(anna.id).first, isEmpty);
    expect(await repo.watchForPerson(ben.id).first, [b]);
  });

  test('deleting an intention keeps the event and clears the link', () async {
    final i = await intentions.add(personId: anna.id);
    final event = await repo.completeIntention(i.id, now: t);
    await intentions.delete(i.id);
    final kept = (await repo.watchForPerson(anna.id).first).single;
    expect(kept.id, event.id);
    expect(kept.intentionId, isNull);
  });

  test('update sets activity and note, and null clears them', () async {
    final event = await add(anna, 0, note: 'old', kind: ContactKind.met);
    await repo.update(event.id, activity: 'Bouldering', note: 'new job');
    var stored = (await repo.watchForPerson(anna.id).first).single;
    expect(stored.activity, 'Bouldering');
    expect(stored.note, 'new job');
    expect(stored.kind, ContactKind.met);
    expect(stored.at, event.at);

    await repo.update(event.id);
    stored = (await repo.watchForPerson(anna.id).first).single;
    expect(stored.activity, isNull);
    expect(stored.note, isNull);
  });
}
