import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/group.dart';
import '../../domain/plans.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../widgets/avatar.dart';
import '../widgets/couple_avatar.dart';
import '../people/couple_screen.dart';
import '../people/person_screen.dart';
import '../widgets/grey_button.dart';
import '../widgets/grey_icon_button.dart';
import 'nice_one_screen.dart';
import 'thought_sheet.dart';
import '../widgets/kept_card.dart';
import '../widgets/link_row.dart';
import '../widgets/section_label.dart';

/// The open intentions, newest first, under "On your mind". Tapping a row
/// opens the person, or the couple page for a couple's thought; the
/// three-dot button edits the thought. Nothing is
/// shown as late and there are no dates (02-design.md §2.3). With none,
/// nothing is shown at all. The pick above it ([TonightsPick]) is the one
/// the evening question scrolls to.
class OpenThoughts extends ConsumerWidget {
  const OpenThoughts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intentions = ref.watch(openIntentionsProvider).value ?? const [];
    final resolve = ref.watch(thoughtSubjectProvider);
    final rows = [
      for (final i in intentions)
        if (resolve(i) case final subject?) _Row(subject, i),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [SectionLabel(context.l10n.onYourMind), ...rows],
      ),
    );
  }
}

class _Row extends ConsumerWidget {
  const _Row(this.subject, this.intention);

  final ThoughtSubject subject;
  final Intention intention;

  Person get person => subject.person;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final note = intention.note.trim();
    final couple = subject.couple;
    return KeptCard(
      small: true,
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => couple == null
              ? PersonScreen(id: person.id)
              : CoupleScreen(id: couple.group.id),
        ),
      ),
      child: Row(
        spacing: 12,
        children: [
          if (couple == null)
            Avatar.person(person, size: 44, classBadge: true)
          else
            CoupleAvatar(
              couple.members,
              size: 44,
              ringColor: context.kept.surface,
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Flexible(
                      child: Text(
                        subject.label(ref.watch(displayNamesProvider)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.labelLarge?.copyWith(
                          color: context.kept.text,
                        ),
                      ),
                    ),
                    KeptIcon(kindIcon(intention.kind), size: 22),
                    if (intention.link != null) const LinkMark(),
                  ],
                ),
                if (note.isNotEmpty)
                  Text(
                    note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium,
                  ),
                WhenLine(intention),
                if (couple == null) LastTimeLine(person.id),
              ],
            ),
          ),
          GreyButton(
            small: true,
            label: context.l10n.done,
            onPressed: () => completeThought(context, ref, person, intention),
          ),
          // The row opens the person; editing is this visible button.
          GreyIconButton(
            icon: Icons.more_horiz_rounded,
            tooltip: context.l10n.editThought,
            size: 40,
            radius: 20,
            onPressed: () => showThoughtSheet(context, ref, person, intention),
          ),
        ],
      ),
    );
  }
}

/// "Last time: ..." with the person's newest contact line, small and
/// muted; nothing when there is none.
class LastTimeLine extends ConsumerWidget {
  const LastTimeLine(this.personId, {super.key});

  final String personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final note = ref.watch(personLatestNoteProvider(personId)).value?.trim();
    if (note == null || note.isEmpty) return const SizedBox.shrink();
    return Text(
      context.l10n.lastTime(note),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.text.bodySmall?.copyWith(color: context.kept.muted),
    );
  }
}

/// The "when" of a thought as a small line in the sun colour ("Sat 21
/// Nov · 11:00", "Soon", "when it is warm again"); nothing when it has
/// none.
class WhenLine extends StatelessWidget {
  const WhenLine(this.intention, {super.key});

  final Intention intention;

  @override
  Widget build(BuildContext context) {
    final text = whenText(whenOf(intention), context.l10n);
    if (text.isEmpty) return const SizedBox.shrink();
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.text.bodySmall?.copyWith(
        color: context.kept.sunTone.onContainer,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
