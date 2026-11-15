import '../common.dart';
import '../material.dart';

/// The grey text button (ui-style.md §6): a pill, 52 high, surface-high,
/// hard shadow 4 in the grey edge colour. For the quiet choice next to a
/// [MainButton].
class GreyButton extends StatelessWidget {
  const GreyButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

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
            height: 52,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelLarge?.copyWith(color: kept.text),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
