import '../../app/theme.dart';
import '../common.dart';
import '../material.dart';

/// A card (ui-style.md §6): surface colour or a [Tone], radius 28, padding
/// 16, hard shadow 5. [small] is the list-row size: radius 20, shadow 4.
/// With [onTap] the whole card is tappable.
class KeptCard extends StatelessWidget {
  const KeptCard({
    super.key,
    this.tone,
    this.small = false,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    required this.child,
  });

  final Tone? tone;
  final bool small;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    final radius = BorderRadius.circular(small ? 20 : 28);
    final content = DefaultTextStyle.merge(
      style: TextStyle(color: tone?.onContainer ?? kept.text),
      child: child,
    );
    return Container(
      decoration: BoxDecoration(
        color: tone?.container ?? kept.surface,
        borderRadius: radius,
        // A solid offset copy, no blur (ui-style.md §2.3).
        boxShadow: [
          BoxShadow(color: kept.shadow, offset: Offset(0, small ? 4 : 5)),
        ],
      ),
      child: onTap == null
          ? Padding(padding: padding, child: content)
          // The ink needs its own Material above the card's colour.
          : Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: radius,
                onTap: onTap,
                child: Padding(padding: padding, child: content),
              ),
            ),
    );
  }
}
