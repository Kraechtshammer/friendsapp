import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/app.dart';
import 'package:kept/app/providers.dart';
import 'package:kept/app/services.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/contact_event.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/ui/material.dart';
import 'package:kept/ui/widgets/kept_switch.dart';

import 'fake_notifications.dart';

void main() {
  late AppServices services;

  setUp(() {
    services = AppServices(
      db: AppDatabase(NativeDatabase.memory()),
      openDemo: () => AppDatabase(NativeDatabase.memory()),
    );
  });

  Future<void> pumpApp(WidgetTester tester, FakeNotifications fake) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          servicesProvider.overrideWithValue(services),
          firstStartEnabledProvider.overrideWithValue(false),
          notificationsProvider.overrideWithValue(fake),
          clockProvider.overrideWithValue(() => DateTime(2026, 11, 16, 14)),
        ],
        child: const KeptApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> finish(WidgetTester tester) async {
    // As in widget_test.dart: let drift's timers run, then close for real.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(services.close);
  }

  /// Lets the database streams deliver, then waits out the debounce.
  Future<void> settleSchedule(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> openSettings(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    // The section at the top of the screen. Scrolling to "Days" would put
    // it under the app bar now that the page is longer (M7).
    await tester.scrollUntilVisible(find.text('EVENING QUESTION'), 100);
    await tester.pumpAndSettle();
  }

  testWidgets('first start asks once and schedules every day at 19:00', (
    tester,
  ) async {
    final fake = FakeNotifications(enabled: false);
    await pumpApp(tester, fake);

    expect(fake.permissionRequests, 1);
    expect((await services.settings.load()).notificationPermissionAsked, true);
    final plan = fake.plans.last;
    expect(plan.weekdays, [1, 2, 3, 4, 5, 6, 7]);
    expect(plan.minute, 19 * 60);
    expect(plan.title, 'Got ten minutes for someone today?');
    expect(plan.yes, 'Yes');
    expect(plan.notToday, 'Not today');

    // The next start schedules again but does not ask again.
    await tester.pumpWidget(const SizedBox());
    final second = FakeNotifications();
    await pumpApp(tester, second);
    expect(second.permissionRequests, 0);
    expect(second.plans, isNotEmpty);

    await finish(tester);
  });

  testWidgets('the settings change the schedule', (tester) async {
    final fake = FakeNotifications();
    await pumpApp(tester, fake);
    await openSettings(tester);

    expect(find.text('EVENING QUESTION'), findsOneWidget);
    // English test locale, 12-hour clock; the phone's own setting decides.
    expect(find.text('7:00 PM'), findsOneWidget);
    expect(find.text('Notifications are off for Kept.'), findsNothing);

    // Saturday off.
    await tester.tap(find.text('Sat'));
    await tester.pumpAndSettle();
    expect((await services.settings.load()).eveningExcludedDays, {6});
    expect(fake.plans.last.weekdays, [1, 2, 3, 4, 5, 7]);

    // The time row opens the time picker.
    await tester.tap(find.text('Time'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Off: nothing scheduled, the rows go away.
    final asked = fake.permissionRequests;
    await tester.tap(find.byType(KeptSwitch).first);
    await tester.pumpAndSettle();
    expect((await services.settings.load()).eveningOn, isFalse);
    expect(fake.plans.last.weekdays, isEmpty);
    expect(find.text('Days'), findsNothing);
    expect(fake.permissionRequests, asked);

    // On again: asks for the permission, Saturday stays off.
    await tester.tap(find.byType(KeptSwitch).first);
    await tester.pumpAndSettle();
    expect((await services.settings.load()).eveningOn, isTrue);
    expect(fake.permissionRequests, asked + 1);
    expect(fake.plans.last.weekdays, [1, 2, 3, 4, 5, 7]);

    await finish(tester);
  });

  testWidgets('refused notifications show one line with a way out', (
    tester,
  ) async {
    await services.settings.update(
      (s) => s.copyWith(notificationPermissionAsked: true),
    );
    final fake = FakeNotifications(enabled: false, grant: false);
    await pumpApp(tester, fake);
    expect(fake.permissionRequests, 0);
    await openSettings(tester);
    await tester.scrollUntilVisible(
      find.text('Open notification settings'),
      100,
    );

    expect(find.text('Notifications are off for Kept.'), findsOneWidget);
    await tester.tap(find.text('Open notification settings'));
    await tester.pumpAndSettle();
    expect(fake.settingsOpened, 1);

    await finish(tester);
  });

  testWidgets('"Yes" opens Home and is stored; "Not today" only stored', (
    tester,
  ) async {
    final fake = FakeNotifications();
    await pumpApp(tester, fake);
    await tester.tap(find.text('People'));
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsNothing);

    fake.answer(DayAnswerValue.notToday);
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsNothing);
    final answers = services.dayAnswersFor(demo: false);
    expect(
      (await answers.forDay(DateTime.now()))?.answer,
      DayAnswerValue.notToday,
    );

    fake.answer(DayAnswerValue.yes);
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsOneWidget);
    expect((await answers.forDay(DateTime.now()))?.answer, DayAnswerValue.yes);

    await finish(tester);
  });

  testWidgets('each day names its reason; a burst schedules once', (
    tester,
  ) async {
    final people = services.peopleFor(demo: false);
    final events = services.contactEventsFor(demo: false);
    late Person jonas;
    late Person mia;
    await tester.runAsync(() async {
      jonas = await people.add(name: 'Jonas Berg', closeness: Closeness.close);
      mia = await people.add(name: 'Mia Lang', closeness: Closeness.nowAndThen);
      await events.add(
        personId: jonas.id,
        at: DateTime(2026, 11, 13, 10),
        kind: ContactKind.wrote,
        direction: ContactDirection.byThem,
        source: ContactSource.manual,
      );
      await services.settings.update(
        (s) => s.withReconnect(mia.id, DateTime(2026, 11, 16)),
      );
    });
    final fake = FakeNotifications();
    await pumpApp(tester, fake);
    await settleSchedule(tester);

    var plan = fake.plans.last;
    expect(plan.title, 'Got ten minutes for someone today?');
    expect(plan.days, hasLength(21));
    expect(plan.days.first.at, DateTime(2026, 11, 16, 19));
    expect(plan.days.first.title, 'Still owe Jonas a reply?');

    // "Already answered": Mia is next.
    await tester.runAsync(
      () => people.setReplyClearedAt(jonas.id, DateTime(2026, 11, 16, 13)),
    );
    await settleSchedule(tester);
    plan = fake.plans.last;
    expect(plan.days.first.title, 'This month: Mia. Got ten minutes?');

    // Three contacts with Mia in a row: one new schedule, the general
    // question.
    final before = fake.plans.length;
    // Each write in its own runAsync, with a short pump between that
    // lets the database streams deliver, well within the debounce time.
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
        () => events.add(
          personId: mia.id,
          at: DateTime(2026, 11, 16, 9 + i),
          kind: ContactKind.wrote,
          direction: ContactDirection.byUser,
          source: ContactSource.manual,
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(fake.plans.length, before);
    await settleSchedule(tester);
    expect(fake.plans.length, before + 1);
    expect(
      fake.plans.last.days.map((d) => d.title),
      everyElement('Got ten minutes for someone today?'),
    );
    // No evening day has two notifications.
    expect(fake.pendingEvening, hasLength(28));

    await finish(tester);
  });
}
