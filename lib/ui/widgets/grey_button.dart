import '../common.dart';
import '../material.dart';

/// The grey text button (ui-style.md §6): a pill, 52 high, surface-high,
/// hard shadow 4 in the grey edge colour. For the quiet choice next to a
/// [MainButton].
class GreyButton extends StatelessWidget {
  const GreyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.small = false,
  });

  final String label;
  final VoidCallback? onPressed;

  /// A 40 high version for use inside a card.
  final bool small;

  static const _radius = BorderRadius.all(Radius.circular(26));

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: _radius,
        boxShadow: [
          BoxShadow(color: kept.greyEdge, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: kept.surfaceHigh,
        borderRadius: _radius,
        child: InkWell(
          borderRadius: _radius,
          onTap: onPressed,
          child: SizedBox(
            height: small ? 40 : 52,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: small ? 16 : 20),
                // Shrinks a long label to fit instead of cutting it off.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: context.text.labelLarge?.copyWith(
                      color: kept.text,
                      fontSize: small ? 15 : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
