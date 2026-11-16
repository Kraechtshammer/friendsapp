/// The plain enums of an intention. No drift here: the database stores them
/// as text by name (`textEnum`), so values can be added or reordered but
/// never renamed. See docs/02-design.md §2.1 and §3.
library;

/// What the user wants to do. Picked at capture; the default is [write].
enum IntentionKind { write, call, meet, game }

/// Open until the user does it or lets it go.
enum IntentionState { open, done, dropped }

/// A rough "when" instead of a date (used from milestone M5).
/// [whenCondition] goes with the intention's condition text.
enum Horizon { soon, later, whenCondition }

/// The "when" of an intention: a date, or a rough horizon, or nothing. At
/// most one of [date] and [horizon] is set; [condition] only goes with
/// [Horizon.whenCondition].
///
/// A day without a time is stored as local midnight, so **midnight means
/// "no time"** ([hasTime]). A planned time of exactly 00:00 cannot be told
/// apart from that, which is fine for this app.
class When {
  const When.none() : date = null, horizon = null, condition = null;

  const When.date(DateTime this.date) : horizon = null, condition = null;

  const When.horizon(Horizon this.horizon, {this.condition}) : date = null;

  final DateTime? date;
  final Horizon? horizon;
  final String? condition;

  bool get isNone => date == null && horizon == null;

  /// Whether the date carries a time of day (it is not local midnight).
  bool get hasTime => date != null && dateHasTime(date!);

  @override
  bool operator ==(Object other) =>
      other is When &&
      other.date == date &&
      other.horizon == horizon &&
      other.condition == condition;

  @override
  int get hashCode => Object.hash(date, horizon, condition);

  @override
  String toString() => 'When($date, $horizon, $condition)';
}

/// Whether a stored date has a time of day. Midnight means "no time".
bool dateHasTime(DateTime date) => date.hour != 0 || date.minute != 0;
