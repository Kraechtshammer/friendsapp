import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

/// Opens a link in the browser (an idea's or a thought's link, M10),
/// behind an interface so tests can fake it.
abstract class LinkOpener {
  /// True if something opened it.
  Future<bool> open(String link);
}

/// [LinkOpener] with `android_intent_plus`: a VIEW intent, as for chats
/// (02-design.md §8). A link without a scheme gets https; only http and
/// https links are opened.
class AndroidLinkOpener implements LinkOpener {
  const AndroidLinkOpener();

  @override
  Future<bool> open(String link) async {
    final uri = withScheme(link);
    if (!RegExp(r'^https?://', caseSensitive: false).hasMatch(uri)) {
      return false;
    }
    try {
      await AndroidIntent(
        action: 'action_view',
        data: uri,
        flags: const [Flag.FLAG_ACTIVITY_NEW_TASK],
      ).launch();
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// [link] with `https://` in front if it has no scheme.
String withScheme(String link) {
  final t = link.trim();
  return RegExp(r'^[a-z][a-z0-9+.-]*:', caseSensitive: false).hasMatch(t)
      ? t
      : 'https://$t';
}
