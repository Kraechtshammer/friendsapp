import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/app.dart';
import 'package:kept/app/licences.dart';
import 'package:kept/app/providers.dart';
import 'package:kept/app/theme.dart';
import 'package:kept/app/services.dart';
import 'package:kept/data/app_settings.dart';
import 'package:kept/data/database.dart';
import 'package:kept/data/settings_repository.dart';
import 'package:kept/domain/first_start.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/platform/app_shortcuts.dart';
import 'package:kept/platform/contacts.dart';
import 'package:kept/ui/material.dart';
import 'package:kept/ui/settings/permissions_screen.dart';
import 'package:kept/ui/settings/settings_screen.dart';
import 'package:kept/ui/widgets/grey_button.dart';

import 'dart:io';

import 'fake_contacts.dart';
import 'fake_incoming_listener.dart';
import 'fake_notifications.dart';

class _NoShortcuts implements AppShortcuts {
  @override
  Future<void> setUp({
    required String captureTitle,
    required VoidCallback onCapture,
  }) async {}
}

void main() {
  test('the first-start rule', () {
    expect(showFirstStart(done: false, peopleCount: 0), isTrue);
    expect(showFirstStart(done: false, peopleCount: 3), isFalse);
    expect(showFirstStart(done: true, peopleCount: 0), isFalse);
    expect(showFirstStart(done: true, peopleCount: 3), isFalse);
  });

  test('the version constant matches pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version: (\d+\.\d+\.\d+)',
      multiLine: true,
    ).firstMatch(pubspec)![1];
    expect(appVersion, version);
  });

  group('Family stamp weight fix', () {
    late AppDatabase db;
    late SettingsRepository repo;
    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = SettingsRepository(db);
    });
    tearDown(() => db.close());

    Future<String?> stored() async => (await (db.select(
      db.settings,
    )..where((s) => s.key.equals('stampFamily'))).getSingleOrNull())?.value;

    test('a stored 1 is removed once, so the start value 2 applies', () async {
      await db
          .into(db.settings)
          .insert(SettingsCompanion.insert(key: 'stampFamily', value: '1'));
      expect((await repo.load()).stampWeights.family, 1);
      await repo.fixFamilyStampWeight();
      expect(await stored(), isNull);
      final s = await repo.load();
      expect(s.stampWeights.family, 2);
      expect(s.familyWeightFixed, isTrue);

      // After the fix, a 1 the user chooses stays.
      await repo.update(
        (s) => s.copyWith(stampWeights: s.stampWeights.copyWith(family: 1)),
      );
      await repo.fixFamilyStampWeight();
      expect(await stored(), '1');
    });

    test('other values stay, and the fix is remembered', () async {
      await db
          .into(db.settings)
          .insert(SettingsCompanion.insert(key: 'stampFamily', value: '3'));
      await repo.fixFamilyStampWeight();
      expect((await repo.load()).stampWeights.family, 3);
      expect((await repo.load()).familyWeightFixed, isTrue);
    });
  });

  group('screens', () {
    late AppServices services;
    late FakeNotifications notifications;
    late FakeIncomingListener listener;
    late FakeContacts contacts;

    setUp(() {
      services = AppServices(
        db: AppDatabase(NativeDatabase.memory()),
        openDemo: () => AppDatabase(NativeDatabase.memory()),
      );
      notifications = FakeNotifications(enabled: false);
      listener = FakeIncomingListener();
      contacts = FakeContacts(const [
        PhoneContact(id: 'c1', name: 'Anna Adler', phones: ['0170 1234567']),
        PhoneContact(id: 'c2', name: 'Ben Bauer'),
        PhoneContact(id: 'c3', name: 'Cora Carl'),
      ]);
    });

    Future<void> start(
      WidgetTester tester, {
      Widget? home,
      bool firstStart = true,
    }) async {
      tester.view.physicalSize = const Size(360, 6000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            servicesProvider.overrideWithValue(services),
            firstStartEnabledProvider.overrideWithValue(firstStart),
            notificationsProvider.overrideWithValue(notifications),
            incomingListenerProvider.overrideWithValue(listener),
            contactsSourceProvider.overrideWithValue(contacts),
            appShortcutsProvider.overrideWithValue(_NoShortcuts()),
          ],
          child: KeptApp(home: home),
        ),
      );
      await settle(tester);
    }

    Future<AppSettings> settings(WidgetTester tester) async =>
        (await tester.runAsync(services.settings.load))!;

    Future<List<Person>> people(WidgetTester tester) async => (await tester
        .runAsync(() => services.peopleFor(demo: false).watchAll().first))!;

    Future<void> closeDown(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      await tester.runAsync(services.close);
    }

    testWidgets('a fresh install gets the flow, asking nothing at start', (
      tester,
    ) async {
      await start(tester);
      expect(find.text('Welcome to Kept.'), findsOneWidget);
      expect(find.textContaining('No account, no server'), findsOneWidget);
      expect(notifications.permissionRequests, 0);
      await closeDown(tester);
    });

    testWidgets('someone with people never sees it, and the flag is set', (
      tester,
    ) async {
      await tester.runAsync(
        () => services
            .peopleFor(demo: false)
            .add(name: 'Tom', closeness: Closeness.close),
      );
      await start(tester);
      expect(find.text('Welcome to Kept.'), findsNothing);
      expect((await settings(tester)).firstStartDone, isTrue);
      await closeDown(tester);
    });

    testWidgets('a finished flow does not come back', (tester) async {
      await tester.runAsync(
        () => services.settings.update((s) => s.copyWith(firstStartDone: true)),
      );
      await start(tester);
      expect(find.text('Welcome to Kept.'), findsNothing);
      await closeDown(tester);
    });

    testWidgets('the main path: contacts, classes, evening, not now, done', (
      tester,
    ) async {
      await start(tester);
      await tester.tap(find.text("Let's go"));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Android asks you for permission'),
        findsOneWidget,
      );
      await tester.tap(find.text('Add from contacts'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Anna Adler'));
      await tester.tap(find.text('Ben Bauer'));
      await tester.pump();
      await tester.tap(find.text('Next (2)'));
      await tester.pumpAndSettle();

      // The legend and four icon buttons per person.
      expect(find.text('How close are you?'), findsOneWidget);
      expect(find.byTooltip('Close friend'), findsNWidgets(2));
      expect(find.byTooltip('Now and then'), findsNWidgets(2));
      expect(find.byTooltip('A few times a year'), findsNWidgets(2));
      expect(find.byTooltip('Family'), findsNWidgets(2));
      await tester.tap(find.byTooltip('Family').first);
      await tester.pump();
      await tester.tap(find.text('Add 2 people'));
      await settle(tester);

      // Evening page: nothing asked before Continue.
      expect(find.text('A question in the evening'), findsOneWidget);
      expect(find.text('7:00 PM'), findsOneWidget);
      expect(notifications.permissionRequests, 0);
      await tester.tap(find.text('Continue'));
      await settle(tester);
      expect(notifications.permissionRequests, 1);

      // Incoming page: off, "Not now" is the main button.
      expect(find.text('Notice who wrote or called'), findsWidgets);
      expect(find.text('Not now'), findsOneWidget);
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(find.text('You are all set'), findsOneWidget);
      await tester.tap(find.text('Go to Home'));
      await settle(tester);

      final s = await settings(tester);
      expect(s.firstStartDone, isTrue);
      expect(s.eveningOn, isTrue);
      expect(s.incomingOn, isFalse);
      expect(listener.accessSettingsOpened, 0);
      final saved = await people(tester);
      expect(saved.map((p) => p.name), ['Anna Adler', 'Ben Bauer']);
      final anna = saved.firstWhere((p) => p.name == 'Anna Adler');
      expect(anna.closeness, Closeness.family);
      expect(anna.contactId, 'c1');
      expect(find.text('Welcome to Kept.'), findsNothing);
      await closeDown(tester);
    });

    testWidgets('by hand, evening off, incoming on leads to the system page', (
      tester,
    ) async {
      await start(tester);
      await tester.tap(find.text("Let's go"));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add by hand later'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ask me in the evening'));
      await tester.pump();
      expect(find.textContaining('everything waits on Home'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await settle(tester);
      expect(notifications.permissionRequests, 0);

      await tester.tap(find.text('Notice who wrote or called').last);
      await settle(tester);
      expect(listener.accessSettingsOpened, 1);
      expect((await settings(tester)).incomingOn, isTrue);
      expect(find.textContaining('Not allowed yet'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Go to Home'));
      await settle(tester);
      final s = await settings(tester);
      expect(s.eveningOn, isFalse);
      expect(s.firstStartDone, isTrue);
      expect(await people(tester), isEmpty);
      await closeDown(tester);
    });

    testWidgets('skip leaves everything optional off', (tester) async {
      await start(tester);
      await tester.tap(find.text('Skip'));
      await settle(tester);
      final s = await settings(tester);
      expect(s.firstStartDone, isTrue);
      expect(s.eveningOn, isFalse);
      expect(s.incomingOn, isFalse);
      expect(notifications.permissionRequests, 0);
      expect(find.text('Welcome to Kept.'), findsNothing);
      await closeDown(tester);
    });

    testWidgets('the permissions page shows the states and the controls', (
      tester,
    ) async {
      await tester.runAsync(
        () => services.settings.update((s) => s.copyWith(firstStartDone: true)),
      );
      contacts.granted = false;
      await start(tester, home: const PermissionsScreen());
      expect(find.textContaining('No account, no server'), findsOneWidget);
      expect(find.textContaining('internet'), findsNothing);
      expect(find.text('Contacts (read only)'), findsOneWidget);
      expect(find.text('Not allowed'), findsWidgets);
      expect(find.text('Always allowed'), findsNWidgets(2));
      expect(find.text('Vibrate'), findsOneWidget);
      expect(find.text('Allow contacts'), findsOneWidget);
      // Evening is on by default but notifications are not allowed.
      expect(find.text('Open notification settings'), findsOneWidget);
      await tester.tap(find.text('Open notification settings'));
      expect(notifications.settingsOpened, 1);

      await tester.tap(find.text('Allow contacts'));
      await settle(tester);
      expect(contacts.requests, 1);
      expect(contacts.settingsOpened, 1);

      // The existing switch for incoming messages.
      await tester.tap(find.text('Notice who wrote or called'));
      await settle(tester);
      expect((await settings(tester)).incomingOn, isTrue);
      expect(find.textContaining('call log'), findsOneWidget);
      await closeDown(tester);
    });

    testWidgets('Settings leads to the permissions page and the licences', (
      tester,
    ) async {
      await tester.runAsync(
        () => services.settings.update((s) => s.copyWith(firstStartDone: true)),
      );
      await start(tester, home: const SettingsScreen());
      await tester.tap(find.text('Permissions and privacy'));
      await settle(tester);
      expect(find.byType(PermissionsScreen), findsOneWidget);
      await tester.pageBack();
      await settle(tester);

      await tester.scrollUntilVisible(find.text('About and licences'), 300);
      await tester.tap(find.text('About and licences'));
      await settle(tester);
      expect(find.byType(LicensePage), findsOneWidget);
      expect(find.text('Kept.'), findsWidgets);
      expect(find.text(appVersion), findsOneWidget);
      await closeDown(tester);
    });

    testWidgets('a long grey label shrinks instead of being cut', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildTheme(Brightness.dark),
            home: Scaffold(
              body: SizedBox(
                width: 110,
                child: GreyButton(label: 'Congratulated', onPressed: () {}),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Congratulated'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

Future<void> settle(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}
