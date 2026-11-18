import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/database.dart';
import '../../domain/contact_event.dart';
import '../../domain/group.dart';
import '../../domain/intention.dart';
import '../../domain/progress.dart';
import '../../domain/treat.dart';
import '../common.dart';
import '../material.dart';
import '../kept_icon.dart';
import '../widgets/avatar.dart';
import '../widgets/couple_avatar.dart';
import '../widgets/kept_switch.dart';
import '../widgets/grey_button.dart';
import '../widgets/kept_card.dart';
import '../widgets/kept_text_field.dart';
import '../widgets/main_button.dart';
import '../widgets/section_label.dart';
import '../widgets/stamps.dart';
import '../widgets/when_picker.dart';

/// Done on an open thought: stores the contact at once, then shows the
/// "Nice one" screen for it. Leaving that screen early loses nothing.
/// [source] is `manual` for the Done button and `confirmed` for "Yes" on
/// "Did you write?". With [replace] the Nice one screen takes the place of
/// the current one (the question). [at] is the time of the contact if it
/// is not now ("Did it happen?" uses the planned date).
///
/// For a couple's thought the contact is stored for both members (one
/// shared event), unless [only] is given: then for that person alone. The
/// chat question passes [only] when the user wrote to or called one of the
/// two (04-architecture.md, "Couples").
Future<void> completeThought(
  BuildContext context,
  WidgetRef ref,
  Person person,
  Intention intention, {
  ContactSource source = ContactSource.manual,
  DateTime? at,
  bool replace = false,
  Person? only,
}) {
  final groupId = intention.groupId;
  return _storeAndCelebrate(
    context,
    person: only ?? person,
    couple: groupId == null ? null : ref.read(couplesByIdProvider)[groupId],
    thought: intention.note.trim(),
    replace: replace,
    store: () => ref
        .read(contactEventsRepositoryProvider)
        .completeIntention(
          intention.id,
          source: source,
          at: at,
          onlyPersonId: only?.id,
        ),
  );
}

/// "Yes" on "Did you write?" for a chat that was not opened for a thought:
/// stores a `wrote` event ([source] `confirmed` for that question,
/// `manual` for Done on the reconnect pick), then shows the "Nice one"
/// screen.
Future<void> completeWrite(
  BuildContext context,
  WidgetRef ref,
  Person person, {
  ContactSource source = ContactSource.confirmed,
  bool replace = false,
}) => _storeAndCelebrate(
  context,
  person: person,
  thought: '',
  replace: replace,
  store: () => ref
      .read(contactEventsRepositoryProvider)
      .add(
        personId: person.id,
        at: DateTime.now(),
        kind: ContactKind.wrote,
        direction: ContactDirection.byUser,
        source: source,
      ),
);

/// "We were in touch" sheet on the person page: stores a contact that
/// already happened, dated [at], then shows the "Nice one" screen. Writing
/// and calling are by the user, meeting and playing are together. The
/// "Nice one" screen asks for the activity and the line for next time.
Future<void> completeLoggedContact(
  BuildContext context,
  WidgetRef ref,
  Person person, {
  required ContactKind kind,
  required DateTime at,
  GroupWithMembers? couple,
  String thought = '',
}) {
  final direction = switch (kind) {
    ContactKind.wrote || ContactKind.called => ContactDirection.byUser,
    _ => ContactDirection.together,
  };
  final repo = ref.read(contactEventsRepositoryProvider);
  return _storeAndCelebrate(
    context,
    person: couple?.members.first ?? person,
    couple: couple,
    thought: thought,
    replace: false,
    // With a couple it is one shared event for both members.
    store: couple == null
        ? () => repo.add(
            personId: person.id,
            at: at,
            kind: kind,
            direction: direction,
            source: ContactSource.manual,
          )
        : () async {
            final rows = await repo.addForGroup(
              groupId: couple.group.id,
              at: at,
              kind: kind,
              direction: direction,
              source: ContactSource.manual,
            );
            return rows.first;
          },
  );
}

/// "We met" on the couple page: stores a meeting with both members as one
/// shared event ([ContactEventsRepository.addForGroup], source `manual`,
/// kind `met`, together), then shows the "Nice one" screen with both faces
/// and both stamps.
Future<void> completeMeeting(
  BuildContext context,
  WidgetRef ref,
  GroupWithMembers couple,
) => _storeAndCelebrate(
  context,
  person: couple.members.first,
  couple: couple,
  thought: '',
  replace: false,
  store: () async {
    final rows = await ref
        .read(contactEventsRepositoryProvider)
        .addForGroup(
          groupId: couple.group.id,
          at: DateTime.now(),
          kind: ContactKind.met,
          direction: ContactDirection.together,
          source: ContactSource.manual,
        );
    return rows.first;
  },
);

