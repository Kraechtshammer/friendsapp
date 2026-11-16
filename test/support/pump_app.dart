import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/app.dart';
import 'package:kept/app/providers.dart';
import 'package:kept/app/services.dart';
import 'package:kept/platform/chat_opener.dart';
import 'package:kept/platform/notifications.dart';
import 'package:kept/platform/app_shortcuts.dart';

import '../fake_notifications.dart';
import 'fakes.dart';

/// Pumps [KeptApp] on [services] with the usual test overrides: no first-start
/// flow, fake notifications, no shortcuts and a fixed clock. [viewSize] sets
/// the test window (reset at the end). [overrides] come last and win.
/// Does not settle: the caller pumps as its screen needs.
Future<void> pumpKeptApp(
  WidgetTester tester, {
  required AppServices services,
  required DateTime Function() clock,
  Size? viewSize,
  Notifications? notifications,
  ChatOpener? opener,
  AppShortcuts? shortcuts,
  List<Override> overrides = const [],
}) async {
  if (viewSize != null) {
    tester.view.physicalSize = viewSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        servicesProvider.overrideWithValue(services),
        firstStartEnabledProvider.overrideWithValue(false),
        notificationsProvider.overrideWithValue(
          notifications ?? FakeNotifications(),
        ),
        appShortcutsProvider.overrideWithValue(shortcuts ?? NoShortcuts()),
        if (opener != null) chatOpenerProvider.overrideWithValue(opener),
        clockProvider.overrideWithValue(clock),
        ...overrides,
      ],
      child: const KeptApp(),
    ),
  );
}
