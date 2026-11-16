import 'dart:async';

import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, LengthLimitingTextInputFormatter;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/birthdays.dart';
import '../../l10n/labels.dart' show birthdayLabel;
import '../common.dart';
import '../home/congratulated_screen.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../widgets/kept_text_field.dart';

/// The user's own birthday (02-design.md §8): the row shows
/// and edits it; once set, a second row opens "Who congratulated you?" for
/// the most recent birthday.
class OwnBirthdayRow extends ConsumerWidget {
  const OwnBirthdayRow({super.key, required this.birthday});

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
    final result = await showDialog<BirthdayResult>(
      context: context,
      builder: (_) => BirthdayDialog(initial: birthday),
    );
    if (result == null) return;
    await settings.update((s) => s.withOwnBirthday(result.birthday));
  }
}

/// What the dialog returns: a birthday, or null to clear it.
class BirthdayResult {
  const BirthdayResult(this.birthday);

  final Birthday? birthday;
}

/// Day, month and an optional year, with the rules of the person form.
/// Empty fields and Save, or Remove, clear the birthday.
class BirthdayDialog extends StatefulWidget {
  const BirthdayDialog({super.key, required this.initial});

  final Birthday? initial;

  @override
  State<BirthdayDialog> createState() => BirthdayDialogState();
}

class BirthdayDialogState extends State<BirthdayDialog> {
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
                Navigator.of(context).pop(const BirthdayResult(null)),
            child: Text(l10n.remove),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: fields.ok
              ? () => Navigator.of(context).pop(BirthdayResult(fields.birthday))
              : null,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
