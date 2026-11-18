import 'dart:async';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, LengthLimitingTextInputFormatter;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/contact_refresh.dart';
import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/display_name.dart';
import '../../domain/group.dart';
import '../../domain/rhythm.dart';
import '../../domain/person.dart';
import '../../domain/contact_route.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/labels.dart';
import '../../platform/installed_apps.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/avatar.dart';
import '../home/person_picker.dart';
import '../widgets/choice_chips.dart';
import '../widgets/grey_button.dart';
import '../widgets/kept_card.dart';
import '../widgets/kept_switch.dart';
import '../widgets/kept_text_field.dart';
import '../widgets/main_button.dart';
import '../widgets/rhythm_stepper.dart';
import '../widgets/section_label.dart';
import 'chat_link_help_page.dart';
import 'photo_crop_screen.dart';
import 'refresh_contacts_screen.dart';

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
  late final _nickname = TextEditingController(text: widget.person?.nickname);
  late final _phone = TextEditingController(text: widget.person?.phone);
  late final _target = TextEditingController(text: widget.person?.chatTarget);
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
  late ChatApp? _messenger = widget.person?.chatApp;
  late AvatarShape _shape = widget.person?.avatarShape ?? AvatarShape.values[0];
  late AvatarColor _color = widget.person?.avatarColor ?? AvatarColor.values[0];

  /// The picture's file name in the photo store. For a person who exists,
  /// a change is stored at once (and the old file deleted); for a new one
  /// it is written with the person on Save.
  late String? _photo = widget.person?.photo;

  /// The linked contact's picture, read once when the page opens; null when
  /// there is none (or no access): "From contact" is then not offered.
  Uint8List? _contactPhoto;

  bool _saving = false;

  bool get _editing => widget.person != null;

  @override
  void initState() {
    super.initState();
    _loadContactPhoto();
    _loadContactRoutes();
  }

  /// The apps the linked contact can reach the person in (its messengers'
  /// entries and chat links in its Website field). Read once per visit;
  /// nothing of it is stored (02-design.md §8, 2026-11-18).
  List<ContactRoute> _routes = const [];

  Future<void> _loadContactRoutes() async {
    final contactId = widget.person?.contactId;
    if (contactId == null) return;
    final entries = await ref.read(contactEntriesProvider).entriesOf(contactId);
    if (mounted) setState(() => _routes = contactRoutes(entries));
  }

  Future<void> _loadContactPhoto() async {
    final contactId = widget.person?.contactId;
    if (contactId == null) return;
    final bytes = await ref.read(contactsSourceProvider).photoFor(contactId);
    if (mounted && bytes != null && bytes.isNotEmpty) {
      setState(() => _contactPhoto = bytes);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _nickname,
      _phone,
      _target,
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

  /// What the avatar shows as its letter: the nickname, else the name.
  String get _shownName =>
      _nickname.text.trim().isNotEmpty ? _nickname.text.trim() : _name.text;

  /// Sets the picture to [name] (null removes it) and deletes the old file.
  Future<void> _setPhoto(String? name) async {
    final old = _photo;
    final person = widget.person;
    if (person != null) {
      await ref.read(peopleRepositoryProvider).setPhoto(person.id, name);
    }
    if (old != null && old != name) {
      await ref.read(photoStoreProvider).delete(old);
    }
    if (mounted) setState(() => _photo = name);
  }

  Future<void> _choosePicture() async {
    final bytes = await ref.read(photoStoreProvider).pickFromGallery();
    if (bytes == null || !mounted) return;
    final name = await cropAndSavePhoto(context, ref, bytes);
    if (name != null) await _setPhoto(name);
  }

  Future<void> _pictureFromContact() async {
    final bytes = _contactPhoto;
    if (bytes == null) return;
    final name = await cropAndSavePhoto(context, ref, bytes);
    if (name != null) await _setPhoto(name);
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
        chatApp: _messenger,
        phone: _orNull(_phone),
        chatTarget: _orNull(_target),
        birthdayMonth: birthday.month,
        birthdayDay: birthday.day,
        birthdayYear: birthday.year,
        notes: _notes.text.trim(),
        nickname: _orNull(_nickname),
        photo: _photo,
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
          chatApp: Value(_messenger),
          phone: Value(_orNull(_phone)),
          chatTarget: Value(_orNull(_target)),
          birthdayMonth: Value(birthday.month),
          birthdayDay: Value(birthday.day),
          birthdayYear: Value(birthday.year),
          avatarShape: _shape,
          avatarColor: _color,
          notes: _notes.text.trim(),
          nickname: Value(_orNull(_nickname)),
          photo: Value(_photo),
        ),
      );
    }
    navigator.pop();
  }

  /// Reads the linked contact; if the user confirms the differences, they
  /// are stored and the form's fields follow, so a later Save does not put
  /// the old values back.
  Future<void> _refreshFromContact() async {
    final person = widget.person!;
    final repo = ref.read(peopleRepositoryProvider);
    // The picture may have been changed in this form since it was opened.
    final diff = await showRefreshPerson(
      context,
      person.copyWith(photo: Value(_photo)),
    );
    if (diff == null) return;
    final saved = await applyContactDiff(
      ref.read(photoStoreProvider),
      repo,
      diff,
    );
    if (!mounted) return;
    setState(() {
      _photo = saved.photo;
      if (diff.name != null) _name.text = diff.name!;
      if (diff.phone != null) _phone.text = diff.phone!;
      if (diff.birthday case final b?) {
        _day.text = '${b.day}';
        _month.text = '${b.month}';
        _year.text = b.year?.toString() ?? '';
      }
    });
  }

  Future<void> _remove() async {
    final person = widget.person!;
    final navigator = Navigator.of(context);
    final repo = ref.read(peopleRepositoryProvider);
    final l10n = context.l10n;
    final inCouple =
        await ref.read(groupsRepositoryProvider).coupleOf(person.id) != null;
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeTitle(person.name)),
        content: Text(
          inCouple
              ? '${l10n.removeBody}\n\n${l10n.removeCoupleLine}'
              : l10n.removeBody,
        ),
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
    final photo = _photo ?? person.photo;
    if (photo != null) await ref.read(photoStoreProvider).delete(photo);
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
                    name: _shownName,
                    shape: _shape,
                    color: _color,
                    size: 96,
                    photo: _photo,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: GreyButton(
                        small: true,
                        label: l10n.choosePicture,
                        onPressed: _choosePicture,
                      ),
                    ),
                    if (_contactPhoto != null)
                      Expanded(
                        child: GreyButton(
                          small: true,
                          label: l10n.pictureFromContact,
                          onPressed: _pictureFromContact,
                        ),
                      ),
                    if (_photo != null)
                      Expanded(
                        child: GreyButton(
                          small: true,
                          label: l10n.removePicture,
                          onPressed: () => _setPhoto(null),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.pictureTip,
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium?.copyWith(fontSize: 13),
                ),
                if (widget.person?.contactId != null) ...[
                  const SizedBox(height: 14),
                  Center(
                    child: GreyButton(
                      small: true,
                      label: l10n.refreshPersonButton,
                      onPressed: _refreshFromContact,
                    ),
                  ),
                ],
                if (_editing) ...[
                  const SizedBox(height: 14),
                  _group(l10n.editLook, [
                    _ShapePicker(
                      name: _shownName,
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
                _group(l10n.editNickname, [
                  KeptTextField(
                    key: const ValueKey('nickname'),
                    controller: _nickname,
                    hint: l10n.nicknameHint,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => setState(() {}),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      l10n.nicknameHelper,
                      style: context.text.bodyMedium?.copyWith(fontSize: 13),
                    ),
                  ),
                ]),
                if (_editing) ...[
                  const SizedBox(height: 18),
                  _group(l10n.partnerLabel, [_PartnerRow(widget.person!)]),
                ],
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
                _messengerSection(context),
                const SizedBox(height: 18),
                _group(l10n.editReach, [
                  KeptTextField(
                    key: const ValueKey('phone'),
                    controller: _phone,
                    label: l10n.phoneNumber,
                    hint: l10n.phoneHint,
                    keyboardType: TextInputType.phone,
                    // The messenger line above may change with the number.
                    onChanged: (_) => setState(() {}),
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

  /// The messenger: the apps the contact offers first, then None and the
  /// other installed apps, then the optional chat target with a line that
  /// says what "Open" will do (02-design.md §8, 2026-11-18).
  Widget _messengerSection(BuildContext context) {
    final l10n = context.l10n;
    final installed =
        ref.watch(installedChatAppsProvider).value ?? InstalledChatApps.all;
    // SMS reaches anyone with a number; for a person linked to a contact
    // that number came from the contact, so SMS sits with its apps.
    final smsFromContact =
        widget.person?.contactId != null &&
        _orNull(_phone) != null &&
        installed.has(ChatApp.sms);
    final fromContact = <ChatApp>[
      for (final app in ChatApp.values)
        if (_routes.any((r) => r.app == app) ||
            (app == ChatApp.sms && smsFromContact))
          app,
    ];
    ChipOption<ChatApp?> option(ChatApp m) =>
        ChipOption(m, messengerLabel(m, l10n), icon: messengerIcon(m));
    final others = [
      for (final m in installed.choices(_messenger))
        if (!fromContact.contains(m)) m,
    ];
    void choose(ChatApp? v) => setState(() => _messenger = v);
    final app = _messenger;
    return _group(l10n.editMessenger, [
      if (fromContact.isNotEmpty) ...[
        Text(l10n.editMessengerFromContact, style: context.text.bodySmall),
        ChoiceChips<ChatApp?>(
          options: [for (final m in fromContact) option(m)],
          value: _messenger,
          onChanged: choose,
        ),
        Text(l10n.editMessengerOthers, style: context.text.bodySmall),
      ],
      ChoiceChips<ChatApp?>(
        options: [
          ChipOption(null, l10n.messengerNone),
          for (final m in others) option(m),
        ],
        value: _messenger,
        onChanged: choose,
      ),
      if (app != null) ...[
        KeptTextField(
          key: const ValueKey('chatTarget'),
          controller: _target,
          label: l10n.chatTarget,
          hint: l10n.chatTargetHint,
          keyboardType: TextInputType.url,
          onChanged: (_) => setState(() {}),
        ),
        Text(_targetLine(l10n, app), style: context.text.bodySmall),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: context.kept.text,
            ),
            onPressed: () => unawaited(
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ChatLinkHelpPage(current: app),
                ),
              ),
            ),
            child: Text(l10n.chatLinkHelpButton),
          ),
        ),
      ],
    ]);
  }

  /// What "Open" does with what is entered now, in the order of
  /// `openChat`: the target, the contact, the phone number, the app.
  String _targetLine(AppLocalizations l10n, ChatApp app) {
    final name = messengerLabel(app, l10n);
    final target = _target.text.trim();
    if (target.isNotEmpty) {
      return app.targetLink(target) != null
          ? l10n.chatTargetUsed(name)
          : l10n.chatTargetNotUnderstood(name);
    }
    if (_routes.any((r) => r.app == app)) return l10n.chatTargetViaContact;
    if (app.phoneLink(_orNull(_phone)) != null) {
      return l10n.chatTargetViaPhone;
    }
    return app.takesBareTarget
        ? l10n.chatTargetHelpUsername(name)
        : l10n.chatTargetHelpLink(name);
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

/// The "Partner" row of the edit page, the only way to link two people as
/// a couple (02-design.md §8, 2026-11-16). Empty: a short line and "Link a
/// partner", which opens the person picker with everyone who is not in a
/// couple yet. Linked: the partner's face and name and "Unlink", after a
/// confirm. Both act at once, not on Save.
class _PartnerRow extends ConsumerWidget {
  const _PartnerRow(this.person);

  final Person person;

  Future<void> _link(BuildContext context, WidgetRef ref) async {
    final inCouple = {
      for (final c
          in ref.read(couplesProvider).value ?? const <GroupWithMembers>[])
        for (final p in c.members) p.id,
    };
    final candidates = [
      for (final p in ref.read(peopleProvider).value ?? const <Person>[])
        if (p.id != person.id && !inCouple.contains(p.id)) p,
    ];
    final picked = await showPersonPicker(context, candidates);
    if (picked == null) return;
    try {
      await ref
          .read(groupsRepositoryProvider)
          .createCouple(person.id, picked.id);
    } on AlreadyInCoupleException {
      // Linked meanwhile: the row shows the current state.
    }
  }

  Future<void> _unlink(
    BuildContext context,
    WidgetRef ref,
    GroupWithMembers couple,
  ) async {
    final l10n = context.l10n;
    final names = ref.read(displayNamesProvider);
    final repo = ref.read(groupsRepositoryProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.partnerUnlinkTitle(
            shortNameIn(names, couple.members[0]),
            shortNameIn(names, couple.members[1]),
          ),
        ),
        // Dissolving gives the couple's open thoughts to both members.
        content: Text(l10n.partnerUnlinkBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.partnerUnlink),
          ),
        ],
      ),
    );
    if (confirmed == true) await repo.dissolve(couple.group.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final couple = ref.watch(personCoupleProvider(person.id)).value;
    final partner = couple?.members.where((p) => p.id != person.id).firstOrNull;
    return KeptCard(
      small: true,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: partner == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Text(l10n.partnerHelp, style: context.text.bodyMedium),
                GreyButton(
                  small: true,
                  label: l10n.partnerLink,
                  onPressed: () => _link(context, ref),
                ),
              ],
            )
          : Row(
              spacing: 12,
              children: [
                Avatar.person(partner, size: 44),
                Expanded(
                  child: Text(
                    ref.shortName(partner),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GreyButton(
                  small: true,
                  label: l10n.partnerUnlink,
                  onPressed: () => _unlink(context, ref, couple!),
                ),
              ],
            ),
    );
  }
}
