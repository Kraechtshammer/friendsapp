/// The plain enums of an intention. No drift here: the database stores them
/// as text by name (`textEnum`), so values can be added or reordered but
/// never renamed. See docs/02-design.md §2.1 and §3.
library;

/// What the user wants to do. Picked at capture; the default is [write].
enum IntentionKind { write, call, meet }

/// Open until the user does it or lets it go.
enum IntentionState { open, done, dropped }

/// A rough "when" instead of a date (used from milestone M5).
/// [whenCondition] goes with the intention's condition text.
enum Horizon { soon, later, whenCondition }
