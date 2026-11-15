import '../../app/theme.dart';
import '../common.dart';
import '../material.dart';

/// A card (ui-style.md §6): surface colour or a [Tone], radius 28, padding
/// 16, hard shadow 5. [small] is the list-row size: radius 20, shadow 4.
class KeptCard extends StatelessWidget {
  const KeptCard({
    super.key,
    this.tone,
    this.small = false,
    this.padding = const EdgeInsets.all(16),
    required this.child,
  });

  final Tone? tone;
  final bool small;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: tone?.container ?? kept.surface,
        borderRadius: BorderRadius.circular(small ? 20 : 28),
        // A solid offset copy, no blur (ui-style.md §2.3).
        boxShadow: [
          BoxShadow(color: kept.shadow, offset: Offset(0, small ? 4 : 5)),
        ],
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: tone?.onContainer ?? kept.text),
        child: child,
      ),
    );
  }
}
