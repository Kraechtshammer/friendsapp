import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/contact_event.dart';
import '../../domain/group.dart';
import '../../domain/intention.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../home/nice_one_screen.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../widgets/avatar.dart';
import '../widgets/choice_chips.dart';
import '../widgets/grey_button.dart';
import '../widgets/grey_icon_button.dart';
import '../widgets/kept_card.dart';
import '../widgets/kept_text_field.dart';
import '../widgets/main_button.dart';
import '../widgets/section_label.dart';
import '../widgets/when_picker.dart';
import 'contact_entry_sheet.dart';
import 'person_screen.dart';
import 'person_timeline_view.dart';
import '../varied_text.dart';

/// A couple's page (02-design.md §8, 2026-11-16): both people large side
/// by side (a tap opens their own page), "We met", a thought for both, the
/// couple's open thoughts and the history of what they did together. Kept
/// plain, in the style of the person page.
class CoupleScreen extends ConsumerWidget {
  const CoupleScreen({super.key, required this.id});

  /// The group id.
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couple = ref.watch(couplesByIdProvider)[id];
    final dark = Theme.of(context).brightness == Brightness.dark;
    final overlay =
        (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(statusBarColor: Colors.transparent);
    // Unlinked while this page was open: nothing left to show.
    if (couple == null && ref.watch(couplesProvider).hasValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).maybePop();
      });
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        body: couple == null ? const SizedBox.shrink() : _Body(couple),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body(this.couple);

  final GroupWithMembers couple;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final first = couple.members.first;
    final open = <Intention>[
      for (final i in ref.watch(openIntentionsProvider).value ?? const [])
        if (i.groupId == couple.group.id) i,
    ];
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _Header(couple),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              MainButton(
                label: l10n.coupleWeMet,
                icon: KeptIcons.people,
                onPressed: () => completeMeeting(context, ref, couple),
              ),
              GreyButton(
                label: l10n.coupleThoughtForBoth,
                onPressed: () => showCoupleThoughtSheet(context, couple),
              ),
              OpenIntentionCards(first, open),
              _History(couple),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header(this.couple);

  final GroupWithMembers couple;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kept = context.kept;
    final tone = couple.members.first.avatarColor.tone(kept);
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.paddingOf(context).top + 16,
        16,
        20,
      ),
      decoration: BoxDecoration(
        color: tone.container,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [BoxShadow(color: kept.shadow, offset: const Offset(0, 5))],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 44),
            child: Row(
              children: [
                for (final p in couple.members)
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => PersonScreen(id: p.id),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          spacing: 8,
                          children: [
                            Avatar.person(p, size: 84),
                            Text(
                              ref.shortName(p),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.titleLarge?.copyWith(
                                color: tone.onContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: GreyIconButton(
              icon: Icons.arrow_back_rounded,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              size: 44,
              radius: 16,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
    );
  }
}

/// What they did together: one line per shared event, newest first.
class _History extends ConsumerWidget {
  const _History(this.couple);

  final GroupWithMembers couple;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final seen = <String>{};
    // One row of each shared event (every member has one).
    final events = [
      for (final e in ref.watch(allContactEventsProvider).value ?? const [])
        if (e.groupId == couple.group.id && seen.add(e.sharedId ?? e.id)) e,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        const SizedBox(height: 4),
        SectionLabel(l10n.coupleTogether),
        if (events.isEmpty)
          Text(l10n.coupleNothingTogether, style: context.text.bodyMedium),
        for (final e in events)
          KeptCard(
            small: true,
            padding: const EdgeInsets.all(12),
            onTap: () => showContactEntrySheet(context, ref, e),
            child: Row(
              spacing: 10,
              children: [
                KeptIcon(
                  e.kind == ContactKind.gamed
                      ? KeptIcons.controller
                      : KeptIcons.people,
                  size: 22,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contactTitle(e, '', l10n),
                        style: context.text.bodyLarge,
                      ),
                      if ((e.note ?? '').trim().isNotEmpty)
                        Text(e.note!.trim(), style: context.text.bodyMedium),
                    ],
                  ),
                ),
                Text(
                  l10n.dateDayMonthYear(e.at),
                  style: context.text.bodySmall?.copyWith(
                    color: context.kept.muted,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The sheet for a thought for both: text, kind (meet to start with) and
/// "when", saved with the couple's `groupId`.
Future<void> showCoupleThoughtSheet(
  BuildContext context,
  GroupWithMembers couple,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  backgroundColor: context.kept.surface,
  builder: (_) => _ThoughtForm(couple),
);

class _ThoughtForm extends ConsumerStatefulWidget {
  const _ThoughtForm(this.couple);

  final GroupWithMembers couple;

  @override
  ConsumerState<_ThoughtForm> createState() => _ThoughtFormState();
}

class _ThoughtFormState extends ConsumerState<_ThoughtForm> with VariedText {
  final _note = TextEditingController();
  var _kind = IntentionKind.meet;
  var _when = const When.none();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    await ref
        .read(intentionsRepositoryProvider)
        .add(
          groupId: widget.couple.group.id,
          note: _note.text.trim(),
          kind: _kind,
          when: _when,
        );
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kept = context.kept;
    final label = widget.couple.label(ref.watch(displayNamesProvider));
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
          Text(
            l10n.captureSave(label),
            style: context.text.titleLarge?.copyWith(color: kept.text),
          ),
          KeptTextField(
            controller: _note,
            hint: vary(l10n.captureHints),
            fillColor: kept.ground,
            textCapitalization: TextCapitalization.sentences,
          ),
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
          MainButton(label: l10n.save, onPressed: _save),
        ],
      ),
    );
  }
}
