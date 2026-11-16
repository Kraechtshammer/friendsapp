/// The plain enum of a treat. No drift here: the database stores it as text
/// by name (`textEnum`), so values can be added or reordered but never
/// renamed. Added in schema version 4.
library;

/// Where a treat stands. Stamps go onto the [current] treat's card.
enum TreatState {
  /// In the queue, ordered by its position.
  waiting,

  /// The one the stamps go onto now. At most one.
  current,

  /// The card is full; the user has not had the treat yet.
  earned,

  /// The user had it.
  enjoyed,
}

/// The twelve default treats (02-design.md §6.9 and §6.10) with their
/// stamp numbers, in order. The names are texts (`defaultTreatNames` in
/// `l10n/labels.dart`), stored in the language of the app when they are
/// inserted.
const defaultTreatStamps = <int>[
  10,
  10,
  10,
  20,
  10,
  30,
  40,
  10,
  10,
  20,
  20,
  30,
];
