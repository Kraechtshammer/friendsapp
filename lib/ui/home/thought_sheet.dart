import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/intention.dart';
import '../../domain/plans.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/activity_icon_picker.dart';
import '../widgets/avatar.dart';
import '../widgets/couple_avatar.dart';
import '../widgets/choice_chips.dart';
import '../widgets/grey_button.dart';
import '../widgets/kept_text_field.dart';
import '../widgets/link_row.dart';
import '../widgets/main_button.dart';
import '../widgets/section_label.dart';
import '../widgets/when_picker.dart';
import 'nice_one_screen.dart';
import '../varied_text.dart';

/// Opens the sheet that edits an open thought: text, kind, "when", an
/// optional link and, for a meetup or a game, an activity icon, with
/// Save, Done and Drop. The three-dot button on a Home row, a tap on a
/// thought on the person page and on the Upcoming tab opens it. Done stores the changes first and then
/// goes on as the Done button does ([completeThought]).
Future<void> showThoughtSheet(
  BuildContext context,
  WidgetRef ref,
  Person person,
  Intention intention,
) async {
  final done = await showModalBottomSheet<Intention>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: context.kept.surface,
    builder: (_) => _ThoughtSheet(person, intention),
  );
  if (done == null || !context.mounted) return;
  await completeThought(context, ref, person, done);
}

class _ThoughtSheet extends ConsumerStatefulWidget {
  const _ThoughtSheet(this.person, this.intention);

  final Person person;
  final Intention intention;

  @override
  ConsumerState<_ThoughtSheet> createState() => _ThoughtSheetState();
}

class _ThoughtSheetState extends ConsumerState<_ThoughtSheet> with VariedText {
  late final _note = TextEditingController(text: widget.intention.note);
  late var _kind = widget.intention.kind;
  late var _when = whenOf(widget.intention);
  late final _link = TextEditingController(text: widget.intention.link ?? '');
  late var _icon = activityIconByName(widget.intention.activityIcon);

  /// Only a meetup or a game has an activity icon.
  bool get _hasIcon =>
      _kind == IntentionKind.meet || _kind == IntentionKind.game;

  @override
  void dispose() {
    _note.dispose();
    _link.dispose();
    super.dispose();
  }

  /// Writes the changes, if there are any, and returns the thought as it
  /// is now.
  Future<Intention> _store() async {
    final old = widget.intention;
    final note = _note.text.trim();
    final link = _link.text.trim().isEmpty ? null : _link.text.trim();
    final icon = _hasIcon ? _icon?.name : null;
    final updated = old.copyWith(
      note: note,
      kind: _kind,
      link: Value(link),
      activityIcon: Value(icon),
      date: Value(_when.date),
      horizon: Value(_when.horizon),
      condition: Value(
        _when.horizon == Horizon.whenCondition &&
                (_when.condition?.trim().isNotEmpty ?? false)
            ? _when.condition!.trim()
            : null,
      ),
    );
    if (note != old.note ||
        _kind != old.kind ||
        _when != whenOf(old) ||
        link != old.link ||
        icon != old.activityIcon) {
      await ref
          .read(intentionsRepositoryProvider)
          .update(
            old.id,
            note: note,
            kind: _kind,
            when: _when,
            link: link,
            activityIcon: icon,
          );
    }
    return updated;
  }

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    await _store();
    navigator.pop();
  }

  Future<void> _done() async {
    final navigator = Navigator.of(context);
    final updated = await _store();
    navigator.pop(updated);
  }

  Future<void> _drop() async {
    final navigator = Navigator.of(context);
    await ref
        .read(intentionsRepositoryProvider)
        .setState(widget.intention.id, IntentionState.dropped);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kept = context.kept;
    final person = widget.person;
    final groupId = widget.intention.groupId;
    final couple = groupId == null
        ? null
        : ref.watch(couplesByIdProvider)[groupId];
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Row(
            spacing: 12,
            children: [
              if (couple != null)
                CoupleAvatar(couple.members, size: 44, ringColor: kept.surface)
              else
                Avatar.person(person, size: 44, classBadge: true),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      couple?.label(ref.watch(displayNamesProvider)) ??
                          ref.shortName(person),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleLarge?.copyWith(
                        color: kept.text,
                      ),
                    ),
                    Text(l10n.editThought, style: context.text.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Expanded(
                child: KeptTextField(
                  controller: _note,
                  hint: vary(l10n.captureHints),
                  fillColor: kept.ground,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  minLines: 1,
                ),
              ),
              if (_hasIcon)
                ActivityIconButton(
                  icon: _icon,
                  onChanged: (icon) => setState(() => _icon = icon),
                ),
            ],
          ),
          ChoiceChips<IntentionKind>(
            options: [
              for (final k in IntentionKind.values)
                ChipOption(k, kindLabel(k, l10n), icon: kindIcon(k)),
            ],
            value: _kind,
            onChanged: (k) => setState(() => _kind = k),
          ),
          KeptTextField(
            controller: _link,
            hint: l10n.linkHint,
            fillColor: kept.ground,
            keyboardType: TextInputType.url,
            onChanged: (_) => setState(() {}),
          ),
          if (_link.text.trim().isNotEmpty) LinkRow(_link.text.trim()),
          SectionLabel(l10n.whenSection),
          WhenPicker(
            value: _when,
            fieldColor: kept.ground,
            onChanged: (w) => setState(() => _when = w),
          ),
          MainButton(label: l10n.save, onPressed: _save),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: GreyButton(label: l10n.done, onPressed: _done),
              ),
              Expanded(
                child: GreyButton(label: l10n.drop, onPressed: _drop),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
