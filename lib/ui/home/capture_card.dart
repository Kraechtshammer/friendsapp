import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/contact_event.dart';
import '../../domain/shared_event.dart';
import '../../domain/intention.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../material.dart';
import '../kept_icon.dart';
import '../widgets/activity_icon_picker.dart';
import '../widgets/face_blob.dart';
import '../widgets/kind_tiles.dart';
import '../widgets/grey_button.dart';
import '../widgets/kept_card.dart';
import '../widgets/kept_text_field.dart';
import '../widgets/main_button.dart';
import '../widgets/past_day_picker.dart';
import '../widgets/when_picker.dart';
import 'nice_one_screen.dart';
import 'who_row.dart';
import '../varied_text.dart';

/// The capture card: a note, the people, a kind, when, Save (02-design.md
/// §2.1 and §8, 2026-11-23; concept log-sheet-v3). The kind tiles, the when
/// chips and Save show once someone is chosen. The note may be empty, the
/// person is required. A plan saves one thought per chosen person (a linked
/// couple is one). "Done" logs a contact for all chosen people instead.
class CaptureCard extends ConsumerStatefulWidget {
  const CaptureCard({super.key, required this.onAddPeople});

  final VoidCallback onAddPeople;

  @override
  ConsumerState<CaptureCard> createState() => _CaptureCardState();
}

class _CaptureCardState extends ConsumerState<CaptureCard> with VariedText {
  final _note = TextEditingController();
  final _focus = FocusNode();

  /// Person ids and group ids, in the order they were chosen.
  var _chosen = <String>[];
  var _kind = IntentionKind.write;

  /// For a meetup or a game only; see [_iconName].
  KeptIcons? _icon;

  /// Optional, and collapsed into one row of chips (02-design.md §6.9).
  var _when = const When.none();

  /// "Done": the card logs a contact instead of a thought.
  var _happened = false;
  var _day = const PastDay.today();

  bool get _hasIcon =>
      _kind == IntentionKind.meet || _kind == IntentionKind.game;

  String? get _iconName => _hasIcon ? _icon?.name : null;

  @override
  void dispose() {
    _note.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _reset() {
    _note.clear();
    setState(() {
      _chosen = [];
      _kind = IntentionKind.write;
      _icon = null;
      _when = const When.none();
      _happened = false;
      _day = const PastDay.today();
    });
  }

  Future<void> _saveContact(List<PersonChoice> subjects) async {
    final note = _note.text.trim();
    final kind = contactKindFor(_kind);
    final at = _day.at(ref.read(clockProvider)());
    final icon = _iconName;
    // One couple alone is the couple's contact; otherwise everyone is
    // flattened into one shared event.
    final couple = subjects.length == 1 ? subjects.single.couple : null;
    final people = <Person>[];
    for (final s in subjects) {
      for (final p in s.members) {
        if (!people.any((o) => o.id == p.id)) people.add(p);
      }
    }
    FocusScope.of(context).unfocus();
    final nav = context;
    _reset();
    await completeLoggedContact(
      nav,
      ref,
      people.first,
      kind: kind,
      at: at,
      couple: couple,
      withPeople: couple == null ? people.sublist(1) : const [],
      thought: note,
      activityIcon: icon,
    );
  }

  Future<void> _save(List<PersonChoice> subjects) async {
    final messenger = ScaffoldMessenger.of(context);
    final saved = context.l10n.captureSaved(_joined(subjects));
    final note = _note.text.trim();
    FocusScope.of(context).unfocus();
    final repo = ref.read(intentionsRepositoryProvider);
    for (final s in subjects) {
      await repo.add(
        personId: s.isCouple ? null : s.person.id,
        groupId: s.couple?.group.id,
        note: note,
        kind: _kind,
        when: _when,
        activityIcon: _iconName,
      );
    }
    if (!mounted) return;
    _reset();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(saved)));
  }

  String _joined(List<PersonChoice> subjects) =>
      joinNames([for (final s in subjects) s.label], context.l10n.namesAnd);

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
    final couples = ref.watch(couplesProvider).value ?? const [];
    final events = ref.watch(allContactEventsProvider).value ?? const [];
    final names = ref.watch(displayNamesProvider);
    final choices = allChoices(people, couples, names);
    final byId = {for (final c in choices) c.id: c};
    final subjects = [
      for (final id in _chosen)
        if (byId[id] != null) byId[id]!,
    ];
    final tone = kept.sunTone;
    String kindText(IntentionKind k) =>
        _happened ? pastKindLabel(k, l10n) : kindLabel(k, l10n);
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
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: KeptTextField(
                  controller: _note,
                  focusNode: _focus,
                  hint: vary(l10n.captureHints),
                  fillColor: kept.ground,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              if (_hasIcon)
                ActivityIconButton(
                  icon: _icon,
                  onChanged: (icon) => setState(() => _icon = icon),
                ),
            ],
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
            WhoRow(
              choices: choices,
              suggestions: suggestedChoices(
                people: people,
                couples: couples,
                intentions: open,
                events: events,
                now: ref.read(clockProvider)(),
                names: names,
              ),
              chosen: _chosen,
              onChanged: (ids) => setState(() {
                final wasCouple = subjects.firstOrNull?.isCouple ?? false;
                _chosen = ids;
                final first = ids.isEmpty ? null : byId[ids.first];
                // A couple is met together; the kind follows the choice
                // until the user picks one.
                if ((first?.isCouple ?? false) && !wasCouple) {
                  _kind = IntentionKind.meet;
                }
                if (!(first?.isCouple ?? false) && wasCouple) {
                  _kind = IntentionKind.write;
                }
              }),
            ),
            if (subjects.isNotEmpty) ...[
              KindTiles<IntentionKind>(
                options: [
                  for (final k in IntentionKind.values)
                    KindOption(k, kindIcon(k), kindText(k)),
                ],
                value: _kind,
                onChanged: (k) => setState(() => _kind = k),
              ),
              WhenPicker(
                value: _when,
                fieldColor: kept.ground,
                onChanged: (w) => setState(() {
                  _when = w;
                  if (w.date != null || w.horizon != null) _happened = false;
                }),
                leading: SmallChip(
                  label: l10n.done,
                  selected: _happened,
                  fit: true,
                  onTap: () => setState(() {
                    _happened = !_happened;
                    if (_happened) _when = const When.none();
                  }),
                ),
              ),
              if (_happened)
                PastDayChips(
                  value: _day,
                  onChanged: (d) => setState(() => _day = d),
                ),
            ],
            MainButton(
              label: subjects.isEmpty
                  ? l10n.save
                  : _happened
                  ? l10n.save
                  : l10n.captureSave(_joined(subjects)),
              onPressed: subjects.isEmpty
                  ? null
                  : () => _happened ? _saveContact(subjects) : _save(subjects),
            ),
          ],
        ],
      ),
    );
  }
}
