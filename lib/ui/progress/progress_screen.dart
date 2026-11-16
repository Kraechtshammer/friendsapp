import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/progress.dart';
import '../../domain/stamps.dart';
import '../../domain/treat.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../widgets/avatar.dart';
import '../widgets/kept_card.dart';
import '../widgets/grey_button.dart';
import '../widgets/section_label.dart';
import '../widgets/tag.dart';
import 'stamp_card.dart';
import 'treats_screen.dart';

/// The Progress tab (02-design.md §8, M9; concept V6 · Progress and stamp
/// card): the stamp count that only grows, the current stamp card, treats
/// that are earned, this week, "weeks in a row" that pause and never reset,
/// and a few numbers for the user's own use. Nothing here is a target, and
/// nothing is shown as lost or missed.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider)();
    final treats = ref.watch(treatsProvider).value ?? const <Treat>[];
    final stamps = ref.watch(stampsProvider).value ?? const <Stamp>[];
    final events =
        ref.watch(allContactEventsProvider).value ?? const <ContactEvent>[];
    final people = ref.watch(peopleProvider).value ?? const <Person>[];
    final answers = ref.watch(dayAnswersProvider).value ?? const <DayAnswer>[];
    final current = currentTreat(treats);
    final celebrate = treatsIn(treats, TreatState.earned);
    final week = peopleThisWeek(events, now);
    final byId = {for (final p in people) p.id: p};
    final weeks = weeksWithContact([
      for (final e in events)
        if (isOwnContact(e)) e.at,
    ], now);
    return TabPage(
      title: context.l10n.tabProgress,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _Count(total: stampTotal(stamps)),
          for (final t in celebrate) ...[
            const SizedBox(height: 14),
            _Earned(treat: t),
          ],
          const SizedBox(height: 14),
          StampCard(
            treat: current,
            filled: current == null ? 0 : stampsOnCard(stamps, current.id),
            onMyTreats: () => openTreats(context),
          ),
          const SizedBox(height: 14),
          _ThisWeek(
            people: [
              for (final id in week)
                if (byId[id] != null) byId[id]!,
            ],
            weeks: weeks,
          ),
          const SizedBox(height: 14),
          _Numbers(numbers: yourNumbers(events, answers, now)),
        ],
      ),
    );
  }
}

/// The big number: every stamp the user has. Mint tonal card.
class _Count extends StatelessWidget {
  const _Count({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    return KeptCard(
      tone: kept.mintTone,
      child: Row(
        spacing: 14,
        children: [
          Text(
            '$total',
            style: context.text.displayLarge?.copyWith(
              color: kept.mintTone.onContainer,
              height: .9,
            ),
          ),
          Expanded(
            child: Text(
              context.l10n.progressStampsLine,
              style: context.text.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: kept.mintTone.onContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A full card that has not been enjoyed yet: a small celebration with the
/// "Enjoyed" button. Pink tonal card.
class _Earned extends ConsumerWidget {
  const _Earned({required this.treat});

  final Treat treat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final kept = context.kept;
    return KeptCard(
      tone: kept.pinkTone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            spacing: 12,
            children: [
              const KeptIcon(KeptIcons.gift, size: 36),
              Expanded(
                child: Text(
                  l10n.treatEarnedTitle(treat.name),
                  style: context.text.titleLarge?.copyWith(
                    color: kept.pinkTone.onContainer,
                  ),
                ),
              ),
              Tag(l10n.treatFull, accent: kept.pinkTone.onContainer, tilt: 4),
            ],
          ),
          Text(l10n.treatEarnedBody),
          Align(
            alignment: Alignment.centerLeft,
            child: GreyButton(
              small: true,
              label: l10n.treatEnjoyedButton,
              onPressed: () => unawaited(
                ref.read(treatsRepositoryProvider).markEnjoyed(treat.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The people the user was in contact with this week, as avatars, and
/// "weeks in a row".
class _ThisWeek extends StatelessWidget {
  const _ThisWeek({required this.people, required this.weeks});

  final List<Person> people;
  final WeeksInARow weeks;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kept = context.kept;
    return KeptCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          SectionLabel(l10n.progressThisWeek),
          if (people.isEmpty)
            Text(l10n.progressThisWeekEmpty, style: context.text.bodyMedium)
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [for (final p in people) Avatar.person(p, size: 44)],
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: kept.line, width: 1.5)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                spacing: 12,
                children: [
                  const KeptIcon(KeptIcons.leaf, size: 26),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (weeks.count > 0)
                          Text(
                            l10n.weeksInARow(weeks.count),
                            style: context.text.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        Text(
                          weeks.count == 0
                              ? l10n.weeksNone
                              : weeks.thisWeekActive
                              ? l10n.weeksNote
                              : l10n.weeksPaused,
                          style: context.text.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Your numbers": three plain counts, for the user's own use.
class _Numbers extends StatelessWidget {
  const _Numbers({required this.numbers});

  final YourNumbers numbers;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tone = context.kept.skyTone;
    Widget cell(int n, String label) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Text(
            '$n',
            style: context.text.headlineLarge?.copyWith(
              color: tone.onContainer,
            ),
          ),
          Text(
            label,
            style: context.text.bodyMedium?.copyWith(
              color: tone.onContainer,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
    return KeptCard(
      tone: tone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          SectionLabel(l10n.yourNumbers, color: tone.onContainer),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              cell(
                numbers.eveningsYes,
                l10n.numberEveningsYes(numbers.eveningsYes),
              ),
              cell(
                numbers.contactsThisMonth,
                l10n.numberContacts(numbers.contactsThisMonth),
              ),
              cell(
                numbers.peopleThisMonth,
                l10n.numberPeople(numbers.peopleThisMonth),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
