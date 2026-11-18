import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/app.dart';
import 'package:kept/app/providers.dart';
import 'package:kept/app/services.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/contact_event.dart';
import 'package:kept/domain/intention.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/ui/kept_icon.dart';
import 'package:kept/ui/material.dart';

import 'fake_notifications.dart';
import 'support/fakes.dart';

/// The friend timeline on the person page, "They wrote" and "They called",
/// and the edit sheet (M6).
void main() {
  late AppServices services;
  late Person tom;
  final today = DateTime.now();
  DateTime back(int days, [int hour = 12]) =>
      DateTime(today.year, today.month, today.day - days, hour);

  setUp(() {
    services = AppServices(
      db: AppDatabase(NativeDatabase.memory()),
      openDemo: () => AppDatabase(NativeDatabase.memory()),
    );
  });

  Future<void> start(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      tom = await services
          .peopleFor(demo: false)
          .add(name: 'Tom Berger', closeness: Closeness.close);
      final repo = services.contactEventsFor(demo: false);
      await repo.add(
        personId: tom.id,
        at: back(3),
        kind: ContactKind.wrote,
        direction: ContactDirection.byUser,
        source: ContactSource.manual,
        note: 'New job is going well.',
      );
      await repo.add(
        personId: tom.id,
        at: back(8),
        kind: ContactKind.met,
        direction: ContactDirection.together,
        source: ContactSource.manual,
        activity: 'bouldering',
      );
      await repo.add(
        personId: tom.id,
        at: back(9),
        kind: ContactKind.called,
        direction: ContactDirection.byThem,
        source: ContactSource.manual,
      );
      await repo.add(
        personId: tom.id,
        at: back(20),
        kind: ContactKind.birthdayWish,
        direction: ContactDirection.byThem,
        source: ContactSource.manual,
      );
      await services
          .intentionsFor(demo: false)
          .add(
            personId: tom.id,
            note: 'Bouldering together',
            kind: IntentionKind.meet,
            when: When.date(
              DateTime(today.year, today.month, today.day + 5, 11),
            ),
          );
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          servicesProvider.overrideWithValue(services),
          firstStartEnabledProvider.overrideWithValue(false),
          notificationsProvider.overrideWithValue(FakeNotifications()),
          appShortcutsProvider.overrideWithValue(NoShortcuts()),
        ],
        child: const KeptApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('People'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tom'));
    await tester.pumpAndSettle();
  }

  Future<void> closeDown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(services.close);
  }

  Future<List<ContactEvent>> events(WidgetTester tester) => tester
      .runAsync(
        () =>
            services.contactEventsFor(demo: false).watchForPerson(tom.id).first,
      )
      .then((v) => v!);

  /// Lets a tap's database write finish and the page rebuild, without
  /// waiting for a snack bar to go away.
  Future<void> settleWrite(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('the page shows the timeline', (tester) async {
    await start(tester);
    expect(find.text('COMING UP'), findsOneWidget);
    // The mark, and today's entry shows "Today" instead of a date.
    expect(find.text('TODAY'), findsNWidgets(2));
    // Upcoming above the Today mark, history below.
    double top(String t) => tester.getTopLeft(find.text(t).first).dy;
    final upcomingTop = tester
        .getTopLeft(find.textContaining('Meet ·').first)
        .dy;
    expect(upcomingTop, lessThan(top('TODAY')));
    expect(find.text('Bouldering together'), findsWidgets);
    expect(top('You wrote'), greaterThan(top('TODAY')));
    expect(find.text('New job is going well.'), findsOneWidget);
    expect(find.text('You met · bouldering'), findsOneWidget);
    expect(find.text('Tom called'), findsOneWidget);
    expect(find.text('Your birthday'), findsOneWidget);
    expect(find.text('Tom congratulated you'), findsOneWidget);
    expect(find.text('Added to your people'), findsOneWidget);
    // Newest first: wrote, met, called, your birthday, added.
    expect(top('You wrote'), lessThan(top('You met · bouldering')));
    expect(top('You met · bouldering'), lessThan(top('Tom called')));
    expect(top('Tom called'), lessThan(top('Your birthday')));
    expect(top('Your birthday'), lessThan(top('Added to your people')));
    // Nothing says missed or overdue.
    expect(find.textContaining('missed', findRichText: true), findsNothing);
    expect(find.textContaining('overdue', findRichText: true), findsNothing);
    await closeDown(tester);
  });

  testWidgets('We were in touch logs a call from yesterday', (tester) async {
    await start(tester);
    final before = (await events(tester)).length;
    await tester.tap(find.text('We were in touch'));
    await tester.pumpAndSettle();
    expect(find.text('We were in touch with Tom'), findsOneWidget);
    await tester.tap(find.text('Called'));
    await tester.tap(find.text('Yesterday'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await settleWrite(tester);
    await tester.pumpAndSettle();

    final stored = await events(tester);
    expect(stored, hasLength(before + 1));
    final e = stored.firstWhere((e) => e.at == back(1));
    expect(e.kind, ContactKind.called);
    expect(e.direction, ContactDirection.byUser);
    expect(e.source, ContactSource.manual);
    expect(find.text('Nice one!'), findsOneWidget);
    await closeDown(tester);
  });

  testWidgets('They wrote stores one event a day; Undo removes it', (
    tester,
  ) async {
    await start(tester);
    final before = (await events(tester)).length;
    await tester.tap(find.text('They wrote'));
    await settleWrite(tester);

    var stored = await events(tester);
    expect(stored, hasLength(before + 1));
    final e = stored.firstWhere(
      (e) =>
          e.direction == ContactDirection.byThem && e.kind == ContactKind.wrote,
    );
    expect(e.source, ContactSource.manual);
    expect(e.at.day, today.day);
    expect(find.text('Noted: Tom wrote'), findsOneWidget);
    expect(find.text('Tom wrote'), findsOneWidget);

    // A second tap the same day adds nothing.
    await tester.tap(find.text('They wrote'));
    await settleWrite(tester);
    expect(await events(tester), hasLength(before + 1));
    expect(find.text('Already noted for today'), findsOneWidget);

    // Undo removes it, and then it can be noted again.
    await tester.tap(find.text('They called'));
    await settleWrite(tester);
    expect(find.text('Noted: Tom called'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await settleWrite(tester);
    stored = await events(tester);
    expect(
      stored.where(
        (e) =>
            e.kind == ContactKind.called &&
            e.direction == ContactDirection.byThem &&
            e.at.day == today.day,
      ),
      isEmpty,
    );
    await tester.tap(find.text('They called'));
    await settleWrite(tester);
    expect(find.text('Noted: Tom called'), findsOneWidget);
    expect(
      (await events(tester)).where(
        (e) =>
            e.kind == ContactKind.called &&
            e.direction == ContactDirection.byThem &&
            e.at.day == today.day,
      ),
      hasLength(1),
    );
    await closeDown(tester);
  });

  testWidgets('tapping an entry edits its activity and note', (tester) async {
    await start(tester);
    await tester.tap(find.text('You wrote'));
    await tester.pumpAndSettle();
    expect(find.text('Edit entry'), findsOneWidget);
    // The sheet's fields, not the ideas field on the page behind.
    final fields = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(TextField),
    );
    expect(
      tester.widget<TextField>(fields.last).controller!.text,
      'New job is going well.',
    );
    await tester.enterText(fields.first, 'chat');
    await tester.enterText(fields.last, '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    final wrote = (await events(tester))
        .firstWhere((e) => e.kind == ContactKind.wrote);
    expect(wrote.activity, 'chat');
    expect(wrote.note, isNull);
    expect(find.text('You wrote · chat'), findsOneWidget);
    await closeDown(tester);
  });

  testWidgets('a meeting gets an icon that the timeline shows', (tester) async {
    await start(tester);
    bool climberShown() => tester
        .widgetList<KeptIcon>(find.byType(KeptIcon))
        .any((w) => w.icon == KeptIcons.climber);

    // Writing has no activity icon.
    await tester.tap(find.text('You wrote'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Icon for the activity'), findsNothing);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('You met · bouldering'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Icon for the activity'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is KeptIcon && w.icon == KeptIcons.climber,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    Future<ContactEvent> met() async =>
        (await events(tester)).firstWhere((e) => e.kind == ContactKind.met);
    expect((await met()).activityIcon, 'climber');
    expect(climberShown(), isTrue);

    // "No icon" clears it again.
    await tester.tap(find.text('You met · bouldering'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Icon for the activity'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No icon'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect((await met()).activityIcon, isNull);
    expect(climberShown(), isFalse);
    await closeDown(tester);
  });

  testWidgets('delete asks first', (tester) async {
    await start(tester);
    await tester.tap(find.text('Tom called'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete this entry'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this entry?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(
      (await events(tester)).where((e) => e.kind == ContactKind.called),
      hasLength(1),
    );

    await tester.tap(find.text('Delete this entry'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(
      (await events(tester)).where((e) => e.kind == ContactKind.called),
      isEmpty,
    );
    expect(find.text('Tom called'), findsNothing);
    expect(find.text('Edit entry'), findsNothing);
    await closeDown(tester);
  });

  testWidgets('birthday and Added entries do not open the sheet', (
    tester,
  ) async {
    await start(tester);
    await tester.tap(find.text('Your birthday'));
    await tester.pumpAndSettle();
    expect(find.text('Edit entry'), findsNothing);
    await tester.tap(find.text('Added to your people'));
    await tester.pumpAndSettle();
    expect(find.text('Edit entry'), findsNothing);
    await closeDown(tester);
  });
}
