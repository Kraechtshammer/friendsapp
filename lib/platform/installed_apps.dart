import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../domain/chat_app.dart';

/// Which chat apps are on the phone (02-design.md §8, 2026-11-18). Behind
/// an interface so tests can fake it. Native side: InstalledAppsChannel.kt.
abstract class InstalledApps {
  Future<InstalledChatApps> chatApps();
}

/// The installed packages of the apps in [ChatApp], and whether an SMS app
/// exists.
class InstalledChatApps {
  const InstalledChatApps(this.packages, {required this.sms});

  /// Everything counts as installed: used when the phone cannot be asked.
  static final all = InstalledChatApps({
    for (final app in ChatApp.values) ...app.packages,
  }, sms: true);

  final Set<String> packages;
  final bool sms;

  bool has(ChatApp app) =>
      app == ChatApp.sms ? sms : app.packages.any(packages.contains);

  /// The apps to offer in a choice: the installed ones in list order, and
  /// [current] even when it is not installed, so a choice never vanishes.
  List<ChatApp> choices(ChatApp? current) => [
    for (final app in ChatApp.values)
      if (has(app) || app == current) app,
  ];

  /// The package to open [app] with: the first installed one (WhatsApp
  /// before WhatsApp Business), else the main one; null for SMS.
  String? packageFor(ChatApp app) {
    for (final p in app.packages) {
      if (packages.contains(p)) return p;
    }
    return app.packages.isEmpty ? null : app.packages.first;
  }
}

/// [InstalledApps] over the method channel `de.gartenpa.kept/installedApps`.
class AndroidInstalledApps implements InstalledApps {
  const AndroidInstalledApps();

  static const _channel = MethodChannel('de.gartenpa.kept/installedApps');

  @override
  Future<InstalledChatApps> chatApps() async {
    try {
      final found = await _channel.invokeListMethod<String>('installed', {
        'packages': [for (final app in ChatApp.values) ...app.packages],
      });
      final sms = await _channel.invokeMethod<bool>('hasSmsApp');
      return InstalledChatApps({...?found}, sms: sms ?? true);
    } catch (e) {
      debugPrint('Installed apps not read: ${e.runtimeType}');
      return InstalledChatApps.all;
    }
  }
}
