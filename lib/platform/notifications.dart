import 'dart:async';
import 'dart:ui' show DartPluginRegistrant;

import 'package:flutter/foundation.dart' show ValueChanged, debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../app/theme.dart' show KeptColors;
import '../data/contact_events_repository.dart';
import '../data/database_connection.dart';
import '../data/day_answers_repository.dart';
import '../domain/birthday_notifications.dart';
import '../domain/contact_event.dart';
import '../domain/evening_question.dart';
import '../domain/person_name.dart';

/// The app's notifications, behind an interface so tests can fake them:
/// the evening question (02-design.md §2.2) and the birthday notifications
/// (§8, birthdays M4; ids in `domain/birthday_notifications.dart`).
abstract class Notifications {
  /// Sets the plugin up. [onAnswer] gets the evening answers that reach the
  /// running app: "Yes" and a tap on the notification, also when one of
  /// them started the app. "Not today" does not open the app; it is stored
  /// by [onResponseInBackground]. [onBirthday] gets the birthday responses
  /// that reach the running app: "Open chat", a tap, and "Yes" when the
  /// plugin delivers it to the app instead of the background handler.
  Future<void> setUp({
    required ValueChanged<DayAnswerValue> onAnswer,
    required ValueChanged<BirthdayResponse> onBirthday,
  });

  /// Makes the scheduled evening notifications match [plan]: a one-off
  /// notification with its own text on each day in it, and after those one
  /// weekly general notification per allowed weekday ([eveningChanges]).
  Future<void> scheduleEvening(EveningPlan plan);

  /// Makes the scheduled birthday notifications match [plan]: each alarm
  /// in it is scheduled (replacing an older one with its id), and pending
  /// birthday notifications that are not in it are cancelled.
  Future<void> scheduleBirthdays(BirthdayPlan plan);

  /// Cancels [personId]'s birthday notifications, pending or shown: both,
  /// or with [lateOnly] only the 23:00 one.
  Future<void> cancelBirthday(String personId, {bool lateOnly = false});

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
  static const _birthdayChannelId = 'birthdays';

  /// The small white-on-transparent icon in res/drawable.
  static const _icon = 'ic_stat_kept';

  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _ready;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<void> setUp({
    required ValueChanged<DayAnswerValue> onAnswer,
    required ValueChanged<BirthdayResponse> onBirthday,
  }) => _ready ??= _setUp(onAnswer, onBirthday);

