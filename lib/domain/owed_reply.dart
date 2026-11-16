import '../data/database.dart';
import 'contact_event.dart';

/// Owed replies (02-design.md §2.6, F6, Q9). The app cannot see the user's
/// answer, so it only asks, after a waiting time: "Still owe Jonas a
/// reply?". These rules are pure; the current time is a parameter.

/// The start value of the waiting time, in days.
const defaultReplyWaitDays = 2;

/// Since when [person] has been waiting for a reply, or null if no reply
/// is owed at [now].
///
/// A reply is owed when the person's newest incoming written contact
/// (`wrote`, `byThem`, any source) is at least [waitDays] days old, the
/// user has not been in contact since (no event `byUser` or `together` at
/// or after it), and "Already answered" or opening the chat
/// (`replyClearedAt`) was not at or after it. Only the newest incoming
/// message counts: if it is younger than the waiting time, nothing is
/// owed yet, however old an earlier one is. Calls never make a reply owed.
///
/// With [listenerOn] false, entries from the notification listener are
/// left out; ones entered by hand still count. [events] may hold other
/// people's events; they are ignored.
DateTime? owedSince(
  Person person,
  Iterable<ContactEvent> events, {
  required DateTime now,
  int waitDays = defaultReplyWaitDays,
  bool listenerOn = true,
}) {
  ContactEvent? incoming;
  for (final e in events) {
    if (e.personId != person.id) continue;
    if (e.kind != ContactKind.wrote || e.direction != ContactDirection.byThem) {
      continue;
    }
    if (!listenerOn && e.source == ContactSource.listener) continue;
    if (incoming == null || e.at.isAfter(incoming.at)) incoming = e;
  }
  if (incoming == null) return null;
  final since = incoming.at;
  // Calendar days, so a clock change does not move the day.
  final due = DateTime(
    since.year,
    since.month,
    since.day + waitDays,
    since.hour,
    since.minute,
    since.second,
  );
  if (now.isBefore(due)) return null;
  for (final e in events) {
    if (e.personId != person.id) continue;
    if (e.direction == ContactDirection.byThem) continue;
    if (!e.at.isBefore(since)) return null;
  }
  final cleared = person.replyClearedAt;
  if (cleared != null && !cleared.isBefore(since)) return null;
  return since;
}

/// A person who may be owed a reply, and since when.
typedef OwedReply = ({Person person, DateTime since});

/// Everyone in [people] who is owed a reply at [now] ([owedSince]), longest
/// owed first; ties go by the order of [people].
List<OwedReply> owedReplies(
  List<Person> people,
  Iterable<ContactEvent> events, {
  required DateTime now,
  int waitDays = defaultReplyWaitDays,
  bool listenerOn = true,
}) {
  final byPerson = <String, List<ContactEvent>>{};
  for (final e in events) {
    (byPerson[e.personId] ??= []).add(e);
  }
  final owed = <OwedReply>[
    for (final p in people)
      if (owedSince(
            p,
            byPerson[p.id] ?? const [],
            now: now,
            waitDays: waitDays,
            listenerOn: listenerOn,
          )
          case final since?)
        (person: p, since: since),
  ];
  // List.sort is not stable; keep the order of [people] on a tie.
  final index = {for (var i = 0; i < people.length; i++) people[i].id: i};
  owed.sort((a, b) {
    final c = a.since.compareTo(b.since);
    return c != 0 ? c : index[a.person.id]!.compareTo(index[b.person.id]!);
  });
  return owed;
}
