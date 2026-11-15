import '../../app/theme.dart';
import '../common.dart';
import '../material.dart';

/// The switch of ui-style.md §6: a 52 × 32 pill, mint with a dark knob when
/// on, surface-high with a muted knob when off.
class KeptSwitch extends StatelessWidget {
  const KeptSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    return Switch(
      value: value,
      onChanged: onChanged,
      thumbColor: WidgetStatePropertyAll(
        value ? KeptColors.onAccent : kept.muted,
      ),
      trackColor: WidgetStatePropertyAll(
        value ? KeptColors.mint : kept.surfaceHigh,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      thumbIcon: const WidgetStatePropertyAll(null),
    );
  }
}
