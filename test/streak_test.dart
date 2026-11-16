import 'package:flutter_test/flutter_test.dart';
import 'package:kept/data/app_settings.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/contact_event.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/domain/progress.dart';

ContactEvent event(
  String person,
  DateTime at, {
  ContactDirection direction = ContactDirection.byUser,
}) => ContactEvent(
  id: '$person-$at-$direction',
  personId: person,
  at: at,
  kind: ContactKind.wrote,
  direction: direction,
  source: ContactSource.manual,
  createdAt: at,
);

void main() {
  const who = {
    'tom': Closeness.close,
    'ann': Closeness.nowAndThen,
    'mum': Closeness.family,
    'old': Closeness.fewTimesAYear,
  };
  // Wednesday 18 November 2026; its Monday is the 16th.
  final now = DateTime(2026, 11, 18, 12);
  WeekStreak strict(List<ContactEvent> e, [DateTime? at]) =>
      weekStreak(e, who, at ?? now, StreakMode.strict);
  WeekStreak friendly(List<ContactEvent> e, [DateTime? at]) =>
      weekStreak(e, who, at ?? now, StreakMode.friendly);

  group('which weeks count', () {
    test('close friends do not count, family and the others do', () {
      expect(strict([event('tom', now)]).count, 0);
      expect(strict([event('ann', now)]).count, 1);
      expect(strict([event('mum', now)]).count, 1);
      expect(strict([event('old', now)]).count, 1);
      // A close friend and another person in one week: it counts.
      expect(strict([event('tom', now), event('ann', now)]).count, 1);
    });

    test('incoming contact and unknown people do not count', () {
      expect(
        strict([event('ann', now, direction: ContactDirection.byThem)]).count,
        0,
      );
      expect(strict([event('ghost', now)]).count, 0);
      expect(
        strict([event('ann', now, direction: ContactDirection.together)]).count,
        1,
      );
    });

    test('no contact at all: zero, nothing ended', () {
      final r = strict([]);
      expect(r, const WeekStreak(count: 0, longest: 0, thisWeekCounts: false));
      expect(r.ended, isFalse);
    });
  });

  group('strict', () {
    test('consecutive weeks add up, many contacts in a week are one', () {
      final r = strict([
        event('ann', DateTime(2026, 11, 16, 9)),
        event('mum', DateTime(2026, 11, 18, 9)),
        event('ann', DateTime(2026, 11, 9, 9)),
        event('ann', DateTime(2026, 11, 2, 9)),
      ]);
      expect(r, const WeekStreak(count: 3, longest: 3, thisWeekCounts: true));
    });

    test('the running week does not break the run while it is open', () {
      final r = strict([
        event('ann', DateTime(2026, 11, 9, 9)),
        event('ann', DateTime(2026, 11, 2, 9)),
      ]);
      expect(r, const WeekStreak(count: 2, longest: 2, thisWeekCounts: false));
      expect(r.ended, isFalse);
    });

    test('a finished week without a contact ends the run', () {
      // Weeks of 26 Oct and 2 Nov, nothing in the week of 9 Nov.
      final r = strict([
        event('ann', DateTime(2026, 10, 26, 9)),
        event('ann', DateTime(2026, 11, 2, 9)),
      ]);
      expect(r, const WeekStreak(count: 0, longest: 2, thisWeekCounts: false));
      expect(r.ended, isTrue);
    });

    test('a close friend alone does not keep the run going', () {
      final r = strict([
        event('ann', DateTime(2026, 11, 2, 9)),
        event('tom', DateTime(2026, 11, 10, 9)),
      ]);
      expect(r.ended, isTrue);
    });

    test('after the end the next counting week starts at 1', () {
      final r = strict([
        event('ann', DateTime(2026, 10, 26, 9)),
        event('ann', DateTime(2026, 11, 2, 9)),
        event('ann', DateTime(2026, 11, 17, 9)),
      ]);
      expect(r, const WeekStreak(count: 1, longest: 2, thisWeekCounts: true));
    });

    test('the longest run is kept next to a shorter current one', () {
      final r = strict([
        for (var w = 0; w < 5; w++) event('ann', DateTime(2026, 8, 3 + 7 * w)),
        event('ann', DateTime(2026, 11, 9, 9)),
      ]);
      expect(r.count, 1);
      expect(r.longest, 5);
    });

    test('the Sunday night and Monday morning belong to two weeks', () {
      final r = strict([
        event('ann', DateTime(2026, 11, 15, 23, 59)),
        event('ann', DateTime(2026, 11, 16)),
      ]);
      expect(r.count, 2);
    });

    test('a run crosses the year boundary', () {
      // Weeks of 21 Dec, 28 Dec and 4 Jan; 2027-01-05 is in the third.
      final r = strict([
        event('ann', DateTime(2026, 12, 21, 9)),
        event('ann', DateTime(2026, 12, 28, 9)),
        event('ann', DateTime(2027, 1, 1, 9)),
        event('ann', DateTime(2027, 1, 5, 9)),
      ], DateTime(2027, 1, 6));
      expect(r, const WeekStreak(count: 3, longest: 3, thisWeekCounts: true));
    });

    test('a running week at the start of the year still counts the last', () {
      final r = strict([
        event('ann', DateTime(2026, 12, 29, 9)),
      ], DateTime(2027, 1, 4, 8));
      expect(r.count, 1);
      expect(r.ended, isFalse);
      // A week later with nothing in between: ended.
      expect(
        strict([
          event('ann', DateTime(2026, 12, 29, 9)),
        ], DateTime(2027, 1, 11, 8)).ended,
        isTrue,
      );
    });
  });

  group('friendly', () {
    test('counts all counting weeks and never ends', () {
      final r = friendly([
        event('ann', DateTime(2026, 10, 26, 9)),
        event('ann', DateTime(2026, 11, 2, 9)),
        event('mum', DateTime(2026, 11, 2, 12)),
        event('tom', DateTime(2026, 11, 10, 9)),
      ]);
      expect(r, const WeekStreak(count: 2, longest: 2, thisWeekCounts: false));
      expect(r.ended, isFalse);
    });

    test('the running week is counted once it has a contact', () {
      expect(friendly([event('ann', now)]).thisWeekCounts, isTrue);
    });
  });

  group('settings', () {
    test('the mode is stored by name; strict is the start value', () {
      expect(const AppSettings().streakMode, StreakMode.strict);
      final s = const AppSettings().copyWith(streakMode: StreakMode.friendly);
      expect(s.toMap()['streakMode'], 'friendly');
      expect(
        AppSettings.fromMap({'streakMode': 'friendly'}).streakMode,
        StreakMode.friendly,
      );
      expect(
        AppSettings.fromMap({'streakMode': 'x'}).streakMode,
        StreakMode.strict,
      );
    });

    test(
      'a weight at its start value is not stored, so start values follow',
      () {
        final s = const AppSettings();
        expect(s.toMap()['stampFamily'], isNull);
        expect(s.toMap()['stampGameClose'], isNull);
        expect(AppSettings.fromMap({}).stampWeights.family, 2);
        expect(AppSettings.fromMap({}).stampWeights.gameCloseMultiplier, 1);
        // An own value is kept.
        expect(
          AppSettings.fromMap({'stampFamily': '1'}).stampWeights.family,
          1,
        );
        final own = s.copyWith(
          stampWeights: s.stampWeights.copyWith(
            family: 3,
            gameCloseMultiplier: 2,
          ),
        );
        expect(own.toMap()['stampFamily'], '3');
        expect(own.toMap()['stampGameClose'], '2');
      },
    );
  });
}
