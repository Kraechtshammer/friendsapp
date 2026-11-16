import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../data/ideas_repository.dart';
import '../../domain/idea.dart';
import '../../domain/ideas.dart';
import '../../domain/intention.dart';
import '../../domain/person_name.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/labels.dart';
import '../../platform/share_receiver.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/choice_chips.dart';
import '../widgets/grey_button.dart';
import '../widgets/kept_text_field.dart';
import '../widgets/link_row.dart';
import '../widgets/main_button.dart';
import '../widgets/picture_thumb.dart';
import '../widgets/section_label.dart';
import 'person_choice_row.dart';

/// What a shared thing becomes.
enum ShareTarget { ideaToDo, ideaToTalk, thought }

String _targetLabel(ShareTarget t, AppLocalizations l10n) => switch (t) {
  ShareTarget.ideaToDo => l10n.shareIdeaToDo,
  ShareTarget.ideaToTalk => l10n.shareIdeaToTalk,
  ShareTarget.thought => l10n.shareThought,
};

/// "Keep this for…" (sharing in): shows what another app shared, lets
/// the user pick a person and what it becomes (an idea to do, an idea to
/// talk about, or a thought; a picture only an idea), and saves it. A short
/// note confirms it; the screen behind stays as it was. Cancelling deletes a
/// copied picture again.
Future<void> showShareSheet(BuildContext context, SharedItem item) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final savedFor = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: context.kept.surface,
    builder: (_) => _ShareSheet(item),
  );
  if (savedFor == null) {
    if (item case SharedImage(:final path)) await deletePictureFile(path);
    return;
  }
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(l10n.shareSaved(savedFor))));
}

class _ShareSheet extends ConsumerStatefulWidget {
  const _ShareSheet(this.item);

  final SharedItem item;

  @override
  ConsumerState<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends ConsumerState<_ShareSheet> {
  late final SplitText _split = switch (widget.item) {
    SharedText(:final text) => splitSharedText(text),
    SharedImage() => const SplitText('', null),
  };
  late final _text = TextEditingController(text: _split.text);
  String? _personId;
  var _target = ShareTarget.ideaToDo;
  var _kind = IntentionKind.write;
  var _saving = false;

  String? get _imagePath => switch (widget.item) {
    SharedImage(:final path) => path,
    SharedText() => null,
  };

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _save(Person person) async {
    if (_saving) return;
    _saving = true;
    final navigator = Navigator.of(context);
    final note = _text.text.trim();
    switch (_target) {
      case ShareTarget.ideaToDo || ShareTarget.ideaToTalk:
        await ref
            .read(ideasRepositoryProvider)
            .add(
              personId: person.id,
              note: note,
              kind: _target == ShareTarget.ideaToDo
                  ? IdeaKind.toDo
                  : IdeaKind.toTalk,
              link: _split.link,
              imagePath: _imagePath,
            );
      case ShareTarget.thought:
        await ref
            .read(intentionsRepositoryProvider)
            .add(
              personId: person.id,
              note: note,
              kind: _kind,
              link: _split.link,
            );
    }
    navigator.pop(firstNameOf(person.name));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kept = context.kept;
    final peopleState = ref.watch(peopleProvider);
    final people = peopleState.value ?? const <Person>[];
    final open = ref.watch(openIntentionsProvider).value ?? const [];
    Person? selected;
    for (final p in people) {
      if (p.id == _personId) selected = p;
    }
    final image = _imagePath;
    final link = _split.link;
    final targets = [
      for (final t in ShareTarget.values)
        if (image == null || t != ShareTarget.thought) t,
    ];
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
            l10n.shareTitle,
            style: context.text.titleLarge?.copyWith(color: kept.text),
          ),
          if (image != null || link != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: kept.ground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                spacing: 12,
                children: [
                  if (image != null) PictureThumb(image, size: 72),
                  if (link != null) Expanded(child: LinkRow(link)),
                ],
              ),
            ),
          KeptTextField(
            controller: _text,
            hint: l10n.shareTextHint,
            fillColor: kept.ground,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 4,
            minLines: 1,
          ),
          if (peopleState.hasValue && people.isEmpty)
            Text(
              l10n.captureNoPeople,
              style: context.text.bodyMedium?.copyWith(color: kept.muted),
            )
          else if (people.isNotEmpty)
            PersonChoiceRow(
              people: people,
              intentions: open,
              selectedId: _personId,
              textColor: kept.text,
              fieldColor: kept.ground,
              onChanged: (id) => setState(() => _personId = id),
            ),
          SectionLabel(l10n.shareKeepAs),
          ChoiceChips<ShareTarget>(
            options: [
              for (final t in targets) ChipOption(t, _targetLabel(t, l10n)),
            ],
            value: _target,
            onChanged: (t) => setState(() => _target = t),
          ),
          if (_target == ShareTarget.thought)
            ChoiceChips<IntentionKind>(
              options: [
                for (final k in IntentionKind.values)
                  ChipOption(k, kindLabel(k, l10n), icon: kindIcon(k)),
              ],
              value: _kind,
              onChanged: (k) => setState(() => _kind = k),
            ),
          if (selected != null)
            MainButton(
              label: l10n.shareSave(firstNameOf(selected.name)),
              onPressed: () => unawaited(_save(selected!)),
            ),
          GreyButton(
            label: l10n.cancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
