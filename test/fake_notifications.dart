import 'package:flutter/foundation.dart' show ValueChanged;
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
  var permissionRequests = 0;
  var settingsOpened = 0;
  ValueChanged<DayAnswerValue>? _onAnswer;

  /// Sends [answer] to the app as the plugin would.
  void answer(DayAnswerValue answer) => _onAnswer!(answer);

  @override
  Future<void> setUp({required ValueChanged<DayAnswerValue> onAnswer}) async {
    _onAnswer = onAnswer;
  }

  @override
  Future<void> scheduleEvening(EveningPlan plan) async => plans.add(plan);

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
