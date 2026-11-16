import 'package:flutter_test/flutter_test.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/intention.dart';
import 'package:kept/domain/pick_order.dart';
import 'package:kept/domain/plans.dart';

import 'pick_order_test.dart' show person;

Intention plan(
  String id,
  String personId, {
  DateTime? created,
  DateTime? date,
  Horizon? horizon,
  IntentionState state = IntentionState.open,
  String? condition,
}) => Intention(
  id: id,
  personId: personId,
  note: id,
  kind: IntentionKind.meet,
  state: state,
  date: date,
  horizon: horizon,
  condition: condition,
  createdAt: created ?? DateTime(2026, 10, 1, 12),
);

void main() {
  final people = [person('tom'), person('anna'), person('jonas')];
  final created = DateTime(2026, 11, 1, 12);

  group('the due constants', () {
    test('are 14 and 60 days', () {
      expect(soonPlanDueDays, 14);
      expect(laterPlanDueDays, 60);
    });
  });

  group('plans as picks', () {
    PlanPick? planOf(List<IntentionPick> picks, String id) {
      for (final p in picks) {
        if (p.intention.id == id && p is PlanPick) return p;
      }
      return null;
    }

    test('soon is due after 14 days, not a minute before', () {
      final soon = plan('s', 'tom', created: created, horizon: Horizon.soon);
      final before = DateTime(2026, 11, 15, 11, 59);
      final at = DateTime(2026, 11, 15, 12);
      expect(intentionPicks(people, [soon], now: before), isEmpty);
      expect(planOf(intentionPicks(people, [soon], now: at), 's'), isNotNull);
    });

    test('later is due after 60 days', () {
      final later = plan('l', 'tom', created: created, horizon: Horizon.later);
      expect(
        intentionPicks(people, [later], now: DateTime(2026, 12, 30, 11)),
        isEmpty,
      );
      expect(
        planOf(
          intentionPicks(people, [later], now: DateTime(2026, 12, 31, 12)),
          'l',
        ),
        isNotNull,
      );
    });

    test('when… plans never come up, however old', () {
      final w = plan(
        'w',
        'tom',
        created: DateTime(2020),
        horizon: Horizon.whenCondition,
        condition: 'when it is warm',
      );
      expect(intentionPicks(people, [w], now: DateTime(2030)), isEmpty);
    });

    test('a thought with a future or a passed date is no pick', () {
      final future = plan('f', 'tom', date: DateTime(2026, 12, 1));
      final past = plan('p', 'anna', date: DateTime(2026, 11, 1));
      expect(
        intentionPicks(people, [future, past], now: DateTime(2026, 11, 20)),
        isEmpty,
      );
    });

    test('plain thoughts and due plans are mixed by age, one per person', () {
      final picks = intentionPicks(people, [
        plan('plain-new', 'anna', created: DateTime(2026, 11, 10)),
        plan(
          'due-old',
          'tom',
          created: DateTime(2026, 10, 1),
          horizon: Horizon.later,
        ),
        plan('plain-old', 'jonas', created: DateTime(2026, 10, 15)),
        // Tom's newer plain thought loses to his older due plan.
        plan('tom-plain', 'tom', created: DateTime(2026, 11, 5)),
      ], now: DateTime(2026, 12, 5));
      expect(picks.map((p) => p.intention.id), [
        'due-old',
        'plain-old',
        'plain-new',
      ]);
      expect(picks.first, isA<PlanPick>());
      expect(picks.first.kind, PickKind.plan);
      expect(picks[1].kind, PickKind.intention);
    });

    test('tonightsPicks passes the time on', () {
      final soon = plan('s', 'tom', created: created, horizon: Horizon.soon);
      final args = (
        people: people,
        today: DateTime(2026, 11, 15),
        congratulated: <String>{},
      );
      expect(
        tonightsPicks(
          people: args.people,
          intentions: [soon],
          today: args.today,
          congratulated: args.congratulated,
          now: DateTime(2026, 11, 15, 12),
        ).single,
        isA<PlanPick>(),
      );
      expect(
        tonightsPicks(
          people: args.people,
          intentions: [soon],
          today: args.today,
          congratulated: args.congratulated,
          now: DateTime(2026, 11, 14),
        ),
        isEmpty,
      );
    });
  });

  group('did it happen', () {
    final planned = DateTime(2026, 11, 20);

    test('a day without a time is over when the day is', () {
      final i = plan('a', 'tom', date: planned);
      expect(didItHappen(people, [i], DateTime(2026, 11, 20, 23, 59)), isEmpty);
      expect(didItHappen(people, [i], DateTime(2026, 11, 21)), [i]);
    });

    test('a timed date passes three hours after the time', () {
      final i = plan('a', 'tom', date: DateTime(2026, 11, 20, 11));
      expect(didItHappen(people, [i], DateTime(2026, 11, 20, 13, 59)), isEmpty);
      expect(didItHappen(people, [i], DateTime(2026, 11, 20, 14)), [i]);
    });

    test('oldest first, only open dated thoughts of known people', () {
      final late = plan('late', 'tom', date: DateTime(2026, 11, 18));
      final early = plan('early', 'anna', date: DateTime(2026, 11, 10));
      final done = plan(
        'done',
        'jonas',
        date: DateTime(2026, 11, 1),
        state: IntentionState.done,
      );
      final stranger = plan('x', 'nobody', date: DateTime(2026, 11, 1));
      final undated = plan('u', 'tom', horizon: Horizon.soon);
      final future = plan('f', 'tom', date: DateTime(2026, 12, 1));
      final asked = didItHappen(people, [
        late,
        done,
        stranger,
        undated,
        future,
        early,
      ], DateTime(2026, 11, 25));
      expect(asked.map((i) => i.id), ['early', 'late']);
    });
  });

  group('the "when" of a thought', () {
    test('midnight means no time', () {
      expect(When.date(DateTime(2026, 11, 20)).hasTime, isFalse);
      expect(When.date(DateTime(2026, 11, 20, 0, 1)).hasTime, isTrue);
      expect(const When.none().isNone, isTrue);
    });

    test('whenOf reads the row', () {
      expect(whenOf(plan('a', 'tom')), const When.none());
      expect(
        whenOf(plan('a', 'tom', horizon: Horizon.later)),
        const When.horizon(Horizon.later),
      );
      expect(
        whenOf(plan('a', 'tom', date: DateTime(2026, 11, 20, 9))),
        When.date(DateTime(2026, 11, 20, 9)),
      );
    });
  });

  test('undated plans are grouped by horizon, oldest first', () {
    final groups = undatedPlans(people, [
      plan('l', 'tom', horizon: Horizon.later, created: DateTime(2026, 11, 2)),
      plan('s2', 'anna', horizon: Horizon.soon, created: DateTime(2026, 11, 5)),
      plan('s1', 'tom', horizon: Horizon.soon, created: DateTime(2026, 11, 3)),
      plan('d', 'tom', date: DateTime(2026, 12, 1), horizon: null),
      plan('x', 'nobody', horizon: Horizon.soon),
      plan('p', 'tom'),
    ]);
    expect(groups.keys, [Horizon.soon, Horizon.later]);
    expect(groups[Horizon.soon]!.map((i) => i.id), ['s1', 's2']);
    expect(groups[Horizon.later]!.map((i) => i.id), ['l']);
  });
}