/// "Congratulated" on a birthday pick ([source] `manual`) or "Yes" on "Did
/// you congratulate?" (`confirmed`): stores the user's birthday wish for
/// today (once), cancels today's birthday notifications for the person,
/// then shows the "Nice one" screen. HomeShell plans the notifications
/// again when the wish appears, which moves them to the next birthday.
Future<void> completeBirthday(
  BuildContext context,
  WidgetRef ref,
  Person person, {
  ContactSource source = ContactSource.manual,
  bool replace = false,
}) {
  final now = ref.read(clockProvider)();
  final notifications = ref.read(notificationsProvider);
  return _storeAndCelebrate(
    context,
    person: person,
    thought: '',
    replace: replace,
    store: () async {
      final event = await ref
          .read(contactEventsRepositoryProvider)
          .addBirthdayWishOnce(
            personId: person.id,
            day: now,
            at: now,
            source: source,
          );
      unawaited(notifications.cancelBirthday(person.id));
      return event;
    },
  );
}

Future<void> _storeAndCelebrate(
  BuildContext context, {
  required Person person,
  GroupWithMembers? couple,
  required String thought,
  required bool replace,
  required Future<ContactEvent> Function() store,
}) async {
  // The row is gone once the thought is done, so keep what is needed.
  final navigator = Navigator.of(context);
  // A "Saved for ..." note must not cover the Close button.
  ScaffoldMessenger.of(context).clearSnackBars();
  final event = await store();
  final route = MaterialPageRoute<void>(
    builder: (_) => NiceOneScreen(
      person: person,
      event: event,
      thought: thought,
      couple: couple,
    ),
  );
  unawaited(replace ? navigator.pushReplacement(route) : navigator.push(route));
}

/// The screen after a contact is confirmed. See concept V6 · After 'Yes, I
/// wrote' (docs/concepts/gen_v6.py). "Planning to meet up?" is a small
/// sky row under the line for next time ([_PlanRow]); it is left out when
/// the person already has an open meet-up thought. The stamps the contact earned are shown under the
/// card ([_StampsCard]); a contact that earned none shows nothing about
/// stamps.
///
/// Closing, by the button or back, saves the activity and the line to the
/// event; with "Remind me" on, the line also becomes a new open thought,
/// and a meet-up planned in the row becomes a meet thought with its "when".
///
/// For a couple ([couple]) the event is the shared one when it has a
/// `groupId`: the screen shows both faces and the stamps of both. A
/// "Remind me" line then becomes a thought for the couple. Whatever
/// was recorded, the meet-up planned in the row is for the couple when
/// the screen comes from a couple's thought.
class NiceOneScreen extends ConsumerStatefulWidget {
  const NiceOneScreen({
    super.key,
    required this.person,
    required this.event,
    this.thought = '',
    this.couple,
  });

  /// The person the contact was stored for (the first member when it was
  /// stored for the couple).
  final Person person;
  final ContactEvent event;

  /// The couple the thought was for, if any.
  final GroupWithMembers? couple;

  /// The text of the thought that was done; prefills the activity.
  final String thought;

  @override
  ConsumerState<NiceOneScreen> createState() => _NiceOneScreenState();
}

class _NiceOneScreenState extends ConsumerState<NiceOneScreen> {
  late final _activity = TextEditingController(text: widget.thought);
  final _line = TextEditingController();
  final _planNote = TextEditingController();
  var _planWhen = const When.none();
  var _remind = false;
  var _saved = false;

  /// The contact is the couple's: stored for both members.
  bool get _forBoth => widget.couple != null && widget.event.groupId != null;

  bool get _asksActivity =>
      widget.event.kind == ContactKind.met ||
      widget.event.kind == ContactKind.gamed;

  @override
  void dispose() {
    _activity.dispose();
    _line.dispose();
    _planNote.dispose();
    super.dispose();
  }

