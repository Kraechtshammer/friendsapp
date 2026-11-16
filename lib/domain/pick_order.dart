import '../data/database.dart';
import 'birthdays.dart';
import 'owed_reply.dart';
import 'person.dart';
import 'plans.dart';
import 'rhythm.dart';

/// Where a pick comes from (02-design.md §2.4).
enum PickKind { birthday, reply, reconnect, intention, plan, hint }

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

/// The reconnect person of the current span (§2.4, step 3): the card says "This
/// week: NAME" until the user has been in touch in that span.
class ReconnectPick extends Pick {
  const ReconnectPick(super.person);

  @override
  PickKind get kind => PickKind.reconnect;
}

/// A person whose rhythm says it has been a while (§2.4, step 5; F8,
/// [peopleDueForHint]). The card says "It's been a while with NAME", with no
/// number. There is nothing to tick off, so it has no Done.
class HintPick extends Pick {
  const HintPick(super.person);

  @override
  PickKind get kind => PickKind.hint;
}

/// One of the user's own open intentions (§2.4, step 4). For a couple's
/// intention [person] is the first member and [members] are all of them,
/// in order; for one person's intention [members] is empty.
class IntentionPick extends Pick {
  const IntentionPick(super.person, this.intention, {this.members = const []});

  final Intention intention;
  final List<Person> members;

  @override
  PickKind get kind => PickKind.intention;
}

/// An undated plan that is due (02-design.md §6.10, [isPlanDue]): the card
/// asks "Want to set a date with NAME?". It is an [IntentionPick] too, so
/// Open chat, Done and the rest work as for a thought.
class PlanPick extends IntentionPick {
  const PlanPick(super.person, super.intention, {super.members});

  @override
  PickKind get kind => PickKind.plan;
}

/// Tonight's picks, in order: birthdays on the local day of [today] of
/// people not in [congratulated] (in the order of [people]), then the owed
/// replies [owed] (from [owedReplies], longest owed first), then the
/// [reconnect] person of the span, then the plain thoughts and the due
/// plans ([intentionPicks]), and last at most one [HintPick].
///
/// The hint is chosen only when [classRhythms] is given: from the people
/// due ([peopleDueForHint], with [events]) by the rotation of the day
/// ([hintPersonFor]), leaving out everyone with an earlier pick and
/// everyone with an open thought or plan in [intentions], with or without
/// a date. At most one pick per person: a person with an earlier pick has
/// no later one until that is gone. A couple's thought ([groupMembers]:
/// group id to member ids in order) counts for all its members here. [now]
/// is the time for the due plans and the hint; it defaults to [today].
List<Pick> tonightsPicks({
  required List<Person> people,
  required List<Intention> intentions,
  required DateTime today,
  required Set<String> congratulated,
  List<OwedReply> owed = const [],
  Person? reconnect,
  Iterable<ContactEvent> events = const [],
  Map<Closeness, int?>? classRhythms,
  Map<String, List<String>> groupMembers = const {},
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
  final reconnectPick = reconnect == null || !taken.add(reconnect.id)
      ? null
      : ReconnectPick(reconnect);
  Iterable<String> whoOf(Intention i) =>
      i.personId != null ? [i.personId!] : groupMembers[i.groupId] ?? const [];
  final thoughts = [
    for (final i in intentionPicks(
      people,
      intentions,
      now: now ?? today,
      groupMembers: groupMembers,
    ))
      if (!whoOf(i.intention).any(taken.contains)) i,
  ];
  taken
    ..addAll(thoughts.expand((i) => whoOf(i.intention)))
    ..addAll(intentions.expand(whoOf));
  final hint = classRhythms == null
      ? null
      : hintPersonFor([
          for (final p in peopleDueForHint(
            people,
            events,
            classRhythms,
            now ?? today,
          ))
            if (!taken.contains(p.id)) p,
        ], today);
  return [
    ...birthdays,
    ...replies,
    ?reconnectPick,
    ...thoughts,
    if (hint != null) HintPick(hint),
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
///
/// A couple's intention (`groupId` set) is treated like a person's, keyed
/// by the group: at most one pick per group. Its members come from
/// [groupMembers] (group id to member ids in order); those not in [people]
/// are left out, and a group without any is left out.
List<IntentionPick> intentionPicks(
  List<Person> people,
  List<Intention> intentions, {
  DateTime? now,
  Map<String, List<String>> groupMembers = const {},
}) {
  final byId = {for (final p in people) p.id: p};
  List<Person> membersOf(Intention i) => [
    for (final id in groupMembers[i.groupId] ?? const <String>[]) ?byId[id],
  ];
  // The person or group an intention is for; null if not known.
  String? keyOf(Intention i) {
    if (i.personId != null) {
      return byId.containsKey(i.personId) ? 'p:${i.personId}' : null;
    }
    return membersOf(i).isEmpty ? null : 'g:${i.groupId}';
  }

  final sorted =
      [
        for (final i in intentions)
          if (keyOf(i) != null &&
              (isPlainThought(i) || (now != null && isPlanDue(i, now))))
            i,
      ]..sort((a, b) {
        final c = a.createdAt.compareTo(b.createdAt);
        return c != 0 ? c : a.id.compareTo(b.id);
      });
  final seen = <String>{};
  return [
    for (final i in sorted)
      if (seen.add(keyOf(i)!))
        if (i.personId != null)
          isPlainThought(i)
              ? IntentionPick(byId[i.personId]!, i)
              : PlanPick(byId[i.personId]!, i)
        else
          isPlainThought(i)
              ? IntentionPick(membersOf(i).first, i, members: membersOf(i))
              : PlanPick(membersOf(i).first, i, members: membersOf(i)),
  ];
}
