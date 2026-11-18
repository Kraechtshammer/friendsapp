import 'chat_app.dart';

/// One data row of a phone contact that is not one of Android's own kinds:
/// an entry a messenger wrote (WhatsApp, Signal, Telegram, ...) or a
/// Website entry. [id] changes when the contact syncs again, so it is
/// never stored.
class ContactEntry {
  const ContactEntry({
    required this.id,
    required this.mimeType,
    this.value,
    this.label,
  });

  final String id;
  final String mimeType;

  /// data1: the URL for a Website entry; for messenger entries often an
  /// account id or the number.
  final String? value;

  /// data3: the text Contacts shows, such as "Message +49 170 ...".
  final String? label;

  static const websiteMimeType = 'vnd.android.cursor.item/website';
}

/// A way to reach a person in [app] that their contact holds: either the
/// messenger's own [entry], or a chat [link] from the Website field.
class ContactRoute {
  const ContactRoute(this.app, {this.entry, this.link});

  final ChatApp app;
  final ContactEntry? entry;
  final String? link;

  @override
  bool operator ==(Object other) =>
      other is ContactRoute &&
      other.app == app &&
      other.entry?.id == entry?.id &&
      other.link == link;

  @override
  int get hashCode => Object.hash(app, entry?.id, link);

  @override
  String toString() => 'ContactRoute(${app.name}, ${entry?.id}, $link)';
}

/// The routes in [entries], in the order of [ChatApp.values]: per app the
/// messenger's own entry first, then each Website link that belongs to
/// the app. Website links of no known app and other entries are left out.
List<ContactRoute> contactRoutes(List<ContactEntry> entries) {
  final routes = <ContactRoute>[];
  for (final app in ChatApp.values) {
    final mime = app.contactMimeType;
    if (mime != null) {
      for (final e in entries) {
        if (e.mimeType == mime) {
          routes.add(ContactRoute(app, entry: e));
          break;
        }
      }
    }
    for (final e in entries) {
      if (e.mimeType != ContactEntry.websiteMimeType) continue;
      final link = _asLink(e.value);
      if (link != null && ChatApp.forLink(link) == app) {
        routes.add(ContactRoute(app, link: link));
      }
    }
  }
  return routes;
}

/// A Website value as a link: one without a scheme gets `https://`.
String? _asLink(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return null;
  return v.contains(':') ? v : 'https://$v';
}
