import '../data/database.dart';
import 'birthdays.dart';
import 'intention.dart';

/// Where a pick comes from (02-design.md §2.4). Owed replies, the
/// reconnect person and rhythms will add their own kinds.
enum PickKind { birthday, intention }

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

/// One of the user's own open intentions (§2.4, step 4).
class IntentionPick extends Pick {
  const IntentionPick(super.person, this.intention);

  final Intention intention;

  @override
  PickKind get kind => PickKind.intention;
}

/// Tonight's picks, in order: birthdays on the local day of [today] of
/// people not in [congratulated] (in the order of [people]), then the open
/// intentions ([intentionPicks]). At most one pick per person: a person
/// with a birthday pick has no intention pick until the birthday pick is
/// gone.
List<Pick> tonightsPicks({
  required List<Person> people,
  required List<Intention> intentions,
  required DateTime today,
  required Set<String> congratulated,
}) {
  final birthdays = [
    for (final p in birthdaysOn(people, today))
      if (!congratulated.contains(p.id))
        BirthdayPick(p, age: ageTurned(p.birthdayYear, today)),
  ];
  final taken = {for (final b in birthdays) b.person.id};
  return [
    ...birthdays,
    for (final i in intentionPicks(people, intentions))
      if (!taken.contains(i.person.id)) i,
  ];
}

/// The picks from the user's own open intentions (02-design.md §2.4, step
/// 4): oldest first, at most one per person (their oldest). Intentions of
/// people that are not in [people], and intentions that are not open, are
/// left out. Ties go by id, so the order is stable.
List<IntentionPick> intentionPicks(
  List<Person> people,
  List<Intention> intentions,
) {
  final byId = {for (final p in people) p.id: p};
  final sorted =
      [
        for (final i in intentions)
          if (i.state == IntentionState.open && byId.containsKey(i.personId)) i,
      ]..sort((a, b) {
        final c = a.createdAt.compareTo(b.createdAt);
        return c != 0 ? c : a.id.compareTo(b.id);
      });
  final seen = <String>{};
  return [
    for (final i in sorted)
      if (seen.add(i.personId)) IntentionPick(byId[i.personId]!, i),
  ];
}
