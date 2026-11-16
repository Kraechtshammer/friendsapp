import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/person_name.dart';
import '../../domain/reconnect_week.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/avatar.dart';
import '../widgets/grey_button.dart';
import '../widgets/kept_card.dart';
import '../widgets/main_button.dart';

/// "You and NAME are back in touch." (02-design.md §2.4, F13): once a
/// person in the "getting back in touch" state has had a first exchange
/// ([backInTouch]), Home asks once, one person at a time. "Keep as getting
/// back in touch" leaves the state on; "Done" switches `reconnecting` off,
/// the class stays. Either way the answer is stored in the settings
/// (`backInTouchAnswered`), so the card does not come back.
class BackInTouchCard extends ConsumerWidget {
  const BackInTouchCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(peopleProvider).value ?? const <Person>[];
    final events =
        ref.watch(allContactEventsProvider).value ?? const <ContactEvent>[];
    final now = ref.watch(clockProvider)();
    final asked = backInTouch(
      people,
      events,
      ref.settings.backInTouchAnswered,
      now,
    );
    if (asked.isEmpty) return const SizedBox.shrink();
    final person = asked.first;
    final l10n = context.l10n;
    final tone = context.kept.mintTone;

    Future<void> answer({required bool done}) async {
      final people = ref.read(peopleRepositoryProvider);
      await ref.services.settings.update(
        (s) => s.copyWith(
          backInTouchAnswered: {...s.backInTouchAnswered, person.id},
        ),
      );
      if (done) await people.setReconnecting(person.id, false);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: KeptCard(
        tone: tone,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Row(
              spacing: 14,
              children: [
                Avatar.person(person, size: 48),
                Expanded(
                  child: Text(
                    l10n.backInTouchTitle(firstNameOf(person.name)),
                    style: context.text.titleLarge?.copyWith(
                      color: tone.onContainer,
                    ),
                  ),
                ),
              ],
            ),
            GreyButton(
              label: l10n.backInTouchKeep,
              onPressed: () => unawaited(answer(done: false)),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: MainButton(
                label: l10n.done,
                onPressed: () => unawaited(answer(done: true)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
