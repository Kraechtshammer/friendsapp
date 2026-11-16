import '../common.dart';
import '../material.dart';
import 'grey_icon_button.dart';

/// A minus button, the value and a plus button (ui-style.md §6: grey
/// square buttons, like the rhythm stepper), for a whole number between
/// [min] and [max]. [label] turns the value into text ("+1", "x2").
class NumberStepper extends StatelessWidget {
  const NumberStepper({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.label,
    this.size = 44,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final String Function(int value)? label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      spacing: 8,
      children: [
        GreyIconButton(
          icon: Icons.remove_rounded,
          tooltip: l10n.stampLess,
          size: size,
          radius: 14,
          onPressed: value > min ? () => onChanged(value - 1) : null,
        ),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label?.call(value) ?? '$value',
              style: context.text.labelLarge,
            ),
          ),
        ),
        GreyIconButton(
          icon: Icons.add_rounded,
          tooltip: l10n.stampMore,
          size: size,
          radius: 14,
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}
