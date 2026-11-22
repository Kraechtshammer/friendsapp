import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/avatar.dart';
import '../widgets/section_label.dart';
import 'people_multi_picker.dart';

/// The "With" label and chips of a contact with several people at once:
/// [person] (fixed), the [others] (removable) and "Add person". The owner
/// keeps the list; every change goes out through [onChanged].
class WithRow extends ConsumerWidget {
  const WithRow({
    super.key,
    required this.person,
    required this.others,
    required this.onChanged,
  });

  final Person person;
  final List<Person> others;
  final ValueChanged<List<Person>> onChanged;

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final taken = {person.id, for (final p in others) p.id};
    final free = [
      for (final p in ref.read(peopleProvider).value ?? const <Person>[])
        if (!taken.contains(p.id)) p,
    ];
    final picked = await showPeopleMultiPicker(
      context,
      free,
      title: context.l10n.logPickPeople,
    );
    if (picked == null || !context.mounted) return;
    onChanged([...others, ...picked]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        SectionLabel(l10n.logContactWith),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            InputChip(
              avatar: Avatar.person(person, size: 24),
              label: Text(ref.readShortName(person)),
            ),
            for (final p in others)
              InputChip(
                avatar: Avatar.person(p, size: 24),
                label: Text(ref.readShortName(p)),
                onDeleted: () => onChanged([
                  for (final o in others)
                    if (o != p) o,
                ]),
              ),
            ActionChip(
              avatar: const Icon(Icons.add_rounded, size: 18),
              label: Text(l10n.logAddPerson),
              onPressed: () => _add(context, ref),
            ),
          ],
        ),
      ],
    );
  }
}