  Future<void> _setUp(
    ValueChanged<DayAnswerValue> onAnswer,
    ValueChanged<BirthdayResponse> onBirthday,
  ) async {
    await _initTimeZone();
    try {
      void handle(NotificationResponse r) {
        final answer = eveningAnswerFor(
          actionId: r.actionId,
          payload: r.payload,
        );
        if (answer != null) onAnswer(answer);
        final birthday = birthdayResponseFor(
          actionId: r.actionId,
          payload: r.payload,
        );
        if (birthday != null) onBirthday(birthday);
      }

      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings(_icon),
        ),
        onDidReceiveNotificationResponse: handle,
        onDidReceiveBackgroundNotificationResponse: onResponseInBackground,
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
      final pending = [
        for (final p in await _plugin.pendingNotificationRequests()) p.id,
      ];
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
      final changes = eveningChanges(plan, pending);
      // Only pending ones: cancel also removes a notification that is shown.
      for (final id in changes.cancel) {
        await _plugin.cancel(id: id);
      }
      // Scheduled again on every change: this replaces an alarm with the
      // same id without removing a notification that is shown now, and
      // brings back alarms the phone dropped (for example after a force
      // stop). The weekly ones come first, so that ids 101 to 107 from an
      // older version, which repeat from now, are moved behind the one-off
      // days before those are added.
      for (final a in changes.schedule) {
        try {
          await _scheduleEveningAlarm(a, details);
        } catch (e) {
          // One that fails (for example a time that just passed) must not
          // stop the others.
          debugPrint('Evening notification not scheduled: $e');
        }
      }
    } catch (e) {
      debugPrint('Evening question not scheduled: $e');
    }
  }

  Future<void> _scheduleEveningAlarm(
    EveningAlarm a,
    NotificationDetails details,
  ) => _plugin.zonedSchedule(
    id: a.id,
    title: a.title,
    body: a.body,
    scheduledDate: tz.TZDateTime(
      tz.local,
      a.at.year,
      a.at.month,
      a.at.day,
      a.at.hour,
      a.at.minute,
    ),
    notificationDetails: details,
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    matchDateTimeComponents: a.weekly
        ? DateTimeComponents.dayOfWeekAndTime
        : null,
    payload: eveningPayload,
  );

  @override
  Future<void> scheduleBirthdays(BirthdayPlan plan) async {
    final android = _android;
    if (_ready == null || android == null) return;
    await _ready;
    try {
      await android.createNotificationChannel(
        AndroidNotificationChannel(
          _birthdayChannelId,
          plan.channelName,
          importance: Importance.high,
        ),
      );
      final wanted = {for (final a in plan.alarms) a.id};
      for (final p in await _plugin.pendingNotificationRequests()) {
        // Only pending ones: cancel also removes one that is shown.
        if (isBirthdayNotificationId(p.id) && !wanted.contains(p.id)) {
          await _plugin.cancel(id: p.id);
        }
      }
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          _birthdayChannelId,
          plan.channelName,
          icon: _icon,
          color: KeptColors.coral,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          actions: [
            AndroidNotificationAction(birthdayYesAction, plan.yes),
            AndroidNotificationAction(
              birthdayOpenChatAction,
              plan.openChat,
              showsUserInterface: true,
            ),
          ],
        ),
      );
      for (final a in plan.alarms) {
        final name = firstNameOf(a.person.name);
        await _plugin.zonedSchedule(
          id: a.id,
          title: a.late ? plan.lateTitle(name) : plan.title(name),
          body: a.late ? plan.lateBody : null,
          scheduledDate: tz.TZDateTime(
            tz.local,
            a.at.year,
            a.at.month,
            a.at.day,
            a.at.hour,
            a.at.minute,
          ),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: a.payload,
        );
      }
    } catch (e) {
      debugPrint('Birthday notifications not scheduled: $e');
    }
  }

  /// Works without [setUp], so the background handler can use it.
  @override
  Future<void> cancelBirthday(String personId, {bool lateOnly = false}) async {
    try {
      for (final late in [if (!lateOnly) false, true]) {
        await _plugin.cancel(id: birthdayNotificationId(personId, late: late));
      }
    } catch (e) {
      debugPrint('Birthday notification not cancelled: $e');
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

/// "Yes" on a birthday notification: stores that the user congratulated
/// the person on that birthday, once (nothing is added if a wish by the
/// user is already stored for the day), and cancels the person's 23:00
/// notification. Shared by the running app and the background handler.
/// The late one is cancelled even if storing fails, as the user said yes.
Future<void> recordBirthdayYes(
  ContactEventsRepository events,
  Notifications notifications,
  BirthdayResponse response, {
  DateTime? now,
}) async {
  try {
    await events.addBirthdayWishOnce(
      personId: response.personId,
      day: response.day,
      source: ContactSource.confirmed,
      now: now,
    );
  } finally {
    await notifications.cancelBirthday(response.personId, lateOnly: true);
  }
}

/// Buttons that do not open the app: "Not today" on the evening question
/// and "Yes" on a birthday notification. Runs in a background isolate the
/// plugin starts, also when the app is closed.
///
/// Writes to the real database only: it opens it with [openAppDatabase],
/// never the demo one. The connection is short-lived and closed in all
/// cases. drift_flutter shares one database isolate per file within the
/// app's process (`shareAcrossIsolates`), so while the app runs this joins
/// the app's own connection instead of opening a second one, and the
/// screens see the change.
@pragma('vm:entry-point')
Future<void> onResponseInBackground(NotificationResponse r) async {
  final evening = eveningAnswerFor(actionId: r.actionId, payload: r.payload);
  final birthday = birthdayResponseFor(
    actionId: r.actionId,
    payload: r.payload,
  );
  if (evening == null && birthday?.action != BirthdayAction.yes) return;
  DartPluginRegistrant.ensureInitialized();
  final db = openAppDatabase();
  try {
    if (evening != null) {
      await recordEveningResponse(
        DayAnswersRepository(db),
        actionId: r.actionId,
        payload: r.payload,
      ).timeout(const Duration(seconds: 20));
    } else {
      await recordBirthdayYes(
        ContactEventsRepository(db),
        LocalNotifications(),
        birthday!,
      ).timeout(const Duration(seconds: 20));
    }
  } catch (e) {
    debugPrint('Notification answer not stored: $e');
  } finally {
    await db.close();
  }
}
