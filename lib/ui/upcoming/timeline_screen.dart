import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/database.dart';
import '../../domain/birthdays.dart';
import '../../domain/contact_event.dart';
import '../../domain/display_name.dart';
import '../../domain/group.dart';
import '../../domain/intention.dart';
import '../../domain/past_timeline.dart';
import '../../domain/plans.dart';
import '../../domain/timeline.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../home/thought_sheet.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../people/contact_entry_sheet.dart';
import '../people/person_screen.dart';
import '../people/person_timeline_view.dart' show contactTitle;
import '../widgets/dashed_card.dart';
import '../widgets/date_badge.dart';
import '../widgets/face_stack.dart';
import '../widgets/grey_button.dart';
import '../widgets/kept_card.dart';
import '../widgets/section_label.dart';
import '../widgets/when_picker.dart';
import 'entry_style.dart';

/// The Timeline tab (02-design.md §8, replacing the Upcoming tab of §6.9):
/// one list that opens with the "Today" mark in the middle of the screen.
/// Above it the next 12 months (every birthday and open dated thought,
/// the soonest nearest the mark) and, at the very top, the plans without
/// a date. Below it what happened (calls, meet-ups, gaming, birthdays),
/// newest first. Writing is left out, and nothing is shown as late or
/// missed.
class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  static const _todayKey = ValueKey('today');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final people = ref.watch(peopleProvider).value ?? const <Person>[];
    final intentions = ref.watch(openIntentionsProvider).value ?? const [];
    final events = ref.watch(allContactEventsProvider).value ?? const [];
    final now = ref.watch(clockProvider)();
    final couples = ref.watch(couplesByIdProvider);
    final coming = groupUpcoming(
      upcomingEntries(people, intentions, now, couples: couples),
      now,
    );
    final past = groupPast(
      pastEntries(people, events, now, couples: couples),
      now,
    );
    final plans = undatedPlans(people, intentions, couples: couples);
    final resolve = ref.watch(thoughtSubjectProvider);

    // Above the mark the list grows upwards: the first item sits right
    // over "Today". Each group: its entries soonest first, then its label.
    var tilt = 0;
    final above = <Widget>[
      if (coming.isEmpty)
        _OnLine(
          child: KeptCard(
            small: true,
            child: Text(l10n.upcomingEmpty, style: context.text.bodyMedium),
          ),
        ),
      for (final g in coming) ...[
        for (final e in g.entries)
          _OnLine(child: _UpcomingRow(e, entryTilt(tilt++))),
        _OnLine(child: _GroupLabel(_groupLabel(g, now.year, l10n))),
      ],
      if (plans.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _NoDateYet(plans, resolve),
        ),
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(l10n.timelineSubtitle, style: context.text.bodyMedium),
      ),
    ];
    final below = <Widget>[
      if (past.isEmpty)
        _OnLine(
          child: KeptCard(
            small: true,
            child: Text(l10n.pastEmpty, style: context.text.bodyMedium),
          ),
        ),
      for (final g in past) ...[
        if (g.kind != PastGroupKind.today)
          _OnLine(child: _GroupLabel(_pastLabel(g, now.year, l10n))),
        for (final e in g.entries)
          _OnLine(child: _PastRow(e, entryTilt(tilt++))),
      ],
    ];
    return TabPage(
      title: l10n.tabTimeline,
      child: CustomScrollView(
        center: _todayKey,
        anchor: .5,
        slivers: [
          SliverList.list(children: above),
          const SliverToBoxAdapter(key: _todayKey, child: _TodayMark()),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 24),
            sliver: SliverList.list(children: below),
          ),
        ],
      ),
    );
  }
}

/// A piece of the vertical line under the middle of the date badges
/// (56 wide, so 27 + 1), with [child] on it.
class _OnLine extends StatelessWidget {
  const _OnLine({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned(
        left: 27,
        top: 0,
        bottom: 0,
        width: 2,
        child: ColoredBox(color: context.kept.line),
      ),
      Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: child),
    ],
  );
}

/// A group label sitting on the line, the ground colour behind it.
class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      color: context.kept.ground,
      padding: const EdgeInsets.fromLTRB(0, 3, 8, 3),
      child: SectionLabel(text),
    ),
  );
}

/// "Today": the label on the line and a rule across, where the list opens.
class _TodayMark extends StatelessWidget {
  const _TodayMark();

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    return _OnLine(
      child: Row(
        children: [
          Container(
            color: kept.ground,
            padding: const EdgeInsets.fromLTRB(0, 3, 8, 3),
            child: SectionLabel(context.l10n.timelineToday, color: kept.text),
          ),
          Expanded(child: Container(height: 2, color: kept.line)),
        ],
      ),
    );
  }
}

/// "This week", "Next week", or the month (with the year when it is not
/// the current one).
String _groupLabel(UpcomingGroup g, int year, AppLocalizations l10n) =>
    switch (g.kind) {
      UpcomingGroupKind.thisWeek => l10n.groupThisWeek,
      UpcomingGroupKind.nextWeek => l10n.groupNextWeek,
      UpcomingGroupKind.month => _month(g.month!, year, l10n),
    };

