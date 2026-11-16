import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/contact_event.dart';
import '../../domain/person_name.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/grey_button.dart';

/// "They wrote" and "They called": two small grey buttons that store a
/// contact event from the person (direction byThem, source manual) dated
/// now. At most one per person, kind and day: a second tap on the same day
/// stores nothing and says it is already noted. Each shows a short
/// confirmation with Undo. The concept does not place them (02-design.md
/// §6.6); they sit above the timeline.
class IncomingButtons extends ConsumerWidget {
  const IncomingButtons(this.person, {super.key});

  final Person person;

  Future<void> _note(
    BuildContext context,
    WidgetRef ref,
    ContactKind kind,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(contactEventsRepositoryProvider);
    final name = firstNameOf(person.name);
    final event = await repo.addByThemOnce(
      personId: person.id,
      kind: kind,
      at: ref.read(clockProvider)(),
    );
    messenger.clearSnackBars();
    if (event == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.alreadyNoted)));
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          kind == ContactKind.wrote
              ? l10n.notedTheyWrote(name)
              : l10n.notedTheyCalled(name),
        ),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () => repo.delete(event.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Row(
      spacing: 12,
      children: [
        Expanded(
          child: GreyButton(
            small: true,
            label: l10n.buttonTheyWrote,
            onPressed: () => _note(context, ref, ContactKind.wrote),
          ),
        ),
        Expanded(
          child: GreyButton(
            small: true,
            label: l10n.buttonTheyCalled,
            onPressed: () => _note(context, ref, ContactKind.called),
          ),
        ),
      ],
    );
  }
}
