/// The plain enum of an idea for a person. No drift here: the database
/// stores it as text by name (`textEnum`), so values can be added or
/// reordered but never renamed. Added in schema version 4.
library;

/// What kind of idea it is.
enum IdeaKind {
  /// Something to do with the person.
  toDo,

  /// Something to talk about with the person.
  toTalk,
}
