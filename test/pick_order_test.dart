import 'package:flutter_test/flutter_test.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/intention.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/domain/pick_order.dart';

Person person(String id, {int? month, int? day, int? year}) => Person(
  id: id,
  name: id,
  closeness: Closeness.close,
  avatarShape: AvatarShape.scallop,
  avatarColor: AvatarColor.mint,
  reconnecting: false,
  notes: '',
  createdAt: DateTime(2026),
  birthdayMonth: month,
  birthdayDay: day,
  birthdayYear: year,
);

Intention thought(
  String id,
  String personId,
  int day, {
  IntentionState state = IntentionState.open,
}) => Intention(
  id: id,
  personId: personId,
  note: id,
  kind: IntentionKind.write,
  state: state,
  createdAt: DateTime(2026, 11, day),
);

void main() {
  final people = [person('tom'), person('anna'), person('jonas')];

  test('oldest first, one per person', () {
    final picks = intentionPicks(people, [
      thought('t-new', 'tom', 9),
      thought('a1', 'anna', 5),
      thought('t-old', 'tom', 2),
      thought('j1', 'jonas', 7),
    ]);
    expect(picks.map((p) => p.intention.id), ['t-old', 'a1', 'j1']);
    expect(picks.map((p) => p.person.id), ['tom', 'anna', 'jonas']);
  });

  test('closed thoughts and unknown people are left out', () {
    final picks = intentionPicks(people, [
      thought('d', 'tom', 1, state: IntentionState.done),
      thought('x', 'nobody', 2),
      thought('a', 'anna', 3),
    ]);
    expect(picks.map((p) => p.intention.id), ['a']);
    expect(intentionPicks(people, const []), isEmpty);
  });

  test('a tie goes by id', () {
    final picks = intentionPicks(people, [
      thought('b', 'anna', 4),
      thought('a', 'tom', 4),
    ]);
    expect(picks.map((p) => p.intention.id), ['a', 'b']);
  });

  group('with birthdays', () {
    final today = DateTime(2026, 11, 16);
    final lena = person('lena', month: 11, day: 16, year: 1994);
    final kai = person('kai', month: 11, day: 16);
    final all = [lena, ...people, kai];
    final thoughts = [
      thought('t1', 'tom', 2),
      thought('l1', 'lena', 1),
      thought('a1', 'anna', 3),
    ];

    test('birthdays first, with the age; one pick per person', () {
      final picks = tonightsPicks(
        people: all,
        intentions: thoughts,
        today: today,
        congratulated: const {},
      );
      expect(picks.map((p) => (p.kind, p.person.id)), [
        (PickKind.birthday, 'lena'),
        (PickKind.birthday, 'kai'),
        (PickKind.intention, 'tom'),
        (PickKind.intention, 'anna'),
      ]);
      expect((picks[0] as BirthdayPick).age, 32);
      expect((picks[1] as BirthdayPick).age, isNull);
    });

    test('congratulated: the birthday pick is gone, the thought is back', () {
      final picks = tonightsPicks(
        people: all,
        intentions: thoughts,
        today: today,
        congratulated: const {'lena'},
      );
      expect(picks.map((p) => (p.kind, p.person.id)), [
        (PickKind.birthday, 'kai'),
        (PickKind.intention, 'lena'),
        (PickKind.intention, 'tom'),
        (PickKind.intention, 'anna'),
      ]);
    });

    test('another day: no birthday picks', () {
      final picks = tonightsPicks(
        people: all,
        intentions: thoughts,
        today: DateTime(2026, 11, 17),
        congratulated: const {},
      );
      expect(picks.every((p) => p.kind == PickKind.intention), isTrue);
    });
  });
}
