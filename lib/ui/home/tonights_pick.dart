import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/app_settings.dart';
import '../../data/database.dart';
import '../../domain/birthdays.dart';
import '../../domain/contact_event.dart';
import '../../domain/ideas.dart';
import '../../domain/intention.dart';
import '../../domain/owed_reply.dart';
import '../../domain/display_name.dart';
import '../../domain/group.dart';
import '../../domain/pick_order.dart';
import '../../domain/reconnect_span.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../people/idea_sheet.dart';
import '../people/couple_screen.dart';
import '../people/person_screen.dart';
import '../widgets/avatar.dart';
import '../widgets/couple_avatar.dart';
import '../widgets/grey_button.dart';
import '../widgets/kept_card.dart';
import '../widgets/main_button.dart';
import '../widgets/section_label.dart';
import '../widgets/tag.dart';
import '../widgets/when_picker.dart';
import 'nice_one_screen.dart';
import 'open_chat.dart';
import 'open_thoughts.dart';
import '../upcoming/entry_style.dart' show thoughtIcon;

/// "Tonight's pick" under the capture card (02-design.md §2.3 and §2.4;
/// concept V6 · Home): one card with "Another one", or three compact
/// cards, depending on the setting `openItems`. The picks come from
/// [tonightsPicks]: today's birthdays not congratulated yet come first,
/// then the owed replies ([owedReplies]), then the reconnect person of the
/// week, then the open thoughts and plans, and last a gentle hint for
/// someone whose rhythm says it has been a while. With nothing to pick,
/// nothing is shown.
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
    final settings = ref.settings;
    final events =
        ref.watch(allContactEventsProvider).value ?? const <ContactEvent>[];
    final week = reconnectState(
      people: people,
      events: events,
      chosenId: settings.reconnectPersonId,
      chosenStart: settings.reconnectStart,
      span: settings.reconnectSpan,
      today: now,
    );
    final picks = tonightsPicks(
      people: people,
      intentions: loaded.value ?? const <Intention>[],
      today: today,
      now: now,
      reconnect: week is ReconnectChosen ? week.person : null,
      events: events,
      classRhythms: settings.classRhythms,
      groupMembers: {
        for (final c in ref.watch(couplesProvider).value ?? const [])
          c.group.id: [for (final p in c.members) p.id],
      },
      // Until the wishes are loaded nobody counts as having a birthday
      // pick, so one already congratulated never shows for a moment.
      congratulated: wishes.hasValue
          ? congratulatedIds(wishes.requireValue, today)
          : {for (final p in people) p.id},
      owed: owedReplies(
        people,
        events,
        now: now,
        waitDays: settings.replyWaitDays,
        listenerOn: ref.watch(incomingBuiltInProvider) && settings.incomingOn,
      ),
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
    final mode = settings.openItems;
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
    final couple = _coupleOf(pick);
    final messenger = person.chatApp;
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
                  if (couple != null)
                    CoupleAvatar(couple, size: 60, ringColor: kept.surface)
                  else
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
                                _pickName(
                                  pick,
                                  ref.watch(displayNamesProvider),
                                ),
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
                          couple != null
                              ? closenessLabel(coupleClass(couple), l10n)
                              : [
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
                    if (pick is PlanPick)
                      Text(
                        l10n.wantSetDate(
                          _pickName(pick, ref.watch(displayNamesProvider)),
                        ),
                        style: context.text.labelLarge?.copyWith(
                          color: kept.text,
                        ),
                      ),
                    Text(
                      _pickText(
                        pick,
                        l10n,
                        ref.settings.reconnectSpan,
                        ref.watch(displayNamesProvider),
                      ),
                      style: context.text.bodyLarge?.copyWith(color: kept.text),
                    ),
                    WhenLineOf(pick),
                    if (couple == null) ...[
                      LastTimeLine(person.id),
                      IdeaLine(pick),
                    ],
                  ],
                ),
              ),
              if (couple != null && anyHasMessenger(couple))
                MainButton(
                  label: l10n.coupleOpenChat,
                  icon: KeptIcons.chat,
                  onPressed: () => _openChat(context, ref, pick),
                )
              else if (couple == null && messenger != null)
                MainButton(
                  label: l10n.openMessenger(messengerLabel(messenger, l10n)),
                  icon: messengerIcon(messenger),
                  onPressed: () => _openChat(context, ref, pick),
                ),
              if (pick is PlanPick)
                GreyButton(
                  label: l10n.setADate,
                  onPressed: () => _setDate(context, ref, pick),
                ),
              // A hint has nothing to tick off: no Done.
              if (pick is! HintPick || onAnother != null)
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
                      if (pick is! HintPick)
                        Expanded(
                          child: GreyButton(
                            label: _completeLabel(pick, l10n),
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
    final pick = this.pick;
    final l10n = context.l10n;
    final person = pick.person;
    final couple = _coupleOf(pick);
    final messenger = person.chatApp;
    return KeptCard(
      small: true,
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => pick is IntentionPick && couple != null
              ? CoupleScreen(id: pick.intention.groupId!)
              : PersonScreen(id: person.id),
        ),
      ),
      child: Row(
        spacing: 12,
        children: [
          if (couple != null)
            CoupleAvatar(couple, size: 44, ringColor: context.kept.surface)
          else
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
                        _pickName(pick, ref.watch(displayNamesProvider)),
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
                  pick is PlanPick
                      ? l10n.wantSetDate(
                          _pickName(pick, ref.watch(displayNamesProvider)),
                        )
                      : _pickText(
                          pick,
                          l10n,
                          ref.settings.reconnectSpan,
                          ref.watch(displayNamesProvider),
                        ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium,
                ),
                if (pick is PlanPick)
                  Text(
                    _pickText(
                      pick,
                      l10n,
                      ref.settings.reconnectSpan,
                      ref.watch(displayNamesProvider),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(
                      color: context.kept.muted,
                    ),
                  ),
                if (couple == null) LastTimeLine(person.id),
              ],
            ),
          ),
          if (couple != null && anyHasMessenger(couple))
            _SquareButton(
              size: 48,
              coral: true,
              tooltip: l10n.coupleOpenChat,
              icon: KeptIcons.chat,
              onPressed: () => _openChat(context, ref, pick),
            )
          else if (couple == null && messenger != null)
            _SquareButton(
              size: 48,
              coral: true,
              tooltip: l10n.openMessenger(messengerLabel(messenger, l10n)),
              icon: messengerIcon(messenger),
              onPressed: () => _openChat(context, ref, pick),
            ),
          if (pick is PlanPick)
            _SquareButton(
              size: 48,
              tooltip: l10n.setADate,
              icon: KeptIcons.calendar,
              onPressed: () => _setDate(context, ref, pick),
            ),
          if (pick is! HintPick)
            _SquareButton(
              size: 48,
              tooltip: _completeLabel(pick, l10n),
              icon: KeptIcons.check,
              onPressed: () => _complete(context, ref, pick),
            ),
        ],
      ),
    );
  }
}

