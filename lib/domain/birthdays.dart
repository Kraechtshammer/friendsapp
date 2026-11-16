import '../data/database.dart';
import 'contact_event.dart';

/// Birthdays (02-design.md §2.5 and the M4 decisions in §8) as pure
/// functions. Days are local calendar days; nothing here reads the clock.
///
/// A birthday on 29 February counts on 28 February in years without a
/// 29 February.

/// A birthday: day and month, the year only when it is known. Used for the
/// user's own birthday, which is a setting.
class Birthday {
  const Birthday(this.month, this.day, [this.year]);

  final int month;
  final int day;
  final int? year;

  /// Reads the stored form: `MM-DD` or `YYYY-MM-DD`. Null for anything
  /// else, or for a day that does not exist.
  static Birthday? parse(String? text) {
    final m = RegExp(r'^(?:(\d{4})-)?(\d{2})-(\d{2})$')
        .firstMatch(text?.trim() ?? '');
    if (m == null) return null;
    final year = m[1] == null ? null : int.parse(m[1]!);
    final b = Birthday(int.parse(m[2]!), int.parse(m[3]!), year);
    return b.isValid ? b : null;
  }

  /// A real day and month; 29 February is fine without a year and with a
  /// year only in a leap year.
  bool get isValid {
    if (month < 1 || month > 12 || day < 1) return false;
    // 2000 is a leap year, so 29 February works when the year is unknown.
    final check = DateTime(year ?? 2000, month, day);
    return check.month == month && check.day == day;
  }

  /// The stored form, see [parse].
  String format() {
    String two(int n) => n.toString().padLeft(2, '0');
    final md = '${two(month)}-${two(day)}';
    return year == null ? md : '${year.toString().padLeft(4, '0')}-$md';
  }

  @override
  bool operator ==(Object other) =>
      other is Birthday &&
      other.month == month &&
      other.day == day &&
      other.year == year;

  @override
  int get hashCode => Object.hash(month, day, year);

  @override
  String toString() => 'Birthday(${format()})';
}

/// The result of checking typed birthday fields: [ok] is false for fields
/// that do not form a real day; [birthday] is null for empty fields.
class BirthdayFields {
  const BirthdayFields._(this.birthday, this.ok);

  final Birthday? birthday;
  final bool ok;

  /// Empty fields are no birthday. Day and month must both be there and
  /// form a real date. A year is optional but must be 1900 or later and not
  /// in the future. The same rules as the person form.
  static BirthdayFields check(
    String day,
    String month,
    String year,
    DateTime now,
  ) {
    const bad = BirthdayFields._(null, false);
    if (day.trim().isEmpty && month.trim().isEmpty && year.trim().isEmpty) {
      return const BirthdayFields._(null, true);
    }
    final d = int.tryParse(day.trim()), m = int.tryParse(month.trim());
    final y = int.tryParse(year.trim());
    if (d == null || m == null) return bad;
    if (year.trim().isNotEmpty && (y == null || y < 1900 || y > now.year)) {
      return bad;
    }
    final b = Birthday(m, d, y);
    return b.isValid ? BirthdayFields._(b, true) : bad;
  }
}

/// The day in [year] on which a birthday of [month] and [day] is kept:
/// that day, or 28 February for 29 February in a year without it.
DateTime birthdayIn(int year, int month, int day) {
  if (month == 2 && day == 29 && DateTime(year, 2, 29).month != 2) {
    return DateTime(year, 2, 28);
  }
  return DateTime(year, month, day);
}

/// Whether a birthday of [month] and [day] falls on the local day of [date].
bool isBirthdayOn(int month, int day, DateTime date) {
  final kept = birthdayIn(date.year, month, day);
  return kept.month == date.month && kept.day == date.day;
}

/// The person's birthday, if both day and month are known.
Birthday? birthdayOf(Person p) =>
    p.birthdayMonth != null && p.birthdayDay != null
    ? Birthday(p.birthdayMonth!, p.birthdayDay!, p.birthdayYear)
    : null;

/// The people in [people] whose birthday is on the local day of [date], in
/// the order given.
List<Person> birthdaysOn(List<Person> people, DateTime date) => [
  for (final p in people)
    if (birthdayOf(p) case final b? when isBirthdayOn(b.month, b.day, date)) p,
];

/// The next day (midnight) on or after the local day of [from] on which the
/// birthday is kept. On the birthday itself that is the same day.
DateTime nextBirthday(int month, int day, DateTime from) {
  final today = DateTime(from.year, from.month, from.day);
  final thisYear = birthdayIn(from.year, month, day);
  return thisYear.isBefore(today)
      ? birthdayIn(from.year + 1, month, day)
      : thisYear;
}

/// The most recent day (midnight) on or before the local day of [from] on
/// which the birthday was kept. On the birthday itself that is the same
/// day.
DateTime lastBirthday(int month, int day, DateTime from) {
  final today = DateTime(from.year, from.month, from.day);
  final thisYear = birthdayIn(from.year, month, day);
  return thisYear.isAfter(today)
      ? birthdayIn(from.year - 1, month, day)
      : thisYear;
}

/// The age turned on the birthday in the year of [date], if the birth year
/// is known and before that year. Null otherwise.
int? ageTurned(int? birthYear, DateTime date) {
  if (birthYear == null) return null;
  final age = date.year - birthYear;
  return age > 0 ? age : null;
}

/// Whether [e] is the user's birthday wish on the local day of [date].
bool isWishByUserOn(ContactEvent e, DateTime date) =>
    e.kind == ContactKind.birthdayWish &&
    e.direction == ContactDirection.byUser &&
    dayKey(e.at) == dayKey(date);

/// Whether the user congratulated on the local day of [date], from one
/// person's contact events: a birthday wish by the user dated that day.
bool congratulatedOn(Iterable<ContactEvent> events, DateTime date) =>
    events.any((e) => isWishByUserOn(e, date));

/// The ids of the people the user congratulated on the local day of
/// [date], from any events.
Set<String> congratulatedIds(Iterable<ContactEvent> events, DateTime date) => {
  for (final e in events)
    if (isWishByUserOn(e, date)) e.personId,
};
