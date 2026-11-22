import '../data/database.dart';

/// The ids of the other people of the shared event [e] (a contact with
/// several people at once), in the order of [all]. Empty for an event that
/// is not shared.
List<String> sharedWith(Iterable<ContactEvent> all, ContactEvent e) {
  final s = e.sharedId;
  if (s == null) return const [];
  final ids = <String>[];
  for (final o in all) {
    if (o.sharedId == s &&
        o.personId != e.personId &&
        !ids.contains(o.personId)) {
      ids.add(o.personId);
    }
  }
  return ids;
}

/// "Franz", "Franz and Lucy", "Franz, Lucy and Tom". [and] puts the last
/// name after the rest in the language of the app.
String joinNames(
  List<String> names,
  String Function(String rest, String last) and,
) => names.length < 2
    ? names.join()
    : and(names.sublist(0, names.length - 1).join(', '), names.last);
