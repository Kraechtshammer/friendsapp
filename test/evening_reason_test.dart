import 'package:flutter_test/flutter_test.dart';
import 'package:kept/domain/contact_event.dart';
import 'package:kept/domain/evening_question.dart';
import 'package:kept/domain/evening_reason.dart';
import 'package:kept/domain/reconnect_week.dart';

import 'owed_reply_test.dart' show event, person;

const texts = EveningTexts(
  general: 'general',
  owedReply: _owed,
  reconnect: _reconnect,
);

String _owed(String name) => 'owe $name';
String _reconnect(ReconnectSpan span, String name) => '${span.name}: $name';
String _first(String name) => name.split(' ').first;

void main() {
  // Monday 16 November 2026, 14:00; the question comes at 19:00.
  final now = DateTime(2026, 11, 16, 14);
  const minute = 19 * 60;
  const all = [1, 2, 3, 4, 5, 6, 7];
  final jonas = person('jonas');
  final mia = person('mia');

  List<EveningDay> days(
    EveningInputs inputs, {
    List<int> weekdays = all,
    DateTime? at,
    int count = 7,
  }) => eveningDays(
    now: at ?? now,
    weekdays: weekdays,
    minute: minute,
    inputs: inputs,
    texts: texts,
    nameOf: _first,
    count: count,
  );

  List<String> titles(List<EveningDay> d) => [for (final x in d) x.title];

  group('owed replies', () {
    test('owed today: today names the person', () {
      final d = days(
        EveningInputs(
          people: [jonas],
          events: [event('jonas', DateTime(2026, 11, 14, 10))],
        ),
      );
      expect(d.first.at, DateTime(2026, 11, 16, 19));
      expect(d.first.reason, EveningOwedReply(jonas));
      expect(titles(d), everyElement('owe jonas'));
    });

    test('a message from today is owed in two days, not before', () {
      final d = days(
        EveningInputs(
          people: [jonas],
          events: [event('jonas', DateTime(2026, 11, 16, 12))],
        ),
      );
      expect(titles(d).take(3), ['general', 'general', 'owe jonas']);
      expect(d[2].at, DateTime(2026, 11, 18, 19));
    });

    test('the waiting time and the listener switch count', () {
      final events = [event('jonas', DateTime(2026, 11, 15, 12))];
      final d = days(
        EveningInputs(people: [jonas], events: events, replyWaitDays: 3),
      );
      // Written Sunday 12:00, three days: owed from Wednesday's evening.
      expect(titles(d).take(3), ['general', 'general', 'owe jonas']);
      expect(
        titles(
          days(
            EveningInputs(people: [jonas], events: events, listenerOn: false),
          ),
        ),
        everyElement('general'),
      );
    });

    test('cleared or answered is not owed', () {
      final wrote = DateTime(2026, 11, 13, 10);
      expect(
        titles(
          days(
            EveningInputs(
              people: [person('jonas', cleared: DateTime(2026, 11, 14))],
              events: [event('jonas', wrote)],
            ),
          ),
        ),
        everyElement('general'),
      );
      expect(
        titles(
          days(
            EveningInputs(
              people: [jonas],
              events: [
                event('jonas', wrote),
                event(
                  'jonas',
                  DateTime(2026, 11, 15),
                  direction: ContactDirection.byUser,
                ),
              ],
            ),
          ),
        ),
        everyElement('general'),
      );
    });

    test('several owed: the one owed longest comes first', () {
      final d = days(
        EveningInputs(
          people: [jonas, mia],
          events: [
            event('jonas', DateTime(2026, 11, 13, 10)),
            event('mia', DateTime(2026, 11, 10, 10)),
          ],
        ),
      );
      expect(titles(d), everyElement('owe mia'));
    });

    test('an owed reply comes before the reconnect person', () {
      final d = days(
        EveningInputs(
          people: [jonas, mia],
          events: [event('jonas', DateTime(2026, 11, 13, 10))],
          reconnectId: 'mia',
          reconnectStart: DateTime(2026, 11, 16),
        ),
      );
      expect(d.first.reason, EveningOwedReply(jonas));
    });
  });

  group('the reconnect person', () {
    test('a reason only on days inside the span', () {
      // A week from Wednesday 11 November: the last day is Tuesday 17th.
      final d = days(
        EveningInputs(
          people: [mia],
          reconnectId: 'mia',
          reconnectStart: DateTime(2026, 11, 11),
          reconnectSpan: ReconnectSpan.week,
        ),
      );
      expect(titles(d), [
        'week: mia',
        'week: mia',
        'general',
        'general',
        'general',
        'general',
        'general',
      ]);
      expect(d.first.reason, EveningReconnect(mia, ReconnectSpan.week));
    });

    test('the title follows the span', () {
      final d = days(
        EveningInputs(
          people: [person('mia lang')],
          reconnectId: 'mia lang',
          reconnectStart: DateTime(2026, 11, 16),
        ),
      );
      expect(titles(d), everyElement('month: mia'));
    });

    test('no reason after contact in the span, nor without a choice', () {
      expect(
        titles(
          days(
            EveningInputs(
              people: [mia],
              events: [
                event(
                  'mia',
                  DateTime(2026, 11, 16, 9),
                  kind: ContactKind.met,
                  direction: ContactDirection.together,
                ),
              ],
              reconnectId: 'mia',
              reconnectStart: DateTime(2026, 11, 12),
            ),
          ),
        ),
        everyElement('general'),
      );
      expect(
        titles(days(EveningInputs(people: [person('x')]))),
        everyElement('general'),
      );
    });

    test('a person no longer there is no reason', () {
      expect(
        titles(
          days(
            EveningInputs(
              people: [jonas],
              reconnectId: 'mia',
              reconnectStart: DateTime(2026, 11, 16),
            ),
          ),
        ),
        everyElement('general'),
      );
    });
  });

  group('which days', () {
    test('excluded weekdays have none', () {
      final d = days(const EveningInputs(), weekdays: [1, 3, 5], count: 14);
      expect([for (final x in d) x.at.weekday], [1, 3, 5, 1, 3, 5]);
    });

    test('switched off: none', () {
      final weekdays = eveningWeekdays(on: false, excluded: {});
      expect(days(const EveningInputs(), weekdays: weekdays), isEmpty);
    });

    test('once the time has passed today starts tomorrow', () {
      final d = days(const EveningInputs(), at: DateTime(2026, 11, 16, 19));
      expect(d.first.at, DateTime(2026, 11, 17, 19));
      expect(d, hasLength(6));
    });

    test('21 days by default, at the wall-clock time', () {
      final d = eveningDays(
        now: now,
        weekdays: all,
        minute: minute,
        inputs: const EveningInputs(),
        texts: texts,
        nameOf: _first,
      );
      expect(d, hasLength(eveningOneOffDays));
      expect(d.last.at, DateTime(2026, 12, 6, 19));
      expect(d.every((x) => x.at.hour == 19 && x.at.minute == 0), isTrue);
    });
  });
}
