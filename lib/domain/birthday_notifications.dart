import 'package:flutter/foundation.dart' show listEquals;

import '../data/database.dart';
import 'birthdays.dart';
import 'contact_event.dart';

/// The birthday notifications (02-design.md §8, birthdays M4) as pure
/// functions: which ones, when, with which id and payload, and what a
/// response means.
///
/// On a person's birthday there is one notification at the evening time
/// and one at 23:00 (the last hour of the day). They come in addition to
/// the evening question and also on its excluded weekdays; its on/off
/// switch silences them too. Only the next birthday of each person is
/// scheduled; it moves on to the next year once the user congratulated or
/// both times have passed.
///
/// **Ids.** The evening question uses 101 to 107. A birthday notification
/// uses `0x10000000 + 2 * h + slot`, where `h` is the 26-bit FNV-1a hash of
/// the person's id and `slot` is 0 for the evening one and 1 for the late
/// one: 268435456 to 402653183, stable across starts and far from the
/// evening ids. Two people whose ids hash alike would share ids (about one
/// chance in 7000 with 100 people); the later one scheduled wins.

/// The id of the "Yes" button. It does not open the app.
const birthdayYesAction = 'birthday_yes';

/// The id of the "Open chat" button. It opens the app and the messenger.
const birthdayOpenChatAction = 'birthday_open_chat';

/// The hour of the second notification.
const birthdayLateHour = 23;

const _idBase = 0x10000000;
const _hashBits = 26;
const _payloadPrefix = 'birthday';

/// Whether [id] is in the range of birthday notifications.
bool isBirthdayNotificationId(int id) =>
    id >= _idBase && id < _idBase + (2 << _hashBits);

/// The notification id of [personId]'s evening ([late] false) or 23:00
/// ([late] true) birthday notification. See the id scheme above.
int birthdayNotificationId(String personId, {required bool late}) {
  // FNV-1a, 32 bit, over the UTF-16 code units; folded to 26 bits.
  var h = 0x811c9dc5;
  for (final c in personId.codeUnits) {
    h ^= c;
    h = (h * 0x01000193) & 0xffffffff;
  }
  final folded = (h ^ (h >> _hashBits)) & ((1 << _hashBits) - 1);
  return _idBase + 2 * folded + (late ? 1 : 0);
}

/// One birthday notification to schedule.
class BirthdayAlarm {
  const BirthdayAlarm({
    required this.person,
    required this.at,
    required this.late,
  });

  final Person person;

  /// Local time it comes.
  final DateTime at;

  /// The 23:00 one.
  final bool late;

  int get id => birthdayNotificationId(person.id, late: late);

  String get payload => birthdayPayload(person.id, at, late: late);

  @override
  bool operator ==(Object other) =>
      other is BirthdayAlarm &&
      other.person.id == person.id &&
      other.person.name == person.name &&
      other.at == at &&
      other.late == late;

  @override
  int get hashCode => Object.hash(person.id, person.name, at, late);

  @override
  String toString() => 'BirthdayAlarm(${person.name}, $at, late: $late)';
}

/// The birthday notifications that should be scheduled at [now], for
/// [people], at the evening time [minute] (minutes after midnight). [on] is
/// the evening question's switch: off means none. [congratulated] holds the
/// ids of people the user already congratulated today; their birthday
/// today needs no notification any more.
///
/// For each person with a birthday: the next birthday on or after today;
/// its evening one at [minute], and its late one at 23:00 unless [minute]
/// is 23:00 or later. Times already past are left out; if both are past
/// (or the person was congratulated today), the birthday a year later is
/// used. Sorted by time, then by name.
List<BirthdayAlarm> birthdayAlarms({
  required List<Person> people,
  required Set<String> congratulated,
  required DateTime now,
  required bool on,
  required int minute,
}) {
  if (!on) return const [];
  List<BirthdayAlarm> forDay(Person p, DateTime day) => [
    BirthdayAlarm(
      person: p,
      at: DateTime(day.year, day.month, day.day, minute ~/ 60, minute % 60),
      late: false,
    ),
    if (minute < birthdayLateHour * 60)
      BirthdayAlarm(
        person: p,
        at: DateTime(day.year, day.month, day.day, birthdayLateHour),
        late: true,
      ),
  ];
  final result = <BirthdayAlarm>[];
  for (final p in people) {
    final b = birthdayOf(p);
    if (b == null) continue;
    final day = nextBirthday(b.month, b.day, now);
    final isToday =
        day.year == now.year && day.month == now.month && day.day == now.day;
    var alarms = [
      if (!(isToday && congratulated.contains(p.id)))
        for (final a in forDay(p, day))
          if (a.at.isAfter(now)) a,
    ];
    if (alarms.isEmpty) {
      alarms = forDay(p, birthdayIn(day.year + 1, b.month, b.day));
    }
    result.addAll(alarms);
  }
  result.sort((a, b) {
    final c = a.at.compareTo(b.at);
    return c != 0 ? c : a.person.name.compareTo(b.person.name);
  });
  return result;
}

