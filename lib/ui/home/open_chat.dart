import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/chat_link.dart';
import '../../domain/chat_question.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../material.dart';

/// "Open" with the person's messenger for [person]: opens their main messenger and queues
/// the "Did you write?" question for when the user is back in the app
/// ([pendingChatQuestionProvider]). [intention] is the thought the chat is
/// for, if any; [birthday] says it was opened to congratulate. If the messenger does not open, nothing is queued and a
/// note says so. Does nothing for a person without a main messenger.
///
/// Once the chat is open, an owed reply to [person] counts as dealt with
/// (`replyClearedAt`, 02-design.md §2.6).
Future<void> openChat(
  BuildContext context,
  WidgetRef ref,
  Person person, {
  Intention? intention,
  bool birthday = false,
}) async {
  final link = chatLink(person);
  if (link == null) return;
  final l10n = context.l10n;
  final name = messengerLabel(person.mainMessenger!, l10n);
  final messenger = ScaffoldMessenger.of(context);
  final pending = ref.read(pendingChatQuestionProvider.notifier);
  final people = ref.read(peopleRepositoryProvider);
  final now = ref.read(clockProvider)();
  // Queued before opening, so a quick return cannot beat it.
  pending.set(ChatQuestion(person, intention: intention, birthday: birthday));
  final opened = await ref.read(chatOpenerProvider).open(link);
  if (!opened) {
    pending.take();
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.messengerNotOpened(name))),
    );
    return;
  }
  try {
    await people.setReplyClearedAt(person.id, now);
  } catch (e) {
    debugPrint('Owed reply not cleared: ${e.runtimeType}');
  }
}
