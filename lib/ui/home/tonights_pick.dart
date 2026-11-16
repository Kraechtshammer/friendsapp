import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/app_settings.dart';
import '../../data/database.dart';
import '../../domain/birthdays.dart';
import '../../domain/contact_event.dart';
import '../../domain/person_name.dart';
import '../../domain/pick_order.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../people/person_screen.dart';
import '../widgets/avatar.dart';
import '../widgets/grey_button.dart';
import '../widgets/kept_card.dart';
import '../widgets/main_button.dart';
import '../widgets/section_label.dart';
import '../widgets/tag.dart';
import 'nice_one_screen.dart';
import 'open_chat.dart';
import 'open_thoughts.dart';

/// "Tonight's pick" under the capture card (02-design.md §2.3 and §2.4;
/// concept V6 · Home): one card with "Another one", or three compact
/// cards, depending on the setting `openItems`. The picks come from
/// [tonightsPicks]: today's birthdays not congratulated yet come first,
/// then the open thoughts. With nothing to pick, nothing is shown.
///
/// "Yes" on the evening question scrolls Home here
/// ([openThoughtsRequestProvider]). If the thoughts are still loading, the
/// scroll waits for them.
class TonightsPick extends ConsumerStatefulWidget {
  const TonightsPick({super.key});

  @override
  ConsumerState<TonightsPick> createState() => _TonightsPickState();
}

class _TonightsPickState extends ConsumerState<TonightsPick> {
  var _scrollPending = false;

  /// Which pick the one-item card shows; "Another one" moves it on.
  var _index = 0;

  @override
  void initState() {
    super.initState();
    // A request made before this was built (a cold start from the
    // notification) counts too.
    _scrollPending = ref.read(openThoughtsRequestProvider) > 0;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(openThoughtsRequestProvider, (_, _) {
      setState(() => _scrollPending = true);
    });
    final loaded = ref.watch(openIntentionsProvider);
    final now = ref.watch(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final wishes = ref.watch(
      birthdayWishesProvider((ContactDirection.byUser, today)),
    );
    final people = ref.watch(peopleProvider).value ?? const <Person>[];
    final picks = tonightsPicks(
      people: people,
      intentions: loaded.value ?? const <Intention>[],
      today: today,
      // Until the wishes are loaded nobody counts as having a birthday
      // pick, so one already congratulated never shows for a moment.
      congratulated: wishes.hasValue
          ? congratulatedIds(wishes.requireValue, today)
          : {for (final p in people) p.id},
    );
    if (_scrollPending && picks.isNotEmpty) {
      _scrollPending = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      });
    } else if (_scrollPending && loaded.hasValue && picks.isEmpty) {
      // Nothing to show: don't jump later when a thought is added.
      _scrollPending = false;
    }
    if (picks.isEmpty) return const SizedBox.shrink();
    final mode = ref.settings.openItems;
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: switch (mode) {
        OpenItemsMode.one => _PickCard(
          picks[_index % picks.length],
          onAnother: picks.length > 1
              ? () => setState(() => _index = (_index + 1) % picks.length)
              : null,
        ),
        OpenItemsMode.three => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            SectionLabel(context.l10n.tonightsPick),
            for (final pick in picks.take(3)) _CompactPick(pick),
          ],
        ),
      },
    );
  }
}

/// The one-item card: person, thought (or birthday), last time, and the
/// three buttons. For a birthday "Done" is "Congratulated".
class _PickCard extends ConsumerWidget {
  const _PickCard(this.pick, {required this.onAnother});

  final Pick pick;

  /// Null when there is only one pick: the button is not shown.
  final VoidCallback? onAnother;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final kept = context.kept;
    final pick = this.pick;
    final person = pick.person;
    final messenger = person.mainMessenger;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        KeptCard(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Row(
                spacing: 14,
                children: [
                  Avatar.person(person, size: 60, classBadge: true),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: 8,
                          children: [
                            Flexible(
                              child: Text(
                                firstNameOf(person.name),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.titleLarge?.copyWith(
                                  color: kept.text,
                                ),
                              ),
                            ),
                            KeptIcon(_pickIcon(pick), size: 22),
                          ],
                        ),
                        Text(
                          [
                            closenessLabel(person.closeness, l10n),
                            ?(messenger == null
                                ? null
                                : messengerLabel(messenger, l10n)),
                          ].join(' · '),
                          style: context.text.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: kept.surfaceHigh,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      _pickText(pick, l10n),
                      style: context.text.bodyLarge?.copyWith(color: kept.text),
                    ),
                    LastTimeLine(person.id),
                  ],
                ),
              ),
              if (messenger != null)
                MainButton(
                  label: l10n.openMessenger(messengerLabel(messenger, l10n)),
                  icon: messengerIcon(messenger),
                  onPressed: () => _openChat(context, ref, pick),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  spacing: 12,
                  children: [
                    if (onAnother != null)
                      Expanded(
                        child: GreyButton(
                          label: l10n.anotherOne,
                          onPressed: onAnother,
                        ),
                      ),
                    Expanded(
                      child: GreyButton(
                        label: pick is BirthdayPick
                            ? l10n.congratulated
                            : l10n.done,
                        onPressed: () => _complete(context, ref, pick),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 12,
          top: -13,
          child: Tag(l10n.tonightsPick, accent: KeptColors.coral, tilt: -3),
        ),
      ],
    );
  }
}

