import '../data/database.dart';
import 'group.dart';
import 'intention.dart';

/// Dates and plans of intentions (02-design.md §6.9 and §6.10) as pure
/// functions. Days are local calendar days; nothing here reads the clock.

/// A "soon" plan comes back as a pick this many days after it was made
/// (02-design.md §6.10: about two weeks).
const soonPlanDueDays = 14;

/// A "later" plan comes back as a pick this many days after it was made
/// (about two months).
const laterPlanDueDays = 60;

/// How long after a planned time the app waits before asking "Did it
/// happen?". A day without a time is over at the end of that day.
const didItHappenAfterHours = 3;

/// The "when" an intention has now.
When whenOf(Intention i) => i.date != null
    ? When.date(i.date!)
    : i.horizon == null
    ? const When.none()
    : When.horizon(i.horizon!, condition: i.condition);

/// An open thought with no date and no horizon: the plain kind that is a
/// pick from the start.
bool isPlainThought(Intention i) =>
    i.state == IntentionState.open && i.date == null && i.horizon == null;

/// An open plan: no date, but a horizon.
bool isUndatedPlan(Intention i) =>
    i.state == IntentionState.open && i.date == null && i.horizon != null;

/// The moment from which a "soon" or "later" plan made at [createdAt] is
/// due; null for a "when…" plan, which never comes up by itself.
DateTime? planDueFrom(Horizon horizon, DateTime createdAt) => switch (horizon) {
  Horizon.soon => _plusDays(createdAt, soonPlanDueDays),
  Horizon.later => _plusDays(createdAt, laterPlanDueDays),
  Horizon.whenCondition => null,
};

/// Whether the undated plan [i] is due as a pick at [now].
bool isPlanDue(Intention i, DateTime now) {
  if (!isUndatedPlan(i)) return false;
  final from = planDueFrom(i.horizon!, i.createdAt);
  return from != null && !now.isBefore(from);
}

/// Calendar arithmetic: the same time of day [days] days later.
DateTime _plusDays(DateTime t, int days) =>
    DateTime(t.year, t.month, t.day + days, t.hour, t.minute, t.second);

/// The moment from which the planned [date] counts as passed: three hours
/// after a timed date, the start of the next day for a day without a time.
DateTime passedFrom(DateTime date) => dateHasTime(date)
    ? date.add(const Duration(hours: didItHappenAfterHours))
    : DateTime(date.year, date.month, date.day + 1);

/// Whether the planned [date] has passed at [now] (see [passedFrom]).
bool hasPassed(DateTime date, DateTime now) => !now.isBefore(passedFrom(date));

/// The open, dated intentions of people in [people] whose date has passed
/// at [now], oldest date first: the ones to ask "Did it happen?" about.
/// Ties go by id, so the order is stable. A couple's thought ([couples]:
/// group id to couple) counts when one of its members is in [people].
List<Intention> didItHappen(
  List<Person> people,
  List<Intention> intentions,
  DateTime now, {
  Map<String, GroupWithMembers> couples = const {},
}) {
  final byId = {for (final p in people) p.id: p};
  return [
    for (final i in intentions)
      if (i.state == IntentionState.open &&
          i.date != null &&
          subjectOf(i, byId, couples) != null &&
          hasPassed(i.date!, now))
        i,
  ]..sort((a, b) {
    final c = a.date!.compareTo(b.date!);
    return c != 0 ? c : a.id.compareTo(b.id);
  });
}

/// The open undated plans of people in [people], by horizon, oldest first
/// inside each group. Empty groups are left out. Couples as in
/// [didItHappen].
Map<Horizon, List<Intention>> undatedPlans(
  List<Person> people,
  List<Intention> intentions, {
  Map<String, GroupWithMembers> couples = const {},
}) {
  final byId = {for (final p in people) p.id: p};
  final sorted =
      [
        for (final i in intentions)
          if (isUndatedPlan(i) && subjectOf(i, byId, couples) != null) i,
      ]..sort((a, b) {
        final c = a.createdAt.compareTo(b.createdAt);
        return c != 0 ? c : a.id.compareTo(b.id);
      });
  return {
    for (final h in Horizon.values)
      if (sorted.any((i) => i.horizon == h))
        h: [
          for (final i in sorted)
            if (i.horizon == h) i,
        ],
  };
}
