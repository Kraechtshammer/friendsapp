import 'package:flutter/foundation.dart' show ValueChanged;
import 'package:kept/domain/birthday_notifications.dart';
import 'package:kept/domain/contact_event.dart';
import 'package:kept/domain/evening_question.dart';
import 'package:kept/platform/notifications.dart';

/// [Notifications] without the plugin. Records what the app asks for and
/// lets a test send an answer as if the user tapped the notification.
class FakeNotifications implements Notifications {
  FakeNotifications({this.enabled = true, this.grant = true});

  /// What [areEnabled] returns.
  bool enabled;

  /// Whether [requestPermission] grants.
  bool grant;

  final plans = <EveningPlan>[];
  final birthdayPlans = <BirthdayPlan>[];

  /// Every cancelled birthday notification id, in order.
  final cancelled = <int>[];
  var permissionRequests = 0;
  var settingsOpened = 0;
  ValueChanged<DayAnswerValue>? _onAnswer;
  ValueChanged<BirthdayResponse>? _onBirthday;

  /// Sends [answer] to the app as the plugin would.
  void answer(DayAnswerValue answer) => _onAnswer!(answer);

  /// Sends a birthday [response] to the app as the plugin would.
  void birthday(BirthdayResponse response) => _onBirthday!(response);

  @override
  Future<void> setUp({
    required ValueChanged<DayAnswerValue> onAnswer,
    required ValueChanged<BirthdayResponse> onBirthday,
  }) async {
    _onAnswer = onAnswer;
    _onBirthday = onBirthday;
  }

  @override
  Future<void> scheduleEvening(EveningPlan plan) async => plans.add(plan);

  @override
  Future<void> scheduleBirthdays(BirthdayPlan plan) async =>
      birthdayPlans.add(plan);

  @override
  Future<void> cancelBirthday(String personId, {bool lateOnly = false}) async {
    for (final late in [if (!lateOnly) false, true]) {
      cancelled.add(birthdayNotificationId(personId, late: late));
    }
  }

  @override
  Future<bool> areEnabled() async => enabled;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    if (grant) enabled = true;
    return enabled;
  }

  @override
  Future<void> openSettings() async => settingsOpened++;
}
