import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/chat_question.dart';
import '../../domain/contact_event.dart';
import '../../domain/intention.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/avatar.dart';
import '../widgets/couple_avatar.dart';
import '../widgets/grey_button.dart';
import '../widgets/main_button.dart';
import 'nice_one_screen.dart';

/// "Did you write to Tom?" after the user comes back from a messenger. See
/// concept V6 · Back from the chat (docs/concepts/gen_v6.py).
///
/// After a birthday pick it asks "Did you congratulate Tom?" and Yes
/// stores a confirmed birthday wish.
///
/// Yes stores a confirmed contact and shows the Nice one screen in its
/// place. Not yet closes the screen and stores nothing; the thought, if
/// there is one, stays open and nothing becomes overdue.
class ChatQuestionScreen extends ConsumerWidget {
  const ChatQuestionScreen(this.question, {super.key});

  final ChatQuestion question;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final person = question.person;
    final intention = question.intention;
    final names = ref.watch(displayNamesProvider);
    // A couple's thought: meeting or gaming is about both of them, writing
    // or calling about the one the chat was opened with.
    final couple = intention?.groupId == null
        ? null
        : ref.watch(couplesByIdProvider)[intention!.groupId];
    final together =
        intention?.groupId != null &&
        (intention!.kind == IntentionKind.meet ||
            intention.kind == IntentionKind.game);
    final name = together && couple != null
        ? couple.label(names)
        : ref.shortName(person);
    final title = question.birthday
        ? l10n.chatQuestionBirthday(name)
        : switch (intention?.kind ?? IntentionKind.write) {
            IntentionKind.write => l10n.chatQuestionWrite(name),
            IntentionKind.call => l10n.chatQuestionCall(name),
            IntentionKind.meet => l10n.chatQuestionMeet(name),
            IntentionKind.game => l10n.chatQuestionGame(name),
          };
    final messenger = person.chatApp;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 18,
              children: [
                Column(
                  spacing: 10,
                  children: [
                    if (together && couple != null)
                      CoupleAvatar(couple.members, size: 112)
                    else
                      Avatar.person(person, size: 96),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: context.text.headlineLarge,
                    ),
                    if (messenger != null)
                      Text(
                        l10n.chatQuestionOpened(
                          messengerLabel(messenger, l10n),
                        ),
                        textAlign: TextAlign.center,
                        style: context.text.bodyMedium,
                      ),
                  ],
                ),
                MainButton(
                  label: l10n.chatQuestionYes,
                  onPressed: () => question.birthday
                      ? completeBirthday(
                          context,
                          ref,
                          person,
                          source: ContactSource.confirmed,
                          replace: true,
                        )
                      : intention == null
                      ? completeWrite(context, ref, person, replace: true)
                      : completeThought(
                          context,
                          ref,
                          person,
                          intention,
                          source: ContactSource.confirmed,
                          replace: true,
                          // Writing or calling one of the two stores the
                          // contact for that person only.
                          only: intention.groupId != null && !together
                              ? person
                              : null,
                        ),
                ),
                GreyButton(
                  label: l10n.chatQuestionNotYet,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                Text(
                  l10n.chatQuestionHint,
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
