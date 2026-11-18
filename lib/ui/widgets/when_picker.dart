import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/intention.dart';
import '../../domain/timeline.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../material.dart';
import 'kept_text_field.dart';

/// Asks for a day with the date picker. The day lies between today and the
/// end of the 12 months the Upcoming tab shows; [initial] outside of that
/// (an old date being edited) is allowed to stay. Null if cancelled. The
/// result is local midnight, which means "no time".
Future<DateTime?> pickDay(
  BuildContext context,
  WidgetRef ref, {
  DateTime? initial,
}) {
  final now = ref.read(clockProvider)();
  final today = DateTime(now.year, now.month, now.day);
  final last = DateTime(
    today.year,
    today.month + upcomingMonths,
    today.day - 1,
  );
  var start = initial == null
      ? today
      : DateTime(initial.year, initial.month, initial.day);
  if (start.isBefore(today)) start = today;
  if (start.isAfter(last)) start = last;
  return showDatePicker(
    context: context,
    initialDate: start,
    firstDate: today,
    lastDate: last,
  );
}

/// "When" of a thought, as one compact row of chips: Date, Soon, Later,
/// When… (02-design.md §6.9). Nothing chosen is the default; tapping the
/// chosen chip again clears it. Date opens the date picker, then a Time
/// chip offers an optional time. When… shows a one-line field for the
/// condition. Chips are 36 high, so the row stays small on the capture card.
class WhenPicker extends ConsumerStatefulWidget {
  const WhenPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.fieldColor,
  });

  final When value;
  final ValueChanged<When> onChanged;

  /// The fill of the condition field; the ground colour on a card.
  final Color? fieldColor;

  @override
  ConsumerState<WhenPicker> createState() => _WhenPickerState();
}

class _WhenPickerState extends ConsumerState<WhenPicker> {
  late final _condition = TextEditingController(
    text: widget.value.condition ?? '',
  );

  @override
  void dispose() {
    _condition.dispose();
    super.dispose();
  }

  When get _v => widget.value;

  Future<void> _date() async {
    if (_v.date != null) return widget.onChanged(const When.none());
    final day = await pickDay(context, ref);
    if (day != null) widget.onChanged(When.date(day));
  }

  Future<void> _time() async {
    final date = _v.date;
    if (date == null) return;
    if (_v.hasTime) {
      return widget.onChanged(
        When.date(DateTime(date.year, date.month, date.day)),
      );
    }
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (time == null) return;
    widget.onChanged(
      When.date(
        DateTime(date.year, date.month, date.day, time.hour, time.minute),
      ),
    );
  }

  void _horizon(Horizon h) {
    if (_v.horizon == h) {
      _condition.clear();
      return widget.onChanged(const When.none());
    }
    widget.onChanged(
      h == Horizon.whenCondition
          ? When.horizon(h, condition: _condition.text)
          : When.horizon(h),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final date = _v.date;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SmallChip(
              label: date == null ? l10n.whenDate : l10n.dateShort(date),
              selected: date != null,
              onTap: _date,
            ),
            if (date != null)
              SmallChip(
                label: _v.hasTime ? l10n.timeShort(date) : l10n.whenAddTime,
                selected: _v.hasTime,
                onTap: _time,
              )
            else ...[
              for (final h in Horizon.values)
                SmallChip(
                  label: horizonLabel(h, l10n),
                  selected: _v.horizon == h,
                  onTap: () => _horizon(h),
                ),
            ],
          ],
        ),
        if (_v.horizon == Horizon.whenCondition)
          KeptTextField(
            controller: _condition,
            hint: l10n.whenConditionHint,
            fillColor: widget.fieldColor,
            onChanged: (text) => widget.onChanged(
              When.horizon(Horizon.whenCondition, condition: text),
            ),
          ),
      ],
    );
  }
}

/// A chip like [ChoiceChips] draws, but 36 high with 14 px text.
class SmallChip extends StatelessWidget {
  const SmallChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    final shape = BorderRadius.circular(14);
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
            height: 36,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  style: context.text.labelLarge?.copyWith(
                    fontSize: 14,
                    color: selected ? KeptColors.onAccent : kept.text,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
