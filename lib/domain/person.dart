/// The plain enums of a person. No drift here: the database stores them as
/// text by name (`textEnum`), so values can be reordered but never renamed.
/// See docs/02-design.md §3 and §8.
library;

export 'chat_app.dart' show ChatApp;

/// The class a person is in, or Family as its own group.
enum Closeness { close, nowAndThen, fewTimesAYear, family }

/// The avatar's outline, picked when the person is added.
enum AvatarShape { scallop, squircle, leaf, arch }

/// The avatar's colour, one of the style guide's accents.
enum AvatarColor { coral, sun, mint, lilac, sky, pink }
