import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/idea.dart';
import '../../domain/ideas.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/choice_chips.dart';
import '../widgets/grey_button.dart';
import '../widgets/kept_text_field.dart';
import '../widgets/link_row.dart';
import '../widgets/main_button.dart';
import '../widgets/picture_thumb.dart';
import '../varied_text.dart';

/// The text an idea shows: its text, else its link, else "Picture".
String ideaText(Idea idea, AppLocalizations l10n) {
  final note = idea.note.trim();
  if (note.isNotEmpty) return note;
  final link = idea.link;
  if (link != null && link.trim().isNotEmpty) return shortLink(link);
  return l10n.ideaPicture;
}

/// The two idea kinds as chips with their icons.
List<ChipOption<IdeaKind>> ideaKindOptions(AppLocalizations l10n) => [
  for (final k in IdeaKind.values)
    ChipOption(k, ideaKindLabel(k, l10n), icon: ideaKindIcon(k)),
];

/// Opens the sheet that edits an idea: text, kind and link, with Save and
/// Delete. The picture, if any, is shown and can be opened larger.
Future<void> showIdeaSheet(BuildContext context, Idea idea) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: context.kept.surface,
      builder: (_) => _IdeaSheet(idea),
    );

class _IdeaSheet extends ConsumerStatefulWidget {
  const _IdeaSheet(this.idea);

  final Idea idea;

  @override
  ConsumerState<_IdeaSheet> createState() => _IdeaSheetState();
}

class _IdeaSheetState extends ConsumerState<_IdeaSheet> with VariedText {
  late final _note = TextEditingController(text: widget.idea.note);
  late final _link = TextEditingController(text: widget.idea.link ?? '');
  late var _kind = widget.idea.kind;

  @override
  void dispose() {
    _note.dispose();
    _link.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    await ref
        .read(ideasRepositoryProvider)
        .update(
          widget.idea.id,
          note: _note.text,
          kind: _kind,
          link: _link.text,
        );
    navigator.pop();
  }

  Future<void> _delete() async {
    final navigator = Navigator.of(context);
    await ref.read(ideasRepositoryProvider).delete(widget.idea.id);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kept = context.kept;
    final picture = widget.idea.imagePath;
    final link = _link.text.trim();
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
            l10n.editIdea,
            style: context.text.titleLarge?.copyWith(color: kept.text),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Expanded(
                child: KeptTextField(
                  controller: _note,
                  hint: vary(l10n.ideaTextHints),
                  fillColor: kept.ground,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  minLines: 1,
                ),
              ),
              if (picture != null) PictureThumb(picture),
            ],
          ),
          ChoiceChips<IdeaKind>(
            options: ideaKindOptions(l10n),
            value: _kind,
            onChanged: (k) => setState(() => _kind = k),
          ),
          KeptTextField(
            controller: _link,
            hint: l10n.linkHint,
            fillColor: kept.ground,
            keyboardType: TextInputType.url,
            onChanged: (_) => setState(() {}),
          ),
          if (link.isNotEmpty) LinkRow(link),
          MainButton(label: l10n.save, onPressed: _save),
          GreyButton(label: l10n.delete, onPressed: _delete),
        ],
      ),
    );
  }
}
