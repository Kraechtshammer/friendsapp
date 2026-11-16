import 'package:flutter_test/flutter_test.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/contact_event.dart';
import 'package:kept/domain/intention.dart';
import 'package:kept/domain/owed_reply.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/domain/pick_order.dart';

Person person(String id, {DateTime? cleared, int? month, int? day}) => Person(
  id: id,
  name: id,
  closeness: Closeness.close,
  avatarShape: AvatarShape.scallop,
  avatarColor: AvatarColor.mint,
  reconnecting: false,
  notes: '',
  createdAt: DateTime(2026),
  replyClearedAt: cleared,
  birthdayMonth: month,
  birthdayDay: day,
);

var _n = 0;

ContactEvent event(
  String personId,
  DateTime at, {
  ContactKind kind = ContactKind.wrote,
  ContactDirection direction = ContactDirection.byThem,
  ContactSource source = ContactSource.listener,
}) => ContactEvent(
  id: 'e${_n++}',
  personId: personId,
  at: at,
  kind: kind,
  direction: direction,
  source: source,
  createdAt: at,
);

void main() {
  final now = DateTime(2026, 11, 16, 20);
  final jonas = person('jonas');

  group('owedSince', () {
    test('owed once the waiting time has passed', () {
      final wrote = DateTime(2026, 11, 14, 20);
      final events = [event('jonas', wrote)];
      expect(owedSince(jonas, events, now: now), wrote);
      // One second earlier it is not owed yet.
      expect(
        owedSince(jonas, events, now: now.subtract(const Duration(seconds: 1))),
        isNull,
      );
    });

    test('the waiting time is a setting', () {
      final events = [event('jonas', DateTime(2026, 11, 13, 20))];
      expect(owedSince(jonas, events, now: now, waitDays: 3), isNotNull);
      expect(owedSince(jonas, events, now: now, waitDays: 4), isNull);
    });

    test('nothing incoming, nothing owed', () {
      expect(owedSince(jonas, const [], now: now), isNull);
      expect(
        owedSince(jonas, [event('anna', DateTime(2026, 11, 1))], now: now),
        isNull,
      );
    });

    test('calls never make a reply owed', () {
      final events = [
        event('jonas', DateTime(2026, 11, 1), kind: ContactKind.called),
      ];
      expect(owedSince(jonas, events, now: now), isNull);
    });

    test('contact by the user or together after it answers it', () {
      final wrote = DateTime(2026, 11, 10);
      for (final (kind, direction) in [
        (ContactKind.wrote, ContactDirection.byUser),
        (ContactKind.called, ContactDirection.byUser),
        (ContactKind.met, ContactDirection.together),
      ]) {
        final events = [
          event('jonas', wrote),
          event(
            'jonas',
            DateTime(2026, 11, 11),
            kind: kind,
            direction: direction,
            source: ContactSource.manual,
          ),
        ];
        expect(owedSince(jonas, events, now: now), isNull, reason: '$kind');
      }
      // Contact before the message does not answer it.
      final before = [
        event('jonas', wrote),
        event(
          'jonas',
          DateTime(2026, 11, 9),
          direction: ContactDirection.byUser,
        ),
      ];
      expect(owedSince(jonas, before, now: now), wrote);
    });

    test('a call from them does not answer it either', () {
      final wrote = DateTime(2026, 11, 10);
      final events = [
        event('jonas', wrote),
        event('jonas', DateTime(2026, 11, 11), kind: ContactKind.called),
      ];
      expect(owedSince(jonas, events, now: now), wrote);
    });

    test('Already answered or an opened chat clears it', () {
      final wrote = DateTime(2026, 11, 10);
      final events = [event('jonas', wrote)];
      expect(
        owedSince(
          person('jonas', cleared: DateTime(2026, 11, 12)),
          events,
          now: now,
        ),
        isNull,
      );
      // Cleared before this message: a new message is owed again.
      expect(
        owedSince(
          person('jonas', cleared: DateTime(2026, 11, 9)),
          events,
          now: now,
        ),
        wrote,
      );
    });

    test('only the newest incoming message counts', () {
      // An old message and a fresh one: the fresh one is not due yet.
      final events = [
        event('jonas', DateTime(2026, 11, 1)),
        event('jonas', DateTime(2026, 11, 16, 9)),
      ];
      expect(owedSince(jonas, events, now: now), isNull);
      // Once it is, it is the time that counts.
      expect(
        owedSince(jonas, events, now: DateTime(2026, 11, 19)),
        DateTime(2026, 11, 16, 9),
      );
    });

    test('with the listener off only entries by hand count', () {
      final listener = [event('jonas', DateTime(2026, 11, 10))];
      expect(owedSince(jonas, listener, now: now, listenerOn: false), isNull);
      final manual = [
        event('jonas', DateTime(2026, 11, 10), source: ContactSource.manual),
      ];
      expect(
        owedSince(jonas, manual, now: now, listenerOn: false),
        DateTime(2026, 11, 10),
      );
    });
  });

  test('owedReplies: longest owed first', () {
    final people = [person('anna'), jonas, person('tom')];
    final owed = owedReplies(people, [
      event('anna', DateTime(2026, 11, 12)),
      event('jonas', DateTime(2026, 11, 3)),
      event('tom', DateTime(2026, 11, 16)),
    ], now: now);
    expect(owed.map((o) => o.person.id), ['jonas', 'anna']);
    expect(owed.first.since, DateTime(2026, 11, 3));
  });

  group('pick order', () {
    final today = DateTime(2026, 11, 16);
    final lena = person('lena', month: 11, day: 16);
    final people = [lena, person('anna'), jonas, person('tom')];
    final thoughts = [
      Intention(
        id: 't1',
        personId: 'tom',
        note: 'Bouldering',
        kind: IntentionKind.write,
        state: IntentionState.open,
        createdAt: DateTime(2026, 11, 1),
      ),
      Intention(
        id: 'j1',
        personId: 'jonas',
        note: 'Ask about the flat',
        kind: IntentionKind.write,
        state: IntentionState.open,
        createdAt: DateTime(2026, 11, 2),
      ),
    ];

    test('owed replies come second, after birthdays', () {
      final owed = owedReplies(people, [
        event('anna', DateTime(2026, 11, 12)),
        event('jonas', DateTime(2026, 11, 3)),
        // Lena's birthday pick wins over her owed reply.
        event('lena', DateTime(2026, 11, 1)),
      ], now: now);
      final picks = tonightsPicks(
        people: people,
        intentions: thoughts,
        today: today,
        congratulated: const {},
        owed: owed,
      );
      expect(picks.map((p) => (p.kind, p.person.id)), [
        (PickKind.birthday, 'lena'),
        (PickKind.reply, 'jonas'),
        (PickKind.reply, 'anna'),
        // Jonas has a pick already, so his thought waits.
        (PickKind.intention, 'tom'),
      ]);
      expect((picks[1] as ReplyPick).since, DateTime(2026, 11, 3));
    });

    test('without owed replies nothing changes', () {
      final picks = tonightsPicks(
        people: people,
        intentions: thoughts,
        today: today,
        congratulated: {'lena'},
      );
      expect(picks.map((p) => p.kind), [
        PickKind.intention,
        PickKind.intention,
      ]);
    });
  });
}
