import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/app.dart';
import 'package:kept/app/providers.dart';
import 'package:kept/app/services.dart';
import 'package:kept/data/app_settings.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/birthday_notifications.dart';
import 'package:kept/domain/birthdays.dart';
import 'package:kept/domain/chat_link.dart';
import 'package:kept/domain/contact_event.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/platform/app_shortcuts.dart';
import 'package:kept/platform/chat_opener.dart';
import 'package:kept/ui/home/chat_question_screen.dart';
import 'package:kept/ui/home/congratulated_screen.dart';
import 'package:kept/ui/home/nice_one_screen.dart';
import 'package:kept/ui/material.dart';

import 'fake_notifications.dart';

/// Monday 16 November 2026, 14:00: Lena's birthday.
final now = DateTime(2026, 11, 16, 14);

void main() {
  late AppServices services;
  late FakeNotifications notifications;
  late Person lena, tom;
  final opener = _FakeOpener();

  setUp(() {
    opener.opened.clear();
    notifications = FakeNotifications();
    services = AppServices(
      db: AppDatabase(NativeDatabase.memory()),
      openDemo: () => AppDatabase(NativeDatabase.memory()),
    );
  });

  /// Lena (WhatsApp, birthday today, born 1994) and Tom (WhatsApp, one
  /// thought, birthday in March).
  Future<void> start(
    WidgetTester tester, {
    OpenItemsMode mode = OpenItemsMode.one,
    AppSettings Function(AppSettings)? settings,
  }) async {
    tester.view.physicalSize = const Size(400, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      final people = services.peopleFor(demo: false);
      lena = await people.add(
        name: 'Lena Hartwig',
        closeness: Closeness.close,
        mainMessenger: Messenger.whatsapp,
        phone: '+4900000000101',
        birthdayMonth: 11,
        birthdayDay: 16,
        birthdayYear: 1994,
      );
      tom = await people.add(
        name: 'Tom Berger',
        closeness: Closeness.close,
        mainMessenger: Messenger.whatsapp,
        phone: '+4900000000102',
        birthdayMonth: 3,
        birthdayDay: 3,
      );
      await services
          .intentionsFor(demo: false)
          .add(
            personId: tom.id,
            note: 'Bouldering',
            now: DateTime(2026, 11, 1),
          );
      await services.settings.update(
        (s) => (settings ?? (s) => s)(s.copyWith(openItems: mode)),
      );
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          servicesProvider.overrideWithValue(services),
          notificationsProvider.overrideWithValue(notifications),
          appShortcutsProvider.overrideWithValue(_NoShortcuts()),
          chatOpenerProvider.overrideWithValue(opener),
          clockProvider.overrideWithValue(() => now),
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
    await tester.pumpAndSettle();
  }

  Future<List<ContactEvent>> events(WidgetTester tester, Person p) => tester
      .runAsync(
        () => services.contactEventsFor(demo: false).watchForPerson(p.id).first,
      )
      .then((v) => v!);

  /// The alarms of the last birthday plan, as (name, time, late).
  List<(String, DateTime, bool)> alarms() => [
    for (final a in notifications.birthdayPlans.last.alarms)
      (a.person.name, a.at, a.late),
  ];

  testWidgets('the birthday is the first pick, with cake and age', (
    tester,
  ) async {
    await start(tester);
    expect(find.text('Turns 32 today'), findsOneWidget);
    expect(find.text('Congratulated'), findsOneWidget);
    expect(find.text('Open WhatsApp'), findsOneWidget);
    // Tom's thought is next.
    await tester.tap(find.text('Another one'));
    await tester.pumpAndSettle();
    expect(find.text('Bouldering'), findsNWidgets(2));
    expect(find.text('Congratulated'), findsNothing);
    await closeDown(tester);
  });

  testWidgets('Congratulated stores a manual wish and the pick is gone', (
    tester,
  ) async {
    await start(tester);
    expect(alarms(), [
      ('Lena Hartwig', DateTime(2026, 11, 16, 19), false),
      ('Lena Hartwig', DateTime(2026, 11, 16, 23), true),
      ('Tom Berger', DateTime(2027, 3, 3, 19), false),
      ('Tom Berger', DateTime(2027, 3, 3, 23), true),
    ]);
    await tester.tap(find.text('Congratulated'));
    await tester.pumpAndSettle();
    expect(find.byType(NiceOneScreen), findsOneWidget);
    final stored = (await events(tester, lena)).single;
    expect(stored.kind, ContactKind.birthdayWish);
    expect(stored.direction, ContactDirection.byUser);
    expect(stored.source, ContactSource.manual);
    expect(stored.at, now);
    expect(notifications.cancelled, [
      birthdayNotificationId(lena.id, late: false),
      birthdayNotificationId(lena.id, late: true),
    ]);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Turns 32 today'), findsNothing);
    expect(find.text('Open WhatsApp'), findsOneWidget);
    // Planned again: Lena's next ones are a year later.
    expect(alarms().where((a) => a.$1 == 'Lena Hartwig').map((a) => a.$2), [
      DateTime(2027, 11, 16, 19),
      DateTime(2027, 11, 16, 23),
    ]);
    await closeDown(tester);
  });

  testWidgets('Open WhatsApp, back, Yes: a confirmed wish', (tester) async {
    await start(tester);
    await tester.tap(find.text('Open WhatsApp'));
    await tester.pumpAndSettle();
    expect(opener.opened.single.package, 'com.whatsapp');
    await leaveAndReturn(tester);
    expect(find.text('Did you congratulate Lena?'), findsOneWidget);
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(find.byType(NiceOneScreen), findsOneWidget);
    expect(find.byType(ChatQuestionScreen), findsNothing);
    final stored = (await events(tester, lena)).single;
    expect(stored.kind, ContactKind.birthdayWish);
    expect(stored.source, ContactSource.confirmed);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Turns 32 today'), findsNothing);
    await closeDown(tester);
  });

  testWidgets('three mode: the birthday takes the first slot', (tester) async {
    await start(tester, mode: OpenItemsMode.three);
    expect(find.byTooltip('Congratulated'), findsOneWidget);
    expect(find.byTooltip('Done'), findsOneWidget);
    final birthday = tester.getTopLeft(find.text('Turns 32 today'));
    final thought = tester.getTopLeft(find.text('Bouldering').first);
    expect(birthday.dy, lessThan(thought.dy));
    await tester.tap(find.byTooltip('Congratulated'));
    await tester.pumpAndSettle();
    expect(find.byType(NiceOneScreen), findsOneWidget);
    expect((await events(tester, lena)).single.source, ContactSource.manual);
    await closeDown(tester);
  });

  testWidgets('the off switch silences them, excluded days do not', (
    tester,
  ) async {
    await start(
      tester,
      settings: (s) => s.copyWith(eveningExcludedDays: {1, 2, 3, 4, 5, 6, 7}),
    );
    expect(notifications.plans.last.weekdays, isEmpty);
    expect(alarms(), hasLength(4));
    await tester.runAsync(
      () => services.settings.update((s) => s.copyWith(eveningOn: false)),
    );
    await tester.pumpAndSettle();
    expect(notifications.birthdayPlans.last.alarms, isEmpty);
    await closeDown(tester);
  });

  testWidgets('a later evening time moves them; 23:00 drops the late one', (
    tester,
  ) async {
    await start(tester);
    await tester.runAsync(
      () => services.settings.update((s) => s.copyWith(eveningMinute: 23 * 60)),
    );
    await tester.pumpAndSettle();
    expect(alarms().first, ('Lena Hartwig', DateTime(2026, 11, 16, 23), false));
    expect(alarms(), hasLength(2));
    await closeDown(tester);
  });

  testWidgets('Open chat on the notification opens Home and the chat', (
    tester,
  ) async {
    await start(tester);
    await tester.tap(find.text('People'));
    await tester.pumpAndSettle();
    notifications.birthday(
      BirthdayResponse(
        personId: lena.id,
        day: DateTime(2026, 11, 16),
        late: false,
        action: BirthdayAction.openChat,
      ),
    );
    // The person is read from the database before the chat opens.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Turns 32 today'), findsOneWidget);
    expect(opener.opened.single.package, 'com.whatsapp');
    await leaveAndReturn(tester);
    expect(find.text('Did you congratulate Lena?'), findsOneWidget);
    await closeDown(tester);
  });

  testWidgets('Yes on the notification in the running app stores once', (
    tester,
  ) async {
    await start(tester);
    final yes = BirthdayResponse(
      personId: lena.id,
      day: DateTime(2026, 11, 16),
      late: false,
      action: BirthdayAction.yes,
    );
    notifications.birthday(yes);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    notifications.birthday(yes);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    final stored = await events(tester, lena);
    expect(stored.single.source, ContactSource.confirmed);
    expect(
      notifications.cancelled,
      contains(birthdayNotificationId(lena.id, late: true)),
    );
    expect(find.text('Turns 32 today'), findsNothing);
    await closeDown(tester);
  });

  testWidgets('own birthday: the card opens the list, toggles store', (
    tester,
  ) async {
    await start(
      tester,
      settings: (s) => s.withOwnBirthday(const Birthday(11, 16, 1990)),
    );
    expect(find.text('Who congratulated you?'), findsOneWidget);
    await tester.tap(find.text('Who congratulated you?'));
    await tester.pumpAndSettle();
    expect(find.byType(CongratulatedScreen), findsOneWidget);
    expect(find.text('Happy birthday!'), findsOneWidget);
    expect(find.text('Lena Hartwig'), findsOneWidget);
    expect(find.text('Tom Berger'), findsOneWidget);

    await tester.tap(find.text('Tom Berger'));
    await tester.pumpAndSettle();
    final stored = (await events(tester, tom)).single;
    expect(stored.kind, ContactKind.birthdayWish);
    expect(stored.direction, ContactDirection.byThem);
    expect(stored.source, ContactSource.manual);
    expect(dayKey(stored.at), '2026-11-16');

    await tester.tap(find.text('Tom Berger'));
    await tester.pumpAndSettle();
    expect(await events(tester, tom), isEmpty);
    await closeDown(tester);
  });

  testWidgets('no own birthday card on other days', (tester) async {
    await start(
      tester,
      settings: (s) => s.withOwnBirthday(const Birthday(3, 7)),
    );
    expect(find.text('Who congratulated you?'), findsNothing);
    await closeDown(tester);
  });

  testWidgets('the settings row sets, opens and clears the birthday', (
    tester,
  ) async {
    await start(tester);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Your birthday'), 100);
    await tester.pumpAndSettle();
    expect(find.text('Not set'), findsOneWidget);
    expect(find.text('Who congratulated you?'), findsNothing);

    await tester.tap(find.text('Your birthday'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('ownDay')), '31');
    await tester.enterText(find.byKey(const ValueKey('ownMonth')), '2');
    await tester.pump();
    expect(
      find.text('Enter a real day and month, or leave all three empty.'),
      findsOneWidget,
    );
    await tester.enterText(find.byKey(const ValueKey('ownDay')), '7');
    await tester.enterText(find.byKey(const ValueKey('ownMonth')), '3');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(
      (await tester.runAsync(services.settings.load))!.ownBirthday,
      const Birthday(3, 7),
    );
    expect(find.text('7 March'), findsOneWidget);

    // Not today: the list is for the most recent birthday.
    await tester.scrollUntilVisible(find.text('Who congratulated you?'), 100);
    await tester.tap(find.text('Who congratulated you?'));
    await tester.pumpAndSettle();
    expect(find.text('Your birthday on 7 March'), findsOneWidget);
    await tester.tap(find.text('Lena Hartwig'));
    await tester.pumpAndSettle();
    expect(dayKey((await events(tester, lena)).single.at), '2026-03-07');
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Your birthday'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(
      (await tester.runAsync(services.settings.load))!.ownBirthday,
      isNull,
    );
    expect(find.text('Not set'), findsOneWidget);
    await closeDown(tester);
  });
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
