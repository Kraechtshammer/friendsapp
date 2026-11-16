import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/chat_link.dart';
import '../../domain/chat_question.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../widgets/avatar.dart';

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

/// Whether anyone of [members] has a main messenger, so "Open chat" on a
/// couple's thought can do something.
bool anyHasMessenger(List<Person> members) =>
    members.any((p) => p.mainMessenger != null);

/// "Open chat" on a couple's thought: asks which of the two to write to
/// (a small sheet with both faces and their messenger), then goes the
/// normal way ([openChat]) with that person and the couple's [intention].
/// The "Did you write to ...?" question that follows is about that person.
Future<void> openCoupleChat(
  BuildContext context,
  WidgetRef ref,
  List<Person> members, {
  required Intention intention,
}) async {
  final chosen = await showModalBottomSheet<Person>(
    context: context,
    showDragHandle: true,
    backgroundColor: context.kept.surface,
    builder: (_) => _WhoSheet(members),
  );
  if (chosen == null || !context.mounted) return;
  await openChat(context, ref, chosen, intention: intention);
}

/// The two people with their messenger; one without a messenger is shown
/// but cannot be chosen.
class _WhoSheet extends ConsumerWidget {
  const _WhoSheet(this.members);

  final List<Person> members;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Text(
              l10n.coupleChatWho,
              style: context.text.titleLarge?.copyWith(
                color: context.kept.text,
              ),
            ),
            for (final p in members)
              Opacity(
                opacity: p.mainMessenger == null ? .5 : 1,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  leading: Avatar.person(p, size: 44),
                  title: Text(
                    ref.shortName(p),
                    style: context.text.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    p.mainMessenger == null
                        ? l10n.messengerNone
                        : messengerLabel(p.mainMessenger!, l10n),
                  ),
                  trailing: p.mainMessenger == null
                      ? null
                      : KeptIcon(messengerIcon(p.mainMessenger!), size: 28),
                  onTap: p.mainMessenger == null
                      ? null
                      : () => Navigator.of(context).pop(p),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
