import '../data/database.dart';

/// The people to offer first when picking whom an intention is about
/// (02-design.md §2.1, step 2): those with the most recent intention first
/// (by its `createdAt`, in any state), then the rest by when they were
/// added, newest first. Ties go by name. At most [limit] people.
List<Person> recentPeople(
  List<Person> people,
  List<Intention> intentions, {
  int limit = 4,
}) {
  final latest = <String, DateTime>{};
  for (final i in intentions) {
    final seen = latest[i.personId];
    if (seen == null || i.createdAt.isAfter(seen)) {
      latest[i.personId] = i.createdAt;
    }
  }
  int byName(Person a, Person b) {
    final c = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    return c != 0 ? c : a.id.compareTo(b.id);
  }

  final sorted = [...people]
    ..sort((a, b) {
      final la = latest[a.id];
      final lb = latest[b.id];
      if (la != null && lb != null) {
        final c = lb.compareTo(la);
        return c != 0 ? c : byName(a, b);
      }
      if (la != null) return -1;
      if (lb != null) return 1;
      final c = b.createdAt.compareTo(a.createdAt);
      return c != 0 ? c : byName(a, b);
    });
  return sorted.take(limit).toList();
}
