// Throwaway code for the "Phone checks" screen. Delete it together with
// lib/ui/checks/ and the Kotlin files beside MainActivity.kt once the
// checks on the phone are done.

import 'dart:io';
import 'dart:ui' show DartPluginRegistrant;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

const _channelId = 'checks';
const _channelName = 'Phone checks';
const _buttonsNotificationId = 1;
const _actionsFileName = 'check_actions.txt';

final _plugin = FlutterLocalNotificationsPlugin();

AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
    .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin
    >();

/// Sets up the time zone and the notification plugin. Called once from
/// main(); the caller catches errors so the app always opens.
Future<void> initPhoneChecks() async {
  await initTimeZone();
  await _plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
    onDidReceiveNotificationResponse: (response) =>
        _logAction(response, 'foreground'),
    onDidReceiveBackgroundNotificationResponse: onCheckActionInBackground,
  );
  await _android?.createNotificationChannel(
    const AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.high,
    ),
  );
}

/// The device's time zone; falls back to Europe/Berlin, never throws.
Future<void> initTimeZone() async {
  try {
    tz_data.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (e) {
      debugPrint('Time zone lookup failed: $e');
      tz.setLocalLocation(tz.getLocation('Europe/Berlin'));
    }
  } catch (e) {
    debugPrint('Time zone setup failed: $e');
  }
}

/// Button presses while the app isn't running. Runs in a background isolate.
@pragma('vm:entry-point')
Future<void> onCheckActionInBackground(NotificationResponse response) async {
  DartPluginRegistrant.ensureInitialized();
  await _logAction(response, 'background');
}

Future<void> _logAction(NotificationResponse response, String where) async {
  try {
    final file = await _actionsFile();
    final action = response.actionId ?? '(tap)';
    await file.writeAsString(
      '${DateTime.now().toIso8601String()} $action ($where)\n',
      mode: FileMode.append,
      flush: true,
    );
  } catch (e) {
    debugPrint('Writing the action log failed: $e');
  }
}

Future<File> _actionsFile() async {
  final dir = await getApplicationSupportDirectory();
  return File('${dir.path}/$_actionsFileName');
}

/// Asks for the notification permission if needed. Returns whether
/// notifications are allowed.
Future<bool> ensureNotificationPermission() async {
  final android = _android;
  if (android == null) return false;
  if (await android.areNotificationsEnabled() ?? false) return true;
  return await android.requestNotificationsPermission() ?? false;
}

String hhmmss(DateTime t) =>
    [t.hour, t.minute, t.second].map((v) => '$v'.padLeft(2, '0')).join(':');

/// Check 1: schedules a notification in [delay], inexact but allowed in
/// Doze. Returns the time it was scheduled for.
Future<DateTime> scheduleCheck(Duration delay) async {
  final at = tz.TZDateTime.now(tz.local).add(delay);
  final id = 100 + (DateTime.now().millisecondsSinceEpoch ~/ 1000) % 100000;
  await _plugin.zonedSchedule(
    id: id,
    title: 'Check: in ${delay.inMinutes} min',
    body: 'Scheduled for ${hhmmss(at)}',
    scheduledDate: at,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
  );
  return at;
}

Future<List<PendingNotificationRequest>> pendingChecks() =>
    _plugin.pendingNotificationRequests();

/// Check 2: a notification with two buttons that don't open the app.
Future<void> showButtonsNotification() => _plugin.show(
  id: _buttonsNotificationId,
  title: 'Check: buttons',
  body: 'Tap "Yes" or "Not today". The app should not open.',
  notificationDetails: const NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.high,
      priority: Priority.high,
      actions: [
        AndroidNotificationAction(
          'yes',
          'Yes',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'not_today',
          'Not today',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    ),
  ),
);

Future<List<String>> actionLog() async {
  final file = await _actionsFile();
  if (!await file.exists()) return [];
  return (await file.readAsLines()).where((l) => l.isNotEmpty).toList();
}

Future<void> clearActionLog() async {
  final file = await _actionsFile();
  if (await file.exists()) await file.delete();
}

/// Checks 4 and 5: the Kotlin side in MainActivity.kt.
const _channel = MethodChannel('de.gartenpa.kept/checks');

Future<bool> listenerEnabled() async =>
    await _channel.invokeMethod<bool>('listenerEnabled') ?? false;

Future<void> openListenerSettings() =>
    _channel.invokeMethod<void>('openListenerSettings');

Future<List<String>> listenerLog() async =>
    await _channel.invokeListMethod<String>('listenerLog') ?? [];

Future<void> clearListenerLog() =>
    _channel.invokeMethod<void>('clearListenerLog');

/// PNG bytes of the app's launcher icon, or null if it isn't installed.
Future<Uint8List?> appIcon(String package) =>
    _channel.invokeMethod<Uint8List>('appIcon', {'package': package});
