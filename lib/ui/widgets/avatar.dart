import 'dart:math' as math;

import '../../app/theme.dart';
import '../../data/database.dart';
import '../../domain/person.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';

/// The accent and the tone that belong to an avatar colour.
extension AvatarColorLook on AvatarColor {
  Color get accent => switch (this) {
    AvatarColor.coral => KeptColors.coral,
    AvatarColor.sun => KeptColors.sun,
    AvatarColor.mint => KeptColors.mint,
    AvatarColor.lilac => KeptColors.lilac,
    AvatarColor.sky => KeptColors.sky,
    AvatarColor.pink => KeptColors.pink,
  };

  Tone tone(KeptColors c) => switch (this) {
    AvatarColor.coral => c.coralTone,
    AvatarColor.sun => c.sunTone,
    AvatarColor.mint => c.mintTone,
    AvatarColor.lilac => c.lilacTone,
    AvatarColor.sky => c.skyTone,
    AvatarColor.pink => c.pinkTone,
  };
}

/// The outline of an avatar in a square of [side] (ui-style.md §6, the
/// `.sh1` to `.sh4` classes in docs/concepts/gen_v6.py).
Path avatarPath(AvatarShape shape, double side) {
  final rect = Offset.zero & Size.square(side);
  Radius r(double f) => Radius.circular(side * f);
  return switch (shape) {
    AvatarShape.scallop => _scallop(side),
    AvatarShape.squircle =>
      Path()..addRRect(RRect.fromRectAndRadius(rect, r(.34))),
    // Round, with the bottom left corner tighter.
    AvatarShape.leaf =>
      Path()..addRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: r(.5),
          topRight: r(.5),
          bottomRight: r(.5),
          bottomLeft: r(.22),
        ),
      ),
    // Round top, tighter bottom.
    AvatarShape.arch =>
      Path()..addRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: r(.5),
          topRight: r(.5),
          bottomRight: r(.24),
          bottomLeft: r(.24),
        ),
      ),
  };
}

/// A circle with eight lobes: the radius swings by 5 % of the side, as
/// `cookie_pts` in the concept generator.
Path _scallop(double side, {int lobes = 8, double depth = .05}) {
  const steps = 192;
  final path = Path();
  for (var i = 0; i < steps; i++) {
    final t = 2 * math.pi * i / steps;
    final r = .5 - depth + depth * math.cos(lobes * t);
    final p = Offset(.5 + r * math.cos(t), .5 + r * math.sin(t)) * side;
    i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
  }
  return path..close();
}

/// The class shown on an avatar, if at all. Which one is used is still
/// open; the developer decides on pictures.
enum AvatarBadge { none, dots, icon }

/// Throwaway: which badge the People tab shows, set under "Development" in
/// Settings, so the developer can pick a badge style on the phone. Remove
/// once the style is decided (02-design.md §8).
final badgePreview = ValueNotifier<AvatarBadge>(AvatarBadge.none);

/// A person's initial on their accent, in their shape, with a hard drop
/// shadow that follows the shape (ui-style.md §5 and §6).
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.name,
    required this.shape,
    required this.color,
    this.size = 48,
    this.badge = AvatarBadge.none,
    this.closeness,
  }) : assert(badge == AvatarBadge.none || closeness != null);

  Avatar.person(
    Person person, {
    Key? key,
    double size = 48,
    AvatarBadge badge = AvatarBadge.none,
  }) : this(
         key: key,
         name: person.name,
         shape: person.avatarShape,
         color: person.avatarColor,
         size: size,
         badge: badge,
         closeness: person.closeness,
       );

  final String name;
  final AvatarShape shape;
  final AvatarColor color;
  final double size;
  final AvatarBadge badge;

  /// Needed for a badge.
  final Closeness? closeness;

  /// The first letter of the name, upper case.
  static String initial(String name) {
    final chars = name.trim().characters;
    return chars.isEmpty ? '' : chars.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final face = SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _ShapePainter(
          path: avatarPath(shape, size),
          color: color.accent,
          shadow: size >= 64 ? 3 : 2,
        ),
        child: Center(
          child: Text(
            initial(name),
            style: outfit(
              size * .44,
              FontWeight.w700,
              color: KeptColors.onAccent,
            ).copyWith(height: 1),
          ),
        ),
      ),
    );
    if (badge == AvatarBadge.none) return face;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        face,
        Positioned(
          right: -size * .06,
          bottom: -size * .06,
          child: _Badge(badge, closeness!, size * .38),
        ),
      ],
    );
  }
}

/// Paints [path] in [color] over a copy of itself [shadow] px lower.
class _ShapePainter extends CustomPainter {
  _ShapePainter({
    required this.path,
    required this.color,
    required this.shadow,
  });

  final Path path;
  final Color color;
  final double shadow;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      path.shift(Offset(0, shadow)),
      Paint()..color = KeptColors.avatarShadow,
    );
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ShapePainter old) =>
      old.color != color || old.shadow != shadow || old.path != path;
}

/// The class as a small surface-coloured pill (dots) or circle (icon).
class _Badge extends StatelessWidget {
  const _Badge(this.badge, this.closeness, this.height);

  final AvatarBadge badge;
  final Closeness closeness;
  final double height;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    final Widget content;
    var pill = false;
    if (badge == AvatarBadge.icon || closeness == Closeness.family) {
      final icon = switch (closeness) {
        Closeness.close => KeptIcons.star,
        Closeness.nowAndThen => KeptIcons.chat,
        Closeness.fewTimesAYear => KeptIcons.leaf,
        Closeness.family => KeptIcons.cottage,
      };
      content = KeptIcon(icon, size: height * .66, shadow: false);
    } else {
      pill = true;
      final count = switch (closeness) {
        Closeness.close => 3,
        Closeness.nowAndThen => 2,
        _ => 1,
      };
      final dot = height * .22;
      content = Row(
        mainAxisSize: MainAxisSize.min,
        spacing: dot * .6,
        children: [
          for (var i = 0; i < count; i++)
            Container(
              width: dot,
              height: dot,
              decoration: BoxDecoration(
                color: kept.text,
                shape: BoxShape.circle,
              ),
            ),
        ],
      );
    }
    return Container(
      height: height,
      constraints: BoxConstraints(minWidth: height),
      padding: pill ? EdgeInsets.symmetric(horizontal: height * .28) : null,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: kept.surface,
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: const [
          BoxShadow(color: KeptColors.avatarShadow, offset: Offset(0, 2)),
        ],
      ),
      child: content,
    );
  }
}
