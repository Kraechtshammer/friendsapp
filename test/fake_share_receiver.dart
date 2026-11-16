import 'dart:io';

import 'package:kept/platform/link_opener.dart';
import 'package:kept/platform/share_receiver.dart';

/// [ShareReceiver] without the platform: [send] delivers a share as the
/// Kotlin channel would.
class FakeShareReceiver implements ShareReceiver {
  FakeShareReceiver({this.directory});

  /// What [picturesDirectory] returns.
  Directory? directory;

  void Function(SharedItem item)? _onShare;

  /// Shares sent before the app listened, as a share that starts the app.
  final _waiting = <SharedItem>[];

  void send(SharedItem item) {
    final onShare = _onShare;
    onShare == null ? _waiting.add(item) : onShare(item);
  }

  @override
  Future<void> listen(void Function(SharedItem item) onShare) async {
    _onShare = onShare;
    for (final item in _waiting) {
      onShare(item);
    }
    _waiting.clear();
  }

  @override
  Future<Directory?> picturesDirectory() async => directory;

  /// How often the app asked to close its screen.
  var finished = 0;

  @override
  Future<void> finish() async => finished++;
}

/// [LinkOpener] that records the links.
class FakeLinkOpener implements LinkOpener {
  final opened = <String>[];
  var result = true;

  @override
  Future<bool> open(String link) async {
    opened.add(link);
    return result;
  }
}
