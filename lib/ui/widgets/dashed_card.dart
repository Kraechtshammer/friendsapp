import 'dart:ui' show PathMetric;

import '../common.dart';
import '../material.dart';

/// A dashed "empty" card (ui-style.md §5 and §6): transparent, a 2 px dashed
/// border in the line colour, radius 22, no shadow. For the undated plans.
class DashedCard extends StatelessWidget {
  const DashedCard({
    super.key,
    this.padding = const EdgeInsets.all(14),
    required this.child,
  });

  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DashedBorder(context.kept.line),
    child: Padding(padding: padding, child: child),
  );
}

class _DashedBorder extends CustomPainter {
  const _DashedBorder(this.color);

  final Color color;

  static const _radius = 22.0;
  static const _dash = 9.0;
  static const _gap = 7.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(_radius),
    ).deflate(1);
    final path = Path()..addRRect(rect);
    for (final PathMetric metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += _dash + _gap) {
        canvas.drawPath(metric.extractPath(d, d + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder old) => old.color != color;
}
