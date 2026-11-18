import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/app.dart';
import 'package:kept/app/providers.dart';
import 'package:kept/app/services.dart';
import 'package:kept/data/app_settings.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/contact_event.dart';
import 'package:kept/domain/intention.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/ui/home/chat_question_screen.dart';
import 'package:kept/ui/home/nice_one_screen.dart';
import 'package:kept/ui/material.dart';

import 'fake_notifications.dart';
import 'support/fakes.dart';

void main() {
  late AppServices services;
  late Person tom, anna, jonas;
  final opener = FakeChatOpener();

  setUp(() {
    opener
      ..opened.clear()
      ..result = true;
    services = AppServices(
      db: AppDatabase(NativeDatabase.memory()),
      openDemo: () => AppDatabase(NativeDatabase.memory()),
    );
  });

  /// Tom (WhatsApp), Anna (Telegram) and Jonas (no messenger), each with
  /// one thought; Tom's is the oldest. [only] keeps just Tom's.
  Future<void> start(
    WidgetTester tester, {
    bool only = false,
    IntentionKind tomKind = IntentionKind.write,
    OpenItemsMode mode = OpenItemsMode.one,
  }) async {
    tester.view.physicalSize = const Size(400, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      final people = services.peopleFor(demo: false);
      final thoughts = services.intentionsFor(demo: false);
      tom = await people.add(
        name: 'Tom Berger',
        closeness: Closeness.close,
        chatApp: ChatApp.whatsapp,
        phone: '+4900000000101',
      );
      await thoughts.add(
        personId: tom.id,
        note: 'Bouldering',
        kind: tomKind,
        now: DateTime(2026, 11, 1),
      );
      if (!only) {
        anna = await people.add(
          name: 'Anna Keller',
          closeness: Closeness.nowAndThen,
          chatApp: ChatApp.telegram,
          chatTarget: '@demo_anna',
        );
        jonas = await people.add(
          name: 'Jonas Wirth',
          closeness: Closeness.family,
        );
        await thoughts.add(
          personId: anna.id,
          note: 'New flat',
          now: DateTime(2026, 11, 2),
        );
        await thoughts.add(
          personId: jonas.id,
          note: 'Say hi',
          now: DateTime(2026, 11, 3),
        );
      }
      await services.settings.update((s) => s.copyWith(openItems: mode));
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          servicesProvider.overrideWithValue(services),
          firstStartEnabledProvider.overrideWithValue(false),
          notificationsProvider.overrideWithValue(FakeNotifications()),
          appShortcutsProvider.overrideWithValue(NoShortcuts()),
          chatOpenerProvider.overrideWithValue(opener),
        ],
        child: const KeptApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> closeDown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(services.close);
  }

  /// The app goes to the background and comes back.
  Future<void> leaveAndReturn(WidgetTester tester) async {
    final binding = tester.binding;
    for (final s in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      binding.handleAppLifecycleStateChanged(s);
    }
    await tester.pumpAndSettle();
  }

  Future<List<ContactEvent>> events(WidgetTester tester, Person p) => tester
      .runAsync(
        () => services.contactEventsFor(demo: false).watchForPerson(p.id).first,
      )
      .then((v) => v!);

  Future<List<Intention>> open(WidgetTester tester) => tester
      .runAsync(() => services.intentionsFor(demo: false).watchOpen().first)
      .then((v) => v!);

  testWidgets('one mode: the oldest thought, Another one wraps around', (
    tester,
  ) async {
    await start(tester);
    expect(find.text("TONIGHT'S PICK"), findsNothing);
    expect(find.text("Tonight's pick"), findsOneWidget);
    expect(find.text('Open WhatsApp'), findsOneWidget);
    expect(find.text('Close friend · WhatsApp'), findsOneWidget);
    // The pick and the list below it.
    expect(find.text('Bouldering'), findsNWidgets(2));
    expect(find.text('On your mind'.toUpperCase()), findsOneWidget);

    await tester.tap(find.text('Another one'));
    await tester.pumpAndSettle();
    expect(find.text('Open Telegram'), findsOneWidget);
    expect(find.text('Open WhatsApp'), findsNothing);
    expect(find.text('Now and then · Telegram'), findsOneWidget);

    // Jonas has no messenger: no Open button.
    await tester.tap(find.text('Another one'));
    await tester.pumpAndSettle();
    expect(find.text('Family'), findsOneWidget);
    expect(find.textContaining('Open '), findsNothing);

    await tester.tap(find.text('Another one'));
    await tester.pumpAndSettle();
    expect(find.text('Open WhatsApp'), findsOneWidget);
    await closeDown(tester);
  });

  testWidgets('one mode with one thought has no Another one', (tester) async {
    await start(tester, only: true);
    expect(find.text('Open WhatsApp'), findsOneWidget);
    expect(find.text('Another one'), findsNothing);
    expect(find.text('Done'), findsNWidgets(2));
    await closeDown(tester);
  });

  testWidgets('no thoughts: no pick section', (tester) async {
    await start(tester, only: true);
    await tester.runAsync(() async {
      final repo = services.intentionsFor(demo: false);
      for (final i in await repo.watchOpen().first) {
        await repo.setState(i.id, IntentionState.dropped);
      }
    });
    await tester.pumpAndSettle();
    expect(find.text("Tonight's pick"), findsNothing);
    expect(find.text('ON YOUR MIND'), findsNothing);
    await closeDown(tester);
  });

  testWidgets('three mode: three compact cards', (tester) async {
    await start(tester, mode: OpenItemsMode.three);
    expect(find.text("TONIGHT'S PICK"), findsOneWidget);
    expect(find.text('Another one'), findsNothing);
    expect(find.byTooltip('Done'), findsNWidgets(3));
    expect(find.byTooltip('Open WhatsApp'), findsOneWidget);
    expect(find.byTooltip('Open Telegram'), findsOneWidget);

    await tester.tap(find.byTooltip('Open Telegram'));
    await tester.pumpAndSettle();
    expect(opener.opened.single.package, 'org.telegram.messenger');
    await closeDown(tester);
  });

  testWidgets('the setting switches the mode', (tester) async {
    await start(tester);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Evening question'));
    await tester.pumpAndSettle();
    expect(find.text('OPEN ITEMS'), findsOneWidget);
    await tester.tap(find.text('Three'));
    await tester.pumpAndSettle();
    expect(
      (await tester.runAsync(services.settings.load))!.openItems,
      OpenItemsMode.three,
    );
    await tester.tap(find.text('One'));
    await tester.pumpAndSettle();
    expect(
      (await tester.runAsync(services.settings.load))!.openItems,
      OpenItemsMode.one,
    );
    await closeDown(tester);
  });

  testWidgets('Done on the pick records a manual contact', (tester) async {
    await start(tester);
    await tester.tap(find.text('Done').first);
    await tester.pumpAndSettle();
    expect(find.byType(NiceOneScreen), findsOneWidget);
    final stored = await events(tester, tom);
    expect(stored.single.source, ContactSource.manual);
    expect(stored.single.kind, ContactKind.wrote);
    // The next oldest thought is the pick now.
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Open Telegram'), findsOneWidget);
    await closeDown(tester);
  });

  testWidgets('Open chat, back, Yes: confirmed contact and Nice one', (
    tester,
  ) async {
    await start(tester);
    await tester.tap(find.text('Open WhatsApp'));
    await tester.pumpAndSettle();
    expect(opener.opened.single.package, 'com.whatsapp');
    // Nothing is asked before the user is back.
    expect(find.byType(ChatQuestionScreen), findsNothing);

    await leaveAndReturn(tester);
    expect(find.text('Did you write to Tom?'), findsOneWidget);
    expect(find.text('You opened WhatsApp a moment ago.'), findsOneWidget);
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    expect(find.byType(NiceOneScreen), findsOneWidget);
    expect(find.byType(ChatQuestionScreen), findsNothing);
    final stored = (await events(tester, tom)).single;
    expect(stored.source, ContactSource.confirmed);
    expect(stored.kind, ContactKind.wrote);
    expect(stored.intentionId, isNotNull);
    expect(
      (await open(tester)).map((i) => i.personId),
      isNot(contains(tom.id)),
    );

    // Closing goes back to Home, and nothing is asked again.
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    await leaveAndReturn(tester);
    expect(find.byType(ChatQuestionScreen), findsNothing);
    await closeDown(tester);
  });

  testWidgets('Not yet stores nothing and the question is asked once', (
    tester,
  ) async {
    await start(tester);
    await tester.tap(find.text('Open WhatsApp'));
    await tester.pumpAndSettle();
    await leaveAndReturn(tester);
    expect(find.byType(ChatQuestionScreen), findsOneWidget);
    await tester.tap(find.text('Not yet'));
    await tester.pumpAndSettle();

    expect(find.byType(ChatQuestionScreen), findsNothing);
    expect(find.byType(NiceOneScreen), findsNothing);
    expect(await events(tester, tom), isEmpty);
    expect(await open(tester), hasLength(3));
    await leaveAndReturn(tester);
    expect(find.byType(ChatQuestionScreen), findsNothing);
    await closeDown(tester);
  });

  testWidgets('the wording follows the kind of the thought', (tester) async {
    await start(tester, tomKind: IntentionKind.call);
    await tester.tap(find.text('Open WhatsApp'));
    await tester.pumpAndSettle();
    await leaveAndReturn(tester);
    expect(find.text('Did you call Tom?'), findsOneWidget);
    await closeDown(tester);
  });

  testWidgets('a messenger that does not open asks nothing', (tester) async {
    await start(tester);
    opener.result = false;
    await tester.tap(find.text('Open WhatsApp'));
    await tester.pumpAndSettle();
    expect(find.text("WhatsApp could not be opened."), findsOneWidget);
    await leaveAndReturn(tester);
    expect(find.byType(ChatQuestionScreen), findsNothing);
    await closeDown(tester);
  });

  testWidgets('from the person page: Yes adds a confirmed write', (
    tester,
  ) async {
    await start(tester);
    await tester.tap(find.text('People'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tom').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open WhatsApp'));
    await tester.pumpAndSettle();
    await leaveAndReturn(tester);

    expect(find.text('Did you write to Tom?'), findsOneWidget);
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(find.byType(NiceOneScreen), findsOneWidget);
    final stored = (await events(tester, tom)).single;
    expect(stored.kind, ContactKind.wrote);
    expect(stored.direction, ContactDirection.byUser);
    expect(stored.source, ContactSource.confirmed);
    expect(stored.intentionId, isNull);
    // The thought was not the reason for this chat, so it stays open.
    expect(await open(tester), hasLength(3));
    await closeDown(tester);
  });
}
