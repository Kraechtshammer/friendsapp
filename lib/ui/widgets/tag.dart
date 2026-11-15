import 'dart:math' as math;

import '../../app/theme.dart';
import '../common.dart';
import '../material.dart';

/// A small label that marks state (ui-style.md §6): Outfit on an accent,
/// or on surface-high when [accent] is null; radius 14, shadow 3, tilted by
/// [tilt] degrees.
class Tag extends StatelessWidget {
  const Tag(this.label, {super.key, this.accent, this.tilt = 0});

  final String label;
  final Color? accent;
  final double tilt;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    final tag = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: accent ?? kept.surfaceHigh,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: kept.shadow, offset: const Offset(0, 3))],
      ),
      child: Text(
        label,
        style: outfit(
          13,
          FontWeight.w600,
          color: accent == null ? kept.text : KeptColors.onAccent,
        ),
      ),
    );
    if (tilt == 0) return tag;
    return Transform.rotate(angle: tilt * math.pi / 180, child: tag);
  }
}
