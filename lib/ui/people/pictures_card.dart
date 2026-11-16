import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/contact_photos.dart';
import '../../app/providers.dart';
import '../../data/database.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/grey_button.dart';
import '../widgets/kept_card.dart';
import '../widgets/main_button.dart';

/// "Add pictures from your contacts?" (02-design.md §8, 2026-11-16): for
/// people imported before pictures existed. Shown once on the People tab,
/// when some person is linked to a contact and has no picture, and the app
/// may read the contacts (without access it stays hidden and asks nothing).
/// Add fills the pictures, Not now only hides it; either way it does not
/// come back.
class PicturesCard extends ConsumerStatefulWidget {
  const PicturesCard(this.people, {super.key});

  final List<Person> people;

  @override
  ConsumerState<PicturesCard> createState() => _PicturesCardState();
}

class _PicturesCardState extends ConsumerState<PicturesCard> {
  var _busy = false;

  Future<void> _markAsked() => ref.services.settings.update(
    (s) => s.copyWith(picturesCatchUpAsked: true),
  );

  Future<void> _add() async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    var added = 0;
    try {
      added = await fillMissingPictures(
        people: widget.people,
        repo: ref.read(peopleRepositoryProvider),
        contacts: ref.read(contactsSourceProvider),
        store: ref.read(photoStoreProvider),
      );
    } finally {
      await _markAsked();
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.picturesAdded(added))));
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).value;
    final access = ref.watch(contactsAccessProvider).value ?? false;
    final needed = widget.people.any(
      (p) => p.contactId != null && p.photo == null,
    );
    if (settings == null ||
        settings.demoMode ||
        settings.picturesCatchUpAsked ||
        !access ||
        !needed) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final tone = context.kept.skyTone;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: KeptCard(
        tone: tone,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(
              l10n.pictureCardTitle,
              style: context.text.titleLarge?.copyWith(color: tone.onContainer),
            ),
            Text(
              l10n.pictureCardBody,
              style: context.text.bodyMedium?.copyWith(color: tone.onContainer),
            ),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: GreyButton(
                    small: true,
                    label: l10n.pictureCardNotNow,
                    onPressed: _busy ? null : () => unawaited(_markAsked()),
                  ),
                ),
                Expanded(
                  child: MainButton(
                    label: l10n.pictureCardAdd,
                    onPressed: _busy ? null : _add,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
