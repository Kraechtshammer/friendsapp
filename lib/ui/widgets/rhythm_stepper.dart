import '../../domain/rhythm.dart';
import '../common.dart';
import '../material.dart';
import 'grey_icon_button.dart';

/// The choices of a rhythm stepper, shortest first: [rhythmSpans], plus
/// [current] when it is none of them (so an odd stored value still shows
/// and can be stepped away from). Null stands for the "no value" choice:
/// "none" for a class (it comes last, as the longest) or "like the class"
/// for a person ([nullFirst], it comes first).
List<int?> rhythmOptions({int? current, bool nullFirst = false}) {
  final days = {...rhythmSpans, ?current}.toList()..sort();
  return nullFirst ? [null, ...days] : [...days, null];
}

/// A minus button, the chosen value and a plus button, in the look of the
/// reply-wait stepper in the settings (ui-style.md §6: grey square
/// buttons). [label] turns a choice into text; stepping stops at the ends.
class RhythmStepper extends StatelessWidget {
  const RhythmStepper({
    super.key,
    required this.options,
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final List<int?> options;
  final int? value;
  final String Function(int? value) label;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final index = options.indexOf(value);
    return Row(
      spacing: 8,
      children: [
        GreyIconButton(
          icon: Icons.remove_rounded,
          tooltip: l10n.shorter,
          size: 44,
          radius: 14,
          onPressed: index > 0 ? () => onChanged(options[index - 1]) : null,
        ),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label(value), style: context.text.labelLarge),
          ),
        ),
        GreyIconButton(
          icon: Icons.add_rounded,
          tooltip: l10n.longer,
          size: 44,
          radius: 14,
          onPressed: index >= 0 && index < options.length - 1
              ? () => onChanged(options[index + 1])
              : null,
        ),
      ],
    );
  }
}
