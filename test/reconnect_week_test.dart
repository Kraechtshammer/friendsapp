import 'package:flutter_test/flutter_test.dart';
import 'package:kept/data/app_settings.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/contact_event.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/domain/reconnect_week.dart';

Person person(String id, {bool reconnecting = true}) => Person(
  id: id,
  name: id,
  closeness: Closeness.nowAndThen,
  avatarShape: AvatarShape.scallop,
  avatarColor: AvatarColor.mint,
  reconnecting: reconnecting,
  notes: '',
  createdAt: DateTime(2026),
);

ContactEvent event(
  String personId,
  DateTime at, {
  ContactDirection direction = ContactDirection.byUser,
  ContactKind kind = ContactKind.wrote,
}) => ContactEvent(
  id: '$personId-$at-$direction-$kind',
  personId: personId,
  at: at,
  kind: kind,
  direction: direction,
  source: ContactSource.manual,
  createdAt: at,
);

void main() {
  // Monday 16 November 2026.
  final monday = DateTime(2026, 11, 16);
  final jonas = person('jonas'),
      kenji = person('kenji'),
      tom = person('tom', reconnecting: false);
  final people = [jonas, kenji, tom];

  ReconnectState stateAt(
    DateTime today, {
    String? chosen,
    DateTime? week,
    List<ContactEvent> events = const [],
    List<Person>? who,
    ReconnectSpan span = ReconnectSpan.week,
  }) => reconnectState(
    people: who ?? people,
    events: events,
    chosenId: chosen,
    chosenStart: week,
    span: span,
    today: today,
  );

  group('weeks', () {
    test('Monday is the start, Sunday still belongs to the week', () {
      expect(mondayOf(DateTime(2026, 11, 16, 0, 0)), monday);
      expect(mondayOf(DateTime(2026, 11, 22, 23, 59)), monday);
      expect(mondayOf(DateTime(2026, 11, 23)), DateTime(2026, 11, 23));
      expect(mondayOf(DateTime(2026, 11, 18, 12)), monday);
      expect(nextMonday(monday), DateTime(2026, 11, 23));
      // Across a month and a year.
      expect(mondayOf(DateTime(2027, 1, 3)), DateTime(2026, 12, 28));
      expect(nextMonday(DateTime(2026, 12, 28)), DateTime(2027, 1, 4));
    });
  });

  group('spans', () {
    test('each span ends after its length', () {
      final start = DateTime(2026, 11, 16);
      expect(ReconnectSpan.week.endOf(start), DateTime(2026, 11, 23));
      expect(ReconnectSpan.twoWeeks.endOf(start), DateTime(2026, 11, 30));
      expect(ReconnectSpan.month.endOf(start), DateTime(2026, 12, 16));
      expect(ReconnectSpan.twoMonths.endOf(start), DateTime(2027, 1, 16));
      expect(ReconnectSpan.threeMonths.endOf(start), DateTime(2027, 2, 16));
      expect(ReconnectSpan.defaultSpan, ReconnectSpan.month);
    });

    test('a month from the 31st ends on the last day of a short month', () {
      expect(
        ReconnectSpan.month.endOf(DateTime(2026, 1, 31)),
        DateTime(2026, 2, 28),
      );
      expect(
        ReconnectSpan.month.endOf(DateTime(2028, 1, 31)),
        DateTime(2028, 2, 29),
      );
      expect(
        ReconnectSpan.twoMonths.endOf(DateTime(2026, 12, 31)),
        DateTime(2027, 2, 28),
      );
      expect(
        ReconnectSpan.threeMonths.endOf(DateTime(2026, 11, 30)),
        DateTime(2027, 2, 28),
      );
    });

    test('a choice lasts from its start day to the end day, not including', () {
      final start = DateTime(2026, 11, 18); // a Wednesday, not a Monday
      ReconnectState at(DateTime today, ReconnectSpan span) =>
          stateAt(today, chosen: 'kenji', week: start, span: span);
      expect(
        at(DateTime(2026, 12, 17, 23, 59), ReconnectSpan.month),
        isA<ReconnectChosen>(),
      );
      expect(
        at(DateTime(2026, 12, 18), ReconnectSpan.month),
        isA<ReconnectChoose>(),
      );
      expect(
        at(DateTime(2026, 11, 24, 23), ReconnectSpan.week),
        isA<ReconnectChosen>(),
      );
      expect(
        at(DateTime(2026, 11, 25), ReconnectSpan.week),
        isA<ReconnectChoose>(),
      );
      expect(
        at(DateTime(2026, 12, 2), ReconnectSpan.twoWeeks),
        isA<ReconnectChoose>(),
      );
      expect(
        at(DateTime(2027, 2, 17), ReconnectSpan.threeMonths),
        isA<ReconnectChosen>(),
      );
      expect(
        at(DateTime(2027, 2, 18), ReconnectSpan.threeMonths),
        isA<ReconnectChoose>(),
      );
    });

    test(
      'contact before the start day does not count, done lasts to the end',
      () {
        final start = DateTime(2026, 11, 18);
        ReconnectState with_(DateTime at, DateTime today) => stateAt(
          today,
          chosen: 'kenji',
          week: start,
          span: ReconnectSpan.month,
          events: [event('kenji', at)],
        );
        expect(
          with_(DateTime(2026, 11, 17, 23), DateTime(2026, 11, 20)),
          isA<ReconnectChosen>(),
        );
        expect(
          with_(DateTime(2026, 11, 18, 0, 0), DateTime(2026, 12, 17)),
          isA<ReconnectDone>(),
        );
        // The span is over: the card asks again, with no word about it.
        expect(
          with_(DateTime(2026, 11, 18, 9), DateTime(2026, 12, 18)),
          isA<ReconnectChoose>(),
        );
      },
    );

    test('an old stored Monday is a start day: the choice carries on', () {
      final old = AppSettings.fromMap({
        'reconnectPerson': 'kenji',
        'reconnectWeek': '2026-11-16',
      });
      expect(old.reconnectSpan, ReconnectSpan.month);
      final s = stateAt(
        DateTime(2026, 11, 19),
        chosen: old.reconnectPersonId,
        week: old.reconnectStart,
        span: old.reconnectSpan,
      );
      expect((s as ReconnectChosen).person.id, 'kenji');
    });
  });

  group('the state', () {
    test('nobody in the state and nobody chosen: nothing', () {
      expect(stateAt(monday, who: [tom]), isA<ReconnectNone>());
      expect(stateAt(monday, who: const []), isA<ReconnectNone>());
    });

    test('nobody chosen: the people in the state, with a suggestion', () {
      final s = stateAt(monday) as ReconnectChoose;
      expect(s.candidates.map((p) => p.id), ['jonas', 'kenji']);
      expect(s.candidates, contains(s.suggested));
    });

    test('the suggestion is stable within a week and moves on', () {
      Person suggested(DateTime d) => (stateAt(d) as ReconnectChoose).suggested;
      expect(suggested(DateTime(2026, 11, 22, 23)), suggested(monday));
      expect(suggested(DateTime(2026, 11, 23)), isNot(suggested(monday)));
    });

    test('chosen this week and no contact yet: chosen', () {
      final s = stateAt(DateTime(2026, 11, 18), chosen: 'kenji', week: monday);
      expect((s as ReconnectChosen).person.id, 'kenji');
    });

    test('a contact by the user in the week turns it to done', () {
      final events = [event('kenji', DateTime(2026, 11, 19, 20))];
      final s = stateAt(
        DateTime(2026, 11, 20),
        chosen: 'kenji',
        week: monday,
        events: events,
      );
      expect((s as ReconnectDone).person.id, 'kenji');
    });

    test('a meet-up counts; something that only came in does not', () {
      ReconnectState with_(ContactEvent e) =>
          stateAt(monday, chosen: 'kenji', week: monday, events: [e]);
      expect(
        with_(
          event(
            'kenji',
            DateTime(2026, 11, 17),
            direction: ContactDirection.together,
            kind: ContactKind.met,
          ),
        ),
        isA<ReconnectDone>(),
      );
      expect(
        with_(
          event(
            'kenji',
            DateTime(2026, 11, 17),
            direction: ContactDirection.byThem,
          ),
        ),
        isA<ReconnectChosen>(),
      );
      // Contact with somebody else does not count.
      expect(
        with_(event('jonas', DateTime(2026, 11, 17))),
        isA<ReconnectChosen>(),
      );
    });

    test('Monday boundaries of the week: 00:00 in, next Monday 00:00 out', () {
      ReconnectState with_(DateTime at) => stateAt(
        DateTime(2026, 11, 18),
        chosen: 'kenji',
        week: monday,
        events: [event('kenji', at)],
      );
      expect(with_(DateTime(2026, 11, 16, 0, 0)), isA<ReconnectDone>());
      expect(with_(DateTime(2026, 11, 15, 23, 59)), isA<ReconnectChosen>());
      expect(with_(DateTime(2026, 11, 22, 23, 59)), isA<ReconnectDone>());
      expect(with_(DateTime(2026, 11, 23, 0, 0)), isA<ReconnectChosen>());
    });

    test('done lasts to the end of the week, Sunday night included', () {
      final events = [event('kenji', DateTime(2026, 11, 16, 9))];
      expect(
        stateAt(
          DateTime(2026, 11, 22, 23, 59),
          chosen: 'kenji',
          week: monday,
          events: events,
        ),
        isA<ReconnectDone>(),
      );
    });

    test('a new week starts empty again: last week says nothing', () {
      final events = [event('kenji', DateTime(2026, 11, 19))];
      // Chosen and done last week, now Monday: the list again.
      final s = stateAt(
        DateTime(2026, 11, 23),
        chosen: 'kenji',
        week: monday,
        events: events,
      );
      expect(s, isA<ReconnectChoose>());
      // Same if it was never done.
      expect(
        stateAt(DateTime(2026, 11, 23), chosen: 'jonas', week: monday),
        isA<ReconnectChoose>(),
      );
      // And with nobody in the state any more, nothing.
      expect(
        stateAt(
          DateTime(2026, 11, 23),
          chosen: 'kenji',
          week: monday,
          who: [tom],
        ),
        isA<ReconnectNone>(),
      );
    });

    test('a chosen person who is gone counts as nobody chosen', () {
      final s = stateAt(monday, chosen: 'ghost', week: monday);
      expect(s, isA<ReconnectChoose>());
    });

    test(
      'a chosen person stays for the week even if the state was switched off',
      () {
        final s = stateAt(monday, chosen: 'tom', week: monday);
        expect((s as ReconnectChosen).person.id, 'tom');
      },
    );
  });

  group('first exchange', () {
    final now = DateTime(2026, 11, 16, 12);

    bool exchange(List<ContactEvent> events) =>
        hadFirstExchange('kenji', events, now);

    test('the user, then them: yes', () {
      expect(
        exchange([
          event('kenji', DateTime(2026, 11, 10)),
          event(
            'kenji',
            DateTime(2026, 11, 12),
            direction: ContactDirection.byThem,
          ),
        ]),
        isTrue,
      );
    });

    test('the user, then a meet-up or gaming together: yes', () {
      for (final kind in [ContactKind.met, ContactKind.gamed]) {
        expect(
          exchange([
            event('kenji', DateTime(2026, 11, 10)),
            event(
              'kenji',
              DateTime(2026, 11, 14),
              direction: ContactDirection.together,
              kind: kind,
            ),
          ]),
          isTrue,
          reason: '$kind',
        );
      }
    });

    test('only the user, or only them, or them before the user: no', () {
      expect(exchange([event('kenji', DateTime(2026, 11, 10))]), isFalse);
      expect(
        exchange([
          event(
            'kenji',
            DateTime(2026, 11, 10),
            direction: ContactDirection.byThem,
          ),
        ]),
        isFalse,
      );
      expect(
        exchange([
          event(
            'kenji',
            DateTime(2026, 11, 12),
            direction: ContactDirection.byThem,
          ),
          event('kenji', DateTime(2026, 11, 13)),
        ]),
        isFalse,
      );
      // A meet-up alone is no exchange either.
      expect(
        exchange([
          event(
            'kenji',
            DateTime(2026, 11, 10),
            direction: ContactDirection.together,
            kind: ContactKind.met,
          ),
        ]),
        isFalse,
      );
    });

    test('a birthday wish from them is no exchange', () {
      expect(
        exchange([
          event('kenji', DateTime(2026, 11, 10)),
          event(
            'kenji',
            DateTime(2026, 11, 12),
            direction: ContactDirection.byThem,
            kind: ContactKind.birthdayWish,
          ),
        ]),
        isFalse,
      );
    });

    test('old history does not count, and other people are ignored', () {
      expect(
        exchange([
          event('kenji', DateTime(2025, 11, 10)),
          event(
            'kenji',
            DateTime(2025, 11, 12),
            direction: ContactDirection.byThem,
          ),
        ]),
        isFalse,
      );
      // They wrote last week, the user's last contact is a year ago.
      expect(
        exchange([
          event('kenji', DateTime(2025, 10, 1)),
          event(
            'kenji',
            DateTime(2026, 11, 9),
            direction: ContactDirection.byThem,
          ),
        ]),
        isFalse,
      );
      expect(
        exchange([
          event('jonas', DateTime(2026, 11, 10)),
          event(
            'jonas',
            DateTime(2026, 11, 12),
            direction: ContactDirection.byThem,
          ),
        ]),
        isFalse,
      );
    });

    test('backInTouch: in the state, not answered', () {
      final events = [
        event('kenji', DateTime(2026, 11, 10)),
        event(
          'kenji',
          DateTime(2026, 11, 12),
          direction: ContactDirection.byThem,
        ),
        event('tom', DateTime(2026, 11, 10)),
        event(
          'tom',
          DateTime(2026, 11, 12),
          direction: ContactDirection.byThem,
        ),
      ];
      expect(backInTouch(people, events, const {}, now).map((p) => p.id), [
        'kenji',
      ]);
      expect(backInTouch(people, events, const {'kenji'}, now), isEmpty);
    });
  });

  group('settings', () {
    test('the span is stored by name; a broken one falls back to a month', () {
      final s = const AppSettings().copyWith(
        reconnectSpan: ReconnectSpan.twoWeeks,
      );
      expect(s.toMap()['reconnectSpan'], 'twoWeeks');
      expect(
        AppSettings.fromMap({'reconnectSpan': 'twoWeeks'}).reconnectSpan,
        ReconnectSpan.twoWeeks,
      );
      expect(
        AppSettings.fromMap({'reconnectSpan': 'forever'}).reconnectSpan,
        ReconnectSpan.month,
      );
      expect(const AppSettings().reconnectSpan, ReconnectSpan.month);
    });

    test('the choice and the answers are stored and read back', () {
      final s = const AppSettings()
          .withReconnect('kenji', monday)
          .copyWith(backInTouchAnswered: {'b', 'a'});
      expect(s.toMap()['reconnectPerson'], 'kenji');
      expect(s.toMap()['reconnectWeek'], '2026-11-16');
      expect(s.toMap()['backInTouchAnswered'], 'a,b');
      final back = AppSettings.fromMap({
        for (final e in s.toMap().entries)
          if (e.value != null) e.key: e.value!,
      });
      expect(back, s);
      expect(back.reconnectStart, monday);
    });

    test(
      'clearing the choice removes both keys; a broken date is no choice',
      () {
        final s = const AppSettings()
            .withReconnect('kenji', monday)
            .withReconnect(null, null);
        expect(s.toMap()['reconnectPerson'], isNull);
        expect(s.toMap()['reconnectWeek'], isNull);
        final broken = AppSettings.fromMap({
          'reconnectPerson': 'kenji',
          'reconnectWeek': 'soon',
        });
        expect(broken.reconnectPersonId, isNull);
        expect(broken.reconnectStart, isNull);
      },
    );

    test('other changes keep the choice', () {
      final s = const AppSettings()
          .withReconnect('kenji', monday)
          .copyWith(replyWaitDays: 3)
          .withOwnBirthday(null);
      expect(s.reconnectPersonId, 'kenji');
      expect(s.replyWaitDays, 3);
    });
  });
}
