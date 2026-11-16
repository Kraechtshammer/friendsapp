import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:kept/domain/chat_link.dart';
import 'package:kept/platform/app_shortcuts.dart';
import 'package:kept/platform/chat_opener.dart';

/// [AppShortcuts] that does nothing.
class NoShortcuts implements AppShortcuts {
  @override
  Future<void> setUp({
    required String captureTitle,
    required VoidCallback onCapture,
  }) async {}
}

/// [ChatOpener] that records the links. [result] is what [open] returns.
class FakeChatOpener implements ChatOpener {
  final opened = <ChatLink>[];
  bool result = true;

  @override
  Future<bool> open(ChatLink link) async {
    opened.add(link);
    return result;
  }
}
