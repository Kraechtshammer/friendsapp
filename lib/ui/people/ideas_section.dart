import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/database.dart';
import '../../domain/idea.dart';
import '../../domain/ideas.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../widgets/choice_chips.dart';
import '../widgets/grey_button.dart';
import '../widgets/kept_card.dart';
import '../widgets/kept_text_field.dart';
import '../widgets/link_row.dart';
import '../widgets/picture_thumb.dart';
import '../widgets/section_label.dart';
import 'idea_sheet.dart';

/// "Ideas" on the person page (F11; 01-research.md §9.8): one card
/// with the open ideas grouped by kind, the ticked ones folded into a
/// "n done" line, and a quick add row: one text field and the kind as two
/// chips. Tapping an idea opens [showIdeaSheet].
class IdeasSection extends ConsumerStatefulWidget {
  const IdeasSection(this.person, {super.key});

  final Person person;

  @override
  ConsumerState<IdeasSection> createState() => _IdeasSectionState();
}

class _IdeasSectionState extends ConsumerState<IdeasSection> {
  final _text = TextEditingController();
  var _kind = IdeaKind.toDo;
  var _showDone = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    // Text with a link in it keeps the link apart, as a share does.
    final split = splitSharedText(text);
    _text.clear();
    setState(() {});
    await ref
        .read(ideasRepositoryProvider)
        .add(
          personId: widget.person.id,
          note: split.text,
          kind: _kind,
          link: split.link,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kept = context.kept;
    final ideas =
        ref.watch(personIdeasProvider(widget.person.id)).value ?? const [];
    final done = [
      for (final i in ideas)
        if (i.doneAt != null) i,
    ];
    final groups = [
      for (final kind in IdeaKind.values) (kind, openIdeas(ideas, kind)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        const SizedBox(height: 4),
        SectionLabel(l10n.ideasSection),
        KeptCard(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              for (final (kind, open) in groups)
                if (open.isNotEmpty) ...[
                  _GroupHeading(kind),
                  for (final idea in open) _IdeaRow(idea),
                  const SizedBox(height: 4),
                ],
              if (done.isNotEmpty) ...[
                _DoneLine(
                  count: done.length,
                  open: _showDone,
                  onTap: () => setState(() => _showDone = !_showDone),
                ),
                if (_showDone)
                  for (final idea in done) _IdeaRow(idea),
                const SizedBox(height: 4),
              ],
              KeptTextField(
                controller: _text,
                hint: l10n.ideaAddHint,
                fillColor: kept.ground,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => unawaited(_add()),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 8,
                children: [
                  Expanded(
                    child: ChoiceChips<IdeaKind>(
                      options: ideaKindOptions(l10n),
                      value: _kind,
                      onChanged: (k) => setState(() => _kind = k),
                    ),
                  ),
                  if (_text.text.trim().isNotEmpty)
                    GreyButton(
                      small: true,
                      label: l10n.ideaAdd,
                      onPressed: () => unawaited(_add()),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The kind's icon and name over its ideas.
class _GroupHeading extends StatelessWidget {
  const _GroupHeading(this.kind);

  final IdeaKind kind;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 2),
    child: Row(
      spacing: 8,
      children: [
        KeptIcon(ideaKindIcon(kind), size: 20),
        Text(
          ideaKindLabel(kind, context.l10n),
          style: context.text.labelLarge?.copyWith(
            fontSize: 15,
            color: context.kept.text,
          ),
        ),
      ],
    ),
  );
}

/// "n done" with a chevron; opens and closes the ticked ideas.
class _DoneLine extends StatelessWidget {
  const _DoneLine({
    required this.count,
    required this.open,
    required this.onTap,
  });

  final int count;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final muted = context.kept.muted;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: SizedBox(
        height: 44,
        child: Row(
          spacing: 6,
          children: [
            Icon(
              open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              color: muted,
            ),
            Text(
              context.l10n.ideasDone(count),
              style: context.text.bodyMedium?.copyWith(color: muted),
            ),
          ],
        ),
      ),
    );
  }
}

/// One idea: the tick, the text with its link below, and its picture.
/// Ticked ideas are muted and crossed out; their tick opens them again.
class _IdeaRow extends ConsumerWidget {
  const _IdeaRow(this.idea);

  final Idea idea;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final kept = context.kept;
    final done = idea.doneAt != null;
    final link = idea.link;
    final picture = idea.imagePath;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => showIdeaSheet(context, idea),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 6,
          children: [
            _Tick(
              done: done,
              tooltip: done ? l10n.ideaReopen : l10n.ideaTickOff,
              onTap: () =>
                  ref.read(ideasRepositoryProvider).setDone(idea.id, !done),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ideaText(idea, l10n),
                    style: context.text.bodyLarge?.copyWith(
                      color: done ? kept.muted : kept.text,
                      decoration: done ? TextDecoration.lineThrough : null,
                      decorationColor: kept.muted,
                    ),
                  ),
                  if (link != null && !done) LinkRow(link),
                ],
              ),
            ),
            if (picture != null) PictureThumb(picture, size: 48),
          ],
        ),
      ),
    );
  }
}

/// A round tick, 26 inside a 44 touch target: a ring when open, a mint
/// circle with a dark check when done.
class _Tick extends StatelessWidget {
  const _Tick({required this.done, required this.tooltip, required this.onTap});

  final bool done;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        checked: done,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(
            dimension: 44,
            child: Center(
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? KeptColors.mint : Colors.transparent,
                  border: done ? null : Border.all(color: kept.line, width: 2),
                ),
                child: done
                    ? const Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: KeptColors.onAccent,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
