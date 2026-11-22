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

/// Three or more faces for a contact with several people, overlapping in a
/// row like [CoupleAvatar]'s pair, each with a ring in [ringColor]. Shows at
/// most [max] faces; the rest are one "+n" bubble. [size] is the height of
/// a face.
class CrowdAvatar extends StatelessWidget {
  const CrowdAvatar(
    this.people, {
    super.key,
    this.size = 72,
    this.max = 4,
    this.ringColor,
  });

  final List<Person> people;
  final double size;
  final int max;
  final Color? ringColor;

  static const _ring = 3.0;

  @override
  Widget build(BuildContext context) {
    final shown = people.take(max).toList();
    final more = people.length - shown.length;
    final ring = ringColor ?? context.kept.ground;
    final step = size * .62;
    final count = shown.length + (more > 0 ? 1 : 0);
    return SizedBox(
      width: size + step * (count - 1),
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < shown.length; i++) ...[
            if (i > 0)
              Positioned(
                left: step * i - _ring,
                top: -_ring,
                child: CustomPaint(
                  size: Size.square(size + 2 * _ring),
                  painter: _RingPainter(
                    avatarPath(shown[i].avatarShape, size + 2 * _ring),
                    ring,
                  ),
                ),
              ),
            Positioned(
              left: step * i,
              child: Avatar.person(shown[i], size: size),
            ),
          ],
          if (more > 0)
            Positioned(
              left: step * shown.length - _ring,
              top: -_ring,
              child: Container(
                width: size + 2 * _ring,
                height: size + 2 * _ring,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: ring, shape: BoxShape.circle),
                child: Container(
                  width: size,
                  height: size,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.kept.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '+$more',
                    style: context.text.titleLarge?.copyWith(
                      color: context.kept.text,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
