import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, LengthLimitingTextInputFormatter;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/app_settings.dart';
import '../../domain/birthdays.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../home/congratulated_screen.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../widgets/kept_switch.dart';
import '../widgets/kept_text_field.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.settings;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.settingsTheme.toUpperCase(),
            style: context.text.labelMedium,
          ),
          const SizedBox(height: 12),
          SegmentedButton<AppThemeMode>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: AppThemeMode.system,
                label: Text(l10n.themeSystem),
              ),
              ButtonSegment(
                value: AppThemeMode.light,
                label: Text(l10n.themeLight),
              ),
              ButtonSegment(
                value: AppThemeMode.dark,
                label: Text(l10n.themeDark),
              ),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (chosen) => unawaited(
              ref.services.settings.update(
                (s) => s.copyWith(themeMode: chosen.single),
              ),
            ),
          ),
          const SizedBox(height: 32),
          _OpenItems(mode: settings.openItems),
          const SizedBox(height: 32),
          _EveningQuestion(settings: settings),
          const SizedBox(height: 32),
          _OwnBirthday(birthday: settings.ownBirthday),
          if (kDebugMode) _Development(demoMode: settings.demoMode),
        ],
      ),
    );
  }
}

/// How many open items Home shows for tonight (02-design.md §2.3): one
/// with "Another one", or a list of three.
class _OpenItems extends ConsumerWidget {
  const _OpenItems({required this.mode});

  final OpenItemsMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.settingsOpenItems.toUpperCase(),
          style: context.text.labelMedium,
        ),
        const SizedBox(height: 4),
        Text(l10n.settingsOpenItemsHelp, style: context.text.bodyMedium),
        const SizedBox(height: 12),
        SegmentedButton<OpenItemsMode>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: OpenItemsMode.one,
              label: Text(l10n.openItemsOne),
            ),
            ButtonSegment(
              value: OpenItemsMode.three,
              label: Text(l10n.openItemsThree),
            ),
          ],
          selected: {mode},
          onSelectionChanged: (chosen) => unawaited(
            ref.services.settings.update(
              (s) => s.copyWith(openItems: chosen.single),
            ),
          ),
        ),
      ],
    );
  }
}

/// The evening question (02-design.md §2.2): on or off, the time and the
/// weekdays it comes on. Every change is stored; HomeShell schedules the
/// notifications again from the stored settings.
class _EveningQuestion extends ConsumerStatefulWidget {
  const _EveningQuestion({required this.settings});

  final AppSettings settings;

  @override
  ConsumerState<_EveningQuestion> createState() => _EveningQuestionState();
}

class _EveningQuestionState extends ConsumerState<_EveningQuestion> {
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
    final services = ref.read(servicesProvider);
    final notifications = ref.read(notificationsProvider);
    await services.settings.update(
      (s) => s.copyWith(
        eveningOn: on,
        notificationPermissionAsked: on ? true : null,
      ),
    );
    if (!on) return;
    // Switching on asks again; Android itself stops showing the dialog
    // after the user has said no twice.
    await notifications.requestPermission();
    if (mounted) ref.invalidate(notificationsEnabledProvider);
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
          _Weekdays(
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
class _Weekdays extends StatelessWidget {
  const _Weekdays({required this.excluded, required this.onToggle});

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
            child: _DayChip(
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
class _DayChip extends StatelessWidget {
  const _DayChip({
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

/// The user's own birthday (02-design.md §8, birthdays M4): the row shows
/// and edits it; once set, a second row opens "Who congratulated you?" for
/// the most recent birthday.
class _OwnBirthday extends ConsumerWidget {
  const _OwnBirthday({required this.birthday});

  final Birthday? birthday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final b = birthday;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.birthday.toUpperCase(), style: context.text.labelMedium),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.settingsOwnBirthday),
          trailing: Text(
            b == null
                ? l10n.settingsOwnBirthdayNotSet
                : birthdayLabel(b.month, b.day, b.year, l10n),
            style: context.text.labelLarge,
          ),
          onTap: () => unawaited(_edit(context, ref)),
        ),
        if (b != null)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const KeptIcon(KeptIcons.cake, size: 28),
            title: Text(l10n.congratulatedTitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => openCongratulated(context, b),
          ),
      ],
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(servicesProvider).settings;
    final result = await showDialog<_BirthdayResult>(
      context: context,
      builder: (_) => _BirthdayDialog(initial: birthday),
    );
    if (result == null) return;
    await settings.update((s) => s.withOwnBirthday(result.birthday));
  }
}

/// What the dialog returns: a birthday, or null to clear it.
class _BirthdayResult {
  const _BirthdayResult(this.birthday);

  final Birthday? birthday;
}

/// Day, month and an optional year, with the rules of the person form.
/// Empty fields and Save, or Remove, clear the birthday.
class _BirthdayDialog extends StatefulWidget {
  const _BirthdayDialog({required this.initial});

  final Birthday? initial;

  @override
  State<_BirthdayDialog> createState() => _BirthdayDialogState();
}

class _BirthdayDialogState extends State<_BirthdayDialog> {
  late final _day = TextEditingController(text: widget.initial?.day.toString());
  late final _month = TextEditingController(
    text: widget.initial?.month.toString(),
  );
  late final _year = TextEditingController(
    text: widget.initial?.year?.toString(),
  );

  @override
  void dispose() {
    _day.dispose();
    _month.dispose();
    _year.dispose();
    super.dispose();
  }

  BirthdayFields get _fields =>
      BirthdayFields.check(_day.text, _month.text, _year.text, DateTime.now());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fields = _fields;
    return AlertDialog(
      title: Text(l10n.settingsOwnBirthday),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Row(
            spacing: 10,
            children: [
              for (final (key, c, label, flex, length) in [
                ('ownDay', _day, l10n.birthdayDay, 2, 2),
                ('ownMonth', _month, l10n.birthdayMonthField, 2, 2),
                ('ownYear', _year, l10n.birthdayYearOptional, 3, 4),
              ])
                Expanded(
                  flex: flex,
                  child: KeptTextField(
                    key: ValueKey(key),
                    controller: c,
                    label: label,
                    hasError: !fields.ok,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(length),
                    ],
                    onChanged: (_) => setState(() {}),
                  ),
                ),
            ],
          ),
          if (!fields.ok)
            Text(
              l10n.birthdayError,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.error,
              ),
            ),
        ],
      ),
      actions: [
        if (widget.initial != null)
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(const _BirthdayResult(null)),
            child: Text(l10n.remove),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: fields.ok
              ? () =>
                    Navigator.of(context).pop(_BirthdayResult(fields.birthday))
              : null,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

/// Development builds only (02-design.md §8, demo data). These texts are
/// hard-coded English on purpose: the user never sees them, so they are
/// not ARB keys.
class _Development extends ConsumerWidget {
  const _Development({required this.demoMode});

  final bool demoMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        Text('DEVELOPMENT', style: context.text.labelMedium),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Demo data'),
          subtitle: const Text(
            'Shows invented people. Your own data is not touched.',
          ),
          value: demoMode,
          onChanged: (on) => unawaited(ref.services.setDemoMode(on)),
        ),
      ],
    );
  }
}