/// The name on a pick: the person's short name, or for a couple's thought
/// the members' short names joined with " & ". [names] are
/// `displayNamesProvider`.
String _pickName(Pick pick, Map<String, String> names) => switch (pick) {
  IntentionPick(:final members) when members.length > 1 =>
    members.map((p) => shortNameIn(names, p)).join(' & '),
  _ => shortNameIn(names, pick.person),
};

/// The members of a couple's pick; null for everything else.
List<Person>? _coupleOf(Pick pick) =>
    pick is IntentionPick && pick.members.length > 1 ? pick.members : null;

/// The icon next to the name: the cake for a birthday, the chat bubble for
/// an owed reply, else the kind.
KeptIcons _pickIcon(Pick pick) => switch (pick) {
  BirthdayPick() => KeptIcons.cake,
  ReplyPick() => KeptIcons.chat,
  ReconnectPick() => KeptIcons.people,
  HintPick() => KeptIcons.leaf,
  IntentionPick(:final intention) => thoughtIcon(intention),
};

/// The line under the name: the birthday with the age if known, the
/// question about an owed reply, or the thought (its kind when it has no
/// text).
String _pickText(
  Pick pick,
  AppLocalizations l10n,
  ReconnectSpan span,
  Map<String, String> names,
) => switch (pick) {
  BirthdayPick(:final age?) => l10n.birthdayTurns(age),
  BirthdayPick() => l10n.birthdayToday,
  ReplyPick(:final person) => l10n.stillOweReply(shortNameIn(names, person)),
  ReconnectPick(:final person) => reconnectTitle(
    span,
    shortNameIn(names, person),
    l10n,
  ),
  HintPick(:final person) => l10n.hintPick(shortNameIn(names, person)),
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
      // Opening the chat also clears the owed reply (openChat).
      ReplyPick(:final person) => openChat(context, ref, person),
      ReconnectPick(:final person) => openChat(context, ref, person),
      HintPick(:final person) => openChat(context, ref, person),
      IntentionPick(:final members, :final intention) when members.length > 1 =>
        openCoupleChat(context, ref, members, intention: intention),
      IntentionPick(:final person, :final intention) => openChat(
        context,
        ref,
        person,
        intention: intention,
      ),
    });

