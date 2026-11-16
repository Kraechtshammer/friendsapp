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
import 'package:kept/platform/app_shortcuts.dart';
import 'package:kept/ui/home/nice_one_screen.dart';
import 'package:kept/ui/material.dart';
import 'package:kept/ui/people/person_screen.dart';

import 'fake_notifications.dart';

void main() {
  late AppServices services;
  late Person tom;

  setUp(() {
    services = AppServices(
      db: AppDatabase(NativeDatabase.memory()),
      openDemo: () => AppDatabase(NativeDatabase.memory()),
    );
  });

  Future<void> start(WidgetTester tester, IntentionKind kind) async {
    // Tall, so the list below tonight's pick is built too.
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      tom = await services
          .peopleFor(demo: false)
          .add(name: 'Tom Berger', closeness: Closeness.close);
      await services
          .intentionsFor(demo: false)
          .add(personId: tom.id, note: 'Bouldering', kind: kind);
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          servicesProvider.overrideWithValue(services),
          firstStartEnabledProvider.overrideWithValue(false),
          notificationsProvider.overrideWithValue(FakeNotifications()),
          appShortcutsProvider.overrideWithValue(_NoShortcuts()),
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

  Future<List<ContactEvent>> events(WidgetTester tester) => tester
      .runAsync(
        () =>
            services.contactEventsFor(demo: false).watchForPerson(tom.id).first,
      )
      .then((v) => v!);

  Future<List<Intention>> open(WidgetTester tester) => tester
      .runAsync(() => services.intentionsFor(demo: false).watchOpen().first)
      .then((v) => v!);

  Future<void> tapDone(WidgetTester tester) async {
    await tester.tap(find.text('Done').first);
    await tester.pumpAndSettle();
  }

  testWidgets('Done stores a manual event and opens the screen', (
    tester,
  ) async {
    await start(tester, IntentionKind.write);
    await tapDone(tester);

    expect(find.byType(NiceOneScreen), findsOneWidget);
    expect(find.text('Nice one!'), findsOneWidget);
    final stored = await events(tester);
    expect(stored.single.source, ContactSource.manual);
    expect(stored.single.kind, ContactKind.wrote);
    expect(await open(tester), isEmpty);

    // Leaving at once keeps the event and adds nothing.
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(NiceOneScreen), findsNothing);
    expect((await events(tester)).single.note, isNull);
    await closeDown(tester);
  });

  testWidgets('Done on the person page does the same', (tester) async {
    await start(tester, IntentionKind.call);
    await tester.tap(find.text('People'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tom'));
    await tester.pumpAndSettle();
    await tapDone(tester);
    expect(find.byType(NiceOneScreen), findsOneWidget);
    expect((await events(tester)).single.kind, ContactKind.called);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(NiceOneScreen), findsNothing);
    expect(find.byType(PersonScreen), findsOneWidget);
    await closeDown(tester);
  });

  testWidgets('closing saves the activity and the line', (tester) async {
    await start(tester, IntentionKind.meet);
    await tapDone(tester);

    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(2));
    expect(
      tester.widget<TextField>(fields.first).controller!.text,
      'Bouldering',
    );
    await tester.enterText(fields.first, 'Bouldering hall');
    await tester.enterText(fields.last, 'new job in March');
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    final event = (await events(tester)).single;
    expect(event.kind, ContactKind.met);
    expect(event.activity, 'Bouldering hall');
    expect(event.note, 'new job in March');
    expect(await open(tester), isEmpty);

    // The line shows as "Last time" once Tom has an open thought again.
    await tester.runAsync(
      () => services
          .intentionsFor(demo: false)
          .add(personId: tom.id, note: 'Call him'),
    );
    await tester.pumpAndSettle();
    // In the pick and in the list below it.
    expect(find.text('Last time: new job in March'), findsNWidgets(2));
    await closeDown(tester);
  });

  testWidgets('empty text is stored as null', (tester) async {
    await start(tester, IntentionKind.game);
    await tapDone(tester);
    await tester.enterText(find.byType(TextField).first, '  ');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    final event = (await events(tester)).single;
    expect(event.activity, isNull);
    expect(event.note, isNull);
    await closeDown(tester);
  });

  testWidgets('Remind me keeps the line as an open thought', (tester) async {
    await start(tester, IntentionKind.write);
    await tapDone(tester);
    await tester.enterText(find.byType(TextField), 'ask about the job');
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    final thoughts = await open(tester);
    expect(thoughts.single.note, 'ask about the job');
    expect(thoughts.single.kind, IntentionKind.write);
    expect(thoughts.single.personId, tom.id);
    expect((await events(tester)).single.note, 'ask about the job');
    await closeDown(tester);
  });

  testWidgets('Remind me with an empty line adds nothing', (tester) async {
    await start(tester, IntentionKind.write);
    await tapDone(tester);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(await open(tester), isEmpty);
    await closeDown(tester);
  });

  testWidgets('the activity field is for meet and game only', (tester) async {
    for (final (kind, fields) in [
      (IntentionKind.write, 1),
      (IntentionKind.call, 1),
      (IntentionKind.meet, 2),
      (IntentionKind.game, 2),
    ]) {
      services = AppServices(
        db: AppDatabase(NativeDatabase.memory()),
        openDemo: () => AppDatabase(NativeDatabase.memory()),
      );
      await start(tester, kind);
      await tapDone(tester);
      expect(find.byType(TextField), findsNWidgets(fields), reason: '$kind');
      expect(
        find.text('WHAT DID YOU DO?'),
        fields == 2 ? findsOneWidget : findsNothing,
      );
      await closeDown(tester);
    }
  });

  group('Planning to meet up?', () {
    testWidgets('a row, closed at first; closing with nothing stores nothing', (
      tester,
    ) async {
      await start(tester, IntentionKind.write);
      await tapDone(tester);
      expect(find.text('Planning to meet up?'), findsOneWidget);
      expect(find.text('Plan it'), findsOneWidget);
      expect(find.text('Soon'), findsNothing);
      await tester.tap(find.text('Plan it'));
      await tester.pumpAndSettle();
      expect(find.text('Soon'), findsOneWidget);
      expect(find.text('Later'), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(await open(tester), isEmpty);
      await closeDown(tester);
    });

    testWidgets('a "when" and a text become a meet thought on closing', (
      tester,
    ) async {
      await start(tester, IntentionKind.write);
      await tapDone(tester);
      await tester.tap(find.text('Plan it'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Soon'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Cinema');
      // Nothing is stored before the screen closes.
      expect(await open(tester), isEmpty);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      final planned = (await open(tester)).single;
      expect(planned.kind, IntentionKind.meet);
      expect(planned.personId, tom.id);
      expect(planned.note, 'Cinema');
      expect(planned.horizon, Horizon.soon);
      expect(planned.date, isNull);
      await closeDown(tester);
    });

    testWidgets('a date is stored as the date of the thought', (tester) async {
      await start(tester, IntentionKind.write);
      await tapDone(tester);
      await tester.tap(find.text('Plan it'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Date'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      final planned = (await open(tester)).single;
      expect(planned.kind, IntentionKind.meet);
      expect(planned.date, isNotNull);
      expect(planned.note, '');
      await closeDown(tester);
    });

    testWidgets('nothing is shown when the person has an open meet plan', (
      tester,
    ) async {
      await start(tester, IntentionKind.write);
      await tester.runAsync(
        () => services
            .intentionsFor(demo: false)
            .add(
              personId: tom.id,
              note: 'Hall',
              kind: IntentionKind.meet,
              when: const When.horizon(Horizon.later),
            ),
      );
      await tester.pumpAndSettle();
      await tapDone(tester);
      expect(find.byType(NiceOneScreen), findsOneWidget);
      expect(find.text('Planning to meet up?'), findsNothing);
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
