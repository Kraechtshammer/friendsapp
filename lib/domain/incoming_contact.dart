import '../data/database.dart';
import 'chat_app.dart';
import 'contact_event.dart';

/// Incoming contact through the notification listener (02-design.md §2.6
/// and §6.9). Optional part: the pure rules for the watch list and the
/// queue. See lib/platform/incoming_listener.dart for what to delete for a
/// build without the listener.

/// One person the listener watches for: their id, the names a messenger
/// may show as the title of a notification, and conversation [keys] the
/// listener can match exactly ([conversationKeysOf]).
class WatchEntry {
  const WatchEntry(this.personId, this.names, [this.keys = const []]);

  final String personId;
  final List<String> names;
  final List<String> keys;

  Map<String, Object> toJson() => {
    'id': personId,
    'names': names,
    'keys': keys,
  };

  @override
  bool operator ==(Object other) =>
      other is WatchEntry &&
      other.personId == personId &&
      _listEquals(other.names, names) &&
      _listEquals(other.keys, keys);

  @override
  int get hashCode =>
      Object.hash(personId, Object.hashAll(names), Object.hashAll(keys));

  @override
  String toString() => 'WatchEntry($personId, $names, $keys)';
}

/// The conversation keys of [p] (2026-11-18): `discord:<channel id>` from a
/// Discord DM link in the chat target (a messenger notification's
/// conversation id is that channel id), and `phone:<digits>` from a phone
/// number in international form (`+` or `00`), which WhatsApp's chat ids
/// contain (unverified). The listener matches these before names.
List<String> conversationKeysOf(Person p) {
  final keys = <String>[];
  final target = p.chatTarget;
  if (p.chatApp == ChatApp.discord && target != null) {
    final m = RegExp(r'discord(?:app)?\.com/channels/@me/(\d+)')
        .firstMatch(target);
    if (m != null) keys.add('discord:${m.group(1)}');
  }
  final phone = p.phone?.trim();
  if (phone != null && (phone.startsWith('+') || phone.startsWith('00'))) {
    var digits = phone.replaceAll(RegExp(r'\D'), '');
    if (phone.startsWith('00')) digits = digits.substring(2);
    if (digits.length >= 6) keys.add('phone:$digits');
  }
  return keys;
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
/// without any name are left out. Each entry carries the person's
/// [conversationKeysOf].
List<WatchEntry> buildWatchList(
  List<Person> people,
  Map<String, String> contactNames,
) => [
  for (final p in people)
    if (_namesOf(p, contactNames) case final names when names.isNotEmpty)
      WatchEntry(p.id, names, conversationKeysOf(p)),
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
