import '../../app/theme.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';

/// One choice in [ChoiceChips].
class ChipOption<T> {
  const ChipOption(this.value, this.label, {this.icon});

  final T value;
  final String label;
  final KeptIcons? icon;
}

/// A single choice among chips (ui-style.md §6): 44 high, radius 14, thin
/// border in the text colour. The chosen one has a sun fill, dark text and
/// no border. The chips wrap onto more lines.
class ChoiceChips<T> extends StatelessWidget {
  const ChoiceChips({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<ChipOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final o in options)
        _Chip(
          option: o,
          selected: o.value == value,
          onTap: () => onChanged(o.value),
        ),
    ],
  );
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final ChipOption<Object?> option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    final shape = BorderRadius.circular(14);
    // Dark text on the sun fill in both themes.
    final textColor = selected ? KeptColors.onAccent : kept.text;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? KeptColors.sun : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: shape,
          side: selected ? BorderSide.none : BorderSide(color: kept.text),
        ),
        child: InkWell(
          borderRadius: shape,
          onTap: onTap,
          child: SizedBox(
            height: 44,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  if (option.icon != null) KeptIcon(option.icon!, size: 20),
                  Text(
                    option.label,
                    style: context.text.labelLarge?.copyWith(
                      fontSize: 15,
                      color: textColor,
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
