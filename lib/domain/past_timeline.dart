import '../data/database.dart';
import 'birthdays.dart';
import 'contact_event.dart';
import 'group.dart';

/// The past half of the Timeline tab (02-design.md §8): what happened with
/// everyone, built as a pure function. It is not stored. Messages are one
/// line per day for everyone together, so they do not drown the rest.
/// Nothing is shown as missed:
/// a birthday without a wish is listed plainly.

/// One line of the past timeline.
sealed class PastEntry {
  const PastEntry(this.day);

  /// The local day, at midnight.
  final DateTime day;
}

/// A call, meet-up or gaming session. For a couple's shared contact
/// [couple] is set and the entry stands for every member's row.
class PastContact extends PastEntry {
  PastContact(this.person, this.event, {this.couple})
    : super(DateTime(event.at.year, event.at.month, event.at.day));

  final Person person;
  final ContactEvent event;
  final GroupWithMembers? couple;
}

/// Messages on [day] with [people] (either direction), by name.
class PastTexting extends PastEntry {
  const PastTexting(super.day, this.people);

  final List<Person> people;
}

/// [person]'s birthday on [day]. [congratulated] is true when the user
/// wished them well that day.
class PastPersonBirthday extends PastEntry {
  const PastPersonBirthday(
    this.person,
    super.day, {
    this.age,
    required this.congratulated,
  });

  final Person person;
  final int? age;
  final bool congratulated;
}

/// The user's own birthday on [day], with the people who congratulated,
/// by name.
class PastOwnBirthday extends PastEntry {
  const PastOwnBirthday(super.day, this.from);

  final List<Person> from;
}

/// The contact kinds the past timeline shows.
const pastKinds = {ContactKind.called, ContactKind.met, ContactKind.gamed};

