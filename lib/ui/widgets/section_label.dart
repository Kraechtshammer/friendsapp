import '../common.dart';
import '../material.dart';

/// A section label (ui-style.md §4): Outfit 13/600, upper case, letter
/// spacing 0.08 em, muted.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.label, {super.key, this.color});

  final String label;

  /// Defaults to the muted text colour.
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
    label.toUpperCase(),
    style: context.text.labelMedium?.copyWith(
      color: color ?? context.kept.muted,
    ),
  );
}
