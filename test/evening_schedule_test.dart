import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/debouncer.dart';
import 'package:kept/domain/birthday_notifications.dart';
import 'package:kept/domain/evening_question.dart';
import 'package:kept/domain/evening_reason.dart';

import 'evening_reason_test.dart' show texts;
import 'fake_notifications.dart';
import 'owed_reply_test.dart' show event, person;

void main() {
  // Monday 16 November 2026, 14:00; the question comes at 19:00.
  final now = DateTime(2026, 11, 16, 14);
  const minute = 19 * 60;

  EveningPlan plan({
    DateTime? at,
    List<int> weekdays = const [1, 2, 3, 4, 5, 6, 7],
    EveningInputs inputs = const EveningInputs(),
  }) {
    final t = at ?? now;
    return EveningPlan(
      weekdays: weekdays,
      minute: minute,
      title: 'general',
      yes: 'Yes',
      notToday: 'Not today',
      channelName: 'Evening question',
      start: DateTime(t.year, t.month, t.day),
      days: eveningDays(
        now: t,
        weekdays: weekdays,
        minute: minute,
        inputs: inputs,
        texts: texts,
        nameOf: (p) => p.name,
      ),
    );
  }

  /// The days (local midnight) on which [pending] would show something
  /// between [from] and [to], one entry per notification.
  List<DateTime> shownDays(
    Iterable<EveningAlarm> pending,
    DateTime from,
    DateTime to,
  ) {
    final result = <DateTime>[];
    for (final a in pending) {
      for (var k = 0; ; k++) {
        if (k > 0 && !a.weekly) break;
        final at = DateTime(
          a.at.year,
          a.at.month,
          a.at.day + 7 * k,
          a.at.hour,
          a.at.minute,
        );
        if (at.isAfter(to)) break;
        if (at.isAfter(from)) result.add(DateTime(at.year, at.month, at.day));
      }
    }
    return result..sort();
  }

  group('ids', () {
    test('weekly ones keep 101 to 107', () {
      expect(
        [for (var d = 1; d <= 7; d++) eveningWeeklyId(d)],
        [101, 102, 103, 104, 105, 106, 107],
      );
    });

    test('one per date, stable, apart from the weekly and birthday ids', () {
      final a = eveningDayId(DateTime(2026, 11, 16, 19));
      expect(a, eveningDayId(DateTime(2026, 11, 16)));
      expect(eveningDayId(DateTime(2026, 11, 17)), a + 1);
      // Across the change from summer time and a year end.
      expect(
        eveningDayId(DateTime(2026, 10, 26)),
        eveningDayId(DateTime(2026, 10, 25)) + 1,
      );
      expect(
        eveningDayId(DateTime(2027, 1, 1)),
        eveningDayId(DateTime(2026, 12, 31)) + 1,
      );
      expect(isEveningDayId(a), isTrue);
      expect(isEveningWeeklyId(a), isFalse);
      expect(isBirthdayNotificationId(a), isFalse);
      expect(isEveningDayId(101), isFalse);
      expect(isEveningDayId(birthdayNotificationId('x', late: true)), isFalse);
      expect(isEveningDayId(eveningDayId(DateTime(2100, 12, 31))), isTrue);
    });
  });

  group('eveningAlarms', () {
    test('21 one-off days, then the weekly ones', () {
      final alarms = eveningAlarms(plan());
      expect(alarms, hasLength(28));
      final weekly = alarms.where((a) => a.weekly).toList();
      final once = alarms.where((a) => !a.weekly).toList();
      expect(once.first.at, DateTime(2026, 11, 16, 19));
      expect(once.last.at, DateTime(2026, 12, 6, 19));
      expect(once.first.id, eveningDayId(DateTime(2026, 11, 16)));
      expect(once.every((a) => a.title == 'general'), isTrue);
      expect(weekly.map((a) => a.at), [
        for (var d = 7; d <= 13; d++) DateTime(2026, 12, d, 19),
      ]);
      expect(weekly.map((a) => a.id), [101, 102, 103, 104, 105, 106, 107]);
      expect(weekly.every((a) => a.title == 'general'), isTrue);
      // The weekly ones are scheduled first.
      expect(alarms.take(7).every((a) => a.weekly), isTrue);
    });

    test('the one-off days carry their own texts', () {
      final p = plan(
        inputs: EveningInputs(
          people: [person('jonas')],
          events: [event('jonas', DateTime(2026, 11, 16, 12))],
        ),
      );
      final once = eveningAlarms(p).where((a) => !a.weekly).toList();
      expect(once.take(3).map((a) => a.title), [
        'general',
        'general',
        'owe jonas',
      ]);
      expect(
        eveningAlarms(p).where((a) => a.weekly).map((a) => a.title),
        everyElement('general'),
      );
    });

    test('no day has two, also on excluded days and after the time', () {
      for (final p in [
        plan(),
        plan(weekdays: [2, 6]),
        plan(at: DateTime(2026, 11, 16, 20)),
        plan(at: DateTime(2026, 11, 22, 23, 59), weekdays: [7]),
      ]) {
        final alarms = eveningAlarms(p);
        final days = shownDays(
          alarms,
          p.start,
          DateTime(p.start.year, p.start.month, p.start.day + 70),
        );
        expect(days.toSet(), hasLength(days.length));
        expect(days.every((d) => p.weekdays.contains(d.weekday)), isTrue);
        // After the one-off days every allowed day still has one.
        final later = [
          for (var i = 21; i < 70; i++)
            if (DateTime(p.start.year, p.start.month, p.start.day + i)
                case final d when p.weekdays.contains(d.weekday))
              d,
        ];
        expect(days.where((d) => !d.isBefore(later.first)).toList(), later);
      }
    });

    test('off: nothing', () {
      expect(eveningAlarms(plan(weekdays: const [])), isEmpty);
    });
  });

  group('eveningChanges', () {
    test(
      'the upgrade from 101 to 107 repeating from now: no day twice',
      () async {
        final fake = FakeNotifications();
        // What the older version left: weekly from the next evening on.
        for (var d = 1; d <= 7; d++) {
          fake.pendingEvening[100 + d] = EveningAlarm(
            id: 100 + d,
            at: nextEvening(now, d, minute),
            title: 'general',
            weekly: true,
          );
        }
        await fake.scheduleEvening(plan());
        expect(fake.cancelledEvening, isEmpty);
        expect(fake.pendingEvening, hasLength(28));
        final days = shownDays(
          fake.pendingEvening.values,
          now,
          DateTime(2027, 3, 1),
        );
        expect(days.toSet(), hasLength(days.length));
        expect(days.first, DateTime(2026, 11, 16));
      },
    );

    test('scheduling again on a later day replaces, never doubles', () async {
      final fake = FakeNotifications();
      await fake.scheduleEvening(plan());
      // Five days later, after the evening; the earlier days have come and
      // gone, as the plugin would forget them.
      final later = DateTime(2026, 11, 21, 20);
      fake.pendingEvening.removeWhere(
        (_, a) => !a.weekly && a.at.isBefore(later),
      );
      await fake.scheduleEvening(plan(at: later));
      final days = shownDays(
        fake.pendingEvening.values,
        later,
        DateTime(2027, 3, 1),
      );
      expect(days.toSet(), hasLength(days.length));
      expect(days.first, DateTime(2026, 11, 22));
    });

    test('an excluded or switched-off day is cancelled, if pending', () async {
      final fake = FakeNotifications();
      await fake.scheduleEvening(plan());
      await fake.scheduleEvening(plan(weekdays: [1, 2, 3, 4, 5, 7]));
      expect(fake.cancelledEvening, [
        106,
        eveningDayId(DateTime(2026, 11, 21)),
        eveningDayId(DateTime(2026, 11, 28)),
        eveningDayId(DateTime(2026, 12, 5)),
      ]);
      await fake.scheduleEvening(plan(weekdays: const []));
      expect(fake.pendingEvening, isEmpty);
    });

    test(
      'today\'s pending one stays after its time while today is allowed',
      () {
        final today = eveningDayId(DateTime(2026, 11, 16));
        final late = DateTime(2026, 11, 16, 19, 10);
        expect(eveningChanges(plan(at: late), [today]).cancel, isEmpty);
        expect(eveningChanges(plan(at: late, weekdays: [2]), [today]).cancel, [
          today,
        ]);
      },
    );

    test('other notifications are not touched', () {
      final birthday = birthdayNotificationId('mia', late: false);
      expect(
        eveningChanges(plan(weekdays: const []), [birthday, 999]).cancel,
        isEmpty,
      );
    });
  });

  group('Debouncer', () {
    testWidgets('a burst runs once, after the last call', (tester) async {
      final d = Debouncer(const Duration(milliseconds: 500));
      var runs = 0;
      for (var i = 0; i < 5; i++) {
        d(() => runs++);
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(runs, 0);
      expect(d.isPending, isTrue);
      await tester.pump(const Duration(milliseconds: 500));
      expect(runs, 1);
      d(() => runs++);
      d.cancel();
      await tester.pump(const Duration(seconds: 1));
      expect(runs, 1);
    });
  });
}
