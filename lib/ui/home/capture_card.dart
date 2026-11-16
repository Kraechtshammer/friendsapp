import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/intention.dart';
import '../../domain/person_name.dart';
import '../../domain/recent_people.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../widgets/avatar.dart';
import '../widgets/choice_chips.dart';
import '../widgets/grey_button.dart';
import '../widgets/kept_card.dart';
import '../widgets/kept_text_field.dart';
import '../widgets/main_button.dart';
import '../widgets/when_picker.dart';
import 'person_picker.dart';

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

  Future<void> _more(List<Person> people) async {
    final picked = await showPersonPicker(context, people);
    if (picked != null && mounted) setState(() => _personId = picked.id);
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
    // The picked person always shows in the row, even if not a recent one.
    final shown = recentPeople(people, open);
    if (selected != null && !shown.any((p) => p.id == selected!.id)) {
      if (shown.length == 4) shown.removeLast();
      shown.add(selected);
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final p in shown)
                  Expanded(
                    child: _Blob(
                      label: firstNameOf(p.name),
                      selected: p.id == selected?.id,
                      dimmed: selected != null && p.id != selected.id,
                      onTap: () => setState(
                        () => _personId = p.id == _personId ? null : p.id,
                      ),
                      face: Avatar.person(p, size: 48, classBadge: true),
                    ),
                  ),
                Expanded(
                  child: _Blob(
                    label: l10n.captureMore,
                    selected: false,
                    dimmed: selected != null,
                    onTap: () => _more(people),
                    face: const _MoreFace(),
                  ),
                ),
              ],
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

/// A face over a first name. The chosen one sits on the ground colour with
/// bold text, the others fade (concept V6b).
class _Blob extends StatelessWidget {
  const _Blob({
    required this.label,
    required this.face,
    required this.selected,
    required this.dimmed,
    required this.onTap,
  });

  final String label;
  final Widget face;
  final bool selected;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    return Semantics(
      button: true,
      selected: selected,
      child: Opacity(
        opacity: dimmed ? .45 : 1,
        child: Material(
          color: selected ? kept.ground : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  face,
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium?.copyWith(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: context.kept.sunTone.onContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The "More" blob: the search icon on the ground colour.
class _MoreFace extends StatelessWidget {
  const _MoreFace();

  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 48,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: context.kept.ground,
      borderRadius: BorderRadius.circular(24),
    ),
    child: const KeptIcon(KeptIcons.search, size: 26),
  );
}
