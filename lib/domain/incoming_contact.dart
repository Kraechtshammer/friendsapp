import '../data/database.dart';
import 'contact_event.dart';

/// Incoming contact through the notification listener (02-design.md §2.6
/// and §6.9). Optional part: the pure rules for the watch list and the
/// queue. See lib/platform/incoming_listener.dart for what to delete for a
/// build without the listener.

/// One person the listener watches for: their id and the names a messenger
/// may show as the title of a notification.
class WatchEntry {
  const WatchEntry(this.personId, this.names);

  final String personId;
  final List<String> names;

  Map<String, Object> toJson() => {'id': personId, 'names': names};

  @override
  bool operator ==(Object other) =>
      other is WatchEntry &&
      other.personId == personId &&
      _listEquals(other.names, names);

  @override
  int get hashCode => Object.hash(personId, Object.hashAll(names));

  @override
  String toString() => 'WatchEntry($personId, $names)';
}

bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// The watch list: per person their name in the app and, when they are
/// linked to a phone contact found in [contactNames] (contact id to
/// display name) under a different name, that name too. Names are trimmed;
/// empty names and ones that differ only in case are left out. People
/// without any name are left out.
List<WatchEntry> buildWatchList(
  List<Person> people,
  Map<String, String> contactNames,
) => [
  for (final p in people)
    if (_namesOf(p, contactNames) case final names when names.isNotEmpty)
      WatchEntry(p.id, names),
];

List<String> _namesOf(Person p, Map<String, String> contactNames) {
  final names = <String>[];
  final seen = <String>{};
  for (final raw in [p.name, ?contactNames[p.contactId]]) {
    final name = raw.trim();
    if (name.isEmpty || !seen.add(name.toLowerCase())) continue;
    names.add(name);
  }
  return names;
}

/// One entry of the listener's queue: [personId] wrote or called at [at].
class IncomingEntry {
  const IncomingEntry(this.personId, this.kind, this.at);

  final String personId;

  /// [ContactKind.wrote] or [ContactKind.called].
  final ContactKind kind;
  final DateTime at;
}

/// The queue as the platform sends it: maps with `personId`, `kind`
/// ("wrote" or "called") and `time` (milliseconds since the epoch). Anything
/// else is skipped.
List<IncomingEntry> parseIncomingQueue(List<Object?> raw) => [
  for (final item in raw)
    if (item is Map &&
        item['personId'] is String &&
        (item['personId'] as String).isNotEmpty &&
        item['time'] is int &&
        (item['time'] as int) > 0)
      if (switch (item['kind']) {
            'wrote' => ContactKind.wrote,
            'called' => ContactKind.called,
            _ => null,
          }
          case final kind?)
        IncomingEntry(
          item['personId'] as String,
          kind,
          DateTime.fromMillisecondsSinceEpoch(item['time'] as int),
        ),
];
