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
import 'package:kept/domain/progress.dart';
import 'package:kept/domain/stamps.dart';
import 'package:kept/domain/treat.dart';
import 'package:kept/l10n/app_localizations_en.dart';
import 'package:kept/l10n/labels.dart';
import 'package:kept/platform/app_shortcuts.dart';
import 'package:kept/ui/home/nice_one_screen.dart';
import 'package:kept/ui/material.dart';
import 'package:kept/ui/progress/progress_screen.dart';
import 'package:kept/ui/progress/treats_screen.dart';
import 'package:kept/ui/widgets/stamps.dart';

import 'fake_notifications.dart';

void main() {
  late AppServices services;
  // Wednesday 18 November 2026; its Monday is the 16th.
  final now = DateTime(2026, 11, 18, 12);
  final mon = DateTime(2026, 11, 16, 10);

  setUp(() {
    services = AppServices(
      db: AppDatabase(NativeDatabase.memory()),
      openDemo: () => AppDatabase(NativeDatabase.memory()),
    );
  });

  /// Runs [body] on the real clock, then pumps, so the screens' database
  /// streams finish their queries before the next call (otherwise the next
  /// transaction waits for them for ever).
  Future<T> real<T>(WidgetTester tester, Future<T> Function() body) async {
    final result = await tester.runAsync(body) as T;
    await tester.pumpAndSettle();
    return result;
  }

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // The first start (default treats, backfill) done before the app is up,
    // so the tests do not race it.
    await tester.runAsync(
      () => services.ensureStampsReady(defaultTreatNames(AppLocalizationsEn())),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          servicesProvider.overrideWithValue(services),
          notificationsProvider.overrideWithValue(FakeNotifications()),
          appShortcutsProvider.overrideWithValue(_NoShortcuts()),
          clockProvider.overrideWithValue(() => now),
        ],
        child: const KeptApp(),
      ),
    );
    // Database work the app started under the test clock needs both real
    // time and pumps to finish; do not leave a transaction open.
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();
    }
  }

  Future<void> closeDown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(services.close);
  }

  Future<Person> add(
    WidgetTester tester,
    String name, {
    Closeness closeness = Closeness.close,
  }) => real(
    tester,
    () => services
        .peopleFor(demo: false)
        .add(name: name, closeness: closeness, now: DateTime(2026, 11, 14)),
  );

  Future<void> contact(
    WidgetTester tester,
    Person p,
    DateTime at, {
    ContactKind kind = ContactKind.wrote,
    ContactDirection direction = ContactDirection.byUser,
  }) => real(
    tester,
    () => services
        .contactEventsFor(demo: false)
        .add(
          personId: p.id,
          at: at,
          kind: kind,
          direction: direction,
          source: ContactSource.manual,
        ),
  );

  Future<void> openProgress(WidgetTester tester) async {
    await tester.tap(find.text('Progress'));
    await tester.pumpAndSettle();
  }

  /// Starts the card of the default treat called [name], with [stamps]
  /// stamps if not null.
  Future<Treat> startCard(
    WidgetTester tester,
    String name, {
    int? stamps,
  }) async {
    final repo = services.treatsFor(demo: false);
    final all = await real(tester, () => repo.watchAll().first);
    final t = all.firstWhere((t) => t.name == name);
    if (stamps != null) {
      await real(tester, () => repo.setStampsNeeded(t.id, stamps));
    }
    await real(tester, () => repo.setCurrent(t.id));
    return t;
  }

  testWidgets('a new start shows zero, an invitation and a calm week', (
    tester,
  ) async {
    await pumpApp(tester);
    await openProgress(tester);
    expect(find.byType(ProgressScreen), findsOneWidget);
    expect(find.text('0'), findsWidgets);
    expect(
      find.text('Stamps so far. This number only ever grows.'),
      findsOneWidget,
    );
    expect(find.text('Choose your next treat'), findsOneWidget);
    expect(
      find.text('Nobody yet this week. The week is still long.'),
      findsOneWidget,
    );
    expect(
      find.text('No weeks yet. Your first contact starts them.'),
      findsOneWidget,
    );
    expect(find.text('YOUR NUMBERS'), findsOneWidget);
    await closeDown(tester);
  });

  testWidgets('shows the count, the current card, this week and the weeks', (
    tester,
  ) async {
    await pumpApp(tester);
    await startCard(tester, 'Cinema evening', stamps: 8);
    final tom = await add(tester, 'Tom');
    final ann = await add(tester, 'Ann', closeness: Closeness.nowAndThen);
    final ben = await add(tester, 'Ben');
    await contact(tester, tom, mon);
    await contact(tester, ann, now);
    // Incoming only: not in "this week", no stamp.
    await contact(tester, ben, now, direction: ContactDirection.byThem);
    // Two earlier weeks.
    await contact(tester, tom, DateTime(2026, 11, 9, 10));
    await contact(tester, tom, DateTime(2026, 11, 2, 10));
    await openProgress(tester);
    await tester.pumpAndSettle();

    // 1 + 2 + 1 + 1.
    expect(find.text('5'), findsWidgets);
    expect(find.text('Cinema evening'), findsOneWidget);
    expect(find.text('Choose your next treat'), findsNothing);
    expect(find.text('3 more stamps and it is yours.'), findsOneWidget);
    expect(find.byType(StampMark), findsNWidgets(5));
    // Only Ann is beyond the close friends: one week counts.
    expect(find.text('1 week in a row'), findsOneWidget);
    expect(find.text('This week counts.'), findsOneWidget);
    expect(find.text('Longest so far: 1 week'), findsOneWidget);
    expect(
      find.text('Counts weeks with someone beyond your close friends.'),
      findsOneWidget,
    );
    // Avatars of this week: Tom and Ann.
    expect(find.text('T'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsNothing);
    await closeDown(tester);
  });

  testWidgets('the running week does not break a run; no reset is shown', (
    tester,
  ) async {
    await pumpApp(tester);
    final ann = await add(tester, 'Ann', closeness: Closeness.family);
    await contact(tester, ann, DateTime(2026, 11, 9, 10));
    await contact(tester, ann, DateTime(2026, 11, 2, 10));
    await openProgress(tester);
    expect(find.text('2 weeks in a row'), findsOneWidget);
    expect(find.text('This week is still open.'), findsOneWidget);
    expect(find.text('Longest so far: 2 weeks'), findsOneWidget);
    expect(
      find.text('Nobody yet this week. The week is still long.'),
      findsOneWidget,
    );
    await closeDown(tester);
  });

  testWidgets('strict: an ended run is stated calmly, the longest stays', (
    tester,
  ) async {
    await pumpApp(tester);
    final ann = await add(tester, 'Ann', closeness: Closeness.nowAndThen);
    final tom = await add(tester, 'Tom');
    await contact(tester, ann, DateTime(2026, 10, 26, 10));
    await contact(tester, ann, DateTime(2026, 11, 2, 10));
    // The week of 9 November has only a close friend: it does not count.
    await contact(tester, tom, DateTime(2026, 11, 10, 10));
    await openProgress(tester);
    expect(find.textContaining('weeks in a row'), findsNothing);
    expect(
      find.text(
        'That run is over. The next week with someone beyond your close '
        'friends starts a new one.',
      ),
      findsOneWidget,
    );
    expect(find.text('Longest so far: 2 weeks'), findsOneWidget);
    await closeDown(tester);
  });

  testWidgets('friendly: a quiet week only pauses, the label changes', (
    tester,
  ) async {
    await pumpApp(tester);
    await real(
      tester,
      () => services.settings.update(
        (s) => s.copyWith(streakMode: StreakMode.friendly),
      ),
    );
    final ann = await add(tester, 'Ann', closeness: Closeness.nowAndThen);
    await contact(tester, ann, DateTime(2026, 10, 26, 10));
    await contact(tester, ann, DateTime(2026, 11, 2, 10));
    await openProgress(tester);
    expect(find.text('2 weeks in touch'), findsOneWidget);
    expect(find.textContaining('Longest so far'), findsNothing);
    expect(
      find.text('Paused this week so far. Nothing is lost.'),
      findsOneWidget,
    );
    await closeDown(tester);
  });

  testWidgets('the stamp card shows stamps and dashed slots', (tester) async {
    await pumpApp(tester);
    await startCard(tester, 'Cinema evening', stamps: 6);
    final tom = await add(tester, 'Tom', closeness: Closeness.fewTimesAYear);
    await contact(tester, tom, mon);
    await openProgress(tester);
    expect(find.byType(StampMark), findsNWidgets(3));
    expect(find.byType(EmptySlot), findsNWidgets(3));
    expect(find.text('3 more stamps and it is yours.'), findsOneWidget);
    await closeDown(tester);
  });

  testWidgets('"Your numbers" counts the month and the Yes answers', (
    tester,
  ) async {
    await pumpApp(tester);
    final tom = await add(tester, 'Tom');
    final ann = await add(tester, 'Ann');
    await contact(tester, tom, DateTime(2026, 11, 2, 10));
    await contact(tester, tom, DateTime(2026, 11, 9, 10));
    await contact(tester, ann, DateTime(2026, 11, 10, 10));
    final answers = services.dayAnswersFor(demo: false);
    for (final (day, answer) in [
      (3, DayAnswerValue.yes),
      (4, DayAnswerValue.yes),
      (5, DayAnswerValue.notToday),
    ]) {
      await real(
        tester,
        () => answers.setToday(answer, now: DateTime(2026, 11, day, 20)),
      );
    }
    await openProgress(tester);
    expect(find.text('YOUR NUMBERS'), findsOneWidget);
    Finder numberOf(String label, String n) => find.descendant(
      of: find
          .ancestor(of: find.text(label), matching: find.byType(Column))
          .first,
      matching: find.text(n),
    );
    expect(numberOf('evenings answered Yes', '2'), findsOneWidget);
    expect(numberOf('contacts by you this month', '3'), findsOneWidget);
    expect(numberOf('different people this month', '2'), findsOneWidget);
    await closeDown(tester);
  });

  testWidgets('an earned treat is celebrated and can be marked Enjoyed', (
    tester,
  ) async {
    await pumpApp(tester);
    await startCard(tester, 'Cinema evening', stamps: 1);
    final tom = await add(tester, 'Tom');
    await contact(tester, tom, mon);
    await openProgress(tester);
    expect(find.text('Cinema evening is yours!'), findsOneWidget);
    expect(find.text('Choose your next treat'), findsOneWidget);
    await tester.tap(find.text('Enjoyed').first);
    await tester.pumpAndSettle();
    expect(find.text('Cinema evening is yours!'), findsNothing);
    final treats = await real(
      tester,
      () => services.treatsFor(demo: false).watchAll().first,
    );
    expect(
      treats.firstWhere((t) => t.name == 'Cinema evening').state,
      TreatState.enjoyed,
    );
    await closeDown(tester);
  });

  group('the treats list', () {
    Future<void> openTreatsScreen(WidgetTester tester) async {
      await openProgress(tester);
      await tester.tap(find.text('My treats'));
      await tester.pumpAndSettle();
      expect(find.byType(TreatsScreen), findsOneWidget);
    }

    testWidgets(
      'lists the twelve default treats; Start moves one onto the card',
      (tester) async {
        await pumpApp(tester);
        await openTreatsScreen(tester);
        expect(find.text('Favourite takeaway'), findsOneWidget);
        expect(find.text('Start this card'), findsNWidgets(12));
        await tester.tap(find.text('Start this card').at(1));
        await tester.pumpAndSettle();
        // One card is current: no other Start button.
        expect(find.text('Start this card'), findsNothing);
        final current = currentTreat(
          await real(
            tester,
            () => services.treatsFor(demo: false).watchAll().first,
          ),
        );
        expect(current?.name, 'Cinema evening');
        await closeDown(tester);
      },
    );

    testWidgets('adds a treat with the default card size', (tester) async {
      await pumpApp(tester);
      await real(
        tester,
        () => services.settings.update(
          (s) => s.copyWith(stampWeights: const StampWeights(cardSize: 7)),
        ),
      );
      await tester.pumpAndSettle();
      await openTreatsScreen(tester);
      await tester.tap(find.text('Add a treat'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Sushi night');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final treats = await real(
        tester,
        () => services.treatsFor(demo: false).watchAll().first,
      );
      final sushi = treats.firstWhere((t) => t.name == 'Sushi night');
      expect(sushi.stampsNeeded, 7);
      expect(sushi.state, TreatState.waiting);
      expect(treats.last.id, sushi.id);
      await closeDown(tester);
    });

    testWidgets(
      'renames, changes the number, moves and deletes a waiting treat',
      (tester) async {
        await pumpApp(tester);
        await openTreatsScreen(tester);
        await tester.tap(find.text('Favourite takeaway'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Pizza');
        // Stamp number 10 -> 11.
        await tester.tap(find.byTooltip('More'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        var treats = await real(
          tester,
          () => services.treatsFor(demo: false).watchAll().first,
        );
        expect(treats.first.name, 'Pizza');
        expect(treats.first.stampsNeeded, 11);

        await tester.tap(find.text('Pizza'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Move down'));
        await tester.pumpAndSettle();
        treats = await real(
          tester,
          () => services.treatsFor(demo: false).watchAll().first,
        );
        expect(treats[1].name, 'Pizza');

        await tester.tap(find.text('Pizza'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete treat'));
        await tester.pumpAndSettle();
        treats = await real(
          tester,
          () => services.treatsFor(demo: false).watchAll().first,
        );
        expect(treats, hasLength(11));
        expect(treats.any((t) => t.name == 'Pizza'), isFalse);
        await closeDown(tester);
      },
    );

    testWidgets('earned and enjoyed treats have their own groups', (
      tester,
    ) async {
      await pumpApp(tester);
      await startCard(tester, 'Cinema evening', stamps: 1);
      final tom = await add(tester, 'Tom');
      await contact(tester, tom, mon);
      await openTreatsScreen(tester);
      expect(find.text('EARNED'), findsOneWidget);
      await tester.tap(find.text('Enjoyed').first);
      await tester.pumpAndSettle();
      expect(find.text('EARNED'), findsNothing);
      expect(find.text('ENJOYED'), findsOneWidget);
      await closeDown(tester);
    });
  });

  group('Nice one', () {
    Future<void> doneOn(
      WidgetTester tester,
      Person p,
      IntentionKind kind,
    ) async {
      await real(
        tester,
        () => services
            .intentionsFor(demo: false)
            .add(personId: p.id, note: 'Bouldering', kind: kind),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done').first);
      await tester.pumpAndSettle();
      expect(find.byType(NiceOneScreen), findsOneWidget);
    }

    testWidgets('shows the stamps the contact earned', (tester) async {
      await pumpApp(tester);
      final ann = await add(tester, 'Ann', closeness: Closeness.nowAndThen);
      await doneOn(tester, ann, IntentionKind.write);
      expect(find.text('STAMPS FOR THE CARD'), findsOneWidget);
      expect(find.text('+2'), findsOneWidget);
      expect(find.byType(StampMark), findsNWidgets(2));
      // No card is current yet: the stamps wait.
      expect(find.text('They wait for your next treat.'), findsOneWidget);
      await closeDown(tester);
    });

    testWidgets('shows nothing about stamps when the week already has one', (
      tester,
    ) async {
      await pumpApp(tester);
      final ann = await add(tester, 'Ann', closeness: Closeness.nowAndThen);
      // A meet-up this week: worth 4, so a message earns nothing more.
      await real(
        tester,
        () => services
            .contactEventsFor(demo: false)
            .add(
              personId: ann.id,
              at: DateTime.now(),
              kind: ContactKind.met,
              direction: ContactDirection.together,
              source: ContactSource.manual,
            ),
      );
      await doneOn(tester, ann, IntentionKind.write);
      expect(find.text('STAMPS FOR THE CARD'), findsNothing);
      expect(find.byType(StampMark), findsNothing);
      await closeDown(tester);
    });

    testWidgets('celebrates a card that this contact filled', (tester) async {
      await pumpApp(tester);
      await startCard(tester, 'Cinema evening', stamps: 1);
      final tom = await add(tester, 'Tom');
      await doneOn(tester, tom, IntentionKind.write);
      expect(find.text('Full!'), findsOneWidget);
      expect(find.textContaining('Cinema evening is yours!'), findsOneWidget);
      await closeDown(tester);
    });

    testWidgets('shows how many are left on the current card', (tester) async {
      await pumpApp(tester);
      await startCard(tester, 'Cinema evening', stamps: 4);
      final tom = await add(tester, 'Tom');
      await doneOn(tester, tom, IntentionKind.write);
      expect(find.text('+1'), findsOneWidget);
      expect(find.text('3 more stamps and it is yours.'), findsOneWidget);
      await closeDown(tester);
    });
  });

  group('settings', () {
    Future<void> openSettings(WidgetTester tester) async {
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('STAMPS'), 200);
      await tester.pumpAndSettle();
    }

    testWidgets('the Stamps section changes the weights', (tester) async {
      await pumpApp(tester);
      await openSettings(tester);
      expect(
        find.text('What a contact is worth. You can rebalance these any time.'),
        findsOneWidget,
      );
      expect(find.text('Default card size'), findsOneWidget);
      // The first "More" is the close friends' weight (1 -> 2).
      await tester.ensureVisible(find.byTooltip('More').first);
      await tester.tap(find.byTooltip('More').first);
      await tester.pumpAndSettle();
      var s = await real(tester, services.settings.load);
      expect(s.stampWeights.close, 2);
      expect(s.stampWeights.nowAndThen, 2);

      // Card size: the last "Less".
      await tester.ensureVisible(find.byTooltip('Less').last);
      await tester.tap(find.byTooltip('Less').last);
      await tester.pumpAndSettle();
      s = await real(tester, services.settings.load);
      expect(s.stampWeights.cardSize, 9);
      expect(find.text('×2'), findsNWidgets(2));
      expect(find.text('×1'), findsOneWidget);
      expect(find.text('Gaming with close friends, times'), findsOneWidget);
      expect(find.text('+1'), findsNWidgets(2));
      await closeDown(tester);
    });
  });
}

class _NoShortcuts implements AppShortcuts {
  @override
  Future<void> setUp({
    required String captureTitle,
    required VoidCallback onCapture,
  }) async {}
}
