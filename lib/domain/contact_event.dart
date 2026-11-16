/// The plain enums of a contact event and of the daily answer. No drift
/// here: the database stores them as text by name (`textEnum`), so values
/// can be added or reordered but never renamed. See docs/02-design.md §3.
library;

import 'intention.dart';

/// What kind of contact happened.
enum ContactKind { wrote, called, met, gamed, birthdayWish }

/// Who started it. [together] is for things done together (met, gamed).
enum ContactDirection { byUser, byThem, together }

/// Where the event came from.
enum ContactSource {
  /// The user answered "Did you write?" in the app.
  confirmed,

  /// Entered by hand.
  manual,

  /// Seen by the notification listener.
  listener,
}

/// The user's answer for one day.
enum DayAnswerValue { yes, notToday, none }

/// The contact that doing an intention of [kind] stands for.
ContactKind contactKindFor(IntentionKind kind) => switch (kind) {
  IntentionKind.write => ContactKind.wrote,
  IntentionKind.call => ContactKind.called,
  IntentionKind.meet => ContactKind.met,
  IntentionKind.game => ContactKind.gamed,
};

/// Who the contact for an intention of [kind] goes out from: the user for
/// writing and calling, both for meeting and gaming.
ContactDirection contactDirectionFor(IntentionKind kind) => switch (kind) {
  IntentionKind.write || IntentionKind.call => ContactDirection.byUser,
  IntentionKind.meet || IntentionKind.game => ContactDirection.together,
};

/// The key of the local day of [t] in the day answers: `YYYY-MM-DD`.
String dayKey(DateTime t) {
  final local = t.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year.toString().padLeft(4, '0')}-${two(local.month)}-'
      '${two(local.day)}';
}
