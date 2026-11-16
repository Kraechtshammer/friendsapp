import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/intention.dart';
import '../../domain/person_name.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/choice_chips.dart';
import '../widgets/grey_button.dart';
import '../widgets/kept_card.dart';
import '../widgets/kept_text_field.dart';
import '../widgets/main_button.dart';
import '../widgets/when_picker.dart';
import 'person_choice_row.dart';

/// The capture card: a note, a person, a kind, Save (02-design.md §2.1;
/// concept V6b · Capturing). The kind chips and Save show once a person is
/// chosen. The note may be empty, the person is required.
class CaptureCard extends ConsumerStatefulWidget {
  const CaptureCard({super.key, required this.onAddPeople});

  final VoidCallback onAddPeople;

  @override
  ConsumerState<CaptureCard> createState() => _CaptureCardState();
}

class _CaptureCardState extends ConsumerState<CaptureCard> {
  final _note = TextEditingController();
  final _focus = FocusNode();
  String? _personId;
  var _kind = IntentionKind.write;

  /// Optional, and collapsed into one row of chips (02-design.md §6.9).
  var _when = const When.none();

  @override
  void dispose() {
    _note.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _save(Person person) async {
    final messenger = ScaffoldMessenger.of(context);
    final saved = context.l10n.captureSaved(firstNameOf(person.name));
    final note = _note.text.trim();
    FocusScope.of(context).unfocus();
    await ref
        .read(intentionsRepositoryProvider)
        .add(personId: person.id, note: note, kind: _kind, when: _when);
    if (!mounted) return;
    _note.clear();
    setState(() {
      _personId = null;
      _kind = IntentionKind.write;
      _when = const When.none();
    });
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(saved)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kept = context.kept;
    // The launcher shortcut asks for the field.
    ref.listen(captureFocusProvider, (_, _) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focus.requestFocus();
      });
    });
    final peopleState = ref.watch(peopleProvider);
    final people = peopleState.value ?? const <Person>[];
    final open = ref.watch(openIntentionsProvider).value ?? const [];
    Person? selected;
    for (final p in people) {
      if (p.id == _personId) selected = p;
    }
    final tone = kept.sunTone;
    return KeptCard(
      tone: tone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Text(
            l10n.captureTitle,
            style: context.text.titleLarge?.copyWith(color: tone.onContainer),
          ),
          KeptTextField(
            controller: _note,
            focusNode: _focus,
            hint: l10n.captureHint,
            fillColor: kept.ground,
            textCapitalization: TextCapitalization.sentences,
          ),
          if (peopleState.hasValue && people.isEmpty) ...[
            Text(
              l10n.captureNoPeople,
              style: context.text.bodyMedium?.copyWith(color: kept.muted),
            ),
            GreyButton(
              label: l10n.captureAddPeople,
              onPressed: widget.onAddPeople,
            ),
          ] else if (people.isNotEmpty) ...[
            PersonChoiceRow(
              people: people,
              intentions: open,
              selectedId: _personId,
              textColor: tone.onContainer,
              fieldColor: kept.ground,
              onChanged: (id) => setState(() => _personId = id),
            ),
            if (selected != null) ...[
              ChoiceChips<IntentionKind>(
                options: [
                  for (final k in IntentionKind.values)
                    ChipOption(k, kindLabel(k, l10n), icon: kindIcon(k)),
                ],
                value: _kind,
                onChanged: (k) => setState(() => _kind = k),
              ),
              WhenPicker(
                value: _when,
                fieldColor: kept.ground,
                onChanged: (w) => setState(() => _when = w),
              ),
              MainButton(
                label: l10n.captureSave(firstNameOf(selected.name)),
                onPressed: () => _save(selected!),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
