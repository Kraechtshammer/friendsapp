import 'package:flutter_test/flutter_test.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/intention.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/domain/recent_people.dart';

void main() {
  Person person(String id, String name, DateTime created) => Person(
    id: id,
    name: name,
    closeness: Closeness.close,
    reconnecting: false,
    avatarShape: AvatarShape.leaf,
    avatarColor: AvatarColor.sky,
    notes: '',
    createdAt: created,
  );
  Intention intention(String personId, DateTime created) => Intention(
    id: '$personId-${created.millisecondsSinceEpoch}',
    personId: personId,
    note: '',
    kind: IntentionKind.write,
    state: IntentionState.done,
    createdAt: created,
  );
  DateTime d(int day) => DateTime(2026, 11, day);

  final ann = person('a', 'Ann', d(1));
  final bob = person('b', 'Bob', d(2));
  final cid = person('c', 'Cid', d(3));
  final dan = person('d', 'Dan', d(3));
  final eve = person('e', 'eve', d(4));
  final all = [ann, bob, cid, dan, eve];

  test('without intentions: newest added first, ties by name', () {
    expect(recentPeople(all, const []), [eve, cid, dan, bob]);
  });

  test('people with intentions first, by their latest one', () {
    final intentions = [
      intention('a', d(10)),
      intention('b', d(5)),
      intention('b', d(12)),
    ];
    expect(recentPeople(all, intentions), [bob, ann, eve, cid]);
  });

  test('equal latest intentions go by name', () {
    final intentions = [intention('d', d(10)), intention('c', d(10))];
    expect(recentPeople(all, intentions, limit: 3), [cid, dan, eve]);
  });

  test('respects the limit and short lists', () {
    expect(recentPeople(all, const [], limit: 2), [eve, cid]);
    expect(recentPeople([ann], [intention('a', d(9))]), [ann]);
    expect(recentPeople(const [], [intention('x', d(9))]), isEmpty);
  });
}
