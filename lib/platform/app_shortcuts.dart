import 'dart:ui' show VoidCallback;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:quick_actions/quick_actions.dart';

/// The launcher icon's long-press shortcuts, behind an interface so tests
/// can fake them (02-design.md §2.1).
abstract class AppShortcuts {
  /// Registers the "capture a thought" shortcut under [captureTitle] and
  /// calls [onCapture] when the user picks it, also when it started the app.
  Future<void> setUp({
    required String captureTitle,
    required VoidCallback onCapture,
  });
}

/// [AppShortcuts] on top of `quick_actions` (Android dynamic shortcuts,
/// no icon of its own).
class QuickActionsShortcuts implements AppShortcuts {
  const QuickActionsShortcuts();

  static const _captureType = 'capture';

  @override
  Future<void> setUp({
    required String captureTitle,
    required VoidCallback onCapture,
  }) async {
    try {
      const actions = QuickActions();
      await actions.initialize((type) {
        if (type == _captureType) onCapture();
      });
      await actions.setShortcutItems([
        ShortcutItem(type: _captureType, localizedTitle: captureTitle),
      ]);
    } catch (e) {
      // A missing shortcut must never stop the app.
      debugPrint('Shortcuts not set up: $e');
    }
  }
}
