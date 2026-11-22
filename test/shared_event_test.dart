import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/contact_event.dart';
import 'package:kept/domain/shared_event.dart';

import 'person_timeline_test.dart' show event;

void main() {
  test('sharedWith lists the other people of a shared event', () {
    ContactEvent row(String id, String person, String? shared) => event(
      id,
      DateTime(2026, 11, 12),
      ContactKind.gamed,
      ContactDirection.together,
      personId: person,
    ).copyWith(sharedId: Value(shared));
    final a = row('a', 'tom', 's');
    final all = [
      a,
      row('b', 'anna', 's'),
      row('c', 'ben', 's'),
      row('d', 'x', 't'),
    ];
    expect(sharedWith(all, a), ['anna', 'ben']);
    expect(sharedWith(all, row('e', 'tom', null)), isEmpty);
  });

  test('joinNames', () {
    String and(String rest, String last) => '$rest and $last';
    expect(joinNames([], and), '');
    expect(joinNames(['Franz'], and), 'Franz');
    expect(joinNames(['Franz', 'Lucy'], and), 'Franz and Lucy');
    expect(joinNames(['Franz', 'Lucy', 'Tom'], and), 'Franz, Lucy and Tom');
  });
}