/// One of three: a list row with the messenger as a coral square and Done.
class _CompactPick extends ConsumerWidget {
  const _CompactPick(this.pick);

  final Pick pick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final person = pick.person;
    final messenger = person.mainMessenger;
    return KeptCard(
      small: true,
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => PersonScreen(id: person.id)),
      ),
      child: Row(
        spacing: 12,
        children: [
          Avatar.person(person, size: 44, classBadge: true),
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
                        firstNameOf(person.name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.labelLarge?.copyWith(
                          color: context.kept.text,
                        ),
                      ),
                    ),
                    KeptIcon(_pickIcon(pick), size: 22),
                  ],
                ),
                Text(
                  _pickText(pick, l10n),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium,
                ),
                LastTimeLine(person.id),
              ],
            ),
          ),
          if (messenger != null)
            _SquareButton(
              size: 48,
              coral: true,
              tooltip: l10n.openMessenger(messengerLabel(messenger, l10n)),
              icon: messengerIcon(messenger),
              onPressed: () => _openChat(context, ref, pick),
            ),
          _SquareButton(
            size: 48,
            tooltip: pick is BirthdayPick ? l10n.congratulated : l10n.done,
            icon: KeptIcons.check,
            onPressed: () => _complete(context, ref, pick),
          ),
        ],
      ),
    );
  }
}

/// The icon next to the name: the cake for a birthday, else the kind.
KeptIcons _pickIcon(Pick pick) => switch (pick) {
  BirthdayPick() => KeptIcons.cake,
  IntentionPick(:final intention) => kindIcon(intention.kind),
};

/// The line under the name: the birthday with the age if known, or the
/// thought (its kind when it has no text).
String _pickText(Pick pick, AppLocalizations l10n) => switch (pick) {
  BirthdayPick(:final age?) => l10n.birthdayTurns(age),
  BirthdayPick() => l10n.birthdayToday,
  IntentionPick(:final intention) =>
    intention.note.trim().isEmpty
        ? kindLabel(intention.kind, l10n)
        : intention.note.trim(),
};

void _openChat(BuildContext context, WidgetRef ref, Pick pick) =>
    unawaited(switch (pick) {
      BirthdayPick(:final person) => openChat(
        context,
        ref,
        person,
        birthday: true,
      ),
      IntentionPick(:final person, :final intention) => openChat(
        context,
        ref,
        person,
        intention: intention,
      ),
    });

/// "Congratulated" on a birthday pick, "Done" on a thought.
void _complete(BuildContext context, WidgetRef ref, Pick pick) =>
    unawaited(switch (pick) {
      BirthdayPick(:final person) => completeBirthday(context, ref, person),
      IntentionPick(:final person, :final intention) => completeThought(
        context,
        ref,
        person,
        intention,
      ),
    });

/// A rounded square with a colourful icon (ui-style.md §6): grey, or coral
/// for opening the chat. Hard shadow 4 in the edge colour. [tooltip] is
/// also the screen reader label.
class _SquareButton extends StatelessWidget {
  const _SquareButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.size = 52,
    this.coral = false,
  });

  final String tooltip;
  final KeptIcons icon;
  final VoidCallback? onPressed;
  final double size;
  final bool coral;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    final shape = BorderRadius.circular(18);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: [
          BoxShadow(
            color: coral ? KeptColors.coralEdge : kept.greyEdge,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: coral ? KeptColors.coral : kept.surfaceHigh,
        borderRadius: shape,
        child: InkWell(
          borderRadius: shape,
          onTap: onPressed,
          child: Tooltip(
            message: tooltip,
            child: SizedBox.square(
              dimension: size,
              child: Center(child: KeptIcon(icon, size: coral ? 26 : 28)),
            ),
          ),
        ),
      ),
    );
  }
}
