import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/app_settings.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/kept_switch.dart';
import 'settings_actions.dart';

/// The evening question (02-design.md §2.2): on or off, the time and the
/// weekdays it comes on. Every change is stored; HomeShell schedules the
/// notifications again from the stored settings.
class EveningSection extends ConsumerStatefulWidget {
  const EveningSection({super.key, required this.settings});

  final AppSettings settings;

  @override
  ConsumerState<EveningSection> createState() => EveningSectionState();
}

class EveningSectionState extends ConsumerState<EveningSection> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Back from the phone's settings: the permission may have changed.
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(notificationsEnabledProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _switch(bool on) async {
    await switchEveningQuestion(ref, on);
  }

  Future<void> _pickTime() async {
    final minute = widget.settings.eveningMinute;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minute ~/ 60, minute: minute % 60),
    );
    if (picked == null) return;
    await ref
        .read(servicesProvider)
        .settings
        .update(
          (s) => s.copyWith(eveningMinute: picked.hour * 60 + picked.minute),
        );
  }

  Future<void> _toggleDay(int day) =>
      ref.read(servicesProvider).settings.update((s) {
        final excluded = {...s.eveningExcludedDays};
        if (!excluded.remove(day)) excluded.add(day);
        return s.copyWith(eveningExcludedDays: excluded);
      });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = widget.settings;
    final on = settings.eveningOn;
    final enabled = ref.watch(notificationsEnabledProvider).value ?? true;
    final minute = settings.eveningMinute;
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: minute ~/ 60, minute: minute % 60),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.settingsEvening.toUpperCase(),
          style: context.text.labelMedium,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.settingsEveningSwitch),
          subtitle: Text(l10n.eveningQuestion),
          trailing: KeptSwitch(
            value: on,
            onChanged: (v) => unawaited(_switch(v)),
          ),
          onTap: () => unawaited(_switch(!on)),
        ),
        if (on) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsEveningTime),
            trailing: Text(time, style: context.text.labelLarge),
            onTap: () => unawaited(_pickTime()),
          ),
          const SizedBox(height: 4),
          Text(l10n.settingsEveningDays, style: context.text.bodyLarge),
          const SizedBox(height: 10),
          Weekdays(
            excluded: settings.eveningExcludedDays,
            onToggle: (day) => unawaited(_toggleDay(day)),
          ),
          if (!enabled) ...[
            const SizedBox(height: 16),
            Text(l10n.settingsNotificationsOff, style: context.text.bodyMedium),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: context.kept.text,
                ),
                onPressed: () =>
                    unawaited(ref.read(notificationsProvider).openSettings()),
                child: Text(l10n.settingsOpenNotificationSettings),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

/// Seven chips, one per weekday, in the order of the user's locale. A
/// chosen chip (sun fill) is a day the question comes on.
class Weekdays extends StatelessWidget {
  const Weekdays({super.key, required this.excluded, required this.onToggle});

  final Set<int> excluded;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final first = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    final format = DateFormat.E(Localizations.localeOf(context).toString());
    // 0 is Sunday here, 7 in DateTime.
    final days = [for (var i = 0; i < 7; i++) (first + i) % 7]
        .map((d) => d == 0 ? DateTime.sunday : d);
    return Row(
      spacing: 6,
      children: [
        for (final day in days)
          Expanded(
            child: DayChip(
              // 1 January 2024 was a Monday.
              label: format.format(DateTime(2024, 1, day)),
              selected: !excluded.contains(day),
              onTap: () => onToggle(day),
            ),
          ),
      ],
    );
  }
}

/// A chip as in ui-style.md §6 (ChoiceChips), sized to share one row.
class DayChip extends StatelessWidget {
  const DayChip({
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
            height: 44,
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: context.text.labelLarge?.copyWith(
                  fontSize: 14,
                  color: selected ? KeptColors.onAccent : kept.text,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
