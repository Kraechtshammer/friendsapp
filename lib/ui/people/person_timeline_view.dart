import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/database.dart';
import '../../domain/birthdays.dart';
import '../../domain/contact_event.dart';
import '../../domain/person_timeline.dart';
import '../../domain/plans.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../upcoming/entry_style.dart';
import '../widgets/section_label.dart';
import 'contact_entry_sheet.dart';

/// The friend timeline on the person page, in the compact style of concept
/// V6 (docs/concepts/gen_v6.py, PERSON_MORE and PERSON_MORE2): a thin
/// vertical line, a date on the left, a small icon on the line and the text
/// on the right. "Coming up" lies above the "Today" mark with the soonest
/// nearest to it, the history below, newest first. Direction shows as a
/// small arrow. Nothing is shown as missed or late (02-design.md §6.8).
/// Tapping a contact entry opens the edit sheet.
class PersonTimelineView extends ConsumerWidget {
  const PersonTimelineView(this.person, {super.key});

  final Person person;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final now = ref.watch(clockProvider)();
    final events =
        ref.watch(personContactEventsProvider(person.id)).value ?? const [];
    final intentions = ref.watch(personThoughtsProvider(person.id));
    final couple = ref.watch(personCoupleProvider(person.id)).value;
    final timeline = personTimeline(
      person,
      events,
      intentions,
      now,
      groupId: couple?.group.id,
    );
    final name = ref.shortName(person);
    // Shared things say "with Tom" (the partner's short name).
    final partner = couple?.members.where((p) => p.id != person.id).firstOrNull;
    final withText = partner == null
        ? null
        : l10n.coupleWith(ref.shortName(partner));
    String? withPartner(String? groupId) =>
        groupId != null && groupId == couple?.group.id ? withText : null;
    String? join(Iterable<String?> parts) {
      final text = parts.where((t) => t != null && t.isNotEmpty).join(' · ');
      return text.isEmpty ? null : text;
    }

    var dated = 0;
    return Stack(
      children: [
        Positioned(
          left: 87,
          top: 6,
          bottom: 6,
          width: 2,
          child: ColoredBox(color: context.kept.line),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            if (timeline.upcoming.isNotEmpty) _Label(l10n.comingUp),
            for (final e in timeline.upcoming)
              switch (e) {
                UpcomingBirthday() => _Row(
                  date: _Pill(e.day, KeptColors.pink, entryTilt(dated++), now),
                  icon: KeptIcons.cake,
                  title: l10n.birthdayOf(name),
                  note: e.age == null ? null : l10n.turnsAge(e.age!),
                ),
                UpcomingThought(:final intention, :final time) => _Row(
                  date: _Pill(
                    e.day,
                    kindAccent(intention.kind),
                    entryTilt(dated++),
                    now,
                  ),
                  icon: kindIcon(intention.kind),
                  title: thoughtText(intention, l10n),
                  note: join([
                    kindLabel(intention.kind, l10n),
                    if (time != null) l10n.timeShort(time),
                    withPartner(intention.groupId),
                  ]),
                ),
                // One compact line: no date, so no pill.
                UpcomingPlan(:final intention) => _Row(
                  date: const SizedBox.shrink(),
                  icon: kindIcon(intention.kind),
                  title: [
                    thoughtText(intention, l10n),
                    whenText(whenOf(intention), l10n),
                    ?withPartner(intention.groupId),
                  ].where((t) => t.isNotEmpty).join(' · '),
                ),
                _ => const SizedBox.shrink(),
              },
            _Label(l10n.timelineToday, today: true),
            for (final e in timeline.history)
              switch (e) {
                ContactEntry(:final event) => _Row(
                  date: _DateText(e.day, now),
                  icon: _contactIcon(event.kind),
                  arrow: _arrow(event.direction),
                  title: contactTitle(event, name, l10n),
                  note: join([withPartner(event.groupId), _note(event.note)]),
                  onTap: () => showContactEntrySheet(context, ref, event),
                ),
                // One line per day; tapping edits the newest message.
                TextingDay(:final events, :final byUser, :final byThem) => _Row(
                  date: _DateText(e.day, now),
                  icon: KeptIcons.chat,
                  arrow: byUser && byThem
                      ? null
                      : _arrow(events.first.direction),
                  title: byUser && byThem
                      ? l10n.youTexted
                      : contactTitle(events.first, name, l10n),
                  note: events.map((ev) => _note(ev.note)).nonNulls.firstOrNull,
                  onTap: () =>
                      showContactEntrySheet(context, ref, events.first),
                ),
                PastBirthday(:final congratulated) => _Row(
                  date: _DateText(e.day, now),
                  icon: KeptIcons.cake,
                  title: l10n.birthdayOf(name),
                  note: congratulated ? l10n.youCongratulated : null,
                ),
                OwnBirthdayWish() => _Row(
                  date: _DateText(e.day, now),
                  icon: KeptIcons.cake,
                  title: l10n.yourBirthday,
                  note: l10n.congratulatedYou(name),
                ),
                AddedEntry() => _Row(
                  date: _DateText(e.day, now),
                  icon: KeptIcons.stamp,
                  title: l10n.addedToYourPeople,
                ),
                _ => const SizedBox.shrink(),
              },
          ],
        ),
      ],
    );
  }

  static String? _note(String? note) {
    final t = note?.trim();
    return t == null || t.isEmpty ? null : t;
  }
}

