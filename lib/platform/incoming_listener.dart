import 'dart:convert';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/services.dart';

import '../domain/incoming_contact.dart';

/// Incoming contact (02-design.md §2.6 and §6.9): the app's own
/// notification listener, behind an interface so tests can fake it.
///
/// Optional part, off by default. For a build without it (Play Store),
/// delete: this file, lib/app/incoming_sync.dart,
/// lib/domain/incoming_contact.dart, the "Incoming messages" switch and
/// access rows in lib/ui/settings/settings_screen.dart, the calls in
/// lib/ui/home_shell.dart, [incomingListenerProvider] and
/// [incomingAccessProvider] in lib/app/providers.dart, and on the Android
/// side IncomingRules.kt, KeptNotificationListener.kt, IncomingChannel.kt,
/// the `service` entry in AndroidManifest.xml and the IncomingChannel line
/// in MainActivity.kt. Owed replies from "They wrote" entered by hand keep
/// working.
abstract class IncomingListener {
  /// Switches the listener's recording on or off. Off also makes it forget
  /// the watch list and the queue.
  Future<void> setEnabled(bool on);

  /// The people the listener records.
  Future<void> setWatchList(List<WatchEntry> entries);

  /// The recorded entries, oldest first; the queue is empty afterwards.
  Future<List<IncomingEntry>> takeQueue();

  /// Whether the user has granted notification access to the app.
  Future<bool> hasAccess();

  /// Opens the system's page for notification access.
  Future<void> openAccessSettings();
}

/// [IncomingListener] on the method channel of MainActivity.kt
/// (IncomingChannel.kt). Never throws: a failure counts as "nothing there".
class AndroidIncomingListener implements IncomingListener {
  const AndroidIncomingListener();

  static const _channel = MethodChannel('de.gartenpa.kept/incoming');

  @override
  Future<void> setEnabled(bool on) async {
    try {
      await _channel.invokeMethod<void>('setEnabled', {'on': on});
    } catch (_) {
      // No listener on this platform; nothing to switch.
    }
  }

  @override
  Future<void> setWatchList(List<WatchEntry> entries) async {
    try {
      await _channel.invokeMethod<void>('setWatchList', {
        'json': jsonEncode([for (final e in entries) e.toJson()]),
      });
    } catch (_) {
      // As above. No names in any message.
    }
  }

  @override
  Future<List<IncomingEntry>> takeQueue() async {
    try {
      final raw = await _channel.invokeListMethod<Object?>('takeQueue');
      return parseIncomingQueue(raw ?? const []);
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<bool> hasAccess() async {
    try {
      return await _channel.invokeMethod<bool>('hasAccess') ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> openAccessSettings() async {
    try {
      await const AndroidIntent(
        action: 'android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS',
        flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
      ).launch();
    } catch (_) {
      // Some phones lack the page; the user finds it in the settings.
    }
  }
}
