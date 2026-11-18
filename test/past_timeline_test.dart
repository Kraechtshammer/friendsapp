import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/contact_event.dart';
import 'package:kept/domain/past_timeline.dart';

import 'person_timeline_test.dart' show event;
import 'pick_order_test.dart' show person;

void main() {
  final now = DateTime(2026, 11, 18, 14); // Wednesday
  Person added(Person p, DateTime at) => p.copyWith(createdAt: at);

  String describe(PastEntry e) => switch (e) {
    PastContact(:final event) => 'c:${event.id}',
    PastPersonBirthday(:final person, :final congratulated) =>
      'b:${person.id}${congratulated ? '+' : ''}',
    PastOwnBirthday(:final from) => 'own:${from.map((p) => p.id).join(',')}',
    PastTexting(:final people) => 'w:${people.map((p) => p.id).join(',')}',
  };

  test('contacts newest first, messages one line per day', () {
    final people = [person('tom'), person('anna')];
    final entries = pastEntries(people, [
      event(
        'w',
        DateTime(2026, 11, 17, 9),
        ContactKind.wrote,
        ContactDirection.byUser,
      ),
      event(
        'c',
        DateTime(2026, 11, 17, 10),
        ContactKind.called,
        ContactDirection.byThem,
      ),
      event(
        'm',
        DateTime(2026, 11, 10, 19),
        ContactKind.met,
        ContactDirection.together,
        personId: 'anna',
      ),
      event(
        'g',
        DateTime(2026, 11, 18, 12),
        ContactKind.gamed,
        ContactDirection.together,
      ),
      event(
        'x',
        DateTime(2026, 11, 1),
        ContactKind.met,
        ContactDirection.together,
        personId: 'gone',
      ),
    ], now);
    expect(entries.map(describe), ['c:g', 'c:c', 'w:tom', 'c:m']);
  });

  test('a shared couple contact is one entry', () {
    final people = [person('tom'), person('anna')];
    final a = event(
      'a',
      DateTime(2026, 11, 12),
      ContactKind.met,
      ContactDirection.together,
    ).copyWith(sharedId: const Value('s'));
    final b = event(
      'b',
      DateTime(2026, 11, 12),
      ContactKind.met,
      ContactDirection.together,
      personId: 'anna',
    ).copyWith(sharedId: const Value('s'));
    expect(pastEntries(people, [a, b], now).map(describe), ['c:a']);
  });

  test('birthdays since the person was added, marked when congratulated', () {
    final people = [
      added(person('tom', month: 3, day: 4, year: 1990), DateTime(2025, 1, 1)),
      added(person('anna', month: 11, day: 18), DateTime(2025, 1, 1)),
    ];
    final entries = pastEntries(people, [
      event(
        'w',
        DateTime(2026, 3, 4, 9),
        ContactKind.birthdayWish,
        ContactDirection.byUser,
      ),
    ], now);
    // Anna's birthday today belongs to the coming half.
    expect(entries.map(describe), ['b:tom+', 'b:anna', 'b:tom']);
    expect((entries.first as PastPersonBirthday).age, 36);
  });

  test("the user's own birthday lists who congratulated", () {
    final people = [person('tom'), person('anna')];
    final entries = pastEntries(people, [
      event(
        't',
        DateTime(2026, 6, 1, 9),
        ContactKind.birthdayWish,
        ContactDirection.byThem,
      ),
      event(
        'a',
        DateTime(2026, 6, 1, 20),
        ContactKind.birthdayWish,
        ContactDirection.byThem,
        personId: 'anna',
      ),
    ], now);
    expect(entries.map(describe), ['own:anna,tom']);
    expect(entries.first.day, DateTime(2026, 6, 1));
  });

  test('groups: today, earlier this week, last week, months', () {
    final people = [person('tom')];
    final entries = pastEntries(people, [
      for (final (id, at) in [
        ('today', DateTime(2026, 11, 18, 9)),
        ('mon', DateTime(2026, 11, 16)),
        ('lastweek', DateTime(2026, 11, 10)),
        ('nov', DateTime(2026, 11, 3)),
        ('oct', DateTime(2026, 10, 20)),
      ])
        event(id, at, ContactKind.called, ContactDirection.byUser),
    ], now);
    final groups = groupPast(entries, now);
    expect(groups.map((g) => g.kind), [
      PastGroupKind.today,
      PastGroupKind.earlierThisWeek,
      PastGroupKind.lastWeek,
      PastGroupKind.month,
      PastGroupKind.month,
    ]);
    expect(groups[3].month, DateTime(2026, 11));
    expect(groups[4].month, DateTime(2026, 10));
  });

  test('messages with several people on one day are one line', () {
    final people = [person('tom'), person('anna'), person('mia')];
    final entries = pastEntries(people, [
      for (final (id, who, dir) in [
        ('1', 'tom', ContactDirection.byUser),
        ('2', 'tom', ContactDirection.byThem),
        ('3', 'mia', ContactDirection.byThem),
        ('4', 'anna', ContactDirection.byUser),
      ])
        event(
          id,
          DateTime(2026, 11, 17, 8 + int.parse(id)),
          ContactKind.wrote,
          dir,
          personId: who,
        ),
    ], now);
    expect(entries.map(describe), ['w:anna,mia,tom']);
  });
}
