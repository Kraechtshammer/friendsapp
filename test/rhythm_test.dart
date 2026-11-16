import 'package:flutter_test/flutter_test.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/contact_event.dart';
import 'package:kept/domain/intention.dart';
import 'package:kept/domain/owed_reply.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/domain/pick_order.dart';
import 'package:kept/domain/rhythm.dart';

Person person(
  String id, {
  Closeness closeness = Closeness.close,
  int? rhythmDays,
  DateTime? added,
  int? month,
  int? day,
}) => Person(
  id: id,
  name: id,
  closeness: closeness,
  rhythmDays: rhythmDays,
  avatarShape: AvatarShape.scallop,
  avatarColor: AvatarColor.mint,
  reconnecting: false,
  notes: '',
  createdAt: added ?? DateTime(2026),
  birthdayMonth: month,
  birthdayDay: day,
);

ContactEvent event(
  String personId,
  DateTime at, {
  ContactDirection direction = ContactDirection.byUser,
  ContactKind kind = ContactKind.wrote,
}) => ContactEvent(
  id: '$personId-$at-$direction',
  personId: personId,
  at: at,
  kind: kind,
  direction: direction,
  source: ContactSource.manual,
  createdAt: at,
);

Intention thought(String id, String personId, {DateTime? date}) => Intention(
  id: id,
  personId: personId,
  note: id,
  kind: IntentionKind.write,
  state: IntentionState.open,
  date: date,
  createdAt: DateTime(2026, 11, 1),
);

