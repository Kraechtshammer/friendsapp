import '../data/database.dart';
import 'birthdays.dart';
import 'contact_event.dart';
import 'intention.dart';
import 'plans.dart';

/// The friend timeline on the person page (02-design.md §3, §6.6 and
/// §6.8, D10 and D11), built as a pure function. It is not stored. Days are
/// local calendar days; nothing here reads the clock.

/// One line of the friend timeline.
sealed class TimelineEntry {
  const TimelineEntry(this.day);

  /// The local day, at midnight.
  final DateTime day;
}

/// The person's next birthday (today counts), with the age turned if the
/// birth year is known.
class UpcomingBirthday extends TimelineEntry {
  const UpcomingBirthday(super.day, {this.age});

  final int? age;
}

/// An open thought with a date that has not passed yet.
class UpcomingThought extends TimelineEntry {
  UpcomingThought(this.intention)
    : super(
        DateTime(
          intention.date!.year,
          intention.date!.month,
          intention.date!.day,
        ),
      );

  final Intention intention;

  /// The time of day, when the thought has one.
  DateTime? get time => dateHasTime(intention.date!) ? intention.date : null;
}

/// An open plan with no date, only a horizon ("Soon", "Later", "when…").
/// Its [day] is the day it was made; it is not shown as a date.
class UpcomingPlan extends TimelineEntry {
  UpcomingPlan(this.intention)
    : super(
        DateTime(
          intention.createdAt.year,
          intention.createdAt.month,
          intention.createdAt.day,
        ),
      );

  final Intention intention;
}

/// A contact event, on the local day of [event]'s `at`. The only history
/// entry the user can edit or delete.
class ContactEntry extends TimelineEntry {
  ContactEntry(this.event)
    : super(DateTime(event.at.year, event.at.month, event.at.day));

  final ContactEvent event;
}

/// Several messages on one day, as one entry (the developer, 2026-11-18).
/// [events] are that day's "wrote" events, newest first, at least two. A
/// single message stays a [ContactEntry].
class TextingDay extends TimelineEntry {
  TextingDay(this.events)
    : super(
        DateTime(
          events.first.at.year,
          events.first.at.month,
          events.first.at.day,
        ),
      );

  final List<ContactEvent> events;

  bool get byUser => events.any((e) => e.direction == ContactDirection.byUser);
  bool get byThem => events.any((e) => e.direction == ContactDirection.byThem);
}

/// The person's birthday on [day], in the past. [congratulated] is true
/// when the user congratulated that day; otherwise nothing is said
/// (02-design.md §6.8).
class PastBirthday extends TimelineEntry {
  const PastBirthday(
    super.day, {
    this.age,
    required this.congratulated,
    this.texted = false,
  });

  final int? age;
  final bool congratulated;

  /// The user also wrote that day; those messages have no entry of their
  /// own.
  final bool texted;
}

/// The user's own birthday on [day], an entry only because this person
/// congratulated.
class OwnBirthdayWish extends TimelineEntry {
  OwnBirthdayWish(this.event)
    : super(DateTime(event.at.year, event.at.month, event.at.day));

  final ContactEvent event;
}

/// The oldest entry: the day the person was added.
class AddedEntry extends TimelineEntry {
  const AddedEntry(super.day);
}

/// One person's timeline. [upcoming] is in display order, top to bottom:
/// the farthest first and the soonest last, right above the "Today" mark;
/// undated plans come first of all. [history] is newest first, right below
/// the mark, and ends with the [AddedEntry].
class PersonTimeline {
  const PersonTimeline(this.upcoming, this.history);

  final List<TimelineEntry> upcoming;
  final List<TimelineEntry> history;
}