/// "Set a date" on a due plan: the date picker, then the date is stored
/// and the plan leaves the picks.
Future<void> _setDate(
  BuildContext context,
  WidgetRef ref,
  PlanPick pick,
) async {
  final day = await pickDay(context, ref);
  if (day == null) return;
  await ref
      .read(intentionsRepositoryProvider)
      .setWhen(pick.intention.id, When.date(day));
}

/// The "when" line of the thought in a pick, if it has one (a due plan
/// shows "Soon" or "Later").
class WhenLineOf extends StatelessWidget {
  const WhenLineOf(this.pick, {super.key});

  final Pick pick;

  @override
  Widget build(BuildContext context) => switch (pick) {
    IntentionPick(:final intention) => WhenLine(intention),
    _ => const SizedBox.shrink(),
  };
}

/// One calm line with an idea that helps with [pick]: "Idea:
/// bouldering hall in Altona" ([ideaForPick]). Nothing when there is none.
class IdeaLine extends ConsumerWidget {
  const IdeaLine(this.pick, {super.key});

  final Pick pick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ideaKindFor(pick) == null) return const SizedBox.shrink();
    final ideas =
        ref.watch(personIdeasProvider(pick.person.id)).value ?? const [];
    final idea = ideaForPick(pick, ideas);
    if (idea == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Text(
      l10n.ideaOnPick(ideaText(idea, l10n)),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: context.text.bodyMedium?.copyWith(color: context.kept.muted),
    );
  }
}

/// The label of the last button: "Congratulated" on a birthday pick,
/// "Already answered" on an owed reply, "Done" on a thought.
String _completeLabel(Pick pick, AppLocalizations l10n) => switch (pick) {
  BirthdayPick() => l10n.congratulated,
  ReplyPick() => l10n.alreadyAnswered,
  ReconnectPick() || HintPick() => l10n.done,
  IntentionPick() => l10n.done,
};

/// "Congratulated" on a birthday pick, "Done" on a thought or the
/// reconnect pick (a manual `wrote` contact). "Already
/// answered" on an owed reply only notes the time (`replyClearedAt`) and
/// stores nothing else (02-design.md §2.6).
void _complete(BuildContext context, WidgetRef ref, Pick pick) =>
    unawaited(switch (pick) {
      BirthdayPick(:final person) => completeBirthday(context, ref, person),
      ReplyPick(:final person) =>
        ref
            .read(peopleRepositoryProvider)
            .setReplyClearedAt(person.id, ref.read(clockProvider)()),
      // Done on the reconnect pick: the user got in touch.
      ReconnectPick(:final person) => completeWrite(
        context,
        ref,
        person,
        source: ContactSource.manual,
      ),
      HintPick() => Future<void>.value(),
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
