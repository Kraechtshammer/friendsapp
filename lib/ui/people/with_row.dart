import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/display_name.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/avatar.dart';
import '../widgets/face_blob.dart';
import '../widgets/section_label.dart';
import 'people_multi_picker.dart';

/// The "With" label and faces of a contact with several people at once:
/// [person] first and fixed, the [others] (tap to remove) and a dashed "+"
/// that opens the picker. The owner keeps the list; every change goes out
/// through [onChanged].
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
    final names = ref.read(displayNamesProvider);
    final choices = [
      for (final p in ref.read(peopleProvider).value ?? const <Person>[])
        if (p.id != person.id) PersonChoice(p.id, shortNameIn(names, p), p),
    ];
    final picked = await showPeopleMultiPicker(
      context,
      choices,
      title: context.l10n.logPickPeople,
      initial: {for (final p in others) p.id},
    );
    if (picked == null || !context.mounted) return;
    onChanged([for (final c in picked) c.person]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        SectionLabel(l10n.logContactWith),
        Wrap(
          spacing: 4,
          runSpacing: 8,
          children: [
            FaceBlob(
              label: ref.readShortName(person),
              face: Avatar.person(person),
            ),
            for (final p in others)
              FaceBlob(
                label: ref.readShortName(p),
                face: Avatar.person(p),
                selected: true,
                onTap: () => onChanged([
                  for (final o in others)
                    if (o != p) o,
                ]),
              ),
            AddFaceBlob(
              label: l10n.logAddPerson,
              onTap: () => _add(context, ref),
            ),
          ],
        ),
      ],
    );
  }
}
