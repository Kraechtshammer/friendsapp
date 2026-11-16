import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/grey_button.dart';
import '../widgets/kept_text_field.dart';
import '../widgets/main_button.dart';

/// Opens the small sheet that fixes a mistake in the friend timeline: the
/// activity and the next-time note of one contact event, and Delete (after
/// a confirm). Birthday and "Added" entries are not editable.
Future<void> showContactEntrySheet(
  BuildContext context,
  WidgetRef ref,
  ContactEvent event,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  backgroundColor: context.kept.surface,
  builder: (_) => _EntrySheet(event),
);

class _EntrySheet extends ConsumerStatefulWidget {
  const _EntrySheet(this.event);

  final ContactEvent event;

  @override
  ConsumerState<_EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends ConsumerState<_EntrySheet> {
  late final _activity = TextEditingController(text: widget.event.activity);
  late final _note = TextEditingController(text: widget.event.note);

  @override
  void dispose() {
    _activity.dispose();
    _note.dispose();
    super.dispose();
  }

  /// Empty text is stored as no text.
  static String? _clean(String text) {
    final t = text.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    await ref
        .read(contactEventsRepositoryProvider)
        .update(
          widget.event.id,
          activity: _clean(_activity.text),
          note: _clean(_note.text),
        );
    navigator.pop();
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final repo = ref.read(contactEventsRepositoryProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteEntryTitle),
        content: Text(l10n.deleteEntryBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await repo.delete(widget.event.id);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kept = context.kept;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Text(
            l10n.editEntry,
            style: context.text.titleLarge?.copyWith(color: kept.text),
          ),
          KeptTextField(
            controller: _activity,
            label: l10n.entryActivity,
            fillColor: kept.ground,
            textCapitalization: TextCapitalization.sentences,
          ),
          KeptTextField(
            controller: _note,
            label: l10n.entryNote,
            fillColor: kept.ground,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 3,
            minLines: 1,
          ),
          MainButton(label: l10n.save, onPressed: _save),
          GreyButton(label: l10n.deleteEntry, onPressed: _delete),
        ],
      ),
    );
  }
}
