import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/display_name.dart';
import '../../domain/timeline.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../upcoming/entry_style.dart';
import '../widgets/date_badge.dart';
import '../widgets/kept_card.dart';
import '../widgets/section_label.dart';
import 'thought_sheet.dart';

/// "Coming up" on Home (concept V6 · Home): the next two dated things,
/// birthdays and dated thoughts, as two small cards, with "See all" to the
/// Upcoming tab. A birthday card leads to the Upcoming tab, a thought card
/// opens the thought. With nothing dated, nothing is shown.
class ComingUp extends ConsumerWidget {
  const ComingUp({super.key, required this.onSeeAll});

  /// Switches to the Upcoming tab (the shell owns the tab).
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(peopleProvider).value ?? const <Person>[];
    final intentions = ref.watch(openIntentionsProvider).value ?? const [];
    final now = ref.watch(clockProvider)();
    final next = upcomingEntries(
      people,
      intentions,
      now,
      couples: ref.watch(couplesByIdProvider),
    ).take(2).toList();
    if (next.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            children: [
              Expanded(child: SectionLabel(l10n.comingUp)),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onSeeAll,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Row(
                    spacing: 2,
                    children: [
                      Text(
                        l10n.seeAll,
                        style: context.text.labelLarge?.copyWith(
                          fontSize: 14,
                          color: context.kept.text,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: context.kept.text,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                for (final (i, e) in next.indexed)
                  Expanded(child: _Card(e, entryTilt(i), onSeeAll: onSeeAll)),
                if (next.length == 1) const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends ConsumerWidget {
  const _Card(this.entry, this.tilt, {required this.onSeeAll});

  final UpcomingEntry entry;
  final double tilt;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final e = entry;
    final l10n = context.l10n;
    final names = ref.watch(displayNamesProvider);
    // Concept: "Bouldering, Tom".
    final title = switch (e) {
      BirthdayEntry() => entryTitle(e, l10n, names),
      ThoughtEntry(:final intention, :final person, :final couple) =>
        '${thoughtText(intention, l10n)}, '
            '${couple?.label(names) ?? shortNameIn(names, person)}',
    };
    return KeptCard(
      small: true,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      onTap: () => switch (e) {
        BirthdayEntry() => onSeeAll(),
        ThoughtEntry(:final person, :final intention) => showThoughtSheet(
          context,
          ref,
          person,
          intention,
        ),
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DateBadge(
                date: e.day,
                accent: entryAccent(e),
                tilt: tilt,
                small: true,
              ),
              KeptIcon(entryIcon(e), size: 30),
            ],
          ),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: context.kept.text,
            ),
          ),
        ],
      ),
    );
  }
}
