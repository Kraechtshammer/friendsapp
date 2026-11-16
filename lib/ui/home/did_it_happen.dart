import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/contact_event.dart';
import '../../domain/person_name.dart';
import '../../domain/plans.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../material.dart';
import '../upcoming/entry_style.dart';
import '../widgets/grey_button.dart';
import '../widgets/kept_card.dart';
import '../widgets/main_button.dart';
import 'nice_one_screen.dart';

/// "Did it happen?" (02-design.md §6.9): once the date of a thought has
/// passed ([didItHappen]), one sky card per thought, oldest first, at most
/// two at a time. Yes stores the contact at the planned date and shows the
/// "Nice one" screen; No moves the thought back to the plans without a
/// date, as Soon. Nothing is shown as late or missed.
class DidItHappen extends ConsumerWidget {
  const DidItHappen({super.key});

  /// How many cards show at once.
  static const visible = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(peopleProvider).value ?? const <Person>[];
    final intentions = ref.watch(openIntentionsProvider).value ?? const [];
    final now = ref.watch(clockProvider)();
    final byId = {for (final p in people) p.id: p};
    final asked = didItHappen(people, intentions, now).take(visible);
    if (asked.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [for (final i in asked) _Card(byId[i.personId]!, i)],
      ),
    );
  }
}

class _Card extends ConsumerWidget {
  const _Card(this.person, this.intention);

  final Person person;
  final Intention intention;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tone = context.kept.skyTone;
    final date = intention.date!;
    return KeptCard(
      tone: tone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(
            l10n.didItHappen,
            style: context.text.titleLarge?.copyWith(color: tone.onContainer),
          ),
          Text(
            [
              firstNameOf(person.name),
              thoughtText(intention, l10n),
              whenText(whenOf(intention), l10n),
            ].join(' · '),
            style: context.text.bodyLarge?.copyWith(color: tone.onContainer),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              spacing: 12,
              children: [
                Expanded(
                  child: MainButton(
                    label: l10n.yes,
                    onPressed: () => unawaited(
                      completeThought(
                        context,
                        ref,
                        person,
                        intention,
                        source: ContactSource.confirmed,
                        at: date,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GreyButton(
                    label: l10n.no,
                    onPressed: () => unawaited(
                      ref
                          .read(intentionsRepositoryProvider)
                          .moveBackToPlans(intention.id),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
