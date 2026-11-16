import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, LengthLimitingTextInputFormatter;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/rhythm.dart';
import '../../domain/person.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/avatar.dart';
import '../widgets/choice_chips.dart';
import '../widgets/kept_card.dart';
import '../widgets/kept_switch.dart';
import '../widgets/kept_text_field.dart';
import '../widgets/main_button.dart';
import '../widgets/rhythm_stepper.dart';
import '../widgets/section_label.dart';

/// Opens the form for a new person.
Future<void> openEditPerson(BuildContext context) => Navigator.of(context)
    .push(MaterialPageRoute<void>(builder: (_) => const EditPersonScreen()));

/// The form to add a person (`id` null) or to change one. See 02-design.md
/// §3 for the fields. Shape and colour of the avatar are picked by the
/// repository for a new person; they can be changed when editing.
class EditPersonScreen extends ConsumerWidget {
  const EditPersonScreen({super.key, this.id});

  final String? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = this.id;
    if (id == null) return const _Form(null);
    // The form takes the person once; later changes of the row do not
    // overwrite what the user is typing.
    final person = ref.watch(personProvider(id));
    return switch (person) {
      AsyncValue(value: final p?) => _Form(p),
      _ => Scaffold(appBar: AppBar(title: Text(context.l10n.editPersonTitle))),
    };
  }
}

/// A birthday that was typed in, or why it cannot be used.
class _Birthday {
  const _Birthday.none() : month = null, day = null, year = null, ok = true;
  const _Birthday.bad() : month = null, day = null, year = null, ok = false;
  const _Birthday(this.month, this.day, this.year) : ok = true;

  final int? month, day, year;
  final bool ok;

  /// Empty fields are no birthday. Day and month must both be there and form
  /// a real date; 29 February is fine without a year, and with a year only
  /// in a leap year. A year is optional but must be 1900 or later and not in
  /// the future.
  factory _Birthday.parse(String day, String month, String year, DateTime now) {
    final d = int.tryParse(day.trim()), m = int.tryParse(month.trim());
    final y = int.tryParse(year.trim());
    if (day.trim().isEmpty && month.trim().isEmpty && year.trim().isEmpty) {
      return const _Birthday.none();
    }
    if (d == null || m == null) return const _Birthday.bad();
    if (year.trim().isNotEmpty && (y == null || y < 1900 || y > now.year)) {
      return const _Birthday.bad();
    }
    // 2000 is a leap year, so 29 February works when the year is unknown.
    final check = DateTime(y ?? 2000, m, d);
    if (check.month != m || check.day != d) return const _Birthday.bad();
    return _Birthday(m, d, y);
  }
}

class _Form extends ConsumerStatefulWidget {
  const _Form(this.person);

  final Person? person;

  @override
  ConsumerState<_Form> createState() => _FormState();
}

class _FormState extends ConsumerState<_Form> {
  late final _name = TextEditingController(text: widget.person?.name);
  late final _phone = TextEditingController(text: widget.person?.phone);
  late final _telegram = TextEditingController(
    text: widget.person?.telegramUsername,
  );
  late final _signal = TextEditingController(text: widget.person?.signalLink);
  late final _discord = TextEditingController(
    text: widget.person?.discordUserId,
  );
  late final _day = TextEditingController(
    text: widget.person?.birthdayDay?.toString(),
  );
  late final _month = TextEditingController(
    text: widget.person?.birthdayMonth?.toString(),
  );
  late final _year = TextEditingController(
    text: widget.person?.birthdayYear?.toString(),
  );
  late final _notes = TextEditingController(text: widget.person?.notes);

  late Closeness _closeness = widget.person?.closeness ?? Closeness.nowAndThen;
  late bool _reconnecting = widget.person?.reconnecting ?? false;

  /// The person's own rhythm in days; null is "like the class".
  late int? _rhythm = widget.person?.rhythmDays;
  late Messenger? _messenger = widget.person?.mainMessenger;
  late AvatarShape _shape = widget.person?.avatarShape ?? AvatarShape.values[0];
  late AvatarColor _color = widget.person?.avatarColor ?? AvatarColor.values[0];

  bool _saving = false;

  bool get _editing => widget.person != null;

