import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/app_settings.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/grey_icon_button.dart';
import '../widgets/kept_switch.dart';
import 'settings_actions.dart';

/// Incoming messages (02-design.md §2.6): the switch for the optional
/// notification listener, what it reads, whether notification access is
/// granted, and the waiting time before a reply counts as owed. The
/// waiting time also applies to "They wrote" entered by hand, so it shows
/// with the switch off too. HomeShell passes the switch on to the listener
/// (IncomingSync). In a build without the listener (no KEPT_INCOMING,
/// [incomingBuiltInProvider]) only the waiting time shows.
class IncomingSection extends ConsumerStatefulWidget {
  const IncomingSection({super.key, required this.settings});

  final AppSettings settings;

  @override
  ConsumerState<IncomingSection> createState() => IncomingSectionState();
}

class IncomingSectionState extends ConsumerState<IncomingSection> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Back from the system page: access may have changed.
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(incomingAccessProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _switch(bool on) => switchIncoming(ref, on);

  Future<void> _setWait(int days) => ref
      .read(servicesProvider)
      .settings
      .update((s) => s.copyWith(replyWaitDays: days));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final builtIn = ref.watch(incomingBuiltInProvider);
    final on = builtIn && widget.settings.incomingOn;
    final wait = widget.settings.replyWaitDays;
    final access = on ? ref.watch(incomingAccessProvider).value : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.settingsIncoming.toUpperCase(),
          style: context.text.labelMedium,
        ),
        if (builtIn) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsIncomingSwitch),
            trailing: KeptSwitch(
              value: on,
              onChanged: (v) => unawaited(_switch(v)),
            ),
            onTap: () => unawaited(_switch(!on)),
          ),
          Text(l10n.settingsIncomingHelp, style: context.text.bodyMedium),
        ],
        if (on) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsIncomingAccess),
            trailing: access == null
                ? null
                : Text(
                    access
                        ? l10n.settingsIncomingAccessOn
                        : l10n.settingsIncomingAccessOff,
                    style: context.text.labelLarge,
                  ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: context.kept.text,
              ),
              onPressed: () => unawaited(
                ref.read(incomingListenerProvider).openAccessSettings(),
              ),
              child: Text(l10n.settingsIncomingOpenAccess),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: Text(
                l10n.settingsReplyWait,
                style: context.text.bodyLarge,
              ),
            ),
            GreyIconButton(
              icon: Icons.remove_rounded,
              tooltip: l10n.shorter,
              size: 44,
              radius: 14,
              onPressed: wait > AppSettings.minReplyWaitDays
                  ? () => unawaited(_setWait(wait - 1))
                  : null,
            ),
            SizedBox(
              width: 64,
              child: Text(
                l10n.replyWaitDays(wait),
                textAlign: TextAlign.center,
                style: context.text.labelLarge,
              ),
            ),
            GreyIconButton(
              icon: Icons.add_rounded,
              tooltip: l10n.longer,
              size: 44,
              radius: 14,
              onPressed: wait < AppSettings.maxReplyWaitDays
                  ? () => unawaited(_setWait(wait + 1))
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}