/// Builds the timeline of [person] at [now] from their [events] (every
/// kind and direction) and their [intentions] (only the open ones count).
/// Open thoughts of the couple [groupId] the person is in count as theirs.
///
/// - Upcoming: the next birthday, open thoughts with a date that has not
///   passed ([hasPassed]), and open plans with a horizon.
/// - History: every contact event (several messages on one day as one
///   [TextingDay]), the person's birthdays between the
///   first entry of the history and yesterday (with "congratulated" from
///   the user's birthday wish that day), the user's own birthdays the
///   person congratulated, and the day the person was added at the end.
///   A birthday wish by the user is shown on the birthday entry, not as an
///   entry of its own; one on another day gets a birthday entry of its own.
PersonTimeline personTimeline(
  Person person,
  Iterable<ContactEvent> events,
  Iterable<Intention> intentions,
  DateTime now, {
  String? groupId,
}) {
  final today = DateTime(now.year, now.month, now.day);
  DateTime dayOf(DateTime t) => DateTime(t.year, t.month, t.day);
  final mine = [
    for (final e in events)
      if (e.personId == person.id) e,
  ];
  final open = [
    for (final i in intentions)
      if ((i.personId == person.id ||
              (groupId != null && i.groupId == groupId)) &&
          i.state == IntentionState.open)
        i,
  ];

  // Upcoming, soonest first at first; reversed below.
  final dated = <TimelineEntry>[];
  final birthday = birthdayOf(person);
  if (birthday != null) {
    final day = nextBirthday(birthday.month, birthday.day, now);
    dated.add(UpcomingBirthday(day, age: ageTurned(birthday.year, day)));
  }
  for (final i in open) {
    if (i.date != null && !hasPassed(i.date!, now)) {
      dated.add(UpcomingThought(i));
    }
  }
  int rank(TimelineEntry e) => e is UpcomingBirthday ? 0 : 1;
  dated.sort((a, b) {
    var c = a.day.compareTo(b.day);
    if (c != 0) return c;
    c = rank(a) - rank(b);
    if (c != 0) return c;
    if (a is UpcomingThought && b is UpcomingThought) {
      c = (a.time ?? a.day).compareTo(b.time ?? b.day);
      if (c != 0) return c;
      return a.intention.id.compareTo(b.intention.id);
    }
    return 0;
  });
  final plans =
      [
        for (final i in open)
          if (i.date == null && i.horizon != null) UpcomingPlan(i),
      ]..sort((a, b) {
        final c = b.intention.createdAt.compareTo(a.intention.createdAt);
        return c != 0 ? c : a.intention.id.compareTo(b.intention.id);
      });
  final upcoming = <TimelineEntry>[...plans, ...dated.reversed];

  // History.
  final wishDays = {
    for (final e in mine)
      if (e.kind == ContactKind.birthdayWish &&
          e.direction == ContactDirection.byUser)
        dayKey(e.at): dayOf(e.at),
  };
  // Messages on one day become one entry. On a day the user congratulated
  // they are folded into the birthday entry instead (the developer,
  // 2026-11-18): the wish is mostly sent as a message.
  final textedOnWish = <String>{};
  final contacts = <TimelineEntry>[];
  final texts = <String, List<ContactEvent>>{};
  for (final e in mine) {
    if (e.kind == ContactKind.birthdayWish) continue;
    if (e.kind == ContactKind.wrote && wishDays.containsKey(dayKey(e.at))) {
      textedOnWish.add(dayKey(e.at));
    } else if (e.kind == ContactKind.wrote) {
      texts.putIfAbsent(dayKey(e.at), () => []).add(e);
    } else {
      contacts.add(ContactEntry(e));
    }
  }
  for (final day in texts.values) {
    if (day.length == 1) {
      contacts.add(ContactEntry(day.single));
    } else {
      day.sort((a, b) {
        final c = b.at.compareTo(a.at);
        return c != 0 ? c : b.id.compareTo(a.id);
      });
      contacts.add(TextingDay(day));
    }
  }
  final addedDay = dayOf(person.createdAt);
  var start = addedDay;
  for (final e in mine) {
    final d = dayOf(e.at);
    if (d.isBefore(start)) start = d;
  }
  final birthdays = <TimelineEntry>[];
  final shown = <String>{};
  if (birthday != null) {
    for (var y = start.year; y <= today.year; y++) {
      final day = birthdayIn(y, birthday.month, birthday.day);
      if (day.isBefore(start) || !day.isBefore(today)) continue;
      shown.add(dayKey(day));
      birthdays.add(
        PastBirthday(
          day,
          age: ageTurned(birthday.year, day),
          congratulated: wishDays.containsKey(dayKey(day)),
          texted: textedOnWish.contains(dayKey(day)),
        ),
      );
    }
  }
  for (final w in wishDays.entries) {
    if (!shown.contains(w.key)) {
      birthdays.add(
        PastBirthday(
          w.value,
          age: birthday == null ? null : ageTurned(birthday.year, w.value),
          congratulated: true,
          texted: textedOnWish.contains(w.key),
        ),
      );
    }
  }
  final own = [
    for (final e in mine)
      if (e.kind == ContactKind.birthdayWish &&
          e.direction == ContactDirection.byThem)
        OwnBirthdayWish(e),
  ];

  final body = <TimelineEntry>[...contacts, ...birthdays, ...own];
  DateTime moment(TimelineEntry e) => switch (e) {
    ContactEntry(:final event) => event.at,
    OwnBirthdayWish(:final event) => event.at,
    TextingDay(:final events) => events.first.at,
    _ => e.day,
  };
  // Newest first. On one day the contacts come before the birthdays; the
  // rest keeps the stored order (newest created, then id).
  body.sort((a, b) {
    var c = b.day.compareTo(a.day);
    if (c != 0) return c;
    c = (b is PastBirthday ? 1 : 0) - (a is PastBirthday ? 1 : 0);
    if (c != 0) return -c;
    c = moment(b).compareTo(moment(a));
    if (c != 0) return c;
    if (a is ContactEntry && b is ContactEntry) {
      c = b.event.createdAt.compareTo(a.event.createdAt);
      if (c != 0) return c;
      return b.event.id.compareTo(a.event.id);
    }
    return 0;
  });
  return PersonTimeline(upcoming, [...body, AddedEntry(addedDay)]);
}
