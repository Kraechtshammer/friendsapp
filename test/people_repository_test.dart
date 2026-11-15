import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/data/database.dart';
import 'package:kept/data/people_repository.dart';
import 'package:kept/domain/person.dart';

void main() {
  late AppDatabase db;
  late PeopleRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = PeopleRepository(db);
  });
  tearDown(() => db.close());

  test('starts empty', () async {
    expect(await repo.watchAll().first, isEmpty);
  });

  test('adds a person with all fields and a new id', () async {
    final now = DateTime(2026, 11, 16, 9);
    final added = await repo.add(
      name: 'Ada Example',
      closeness: Closeness.close,
      contactId: 'c1',
      reconnecting: true,
      rhythmDays: 9,
      mainMessenger: Messenger.telegram,
      phone: '+490000000101',
      telegramUsername: 'demo_ada',
      signalLink: 'https://signal.me/#eu/demo',
      discordUserId: '000011112222333344',
      birthdayMonth: 2,
      birthdayDay: 29,
      notes: 'Note',
      now: now,
    );
    expect(added.id, hasLength(36));
    final stored = await repo.watch(added.id).first;
    expect(stored, added);
    expect(stored!.birthdayYear, isNull);
    expect(stored.closeness, Closeness.close);
    expect(stored.mainMessenger, Messenger.telegram);
    expect(stored.createdAt, now);

    final other = await repo.add(name: 'B', closeness: Closeness.family);
    expect(other.id, isNot(added.id));
    expect(other.reconnecting, isFalse);
    expect(other.notes, '');
    expect(other.mainMessenger, isNull);
  });

  test('stores the enums as their names', () async {
    await repo.add(name: 'A', closeness: Closeness.fewTimesAYear);
    final row = await db
        .customSelect('SELECT closeness, avatar_shape FROM people')
        .getSingle();
    expect(row.read<String>('closeness'), 'fewTimesAYear');
    expect(
      AvatarShape.values.map((s) => s.name),
      contains(row.read<String>('avatar_shape')),
    );
  });

  test('orders by name without regard to case', () async {
    for (final name in ['bea', 'Carl', 'anna', 'Bert']) {
      await repo.add(name: name, closeness: Closeness.nowAndThen);
    }
    final people = await repo.watchAll().first;
    expect(people.map((p) => p.name), ['anna', 'bea', 'Bert', 'Carl']);
  });

  test('consecutive people get different avatars', () async {
    final a = await repo.add(name: 'A', closeness: Closeness.close);
    final b = await repo.add(name: 'B', closeness: Closeness.close);
    final c = await repo.add(name: 'C', closeness: Closeness.close);
    expect(b.avatarShape, isNot(a.avatarShape));
    expect(b.avatarColor, isNot(a.avatarColor));
    expect({
      (a.avatarShape, a.avatarColor),
      (b.avatarShape, b.avatarColor),
      (c.avatarShape, c.avatarColor),
    }, hasLength(3));
  });

  test('updates a person', () async {
    final added = await repo.add(
      name: 'A',
      closeness: Closeness.close,
      phone: '+490000000101',
    );
    await repo.update(
      added.copyWith(
        name: 'Anna',
        closeness: Closeness.family,
        phone: const Value(null),
        avatarColor: AvatarColor.mint,
      ),
    );
    final stored = await repo.watch(added.id).first;
    expect(stored!.name, 'Anna');
    expect(stored.closeness, Closeness.family);
    expect(stored.phone, isNull);
    expect(stored.avatarColor, AvatarColor.mint);
    expect(stored.createdAt, added.createdAt);
  });

  test('deletes a person', () async {
    final a = await repo.add(name: 'A', closeness: Closeness.close);
    final b = await repo.add(name: 'B', closeness: Closeness.close);
    await repo.delete(a.id);
    expect(await repo.watch(a.id).first, isNull);
    expect((await repo.watchAll().first).map((p) => p.id), [b.id]);
  });
}
