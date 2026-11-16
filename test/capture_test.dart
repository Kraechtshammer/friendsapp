import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/app.dart';
import 'package:kept/app/providers.dart';
import 'package:kept/app/services.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/intention.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/platform/app_shortcuts.dart';
import 'package:kept/ui/home/nice_one_screen.dart';
import 'package:kept/ui/material.dart';
import 'package:kept/ui/people/person_screen.dart';

import 'fake_notifications.dart';

void main() {
  late AppServices services;
  late _FakeShortcuts shortcuts;
  var now = DateTime(2026, 11, 16, 14);

  setUp(() {
    now = DateTime(2026, 11, 16, 14);
    shortcuts = _FakeShortcuts();
    services = AppServices(
      db: AppDatabase(NativeDatabase.memory()),
      openDemo: () => AppDatabase(NativeDatabase.memory()),
    );
  });

  Future<void> addPeople(WidgetTester tester, List<String> names) =>
      tester.runAsync(() async {
        for (final n in names) {
          await services
              .peopleFor(demo: false)
              .add(name: n, closeness: Closeness.close);
        }
      });

  Future<void> start(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          servicesProvider.overrideWithValue(services),
          notificationsProvider.overrideWithValue(FakeNotifications()),
          clockProvider.overrideWithValue(() => now),
          appShortcutsProvider.overrideWithValue(shortcuts),
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

  Future<void> saveFor(WidgetTester tester, String name) async {
    await tester.tap(find.text('Save for $name'));
    await tester.pumpAndSettle();
  }

  testWidgets('captures a thought for a recent person', (tester) async {
    await addPeople(tester, ['Tom Berger', 'Anna Roth']);
    await start(tester);

    // Save needs a person: nothing to press before one is chosen.
    expect(find.textContaining('Save for'), findsNothing);
    expect(find.text('On your mind'), findsNothing);

    await tester.enterText(find.byType(TextField), 'saw a bouldering video');
    await tester.tap(find.text('Tom'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Call'));
    await tester.pumpAndSettle();
    await saveFor(tester, 'Tom');

    expect(find.text('Saved for Tom.'), findsOneWidget);
    expect(find.text('Save for Tom'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(find.text('ON YOUR MIND'), findsOneWidget);
    expect(find.text('saw a bouldering video'), findsOneWidget);

    final rows = await tester.runAsync(
      () => services.intentionsFor(demo: false).watchOpen().first,
    );
    expect(rows!.single.kind, IntentionKind.call);
    expect(rows.single.note, 'saw a bouldering video');

    // The row opens the person's page, which lists it too.
    await tester.tap(find.text('saw a bouldering video'));
    await tester.pumpAndSettle();
    expect(find.byType(PersonScreen), findsOneWidget);
    expect(find.text('ON YOUR MIND'), findsOneWidget);
    expect(find.text('saw a bouldering video'), findsOneWidget);

    // Done removes it here and on Home.
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Nice one!'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(NiceOneScreen),
        matching: find.text('Close'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('ON YOUR MIND'), findsNothing);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('ON YOUR MIND'), findsNothing);
    expect(find.text('saw a bouldering video'), findsNothing);

    await closeDown(tester);
  });

  testWidgets('tapping a chosen person again deselects them', (tester) async {
    await addPeople(tester, ['Tom']);
    await start(tester);
    await tester.tap(find.text('Tom'));
    await tester.pumpAndSettle();
    expect(find.text('Save for Tom'), findsOneWidget);
    await tester.tap(find.text('Tom'));
    await tester.pumpAndSettle();
    expect(find.text('Save for Tom'), findsNothing);
    await closeDown(tester);
  });

  testWidgets('picks someone through More and search', (tester) async {
    await addPeople(tester, ['Ann', 'Bob', 'Cleo', 'Dan', 'Eve Sommer']);
    await start(tester);
    // Only four are on the card.
    expect(find.text('Eve'), findsNothing);
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'somm');
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsOneWidget);
    await tester.tap(find.text('Eve Sommer'));
    await tester.pumpAndSettle();
    expect(find.text('Save for Eve'), findsOneWidget);
    await saveFor(tester, 'Eve');
    expect(find.text('Saved for Eve.'), findsOneWidget);
    await closeDown(tester);
  });

  testWidgets('without people it offers to add some', (tester) async {
    await start(tester);
    expect(find.text('Add people'), findsOneWidget);
    await tester.tap(find.text('Add people'));
    await tester.pumpAndSettle();
    expect(find.text('Your people'), findsOneWidget);
    await closeDown(tester);
  });

  testWidgets('the greeting follows the clock', (tester) async {
    for (final (hour, text) in [
      (8, 'Good morning'),
      (10, 'Good morning'),
      (11, 'Hello'),
      (16, 'Hello'),
      (17, 'Good evening'),
      (22, 'Good evening'),
    ]) {
      now = DateTime(2026, 11, 16, hour);
      await start(tester);
      expect(find.text(text), findsOneWidget, reason: '$hour');
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.runAsync(services.close);
  });

  testWidgets('the shortcut focuses the capture field', (tester) async {
    await addPeople(tester, ['Tom']);
    await start(tester);
    expect(shortcuts.title, 'Capture a thought');
    await tester.tap(find.text('People'));
    await tester.pumpAndSettle();

    shortcuts.onCapture!();
    await tester.pumpAndSettle();
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.focusNode!.hasFocus, isTrue);
    expect(find.text("Who's on your mind?"), findsOneWidget);
    await closeDown(tester);
  });
}

class _FakeShortcuts implements AppShortcuts {
  String? title;
  VoidCallback? onCapture;

  @override
  Future<void> setUp({
    required String captureTitle,
    required VoidCallback onCapture,
  }) async {
    title = captureTitle;
    this.onCapture = onCapture;
  }
}
