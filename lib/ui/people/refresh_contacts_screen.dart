import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/contact_refresh.dart';
import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/contact_refresh.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/avatar.dart';
import '../widgets/grey_button.dart';
import '../widgets/kept_card.dart';
import '../widgets/main_button.dart';

/// Opens "Refresh from contacts" for everyone.
Future<void> openRefreshContacts(BuildContext context) => Navigator.of(
  context,
).push(MaterialPageRoute<void>(builder: (_) => const RefreshContactsScreen()));

/// Checks every person linked to a contact and lists those whose name,
/// number, birthday or picture differ. Each can be accepted or skipped; "Accept all"
/// takes the rest. Nothing changes without a tap (02-design.md §8).
class RefreshContactsScreen extends ConsumerStatefulWidget {
  const RefreshContactsScreen({super.key});

  @override
  ConsumerState<RefreshContactsScreen> createState() => _RefreshState();
}

class _RefreshState extends ConsumerState<RefreshContactsScreen> {
  RefreshResult? _result;
  var _diffs = <ContactDiff>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final people = await ref.read(peopleRepositoryProvider).watchAll().first;
    final result = await refreshPeople(
      ref.read(contactsSourceProvider),
      people,
    );
    if (!mounted) return;
    setState(() {
      _result = result;
      _diffs = [...result.diffs];
    });
  }

  Future<void> _accept(ContactDiff diff) async {
    await applyContactDiff(
      ref.read(photoStoreProvider),
      ref.read(peopleRepositoryProvider),
      diff,
    );
    if (!mounted) return;
    setState(() {
      _diffs.remove(diff);
    });
  }

  void _skip(ContactDiff diff) => setState(() => _diffs.remove(diff));

  Future<void> _acceptAll() async {
    for (final diff in [..._diffs]) {
      await _accept(diff);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final result = _result;
    final Widget body;
    if (result == null) {
      body = const SizedBox.shrink();
    } else if (result.status != RefreshStatus.ok) {
      body = _Message(
        result.status == RefreshStatus.denied
            ? l10n.importDenied
            : l10n.importLoadError,
        button: result.status == RefreshStatus.denied
            ? GreyButton(
                label: l10n.openSettings,
                onPressed: ref.read(contactsSourceProvider).openSettings,
              )
            : null,
      );
    } else if (_diffs.isEmpty) {
      body = _Message(
        result.diffs.isEmpty ? l10n.refreshAllNothing : l10n.refreshAllDone,
      );
    } else {
      body = ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          Text(l10n.refreshAllIntro, style: context.text.bodyMedium),
          const SizedBox(height: 14),
          for (final diff in _diffs) ...[
            DiffCard(
              diff,
              onAccept: () => _accept(diff),
              onSkip: () => _skip(diff),
            ),
            const SizedBox(height: 14),
          ],
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.refreshTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: body),
          if (_diffs.length > 1)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: MainButton(
                  label: l10n.refreshAcceptAll,
                  onPressed: _acceptAll,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text, {this.button});

  final String text;
  final Widget? button;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          Text(
            text,
            style: context.text.bodyMedium,
            textAlign: TextAlign.center,
          ),
          ?button,
        ],
      ),
    ),
  );
}

/// One person with their differences, old and new side by side, and the
/// two choices. With [onAccept] and [onSkip] only; labels are the same
/// in the sheet for one person.
class DiffCard extends StatelessWidget {
  const DiffCard(
    this.diff, {
    super.key,
    required this.onAccept,
    required this.onSkip,
    this.acceptLabel,
    this.skipLabel,
  });

  final ContactDiff diff;
  final VoidCallback onAccept;
  final VoidCallback onSkip;
  final String? acceptLabel;
  final String? skipLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = diff.person;
    String none() => l10n.refreshNone;
    String birthday(int? m, int? d, int? y) =>
        m == null || d == null ? none() : birthdayLabel(m, d, y, l10n);
    return KeptCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            spacing: 12,
            children: [
              Avatar.person(p, size: 44),
              Expanded(
                child: Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleLarge,
                ),
              ),
            ],
          ),
          Row(
            spacing: 12,
            children: [
              Expanded(child: _Head(l10n.refreshOld)),
              Expanded(child: _Head(l10n.refreshNew)),
            ],
          ),
          if (diff.name != null)
            _Change(l10n.refreshFieldName, p.name, diff.name!),
          if (diff.phone != null)
            _Change(l10n.refreshFieldPhone, p.phone ?? none(), diff.phone!),
          if (diff.photo != null)
            _Change(
              l10n.refreshFieldPicture,
              none(),
              l10n.refreshPictureFromContact,
            ),
          if (diff.birthday != null)
            _Change(
              l10n.refreshFieldBirthday,
              birthday(p.birthdayMonth, p.birthdayDay, p.birthdayYear),
              birthday(
                diff.birthday!.month,
                diff.birthday!.day,
                diff.birthday!.year,
              ),
            ),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: GreyButton(
                  small: true,
                  label: skipLabel ?? l10n.refreshSkip,
                  onPressed: onSkip,
                ),
              ),
              Expanded(
                child: MainButton(
                  label: acceptLabel ?? l10n.refreshApply,
                  onPressed: onAccept,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Head extends StatelessWidget {
  const _Head(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: context.text.labelMedium);
}

class _Change extends StatelessWidget {
  const _Change(this.field, this.oldValue, this.newValue);

  final String field;
  final String oldValue;
  final String newValue;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 2,
    children: [
      Text(field, style: context.text.bodyMedium?.copyWith(fontSize: 13)),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Expanded(child: Text(oldValue, style: context.text.bodyMedium)),
          Expanded(
            child: Text(
              newValue,
              style: context.text.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

/// The button on the edit person page: reads the contact of [person], shows
/// what would change and returns the diff the user confirmed, or null.
Future<ContactDiff?> showRefreshPerson(BuildContext context, Person person) =>
    showModalBottomSheet<ContactDiff>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PersonSheet(person),
    );

class _PersonSheet extends ConsumerStatefulWidget {
  const _PersonSheet(this.person);

  final Person person;

  @override
  ConsumerState<_PersonSheet> createState() => _PersonSheetState();
}

class _PersonSheetState extends ConsumerState<_PersonSheet> {
  RefreshResult? _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await refreshPeople(ref.read(contactsSourceProvider), [
      widget.person,
    ]);
    if (mounted) setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final result = _result;
    String? message;
    Widget? button;
    if (result != null) {
      if (result.status == RefreshStatus.denied) {
        message = l10n.importDenied;
        button = GreyButton(
          label: l10n.openSettings,
          onPressed: ref.read(contactsSourceProvider).openSettings,
        );
      } else if (result.status == RefreshStatus.failed) {
        message = l10n.importLoadError;
      } else if (result.gone > 0) {
        message = l10n.refreshGone;
      } else if (result.diffs.isEmpty) {
        message = l10n.refreshNothing;
      }
    }
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14,
          children: [
            Text(l10n.refreshTitle, style: context.text.titleLarge),
            if (result == null)
              const SizedBox(height: 60)
            else if (message != null) ...[
              Text(message, style: context.text.bodyMedium),
              ?button,
              GreyButton(
                label: l10n.done,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ] else
              DiffCard(
                result.diffs.single,
                skipLabel: l10n.cancel,
                onAccept: () => Navigator.of(context).pop(result.diffs.single),
                onSkip: () => Navigator.of(context).pop(),
              ),
          ],
        ),
      ),
    );
  }
}
