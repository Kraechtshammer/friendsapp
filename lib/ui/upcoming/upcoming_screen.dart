import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/group.dart';
import '../../domain/intention.dart';
import '../../domain/plans.dart';
import '../../domain/timeline.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../home/thought_sheet.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../people/person_screen.dart';
import '../widgets/dashed_card.dart';
import '../widgets/date_badge.dart';
import '../widgets/grey_button.dart';
import '../widgets/kept_card.dart';
import '../widgets/section_label.dart';
import '../widgets/when_picker.dart';
import 'entry_style.dart';

/// The Upcoming tab (02-design.md §6.9; concept V6 · Upcoming): a timeline
/// of the next 12 months with every birthday and every open dated thought,
/// soonest first, and below it the plans without a date, by horizon. Past
/// dates never show here, and nothing is shown as late.
class UpcomingScreen extends ConsumerWidget {
  const UpcomingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final people = ref.watch(peopleProvider).value ?? const <Person>[];
    final intentions = ref.watch(openIntentionsProvider).value ?? const [];
    final now = ref.watch(clockProvider)();
    final couples = ref.watch(couplesByIdProvider);
    final groups = groupUpcoming(
      upcomingEntries(people, intentions, now, couples: couples),
      now,
    );
    final plans = undatedPlans(people, intentions, couples: couples);
    final resolve = ref.watch(thoughtSubjectProvider);
    return TabPage(
      title: l10n.upcomingTitle,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Text(l10n.upcomingSubtitle, style: context.text.bodyMedium),
          const SizedBox(height: 12),
          if (groups.isEmpty)
            KeptCard(
              small: true,
              child: Text(l10n.upcomingEmpty, style: context.text.bodyMedium),
            )
          else
            _Timeline(groups, now.year),
          if (plans.isNotEmpty) ...[
            const SizedBox(height: 14),
            _NoDateYet(plans, resolve),
          ],
        ],
      ),
    );
  }
}

/// The groups on a vertical line, labels sitting on it with the ground
/// colour behind them.
class _Timeline extends StatelessWidget {
  const _Timeline(this.groups, this.year);

  final List<UpcomingGroup> groups;

  /// The current year; other years show in the month label.
  final int year;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    var index = 0;
    return Stack(
      children: [
        // Under the middle of the date badges (56 wide, so 27 + 1).
        Positioned(
          left: 27,
          top: 8,
          bottom: 8,
          width: 2,
          child: ColoredBox(color: kept.line),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            for (final g in groups) ...[
              Container(
                color: kept.ground,
                padding: const EdgeInsets.fromLTRB(0, 3, 8, 3),
                child: SectionLabel(_groupLabel(g, year, context.l10n)),
              ),
              for (final e in g.entries) _EntryRow(e, entryTilt(index++)),
            ],
          ],
        ),
      ],
    );
  }
}

/// "This week", "Next week", or the month (with the year when it is not
/// the current one).
String _groupLabel(UpcomingGroup g, int year, AppLocalizations l10n) =>
    switch (g.kind) {
      UpcomingGroupKind.thisWeek => l10n.groupThisWeek,
      UpcomingGroupKind.nextWeek => l10n.groupNextWeek,
      UpcomingGroupKind.month =>
        g.month!.year == year
            ? l10n.monthLabel(g.month!)
            : l10n.monthYearLabel(g.month!),
    };

class _EntryRow extends ConsumerWidget {
  const _EntryRow(this.entry, this.tilt);

  final UpcomingEntry entry;
  final double tilt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final e = entry;
    final names = ref.watch(displayNamesProvider);
    return Row(
      spacing: 10,
      children: [
        DateBadge(date: e.day, accent: entryAccent(e), tilt: tilt),
        Expanded(
          child: KeptCard(
            small: true,
            padding: const EdgeInsets.fromLTRB(14, 8, 12, 8),
            onTap: () => switch (e) {
              BirthdayEntry(:final person) => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PersonScreen(id: person.id),
                ),
              ),
              ThoughtEntry(:final person, :final intention) => showThoughtSheet(
                context,
                ref,
                person,
                intention,
              ),
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 42),
              child: Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entryTitle(e, l10n, names),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.labelLarge?.copyWith(
                            fontSize: 16,
                            color: context.kept.text,
                          ),
                        ),
                        Text(
                          entrySubtitle(e, l10n, names),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodyMedium?.copyWith(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  KeptIcon(entryIcon(e), size: 30),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The plans without a date, in three groups: Soon, Later, When…
class _NoDateYet extends StatelessWidget {
  const _NoDateYet(this.plans, this.resolve);

  final Map<Horizon, List<Intention>> plans;
  final ThoughtSubject? Function(Intention) resolve;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DashedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          SectionLabel(l10n.noDateYet),
          for (final entry in plans.entries) ...[
            Text(
              horizonLabel(entry.key, l10n),
              style: context.text.titleLarge?.copyWith(
                fontSize: 17,
                color: context.kept.text,
              ),
            ),
            for (final i in entry.value) _PlanRow(resolve(i)!, i),
          ],
        ],
      ),
    );
  }
}

class _PlanRow extends ConsumerWidget {
  const _PlanRow(this.subject, this.intention);

  final ThoughtSubject subject;
  final Intention intention;

  Person get person => subject.person;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final condition = intention.horizon == Horizon.whenCondition
        ? whenText(whenOf(intention), l10n)
        : null;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => showThoughtSheet(context, ref, person, intention),
      child: Row(
        spacing: 10,
        children: [
          KeptIcon(kindIcon(intention.kind), size: 28),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  thoughtText(intention, l10n),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: context.kept.text,
                  ),
                ),
                Text(
                  [
                    subject.label(ref.watch(displayNamesProvider)),
                    ?condition,
                  ].join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium?.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
          GreyButton(
            small: true,
            label: l10n.pickADate,
            onPressed: () async {
              final day = await pickDay(context, ref);
              if (day == null) return;
              await ref
                  .read(intentionsRepositoryProvider)
                  .setWhen(intention.id, When.date(day));
            },
          ),
        ],
      ),
    );
  }
}
