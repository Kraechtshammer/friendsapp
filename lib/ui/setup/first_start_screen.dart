import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/update_controller.dart';
import '../../data/app_settings.dart';
import '../../domain/person.dart';
import '../../platform/contacts.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../people/class_chooser.dart';
import '../people/import_contacts_screen.dart';
import '../settings/settings_actions.dart';
import '../widgets/grey_button.dart';
import '../widgets/kept_card.dart';
import '../widgets/kept_switch.dart';
import '../widgets/main_button.dart';

/// The guided first start (02-design.md §8, permissions): welcome, people,
/// how close, evening question, incoming messages, update check, done. Shown once on a
/// fresh install by HomeShell. Each optional part is switched on here
/// consciously and says what it is for and what to do without it. "Skip" is
/// on every page; it leaves the optional parts off.
class FirstStartScreen extends ConsumerStatefulWidget {
  const FirstStartScreen({super.key});

  @override
  ConsumerState<FirstStartScreen> createState() => _FirstStartState();
}

enum _Step { welcome, people, close, evening, incoming, update, done }

class _FirstStartState extends ConsumerState<FirstStartScreen> {
  var _step = _Step.welcome;
  var _picked = <PhoneContact>[];
  final _closeness = <String, Closeness>{};
  Messenger? _messenger = Messenger.whatsapp;
  var _saving = false;

