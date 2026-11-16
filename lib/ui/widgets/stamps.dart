import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import '../../app/theme.dart';
import '../common.dart';
import '../material.dart';
import 'avatar.dart';
import '../../domain/person.dart';

/// The tilts of the stamps in degrees, 3 to 9, alternating left and right
/// (ui-style.md §6, "Stamp card"). Stamp number [index] takes one.
const _tilts = <double>[-9, 7, -3, 5, -6, 8, -4, 6, -8, 3];

/// One stamp (ui-style.md §6): a coral scalloped circle with a dark check,
/// tilted, with a small hard shadow that follows its shape. It sits in
/// place, not off-centre (02-design.md §6.6, V6).
class StampMark extends StatelessWidget {
  const StampMark({super.key, this.size = 56, this.index = 0});

  final double size;

  /// Which tilt it gets, so a row of stamps alternates.
  final int index;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: _tilts[index % _tilts.length] * math.pi / 180,
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _StampPainter(avatarPath(AvatarShape.scallop, size)),
        child: Center(
          child: Icon(
            Icons.check_rounded,
            size: size * .56,
            color: KeptColors.onAccent,
          ),
        ),
      ),
    ),
  );
}

class _StampPainter extends CustomPainter {
  const _StampPainter(this.path);

  final Path path;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      path.shift(const Offset(0, 2)),
      Paint()..color = KeptColors.avatarShadow,
    );
    canvas.drawPath(path, Paint()..color = KeptColors.coral);
  }

  @override
  bool shouldRepaint(_StampPainter old) => old.path != path;
}

/// An empty slot (ui-style.md §5, §6): a dashed ring, no shadow, in the
/// text colour of the card at half strength.
class EmptySlot extends StatelessWidget {
  const EmptySlot({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: _RingPainter(
        (DefaultTextStyle.of(context).style.color ?? context.kept.text)
            .withValues(alpha: .5),
      ),
    ),
  );
}

class _RingPainter extends CustomPainter {
  const _RingPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final ring = Path()
      ..addOval(Rect.fromLTWH(1, 1, size.width - 2, size.height - 2));
    for (final PathMetric m in ring.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 10) {
        canvas.drawPath(m.extractPath(d, d + 6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.color != color;
}

/// The slots of a stamp card: [filled] stamps, then dashed rings up to
/// [total]. Up to ten slots go five to a row, bigger cards eight to a row;
/// they shrink to fit the width, up to 56.
class StampSlots extends StatelessWidget {
  const StampSlots({super.key, required this.filled, required this.total});

  final int filled;
  final int total;

  static const _gap = 6.0;

  @override
  Widget build(BuildContext context) {
    final perRow = total <= 5 ? total : (total <= 10 ? 5 : 8);
    return Semantics(
      label: context.l10n.stampCardSemantics(filled, total),
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, box) {
          final fit = (box.maxWidth - _gap * (perRow - 1)) / perRow;
          final size = math.min(56.0, fit.isFinite ? fit : 56.0);
          return Wrap(
            spacing: _gap,
            runSpacing: _gap,
            children: [
              for (var i = 0; i < total; i++)
                SizedBox.square(
                  dimension: size,
                  child: i < filled
                      ? StampMark(size: size, index: i)
                      : EmptySlot(size: size),
                ),
            ],
          );
        },
      ),
    );
  }
}
