import 'contact_event.dart';
import 'person.dart';
import 'rhythm.dart';

/// The stamp rule (02-design.md §6.9, §6.10, milestone M9). Pure: no
/// database, the times are parameters. Only numbers that grow: nothing in
/// here takes a stamp away.

/// The weights of the rule and the default card size. The start values are
/// the ones of 02-design.md §6.10; the user can change every one in the
/// settings (ranges below).
class StampWeights {
  const StampWeights({
    this.close = 1,
    this.nowAndThen = 2,
    this.fewTimesAYear = 3,
    this.family = 1,
    this.backInTouchBonus = 1,
    this.longGapBonus = 1,
    this.meetMultiplier = 2,
    this.gameMultiplier = 2,
    this.cardSize = 10,
  });

  /// The value of a contact with a person of that class.
  final int close;
  final int nowAndThen;
  final int fewTimesAYear;
  final int family;

  /// Added when the person is in "getting back in touch".
  final int backInTouchBonus;

  /// Added when the contact before was longer ago than the person's rhythm.
  final int longGapBonus;

  /// Factors for a meet-up and for gaming together.
  final int meetMultiplier;
  final int gameMultiplier;

  /// How many stamps fill the card of a new treat.
  final int cardSize;

  static const minClass = 1, maxClass = 9;
  static const minBonus = 0, maxBonus = 5;
  static const minMultiplier = 1, maxMultiplier = 4;
  static const minCardSize = 3, maxCardSize = 50;

  int classValue(Closeness closeness) => switch (closeness) {
    Closeness.close => close,
    Closeness.nowAndThen => nowAndThen,
    Closeness.fewTimesAYear => fewTimesAYear,
    Closeness.family => family,
  };

  StampWeights copyWith({
    int? close,
    int? nowAndThen,
    int? fewTimesAYear,
    int? family,
    int? backInTouchBonus,
    int? longGapBonus,
    int? meetMultiplier,
    int? gameMultiplier,
    int? cardSize,
  }) => StampWeights(
    close: close ?? this.close,
    nowAndThen: nowAndThen ?? this.nowAndThen,
    fewTimesAYear: fewTimesAYear ?? this.fewTimesAYear,
    family: family ?? this.family,
    backInTouchBonus: backInTouchBonus ?? this.backInTouchBonus,
    longGapBonus: longGapBonus ?? this.longGapBonus,
    meetMultiplier: meetMultiplier ?? this.meetMultiplier,
    gameMultiplier: gameMultiplier ?? this.gameMultiplier,
    cardSize: cardSize ?? this.cardSize,
  );

  @override
  bool operator ==(Object other) =>
      other is StampWeights &&
      other.close == close &&
      other.nowAndThen == nowAndThen &&
      other.fewTimesAYear == fewTimesAYear &&
      other.family == family &&
      other.backInTouchBonus == backInTouchBonus &&
      other.longGapBonus == longGapBonus &&
      other.meetMultiplier == meetMultiplier &&
      other.gameMultiplier == gameMultiplier &&
      other.cardSize == cardSize;

  @override
  int get hashCode => Object.hash(
    close,
    nowAndThen,
    fewTimesAYear,
    family,
    backInTouchBonus,
    longGapBonus,
    meetMultiplier,
    gameMultiplier,
    cardSize,
  );
}

/// Whether a contact can earn a stamp: it is by the user or together
/// (wrote, called, met, gamed, a birthday wish by the user). Incoming
/// contact earns nothing.
bool earnsStamp(ContactKind kind, ContactDirection direction) =>
    direction != ContactDirection.byThem;

/// The value of one contact with a person, before the weekly cap:
/// the class's weight, plus the bonus for "getting back in touch", plus
/// the bonus when the contact before was longer ago than the rhythm
/// ([rhythmDays], null is none: no bonus), then multiplied for a meet-up
/// and for gaming together. [previous] is the time of the contact before
/// this one, or the day the person was added.
int stampValue({
  required Closeness closeness,
  required bool reconnecting,
  required ContactKind kind,
  required DateTime at,
  required DateTime previous,
  required int? rhythmDays,
  StampWeights weights = const StampWeights(),
}) {
  var value = weights.classValue(closeness);
  if (reconnecting) value += weights.backInTouchBonus;
  if (rhythmDays != null && daysBetween(previous, at) > rhythmDays) {
    value += weights.longGapBonus;
  }
  if (kind == ContactKind.met) value *= weights.meetMultiplier;
  if (kind == ContactKind.gamed) value *= weights.gameMultiplier;
  return value;
}

/// How much to add to a person's stamps of one week: all of [value] when
/// there is none yet ([weekTotal] 0), else only what [value] is worth more
/// than the week has (a meet-up after a message raises the stamp), else
/// nothing. At most one stamp per person per week.
int stampToAdd({required int weekTotal, required int value}) =>
    weekTotal <= 0 ? value : (value > weekTotal ? value - weekTotal : 0);

/// Monday 00:00, local, of the week of [t] (a week is Monday to Sunday).
DateTime weekStart(DateTime t) =>
    DateTime(t.year, t.month, t.day - (t.weekday - DateTime.monday));

/// Monday 00:00 of the week after the one of [t].
DateTime nextWeekStart(DateTime t) {
  final s = weekStart(t);
  return DateTime(s.year, s.month, s.day + 7);
}

/// "Weeks in a row" (02-design.md §8, M9): the number of weeks in which the
/// user had at least one contact. It only grows. A week without contact so
/// far does not reset it: [thisWeekActive] is false and the screen shows a
/// calm pause.
class WeeksInARow {
  const WeeksInARow(this.count, {required this.thisWeekActive});

  final int count;
  final bool thisWeekActive;

  @override
  bool operator ==(Object other) =>
      other is WeeksInARow &&
      other.count == count &&
      other.thisWeekActive == thisWeekActive;

  @override
  int get hashCode => Object.hash(count, thisWeekActive);
}

/// The weeks of [contacts] (times of the user's own and shared contacts)
/// counted once each, and whether the week of [now] has one.
WeeksInARow weeksWithContact(Iterable<DateTime> contacts, DateTime now) {
  final weeks = {for (final t in contacts) weekStart(t)};
  return WeeksInARow(
    weeks.length,
    thisWeekActive: weeks.contains(weekStart(now)),
  );
}
