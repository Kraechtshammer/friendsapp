import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/app.dart';
import 'package:kept/app/providers.dart';
import 'package:kept/app/services.dart';
import 'package:kept/data/app_settings.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/chat_link.dart';
import 'package:kept/domain/contact_event.dart';
import 'package:kept/domain/incoming_contact.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/platform/app_shortcuts.dart';
import 'package:kept/platform/chat_opener.dart';
import 'package:kept/platform/contacts.dart';
import 'package:kept/ui/material.dart';

import 'fake_incoming_listener.dart';
import 'fake_notifications.dart';

void main() {
  late AppServices services;
  late FakeIncomingListener listener;
  late Person tom;
  final now = DateTime(2026, 11, 16, 20);
  final opener = _FakeOpener();

  setUp(() {
    opener.opened.clear();
    listener = FakeIncomingListener();
    services = AppServices(
      db: AppDatabase(NativeDatabase.memory()),
      openDemo: () => AppDatabase(NativeDatabase.memory()),
    );
  });

  /// Tom (WhatsApp, linked to a contact) and Anna. [on] switches the
  /// listener on before the start; [settings] changes more.
  Future<void> start(
    WidgetTester tester, {
    bool on = false,
    AppSettings Function(AppSettings)? settings,
    void Function()? beforePump,
  }) async {
    tester.view.physicalSize = const Size(400, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      final people = services.peopleFor(demo: false);
      tom = await people.add(
        name: 'Tom',
        closeness: Closeness.close,
        mainMessenger: Messenger.whatsapp,
        phone: '+4900000000101',
        contactId: 'c1',
      );
      await people.add(name: 'Anna', closeness: Closeness.nowAndThen);
      await services.settings.update(
        (s) => (settings ?? (s) => s)(s.copyWith(incomingOn: on)),
      );
    });
    beforePump?.call();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          servicesProvider.overrideWithValue(services),
          notificationsProvider.overrideWithValue(FakeNotifications()),
          appShortcutsProvider.overrideWithValue(_NoShortcuts()),
          chatOpenerProvider.overrideWithValue(opener),
          incomingListenerProvider.overrideWithValue(listener),
          contactsSourceProvider.overrideWithValue(_Contacts()),
          clockProvider.overrideWithValue(() => now),
        ],
        child: const KeptApp(),
      ),
    );
    await settle(tester);
  }

  Future<void> closeDown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(services.close);
  }

  Future<void> leaveAndReturn(WidgetTester tester) async {
    for (final s in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(s);
    }
    await settle(tester);
  }

  Future<List<ContactEvent>> events(WidgetTester tester) => tester
      .runAsync(
        () =>
            services.contactEventsFor(demo: false).watchForPerson(tom.id).first,
      )
      .then((v) => v!);

  Future<Person> reloadTom(WidgetTester tester) => tester
      .runAsync(() => services.peopleFor(demo: false).watch(tom.id).first)
      .then((v) => v!);

  Future<void> addEvent(
    WidgetTester tester,
    DateTime at, {
    ContactSource source = ContactSource.listener,
  }) => tester.runAsync(
    () => services
        .contactEventsFor(demo: false)
        .addByThemOnce(
          personId: tom.id,
          kind: ContactKind.wrote,
          at: at,
          source: source,
        ),
  );

  testWidgets('settings: off at start, switch, access and waiting time', (
    tester,
  ) async {
    await start(tester);
    expect(listener.enabled, isFalse);
    expect(listener.watchLists, isEmpty);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Ask about a reply after'), 100);
    await tester.pumpAndSettle();
    expect(find.text('INCOMING MESSAGES'), findsOneWidget);
    expect(find.textContaining('never reads what they wrote'), findsOneWidget);
    expect(find.text('Notification access'), findsNothing);
    expect(find.text('2 days'), findsOneWidget);

    // On: stored, passed on with the watch list (contact name included).
    await tester.tap(find.text('Notice who wrote or called'));
    await tester.pumpAndSettle();
    expect((await tester.runAsync(services.settings.load))!.incomingOn, true);
    expect(listener.enabled, isTrue);
    // Ordered by name, like the people.
    expect(listener.watchLists.last, [
      isA<WatchEntry>().having((e) => e.names, 'names', ['Anna']),
      WatchEntry(tom.id, const ['Tom', 'Tom Berger']),
    ]);
    expect(find.text('Notification access'), findsOneWidget);
    expect(find.text('Not allowed yet'), findsOneWidget);
    await tester.tap(find.text('Open notification access'));
    expect(listener.accessSettingsOpened, 1);

    // Back from the system page with access granted.
    listener.access = true;
    await leaveAndReturn(tester);
    expect(find.text('Allowed'), findsOneWidget);

    // Waiting time: 1 to 14 days.
    await tester.tap(find.byTooltip('Longer'));
    await tester.pumpAndSettle();
    expect(find.text('3 days'), findsOneWidget);
    await tester.tap(find.byTooltip('Shorter'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Shorter'));
    await tester.pumpAndSettle();
    expect(find.text('1 day'), findsOneWidget);
    await tester.tap(find.byTooltip('Shorter'));
    await tester.pumpAndSettle();
    expect((await tester.runAsync(services.settings.load))!.replyWaitDays, 1);

    // Off again.
    await tester.tap(find.text('Notice who wrote or called'));
    await tester.pumpAndSettle();
    expect(listener.enabled, isFalse);
    expect(find.text('Notification access'), findsNothing);
    await closeDown(tester);
  });

  testWidgets('the queue is imported at start and on every return', (
    tester,
  ) async {
    await start(
      tester,
      on: true,
      beforePump: () => listener.queue.add(
        IncomingEntry(tom.id, ContactKind.called, DateTime(2026, 11, 15, 9)),
      ),
    );
    expect(listener.enabled, isTrue);
    expect((await events(tester)).single.kind, ContactKind.called);
    // A call asks nothing.
    expect(find.text('Still owe Tom a reply?'), findsNothing);

    listener.queue.addAll([
      IncomingEntry(tom.id, ContactKind.wrote, DateTime(2026, 11, 13, 9)),
      IncomingEntry(tom.id, ContactKind.wrote, DateTime(2026, 11, 13, 18)),
      IncomingEntry('someone-else', ContactKind.wrote, DateTime(2026, 11, 13)),
    ]);
    await leaveAndReturn(tester);
    final wrote = (await events(tester))
        .where((e) => e.kind == ContactKind.wrote);
    expect(wrote.single.source, ContactSource.listener);
    expect(wrote.single.direction, ContactDirection.byThem);
    expect(wrote.single.at, DateTime(2026, 11, 13, 9));

    // Three days ago: a reply counts as owed now.
    expect(find.text('Still owe Tom a reply?'), findsOneWidget);
    expect(find.text('Already answered'), findsOneWidget);
    expect(find.text('Open WhatsApp'), findsOneWidget);

    // The timeline shows them as any "They wrote" and "They called".
    await tester.tap(find.text('People'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tom').last);
    await tester.pumpAndSettle();
    expect(find.text('Tom wrote'), findsOneWidget);
    expect(find.text('Tom called'), findsOneWidget);
    await closeDown(tester);
  });

  testWidgets('switched off, nothing is imported', (tester) async {
    await start(tester);
    listener.queue.add(
      IncomingEntry(tom.id, ContactKind.wrote, DateTime(2026, 11, 13)),
    );
    await leaveAndReturn(tester);
    expect(await events(tester), isEmpty);
    await closeDown(tester);
  });

  testWidgets('Already answered clears it and stores nothing else', (
    tester,
  ) async {
    await start(tester, on: true);
    await addEvent(tester, DateTime(2026, 11, 12));
    await tester.pumpAndSettle();
    expect(find.text('Still owe Tom a reply?'), findsOneWidget);

    await tester.tap(find.text('Already answered'));
    await tester.pumpAndSettle();
    expect((await reloadTom(tester)).replyClearedAt, now);
    expect(await events(tester), hasLength(1));
    expect(find.text('Still owe Tom a reply?'), findsNothing);
    await closeDown(tester);
  });

  testWidgets('Open WhatsApp on the pick clears it', (tester) async {
    await start(tester, on: true);
    await addEvent(tester, DateTime(2026, 11, 12));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open WhatsApp'));
    await tester.pumpAndSettle();
    expect(opener.opened.single.package, 'com.whatsapp');
    expect((await reloadTom(tester)).replyClearedAt, now);
    expect(find.text('Still owe Tom a reply?'), findsNothing);
    await closeDown(tester);
  });

  testWidgets('opening the chat from the person page clears it', (
    tester,
  ) async {
    await start(tester, on: true);
    await tester.tap(find.text('People'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tom').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open WhatsApp'));
    await tester.pumpAndSettle();
    expect((await reloadTom(tester)).replyClearedAt, now);
    await closeDown(tester);
  });

  testWidgets('switched off: listener entries ask nothing, manual ones do', (
    tester,
  ) async {
    await start(tester);
    await addEvent(tester, DateTime(2026, 11, 12));
    await tester.pumpAndSettle();
    expect(find.text('Still owe Tom a reply?'), findsNothing);

    await addEvent(
      tester,
      DateTime(2026, 11, 13),
      source: ContactSource.manual,
    );
    await tester.pumpAndSettle();
    expect(find.text('Still owe Tom a reply?'), findsOneWidget);
    await closeDown(tester);
  });

  testWidgets('three mode: the question with Already answered', (tester) async {
    await start(
      tester,
      on: true,
      settings: (s) => s.copyWith(openItems: OpenItemsMode.three),
    );
    await addEvent(tester, DateTime(2026, 11, 12));
    await tester.pumpAndSettle();
    expect(find.text('Still owe Tom a reply?'), findsOneWidget);
    await tester.tap(find.byTooltip('Already answered'));
    await tester.pumpAndSettle();
    expect((await reloadTom(tester)).replyClearedAt, now);
    expect(find.text('Still owe Tom a reply?'), findsNothing);
    await closeDown(tester);
  });
}

/// Lets the database work started by the app finish.
Future<void> settle(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}

class _Contacts implements ContactsSource {
  @override
  Future<Map<String, String>> displayNames() async => {'c1': 'Tom Berger'};

  @override
  Future<bool> requestAccess() async => false;

  @override
  Future<List<PhoneContact>> load() async => const [];

  @override
  Future<void> openSettings() async {}
}

class _FakeOpener implements ChatOpener {
  final opened = <ChatLink>[];

  @override
  Future<bool> open(ChatLink link) async {
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