  @override
  void dispose() {
    for (final c in [
      _name,
      _phone,
      _telegram,
      _signal,
      _discord,
      _day,
      _month,
      _year,
      _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  _Birthday get _birthday =>
      _Birthday.parse(_day.text, _month.text, _year.text, DateTime.now());

  bool get _canSave => !_saving && _name.text.trim().isNotEmpty && _birthday.ok;

  /// Empty text is stored as null.
  static String? _orNull(TextEditingController c) {
    final text = c.text.trim();
    return text.isEmpty ? null : text;
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    final repo = ref.read(peopleRepositoryProvider);
    final birthday = _birthday;
    final person = widget.person;
    if (person == null) {
      await repo.add(
        name: _name.text.trim(),
        closeness: _closeness,
        reconnecting: _reconnecting,
        rhythmDays: _rhythm,
        mainMessenger: _messenger,
        phone: _orNull(_phone),
        telegramUsername: _orNull(_telegram),
        signalLink: _orNull(_signal),
        discordUserId: _orNull(_discord),
        birthdayMonth: birthday.month,
        birthdayDay: birthday.day,
        birthdayYear: birthday.year,
        notes: _notes.text.trim(),
      );
    } else {
      if (_reconnecting && !person.reconnecting) {
        // A new time of getting back in touch: ask "back in touch?" again.
        await ref
            .read(servicesProvider)
            .settings
            .update(
              (s) => s.copyWith(
                backInTouchAnswered: {...s.backInTouchAnswered}
                  ..remove(person.id),
              ),
            );
      }
      await repo.update(
        person.copyWith(
          name: _name.text.trim(),
          closeness: _closeness,
          reconnecting: _reconnecting,
          rhythmDays: Value(_rhythm),
          mainMessenger: Value(_messenger),
          phone: Value(_orNull(_phone)),
          telegramUsername: Value(_orNull(_telegram)),
          signalLink: Value(_orNull(_signal)),
          discordUserId: Value(_orNull(_discord)),
          birthdayMonth: Value(birthday.month),
          birthdayDay: Value(birthday.day),
          birthdayYear: Value(birthday.year),
          avatarShape: _shape,
          avatarColor: _color,
          notes: _notes.text.trim(),
        ),
      );
    }
    navigator.pop();
  }

  Future<void> _remove() async {
    final person = widget.person!;
    final navigator = Navigator.of(context);
    final repo = ref.read(peopleRepositoryProvider);
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeTitle(person.name)),
        content: Text(l10n.removeBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.remove),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await repo.delete(person.id);
    // Back to the tab, past the person page that is now empty.
    navigator.popUntil((route) => route.isFirst);
  }

  /// The rhythm of the chosen class, as text ("2 weeks" or "none").
  String _classRhythmLabel(BuildContext context) {
    final rhythms =
        ref.watch(settingsProvider).value?.classRhythms ?? defaultClassRhythms;
    final days = rhythms[_closeness];
    return days == null
        ? context.l10n.rhythmNone.toLowerCase()
        : rhythmLabel(days, context.l10n);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final birthdayBad = !_birthday.ok;
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? l10n.editPersonTitle : l10n.addPersonTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                Center(
                  child: Avatar(
                    name: _name.text,
                    shape: _shape,
                    color: _color,
                    size: 84,
                  ),
                ),
                if (_editing) ...[
                  const SizedBox(height: 14),
                  _group(l10n.editLook, [
                    _ShapePicker(
                      name: _name.text,
                      color: _color,
                      value: _shape,
                      onChanged: (v) => setState(() => _shape = v),
                    ),
                    _ColorPicker(
                      value: _color,
                      onChanged: (v) => setState(() => _color = v),
                    ),
                  ]),
                ],
                const SizedBox(height: 14),
                _group(l10n.editName, [
                  KeptTextField(
                    key: const ValueKey('name'),
                    controller: _name,
                    hint: l10n.nameHint,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => setState(() {}),
                  ),
                ]),
                const SizedBox(height: 18),
                _group(l10n.editClass, [
                  ChoiceChips<Closeness>(
                    options: [
                      for (final c in Closeness.values)
                        ChipOption(
                          c,
                          closenessGroupLabel(c, l10n),
                          icon: closenessIcon(c),
                        ),
                    ],
                    value: _closeness,
                    onChanged: (v) => setState(() => _closeness = v),
                  ),
                ]),
                const SizedBox(height: 18),
                _group(l10n.editRhythm, [
                  Text(l10n.editRhythmHelp, style: context.text.bodyMedium),
                  RhythmStepper(
                    options: rhythmOptions(current: _rhythm, nullFirst: true),
                    value: _rhythm,
                    label: (days) => days == null
                        ? '${l10n.rhythmLikeClass} · ${_classRhythmLabel(context)}'
                        : rhythmLabel(days, l10n),
                    onChanged: (v) => setState(() => _rhythm = v),
                  ),
                ]),
                const SizedBox(height: 18),
                _ReconnectingSwitch(
                  value: _reconnecting,
                  onChanged: (v) => setState(() => _reconnecting = v),
                ),
                const SizedBox(height: 18),
                _group(l10n.editMessenger, [
                  ChoiceChips<Messenger?>(
                    options: [
                      ChipOption(null, l10n.messengerNone),
                      for (final m in Messenger.values)
                        ChipOption(m, messengerLabel(m, l10n)),
                    ],
                    value: _messenger,
                    onChanged: (v) => setState(() => _messenger = v),
                  ),
                ]),
                const SizedBox(height: 18),
                _group(l10n.editReach, [
                  KeptTextField(
                    key: const ValueKey('phone'),
                    controller: _phone,
                    label: l10n.phoneNumber,
                    hint: l10n.phoneHint,
                    keyboardType: TextInputType.phone,
                  ),
                  KeptTextField(
                    key: const ValueKey('telegram'),
                    controller: _telegram,
                    label: l10n.telegramUsername,
                  ),
                  KeptTextField(
                    key: const ValueKey('signal'),
                    controller: _signal,
                    label: l10n.signalLink,
                    keyboardType: TextInputType.url,
                  ),
                  KeptTextField(
                    key: const ValueKey('discord'),
                    controller: _discord,
                    label: l10n.discordUserId,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ]),
                const SizedBox(height: 18),
                _group(l10n.birthday, [
                  Row(
                    spacing: 10,
                    children: [
                      for (final (key, c, label, flex) in [
                        ('day', _day, l10n.birthdayDay, 2),
                        ('month', _month, l10n.birthdayMonthField, 2),
                        ('year', _year, l10n.birthdayYearOptional, 3),
                      ])
                        Expanded(
                          flex: flex,
                          child: KeptTextField(
                            key: ValueKey(key),
                            controller: c,
                            label: label,
                            hasError: birthdayBad,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(
                                key == 'year' ? 4 : 2,
                              ),
                            ],
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                    ],
                  ),
                  if (birthdayBad)
                    Text(
                      l10n.birthdayError,
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.error,
                      ),
                    ),
                ]),
                const SizedBox(height: 18),
                _group(l10n.notes, [
                  KeptTextField(
                    key: const ValueKey('notes'),
                    controller: _notes,
                    hint: l10n.notesHint,
                    maxLines: 6,
                    minLines: 3,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ]),
                if (_editing) ...[
                  const SizedBox(height: 18),
                  Center(
                    child: TextButton(
                      onPressed: _remove,
                      style: TextButton.styleFrom(
                        foregroundColor: context.kept.muted,
                        minimumSize: const Size(44, 44),
                      ),
                      child: Text(l10n.removePerson),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Opacity(
                opacity: _canSave ? 1 : .4,
                child: MainButton(
                  label: l10n.save,
                  onPressed: _canSave ? _save : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _group(String label, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 8,
    children: [SectionLabel(label), ...children],
  );
}

/// A small tappable thing with a ring in the text colour when chosen.
class _Pick extends StatelessWidget {
  const _Pick({
    required this.selected,
    required this.onTap,
    required this.label,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    selected: selected,
    button: true,
    child: InkResponse(
      onTap: onTap,
      radius: 28,
      child: Container(
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? context.kept.text : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: child,
      ),
    ),
  );
}

class _ShapePicker extends StatelessWidget {
  const _ShapePicker({
    required this.name,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  final String name;
  final AvatarColor color;
  final AvatarShape value;
  final ValueChanged<AvatarShape> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final s in AvatarShape.values)
        _Pick(
          selected: s == value,
          label: s.name,
          onTap: () => onChanged(s),
          child: Avatar(name: name, shape: s, color: color, size: 36),
        ),
    ],
  );
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.value, required this.onChanged});

  final AvatarColor value;
  final ValueChanged<AvatarColor> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final c in AvatarColor.values)
        _Pick(
          selected: c == value,
          label: c.name,
          onTap: () => onChanged(c),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
          ),
        ),
    ],
  );
}

/// The "getting back in touch" switch, in a lilac card so it reads as a
/// state of its own, apart from the class (02-design.md §6.9).
class _ReconnectingSwitch extends StatelessWidget {
  const _ReconnectingSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final tone = context.kept.lilacTone;
    final l10n = context.l10n;
    return KeptCard(
      tone: tone,
      small: true,
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  l10n.reconnecting,
                  style: context.text.labelLarge?.copyWith(
                    color: tone.onContainer,
                  ),
                ),
                Text(
                  l10n.reconnectingHint,
                  style: context.text.bodyMedium?.copyWith(
                    color: tone.onContainer,
                  ),
                ),
              ],
            ),
          ),
          KeptSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
