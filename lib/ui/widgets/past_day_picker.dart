import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/providers.dart';
import '../common.dart';
import '../material.dart';
import 'choice_chips.dart';

enum PastDayChoice { today, yesterday, picked }

/// A day for a contact that already happened: today, yesterday or a day
/// picked in the calendar. [at] gives the time to store.
class PastDay {
  const PastDay.today() : choice = PastDayChoice.today, picked = null;

  const PastDay.yesterday() : choice = PastDayChoice.yesterday, picked = null;

  const PastDay.picked(DateTime this.picked) : choice = PastDayChoice.picked;

  final PastDayChoice choice;

  /// The calendar day, for [PastDayChoice.picked].
  final DateTime? picked;

  /// The time to store, given [now]. No time is asked for a past day: noon
  /// keeps it inside that day. Today, chosen or picked in the calendar,
  /// counts as now, never as a later noon.
  DateTime at(DateTime now) {
    final day = picked;
    return switch (choice) {
      PastDayChoice.today => now,
      PastDayChoice.picked when DateUtils.isSameDay(day, now) => now,
      PastDayChoice.yesterday => DateTime(now.year, now.month, now.day - 1, 12),
      PastDayChoice.picked => DateTime(day!.year, day.month, day.day, 12),
    };
  }
}

/// The chips Today, Yesterday and Pick a day. Pick a day opens the date
/// picker (a year back to today, starting on yesterday); the chip then
/// shows the date, with the year when it is not this year. Cancelling keeps
/// the previous choice.
class PastDayChips extends ConsumerWidget {
  const PastDayChips({super.key, required this.value, required this.onChanged});

  final PastDay value;
  final ValueChanged<PastDay> onChanged;

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final now = ref.read(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final day = await showDatePicker(
      context: context,
      initialDate: DateTime(today.year, today.month, today.day - 1),
      firstDate: DateTime(today.year - 1, today.month, today.day),
      lastDate: today,
    );
    if (day != null) onChanged(PastDay.picked(day));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final picked = value.picked;
    final locale = Localizations.localeOf(context).toString();
    final now = ref.read(clockProvider)();
    return ChoiceChips<PastDayChoice>(
      options: [
        ChipOption(PastDayChoice.today, l10n.timelineToday),
        ChipOption(PastDayChoice.yesterday, l10n.logDayYesterday),
        ChipOption(
          PastDayChoice.picked,
          picked == null
              ? l10n.logDayPick
              : (picked.year == now.year
                        ? DateFormat.MMMd(locale)
                        : DateFormat.yMMMd(locale))
                    .format(picked),
        ),
      ],
      value: value.choice,
      onChanged: (c) => switch (c) {
        PastDayChoice.today => onChanged(const PastDay.today()),
        PastDayChoice.yesterday => onChanged(const PastDay.yesterday()),
        PastDayChoice.picked => _pick(context, ref),
      },
    );
  }
}
