import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart';

/// Something another app shared into Kept (Android ACTION_SEND).
sealed class SharedItem {
  const SharedItem();
}

/// Shared text: a link, plain text, or both.
class SharedText extends SharedItem {
  const SharedText(this.text);

  final String text;
}

/// A shared picture, already copied into the app's own `shared/` folder by
/// ShareChannel.kt. The app never keeps the other app's URI.
class SharedImage extends SharedItem {
  const SharedImage(this.path);

  final String path;
}

/// Receives shares from other apps, behind an interface so tests can fake
/// it.
abstract class ShareReceiver {
  /// Calls [onShare] for the share that started the app, if any, and for
  /// every later one while the app runs.
  Future<void> listen(void Function(SharedItem item) onShare);

  /// The folder shared pictures are copied to; null if there is none (not
  /// Android).
  Future<Directory?> picturesDirectory();
}

/// [ShareReceiver] on the method channel of ShareChannel.kt. Kotlin keeps a
/// share until Dart takes it ("take") and says "available" when a new one
/// is waiting. Never throws.
class AndroidShareReceiver implements ShareReceiver {
  const AndroidShareReceiver();

  static const _channel = MethodChannel('de.gartenpa.kept/share');

  @override
  Future<void> listen(void Function(SharedItem item) onShare) async {
    Future<void> take() async {
      try {
        final raw = await _channel.invokeMapMethod<String, Object?>('take');
        final item = parseSharedItem(raw);
        if (item != null) onShare(item);
      } catch (e) {
        debugPrint('Share not taken: ${e.runtimeType}');
      }
    }

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'available') await take();
    });
    await take();
  }

  @override
  Future<Directory?> picturesDirectory() async {
    try {
      final path = await _channel.invokeMethod<String>('picturesDirectory');
      return path == null ? null : Directory(path);
    } catch (_) {
      return null;
    }
  }
}

/// Reads the map Kotlin sends: `{type: text, text: ...}` or
/// `{type: image, path: ...}`. Null for anything else or empty text.
SharedItem? parseSharedItem(Map<String, Object?>? raw) {
  if (raw == null) return null;
  return switch (raw['type']) {
    'text' => switch (raw['text']) {
      final String t when t.trim().isNotEmpty => SharedText(t),
      _ => null,
    },
    'image' => switch (raw['path']) {
      final String p when p.isNotEmpty => SharedImage(p),
      _ => null,
    },
    _ => null,
  };
}
