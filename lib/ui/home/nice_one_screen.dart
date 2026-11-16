import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/database.dart';
import '../../domain/contact_event.dart';
import '../../domain/intention.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/avatar.dart';
import '../widgets/kept_switch.dart';
import '../widgets/kept_card.dart';
import '../widgets/kept_text_field.dart';
import '../widgets/main_button.dart';

/// Done on an open thought: stores the contact at once, then shows the
/// "Nice one" screen for it. Leaving that screen early loses nothing.
/// [source] is `manual` for the Done button and `confirmed` for "Yes" on
/// "Did you write?". With [replace] the Nice one screen takes the place of
/// the current one (the question). [at] is the time of the contact if it
/// is not now ("Did it happen?" uses the planned date).
Future<void> completeThought(
  BuildContext context,
  WidgetRef ref,
  Person person,
  Intention intention, {
  ContactSource source = ContactSource.manual,
  DateTime? at,
  bool replace = false,
}) => _storeAndCelebrate(
  context,
  person: person,
  thought: intention.note.trim(),
  replace: replace,
  store: () => ref
      .read(contactEventsRepositoryProvider)
      .completeIntention(intention.id, source: source, at: at),
);

/// "Yes" on "Did you write?" for a chat that was not opened for a thought:
/// stores a confirmed `wrote` event, then shows the "Nice one" screen.
Future<void> completeWrite(
  BuildContext context,
  WidgetRef ref,
  Person person, {
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
        source: ContactSource.confirmed,
      ),
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
    builder: (_) =>
        NiceOneScreen(person: person, event: event, thought: thought),
  );
  unawaited(replace ? navigator.pushReplacement(route) : navigator.push(route));
}

/// The screen after a contact is confirmed. See concept V6 · After 'Yes, I
/// wrote' (docs/concepts/gen_v6.py). The "Planning to meet up?" part
/// (M5) and the stamps (M9) are not built.
///
/// Closing, by the button or back, saves the activity and the line to the
/// event; with "Remind me" on, the line also becomes a new open thought.
class NiceOneScreen extends ConsumerStatefulWidget {
  const NiceOneScreen({
    super.key,
    required this.person,
    required this.event,
    this.thought = '',
  });

  final Person person;
  final ContactEvent event;

  /// The text of the thought that was done; prefills the activity.
  final String thought;

  @override
  ConsumerState<NiceOneScreen> createState() => _NiceOneScreenState();
}

class _NiceOneScreenState extends ConsumerState<NiceOneScreen> {
  late final _activity = TextEditingController(text: widget.thought);
  final _line = TextEditingController();
  var _remind = false;
  var _saved = false;

  bool get _asksActivity =>
      widget.event.kind == ContactKind.met ||
      widget.event.kind == ContactKind.gamed;

  @override
  void dispose() {
    _activity.dispose();
    _line.dispose();
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
    if (_remind && line != null) {
      unawaited(
        ref
            .read(intentionsRepositoryProvider)
            .add(
              personId: widget.person.id,
              note: line,
              kind: IntentionKind.write,
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kept = context.kept;
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
                          Center(child: Avatar.person(widget.person, size: 96)),
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
