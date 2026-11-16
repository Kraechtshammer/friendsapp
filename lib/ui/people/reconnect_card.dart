import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/database.dart';
import '../../domain/person_name.dart';
import '../../domain/reconnect_span.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../home/open_chat.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../widgets/avatar.dart';
import '../widgets/grey_button.dart';
import '../widgets/kept_card.dart';
import '../widgets/main_button.dart';
import '../widgets/tag.dart';

/// The reconnect person for the span the user set, at the top of the People
/// tab (F13; concept V6 · People, docs/concepts/gen_v6.py). Four states
/// ([reconnectState]): nothing (no card), "Who do you want to get back in
/// touch with now?" with the people in the state to tap, "This month: NAME"
/// (the words follow the span) with the messenger button, and a calm done
/// state once the user has been in touch during the span. When the span is
/// over the card asks again; nothing is said about the last one.
class ReconnectCard extends ConsumerWidget {
  const ReconnectCard(this.people, {super.key});

  final List<Person> people;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.settings;
    final now = ref.watch(clockProvider)();
    final events =
        ref.watch(allContactEventsProvider).value ?? const <ContactEvent>[];
    final state = reconnectState(
      people: people,
      events: events,
      chosenId: settings.reconnectPersonId,
      chosenStart: settings.reconnectStart,
      span: settings.reconnectSpan,
      today: now,
    );
    final today = DateTime(now.year, now.month, now.day);
    final card = switch (state) {
      ReconnectNone() => null,
      ReconnectChoose(:final candidates, :final suggested) => _Choose(
        candidates,
        suggested,
        onChoose: (p) => unawaited(
          ref.services.settings.update((s) => s.withReconnect(p.id, today)),
        ),
      ),
      ReconnectChosen(:final person) => _Chosen(
        person,
        span: settings.reconnectSpan,
        onChange: () => unawaited(
          ref.services.settings.update((s) => s.withReconnect(null, null)),
        ),
      ),
      ReconnectDone(:final person) => _Done(person),
    };
    // Room for the tag over the top edge, and a gap to the groups.
    return card == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 18),
            child: card,
          );
  }
}

/// The card with the tag "Getting back in touch" tilted over its top edge.
class _TaggedCard extends StatelessWidget {
  const _TaggedCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      KeptCard(
        tone: context.kept.lilacTone,
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: child,
      ),
      Positioned(
        left: 12,
        top: -13,
        child: Tag(
          context.l10n.reconnecting,
          accent: KeptColors.lilac,
          tilt: -2,
        ),
      ),
    ],
  );
}

class _Choose extends StatelessWidget {
  const _Choose(this.candidates, this.suggested, {required this.onChoose});

  final List<Person> candidates;
  final Person suggested;
  final ValueChanged<Person> onChoose;

  @override
  Widget build(BuildContext context) {
    final tone = context.kept.lilacTone;
    return _TaggedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 14,
        children: [
          Text(
            context.l10n.reconnectChoose,
            style: context.text.titleLarge?.copyWith(color: tone.onContainer),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in candidates)
                _Candidate(
                  p,
                  highlighted: p.id == suggested.id,
                  onTap: () => onChoose(p),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Avatar over first name. The suggested one sits on a soft plate.
class _Candidate extends StatelessWidget {
  const _Candidate(
    this.person, {
    required this.highlighted,
    required this.onTap,
  });

  final Person person;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tone = context.kept.lilacTone;
    return Semantics(
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: highlighted
                ? tone.onContainer.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 54, maxWidth: 76),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                Avatar.person(person, size: 54),
                Text(
                  firstNameOf(person.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: tone.onContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chosen extends ConsumerWidget {
  const _Chosen(this.person, {required this.span, required this.onChange});

  final Person person;
  final ReconnectSpan span;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tone = context.kept.lilacTone;
    final messenger = person.mainMessenger;
    return _TaggedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            spacing: 14,
            children: [
              Avatar.person(person, size: 56),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reconnectTitle(span, firstNameOf(person.name), l10n),
                      style: context.text.titleLarge?.copyWith(
                        color: tone.onContainer,
                      ),
                    ),
                    Text(
                      l10n.reconnectCardHint,
                      style: context.text.bodyMedium?.copyWith(
                        color: tone.onContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Stacked, not side by side as in the concept: at phone width the
          // two labels do not fit in one row, in German even less.
          if (messenger != null)
            MainButton(
              label: l10n.openMessenger(messengerLabel(messenger, l10n)),
              icon: messengerIcon(messenger),
              onPressed: () => unawaited(openChat(context, ref, person)),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: GreyButton(label: l10n.someoneElse, onPressed: onChange),
          ),
        ],
      ),
    );
  }
}

/// The calm state: the user got in touch in the current span. No buttons.
class _Done extends StatelessWidget {
  const _Done(this.person);

  final Person person;

  @override
  Widget build(BuildContext context) {
    final tone = context.kept.mintTone;
    return KeptCard(
      tone: tone,
      small: true,
      child: Row(
        spacing: 12,
        children: [
          const KeptIcon(KeptIcons.check, size: 32),
          Expanded(
            child: Text(
              context.l10n.reconnectDone(firstNameOf(person.name)),
              style: context.text.bodyLarge?.copyWith(color: tone.onContainer),
            ),
          ),
        ],
      ),
    );
  }
}
