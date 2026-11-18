import '../data/database.dart';
import 'chat_app.dart';

/// Where "Open chat" goes: the messenger's Android package and, when the
/// person has a chat target or a phone number the app can use, a link to
/// their chat. Without [uri] the app just opens the messenger. [package] is
/// null for SMS: the phone's default SMS app answers the link
/// (02-design.md §8, 2026-11-18).
class ChatLink {
  const ChatLink({required this.package, this.uri});

  final String? package;
  final String? uri;

  @override
  bool operator ==(Object other) =>
      other is ChatLink && other.package == package && other.uri == uri;

  @override
  int get hashCode => Object.hash(package, uri);

  @override
  String toString() => 'ChatLink($package, $uri)';
}

/// The link for the person's messenger, or null if they have none. The
/// chat target comes first, then the phone number (`chatLinks`). The
/// contact's own messenger entry joins this order in a later step.
ChatLink? chatLink(Person person) {
  final app = person.chatApp;
  if (app == null) return null;
  final links = chatLinks(app, target: person.chatTarget, phone: person.phone);
  return ChatLink(
    package: app.packages.isEmpty ? null : app.packages.first,
    uri: links.isEmpty ? null : links.first,
  );
}
