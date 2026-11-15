import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/database.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/avatar.dart';
import '../widgets/grey_icon_button.dart';
import '../widgets/kept_card.dart';
import '../widgets/main_button.dart';
import '../widgets/section_label.dart';
import '../widgets/tag.dart';
import 'edit_person_screen.dart';

/// One person: the tonal header, the button that opens their chat, and
/// their notes. See concept V6 · One person (docs/concepts/gen_v6.py).
/// Read only for now.
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

class _Body extends StatelessWidget {
  const _Body(this.person);

  final Person person;

  @override
  Widget build(BuildContext context) {
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
                  // Opening chats comes in a later step.
                  onPressed: () => ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(l10n.comingSoon))),
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
            ],
          ),
        ),
      ],
    );
  }
}

/// The tonal header in the tone of the avatar colour, rounded at the
/// bottom only, reaching up under the status bar.
class _Header extends StatelessWidget {
  const _Header(this.person);

  final Person person;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kept = context.kept;
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
                person.name,
                textAlign: TextAlign.center,
                style: context.text.headlineLarge?.copyWith(
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
