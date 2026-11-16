import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/update_controller.dart';
import '../../l10n/app_localizations.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../people/refresh_contacts_screen.dart';
import '../widgets/grey_button.dart';
import '../widgets/kept_card.dart';
import '../widgets/kept_switch.dart';
import '../widgets/main_button.dart';
import '../widgets/section_label.dart';
import '../widgets/tag.dart';
import 'settings_actions.dart';

/// Opens "Permissions and privacy".
Future<void> openPermissions(BuildContext context) => Navigator.of(context)
    .push(MaterialPageRoute<void>(builder: (_) => const PermissionsScreen()));

/// One overview of everything Kept. may use (02-design.md §8, permissions
/// for 1.0.0). One card per part: what it is for, its state, what to do by
/// hand without it, and the control. The switches are the same ones as in
/// Settings, through [switchEveningQuestion] and [switchIncoming].
class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsState();
}

class _PermissionsState extends ConsumerState<PermissionsScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Back from a system page: any of the states may have changed.
    _lifecycle = AppLifecycleListener(
      onResume: () {
        ref.invalidate(contactsAccessProvider);
        ref.invalidate(notificationsEnabledProvider);
        ref.invalidate(incomingAccessProvider);
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _allowContacts() async {
    final source = ref.read(contactsSourceProvider);
    final granted = await source.requestAccess();
    // Asking does nothing after a "never ask again": go to the page.
    if (!granted) await source.openSettings();
    if (mounted) ref.invalidate(contactsAccessProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = ref.settings;
    final contacts = ref.watch(contactsAccessProvider).value;
    final notifications = ref.watch(notificationsEnabledProvider).value;
    final builtIn = ref.watch(incomingBuiltInProvider);
    final access = builtIn ? ref.watch(incomingAccessProvider).value : null;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.permTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          KeptCard(
            tone: context.kept.mintTone,
            child: Row(
              spacing: 12,
              children: [
                const KeptIcon(KeptIcons.check, size: 32),
                Expanded(
                  child: Text(
                    l10n.permNothingLeaves,
                    style: context.text.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _PartCard(
            icon: KeptIcons.people,
            title: l10n.permContactsTitle,
            state: contacts == null ? null : _allowed(l10n, contacts),
            use: l10n.permContactsUse,
            without: l10n.permContactsWithout,
            control: contacts == null
                ? null
                : GreyButton(
                    small: true,
                    label: contacts
                        ? l10n.openSettings
                        : l10n.permContactsAllow,
                    onPressed: contacts
                        ? ref.read(contactsSourceProvider).openSettings
                        : () => unawaited(_allowContacts()),
                  ),
          ),
          const SizedBox(height: 18),
          _PartCard(
            icon: KeptIcons.calendar,
            title: l10n.permNotifTitle,
            state: settings.eveningOn
                ? (notifications == false
                      ? _State(l10n.permStateNotAllowed, null)
                      : _State(l10n.permStateOn, KeptColors.mint))
                : _State(l10n.permStateOff, null),
            use: l10n.permNotifUse,
            without: l10n.permNotifWithout,
            control: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SwitchRow(
                  l10n.settingsEveningSwitch,
                  value: settings.eveningOn,
                  onChanged: (on) => unawaited(switchEveningQuestion(ref, on)),
                ),
                if (settings.eveningOn && notifications == false) ...[
                  Text(
                    l10n.settingsNotificationsOff,
                    style: context.text.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: GreyButton(
                      small: true,
                      label: l10n.settingsOpenNotificationSettings,
                      onPressed: ref.read(notificationsProvider).openSettings,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          _PartCard(
            icon: KeptIcons.gear,
            title: l10n.permBootTitle,
            state: _State(l10n.permStateAlways, KeptColors.mint),
            use: l10n.permBootUse,
            without: l10n.permBootWithout,
          ),
          const SizedBox(height: 18),
          _PartCard(
            icon: KeptIcons.gear,
            title: l10n.permVibrateTitle,
            state: _State(l10n.permStateAlways, KeptColors.mint),
            use: l10n.permVibrateUse,
            without: l10n.permVibrateWithout,
          ),
          const SizedBox(height: 18),
          // Only in a build with the listener (KEPT_INCOMING).
          if (builtIn) ...[
            _PartCard(
              icon: KeptIcons.chat,
              title: l10n.permAccessTitle,
              state: settings.incomingOn
                  ? (access == false
                        ? _State(l10n.permStateNotAllowed, null)
                        : _State(l10n.permStateOn, KeptColors.mint))
                  : _State(l10n.permStateOff, null),
              use: l10n.permAccessUse,
              without: l10n.incomingWithout,
              control: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SwitchRow(
                    l10n.settingsIncomingSwitch,
                    value: settings.incomingOn,
                    onChanged: (on) => unawaited(switchIncoming(ref, on)),
                  ),
                  if (settings.incomingOn)
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
              ),
            ),
            const SizedBox(height: 18),
          ],
          // In-app update, not in a Play build (update_controller.dart).
          _PartCard(
            icon: KeptIcons.gear,
            title: l10n.permUpdateTitle,
            state: settings.updateCheckEnabled
                ? _State(l10n.permStateOn, KeptColors.mint)
                : _State(l10n.permStateOff, null),
            use: l10n.permUpdateUse,
            sent: l10n.permUpdateSent,
            without: l10n.permUpdateWithout,
            control: _SwitchRow(
              l10n.updateSwitch,
              value: settings.updateCheckEnabled,
              onChanged: (on) =>
                  unawaited(ref.read(updateProvider.notifier).setEnabled(on)),
            ),
          ),
          const SizedBox(height: 18),
          _PartCard(
            icon: KeptIcons.stamp,
            title: l10n.permRefreshTitle,
            use: l10n.permRefreshUse,
            control: MainButton(
              label: l10n.permRefreshButton,
              onPressed: () => openRefreshContacts(context),
            ),
          ),
          const SizedBox(height: 24),
          SectionLabel(l10n.permNotUsedTitle),
          const SizedBox(height: 8),
          Text(l10n.permNotUsedList, style: context.text.bodyMedium),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  _State _allowed(AppLocalizations l10n, bool on) => on
      ? _State(l10n.permStateAllowed, KeptColors.mint)
      : _State(l10n.permStateNotAllowed, null);
}

/// A state tag: the word, and its accent (null is the plain grey tag).
class _State {
  const _State(this.label, this.accent);

  final String label;
  final Color? accent;
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

/// One part: icon, title and state tag, what it is for, that nothing is
/// sent (or, with [sent], what is), what to do by hand without it, and the
/// control.
class _PartCard extends StatelessWidget {
  const _PartCard({
    required this.icon,
    required this.title,
    required this.use,
    this.without,
    this.sent,
    this.state,
    this.control,
  });

  final KeptIcons icon;
  final String title;
  final _State? state;
  final String use;
  final String? without;
  final String? sent;
  final Widget? control;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return KeptCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Row(
            spacing: 12,
            children: [
              KeptIcon(icon, size: 28),
              Expanded(child: Text(title, style: context.text.titleLarge)),
              if (state != null) Tag(state!.label, accent: state!.accent),
            ],
          ),
          Text(use, style: context.text.bodyMedium),
          Text(sent ?? l10n.permNothingSent, style: context.text.bodyMedium),
          if (without != null)
            Text(
              without!,
              style: context.text.bodyMedium?.copyWith(
                color: context.kept.text,
              ),
            ),
          ?control,
        ],
      ),
    );
  }
}
