import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/app.dart';
import 'package:kept/app/providers.dart';
import 'package:kept/app/services.dart';
import 'package:kept/app/update_controller.dart';
import 'package:kept/data/app_settings.dart';
import 'package:kept/data/database.dart';
import 'package:kept/data/settings_repository.dart';
import 'package:kept/domain/app_update.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/platform/app_shortcuts.dart';
import 'package:kept/platform/app_update.dart' show releasesPageUrl;
import 'package:kept/platform/link_opener.dart';
import 'package:kept/ui/material.dart';
import 'package:kept/ui/settings/settings_screen.dart';

import 'fake_incoming_listener.dart';
import 'fake_notifications.dart';
import 'fake_update_service.dart';

void main() {
  late AppServices services;
  late FakeUpdateService fake;
  late _FakeLinks links;

  setUp(() {
    services = AppServices(
      db: AppDatabase(NativeDatabase.memory()),
      openDemo: () => AppDatabase(NativeDatabase.memory()),
    );
    fake = FakeUpdateService();
    links = _FakeLinks();
  });

  /// One person, the first start done; [settings] changes more.
  Future<void> start(
    WidgetTester tester, {
    Widget? home,
    AppSettings Function(AppSettings)? settings,
    Future<void> Function()? before,
  }) async {
    tester.view.physicalSize = const Size(400, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      await services
          .peopleFor(demo: false)
          .add(name: 'Tom', closeness: Closeness.close);
      await services.settings.update(
        (s) => (settings ?? (s) => s)(s.copyWith(firstStartDone: true)),
      );
      await before?.call();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          servicesProvider.overrideWithValue(services),
          updateServiceProvider.overrideWithValue(fake),
          notificationsProvider.overrideWithValue(FakeNotifications()),
          incomingListenerProvider.overrideWithValue(FakeIncomingListener()),
          appShortcutsProvider.overrideWithValue(_NoShortcuts()),
          linkOpenerProvider.overrideWithValue(links),
        ],
        child: KeptApp(home: home),
      ),
    );
    await settle(tester);
  }

  Future<AppSettings> load(WidgetTester tester) async =>
      (await tester.runAsync(services.settings.load))!;

  Future<void> closeDown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(services.close);
  }

  group('the card on Home', () {
    testWidgets('asks an install that was never asked; Yes switches on', (
      tester,
    ) async {
      await start(tester);
      expect(find.text('Check GitHub for new versions?'), findsOneWidget);
      expect(find.textContaining('none of your data is ever sent'), findsOne);
      expect(find.textContaining('update by hand from GitHub'), findsOne);
      expect(find.textContaining('Android will ask once'), findsOne);
      // Off until chosen: nothing was fetched at start.
      expect(fake.networkRequests, isEmpty);

      await tester.tap(find.text('Yes'));
      await settle(tester);
      final s = await load(tester);
      expect(s.updateCheckEnabled, isTrue);
      expect(s.updateCheckAsked, isTrue);
      expect(find.text('Check GitHub for new versions?'), findsNothing);
      await closeDown(tester);
    });

    testWidgets('Not now leaves it off and the card does not come back', (
      tester,
    ) async {
      await start(tester);
      await tester.tap(find.text('Not now'));
      await settle(tester);
      final s = await load(tester);
      expect(s.updateCheckEnabled, isFalse);
      expect(s.updateCheckAsked, isTrue);
      expect(find.text('Check GitHub for new versions?'), findsNothing);
      expect(fake.networkRequests, isEmpty);
      await closeDown(tester);
    });

    testWidgets('an answered install sees no card', (tester) async {
      await start(tester, settings: (s) => s.copyWith(updateCheckAsked: true));
      expect(find.text('Check GitHub for new versions?'), findsNothing);
      await closeDown(tester);
    });
  });

  group('on start', () {
    testWidgets('with the check off nothing is fetched and nothing shows', (
      tester,
    ) async {
      fake
        ..failOnNetwork = true
        ..latest = fakeRelease()
        ..installed = '1.1.0'
        ..releases = [ReleaseNotes(AppVersion.tryParse('1.1.0')!, '- X')];
      await start(
        tester,
        settings: (s) => s.copyWith(updateCheckAsked: true),
        before: () => services.settings.setStatus(
          SettingsRepository.lastRunVersion,
          '1.0.0',
        ),
      );
      expect(find.byType(AlertDialog), findsNothing);
      expect(fake.networkRequests, isEmpty);
      await closeDown(tester);
    });

    testWidgets("with the check on: What's new, then the update popup once", (
      tester,
    ) async {
      fake
        ..installed = '1.1.0'
        ..latest = fakeRelease('1.2.0')
        ..releases = [
          ReleaseNotes(AppVersion.tryParse('1.1.0')!, '## New\n\n- Ideas'),
        ];
      await start(
        tester,
        settings: (s) =>
            s.copyWith(updateCheckAsked: true, updateCheckEnabled: true),
        before: () => services.settings.setStatus(
          SettingsRepository.lastRunVersion,
          '1.0.0',
        ),
      );
      expect(find.text("What's new in version 1.1.0"), findsOneWidget);
      expect(find.text('Ideas'), findsOneWidget);
      await tester.tap(find.text('Close'));
      await settle(tester);

      expect(find.text('Update to version 1.2.0'), findsOneWidget);
      expect(find.text('Something new'), findsOneWidget);
      expect(find.text('CI'), findsNothing);
      await tester.tap(find.text('Later'));
      await settle(tester);
      expect(find.byType(AlertDialog), findsNothing);
      await closeDown(tester);
    });
  });

  group('Settings', () {
    Future<void> openSection(WidgetTester tester) async {
      await tester.scrollUntilVisible(find.text('Releases on GitHub'), 300);
      await settle(tester);
    }

    testWidgets('off: one line, and the releases page', (tester) async {
      await start(
        tester,
        home: const SettingsScreen(),
        settings: (s) => s.copyWith(updateCheckAsked: true),
      );
      await openSection(tester);
      expect(find.textContaining('The check is off'), findsOneWidget);
      expect(find.text('Check for updates'), findsNothing);
      expect(find.text('Delete update file'), findsNothing);
      await tester.tap(find.text('Releases on GitHub'));
      await settle(tester);
      expect(links.opened, [releasesPageUrl]);
      expect(fake.networkRequests, isEmpty);
      await closeDown(tester);
    });

    testWidgets('on: the tiles; check, find and install an update', (
      tester,
    ) async {
      await start(
        tester,
        home: const SettingsScreen(),
        settings: (s) =>
            s.copyWith(updateCheckAsked: true, updateCheckEnabled: true),
      );
      await openSection(tester);
      expect(find.textContaining('The check is off'), findsNothing);
      expect(find.text('Check for updates'), findsOneWidget);
      expect(find.text('Delete update file'), findsOneWidget);
      expect(find.text('No file stored'), findsOneWidget);
      expect(find.text('Releases on GitHub'), findsOneWidget);

      // Up to date.
      await tester.tap(find.text('Check for updates'));
      await settle(tester);
      expect(find.text('Kept. is up to date.'), findsOneWidget);
      expect(find.textContaining('Version 1.0.0 · up to date'), findsOne);

      // A new version: the popup, then the update.
      fake.latest = fakeRelease();
      await tester.tap(find.text('Check for updates'));
      await settle(tester);
      expect(find.text('Update to version 1.1.0'), findsWidgets);
      await tester.tap(find.text('Update'));
      await settle(tester);
      expect(fake.installs, 1);
      expect(find.textContaining('Confirm the installation'), findsOneWidget);
      await tester.tap(find.text('Close'));
      await settle(tester);
      expect(find.text('Restart update'), findsOneWidget);
      expect(find.text('Uses 2.0 MB'), findsOneWidget);

      // Switching off removes the tiles and the file.
      await tester.tap(find.text('Check GitHub for new versions'));
      await settle(tester);
      expect(find.textContaining('The check is off'), findsOneWidget);
      expect(find.text('Restart update'), findsNothing);
      expect(fake.deletes, 1);
      await closeDown(tester);
    });
  });
}

class _FakeLinks implements LinkOpener {
  final opened = <String>[];

  @override
  Future<bool> open(String link) async {
    opened.add(link);
    return true;
  }
}

class _NoShortcuts implements AppShortcuts {
  @override
  Future<void> setUp({
    required String captureTitle,
    required VoidCallback onCapture,
  }) async {}
}

Future<void> settle(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}
