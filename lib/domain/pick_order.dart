import '../data/database.dart';
import 'birthdays.dart';
import 'owed_reply.dart';
import 'plans.dart';

/// Where a pick comes from (02-design.md §2.4). The reconnect person and
/// rhythms will add their own kinds.
enum PickKind { birthday, reply, intention, plan }

/// One thing to suggest tonight: a person and the reason.
sealed class Pick {
  const Pick(this.person);

  final Person person;

  PickKind get kind;
}

/// It is [person]'s birthday today and the user has not congratulated yet
/// (§2.4, step 1).
class BirthdayPick extends Pick {
  const BirthdayPick(super.person, {this.age});

  /// The age turned today, if the birth year is known.
  final int? age;

  @override
  PickKind get kind => PickKind.birthday;
}

/// [person] wrote and may still wait for a reply (§2.4, step 2; §2.6): the
/// card asks "Still owe NAME a reply?". [since] is the time of their
/// message ([owedSince]).
class ReplyPick extends Pick {
  const ReplyPick(super.person, {required this.since});

  final DateTime since;

  @override
  PickKind get kind => PickKind.reply;
}

/// One of the user's own open intentions (§2.4, step 4).
class IntentionPick extends Pick {
  const IntentionPick(super.person, this.intention);

  final Intention intention;

  @override
  PickKind get kind => PickKind.intention;
}

/// An undated plan that is due (02-design.md §6.10, [isPlanDue]): the card
/// asks "Want to set a date with NAME?". It is an [IntentionPick] too, so
/// Open chat, Done and the rest work as for a thought.
class PlanPick extends IntentionPick {
  const PlanPick(super.person, super.intention);

  @override
  PickKind get kind => PickKind.plan;
}

/// Tonight's picks, in order: birthdays on the local day of [today] of
/// people not in [congratulated] (in the order of [people]), then the owed
/// replies [owed] (from [owedReplies], longest owed first), then the plain
/// thoughts and the due plans ([intentionPicks]). At most one pick per
/// person: a person with an earlier pick has no later one until that is
/// gone. [now] is the time for the due plans; it defaults to [today].
List<Pick> tonightsPicks({
  required List<Person> people,
  required List<Intention> intentions,
  required DateTime today,
  required Set<String> congratulated,
  List<OwedReply> owed = const [],
  DateTime? now,
}) {
  final birthdays = [
    for (final p in birthdaysOn(people, today))
      if (!congratulated.contains(p.id))
        BirthdayPick(p, age: ageTurned(p.birthdayYear, today)),
  ];
  final taken = {for (final b in birthdays) b.person.id};
  final replies = [
    for (final o in owed)
      if (taken.add(o.person.id)) ReplyPick(o.person, since: o.since),
  ];
  return [
    ...birthdays,
    ...replies,
    for (final i in intentionPicks(people, intentions, now: now ?? today))
      if (!taken.contains(i.person.id)) i,
  ];
}

/// The picks from the user's own intentions (02-design.md §2.4, step 4 and
/// §6.10), oldest first, at most one per person (their oldest):
///
/// - plain open thoughts (no date, no horizon), and
/// - undated plans that are due at [now]: "soon" [soonPlanDueDays] days
///   after they were made, "later" [laterPlanDueDays] days after
///   ([PlanPick]).
///
/// Never a pick: "when…" plans, anything with a date (a future one waits
/// on the Upcoming tab, a passed one is asked about as "Did it happen?"),
/// and anything not open. Without [now] no plan is due. Intentions of
/// people that are not in [people] are left out. Ties go by id, so the
/// order is stable.
List<IntentionPick> intentionPicks(
  List<Person> people,
  List<Intention> intentions, {
  DateTime? now,
}) {
  final byId = {for (final p in people) p.id: p};
  final sorted =
      [
        for (final i in intentions)
          if (byId.containsKey(i.personId) &&
              (isPlainThought(i) || (now != null && isPlanDue(i, now))))
            i,
      ]..sort((a, b) {
        final c = a.createdAt.compareTo(b.createdAt);
        return c != 0 ? c : a.id.compareTo(b.id);
      });
  final seen = <String>{};
  return [
    for (final i in sorted)
      if (seen.add(i.personId))
        isPlainThought(i)
            ? IntentionPick(byId[i.personId]!, i)
            : PlanPick(byId[i.personId]!, i),
  ];
}
