import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/database.dart';
import '../../domain/person.dart';
import '../../domain/phone_number.dart';
import '../../l10n/labels.dart';
import '../../platform/contacts.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../widgets/choice_chips.dart';
import '../widgets/grey_button.dart';
import '../widgets/kept_text_field.dart';
import '../widgets/main_button.dart';
import '../widgets/section_label.dart';

/// Opens the import of people from the phone's contacts.
Future<void> openImportContacts(BuildContext context) => Navigator.of(
  context,
).push(MaterialPageRoute<void>(builder: (_) => const ImportContactsScreen()));

/// Step 1 of the import: pick contacts. Step 2 is [_ClassStep]. The
/// permission is asked for when the screen opens.
class ImportContactsScreen extends ConsumerStatefulWidget {
  const ImportContactsScreen({super.key});

  @override
  ConsumerState<ImportContactsScreen> createState() => _PickState();
}

enum _Access { asking, denied, granted, failed }

class _PickState extends ConsumerState<ImportContactsScreen> {
  final _search = TextEditingController();
  final _picked = <String>{};
  var _access = _Access.asking;
  var _contacts = <PhoneContact>[];

  @override
  void initState() {
    super.initState();
    _open();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    final source = ref.read(contactsSourceProvider);
    try {
      if (!await source.requestAccess()) {
        if (mounted) setState(() => _access = _Access.denied);
        return;
      }
      final contacts = await source.load();
      if (!mounted) return;
      setState(() {
        _contacts = contacts;
        _access = _Access.granted;
      });
    } on Object {
      if (mounted) setState(() => _access = _Access.failed);
    }
  }

  void _toggle(String id) => setState(
    () => _picked.contains(id) ? _picked.remove(id) : _picked.add(id),
  );

  Future<void> _next() async {
    final chosen = [
      for (final c in _contacts)
        if (_picked.contains(c.id)) c,
    ];
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => _ClassStep(chosen)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final imported = {
      for (final p in ref.watch(peopleProvider).value ?? const <Person>[])
        if (p.contactId != null) p.contactId,
    };
    final query = _search.text.trim().toLowerCase();
    final shown = [
      for (final c in _contacts)
        if (!imported.contains(c.id) && c.name.toLowerCase().contains(query)) c,
    ];
    final Widget body = switch (_access) {
      _Access.asking => const SizedBox.shrink(),
      _Access.failed => _Message(l10n.importLoadError),
      _Access.denied => Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          spacing: 16,
          children: [
            _Message(l10n.importDenied),
            GreyButton(
              label: l10n.openSettings,
              onPressed: ref.read(contactsSourceProvider).openSettings,
            ),
          ],
        ),
      ),
      _Access.granted => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: KeptTextField(
              controller: _search,
              hint: l10n.importSearchHint,
              onChanged: (_) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(l10n.importPickHint, style: context.text.bodyMedium),
            ),
          ),
          Expanded(
            child: shown.isEmpty
                ? _Message(l10n.importNoContacts)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: shown.length,
                    itemBuilder: (context, i) => _ContactRow(
                      shown[i],
                      selected: _picked.contains(shown[i].id),
                      onTap: () => _toggle(shown[i].id),
                    ),
                  ),
          ),
        ],
      ),
    };
    return Scaffold(
      appBar: AppBar(title: Text(l10n.importPickTitle)),
      body: Column(
        children: [
          Expanded(child: body),
          if (_access == _Access.granted)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Opacity(
                  opacity: _picked.isEmpty ? .4 : 1,
                  child: MainButton(
                    label: l10n.importNext(_picked.length),
                    onPressed: _picked.isEmpty ? null : _next,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        text,
        style: context.text.bodyMedium,
        textAlign: TextAlign.center,
      ),
    ),
  );
}

class _ContactRow extends StatelessWidget {
  const _ContactRow(
    this.contact, {
    required this.selected,
    required this.onTap,
  });

  final PhoneContact contact;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              spacing: 14,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? KeptColors.sun : Colors.transparent,
                    border: selected
                        ? null
                        : Border.all(color: kept.line, width: 2),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 20,
                          color: KeptColors.onAccent,
                        )
                      : null,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (contact.phones.isNotEmpty)
                        Text(
                          contact.phones.first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodyMedium,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Step 2: a class for each chosen contact, one messenger for all.
class _ClassStep extends ConsumerStatefulWidget {
  const _ClassStep(this.contacts);

  final List<PhoneContact> contacts;

  @override
  ConsumerState<_ClassStep> createState() => _ClassState();
}

class _ClassState extends ConsumerState<_ClassStep> {
  late final _closeness = {
    for (final c in widget.contacts) c.id: Closeness.nowAndThen,
  };
  Messenger? _messenger = Messenger.whatsapp;
  var _saving = false;

  Future<void> _add() async {
    if (_saving) return;
    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    final repo = ref.read(peopleRepositoryProvider);
    // One after the other, so each person sees the avatars before.
    for (final c in widget.contacts) {
      await repo.add(
        name: c.name,
        contactId: c.id,
        closeness: _closeness[c.id]!,
        mainMessenger: _messenger,
        phone: c.phones.isEmpty ? null : normalisePhone(c.phones.first),
        birthdayMonth: c.birthdayMonth,
        birthdayDay: c.birthdayDay,
        birthdayYear: c.birthdayYear,
      );
    }
    navigator.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.importClassTitle)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                SectionLabel(l10n.importMessengerAll),
                const SizedBox(height: 8),
                ChoiceChips<Messenger?>(
                  options: [
                    ChipOption(null, l10n.messengerNone),
                    for (final m in Messenger.values)
                      ChipOption(m, messengerLabel(m, l10n)),
                  ],
                  value: _messenger,
                  onChanged: (v) => setState(() => _messenger = v),
                ),
                const SizedBox(height: 12),
                for (final c in widget.contacts)
                  _ClassRow(
                    c.name,
                    value: _closeness[c.id]!,
                    onChanged: (v) => setState(() => _closeness[c.id] = v),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: MainButton(
                label: l10n.importAdd(widget.contacts.length),
                onPressed: _saving ? null : _add,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A name and the four class icons as a single choice.
class _ClassRow extends StatelessWidget {
  const _ClassRow(this.name, {required this.value, required this.onChanged});

  final String name;
  final Closeness value;
  final ValueChanged<Closeness> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      spacing: 8,
      children: [
        Expanded(
          child: Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        for (final c in Closeness.values)
          Tooltip(
            message: closenessLabel(c, context.l10n),
            child: Semantics(
              selected: c == value,
              button: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => onChanged(c),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: c == value ? KeptColors.sun : Colors.transparent,
                  ),
                  child: KeptIcon(closenessIcon(c), size: 26),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