/// The payload of a birthday notification:
/// `birthday:<person id>:<YYYY-MM-DD>:<evening|late>`.
String birthdayPayload(String personId, DateTime day, {required bool late}) =>
    '$_payloadPrefix:$personId:${dayKey(day)}:${late ? 'late' : 'evening'}';

/// What the user did with a birthday notification.
enum BirthdayAction {
  /// "Yes": congratulated. Handled without opening the app.
  yes,

  /// "Open chat": the app opens at the birthday pick and opens the chat.
  openChat,

  /// A tap on the notification: the app opens at the birthday pick.
  open,
}

/// A response to a birthday notification: who, which birthday, which of
/// the two, and what the user did.
class BirthdayResponse {
  const BirthdayResponse({
    required this.personId,
    required this.day,
    required this.late,
    required this.action,
  });

  final String personId;

  /// The birthday (midnight).
  final DateTime day;
  final bool late;
  final BirthdayAction action;

  @override
  bool operator ==(Object other) =>
      other is BirthdayResponse &&
      other.personId == personId &&
      other.day == day &&
      other.late == late &&
      other.action == action;

  @override
  int get hashCode => Object.hash(personId, day, late, action);
}

/// Reads a response from the notification plugin. Null when it is not
/// from a birthday notification or has an unknown button.
BirthdayResponse? birthdayResponseFor({String? actionId, String? payload}) {
  final parts = (payload ?? '').split(':');
  if (parts.length != 4 || parts[0] != _payloadPrefix || parts[1].isEmpty) {
    return null;
  }
  final date = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(parts[2]);
  if (date == null || (parts[3] != 'late' && parts[3] != 'evening')) {
    return null;
  }
  final action = switch (actionId) {
    birthdayYesAction => BirthdayAction.yes,
    birthdayOpenChatAction => BirthdayAction.openChat,
    null || '' => BirthdayAction.open,
    _ => null,
  };
  if (action == null) return null;
  return BirthdayResponse(
    personId: parts[1],
    day: DateTime(
      int.parse(date[1]!),
      int.parse(date[2]!),
      int.parse(date[3]!),
    ),
    late: parts[3] == 'late',
    action: action,
  );
}

/// What the scheduler needs: the alarms and the texts in the user's
/// language. [title] and [lateTitle] get the person's first name.
class BirthdayPlan {
  const BirthdayPlan({
    required this.alarms,
    required this.title,
    required this.lateTitle,
    required this.lateBody,
    required this.yes,
    required this.openChat,
    required this.channelName,
  });

  final List<BirthdayAlarm> alarms;
  final String Function(String name) title;
  final String Function(String name) lateTitle;
  final String lateBody;
  final String yes;
  final String openChat;
  final String channelName;

  /// The texts for a comparison: functions are compared by their output.
  List<Object> get _key => [
    ...alarms,
    title('·'),
    lateTitle('·'),
    lateBody,
    yes,
    openChat,
    channelName,
  ];

  @override
  bool operator ==(Object other) =>
      other is BirthdayPlan && listEquals(other._key, _key);

  @override
  int get hashCode => Object.hashAll(_key);
}
