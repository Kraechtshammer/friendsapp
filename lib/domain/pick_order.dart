import '../data/database.dart';
import 'intention.dart';

/// One thing to suggest tonight: a person and the reason. For now the only
/// reason is one of the user's own open intentions; birthdays, owed replies
/// and rhythms (02-design.md §2.4) will add their own sources here.
class Pick {
  const Pick(this.person, this.intention);

  final Person person;
  final Intention intention;
}

/// The picks from the user's own open intentions (02-design.md §2.4, step
/// 4): oldest first, at most one per person (their oldest). Intentions of
/// people that are not in [people], and intentions that are not open, are
/// left out. Ties go by id, so the order is stable.
///
/// Pure, so the other sources can be put in front of this list later.
List<Pick> intentionPicks(List<Person> people, List<Intention> intentions) {
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
      if (seen.add(i.personId)) Pick(byId[i.personId]!, i),
  ];
}