  String? _textOrNull(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  void _save() {
    if (_saved) return;
    _saved = true;
    final line = _textOrNull(_line);
    unawaited(
      ref
          .read(contactEventsRepositoryProvider)
          .update(
            widget.event.id,
            activity: _asksActivity ? _textOrNull(_activity) : null,
            note: line,
          ),
    );
    _savePlan();
    if (_remind && line != null) {
      unawaited(
        ref
            .read(intentionsRepositoryProvider)
            .add(
              personId: _forBoth ? null : widget.person.id,
              groupId: _forBoth ? widget.couple!.group.id : null,
              note: line,
              kind: IntentionKind.write,
            ),
      );
    }
  }

  void _savePlan() {
    final note = _textOrNull(_planNote);
    if (_planWhen == const When.none() && note == null) return;
    unawaited(
      ref
          .read(intentionsRepositoryProvider)
          .add(
            personId: widget.couple == null ? widget.person.id : null,
            groupId: widget.couple?.group.id,
            note: note ?? '',
            kind: IntentionKind.meet,
            when: _planWhen,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kept = context.kept;
    final openMeet = (ref.watch(openIntentionsProvider).value ?? const []).any(
      (i) =>
          i.kind == IntentionKind.meet &&
          (i.personId == widget.person.id ||
              (widget.couple != null && i.groupId == widget.couple!.group.id)),
    );
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _save();
      },
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(child: _Confetti()),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 44, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 12,
                        children: [
                          Center(
                            child: _forBoth
                                ? CoupleAvatar(
                                    widget.couple!.members,
                                    size: 112,
                                  )
                                : Avatar.person(widget.person, size: 96),
                          ),
                          Text(
                            l10n.niceOneTitle,
                            textAlign: TextAlign.center,
                            style: context.text.headlineLarge,
                          ),
                          Text(
                            l10n.niceOneSubtitle,
                            textAlign: TextAlign.center,
                            style: context.text.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          KeptCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: 10,
                              children: [
                                if (_asksActivity) ...[
                                  _Label(l10n.activityLabel),
                                  KeptTextField(
                                    controller: _activity,
                                    fillColor: kept.ground,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                  ),
                                ],
                                _Label(l10n.nextTimeLabel),
                                KeptTextField(
                                  controller: _line,
                                  hint: l10n.nextTimeHint,
                                  fillColor: kept.ground,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                ),
                                Row(
                                  spacing: 12,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.remindMe,
                                            style: context.text.labelLarge
                                                ?.copyWith(color: kept.text),
                                          ),
                                          Text(
                                            l10n.remindMeHelp,
                                            style: context.text.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    KeptSwitch(
                                      value: _remind,
                                      onChanged: (v) =>
                                          setState(() => _remind = v),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (!openMeet)
                            _PlanRow(
                              note: _planNote,
                              when: _planWhen,
                              onWhen: (w) => setState(() => _planWhen = w),
                            ),
                          _StampsCard(event: widget.event, shared: _forBoth),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: MainButton(
                      label: l10n.niceOneClose,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Planning to meet up?" (concept V6 · After 'Yes, I wrote'): a small sky
/// row. Tapping "Plan it" opens the when-picker (date, Soon, Later,
/// When...) and an optional short text; the screen saves the meet thought
/// when it closes.
class _PlanRow extends StatefulWidget {
  const _PlanRow({
    required this.note,
    required this.when,
    required this.onWhen,
  });

  final TextEditingController note;
  final When when;
  final ValueChanged<When> onWhen;

  @override
  State<_PlanRow> createState() => _PlanRowState();
}

class _PlanRowState extends State<_PlanRow> {
  var _open = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tone = context.kept.skyTone;
    return KeptCard(
      tone: tone,
      small: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Row(
            spacing: 12,
            children: [
              const KeptIcon(KeptIcons.calendar, size: 28),
              Expanded(
                child: Text(
                  l10n.nicePlanTitle,
                  style: context.text.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: tone.onContainer,
                  ),
                ),
              ),
              if (!_open)
                GreyButton(
                  small: true,
                  label: l10n.nicePlanAction,
                  onPressed: () => setState(() => _open = true),
                ),
            ],
          ),
          if (_open) ...[
            WhenPicker(
              value: widget.when,
              onChanged: widget.onWhen,
              fieldColor: context.kept.ground,
            ),
            KeptTextField(
              controller: widget.note,
              hint: l10n.nicePlanHint,
              fillColor: context.kept.ground,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ],
      ),
    );
  }
}

/// The stamps this contact earned or raised: a sun tonal card with tilted
/// stamps and "+2" (concept V6 · After 'Yes, I wrote'). When the card
/// became full, the treat is celebrated. Nothing when the contact earned no
/// stamp (incoming, or the person already had one this week).
class _StampsCard extends ConsumerWidget {
  const _StampsCard({required this.event, this.shared = false});

  final ContactEvent event;

  /// The event is a couple's: the stamps of every row of it are added up,
  /// with each person's share named.
  final bool shared;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedId = event.sharedId;
    final rows = shared && sharedId != null
        ? [
            for (final e
                in ref.watch(allContactEventsProvider).value ?? const [])
              if (e.sharedId == sharedId) e,
          ]
        : <ContactEvent>[];
    final perRow = [
      for (final e in rows.isEmpty ? [event] : rows)
        (e, ref.watch(eventStampsProvider(e.id)).value ?? const <Stamp>[]),
    ];
    final earned = [for (final r in perRow) ...r.$2];
    final names = ref.watch(displayNamesProvider);
    final value = stampTotal(earned);
    if (value == 0) return const SizedBox.shrink();
    final treats = ref.watch(treatsProvider).value ?? const <Treat>[];
    final l10n = context.l10n;
    final tone = context.kept.sunTone;
    // The card these stamps filled, if it is full now.
    Treat? full;
    for (final s in earned) {
      for (final t in treats) {
        if (t.id == s.treatId &&
            (t.state == TreatState.earned || t.state == TreatState.enjoyed)) {
          full = t;
        }
      }
    }
    final current = currentTreat(treats);
    final onlyLoose = earned.every((s) => s.treatId == null);
    return KeptCard(
      tone: tone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          SectionLabel(l10n.niceOneStampsCard, color: tone.onContainer),
          Row(
            spacing: 6,
            children: [
              for (var i = 0; i < value && i < 5; i++)
                StampMark(size: 48, index: i),
              const SizedBox(width: 6),
              Text(
                full != null ? l10n.treatFull : '+$value',
                style: context.text.headlineLarge?.copyWith(
                  color: tone.onContainer,
                ),
              ),
            ],
          ),
          if (full != null)
            Row(
              spacing: 12,
              children: [
                const KeptIcon(KeptIcons.gift, size: 30),
                Expanded(
                  child: Text(
                    '${l10n.treatEarnedTitle(full.name)} ${l10n.treatEarnedBody}',
                    style: context.text.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            )
          else if (perRow.length > 1)
            Wrap(
              spacing: 14,
              children: [
                for (final (e, stamps) in perRow)
                  if (stampTotal(stamps) > 0)
                    Text(
                      l10n.niceOneStampsOf(
                        names[e.personId] ?? '',
                        stampTotal(stamps),
                      ),
                      style: context.text.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
              ],
            )
          else if (onlyLoose || current == null)
            Text(
              l10n.niceOneStampsLoose,
              style: context.text.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            )
          else
            Text(
              l10n.stampCardLeft(
                (current.stampsNeeded -
                        stampsOnCard(
                          ref.watch(stampsProvider).value ?? const [],
                          current.id,
                        ))
                    .clamp(1, current.stampsNeeded),
              ),
              style: context.text.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: context.text.labelMedium?.copyWith(color: context.kept.muted),
  );
}

/// The static confetti of ui-style.md §6: sixteen dots and bars in the six
/// accents around the avatar. Positions are the concept's, laid out for a
/// 390 wide screen and spread to the width given.
class _Confetti extends StatelessWidget {
  const _Confetti();

  // x, y, width, height, colour, round, rotation in degrees.
  static const _pieces =
      <(double, double, double, double, Color, bool, double)>[
        (24, 46, 14, 14, KeptColors.coral, true, 0),
        (62, 104, 20, 9, KeptColors.mint, false, 24),
        (112, 34, 9, 20, KeptColors.sun, false, -18),
        (300, 50, 16, 16, KeptColors.lilac, true, 0),
        (342, 112, 20, 9, KeptColors.pink, false, -30),
        (262, 22, 9, 20, KeptColors.sky, false, 30),
        (40, 168, 11, 11, KeptColors.sun, true, 0),
        (330, 176, 11, 11, KeptColors.mint, true, 0),
        (86, 60, 9, 9, KeptColors.sky, true, 0),
        (286, 96, 9, 9, KeptColors.sun, true, 0),
        (150, 16, 18, 8, KeptColors.pink, false, 40),
        (252, 122, 8, 18, KeptColors.coral, false, 16),
        (16, 118, 8, 18, KeptColors.lilac, false, -24),
        (358, 40, 8, 18, KeptColors.sun, false, 12),
        (92, 150, 18, 8, KeptColors.coral, false, -12),
        (282, 158, 18, 8, KeptColors.sky, false, 20),
      ];

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, box) => Stack(
          children: [
            for (final (x, y, w, h, color, round, deg) in _pieces)
              Positioned(
                left: x / 390 * box.maxWidth,
                top: top + y,
                child: Transform.rotate(
                  angle: deg * 3.14159265 / 180,
                  child: Container(
                    width: w,
                    height: h,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(round ? w : 4),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
