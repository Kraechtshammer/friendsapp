import 'package:flutter/foundation.dart' show listEquals;

import 'contact_event.dart';

/// The evening question (02-design.md §2.2) as pure functions: on which
/// weekdays and at what time it comes, and what a response means.
/// Weekdays are numbered as in [DateTime]: Monday 1 to Sunday 7.

/// The id of the "Yes" button. It opens the app.
const eveningYesAction = 'yes';

/// The id of the "Not today" button. It does not open the app.
const eveningNotTodayAction = 'not_today';

/// The payload of every evening notification, so a response can be told
/// apart from other notifications that come later.
const eveningPayload = 'evening';

/// The weekdays the question comes on, Monday first. None when it is off.
List<int> eveningWeekdays({required bool on, required Set<int> excluded}) => [
  if (on)
    for (var d = DateTime.monday; d <= DateTime.sunday; d++)
      if (!excluded.contains(d)) d,
];

/// The first local time after [now] that falls on [weekday] at [minute]
/// minutes after midnight. Uses calendar days, not a [Duration], so a
/// change to or from summer time does not move it.
DateTime nextEvening(DateTime now, int weekday, int minute) {
  for (var add = 0; add <= 7; add++) {
    final at = DateTime(
      now.year,
      now.month,
      now.day + add,
      minute ~/ 60,
      minute % 60,
    );
    if (at.weekday == weekday && at.isAfter(now)) return at;
  }
  throw ArgumentError.value(weekday, 'weekday', 'must be 1 to 7');
}

/// What a response to the evening notification stores: "Not today" for
/// that button, "Yes" for the Yes button and for a tap on the notification
/// itself. Null for anything else (another notification, an unknown
/// button).
DayAnswerValue? eveningAnswerFor({String? actionId, String? payload}) {
  if (payload != eveningPayload) return null;
  return switch (actionId) {
    eveningNotTodayAction => DayAnswerValue.notToday,
    eveningYesAction || null || '' => DayAnswerValue.yes,
    _ => null,
  };
}

/// What the scheduler needs: the weekdays, the time and the texts in the
/// user's language.
class EveningPlan {
  const EveningPlan({
    required this.weekdays,
    required this.minute,
    required this.title,
    required this.yes,
    required this.notToday,
    required this.channelName,
  });

  final List<int> weekdays;
  final int minute;
  final String title;
  final String yes;
  final String notToday;

  /// The name of the notification channel in the phone's settings.
  final String channelName;

  @override
  bool operator ==(Object other) =>
      other is EveningPlan &&
      listEquals(other.weekdays, weekdays) &&
      other.minute == minute &&
      other.title == title &&
      other.yes == yes &&
      other.notToday == notToday &&
      other.channelName == channelName;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(weekdays),
    minute,
    title,
    yes,
    notToday,
    channelName,
  );
}
