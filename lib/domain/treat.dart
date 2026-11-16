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
