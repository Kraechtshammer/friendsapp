import '../data/database.dart';
import 'contact_event.dart';
import 'person.dart';
import 'stamps.dart';
import 'treat.dart';

/// What the Progress tab shows, worked out as pure functions. Everything
/// here only grows or is a plain count of what happened; nothing compares
/// with a target (02-design.md §8).

/// The user's stamp count: all stamp values added up. Only ever grows.
int stampTotal(Iterable<Stamp> stamps) =>
    stamps.fold(0, (sum, s) => sum + s.value);

/// How many stamps sit on the card of [treatId].
int stampsOnCard(Iterable<Stamp> stamps, String treatId) => stamps
    .where((s) => s.treatId == treatId)
    .fold(0, (sum, s) => sum + s.value);

/// The treat with the card the stamps go onto now; null if none is chosen.
Treat? currentTreat(Iterable<Treat> treats) {
  for (final t in treats) {
    if (t.state == TreatState.current) return t;
  }
  return null;
}

/// The treats of one [state], in queue order (waiting) or by the time they
/// were earned, newest first (earned, enjoyed).
List<Treat> treatsIn(Iterable<Treat> treats, TreatState state) {
  final list = [
    for (final t in treats)
      if (t.state == state) t,
  ];
  if (state == TreatState.earned || state == TreatState.enjoyed) {
    list.sort((a, b) {
      final x = a.earnedAt ?? a.createdAt, y = b.earnedAt ?? b.createdAt;
      return y.compareTo(x);
    });
  }
  return list;
}

/// Whether [event] is a contact by the user or together (what the weeks
/// and "Your numbers" count).
bool isOwnContact(ContactEvent event) =>
    earnsStamp(event.kind, event.direction);

/// The people the user was in contact with in the week of [now], newest
/// contact first, each once.
List<String> peopleThisWeek(Iterable<ContactEvent> events, DateTime now) {
  final from = weekStart(now), until = nextWeekStart(now);
  final own =
      [
        for (final e in events)
          if (isOwnContact(e) && !e.at.isBefore(from) && e.at.isBefore(until))
            e,
      ]..sort((a, b) {
        final byTime = b.at.compareTo(a.at);
        return byTime != 0 ? byTime : a.id.compareTo(b.id);
      });
  return {for (final e in own) e.personId}.toList();
}

/// How "weeks in a row" treats a finished week without a contact beyond the
/// close friends. Strict is the start value.
enum StreakMode {
  /// Such a week ends the run; the next counting week starts at 1.
  strict,

  /// Such a week only pauses the count, which is the number of all counting
  /// weeks.
  friendly,
}

/// The result of [weekStreak].
class WeekStreak {
  const WeekStreak({
    required this.count,
    required this.longest,
    required this.thisWeekCounts,
  });

  /// The number shown: in strict mode the run up to now, in friendly mode
  /// all counting weeks.
  final int count;

  /// The longest run of counting weeks so far (equal to [count] in friendly
  /// mode).
  final int longest;

  /// The running week already has a contact that counts.
  final bool thisWeekCounts;

  /// Strict mode only: there were counting weeks, but the run is over.
  bool get ended => count == 0 && longest > 0;

  @override
  bool operator ==(Object other) =>
      other is WeekStreak &&
      other.count == count &&
      other.longest == longest &&
      other.thisWeekCounts == thisWeekCounts;

  @override
  int get hashCode => Object.hash(count, longest, thisWeekCounts);
}

/// "Weeks in a row" (02-design.md §8, review of 2026-11-16). A week
/// (Monday to Sunday) counts when the user was in contact (by the user or
/// together) with at least one person who is not a close friend; family and
/// the other classes count. [closeness] maps person ids to their class;
/// contacts of unknown people are left out.
///
/// Strict: the count is the run of consecutive counting weeks that ends in
/// the running week, or in the week before it (the running week does not
/// break a run while it is still open); 0 when neither counts. Friendly:
/// the count is the number of all counting weeks.
WeekStreak weekStreak(
  Iterable<ContactEvent> events,
  Map<String, Closeness> closeness,
  DateTime now,
  StreakMode mode,
) {
  final weeks = {
    for (final e in events)
      if (isOwnContact(e) &&
          closeness[e.personId] != null &&
          closeness[e.personId] != Closeness.close)
        weekStart(e.at),
  }.toList()..sort();
  final thisWeek = weekStart(now);
  final counts = weeks.contains(thisWeek);
  if (mode == StreakMode.friendly) {
    return WeekStreak(
      count: weeks.length,
      longest: weeks.length,
      thisWeekCounts: counts,
    );
  }
  var longest = 0, run = 0;
  DateTime? before;
  final runEnding = <DateTime, int>{};
  for (final w in weeks) {
    run = before != null && nextWeekStart(before) == w ? run + 1 : 1;
    runEnding[w] = run;
    if (run > longest) longest = run;
    before = w;
  }
  final lastWeek = DateTime(thisWeek.year, thisWeek.month, thisWeek.day - 7);
  final count = runEnding[thisWeek] ?? runEnding[lastWeek] ?? 0;
  return WeekStreak(count: count, longest: longest, thisWeekCounts: counts);
}

/// The numbers for the user's own use, small and only counting.
class YourNumbers {
  const YourNumbers({
    required this.eveningsYes,
    required this.contactsThisMonth,
    required this.peopleThisMonth,
  });

  /// Evenings the user answered Yes.
  final int eveningsYes;

  /// Contacts by the user (or together) in the month of now.
  final int contactsThisMonth;

  /// Different people among them.
  final int peopleThisMonth;

  @override
  bool operator ==(Object other) =>
      other is YourNumbers &&
      other.eveningsYes == eveningsYes &&
      other.contactsThisMonth == contactsThisMonth &&
      other.peopleThisMonth == peopleThisMonth;

  @override
  int get hashCode =>
      Object.hash(eveningsYes, contactsThisMonth, peopleThisMonth);
}

YourNumbers yourNumbers(
  Iterable<ContactEvent> events,
  Iterable<DayAnswer> answers,
  DateTime now,
) {
  final month = [
    for (final e in events)
      if (isOwnContact(e) && e.at.year == now.year && e.at.month == now.month)
        e,
  ];
  return YourNumbers(
    eveningsYes: answers.where((a) => a.answer == DayAnswerValue.yes).length,
    contactsThisMonth: month.length,
    peopleThisMonth: {for (final e in month) e.personId}.length,
  );
}
