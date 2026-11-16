import '../data/database.dart';
import 'contact_event.dart';
import 'rhythm.dart';

/// The reconnect person of the week (02-design.md §2.4 step 3, F13,
/// 01-research.md §9.8): people in the "getting back in touch" state are a
/// short list worked through one at a time. The user chooses one for the
/// week; a new week starts empty again, and nothing is said about the last
/// one. Pure rules; the current time is a parameter.

/// The Monday (local midnight) of the week that holds [day].
DateTime mondayOf(DateTime day) =>
    DateTime(day.year, day.month, day.day - (day.weekday - DateTime.monday));

/// The Monday after the week that starts on [monday].
DateTime nextMonday(DateTime monday) =>
    DateTime(monday.year, monday.month, monday.day + 7);

/// What the People tab card and the pick order show.
sealed class ReconnectWeek {
  const ReconnectWeek();
}

/// Nobody is in the state, and nobody is chosen: no card.
class ReconnectNone extends ReconnectWeek {
  const ReconnectNone();
}

/// Nobody is chosen for this week, and [candidates] (in the order of the
/// people list) are in the state. [suggested] is the one the card may
/// highlight, moved on every week.
class ReconnectChoose extends ReconnectWeek {
  const ReconnectChoose(this.candidates, this.suggested);

  final List<Person> candidates;
  final Person suggested;
}

/// [person] is the one for this week and the user has not been in touch
/// yet.
class ReconnectChosen extends ReconnectWeek {
  const ReconnectChosen(this.person);

  final Person person;
}

/// [person] is the one for this week and the user got in touch: calm, for
/// the rest of the week.
class ReconnectDone extends ReconnectWeek {
  const ReconnectDone(this.person);

  final Person person;
}

/// The state at [today] (any time of the day).
///
/// [chosenId] and [chosenWeek] are the stored choice. It holds only while
/// [chosenWeek] is this week's Monday and the person still exists; a choice
/// from an earlier week counts as no choice. With no choice, the people
/// with `reconnecting` are the candidates.
///
/// A contact by the user counts when it lies in the week, from Monday
/// 00:00 up to the next Monday 00:00: any event of the person that is not
/// `byThem` ([isByUser]).
ReconnectWeek reconnectWeekState({
  required List<Person> people,
  required Iterable<ContactEvent> events,
  required String? chosenId,
  required DateTime? chosenWeek,
  required DateTime today,
}) {
  final monday = mondayOf(today);
  if (chosenId != null && chosenWeek == monday) {
    final matches = people.where((p) => p.id == chosenId);
    if (matches.isNotEmpty) {
      final person = matches.first;
      return hasUserContactInWeek(person.id, events, monday)
          ? ReconnectDone(person)
          : ReconnectChosen(person);
    }
  }
  final candidates = [
    for (final p in people)
      if (p.reconnecting) p,
  ];
  if (candidates.isEmpty) return const ReconnectNone();
  return ReconnectChoose(candidates, rotateByDay(candidates, monday)!);
}

/// Whether the user had contact with [personId] in the week that starts on
/// [monday].
bool hasUserContactInWeek(
  String personId,
  Iterable<ContactEvent> events,
  DateTime monday,
) {
  final end = nextMonday(monday);
  return events.any(
    (e) =>
        e.personId == personId &&
        isByUser(e) &&
        !e.at.isBefore(monday) &&
        e.at.isBefore(end),
  );
}

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
