import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/licences.dart';
import 'package:kept/app/providers.dart';
import 'package:kept/app/services.dart';
import 'package:kept/app/update_controller.dart';
import 'package:kept/data/database.dart';
import 'package:kept/data/settings_repository.dart';
import 'package:kept/domain/app_update.dart';
import 'package:kept/platform/app_update.dart';

import 'fake_update_service.dart';

AppVersion v(String text) => AppVersion.tryParse(text)!;

void main() {
  late AppServices services;
  late FakeUpdateService fake;
  late ProviderContainer container;

  setUp(() {
    services = AppServices(
      db: AppDatabase(NativeDatabase.memory()),
      openDemo: () => AppDatabase(NativeDatabase.memory()),
    );
    fake = FakeUpdateService();
    container = ProviderContainer(
      overrides: [
        servicesProvider.overrideWithValue(services),
        updateServiceProvider.overrideWithValue(fake),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await services.close();
  });

  UpdateController controller() => container.read(updateProvider.notifier);
  UpdateState state() => container.read(updateProvider);

  Future<void> switchOn() => services.settings.update(
    (s) => s.copyWith(updateCheckEnabled: true, updateCheckAsked: true),
  );

  group('the check is off', () {
    test('no path makes a network request', () async {
      fake
        ..failOnNetwork = true
        ..latest = fakeRelease()
        ..releases = [ReleaseNotes(v('1.0.0'), '## New\n\n- A')];
      // An install that ran an older version before: What's new would be due.
      await services.settings.setStatus(
        SettingsRepository.lastRunVersion,
        '0.9.0',
      );
      await services.settings.update((s) => s.copyWith(firstStartDone: true));
      final c = controller();

      await c.checkIfDue();
      expect(await c.check(), isFalse);
      await c.resumed();
      await c.install();
      expect(await c.whatsNewOnStart(), isNull);
      await expectLater(c.whatsNew(), throwsA(isA<UpdateCheckOff>()));
      await c.markVersionSeen();
      expect(await c.popupDue(), isFalse);

      expect(fake.networkRequests, isEmpty);
      expect(fake.downloads, 0);
      expect(fake.installs, 0);
      expect(state().latest, isNull);
      expect(state().problem, isNull);
      expect(
        await services.settings.status(SettingsRepository.lastUpdateCheck),
        isNull,
      );
    });

    test('switching off forgets the update and deletes the file', () async {
      await switchOn();
      fake.latest = fakeRelease();
      expect(await controller().check(), isTrue);
      expect(state().latest, isNotNull);

      await controller().setEnabled(false);
      final s = await services.settings.load();
      expect(s.updateCheckEnabled, isFalse);
      expect(s.updateCheckAsked, isTrue);
      expect(state().latest, isNull);
      expect(fake.deletes, 1);

      fake.failOnNetwork = true;
      await controller().checkIfDue();
      expect(fake.networkRequests, ['fetchLatest']);
    });

    test('the default is off, and asking is not done yet', () async {
      final s = await services.settings.load();
      expect(s.updateCheckEnabled, isFalse);
      expect(s.updateCheckAsked, isFalse);
    });
  });

  group('the check is on', () {
    setUp(switchOn);

    test('finds a newer release, remembers the time, cleans up once', () async {
      fake.latest = fakeRelease();
      await controller().checkIfDue();
      expect(state().latest?.version, v('1.1.0'));
      expect(state().installed, v('1.0.0'));
      expect(state().phase, UpdatePhase.idle);
      expect(fake.cleanUps, 1);
      expect(
        await services.settings.status(SettingsRepository.lastUpdateCheck),
        isNotNull,
      );

      // Within 30 minutes: no second request, no second clean-up.
      await controller().checkIfDue();
      expect(fake.networkRequests, ['fetchLatest']);
      expect(fake.cleanUps, 1);
    });

    test('the same or an older release is no update', () async {
      fake.latest = fakeRelease('1.0.0');
      expect(await controller().check(), isTrue);
      expect(state().latest, isNull);
    });

    test(
      'GitHub not reachable is a problem, and check returns false',
      () async {
        fake.fetchError = const SocketExceptionLike();
        expect(await controller().check(), isFalse);
        expect(state().problem, UpdateProblem.checkFailed);
        expect(state().phase, UpdatePhase.idle);
      },
    );

    test('the popup is due once per version', () async {
      fake.latest = fakeRelease();
      await controller().check();
      expect(await controller().popupDue(), isTrue);
      await controller().markPopupShown();
      expect(await controller().popupDue(), isFalse);

      fake.latest = fakeRelease('1.2.0');
      await controller().check();
      expect(await controller().popupDue(), isTrue);
    });

    test('install downloads, then hands the APK to Android', () async {
      fake.latest = fakeRelease();
      await controller().check();
      await controller().install();
      expect(fake.downloads, 1);
      expect(fake.installs, 1);
      expect(state().phase, UpdatePhase.installing);
      expect(state().apkReady, isTrue);
      expect(state().progress, 1);

      // Cancelled in Android's dialog; a restart needs no second download.
      fake.sendResult(InstallResult.aborted);
      await pumpEventQueue();
      expect(state().problem, UpdateProblem.installAborted);
      expect(state().phase, UpdatePhase.idle);
      await controller().install();
      expect(fake.downloads, 1);
      expect(fake.installs, 2);
      expect(state().problem, isNull);
    });

    test('a failed download and a refused install are problems', () async {
      fake
        ..latest = fakeRelease()
        ..downloadError = const SocketExceptionLike();
      await controller().check();
      await controller().install();
      expect(state().problem, UpdateProblem.downloadFailed);
      expect(fake.installs, 0);

      fake
        ..downloadError = null
        ..installError = installRefused();
      await controller().install();
      expect(state().problem, UpdateProblem.installFailed);
      expect(state().problemMessage, 'signatures differ');

      fake.installError = null;
      await controller().install();
      fake.sendResult(1, 'INSTALL_FAILED_UPDATE_INCOMPATIBLE');
      await pumpEventQueue();
      expect(state().problem, UpdateProblem.installFailed);
      expect(state().problemMessage, 'INSTALL_FAILED_UPDATE_INCOMPATIBLE');
    });

    test('without the install permission it opens the switch and goes on '
        'after resume', () async {
      fake
        ..latest = fakeRelease()
        ..allowed = false;
      await controller().check();
      await controller().install();
      expect(fake.permissionOpened, 1);
      expect(fake.downloads, 0);

      // Back without allowing it.
      await controller().resumed();
      expect(state().problem, UpdateProblem.noPermission);

      // Again, this time allowed: the update continues by itself.
      await controller().install();
      fake.allowed = true;
      await controller().resumed();
      expect(fake.downloads, 1);
      expect(fake.installs, 1);
      expect(state().phase, UpdatePhase.installing);
    });

    test('delete files ends a hung install', () async {
      fake.latest = fakeRelease();
      await controller().check();
      await controller().install();
      await controller().deleteFiles();
      expect(state().phase, UpdatePhase.idle);
      expect(state().filesSize, 0);
      expect(state().apkReady, isFalse);
    });
  });

  group("What's new on start", () {
    final releases = [
      ReleaseNotes(v('1.1.0'), '## New\n\n- B'),
      ReleaseNotes(v('1.0.0'), '## Fixed\n\n- A'),
    ];

    setUp(() async {
      await switchOn();
      fake.releases = releases;
    });

    test('a fresh install shows nothing and fetches nothing', () async {
      fake.installed = '1.1.0';
      expect(await controller().whatsNewOnStart(), isNull);
      expect(fake.networkRequests, isEmpty);
    });

    test('after the first start, the version counts as seen', () async {
      fake.installed = '1.0.0';
      await controller().markVersionSeen();
      await services.settings.update((s) => s.copyWith(firstStartDone: true));
      expect(await controller().whatsNewOnStart(), isNull);
      expect(fake.networkRequests, isEmpty);
    });

    test('after an update it shows the new changes once', () async {
      await services.settings.update((s) => s.copyWith(firstStartDone: true));
      await services.settings.setStatus(
        SettingsRepository.lastRunVersion,
        '1.0.0',
      );
      fake.installed = '1.1.0';
      final whatsNew = await controller().whatsNewOnStart();
      expect(whatsNew?.version, v('1.1.0'));
      expect(whatsNew?.sections.single.items, ['B']);
      expect(whatsNew?.earlier.map((r) => '${r.version}'), ['1.0.0']);
      expect(
        await services.settings.status(SettingsRepository.lastRunVersion),
        '1.1.0',
      );
      expect(await controller().whatsNewOnStart(), isNull);
    });

    test('with GitHub not reachable it tries again later', () async {
      await services.settings.update((s) => s.copyWith(firstStartDone: true));
      await services.settings.setStatus(
        SettingsRepository.lastRunVersion,
        '1.0.0',
      );
      fake
        ..installed = '1.1.0'
        ..fetchError = const SocketExceptionLike();
      expect(await controller().whatsNewOnStart(), isNull);
      expect(
        await services.settings.status(SettingsRepository.lastRunVersion),
        '1.0.0',
      );
    });

    test('Settings falls back to the stored notes offline', () async {
      fake.installed = '1.1.0';
      final online = await controller().whatsNew();
      expect(online.sections.single.items, ['B']);
      fake.fetchError = const SocketExceptionLike();
      final offline = await controller().whatsNew();
      expect(offline.sections.single.items, ['B']);
    });
  });

  test(
    'the licence page gets the installed version, else the constant',
    () async {
      fake.installed = '2.3.4';
      expect(await container.read(installedVersionProvider.future), '2.3.4');
      fake.installed = null;
      container.invalidate(installedVersionProvider);
      expect(await container.read(installedVersionProvider.future), appVersion);
    },
  );
}

/// A network error, without opening a socket.
class SocketExceptionLike implements Exception {
  const SocketExceptionLike();
}
