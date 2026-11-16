import '../data/database.dart';
import 'birthdays.dart';
import 'intention.dart';
import 'plans.dart';

/// The Upcoming timeline (02-design.md §6.9, "Upcoming tab"), built from
/// the people and their open dated thoughts as pure functions. It is not
/// stored.

/// How many months ahead the timeline looks.
const upcomingMonths = 12;

/// One line of the timeline: a birthday or a dated thought.
sealed class UpcomingEntry {
  const UpcomingEntry(this.person, this.day);

  final Person person;

  /// The local day, at midnight.
  final DateTime day;

  /// The time of day, for a thought with a time; null otherwise.
  DateTime? get time => null;
}

/// [person]'s birthday on [day]. [age] is the age turned, if known.
class BirthdayEntry extends UpcomingEntry {
  const BirthdayEntry(super.person, super.day, {this.age});

  final int? age;
}

/// A thought with a date.
class ThoughtEntry extends UpcomingEntry {
  ThoughtEntry(Person person, this.intention)
    : super(
        person,
        DateTime(
          intention.date!.year,
          intention.date!.month,
          intention.date!.day,
        ),
      );

  final Intention intention;

  @override
  DateTime? get time => dateHasTime(intention.date!) ? intention.date : null;
}

/// The first day after the window that starts on the local day of [now]:
/// the same date [upcomingMonths] months later. A birthday on that date
/// is not in the window, so one kept today is not listed twice.
DateTime upcomingEnd(DateTime now) =>
    DateTime(now.year, now.month + upcomingMonths, now.day);

/// Everything dated from the local day of [now] up to [upcomingEnd], soonest
/// first: every birthday of [people] (29 February counts on 28 February
/// in years without it), and every open thought with a date that has not
/// passed yet ([hasPassed]; those are asked about as "Did it happen?").
/// Inside a day birthdays come first, then thoughts without a time, then
/// by time; the rest goes by name and id so the order is stable.
List<UpcomingEntry> upcomingEntries(
  List<Person> people,
  List<Intention> intentions,
  DateTime now,
) {
  final today = DateTime(now.year, now.month, now.day);
  final end = upcomingEnd(now);
  final byId = {for (final p in people) p.id: p};
  final entries = <UpcomingEntry>[
    for (final p in people)
      if (birthdayOf(p) case final b?)
        if (nextBirthday(b.month, b.day, now) case final day
            when day.isBefore(end))
          BirthdayEntry(p, day, age: ageTurned(b.year, day)),
    for (final i in intentions)
      if (i.state == IntentionState.open &&
          i.date != null &&
          byId.containsKey(i.personId) &&
          !hasPassed(i.date!, now))
        if (ThoughtEntry(byId[i.personId]!, i) case final e
            when !e.day.isBefore(today) && e.day.isBefore(end))
          e,
  ];
  int rank(UpcomingEntry e) => switch (e) {
    BirthdayEntry() => 0,
    ThoughtEntry() => 1,
  };
  entries.sort((a, b) {
    var c = a.day.compareTo(b.day);
    if (c != 0) return c;
    c = rank(a) - rank(b);
    if (c != 0) return c;
    c = (a.time ?? a.day).compareTo(b.time ?? b.day);
    if (c != 0) return c;
    c = a.person.name.compareTo(b.person.name);
    if (c != 0) return c;
    return a.person.id.compareTo(b.person.id);
  });
  return entries;
}

/// How the timeline is split: this week, next week, then one group per
/// month.
enum UpcomingGroupKind { thisWeek, nextWeek, month }

/// A run of entries under one label. [month] is the first day of the month
/// for [UpcomingGroupKind.month], null otherwise.
class UpcomingGroup {
  const UpcomingGroup(this.kind, this.entries, {this.month});

  final UpcomingGroupKind kind;
  final DateTime? month;
  final List<UpcomingEntry> entries;
}

/// Splits sorted [entries] into groups. Weeks run Monday to Sunday. "This
/// week" is the local day of [now] to the end of that week and "next week"
/// the following Monday to Sunday; everything later is grouped by month.
/// A month that is only partly after next week keeps its own label.
List<UpcomingGroup> groupUpcoming(List<UpcomingEntry> entries, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final nextMonday = DateTime(
    today.year,
    today.month,
    today.day + (8 - today.weekday),
  );
  final weekAfter = DateTime(
    nextMonday.year,
    nextMonday.month,
    nextMonday.day + 7,
  );
  final groups = <UpcomingGroup>[];
  UpcomingGroupKind? kind;
  DateTime? month;
  var current = <UpcomingEntry>[];
  void flush() {
    if (current.isNotEmpty) {
      groups.add(UpcomingGroup(kind!, current, month: month));
    }
    current = [];
  }

  for (final e in entries) {
    final k = e.day.isBefore(nextMonday)
        ? UpcomingGroupKind.thisWeek
        : e.day.isBefore(weekAfter)
        ? UpcomingGroupKind.nextWeek
        : UpcomingGroupKind.month;
    final m = k == UpcomingGroupKind.month
        ? DateTime(e.day.year, e.day.month)
        : null;
    if (k != kind || m != month) {
      flush();
      kind = k;
      month = m;
    }
    current.add(e);
  }
  flush();
  return groups;
}