/// "You wrote", "Tom wrote", "You called", "Tom called", "You met", "You
/// gamed together", with " · activity" when there is one. The direction
/// decides who did it for writing and calling; meeting and gaming are
/// always together.
String contactTitle(ContactEvent e, String name, AppLocalizations l10n) {
  final byThem = e.direction == ContactDirection.byThem;
  final what = switch (e.kind) {
    ContactKind.wrote => byThem ? l10n.theyWrote(name) : l10n.youWrote,
    ContactKind.called => byThem ? l10n.theyCalled(name) : l10n.youCalled,
    ContactKind.met => l10n.youMet,
    ContactKind.gamed => l10n.youGamed,
    // Wishes are shown as birthdays, never as contact entries.
    ContactKind.birthdayWish => l10n.youCongratulated,
  };
  final activity = e.activity?.trim();
  return activity == null || activity.isEmpty ? what : '$what · $activity';
}

KeptIcons _contactIcon(ContactKind kind) => switch (kind) {
  ContactKind.wrote => KeptIcons.chat,
  ContactKind.called => KeptIcons.phone,
  ContactKind.met => KeptIcons.people,
  ContactKind.gamed => KeptIcons.controller,
  ContactKind.birthdayWish => KeptIcons.cake,
};

IconData? _arrow(ContactDirection d) => switch (d) {
  ContactDirection.byUser => Icons.north_east_rounded,
  ContactDirection.byThem => Icons.south_west_rounded,
  ContactDirection.together => null,
};

/// The date, or "Today" for the local day of [now].
String _dateLabel(DateTime day, DateTime now, AppLocalizations l10n) =>
    (isToday(day, now)
            ? l10n.timelineToday
            : day.year == now.year
            ? l10n.dateDayMonth(day)
            : l10n.dateDayMonthYear(day))
        .replaceAll('.', '')
        .toUpperCase();

/// "Coming up" and "Today": a small label that sits on the line.
class _Label extends StatelessWidget {
  const _Label(this.text, {this.today = false});

  final String text;
  final bool today;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 70),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        color: kept.ground,
        child: SectionLabel(text, color: today ? kept.text : null),
      ),
    );
  }
}

class _DateText extends StatelessWidget {
  const _DateText(this.day, this.now);

  final DateTime day;
  final DateTime now;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 7),
    child: Text(
      _dateLabel(day, now, context.l10n),
      maxLines: 1,
      style: outfit(
        12,
        FontWeight.w600,
        color: context.kept.muted,
      ).copyWith(letterSpacing: .72),
    ),
  );
}

/// The tilted accent pill of an upcoming date.
class _Pill extends StatelessWidget {
  const _Pill(this.day, this.accent, this.tilt, this.now);

  final DateTime day;
  final Color accent;
  final double tilt;
  final DateTime now;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Transform.rotate(
      angle: tilt * math.pi / 180,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(color: context.kept.shadow, offset: const Offset(0, 2)),
          ],
        ),
        child: Text(
          _dateLabel(day, now, context.l10n),
          maxLines: 1,
          style: outfit(
            12,
            FontWeight.w600,
            color: KeptColors.onAccent,
          ).copyWith(letterSpacing: .72),
        ),
      ),
    ),
  );
}

/// One row: date (right-aligned in 66), the icon on the line, the text.
class _Row extends StatelessWidget {
  const _Row({
    required this.date,
    required this.icon,
    required this.title,
    this.note,
    this.arrow,
    this.onTap,
  });

  final Widget date;
  final KeptIcons icon;
  final String title;
  final String? note;
  final IconData? arrow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        SizedBox(
          width: 66,
          child: Align(alignment: Alignment.topRight, child: date),
        ),
        Container(
          width: 28,
          height: 30,
          color: kept.ground,
          alignment: Alignment.center,
          child: KeptIcon(icon, size: 22),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 4,
                  children: [
                    if (arrow != null) Icon(arrow, size: 16, color: kept.muted),
                    Expanded(
                      child: Text(
                        title,
                        style: context.text.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (note != null)
                  Text(
                    note!,
                    style: context.text.bodyMedium?.copyWith(fontSize: 13),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}
