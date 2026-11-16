import '../data/database.dart';
import 'contact_event.dart';
import 'stamps.dart';
import 'treat.dart';

/// What the Progress tab shows, worked out as pure functions. Everything
/// here only grows or is a plain count of what happened; nothing compares
/// with a target (02-design.md §8, M9).

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
