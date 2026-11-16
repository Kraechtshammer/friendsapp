import '../../data/database.dart';
import '../common.dart';
import '../material.dart';
import 'avatar.dart';

/// Two avatars overlapping, for a couple (02-design.md §8, 2026-11-16).
/// The second sits lower right and over the first, with a ring between
/// them. The whole thing fits in a [size] square, so it can take the place
/// of a single avatar of that size in a row; each face is 62 % of it.
/// [ringColor] is the colour behind it: the ground by default, the surface
/// colour on a card.
class CoupleAvatar extends StatelessWidget {
  const CoupleAvatar(this.members, {super.key, this.size = 48, this.ringColor})
    : assert(members.length >= 2);

  final List<Person> members;
  final double size;
  final Color? ringColor;

  static const _face = .62;
  static const _ring = 3.0;

  @override
  Widget build(BuildContext context) {
    final d = size * _face;
    final offset = size - d;
    final first = members[0], second = members[1];
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: 0, top: 0, child: Avatar.person(first, size: d)),
          // The ring is the second face's outline, a little larger.
          Positioned(
            left: offset - _ring,
            top: offset - _ring,
            child: CustomPaint(
              size: Size.square(d + 2 * _ring),
              painter: _RingPainter(
                avatarPath(second.avatarShape, d + 2 * _ring),
                ringColor ?? context.kept.ground,
              ),
            ),
          ),
          Positioned(
            left: offset,
            top: offset,
            child: Avatar.person(second, size: d),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.path, this.color);

  final Path path;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) =>
      canvas.drawPath(path, Paint()..color = color);

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.color != color || old.path != path;
}
