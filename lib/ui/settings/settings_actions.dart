import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';

/// Switches the evening question on or off. Switching on asks for the
/// notification permission again; Android itself stops showing the dialog
/// after the user has said no twice. Used by Settings, "Permissions and
/// privacy" and the first-start flow, so there is one implementation.
/// Returns whether notifications are allowed afterwards.
Future<bool> switchEveningQuestion(WidgetRef ref, bool on) async {
  final services = ref.read(servicesProvider);
  final notifications = ref.read(notificationsProvider);
  await services.settings.update(
    (s) => s.copyWith(
      eveningOn: on,
      notificationPermissionAsked: on ? true : null,
    ),
  );
  if (!on) return false;
  final allowed = await notifications.requestPermission();
  if (ref.context.mounted) ref.invalidate(notificationsEnabledProvider);
  return allowed;
}

/// Switches the optional notification listener's recording on or off
/// (IncomingSync passes it on). Never opens a page by itself.
Future<void> switchIncoming(WidgetRef ref, bool on) => ref
    .read(servicesProvider)
    .settings
    .update((s) => s.copyWith(incomingOn: on));
