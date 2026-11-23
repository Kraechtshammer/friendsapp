import '../../app/theme.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';

/// One tile in [KindTiles].
class KindOption<T> {
  const KindOption(this.value, this.icon, this.label);

  final T value;
  final KeptIcons icon;

  /// Shown under the chosen tile; also the accessibility label of every tile.
  final String label;
}

/// Large icon tiles in one row (concept log-sheet-v3, K). The chosen tile
/// is filled with the sun tone and alone shows its label. Every tile keeps
/// its label for screen readers and as a tooltip.
class KindTiles<T> extends StatelessWidget {
  const KindTiles({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<KindOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    const radius = BorderRadius.all(Radius.circular(18));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        for (final o in options)
          Expanded(
            child: Column(
              spacing: 4,
              children: [
                Tooltip(
                  message: o.label,
                  child: Semantics(
                    button: true,
                    selected: o.value == value,
                    label: o.label,
                    child: ExcludeSemantics(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          boxShadow: [
                            BoxShadow(
                              color: o.value == value
                                  ? KeptColors.sunEdge
                                  : kept.greyEdge,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: o.value == value
                              ? KeptColors.sun
                              : kept.surfaceHigh,
                          borderRadius: radius,
                          child: InkWell(
                            borderRadius: radius,
                            onTap: () => onChanged(o.value),
                            child: SizedBox(
                              height: 60,
                              child: Center(child: KeptIcon(o.icon, size: 32)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 18,
                  child: o.value == value
                      ? FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            o.label,
                            style: context.text.bodyMedium?.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: kept.text,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
