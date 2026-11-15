import '../common.dart';
import '../material.dart';

/// The grey button as a rounded square with one icon (ui-style.md §6):
/// 52 × 52 and radius 18 by default, surface-high, hard shadow 4 in the
/// grey edge colour. [tooltip] is also the screen reader label.
class GreyIconButton extends StatelessWidget {
  const GreyIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 52,
    this.radius = 18,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    final shape = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: [
          BoxShadow(color: kept.greyEdge, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: kept.surfaceHigh,
        borderRadius: shape,
        child: InkWell(
          borderRadius: shape,
          onTap: onPressed,
          child: Tooltip(
            message: tooltip,
            child: SizedBox.square(
              dimension: size,
              child: Icon(icon, color: kept.text),
            ),
          ),
        ),
      ),
    );
  }
}
