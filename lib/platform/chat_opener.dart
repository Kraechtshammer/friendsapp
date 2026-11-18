import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

import '../domain/chat_link.dart';

/// Opens a chat in a messenger app, behind an interface so tests can fake
/// it.
abstract class ChatOpener {
  /// True if something was opened. False if the messenger is not installed.
  Future<bool> open(ChatLink link);
}

/// [ChatOpener] with `android_intent_plus`: a VIEW intent with the link
/// and the messenger's package set (SENDTO without a package for SMS). Without a link, or if that fails,
/// the messenger's main screen is opened.
class AndroidChatOpener implements ChatOpener {
  const AndroidChatOpener();

  @override
  Future<bool> open(ChatLink link) async {
    final uri = link.uri;
    if (uri != null) {
      try {
        await AndroidIntent(
          // SMS links go to the default SMS app through SENDTO.
          action: uri.startsWith('smsto:')
              ? 'android.intent.action.SENDTO'
              : 'action_view',
          data: uri,
          package: link.package,
          flags: const [Flag.FLAG_ACTIVITY_NEW_TASK],
        ).launch();
        return true;
      } catch (_) {
        // Fall through to the plain app.
      }
    }
    if (link.package == null) return false;
    try {
      await AndroidIntent(
        action: 'android.intent.action.MAIN',
        category: 'android.intent.category.LAUNCHER',
        package: link.package,
        flags: const [Flag.FLAG_ACTIVITY_NEW_TASK],
      ).launch();
      return true;
    } catch (_) {
      return false;
    }
  }
}
