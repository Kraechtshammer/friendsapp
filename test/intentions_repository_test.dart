import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/data/database.dart';
import 'package:kept/data/intentions_repository.dart';
import 'package:kept/data/people_repository.dart';
import 'package:kept/domain/intention.dart';
import 'package:kept/domain/person.dart';

void main() {
  late AppDatabase db;
  late PeopleRepository people;
  late IntentionsRepository repo;
  late Person anna;
  late Person ben;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    people = PeopleRepository(db);
    repo = IntentionsRepository(db);
    anna = await people.add(name: 'Anna', closeness: Closeness.close);
    ben = await people.add(name: 'Ben', closeness: Closeness.family);
  });
  tearDown(() => db.close());

  test('adds an open intention with a new id', () async {
    final now = DateTime(2026, 11, 16, 9, 30, 12, 345);
    final added = await repo.add(
      personId: anna.id,
      note: 'saw a bouldering video',
      kind: IntentionKind.call,
      now: now,
    );
    expect(added.id, hasLength(36));
    expect(added.state, IntentionState.open);
    expect(added.createdAt, DateTime(2026, 11, 16, 9, 30, 12));
    expect(added.closedAt, isNull);
    expect(await repo.watchForPerson(anna.id).first, [added]);

    final plain = await repo.add(personId: anna.id);
    expect(plain.id, isNot(added.id));
    expect(plain.kind, IntentionKind.write);
    expect(plain.note, '');
  });

  test('keeps an activity icon for a meetup or a game only', () async {
    final meet = await repo.add(
      personId: anna.id,
      kind: IntentionKind.meet,
      activityIcon: 'climber',
    );
    expect(meet.activityIcon, 'climber');
    final call = await repo.add(
      personId: anna.id,
      kind: IntentionKind.call,
      activityIcon: 'climber',
    );
    expect(call.activityIcon, isNull);

    Future<String?> iconOf(String id) async =>
        (await repo.watchForPerson(anna.id).first)
            .firstWhere((i) => i.id == id)
            .activityIcon;
    await repo.update(
      meet.id,
      note: '',
      kind: IntentionKind.game,
      when: const When.none(),
      activityIcon: 'meeple',
    );
    expect(await iconOf(meet.id), 'meeple');
    // Turning it into a call drops the icon.
    await repo.update(
      meet.id,
      note: '',
      kind: IntentionKind.write,
      when: const When.none(),
      activityIcon: 'meeple',
    );
    expect(await iconOf(meet.id), isNull);
  });

  test('stores the enums as their names', () async {
    await repo.add(personId: anna.id, kind: IntentionKind.meet);
    final row = await db
        .customSelect('SELECT kind, state FROM intentions')
        .getSingle();
    expect(row.read<String>('kind'), 'meet');
    expect(row.read<String>('state'), 'open');
  });

  test('refuses an intention for an unknown person', () async {
    await expectLater(repo.add(personId: 'nobody'), throwsA(isA<Exception>()));
  });

  test('orders newest first; open only and per person', () async {
    final t = DateTime(2026, 11, 10, 12);
    final a1 = await repo.add(personId: anna.id, note: 'a1', now: t);
    final b1 = await repo.add(
      personId: ben.id,
      note: 'b1',
      now: t.add(const Duration(hours: 1)),
    );
    final a2 = await repo.add(
      personId: anna.id,
      note: 'a2',
      now: t.add(const Duration(hours: 2)),
    );
    expect(await repo.watchOpen().first, [a2, b1, a1]);
    expect(await repo.watchForPerson(anna.id).first, [a2, a1]);

    await repo.setState(a2.id, IntentionState.done);
    expect((await repo.watchOpen().first).map((i) => i.note), ['b1', 'a1']);
    expect((await repo.watchForPerson(anna.id).first).map((i) => i.note), [
      'a2',
      'a1',
    ]);
  });

  test('setState sets closedAt when leaving open and clears it', () async {
    final added = await repo.add(personId: anna.id, note: 'x');
    final closed = DateTime(2026, 11, 16, 20, 15, 3, 999);
    await repo.setState(added.id, IntentionState.done, now: closed);
    var stored = (await repo.watchForPerson(anna.id).first).single;
    expect(stored.state, IntentionState.done);
    expect(stored.closedAt, DateTime(2026, 11, 16, 20, 15, 3));

    await repo.setState(added.id, IntentionState.dropped, now: closed);
    stored = (await repo.watchForPerson(anna.id).first).single;
    expect(stored.state, IntentionState.dropped);
    expect(stored.closedAt, isNotNull);

    await repo.setState(added.id, IntentionState.open);
    stored = (await repo.watchForPerson(anna.id).first).single;
    expect(stored.state, IntentionState.open);
    expect(stored.closedAt, isNull);
  });

  test('deletes an intention', () async {
    final a = await repo.add(personId: anna.id, note: 'a');
    final b = await repo.add(personId: anna.id, note: 'b');
    await repo.delete(a.id);
    expect((await repo.watchForPerson(anna.id).first).map((i) => i.id), [b.id]);
  });

  test('deleting a person deletes their intentions', () async {
    await repo.add(personId: anna.id, note: 'a');
    final b = await repo.add(personId: ben.id, note: 'b');
    await people.delete(anna.id);
    expect(await repo.watchForPerson(anna.id).first, isEmpty);
    expect(await repo.watchOpen().first, [b]);
  });

  test('replaceAll swaps the whole set', () async {
    await repo.add(personId: anna.id, note: 'old');
    final t = DateTime(2026, 11, 1, 8);
    final next = [
      Intention(
        id: 'i1',
        personId: ben.id,
        note: 'new',
        kind: IntentionKind.call,
        state: IntentionState.open,
        createdAt: t,
      ),
    ];
    await repo.replaceAll(next);
    expect(await repo.watchOpen().first, next);
  });
}
