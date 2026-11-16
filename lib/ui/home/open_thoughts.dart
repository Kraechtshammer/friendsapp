import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/person_name.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../people/person_screen.dart';
import '../widgets/avatar.dart';
import '../widgets/kept_card.dart';
import '../widgets/section_label.dart';

/// The open intentions, newest first, under "On your mind". Nothing is
/// shown as late and there are no dates (02-design.md §2.3). With none,
/// nothing is shown at all.
class OpenThoughts extends ConsumerWidget {
  const OpenThoughts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intentions = ref.watch(openIntentionsProvider).value ?? const [];
    final people = {
      for (final p in ref.watch(peopleProvider).value ?? const <Person>[])
        p.id: p,
    };
    final rows = [
      for (final i in intentions)
        if (people[i.personId] != null) _Row(people[i.personId]!, i),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [SectionLabel(context.l10n.onYourMind), ...rows],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.person, this.intention);

  final Person person;
  final Intention intention;

  @override
  Widget build(BuildContext context) {
    final note = intention.note.trim();
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
                    KeptIcon(kindIcon(intention.kind), size: 22),
                  ],
                ),
                if (note.isNotEmpty)
                  Text(
                    note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
