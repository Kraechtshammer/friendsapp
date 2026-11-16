import 'package:flutter_test/flutter_test.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/intention.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/domain/pick_order.dart';

Person person(String id) => Person(
  id: id,
  name: id,
  closeness: Closeness.close,
  avatarShape: AvatarShape.scallop,
  avatarColor: AvatarColor.mint,
  reconnecting: false,
  notes: '',
  createdAt: DateTime(2026),
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
}
