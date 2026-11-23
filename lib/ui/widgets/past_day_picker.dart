import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../common.dart';
import '../material.dart';
import '../../app/theme.dart';
import '../kept_icon.dart';

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

  /// The calendar day, given [now], without a time.
  DateTime dayOn(DateTime now) {
    final day = picked;
    return switch (choice) {
      PastDayChoice.today => DateTime(now.year, now.month, now.day),
      PastDayChoice.yesterday => DateTime(now.year, now.month, now.day - 1),
      PastDayChoice.picked => DateTime(day!.year, day.month, day.day),
    };
  }

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

/// Five equal badges, no scrolling (concept log-sheet-v3): today, yesterday,
/// the two days before, and a calendar badge that opens the date picker (a
/// year back to today, starting on yesterday). A day picked there that is
/// not one of the four shows on the calendar badge, with its weekday and
/// number. Cancelling keeps the previous choice.
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
    final now = ref.read(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    DateTime ago(int n) => DateTime(today.year, today.month, today.day - n);
    final chosen = value.dayOn(now);
    final shown = [for (var n = 0; n < 4; n++) ago(n)];
    final extra = shown.contains(chosen) ? null : chosen;
    String weekday(DateTime d) =>
        l10n.dateWeekday(d).replaceAll('.', '').toUpperCase();
    Widget day(int n, String top, String semantic) => _Badge(
      top: top,
      big: l10n.dateDayNumber(shown[n]),
      semantic: semantic,
      selected: chosen == shown[n],
      onTap: () => onChanged(switch (n) {
        0 => const PastDay.today(),
        1 => const PastDay.yesterday(),
        _ => PastDay.picked(shown[n]),
      }),
    );
    return Row(
      spacing: 8,
      children: [
        day(0, l10n.timelineToday.toUpperCase(), l10n.timelineToday),
        day(1, l10n.logDayYesterdayShort.toUpperCase(), l10n.logDayYesterday),
        day(2, weekday(shown[2]), l10n.dateShort(shown[2])),
        day(3, weekday(shown[3]), l10n.dateShort(shown[3])),
        extra == null
            ? _Badge(
                top: l10n.logDayPickShort.toUpperCase(),
                icon: KeptIcons.calendar,
                semantic: l10n.logDayPick,
                selected: false,
                onTap: () => _pick(context, ref),
              )
            : _Badge(
                top: weekday(extra),
                big: l10n.dateDayNumber(extra),
                semantic: l10n.dateShort(extra),
                selected: true,
                onTap: () => _pick(context, ref),
              ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.top,
    required this.semantic,
    required this.selected,
    required this.onTap,
    this.big,
    this.icon,
  });

  final String top;
  final String? big;
  final KeptIcons? icon;
  final String semantic;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    const radius = BorderRadius.all(Radius.circular(16));
    final ink = selected ? KeptColors.onAccent : kept.text;
    final small = context.text.labelMedium?.copyWith(
      fontSize: 11,
      letterSpacing: .3,
      color: selected ? KeptColors.onAccent : kept.muted,
    );
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: semantic,
        child: ExcludeSemantics(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: selected ? KeptColors.sunEdge : kept.greyEdge,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: selected ? KeptColors.sun : kept.surfaceHigh,
              borderRadius: radius,
              child: InkWell(
                borderRadius: radius,
                onTap: onTap,
                child: SizedBox(
                  height: 58,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) KeptIcon(icon!, size: 26),
                        // A long word such as "Gestern" shrinks to fit.
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(top, maxLines: 1, style: small),
                        ),
                        if (big != null)
                          Text(
                            big!,
                            style: outfit(22, FontWeight.w700, color: ink),
                          ),
                      ],
                    ),
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
