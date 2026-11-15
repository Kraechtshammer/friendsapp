import '../../app/theme.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';

/// The main button (ui-style.md §6): a coral pill, 52 high, dark Outfit
/// text, an optional colourful icon on the left, hard shadow 4 in the coral
/// edge colour. Fills the width it is given.
class MainButton extends StatelessWidget {
  const MainButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
  });

  final String label;
  final KeptIcons? icon;
  final VoidCallback? onPressed;

  static const _radius = BorderRadius.all(Radius.circular(26));

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: _radius,
        boxShadow: [
          BoxShadow(color: KeptColors.coralEdge, offset: Offset(0, 4)),
        ],
      ),
      child: Material(
        color: KeptColors.coral,
        borderRadius: _radius,
        child: InkWell(
          borderRadius: _radius,
          onTap: onPressed,
          child: SizedBox(
            height: 52,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  if (icon != null) KeptIcon(icon!, size: 28),
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelLarge?.copyWith(
                        color: KeptColors.onAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
