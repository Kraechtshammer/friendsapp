import '../data/database.dart';
import 'contact_event.dart';
import 'rhythm.dart';

/// The reconnect person for a span (02-design.md §2.4 step 3, F13,
/// 01-research.md §9.8, changed in the review of 2026-11-16): people in the
/// "getting back in touch" state are a short list worked through one at a
/// time. The user chooses one; the span the user set in the settings starts
/// on the day of the choice and ends after its length. Then the card asks
/// again, and nothing is said about the last one. Pure rules; the current
/// time is a parameter.

/// The Monday (local midnight) of the week that holds [day].
DateTime mondayOf(DateTime day) =>
    DateTime(day.year, day.month, day.day - (day.weekday - DateTime.monday));

/// The Monday after the week that starts on [monday].
DateTime nextMonday(DateTime monday) =>
    DateTime(monday.year, monday.month, monday.day + 7);

/// How long a reconnect choice lasts. The start value is [month].
enum ReconnectSpan {
  week(days: 7),
  twoWeeks(days: 14),
  month(months: 1),
  twoMonths(months: 2),
  threeMonths(months: 3);

  const ReconnectSpan({this.days = 0, this.months = 0});

  final int days;
  final int months;

  static const defaultSpan = ReconnectSpan.month;

  /// The day (local midnight) on which a span that starts on [start] is
  /// over. Months are calendar months; a start on the 31st ends on the last
  /// day of a shorter month, never later than the month asks for.
  DateTime endOf(DateTime start) {
    if (months == 0) {
      return DateTime(start.year, start.month, start.day + days);
    }
    final first = DateTime(start.year, start.month + months);
    final lastDay = DateTime(first.year, first.month + 1, 0).day;
    return DateTime(
      first.year,
      first.month,
      start.day > lastDay ? lastDay : start.day,
    );
  }
}

/// What the People tab card and the pick order show.
sealed class ReconnectState {
  const ReconnectState();
}

/// Nobody is in the state, and nobody is chosen: no card.
class ReconnectNone extends ReconnectState {
  const ReconnectNone();
}

/// Nobody is chosen for this span, and [candidates] (in the order of the
/// people list) are in the state. [suggested] is the one the card may
/// highlight, moved on every week.
class ReconnectChoose extends ReconnectState {
  const ReconnectChoose(this.candidates, this.suggested);

  final List<Person> candidates;
  final Person suggested;
}

/// [person] is the one for this span and the user has not been in touch
/// yet.
class ReconnectChosen extends ReconnectState {
  const ReconnectChosen(this.person);

  final Person person;
}

/// [person] is the one for this span and the user got in touch: calm, for
/// the rest of the week.
class ReconnectDone extends ReconnectState {
  const ReconnectDone(this.person);

  final Person person;
}

/// The state at [today] (any time of the day).
///
/// [chosenId] and [chosenStart] are the stored choice and the day it began
/// (an old stored value holds a Monday: it is just an earlier start day, so
/// the choice carries on). It holds while [today] lies from [chosenStart]
/// up to, not including, the end of [span] and the person still exists;
/// after that it counts as no choice. With no choice, the people with
/// `reconnecting` are the candidates.
///
/// A contact by the user counts when it lies in the span, from the start
/// day 00:00 to its end: any event of the person that is not `byThem`
/// ([isByUser]).
ReconnectState reconnectState({
  required List<Person> people,
  required Iterable<ContactEvent> events,
  required String? chosenId,
  required DateTime? chosenStart,
  required ReconnectSpan span,
  required DateTime today,
}) {
  if (chosenId != null && chosenStart != null) {
    final end = span.endOf(chosenStart);
    if (!today.isBefore(chosenStart) && today.isBefore(end)) {
      final matches = people.where((p) => p.id == chosenId);
      if (matches.isNotEmpty) {
        final person = matches.first;
        return hasUserContactBetween(person.id, events, chosenStart, end)
            ? ReconnectDone(person)
            : ReconnectChosen(person);
      }
    }
  }
  final candidates = [
    for (final p in people)
      if (p.reconnecting) p,
  ];
  if (candidates.isEmpty) return const ReconnectNone();
  return ReconnectChoose(candidates, rotateByDay(candidates, mondayOf(today))!);
}

/// Whether the user had contact with [personId] from [start] up to, not
/// including, [end].
bool hasUserContactBetween(
  String personId,
  Iterable<ContactEvent> events,
  DateTime start,
  DateTime end,
) => events.any(
  (e) =>
      e.personId == personId &&
      isByUser(e) &&
      !e.at.isBefore(start) &&
      e.at.isBefore(end),
);

/// A contact the user made or shared: not one that only came in.
bool isByUser(ContactEvent e) => e.direction != ContactDirection.byThem;

/// How far back the "back in touch" check looks, in days: older contact
/// says nothing about the way back.
const backInTouchWindowDays = 60;

/// Whether [person]'s newest contacts show a first exchange: within the
/// last [backInTouchWindowDays] days the user made contact (direction
/// `byUser`, any kind) and after that something came back: they wrote or
/// called (`byThem`, not a birthday wish), or the two met or gamed
/// together. [events] may hold other people's events.
bool hadFirstExchange(
  String personId,
  Iterable<ContactEvent> events,
  DateTime now,
) {
  final from = DateTime(now.year, now.month, now.day - backInTouchWindowDays);
  final recent = [
    for (final e in events)
      if (e.personId == personId && !e.at.isBefore(from)) e,
  ];
  DateTime? firstUser;
  for (final e in recent) {
    if (e.direction == ContactDirection.byUser &&
        (firstUser == null || e.at.isBefore(firstUser))) {
      firstUser = e.at;
    }
  }
  if (firstUser == null) return false;
  return recent.any(
    (e) =>
        e.at.isAfter(firstUser!) &&
        e.kind != ContactKind.birthdayWish &&
        (e.direction == ContactDirection.byThem ||
            e.kind == ContactKind.met ||
            e.kind == ContactKind.gamed),
  );
}

/// The people for whom Home asks "You and X are back in touch": in the
/// state, with a first exchange ([hadFirstExchange]) and not answered yet
/// ([answered], from the settings). In the order of [people].
List<Person> backInTouch(
  List<Person> people,
  Iterable<ContactEvent> events,
  Set<String> answered,
  DateTime now,
) => [
  for (final p in people)
    if (p.reconnecting &&
        !answered.contains(p.id) &&
        hadFirstExchange(p.id, events, now))
      p,
];
