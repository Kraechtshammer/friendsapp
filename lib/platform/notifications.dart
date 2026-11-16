import 'dart:async';
import 'dart:ui' show DartPluginRegistrant;

import 'package:flutter/foundation.dart' show ValueChanged, debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../app/theme.dart' show KeptColors;
import '../data/database_connection.dart';
import '../data/day_answers_repository.dart';
import '../domain/contact_event.dart';
import '../domain/evening_question.dart';

/// The app's notifications, behind an interface so tests can fake them.
/// For now only the evening question (02-design.md §2.2).
abstract class Notifications {
  /// Sets the plugin up. [onAnswer] gets the answers that reach the running
  /// app: "Yes" and a tap on the notification, also when one of them
  /// started the app. "Not today" does not open the app; it is stored by
  /// [onEveningResponseInBackground].
  Future<void> setUp({required ValueChanged<DayAnswerValue> onAnswer});

  /// Makes the scheduled evening notifications match [plan]: one weekly
  /// notification per weekday in it, none on the others.
  Future<void> scheduleEvening(EveningPlan plan);

  /// Whether the app may show notifications.
  Future<bool> areEnabled();

  /// Asks for the permission (Android 13 and later). Returns whether
  /// notifications are allowed afterwards.
  Future<bool> requestPermission();

  /// Opens the app's notification settings in the phone's settings.
  Future<void> openSettings();
}

/// [Notifications] on top of `flutter_local_notifications`. Scheduling is
/// inexact on purpose: the app has no exact-alarm permission
/// (02-design.md §8, notification timing). The plugin's boot receiver in
/// the manifest schedules them again after a restart.
class LocalNotifications implements Notifications {
  LocalNotifications();

  static const _channelId = 'evening';

  /// Ids 101 to 107, one per weekday (Monday 1 to Sunday 7).
  static const _baseId = 100;

  /// The small white-on-transparent icon in res/drawable.
  static const _icon = 'ic_stat_kept';

  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _ready;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<void> setUp({required ValueChanged<DayAnswerValue> onAnswer}) =>
      _ready ??= _setUp(onAnswer);

  Future<void> _setUp(ValueChanged<DayAnswerValue> onAnswer) async {
    await _initTimeZone();
    try {
      void handle(NotificationResponse r) {
        final answer = eveningAnswerFor(
          actionId: r.actionId,
          payload: r.payload,
        );
        if (answer != null) onAnswer(answer);
      }

      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings(_icon),
        ),
        onDidReceiveNotificationResponse: handle,
        onDidReceiveBackgroundNotificationResponse:
            onEveningResponseInBackground,
      );
      final launch = await _plugin.getNotificationAppLaunchDetails();
      final response = launch?.notificationResponse;
      if ((launch?.didNotificationLaunchApp ?? false) && response != null) {
        handle(response);
      }
    } catch (e) {
      // Missing notifications must never stop the app.
      debugPrint('Notifications not set up: $e');
    }
  }

  @override
  Future<void> scheduleEvening(EveningPlan plan) async {
    final android = _android;
    if (_ready == null || android == null) return;
    await _ready;
    try {
      await android.createNotificationChannel(
        AndroidNotificationChannel(
          _channelId,
          plan.channelName,
          importance: Importance.high,
        ),
      );
      final pending = {
        for (final p in await _plugin.pendingNotificationRequests()) p.id,
      };
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          plan.channelName,
          icon: _icon,
          color: KeptColors.coral,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          actions: [
            AndroidNotificationAction(
              eveningYesAction,
              plan.yes,
              showsUserInterface: true,
            ),
            AndroidNotificationAction(eveningNotTodayAction, plan.notToday),
          ],
        ),
      );
      final now = DateTime.now();
      for (var day = DateTime.monday; day <= DateTime.sunday; day++) {
        final id = _baseId + day;
        if (!plan.weekdays.contains(day)) {
          // Only cancel what is scheduled: cancel also removes a shown one.
          if (pending.contains(id)) await _plugin.cancel(id: id);
          continue;
        }
        // Scheduled again on every start: this replaces the alarm without
        // removing a notification that is shown now, and brings back alarms
        // the phone dropped (for example after a force stop).
        final at = nextEvening(now, day, plan.minute);
        await _plugin.zonedSchedule(
          id: id,
          title: plan.title,
          scheduledDate: tz.TZDateTime(
            tz.local,
            at.year,
            at.month,
            at.day,
            at.hour,
            at.minute,
          ),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: eveningPayload,
        );
      }
    } catch (e) {
      debugPrint('Evening question not scheduled: $e');
    }
  }

  @override
  Future<bool> areEnabled() async {
    try {
      return await _android?.areNotificationsEnabled() ?? false;
    } catch (e) {
      debugPrint('Notification state unknown: $e');
      return false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      final android = _android;
      if (android == null) return false;
      if (await android.areNotificationsEnabled() ?? false) return true;
      return await android.requestNotificationsPermission() ?? false;
    } catch (e) {
      debugPrint('Notification permission not asked: $e');
      return false;
    }
  }

  @override
  Future<void> openSettings() async {
    try {
      await _android?.openAppNotificationSettings();
    } catch (e) {
      debugPrint('Notification settings not opened: $e');
    }
  }

  /// The phone's time zone; falls back to Europe/Berlin, never throws.
  static Future<void> _initTimeZone() async {
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
}

/// Stores the answer an evening response stands for, if any. Shared by the
/// running app and the background handler.
Future<DayAnswerValue?> recordEveningResponse(
  DayAnswersRepository answers, {
  String? actionId,
  String? payload,
  DateTime? now,
}) async {
  final answer = eveningAnswerFor(actionId: actionId, payload: payload);
  if (answer != null) await answers.setToday(answer, now: now);
  return answer;
}

/// "Not today" (and any other button that does not open the app). Runs in
/// a background isolate the plugin starts, also when the app is closed.
///
/// Writes to the real database only: it opens it with [openAppDatabase],
/// never the demo one. The connection is short-lived and closed in all
/// cases. drift_flutter shares one database isolate per file within the
/// app's process (`shareAcrossIsolates`), so while the app runs this joins
/// the app's own connection instead of opening a second one, and the
/// screens see the change.
@pragma('vm:entry-point')
Future<void> onEveningResponseInBackground(NotificationResponse r) async {
  if (eveningAnswerFor(actionId: r.actionId, payload: r.payload) == null) {
    return;
  }
  DartPluginRegistrant.ensureInitialized();
  final db = openAppDatabase();
  try {
    await recordEveningResponse(
      DayAnswersRepository(db),
      actionId: r.actionId,
      payload: r.payload,
    ).timeout(const Duration(seconds: 20));
  } catch (e) {
    debugPrint('Evening answer not stored: $e');
  } finally {
    await db.close();
  }
}