  var _eveningOn = true;
  var _eveningMinute = AppSettings.defaultEveningMinute;
  var _eveningDecided = false;

  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(incomingAccessProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _go(_Step step) => setState(() => _step = step);

  Future<void> _pickContacts() async {
    final chosen = await Navigator.of(context).push<List<PhoneContact>>(
      MaterialPageRoute(
        builder: (_) => const ImportContactsScreen(returnPicked: true),
      ),
    );
    if (chosen == null || chosen.isEmpty || !mounted) return;
    setState(() {
      _picked = chosen;
      for (final c in chosen) {
        _closeness[c.id] = Closeness.nowAndThen;
      }
      _step = _Step.close;
    });
  }

  Future<void> _addPeople() async {
    if (_saving) return;
    setState(() => _saving = true);
    await addContactsAsPeople(
      ref.read(peopleRepositoryProvider),
      _picked,
      _closeness,
      _messenger,
    );
    if (mounted) {
      setState(() => _saving = false);
      _go(_Step.evening);
    }
  }

  Future<void> _eveningContinue() async {
    final services = ref.read(servicesProvider);
    await services.settings.update(
      (s) => s.copyWith(eveningOn: _eveningOn, eveningMinute: _eveningMinute),
    );
    _eveningDecided = true;
    // Switching on asks for the permission now, not earlier.
    if (_eveningOn) await switchEveningQuestion(ref, true);
    if (mounted) _go(_Step.incoming);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _eveningMinute ~/ 60,
        minute: _eveningMinute % 60,
      ),
    );
    if (picked != null) {
      setState(() => _eveningMinute = picked.hour * 60 + picked.minute);
    }
  }

  /// Ends the flow. Skipping before the evening page leaves the evening
  /// question off: nothing is switched on without the user's say.
  Future<void> _finish() async {
    final navigator = Navigator.of(context);
    // A fresh install shows no "What's new" for the version it started with.
    await ref.read(updateProvider.notifier).markVersionSeen();
    await ref
        .read(servicesProvider)
        .settings
        .update(
          (s) => s.copyWith(
            firstStartDone: true,
            eveningOn: _eveningDecided ? null : false,
          ),
        );
    navigator.pop();
  }

  void _back() {
    switch (_step) {
      case _Step.people:
        _go(_Step.welcome);
      case _Step.close:
        _go(_Step.people);
      case _Step.incoming:
        _go(_Step.evening);
      case _Step.update:
        _go(_Step.incoming);
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 8, 0),
                  child: _step == _Step.done
                      ? const SizedBox(height: 48)
                      : TextButton(
                          onPressed: () => unawaited(_finish()),
                          child: Text(l10n.firstStartSkip),
                        ),
                ),
              ),
              Expanded(child: _page(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _page(BuildContext context) {
    final l10n = context.l10n;
    final kept = context.kept;
    switch (_step) {
      case _Step.welcome:
        return _Page(
          icon: KeptIcons.stamp,
          title: l10n.fsWelcomeTitle,
          body: [
            Text(l10n.fsWelcomeBody, style: context.text.bodyLarge),
            KeptCard(
              tone: kept.mintTone,
              child: Text(
                l10n.fsWelcomePrivacy,
                style: context.text.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          actions: [
            MainButton(label: l10n.fsStart, onPressed: () => _go(_Step.people)),
          ],
        );
      case _Step.people:
        return _Page(
          icon: KeptIcons.people,
          title: l10n.fsPeopleTitle,
          body: [Text(l10n.fsPeopleBody, style: context.text.bodyLarge)],
          actions: [
            MainButton(
              label: l10n.addFromContacts,
              onPressed: () => unawaited(_pickContacts()),
            ),
            GreyButton(
              label: l10n.fsByHandLater,
              onPressed: () => _go(_Step.evening),
            ),
          ],
        );
      case _Step.close:
        return _Page(
          title: l10n.importClassTitle,
          body: [
            ClassAssignment(
              contacts: _picked,
              closeness: _closeness,
              messenger: _messenger,
              onCloseness: (id, v) => setState(() => _closeness[id] = v),
              onMessenger: (v) => setState(() => _messenger = v),
            ),
          ],
          actions: [
            MainButton(
              label: l10n.importAdd(_picked.length),
              onPressed: _saving ? null : () => unawaited(_addPeople()),
            ),
          ],
        );
      case _Step.evening:
        final time = MaterialLocalizations.of(context).formatTimeOfDay(
          TimeOfDay(hour: _eveningMinute ~/ 60, minute: _eveningMinute % 60),
          alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
        );
        return _Page(
          icon: KeptIcons.star,
          title: l10n.fsEveningTitle,
          body: [
            Text(l10n.fsEveningBody, style: context.text.bodyLarge),
            KeptCard(
              child: Column(
                spacing: 8,
                children: [
                  _SwitchRow(
                    l10n.settingsEveningSwitch,
                    value: _eveningOn,
                    onChanged: (v) => setState(() => _eveningOn = v),
                  ),
                  if (_eveningOn)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.settingsEveningTime,
                            style: context.text.bodyLarge,
                          ),
                        ),
                        GreyButton(
                          small: true,
                          label: time,
                          onPressed: () => unawaited(_pickTime()),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Text(
              _eveningOn ? l10n.fsEveningAsk : l10n.fsEveningOff,
              style: context.text.bodyMedium,
            ),
            if (_eveningOn)
              Text(l10n.fsEveningOff, style: context.text.bodyMedium),
          ],
          actions: [
            MainButton(
              label: l10n.fsContinue,
              onPressed: () => unawaited(_eveningContinue()),
            ),
          ],
        );
      case _Step.incoming:
        final on = ref.watch(settingsProvider).value?.incomingOn ?? false;
        final access = on ? ref.watch(incomingAccessProvider).value : null;
        return _Page(
          icon: KeptIcons.chat,
          title: l10n.fsIncomingTitle,
          body: [
            Text(l10n.fsIncomingBody, style: context.text.bodyLarge),
            Text(l10n.incomingWithout, style: context.text.bodyMedium),
            KeptCard(
              child: Column(
                spacing: 8,
                children: [
                  _SwitchRow(
                    l10n.settingsIncomingSwitch,
                    value: on,
                    onChanged: (v) => unawaited(_switchIncoming(v)),
                  ),
                  if (on) ...[
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        access == null
                            ? l10n.settingsIncomingAccess
                            : '${l10n.settingsIncomingAccess}: ${access ? l10n.settingsIncomingAccessOn : l10n.settingsIncomingAccessOff}',
                        style: context.text.bodyMedium,
                      ),
                    ),
                    if (access != true)
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: GreyButton(
                          small: true,
                          label: l10n.settingsIncomingOpenAccess,
                          onPressed: ref
                              .read(incomingListenerProvider)
                              .openAccessSettings,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
          actions: [
            MainButton(
              label: on ? l10n.fsContinue : l10n.fsNotNow,
              onPressed: () => _go(_Step.update),
            ),
          ],
        );
      case _Step.update:
        // In-app update, not in a Play build (update_controller.dart).
        final on =
            ref.watch(settingsProvider).value?.updateCheckEnabled ?? false;
        final update = ref.read(updateProvider.notifier);
        return _Page(
          icon: KeptIcons.gear,
          title: l10n.updateAskTitle,
          body: [
            Text(l10n.updateAskBody, style: context.text.bodyLarge),
            KeptCard(
              child: _SwitchRow(
                l10n.updateSwitch,
                value: on,
                onChanged: (v) => unawaited(update.setEnabled(v)),
              ),
            ),
          ],
          actions: [
            MainButton(
              label: on ? l10n.fsContinue : l10n.fsNotNow,
              onPressed: () async {
                // Either way the question is answered, so Home won't ask.
                await update.setEnabled(on);
                if (mounted) _go(_Step.done);
              },
            ),
          ],
        );
      case _Step.done:
        return _Page(
          icon: KeptIcons.check,
          title: l10n.fsDoneTitle,
          body: [Text(l10n.fsDoneBody, style: context.text.bodyLarge)],
          actions: [
            MainButton(
              label: l10n.fsDoneButton,
              onPressed: () => unawaited(_finish()),
            ),
          ],
        );
    }
  }

  /// Switching on stores the choice and leads to the system's page for
  /// notification access; the page shows the state when the user is back.
  Future<void> _switchIncoming(bool on) async {
    await switchIncoming(ref, on);
    if (on) await ref.read(incomingListenerProvider).openAccessSettings();
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow(this.label, {required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => onChanged(!value),
    child: Row(
      spacing: 12,
      children: [
        Expanded(child: Text(label, style: context.text.bodyLarge)),
        KeptSwitch(value: value, onChanged: onChanged),
      ],
    ),
  );
}

/// A page: an optional big icon, the title, the body, and the buttons at
/// the bottom.
class _Page extends StatelessWidget {
  const _Page({
    this.icon,
    required this.title,
    required this.body,
    required this.actions,
  });

  final KeptIcons? icon;
  final String title;
  final List<Widget> body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            if (icon != null) ...[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: KeptIcon(icon!, size: 56),
              ),
              const SizedBox(height: 14),
            ],
            Text(title, style: context.text.headlineLarge),
            const SizedBox(height: 14),
            for (final w in body) ...[w, const SizedBox(height: 14)],
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: actions,
        ),
      ),
    ],
  );
}
