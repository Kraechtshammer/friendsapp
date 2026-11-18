import 'package:flutter_test/flutter_test.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/contact_event.dart';
import 'package:kept/domain/intention.dart';
import 'package:kept/domain/person_timeline.dart';

import 'pick_order_test.dart' show person;
import 'plans_test.dart' show plan;

ContactEvent event(
  String id,
  DateTime at,
  ContactKind kind,
  ContactDirection direction, {
  String personId = 'tom',
  String? activity,
  String? note,
}) => ContactEvent(
  id: id,
  personId: personId,
  at: at,
  kind: kind,
  direction: direction,
  source: ContactSource.manual,
  activity: activity,
  note: note,
  createdAt: at,
);

void main() {
  final now = DateTime(2026, 11, 16, 14); // Monday
  Person tom({int? month, int? day, int? year, DateTime? added}) => person(
    'tom',
    month: month,
    day: day,
    year: year,
  ).copyWith(createdAt: added ?? DateTime(2026, 2, 10));

  String describe(TimelineEntry e) => switch (e) {
    UpcomingBirthday() => 'ub',
    UpcomingThought(:final intention) => 'ut:${intention.id}',
    UpcomingPlan(:final intention) => 'up:${intention.id}',
    ContactEntry(:final event) => 'c:${event.id}',
    TextingDay(:final events) => 't:${events.map((e) => e.id).join(',')}',
    PastBirthday(:final congratulated) => congratulated ? 'pb+' : 'pb',
    OwnBirthdayWish() => 'own',
    AddedEntry() => 'added',
  };
  List<String> up(PersonTimeline t) => t.upcoming.map(describe).toList();
  List<String> hist(PersonTimeline t) => t.history.map(describe).toList();

  group('upcoming', () {
    test('farthest first, the soonest nearest the Today mark', () {
      final t = personTimeline(tom(month: 12, day: 3, year: 1990), [], [
        plan('later', 'tom', date: DateTime(2026, 11, 25)),
        plan('soon', 'tom', date: DateTime(2026, 11, 20, 11)),
        plan('undated', 'tom', horizon: Horizon.soon),
      ], now);
      expect(up(t), ['up:undated', 'ub', 'ut:later', 'ut:soon']);
      expect((t.upcoming[1] as UpcomingBirthday).age, 36);
      expect(
        (t.upcoming[3] as UpcomingThought).time,
        DateTime(2026, 11, 20, 11),
      );
      expect((t.upcoming[2] as UpcomingThought).time, isNull);
    });

    test('skips passed, done, dropped, plain and other people', () {
      final t = personTimeline(tom(), [], [
        plan('passed', 'tom', date: DateTime(2026, 11, 15, 10)),
        plan(
          'done',
          'tom',
          date: DateTime(2026, 11, 20),
          state: IntentionState.done,
        ),
        plan(
          'dropped',
          'tom',
          date: DateTime(2026, 11, 20),
          state: IntentionState.dropped,
        ),
        plan('plain', 'tom'),
        plan('other', 'anna', date: DateTime(2026, 11, 20)),
      ], now);
      expect(up(t), isEmpty);
    });

    test('a birthday today is upcoming, not history', () {
      final t = personTimeline(tom(month: 11, day: 16), [], [], now);
      expect(up(t), ['ub']);
      expect(hist(t), ['added']);
    });

    test('inside a day the birthday is nearest the mark', () {
      final t = personTimeline(tom(month: 11, day: 20), [], [
        plan('x', 'tom', date: DateTime(2026, 11, 20, 9)),
      ], now);
      expect(up(t), ['ut:x', 'ub']);
    });
  });

  group('history', () {
    test('newest first, ends with Added', () {
      final t = personTimeline(
        tom(),
        [
          event(
            'a',
            DateTime(2026, 10, 12, 15),
            ContactKind.met,
            ContactDirection.together,
            activity: 'bouldering',
          ),
          event(
            'b',
            DateTime(2026, 11, 2, 20),
            ContactKind.wrote,
            ContactDirection.byUser,
          ),
          event(
            'c',
            DateTime(2026, 10, 28, 9),
            ContactKind.wrote,
            ContactDirection.byThem,
          ),
          event(
            'd',
            DateTime(2026, 10, 28, 18),
            ContactKind.called,
            ContactDirection.byUser,
          ),
          event(
            'other',
            DateTime(2026, 11, 3),
            ContactKind.wrote,
            ContactDirection.byUser,
            personId: 'anna',
          ),
        ],
        [],
        now,
      );
      expect(hist(t), ['c:b', 'c:d', 'c:c', 'c:a', 'added']);
      expect(
        (t.history.first as ContactEntry).event.direction,
        ContactDirection.byUser,
      );
      expect((t.history.last as AddedEntry).day, DateTime(2026, 2, 10));
    });

    test('Added stays last even if an event is older', () {
      final t = personTimeline(
        tom(added: DateTime(2026, 6, 1)),
        [
          event(
            'old',
            DateTime(2026, 3, 1, 12),
            ContactKind.met,
            ContactDirection.together,
          ),
        ],
        [],
        now,
      );
      expect(hist(t), ['c:old', 'added']);
    });
  });

  group('their birthday', () {
    test('always there; "congratulated" only when the user did', () {
      final t = personTimeline(
        tom(month: 3, day: 3, year: 1990, added: DateTime(2024, 5, 1)),
        [
          event(
            'w',
            DateTime(2025, 3, 3, 21),
            ContactKind.birthdayWish,
            ContactDirection.byUser,
          ),
        ],
        [],
        now,
      );
      // 2025 congratulated, 2026 not, 2025 is after the start (May 2024).
      expect(hist(t), ['pb', 'pb+', 'added']);
      expect((t.history[0] as PastBirthday).day, DateTime(2026, 3, 3));
      expect((t.history[0] as PastBirthday).age, 36);
      expect((t.history[1] as PastBirthday).age, 35);
      // Next birthday is upcoming.
      expect(up(t), ['ub']);
    });

    test('only since the first entry; not before Added', () {
      final t = personTimeline(
        tom(month: 3, day: 3, added: DateTime(2026, 3, 4)),
        [],
        [],
        now,
      );
      expect(hist(t), ['added']);
      // On the day itself it counts.
      final t2 = personTimeline(
        tom(month: 3, day: 3, added: DateTime(2026, 3, 3, 18)),
        [],
        [],
        now,
      );
      expect(hist(t2), ['pb', 'added']);
    });

    test('an earlier event moves the start back', () {
      final t = personTimeline(
        tom(month: 3, day: 3, added: DateTime(2026, 6, 1)),
        [
          event(
            'e',
            DateTime(2025, 12, 1, 12),
            ContactKind.wrote,
            ContactDirection.byThem,
          ),
        ],
        [],
        now,
      );
      expect(hist(t), ['pb', 'c:e', 'added']);
    });

    test('29 February counts on 28 February in other years', () {
      final t = personTimeline(
        tom(month: 2, day: 29, added: DateTime(2024, 1, 1)),
        [],
        [],
        now,
      );
      expect(hist(t), ['pb', 'pb', 'pb', 'added']);
      expect(t.history.take(3).map((e) => e.day), [
        DateTime(2026, 2, 28),
        DateTime(2025, 2, 28),
        DateTime(2024, 2, 29),
      ]);
      // Upcoming in 2027, still 28 February.
      expect(t.upcoming.single.day, DateTime(2027, 2, 28));
    });

    test('across the year boundary', () {
      final t = personTimeline(
        tom(month: 1, day: 1, added: DateTime(2025, 12, 20)),
        [],
        [],
        DateTime(2026, 12, 30, 9),
      );
      expect(hist(t), ['pb', 'added']);
      expect(t.history.first.day, DateTime(2026, 1, 1));
      expect(t.upcoming.single.day, DateTime(2027, 1, 1));
    });

    test('a wish on another day gets its own birthday entry', () {
      final t = personTimeline(
        tom(month: 3, day: 3, added: DateTime(2026, 3, 10)),
        [
          event(
            'w',
            DateTime(2026, 5, 5, 10),
            ContactKind.birthdayWish,
            ContactDirection.byUser,
          ),
        ],
        [],
        now,
      );
      expect(hist(t), ['pb+', 'added']);
    });
  });

  group('the user\'s birthday', () {
    test('an entry only where this person congratulated', () {
      final t = personTimeline(
        tom(),
        [
          event(
            'w1',
            DateTime(2026, 6, 9, 8),
            ContactKind.birthdayWish,
            ContactDirection.byThem,
          ),
          event(
            'w2',
            DateTime(2026, 6, 9, 8),
            ContactKind.birthdayWish,
            ContactDirection.byThem,
            personId: 'anna',
          ),
        ],
        [],
        now,
      );
      expect(hist(t), ['own', 'added']);
      expect(t.history.first.day, DateTime(2026, 6, 9));
    });

    test('is not listed as a contact and wishes by the user are folded', () {
      final t = personTimeline(
        tom(month: 6, day: 9, added: DateTime(2026, 1, 1)),
        [
          event(
            'mine',
            DateTime(2026, 6, 9, 20),
            ContactKind.birthdayWish,
            ContactDirection.byUser,
          ),
          event(
            'theirs',
            DateTime(2026, 6, 9, 8),
            ContactKind.birthdayWish,
            ContactDirection.byThem,
          ),
          event(
            'msg',
            DateTime(2026, 6, 9, 12),
            ContactKind.called,
            ContactDirection.byThem,
          ),
        ],
        [],
        now,
      );
      // On one day: contacts, then the birthdays.
      expect(hist(t).where((d) => d == 'pb+'), hasLength(1));
      expect(hist(t).where((d) => d == 'own'), hasLength(1));
      expect(hist(t).first, 'c:msg');
      expect(hist(t).last, 'added');
    });
  });

  test('year boundary: an event on 31 December is before 1 January', () {
    final t = personTimeline(
      tom(),
      [
        event(
          'a',
          DateTime(2025, 12, 31, 23, 50),
          ContactKind.wrote,
          ContactDirection.byUser,
        ),
        event(
          'b',
          DateTime(2026, 1, 1, 0, 10),
          ContactKind.wrote,
          ContactDirection.byThem,
        ),
      ],
      [],
      now,
    );
    expect(hist(t), ['c:b', 'c:a', 'added']);
    expect(t.history[0].day, DateTime(2026, 1, 1));
    expect(t.history[1].day, DateTime(2025, 12, 31));
  });

  test('several messages on one day are one entry, newest first', () {
    final t = personTimeline(
      tom(),
      [
        event(
          'a',
          DateTime(2026, 11, 15, 9),
          ContactKind.wrote,
          ContactDirection.byUser,
        ),
        event(
          'b',
          DateTime(2026, 11, 15, 21),
          ContactKind.wrote,
          ContactDirection.byThem,
        ),
        event(
          'c',
          DateTime(2026, 11, 14, 9),
          ContactKind.wrote,
          ContactDirection.byUser,
        ),
        event(
          'd',
          DateTime(2026, 11, 15, 12),
          ContactKind.called,
          ContactDirection.byThem,
        ),
      ],
      [],
      now,
    );
    expect(hist(t), ['t:b,a', 'c:d', 'c:c', 'added']);
    final day = t.history.first as TextingDay;
    expect(day.byUser && day.byThem, isTrue);
  });

  test('messages on a day the user congratulated fold into the birthday', () {
    final t = personTimeline(
      tom(month: 11, day: 15),
      [
        event(
          'w',
          DateTime(2026, 11, 15, 9),
          ContactKind.birthdayWish,
          ContactDirection.byUser,
        ),
        event(
          'a',
          DateTime(2026, 11, 15, 9),
          ContactKind.wrote,
          ContactDirection.byUser,
        ),
        event(
          'b',
          DateTime(2026, 11, 15, 10),
          ContactKind.wrote,
          ContactDirection.byThem,
        ),
      ],
      [],
      now,
    );
    expect(hist(t), ['pb+', 'added']);
    expect((t.history.first as PastBirthday).texted, isTrue);
  });
}