/// Everything that happened up to [now], newest first:
///
/// - every call, meet-up and gaming session of [people] (both directions);
///   a couple's shared contact is one entry;
/// - one [PastTexting] per day with messages, naming everyone written with;
/// - every birthday of each person from the day they were added (or their
///   oldest event, if older) up to yesterday, marked when the user
///   congratulated; a wish on another day gets a birthday entry of its own;
/// - the user's own birthdays someone congratulated on, one entry per day.
///
/// Events of people not in [people] are left out. Inside a day contacts
/// come first, newest first, then the messages, then birthdays by name,
/// then the user's own.
List<PastEntry> pastEntries(
  List<Person> people,
  Iterable<ContactEvent> events,
  DateTime now, {
  Map<String, GroupWithMembers> couples = const {},
}) {
  final today = DateTime(now.year, now.month, now.day);
  DateTime dayOf(DateTime t) => DateTime(t.year, t.month, t.day);
  final byId = {for (final p in people) p.id: p};
  final entries = <PastEntry>[];

  // Contacts.
  final shared = <String>{};
  final starts = {for (final p in people) p.id: dayOf(p.createdAt)};
  final wishes = <String, Map<String, DateTime>>{};
  final ownWishes = <String, List<Person>>{};
  final ownDays = <String, DateTime>{};
  final texts = <String, Set<Person>>{};
  final textDays = <String, DateTime>{};
  for (final e in events) {
    final p = byId[e.personId];
    if (p == null || e.at.isAfter(now)) continue;
    final d = dayOf(e.at);
    if (d.isBefore(starts[p.id]!)) starts[p.id] = d;
    if (e.kind == ContactKind.birthdayWish) {
      final key = dayKey(e.at);
      if (e.direction == ContactDirection.byThem) {
        ownWishes.putIfAbsent(key, () => []).add(p);
        ownDays[key] = d;
      } else {
        (wishes[p.id] ??= {})[key] = d;
      }
      continue;
    }
    if (e.kind == ContactKind.wrote) {
      final key = dayKey(e.at);
      texts.putIfAbsent(key, () => {}).add(p);
      textDays[key] = d;
      continue;
    }
    if (!pastKinds.contains(e.kind)) continue;
    if (e.sharedId case final s?) {
      if (!shared.add(s)) continue;
    }
    entries.add(
      PastContact(p, e, couple: e.groupId == null ? null : couples[e.groupId]),
    );
  }

  // Birthdays of others.
  for (final p in people) {
    final b = birthdayOf(p);
    final mine = wishes[p.id] ?? const <String, DateTime>{};
    final shown = <String>{};
    if (b != null) {
      final start = starts[p.id]!;
      for (var y = start.year; y <= today.year; y++) {
        final day = birthdayIn(y, b.month, b.day);
        if (day.isBefore(start) || !day.isBefore(today)) continue;
        final key = dayKey(day);
        shown.add(key);
        entries.add(
          PastPersonBirthday(
            p,
            day,
            age: ageTurned(b.year, day),
            congratulated: mine.containsKey(key),
          ),
        );
      }
    }
    for (final w in mine.entries) {
      if (shown.contains(w.key) || !w.value.isBefore(today)) continue;
      entries.add(
        PastPersonBirthday(
          p,
          w.value,
          age: b == null ? null : ageTurned(b.year, w.value),
          congratulated: true,
        ),
      );
    }
  }

  for (final t in texts.entries) {
    entries.add(
      PastTexting(
        textDays[t.key]!,
        t.value.toList()..sort((a, b) => a.name.compareTo(b.name)),
      ),
    );
  }

  // The user's own birthdays.
  for (final w in ownWishes.entries) {
    final from = w.value..sort((a, b) => a.name.compareTo(b.name));
    entries.add(PastOwnBirthday(ownDays[w.key]!, from));
  }

  int rank(PastEntry e) => switch (e) {
    PastContact() => 0,
    PastTexting() => 1,
    PastPersonBirthday() => 2,
    PastOwnBirthday() => 3,
  };
  entries.sort((a, b) {
    var c = b.day.compareTo(a.day);
    if (c != 0) return c;
    c = rank(a) - rank(b);
    if (c != 0) return c;
    if (a is PastContact && b is PastContact) {
      c = b.event.at.compareTo(a.event.at);
      if (c != 0) return c;
      return a.event.id.compareTo(b.event.id);
    }
    if (a is PastPersonBirthday && b is PastPersonBirthday) {
      c = a.person.name.compareTo(b.person.name);
      if (c != 0) return c;
      return a.person.id.compareTo(b.person.id);
    }
    return 0;
  });
  return entries;
}

/// How the past is split: today (no label, right under the "Today" mark),
/// earlier this week, last week, then one group per month.
enum PastGroupKind { today, earlierThisWeek, lastWeek, month }

/// A run of past entries under one label. [month] is the first day of the
/// month for [PastGroupKind.month], null otherwise.
class PastGroup {
  const PastGroup(this.kind, this.entries, {this.month});

  final PastGroupKind kind;
  final DateTime? month;
  final List<PastEntry> entries;
}

/// Splits newest-first [entries] into groups. Weeks run Monday to Sunday.
List<PastGroup> groupPast(List<PastEntry> entries, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final monday = DateTime(
    today.year,
    today.month,
    today.day - (today.weekday - 1),
  );
  final lastMonday = DateTime(monday.year, monday.month, monday.day - 7);
  final groups = <PastGroup>[];
  PastGroupKind? kind;
  DateTime? month;
  var current = <PastEntry>[];
  void flush() {
    if (current.isNotEmpty) groups.add(PastGroup(kind!, current, month: month));
    current = [];
  }

  for (final e in entries) {
    final k = !e.day.isBefore(today)
        ? PastGroupKind.today
        : !e.day.isBefore(monday)
        ? PastGroupKind.earlierThisWeek
        : !e.day.isBefore(lastMonday)
        ? PastGroupKind.lastWeek
        : PastGroupKind.month;
    final m = k == PastGroupKind.month
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
