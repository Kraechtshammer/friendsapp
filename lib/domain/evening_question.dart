import 'package:flutter/foundation.dart' show listEquals;

import 'contact_event.dart';
import 'evening_reason.dart';

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

/// What the scheduler needs: the weekdays, the time, the texts in the
/// user's language, and the notifications of the next days with their
/// reasons ([eveningDays]).
class EveningPlan {
  const EveningPlan({
    required this.weekdays,
    required this.minute,
    required this.title,
    required this.yes,
    required this.notToday,
    required this.channelName,
    required this.start,
    this.days = const [],
  });

  final List<int> weekdays;
  final int minute;

  /// The general question; the weekly notifications after [days] use it.
  final String title;
  final String yes;
  final String notToday;

  /// The name of the notification channel in the phone's settings.
  final String channelName;

  /// Today (local midnight) when the plan was made. [days] lie in the
  /// [eveningOneOffDays] days from here; the weekly ones start after them.
  final DateTime start;

  /// The one-off notifications from [start] on, each with its own text.
  final List<EveningDay> days;

  @override
  bool operator ==(Object other) =>
      other is EveningPlan &&
      listEquals(other.weekdays, weekdays) &&
      other.minute == minute &&
      other.title == title &&
      other.yes == yes &&
      other.notToday == notToday &&
      other.channelName == channelName &&
      other.start == start &&
      listEquals(other.days, days);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(weekdays),
    minute,
    title,
    yes,
    notToday,
    channelName,
    start,
    Object.hashAll(days),
  );
}

/// **Ids of the evening notifications.** The weekly general ones keep
/// 101 to 107 (100 + weekday), so a newer version replaces the ones an older
/// version scheduled. A one-off day uses `0x01000000 + n`, where `n` is the
/// number of days from 1 January 1970 to that local date: one id per date,
/// stable across starts, below the birthday range (from 0x10000000) and far
/// above 107.
int eveningWeeklyId(int weekday) => 100 + weekday;

/// Whether [id] is one of the weekly evening notifications.
bool isEveningWeeklyId(int id) => id > 100 && id <= 107;

const _dayIdBase = 0x01000000;

/// The id of the one-off evening notification on the local date of [day].
int eveningDayId(DateTime day) =>
    _dayIdBase +
    DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;

/// Whether [id] is a one-off evening notification.
bool isEveningDayId(int id) => id >= _dayIdBase && id < 2 * _dayIdBase;

/// One evening notification to schedule: a one-off on one day, or a weekly
/// one that first comes at [at] and then every week ([weekly]).
class EveningAlarm {
  const EveningAlarm({
    required this.id,
    required this.at,
    required this.title,
    this.body,
    required this.weekly,
  });

  final int id;
  final DateTime at;
  final String title;
  final String? body;
  final bool weekly;

  @override
  bool operator ==(Object other) =>
      other is EveningAlarm &&
      other.id == id &&
      other.at == at &&
      other.title == title &&
      other.body == body &&
      other.weekly == weekly;

  @override
  int get hashCode => Object.hash(id, at, title, body, weekly);

  @override
  String toString() =>
      'EveningAlarm($id, $at, $title${weekly ? ', weekly' : ''})';
}

/// The alarms of [plan]: first the weekly general ones, one per allowed
/// weekday, each first on the first such day after the [eveningOneOffDays]
/// days from [EveningPlan.start]; then the one-off days. So no day gets two.
List<EveningAlarm> eveningAlarms(EveningPlan plan) {
  final s = plan.start;
  return [
    for (var i = eveningOneOffDays; i < eveningOneOffDays + 7; i++)
      if (DateTime(
            s.year,
            s.month,
            s.day + i,
            plan.minute ~/ 60,
            plan.minute % 60,
          )
          case final at when plan.weekdays.contains(at.weekday))
        EveningAlarm(
          id: eveningWeeklyId(at.weekday),
          at: at,
          title: plan.title,
          weekly: true,
        ),
    for (final d in plan.days)
      EveningAlarm(
        id: eveningDayId(d.at),
        at: d.at,
        title: d.title,
        body: d.body,
        weekly: false,
      ),
  ];
}

/// What the scheduler does to make the pending notifications match [plan],
/// given the ids now [pending]: which to cancel, then which to schedule
/// ([eveningAlarms], each replacing a pending one with its id).
///
/// Only pending ids are ever cancelled, since cancelling also removes a
/// notification that is shown. Cancelled are: weekly ids of weekdays that
/// are no longer allowed, and one-off ids not in the plan, apart from
/// today's while today is allowed. That one is not in the plan only when
/// its time has passed, and it may still be waiting: inexact alarms can
/// come late, so it is left to come. Ids of other kinds are not touched.
({List<int> cancel, List<EveningAlarm> schedule}) eveningChanges(
  EveningPlan plan,
  Iterable<int> pending,
) {
  final alarms = eveningAlarms(plan);
  final wanted = {for (final a in alarms) a.id};
  final todayId = eveningDayId(plan.start);
  final todayAllowed = plan.weekdays.contains(plan.start.weekday);
  return (
    cancel: [
      for (final id in pending)
        if ((isEveningWeeklyId(id) || isEveningDayId(id)) &&
            !wanted.contains(id) &&
            !(id == todayId && todayAllowed))
          id,
    ],
    schedule: alarms,
  );
}
