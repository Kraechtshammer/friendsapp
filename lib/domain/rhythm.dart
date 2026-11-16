import '../data/database.dart';
import 'person.dart';

/// Rhythms and the gentle hint (02-design.md §2.4 step 5, §6.9, §6.10; F8).
/// A rhythm never makes anything overdue. It only decides when a person may
/// come up as "It's been a while". These rules are pure; the current time is
/// a parameter.

/// The spans the user can choose, in days: 1, 2, 3, 4, 6 and 8 weeks, then
/// 3, 4, 6 and 12 months (30 days each, 12 months is 365).
const rhythmSpans = <int>[7, 14, 21, 28, 42, 56, 90, 120, 180, 365];

/// The start values (02-design.md §6.10): 2 weeks, 6 weeks, 3 months. Family
/// has none, but can get one. A null value is no rhythm.
const defaultClassRhythms = <Closeness, int?>{
  Closeness.close: 14,
  Closeness.nowAndThen: 42,
  Closeness.fewTimesAYear: 90,
  Closeness.family: null,
};

/// The number of months a span of 90, 120, 180 or 365 days is named by.
int rhythmMonths(int days) => (days / 30).round();

/// The rhythm of [person] in days: their own, else the one of their class
/// in [classRhythms]. Null means none: they never get a hint.
int? rhythmDaysFor(Person person, Map<Closeness, int?> classRhythms) =>
    person.rhythmDays ?? classRhythms[person.closeness];

/// When the user last had contact with [person]: their newest contact event
/// in any direction (also a birthday wish), else the day they were added.
/// [events] may hold other people's events; they are ignored.
DateTime lastContact(Person person, Iterable<ContactEvent> events) {
  var last = person.createdAt;
  for (final e in events) {
    if (e.personId == person.id && e.at.isAfter(last)) last = e.at;
  }
  return last;
}

/// Whether [person] is due for a hint at [now]: the last contact
/// ([lastContact]) is more than their rhythm ago, counted in calendar
/// days. Without a rhythm, never.
bool isDueForHint(
  Person person,
  Iterable<ContactEvent> events,
  Map<Closeness, int?> classRhythms,
  DateTime now,
) {
  final rhythm = rhythmDaysFor(person, classRhythms);
  if (rhythm == null) return false;
  return daysBetween(lastContact(person, events), now) > rhythm;
}

/// Everyone in [people] who is due for a hint ([isDueForHint]), in the
/// order of [people].
List<Person> peopleDueForHint(
  List<Person> people,
  Iterable<ContactEvent> events,
  Map<Closeness, int?> classRhythms,
  DateTime now,
) {
  final byPerson = <String, List<ContactEvent>>{};
  for (final e in events) {
    (byPerson[e.personId] ??= []).add(e);
  }
  return [
    for (final p in people)
      if (isDueForHint(p, byPerson[p.id] ?? const [], classRhythms, now)) p,
  ];
}

/// The one person to hint at on the local day of [day]: a rotation over
/// [due] that moves on every day and stays put within one. Nothing is
/// stored; the date is the seed. [due] is sorted by id first, so the order
/// of the list does not matter. Null when nobody is due.
Person? hintPersonFor(List<Person> due, DateTime day) => rotateByDay(due, day);

/// One of [items] for the local day of [day]: sorted by id, then the
/// day number modulo the length. The same all day, the next one the next
/// day. Null for an empty list.
Person? rotateByDay(List<Person> items, DateTime day) {
  if (items.isEmpty) return null;
  final sorted = [...items]..sort((a, b) => a.id.compareTo(b.id));
  return sorted[dayNumber(day) % sorted.length];
}

/// Calendar days since 1 January 1970 for the local date of [t].
int dayNumber(DateTime t) =>
    DateTime.utc(t.year, t.month, t.day).difference(DateTime.utc(1970)).inDays;

/// Whole calendar days from the date of [from] to the date of [to].
int daysBetween(DateTime from, DateTime to) => dayNumber(to) - dayNumber(from);