/// "Earlier this week", "Last week", or the month. Today has no label.
String _pastLabel(PastGroup g, int year, AppLocalizations l10n) =>
    switch (g.kind) {
      PastGroupKind.today => '',
      PastGroupKind.earlierThisWeek => l10n.groupEarlierThisWeek,
      PastGroupKind.lastWeek => l10n.groupLastWeek,
      PastGroupKind.month => _month(g.month!, year, l10n),
    };

String _month(DateTime month, int year, AppLocalizations l10n) =>
    month.year == year ? l10n.monthLabel(month) : l10n.monthYearLabel(month);

class _UpcomingRow extends ConsumerWidget {
  const _UpcomingRow(this.entry, this.tilt);

  final UpcomingEntry entry;
  final double tilt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final e = entry;
    final names = ref.watch(displayNamesProvider);
    return _EntryRow(
      day: e.day,
      accent: entryAccent(e),
      tilt: tilt,
      icon: entryIcon(e),
      title: entryTitle(e, l10n, names),
      subtitle: entrySubtitle(e, l10n, names),
      people: switch (e) {
        BirthdayEntry(:final person) => [person],
        ThoughtEntry(:final person, :final couple) =>
          couple?.members ?? [person],
      },
      onTap: () => switch (e) {
        BirthdayEntry(:final person) => _openPerson(context, person),
        ThoughtEntry(:final person, :final intention) => showThoughtSheet(
          context,
          ref,
          person,
          intention,
        ),
      },
    );
  }
}

class _PastRow extends ConsumerWidget {
  const _PastRow(this.entry, this.tilt);

  final PastEntry entry;
  final double tilt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final names = ref.watch(displayNamesProvider);
    String? note(String? text) {
      final t = text?.trim();
      return t == null || t.isEmpty ? null : t;
    }

    return switch (entry) {
      PastContact(:final person, :final event, :final couple) => _EntryRow(
        day: entry.day,
        accent: _contactAccent(event.kind),
        tilt: tilt,
        icon: _contactIcon(event.kind),
        title: contactTitle(event, shortNameIn(names, person), l10n),
        people: couple?.members ?? [person],
        subtitle: [
          couple?.label(names) ?? shortNameIn(names, person),
          ?note(event.note),
        ].join(' · '),
        onTap: () => showContactEntrySheet(context, ref, event),
      ),
      PastPersonBirthday(:final person, :final age, :final congratulated) =>
        _EntryRow(
          day: entry.day,
          accent: KeptColors.pink,
          tilt: tilt,
          icon: KeptIcons.cake,
          title: l10n.birthdayOf(shortNameIn(names, person)),
          subtitle: [
            if (age != null) l10n.turnedAge(age),
            if (congratulated) l10n.youCongratulated,
          ].join(' · '),
          people: [person],
          onTap: () => _openPerson(context, person),
        ),
      PastOwnBirthday(:final from) => _EntryRow(
        day: entry.day,
        accent: KeptColors.pink,
        tilt: tilt,
        icon: KeptIcons.cake,
        title: l10n.yourBirthday,
        people: from,
        subtitle: l10n.wishesFrom(
          from.map((p) => shortNameIn(names, p)).join(', '),
        ),
      ),
    };
  }
}

Color _contactAccent(ContactKind kind) => switch (kind) {
  ContactKind.wrote => KeptColors.sun,
  ContactKind.called => KeptColors.sky,
  ContactKind.met => KeptColors.mint,
  ContactKind.gamed => KeptColors.lilac,
  ContactKind.birthdayWish => KeptColors.pink,
};

KeptIcons _contactIcon(ContactKind kind) => switch (kind) {
  ContactKind.wrote => KeptIcons.chat,
  ContactKind.called => KeptIcons.phone,
  ContactKind.met => KeptIcons.people,
  ContactKind.gamed => KeptIcons.controller,
  ContactKind.birthdayWish => KeptIcons.cake,
};

void _openPerson(BuildContext context, Person person) => Navigator.of(context)
    .push(MaterialPageRoute<void>(builder: (_) => PersonScreen(id: person.id)));

/// One dated row: the tilted badge on the line and a small card.
class _EntryRow extends StatelessWidget {
  const _EntryRow({
    required this.day,
    required this.accent,
    required this.tilt,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.people,
    this.onTap,
  });

  final DateTime day;
  final Color accent;
  final double tilt;
  final KeptIcons icon;
  final String title;
  final String subtitle;

  /// Shown as small faces at the start of the [subtitle] line.
  final List<Person> people;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Consumer(
          builder: (context, ref, _) => DateBadge(
            date: day,
            accent: accent,
            tilt: tilt,
            today: isToday(day, ref.watch(clockProvider)()),
          ),
        ),
        Expanded(
          child: KeptCard(
            small: true,
            padding: const EdgeInsets.fromLTRB(14, 8, 12, 8),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 42),
              child: Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.labelLarge?.copyWith(
                            fontSize: 16,
                            color: context.kept.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          spacing: 6,
                          children: [
                            FaceStack(people),
                            Expanded(
                              child: Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.bodyMedium?.copyWith(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  KeptIcon(icon, size: 30),
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
