import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/database.dart';
import '../../domain/person.dart';
import '../../l10n/labels.dart';
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

/// A person's initial on their accent, in their shape, with a hard drop
/// shadow that follows the shape (ui-style.md §5 and §6). With a [photo]
/// (a file name in the photo store) the picture fills the shape instead of
/// the initial; the shape, the shadow and the class badge stay (02-design.md
/// §8, 2026-11-16).
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.name,
    required this.shape,
    required this.color,
    this.size = 48,
    this.classBadge = false,
    this.closeness,
    this.photo,
  }) : assert(!classBadge || closeness != null);

  Avatar.person(
    Person person, {
    Key? key,
    double size = 48,
    bool classBadge = false,
  }) : this(
         key: key,
         // The initial of the short name (domain/display_name.dart) is always
         // the first letter of the nickname, else of the name.
         name: (person.nickname?.trim().isNotEmpty ?? false)
             ? person.nickname!
             : person.name,
         photo: person.photo,
         shape: person.avatarShape,
         color: person.avatarColor,
         size: size,
         classBadge: classBadge,
         closeness: person.closeness,
       );

  final String name;
  final AvatarShape shape;
  final AvatarColor color;
  final double size;

  /// Shows the class as a small plant at the bottom right: a sprout for a
  /// few times a year, a bud for now and then, a flower for close friends,
  /// and a house for family (02-design.md §8). For places where people of
  /// different classes are mixed.
  final bool classBadge;

  /// Needed for the badge.
  final Closeness? closeness;

  /// The picture's file name in the photo store, or null for the initial.
  /// Needs a `ProviderScope` above.
  final String? photo;

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
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              initial(name),
              style: outfit(
                size * .44,
                FontWeight.w700,
                color: KeptColors.onAccent,
              ).copyWith(height: 1),
            ),
            if (photo != null) _Photo(photo!, shape, size),
          ],
        ),
      ),
    );
    if (!classBadge) return face;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        face,
        Positioned(
          right: -size * .06,
          bottom: -size * .06,
          child: _Badge(closeness!, size * .38),
        ),
      ],
    );
  }
}

/// The picture, cut to the avatar's shape. It is kept in memory once loaded
/// (`photoBytesProvider`), so a list that scrolls does not flash the initial,
/// and decoded at the size it is shown at (times the device pixel ratio),
/// not at the stored 384 px.
class _Photo extends ConsumerWidget {
  const _Photo(this.name, this.shape, this.size);

  final String name;
  final AvatarShape shape;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = ref.watch(photoBytesProvider(name)).value;
    if (bytes == null) return const SizedBox.shrink();
    final px = (size * MediaQuery.devicePixelRatioOf(context)).round();
    return ClipPath(
      clipper: _ShapeClipper(shape),
      child: Image.memory(
        bytes,
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: px,
        cacheHeight: px,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        excludeFromSemantics: true,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    );
  }
}

class _ShapeClipper extends CustomClipper<Path> {
  const _ShapeClipper(this.shape);

  final AvatarShape shape;

  @override
  Path getClip(Size size) => avatarPath(shape, size.width);

  @override
  bool shouldReclip(_ShapeClipper old) => old.shape != shape;
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

/// The class as a small plant in a surface-coloured circle.
class _Badge extends StatelessWidget {
  const _Badge(this.closeness, this.height);

  final Closeness closeness;
  final double height;

  @override
  Widget build(BuildContext context) {
    final icon = closenessIcon(closeness);
    return Container(
      width: height,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.kept.surface,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: KeptColors.avatarShadow, offset: Offset(0, 2)),
        ],
      ),
      child: KeptIcon(icon, size: height * .68, shadow: false),
    );
  }
}
