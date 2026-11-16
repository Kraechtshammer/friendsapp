import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/database.dart';
import '../../domain/intention.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/avatar.dart';
import '../home/nice_one_screen.dart';
import '../home/open_chat.dart';
import '../home/open_thoughts.dart';
import '../home/thought_sheet.dart';
import '../kept_icon.dart';
import '../widgets/grey_button.dart';
import '../widgets/grey_icon_button.dart';
import '../widgets/kept_card.dart';
import '../widgets/link_row.dart';
import '../widgets/main_button.dart';
import '../widgets/section_label.dart';
import '../widgets/tag.dart';
import 'edit_person_screen.dart';
import 'ideas_section.dart';
import 'incoming_buttons.dart';
import 'person_timeline_view.dart';

/// One person: the tonal header, the button that opens their chat, their
/// notes, open thoughts and ideas, then the friend timeline with the "They wrote" and "They
/// called" buttons. The page scrolls as one. See concept V6 · One person
/// (docs/concepts/gen_v6.py).
class PersonScreen extends ConsumerWidget {
  const PersonScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final person = ref.watch(personProvider(id));
    final dark = Theme.of(context).brightness == Brightness.dark;
    // The header runs under the status bar, so the bar is see-through.
    final overlay =
        (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(statusBarColor: Colors.transparent);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        body: switch (person) {
          AsyncValue(value: final p?) => _Body(p),
          AsyncValue(hasError: true) => Center(
            child: Text(
              context.l10n.personError,
              style: context.text.bodyMedium,
            ),
          ),
          // Loading, or deleted a moment ago.
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body(this.person);

  final Person person;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final messenger = person.mainMessenger;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _Header(person),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              if (messenger != null)
                MainButton(
                  label: l10n.openMessenger(messengerLabel(messenger, l10n)),
                  icon: messengerIcon(messenger),
                  onPressed: () => openChat(context, ref, person),
                ),
              if (person.notes.trim().isNotEmpty)
                KeptCard(
                  small: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      SectionLabel(l10n.notes),
                      Text(person.notes, style: context.text.bodyLarge),
                    ],
                  ),
                ),
              _OpenIntentions(person),
              IdeasSection(person),
              IncomingButtons(person),
              PersonTimelineView(person),
            ],
          ),
        ),
      ],
    );
  }
}

/// This person's open intentions, each with Done and Drop (02-design.md
/// §2.3), and the open thoughts of the couple they are in, marked "with
/// Tom". Tapping one opens the edit sheet. Nothing is shown as late.
class _OpenIntentions extends ConsumerWidget {
  const _OpenIntentions(this.person);

  final Person person;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(personThoughtsProvider(person.id));
    final partner = ref
        .watch(personCoupleProvider(person.id))
        .value
        ?.members
        .where((p) => p.id != person.id)
        .firstOrNull;
    return OpenIntentionCards(person, [
      for (final i in all)
        if (i.state == IntentionState.open) i,
    ], withName: partner == null ? null : ref.shortName(partner));
  }
}

/// The cards of open thoughts with Done and Drop, under "On your mind";
/// nothing when [open] is empty. [person] is who Done is for (for a
/// couple's thought the first member is enough). A couple's thought shows
/// "with [withName]" when that is given; the couple page leaves it out. The
/// last contact line shows only for one person's thoughts.
class OpenIntentionCards extends ConsumerWidget {
  const OpenIntentionCards(this.person, this.open, {super.key, this.withName});

  final Person person;
  final List<Intention> open;
  final String? withName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (open.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    final repo = ref.read(intentionsRepositoryProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        const SizedBox(height: 4),
        SectionLabel(l10n.onYourMind),
        for (final i in open)
          KeptCard(
            small: true,
            padding: const EdgeInsets.all(12),
            onTap: () => showThoughtSheet(context, ref, person, i),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    KeptIcon(kindIcon(i.kind), size: 22),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Text(
                            i.note.trim().isEmpty
                                ? kindLabel(i.kind, l10n)
                                : i.note.trim(),
                            style: context.text.bodyLarge,
                          ),
                          WhenLine(i),
                          if (i.groupId != null && withName != null)
                            Text(
                              l10n.coupleWith(withName!),
                              style: context.text.bodySmall?.copyWith(
                                color: context.kept.muted,
                              ),
                            ),
                          if (i.groupId == null) LastTimeLine(person.id),
                        ],
                      ),
                    ),
                    if (i.link != null) const LinkMark(),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 10,
                  children: [
                    GreyButton(
                      small: true,
                      label: l10n.done,
                      onPressed: () => completeThought(context, ref, person, i),
                    ),
                    GreyButton(
                      small: true,
                      label: l10n.drop,
                      onPressed: () =>
                          repo.setState(i.id, IntentionState.dropped),
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

/// The tonal header in the tone of the avatar colour, rounded at the
/// bottom only, reaching up under the status bar.
class _Header extends ConsumerWidget {
  const _Header(this.person);

  final Person person;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final kept = context.kept;
    final shortName = ref.shortName(person);
    final tone = person.avatarColor.tone(kept);
    final messenger = person.mainMessenger;
    final month = person.birthdayMonth, day = person.birthdayDay;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.paddingOf(context).top + 16,
        16,
        18,
      ),
      decoration: BoxDecoration(
        color: tone.container,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [BoxShadow(color: kept.shadow, offset: const Offset(0, 5))],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Center(child: Avatar.person(person, size: 84)),
              Text(
                shortName,
                textAlign: TextAlign.center,
                style: context.text.headlineLarge?.copyWith(
                  color: tone.onContainer,
                ),
              ),
              // The full name small under it, when it says more.
              if (shortName != person.name.trim())
                Text(
                  person.name,
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium?.copyWith(
                    color: tone.onContainer,
                  ),
                ),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 10,
                children: [
                  Tag(
                    closenessLabel(person.closeness, l10n),
                    accent: KeptColors.sun,
                    tilt: -2,
                  ),
                  if (person.reconnecting)
                    Tag(l10n.reconnecting, accent: KeptColors.lilac, tilt: 2),
                  if (messenger != null) Tag(messengerLabel(messenger, l10n)),
                  if (month != null && day != null)
                    Tag(
                      birthdayLabel(month, day, person.birthdayYear, l10n),
                      accent: KeptColors.pink,
                      tilt: 2,
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 0,
            top: 0,
            // The concept's smaller back button: 44, radius 16.
            child: GreyIconButton(
              icon: Icons.arrow_back_rounded,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              size: 44,
              radius: 16,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: GreyIconButton(
              icon: Icons.edit_rounded,
              tooltip: l10n.edit,
              size: 44,
              radius: 16,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => EditPersonScreen(id: person.id),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
