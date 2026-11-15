import 'person.dart';

/// A shape and colour pair for a person's avatar.
typedef Avatar = ({AvatarShape shape, AvatarColor color});

/// All 24 pairs in the order used to break ties. Consecutive pairs differ in
/// both shape and colour, also from the last back to the first: the first
/// 12 walk shape and colour together, the next 12 do the same with the
/// colour moved on by three, which covers the pairs the first walk skips
/// (4 and 6 share the factor 2).
final List<Avatar> avatarOrder = [
  for (var i = 0; i < 24; i++)
    (
      shape: AvatarShape.values[i % 4],
      color: AvatarColor.values[(i + 3 * (i ~/ 12)) % 6],
    ),
];

/// Picks the avatar for a new person, so that people differ
/// (02-design.md §8, avatars). [used] are the avatars of everyone there now.
///
/// Takes the pair used least. Among equals it prefers the colour used
/// least, then the shape used least, then the earlier pair in
/// [avatarOrder]. The result depends only on [used], not on chance.
Avatar pickAvatar(Iterable<Avatar> used) {
  final pairs = <Avatar, int>{};
  final colors = <AvatarColor, int>{};
  final shapes = <AvatarShape, int>{};
  for (final a in used) {
    pairs[a] = (pairs[a] ?? 0) + 1;
    colors[a.color] = (colors[a.color] ?? 0) + 1;
    shapes[a.shape] = (shapes[a.shape] ?? 0) + 1;
  }
  List<int> score(Avatar a) => [
    pairs[a] ?? 0,
    colors[a.color] ?? 0,
    shapes[a.shape] ?? 0,
  ];
  var best = avatarOrder.first;
  var bestScore = score(best);
  for (final a in avatarOrder.skip(1)) {
    final s = score(a);
    final better = s[0] != bestScore[0]
        ? s[0] < bestScore[0]
        : s[1] != bestScore[1]
        ? s[1] < bestScore[1]
        : s[2] < bestScore[2];
    if (better) {
      best = a;
      bestScore = s;
    }
  }
  return best;
}
