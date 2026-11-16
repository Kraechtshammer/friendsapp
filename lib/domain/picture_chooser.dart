/// Which people the "whose picture is this?" list shows, and in what order
/// (share a photo into Kept., docs/04-architecture.md).
library;

import '../data/database.dart';

/// People without a picture first (they are who the user is working
/// through), then the rest; each group A to Z by name, ignoring case.
/// [query], if not blank, keeps only names or nicknames that contain it,
/// ignoring case.
List<Person> pictureChooserOrder(List<Person> people, {String query = ''}) {
  final q = query.trim().toLowerCase();
  bool matches(Person p) =>
      q.isEmpty ||
      p.name.toLowerCase().contains(q) ||
      (p.nickname?.toLowerCase().contains(q) ?? false);
  final shown = people.where(matches).toList();
  int byName(Person a, Person b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());
  return [
    ...shown.where((p) => p.photo == null).toList()..sort(byName),
    ...shown.where((p) => p.photo != null).toList()..sort(byName),
  ];
}

/// How many of [people] have no picture.
int withoutPicture(Iterable<Person> people) =>
    people.where((p) => p.photo == null).length;
