import '../data/database.dart';
import 'person.dart';

/// Where "Open chat" goes: the messenger's Android package and, when the
/// person has the handle that messenger needs, a link to their chat.
/// Without [uri] the app just opens the messenger (02-design.md §8).
class ChatLink {
  const ChatLink({required this.package, this.uri});

  final String package;
  final String? uri;

  @override
  bool operator ==(Object other) =>
      other is ChatLink && other.package == package && other.uri == uri;

  @override
  int get hashCode => Object.hash(package, uri);

  @override
  String toString() => 'ChatLink($package, $uri)';
}

/// The link for the person's main messenger, or null if they have none.
ChatLink? chatLink(Person person) {
  final messenger = person.mainMessenger;
  if (messenger == null) return null;
  final digits = _digits(person.phone);
  return switch (messenger) {
    Messenger.whatsapp => ChatLink(
      package: 'com.whatsapp',
      uri: digits == null ? null : 'https://wa.me/$digits',
    ),
    Messenger.telegram => ChatLink(
      package: 'org.telegram.messenger',
      uri: _telegram(person.telegramUsername, digits),
    ),
    Messenger.signal => ChatLink(
      package: 'org.thoughtcrime.securesms',
      uri:
          _clean(person.signalLink) ??
          (digits == null ? null : 'https://signal.me/#p/+$digits'),
    ),
    Messenger.discord => ChatLink(
      package: 'com.discord',
      uri: _discord(person.discordUserId),
    ),
  };
}

String? _clean(String? s) {
  final t = s?.trim();
  return t == null || t.isEmpty ? null : t;
}

String? _digits(String? phone) {
  final d = phone?.replaceAll(RegExp(r'\D'), '');
  return d == null || d.isEmpty ? null : d;
}

String? _telegram(String? username, String? digits) {
  var name = _clean(username);
  if (name != null && name.startsWith('@')) name = name.substring(1).trim();
  if (name != null && name.isNotEmpty) return 'https://t.me/$name';
  return digits == null ? null : 'https://t.me/+$digits';
}

String? _discord(String? id) {
  final t = _clean(id);
  return t == null ? null : 'https://discord.com/users/$t';
}
