import 'package:flutter_test/flutter_test.dart';
import 'package:kept/domain/intention.dart';
import 'package:kept/domain/timeline.dart';

import 'pick_order_test.dart' show person;
import 'plans_test.dart' show plan;

void main() {
  final now = DateTime(2026, 11, 16, 14); // Monday

  List<String> ids(List<UpcomingEntry> es) => [
    for (final e in es)
      switch (e) {
        BirthdayEntry(:final person) => 'b:${person.id}',
        ThoughtEntry(:final intention) => 't:${intention.id}',
      },
  ];

  test('birthdays and dated thoughts, soonest first', () {
    final people = [
      person('anna', month: 11, day: 19),
      person('tom'),
      person('mia', month: 12, day: 6, year: 1990),
    ];
    final entries = upcomingEntries(people, [
      plan('b-boulder', 'tom', date: DateTime(2026, 11, 21, 11)),
      plan('call', 'tom', date: DateTime(2026, 11, 25)),
      plan('plain', 'tom'),
      plan('soon', 'tom', horizon: Horizon.soon),
    ], now);
    expect(ids(entries), ['b:anna', 't:b-boulder', 't:call', 'b:mia']);
    expect((entries[0] as BirthdayEntry).age, isNull);
    expect((entries[3] as BirthdayEntry).age, 36);
    expect(entries[1].time, DateTime(2026, 11, 21, 11));
    expect(entries[2].time, isNull);
    expect(entries[2].day, DateTime(2026, 11, 25));
  });

  test('inside a day: birthday, then no time, then by time', () {
    final people = [person('anna', month: 11, day: 20), person('tom')];
    final day = DateTime(2026, 11, 20);
    final entries = upcomingEntries(people, [
      plan('late', 'tom', date: DateTime(2026, 11, 20, 20)),
      plan('early', 'tom', date: DateTime(2026, 11, 20, 8)),
      plan('allday', 'tom', date: day),
    ], now);
    expect(ids(entries), ['b:anna', 't:allday', 't:early', 't:late']);
  });

  test('past dates never appear', () {
    final people = [person('tom')];
    final entries = upcomingEntries(people, [
      plan('yesterday', 'tom', date: DateTime(2026, 11, 15, 12)),
      // Today at 09:00 is more than three hours ago: "Did it happen?".
      plan('this-morning', 'tom', date: DateTime(2026, 11, 16, 9)),
      // Today, a day without a time: still on, until the day is over.
      plan('today', 'tom', date: DateTime(2026, 11, 16)),
      plan('tonight', 'tom', date: DateTime(2026, 11, 16, 19)),
      plan(
        'done',
        'tom',
        date: DateTime(2026, 11, 20),
        state: IntentionState.done,
      ),
      plan('stranger', 'nobody', date: DateTime(2026, 11, 20)),
    ], now);
    expect(ids(entries), ['t:today', 't:tonight']);
  });

  group('the 12 month window', () {
    final people = [person('tom')];

    test('ends on the same date next year, not included', () {
      expect(upcomingEnd(now), DateTime(2027, 11, 16));
      final entries = upcomingEntries(people, [
        plan('last', 'tom', date: DateTime(2027, 11, 15, 10)),
        plan('over', 'tom', date: DateTime(2027, 11, 16)),
        plan('far', 'tom', date: DateTime(2028, 1, 1)),
      ], now);
      expect(ids(entries), ['t:last']);
    });

    test('a birthday today is listed once, today', () {
      final entries = upcomingEntries(
        [person('lena', month: 11, day: 16, year: 1994)],
        const [],
        now,
      );
      expect(entries, hasLength(1));
      expect(entries.single.day, DateTime(2026, 11, 16));
      expect((entries.single as BirthdayEntry).age, 32);
    });

    test('birthdays wrap the year and come after this year\'s', () {
      final entries = upcomingEntries(
        [
          person('jan', month: 1, day: 5, year: 2000),
          person('dec', month: 12, day: 24),
          person('earlier', month: 3, day: 1),
          person('yesterday', month: 11, day: 15),
        ],
        const [],
        now,
      );
      expect(ids(entries), ['b:dec', 'b:jan', 'b:earlier', 'b:yesterday']);
      expect(entries[1].day, DateTime(2027, 1, 5));
      expect((entries[1] as BirthdayEntry).age, 27);
      // Yesterday's birthday comes next year, still inside the window.
      expect(entries.last.day, DateTime(2027, 11, 15));
    });
  });

  group('29 February', () {
    final leap = person('leap', month: 2, day: 29, year: 2000);

    test('counts on 28 February in a year without it', () {
      final entries = upcomingEntries([leap], const [], now);
      expect(entries.single.day, DateTime(2027, 2, 28));
      expect((entries.single as BirthdayEntry).age, 27);
    });

    test('counts on 29 February in a leap year', () {
      final entries = upcomingEntries([leap], const [], DateTime(2027, 12, 1));
      expect(entries.single.day, DateTime(2028, 2, 29));
      expect((entries.single as BirthdayEntry).age, 28);
    });

    test('from 29 February itself the window ends on 1 March', () {
      final onLeapDay = DateTime(2028, 2, 29, 9);
      expect(upcomingEnd(onLeapDay), DateTime(2029, 3, 1));
      final entries = upcomingEntries([leap], const [], onLeapDay);
      expect(entries.single.day, DateTime(2028, 2, 29));
    });
  });

  group('groups', () {
    final people = [
      person('a', month: 11, day: 16),
      person('b', month: 11, day: 22),
      person('c', month: 11, day: 25),
      person('d', month: 11, day: 30),
      person('e', month: 12, day: 14),
      person('f', month: 1, day: 3),
    ];

    test('this week, next week, then months (Monday to Sunday)', () {
      final groups = groupUpcoming(upcomingEntries(people, const [], now), now);
      expect(
        [for (final g in groups) '${g.kind.name} ${g.month} ${ids(g.entries)}'],
        [
          'thisWeek null [b:a, b:b]',
          'nextWeek null [b:c]',
          // 30 November is after next week (23 to 29), so it is "November".
          'month 2026-11-01 00:00:00.000 [b:d]',
          'month 2026-12-01 00:00:00.000 [b:e]',
          'month 2027-01-01 00:00:00.000 [b:f]',
        ],
      );
    });

    test('on a Sunday this week is just today', () {
      final sunday = DateTime(2026, 11, 22, 10);
      final groups = groupUpcoming(
        upcomingEntries(people, const [], sunday),
        sunday,
      );
      expect(groups.first.kind, UpcomingGroupKind.thisWeek);
      expect(ids(groups.first.entries), ['b:b']);
      expect(groups[1].kind, UpcomingGroupKind.nextWeek);
      expect(ids(groups[1].entries), ['b:c']);
      expect(groups[2].month, DateTime(2026, 11));
    });

    test('nothing gives no groups', () {
      expect(groupUpcoming(const [], now), isEmpty);
    });
  });
}