void main() {
  final today = DateTime(2026, 11, 16);
  const rhythms = defaultClassRhythms;

  group('the start values', () {
    test('2 weeks, 6 weeks, 3 months, and none for Family', () {
      expect(rhythms[Closeness.close], 14);
      expect(rhythms[Closeness.nowAndThen], 42);
      expect(rhythms[Closeness.fewTimesAYear], 90);
      expect(rhythms[Closeness.family], isNull);
    });

    test('the spans are weeks up to 8, then 3, 4, 6 and 12 months', () {
      expect(rhythmSpans, [7, 14, 21, 28, 42, 56, 90, 120, 180, 365]);
      expect(
        [
          for (final d in [90, 120, 180, 365]) rhythmMonths(d),
        ],
        [3, 4, 6, 12],
      );
    });
  });

  group('last contact', () {
    final tom = person('tom', added: DateTime(2026, 5, 1));

    test('is the newest event in any direction', () {
      final events = [
        event('tom', DateTime(2026, 9, 1)),
        event('tom', DateTime(2026, 10, 5), direction: ContactDirection.byThem),
        event(
          'tom',
          DateTime(2026, 8, 1),
          direction: ContactDirection.together,
          kind: ContactKind.met,
        ),
        // Someone else's newer event does not count.
        event('anna', DateTime(2026, 11, 10)),
      ];
      expect(lastContact(tom, events), DateTime(2026, 10, 5));
    });

    test('is the day they were added when there is no event', () {
      expect(lastContact(tom, const []), DateTime(2026, 5, 1));
      expect(
        lastContact(tom, [event('anna', DateTime(2026, 11, 1))]),
        tom.createdAt,
      );
    });

    test('a birthday wish is a contact too', () {
      final events = [
        event('tom', DateTime(2026, 11, 1), kind: ContactKind.birthdayWish),
      ];
      expect(lastContact(tom, events), DateTime(2026, 11, 1));
    });
  });

  group('due for a hint', () {
    // 14 days is the rhythm of Close friends: due when more than 14 days
    // ago, counted in calendar days.
    test('the class rhythm: longer ago than the rhythm', () {
      final tom = person('tom');
      bool due(DateTime last) =>
          isDueForHint(tom, [event('tom', last)], rhythms, today);
      expect(due(DateTime(2026, 11, 2, 23, 59)), isFalse); // 14 days
      expect(due(DateTime(2026, 11, 1, 8)), isTrue); // 15 days
      expect(due(DateTime(2026, 11, 16)), isFalse);
    });

    test('the other classes', () {
      bool due(Closeness c, DateTime last) => isDueForHint(
        person('p', closeness: c),
        [event('p', last)],
        rhythms,
        today,
      );
      expect(due(Closeness.nowAndThen, DateTime(2026, 10, 5)), isFalse);
      expect(due(Closeness.nowAndThen, DateTime(2026, 10, 4)), isTrue);
      expect(due(Closeness.fewTimesAYear, DateTime(2026, 8, 18)), isFalse);
      expect(due(Closeness.fewTimesAYear, DateTime(2026, 8, 17)), isTrue);
    });

    test('an own rhythm beats the class', () {
      final tom = person('tom', rhythmDays: 7);
      final events = [event('tom', DateTime(2026, 11, 5))];
      expect(isDueForHint(tom, events, rhythms, today), isTrue);
      final slow = person('tom', rhythmDays: 365);
      expect(isDueForHint(slow, events, rhythms, today), isFalse);
      expect(rhythmDaysFor(tom, rhythms), 7);
      expect(rhythmDaysFor(person('x'), rhythms), 14);
    });

    test('none means never, but Family can get one', () {
      final mum = person('mum', closeness: Closeness.family);
      expect(rhythmDaysFor(mum, rhythms), isNull);
      expect(isDueForHint(mum, const [], rhythms, today), isFalse);
      final edited = {...rhythms, Closeness.family: 30};
      expect(isDueForHint(mum, const [], edited, today), isTrue);
      // Own rhythm on a class without one.
      final own = person('mum', closeness: Closeness.family, rhythmDays: 30);
      expect(isDueForHint(own, const [], rhythms, today), isTrue);
      // A class set to none: nobody of it is due.
      final none = {...rhythms, Closeness.close: null};
      expect(isDueForHint(person('tom'), const [], none, today), isFalse);
    });

    test('with no events the day they were added counts', () {
      expect(
        isDueForHint(
          person('new', added: DateTime(2026, 11, 10)),
          const [],
          rhythms,
          today,
        ),
        isFalse,
      );
      expect(
        isDueForHint(
          person('old', added: DateTime(2026, 10, 1)),
          const [],
          rhythms,
          today,
        ),
        isTrue,
      );
    });

    test('a contact from them also counts as contact', () {
      final tom = person('tom');
      final events = [
        event('tom', DateTime(2026, 9, 1)),
        event(
          'tom',
          DateTime(2026, 11, 14),
          direction: ContactDirection.byThem,
        ),
      ];
      expect(isDueForHint(tom, events, rhythms, today), isFalse);
    });

    test('peopleDueForHint keeps the order of the list', () {
      final people = [
        person('b', added: DateTime(2026, 1)),
        person('a', added: DateTime(2026, 11, 15)),
        person('c', added: DateTime(2026, 1)),
      ];
      expect(
        peopleDueForHint(people, const [], rhythms, today).map((p) => p.id),
        ['b', 'c'],
      );
    });
  });

  group('the daily rotation', () {
    final due = [person('c'), person('a'), person('b'), person('d')];

    test('is the same all day, whatever the order of the list', () {
      final morning = hintPersonFor(due, DateTime(2026, 11, 16, 6, 30));
      expect(hintPersonFor(due, DateTime(2026, 11, 16, 23, 59)), morning);
      expect(hintPersonFor(due.reversed.toList(), today), morning);
    });

    test('changes from one day to the next', () {
      for (var i = 0; i < 20; i++) {
        final day = DateTime(2026, 11, 1 + i);
        final next = DateTime(2026, 11, 2 + i);
        expect(
          hintPersonFor(due, day)!.id,
          isNot(hintPersonFor(due, next)!.id),
        );
      }
    });

    test('visits everyone within a few days', () {
      final seen = {
        for (var i = 0; i < 4; i++)
          hintPersonFor(due, DateTime(2026, 11, 1 + i))!.id,
      };
      expect(seen, {'a', 'b', 'c', 'd'});
    });

    test('nobody due: no hint; one person: always that one', () {
      expect(hintPersonFor(const [], today), isNull);
      final solo = [person('solo')];
      expect(hintPersonFor(solo, today), solo.single);
      expect(hintPersonFor(solo, DateTime(2026, 11, 17)), solo.single);
    });
  });

  group('the pick order', () {
    // Everybody was added long ago and has never been in touch, so all of
    // them are due; the pick order decides who is shown.
    final old = DateTime(2026, 1, 1);
    final lena = person('lena', added: old, month: 11, day: 16);
    final jonas = person('jonas', added: old);
    final kai = person('kai', added: old);
    final tom = person('tom', added: old);
    final anna = person('anna', added: old);
    final zoe = person('zoe', added: old);
    final people = [lena, jonas, kai, tom, anna, zoe];
    final owed = [(person: jonas, since: DateTime(2026, 11, 10))];

    List<Pick> picks({
      List<Person>? who,
      Person? reconnect,
      List<Intention> thoughts = const [],
      List<OwedReply>? owedReplies,
      Set<String> congratulated = const {},
      Map<Closeness, int?>? classRhythms = rhythms,
      DateTime? day,
    }) => tonightsPicks(
      people: who ?? people,
      intentions: thoughts,
      today: day ?? today,
      congratulated: congratulated,
      owed: owedReplies ?? owed,
      reconnect: reconnect,
      classRhythms: classRhythms,
    );

    test('birthday, owed reply, reconnect, thought, then the hint', () {
      final all = picks(reconnect: kai, thoughts: [thought('t', 'tom')]);
      expect(all.map((p) => p.kind), [
        PickKind.birthday,
        PickKind.reply,
        PickKind.reconnect,
        PickKind.intention,
        PickKind.hint,
      ]);
      expect(all.map((p) => p.person.id), [
        'lena',
        'jonas',
        'kai',
        'tom',
        all.last.person.id,
      ]);
    });

    test('a plan is ranked with the thoughts, before the hint', () {
      final plan = Intention(
        id: 'p',
        personId: 'tom',
        note: 'trip',
        kind: IntentionKind.meet,
        state: IntentionState.open,
        horizon: Horizon.soon,
        createdAt: DateTime(2026, 10, 1),
      );
      final all = picks(thoughts: [plan]);
      expect(all.map((p) => p.kind), [
        PickKind.birthday,
        PickKind.reply,
        PickKind.plan,
        PickKind.hint,
      ]);
    });

    test('at most one hint, never one of the people above', () {
      final all = picks(reconnect: kai, thoughts: [thought('t', 'tom')]);
      final hints = all.whereType<HintPick>();
      expect(hints, hasLength(1));
      expect({
        'lena',
        'jonas',
        'kai',
        'tom',
      }, isNot(contains(hints.single.person.id)));
    });

    test(
      'no one with a birthday, an owed reply or an open thought is hinted',
      () {
        // Only these are left in the list, all of them due.
        final all = picks(
          who: [lena, jonas, tom],
          thoughts: [thought('t', 'tom')],
        );
        expect(all.whereType<HintPick>(), isEmpty);
        expect(all, hasLength(3));
      },
    );

    test('a thought with a date or a horizon also keeps the hint away', () {
      final dated = thought('t', 'tom', date: DateTime(2026, 12, 1));
      final all = picks(who: [tom], thoughts: [dated], owedReplies: const []);
      expect(all, isEmpty);
    });

    test('a congratulated birthday is a contact: no pick, no hint', () {
      final all = tonightsPicks(
        people: [lena],
        intentions: const [],
        today: today,
        congratulated: {'lena'},
        events: [
          event(
            'lena',
            DateTime(2026, 11, 16, 9),
            kind: ContactKind.birthdayWish,
          ),
        ],
        classRhythms: rhythms,
      );
      expect(all, isEmpty);
    });

    test('the hint follows the daily rotation among those left', () {
      final left = [kai, tom, anna, zoe];
      final day1 = tonightsPicks(
        people: left,
        intentions: const [],
        today: today,
        congratulated: const {},
        classRhythms: rhythms,
      );
      final again = tonightsPicks(
        people: left,
        intentions: const [],
        today: DateTime(2026, 11, 16, 22),
        congratulated: const {},
        classRhythms: rhythms,
      );
      final tomorrow = tonightsPicks(
        people: left,
        intentions: const [],
        today: DateTime(2026, 11, 17),
        congratulated: const {},
        classRhythms: rhythms,
      );
      expect(day1.single.person.id, again.single.person.id);
      expect(day1.single.person.id, isNot(tomorrow.single.person.id));
    });

    test('without rhythms there is no hint (the old behaviour)', () {
      expect(picks(classRhythms: null).map((p) => p.kind), [
        PickKind.birthday,
        PickKind.reply,
      ]);
    });

    test('a reconnect person with a birthday or owed reply has one pick', () {
      final all = picks(reconnect: lena);
      expect(all.where((p) => p.person.id == 'lena'), hasLength(1));
      expect(all.first, isA<BirthdayPick>());
      final second = picks(reconnect: jonas);
      expect(
        second.where((p) => p.person.id == 'jonas').single,
        isA<ReplyPick>(),
      );
    });

    test('the reconnect person comes before thoughts, taking their place', () {
      final all = picks(
        who: [kai, tom],
        reconnect: kai,
        thoughts: [thought('k', 'kai'), thought('t', 'tom')],
        owedReplies: const [],
      );
      expect(all.map((p) => p.kind), [PickKind.reconnect, PickKind.intention]);
      expect(all.map((p) => p.person.id), ['kai', 'tom']);
    });

    test('nobody due and nothing else: no pick at all', () {
      expect(
        picks(
          who: [person('fresh', added: today)],
          owedReplies: const [],
        ),
        isEmpty,
      );
    });
  });
}
