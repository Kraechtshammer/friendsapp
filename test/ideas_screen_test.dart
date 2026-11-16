import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/app.dart';
import 'package:kept/app/providers.dart';
import 'package:kept/app/services.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/idea.dart';
import 'package:kept/domain/intention.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/platform/share_receiver.dart';
import 'package:kept/ui/material.dart';

import 'fake_notifications.dart';
import 'fake_share_receiver.dart';
import 'support/fakes.dart';

/// M10: the ideas on the person page, the idea line on a pick, the link on
/// a thought, and "Keep this for…" after a share.
void main() {
  late AppServices services;
  late Person tom;
  late FakeShareReceiver shares;
  late FakeLinkOpener links;
  late Directory tmp;

  setUp(() async {
    services = AppServices(
      db: AppDatabase(NativeDatabase.memory()),
      openDemo: () => AppDatabase(NativeDatabase.memory()),
    );
    tmp = Directory.systemTemp.createTempSync('kept_share_');
    shares = FakeShareReceiver(directory: tmp);
    links = FakeLinkOpener();
  });
  tearDown(() {
    if (tmp.existsSync()) tmp.deleteSync(recursive: true);
  });

  /// Tom with [thought] (if given) and [ideas], then the app on Home.
  Future<void> start(
    WidgetTester tester, {
    (String, IntentionKind, String?)? thought,
    List<(String, IdeaKind)> ideas = const [],
  }) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      tom = await services
          .peopleFor(demo: false)
          .add(
            name: 'Tom Berger',
            closeness: Closeness.close,
            mainMessenger: Messenger.whatsapp,
            phone: '+4900000000101',
          );
      if (thought case (final note, final kind, final link)) {
        await services
            .intentionsFor(demo: false)
            .add(
              personId: tom.id,
              note: note,
              kind: kind,
              link: link,
              now: DateTime(2026, 11, 1),
            );
      }
      for (final (i, (note, kind)) in ideas.indexed) {
        await services
            .ideasFor(demo: false)
            .add(
              personId: tom.id,
              note: note,
              kind: kind,
              now: DateTime(2026, 11, 2 + i),
            );
      }
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          servicesProvider.overrideWithValue(services),
          firstStartEnabledProvider.overrideWithValue(false),
          notificationsProvider.overrideWithValue(FakeNotifications()),
          appShortcutsProvider.overrideWithValue(NoShortcuts()),
          shareReceiverProvider.overrideWithValue(shares),
          linkOpenerProvider.overrideWithValue(links),
        ],
        child: const KeptApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openTom(WidgetTester tester) async {
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

  Future<void> settleWrite(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text).last);
    await settleWrite(tester);
    await tester.pumpAndSettle();
  }

  Future<List<Idea>> storedIdeas(WidgetTester tester) => tester
      .runAsync(
        () => services.ideasFor(demo: false).watchForPerson(tom.id).first,
      )
      .then((v) => v!);

  Future<List<Intention>> storedThoughts(WidgetTester tester) => tester
      .runAsync(
        () => services.intentionsFor(demo: false).watchForPerson(tom.id).first,
      )
      .then((v) => v!);

  Finder sheetField(int index) => find
      .descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(TextField),
      )
      .at(index);

  group('the ideas section', () {
    testWidgets('adds ideas of both kinds, grouped', (tester) async {
      await start(tester);
      await openTom(tester);
      expect(find.text('IDEAS'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'bouldering hall');
      await tester.pump();
      await tapText(tester, 'Add');
      await tester.enterText(find.byType(TextField), 'his trip');
      await tester.tap(find.text('Talk about'));
      await tester.pump();
      // The keyboard's Done adds too.
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await settleWrite(tester);
      await tester.pumpAndSettle();

      final ideas = await storedIdeas(tester);
      // Both in the same second: the order between them is not fixed.
      expect(
        ideas.map((i) => (i.note, i.kind)),
        unorderedEquals([
          ('his trip', IdeaKind.toTalk),
          ('bouldering hall', IdeaKind.toDo),
        ]),
      );
      expect(find.text('bouldering hall'), findsOneWidget);
      expect(find.text('his trip'), findsOneWidget);
      // Headings ("Do together" is also a chip, so twice).
      double top(Finder f) => tester.getTopLeft(f).dy;
      expect(
        top(find.text('bouldering hall')),
        lessThan(top(find.text('his trip'))),
      );
      expect(find.text('Talk about'), findsNWidgets(2));
      await closeDown(tester);
    });

    testWidgets('edits text, kind and link; the link opens', (tester) async {
      await start(tester, ideas: [('hall', IdeaKind.toDo)]);
      await openTom(tester);
      await tester.tap(find.text('hall'));
      await tester.pumpAndSettle();
      expect(find.text('Edit idea'), findsOneWidget);
      await tester.enterText(sheetField(0), 'bouldering hall');
      await tester.tap(find.text('Talk about').last);
      await tester.enterText(sheetField(1), 'example.org/hall');
      await tester.pump();
      await tapText(tester, 'Save');
      final idea = (await storedIdeas(tester)).single;
      expect(
        (idea.note, idea.kind, idea.link),
        ('bouldering hall', IdeaKind.toTalk, 'example.org/hall'),
      );
      // The link shows as a small row and opens.
      await tester.tap(find.text('example.org/hall'));
      await tester.pump();
      expect(links.opened, ['example.org/hall']);
      await closeDown(tester);
    });

    testWidgets('ticks off into "1 done", opens again, deletes', (
      tester,
    ) async {
      await start(
        tester,
        ideas: [('hall', IdeaKind.toDo), ('trip', IdeaKind.toTalk)],
      );
      await openTom(tester);
      await tester.tap(find.byTooltip('Tick off').first);
      await settleWrite(tester);
      await tester.pumpAndSettle();
      expect(find.text('hall'), findsNothing);
      expect(find.text('1 done'), findsOneWidget);
      expect(
        (await storedIdeas(tester)).firstWhere((i) => i.note == 'hall').doneAt,
        isNotNull,
      );
      await tester.tap(find.text('1 done'));
      await tester.pumpAndSettle();
      expect(find.text('hall'), findsOneWidget);
      await tester.tap(find.byTooltip('Open again'));
      await settleWrite(tester);
      await tester.pumpAndSettle();
      expect(find.text('1 done'), findsNothing);

      await tester.tap(find.text('trip'));
      await tester.pumpAndSettle();
      await tapText(tester, 'Delete');
      expect((await storedIdeas(tester)).map((i) => i.note), ['hall']);
      expect(find.text('trip'), findsNothing);
      await closeDown(tester);
    });
  });

  group('the idea line on a pick', () {
    testWidgets('a meet-up shows the newest to-do idea', (tester) async {
      await start(
        tester,
        thought: ('Bouldering', IntentionKind.meet, null),
        ideas: [
          ('old hall', IdeaKind.toDo),
          ('his trip', IdeaKind.toTalk),
          ('hall in Altona', IdeaKind.toDo),
        ],
      );
      expect(find.text('Idea: hall in Altona'), findsOneWidget);
      expect(find.textContaining('his trip'), findsNothing);
      await closeDown(tester);
    });

    testWidgets('writing shows the talk idea', (tester) async {
      await start(
        tester,
        thought: ('Say hi', IntentionKind.write, null),
        ideas: [('hall', IdeaKind.toDo), ('his trip', IdeaKind.toTalk)],
      );
      expect(find.text('Idea: his trip'), findsOneWidget);
      await closeDown(tester);
    });

    testWidgets('nothing without a fitting idea', (tester) async {
      await start(
        tester,
        thought: ('Say hi', IntentionKind.call, null),
        ideas: [('hall', IdeaKind.toDo)],
      );
      expect(find.textContaining('Idea:'), findsNothing);
      await closeDown(tester);
    });
  });

  testWidgets('a thought with a link shows the mark; the sheet opens it', (
    tester,
  ) async {
    await start(
      tester,
      thought: ('Ramen place', IntentionKind.write, 'https://example.org/r'),
    );
    expect(find.byIcon(Icons.link_rounded), findsWidgets);
    await tester.tap(find.byTooltip('Edit thought').last);
    await tester.pumpAndSettle();
    expect(find.text('Edit thought'), findsOneWidget);
    await tester.tap(find.text('example.org/r'));
    await tester.pump();
    expect(links.opened, ['https://example.org/r']);
    // Changing the link is stored.
    await tester.enterText(sheetField(1), 'https://example.org/s');
    await tester.pump();
    await tapText(tester, 'Save');
    expect((await storedThoughts(tester)).single.link, 'https://example.org/s');
    await closeDown(tester);
  });

  group('Keep this for…', () {
    Future<void> share(WidgetTester tester, SharedItem item) async {
      shares.send(item);
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('Keep this for…'), findsOneWidget);
    }

    testWidgets('plain text becomes a thought with its kind', (tester) async {
      await start(tester);
      await share(tester, const SharedText('ask about the new job'));
      expect(
        tester.widget<TextField>(sheetField(0)).controller!.text,
        'ask about the new job',
      );
      // No Save until someone is picked.
      expect(find.text('Keep for Tom'), findsNothing);
      await tester.tap(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Tom'),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Thought'));
      await tester.pump();
      await tester.tap(find.text('Call').last);
      await tester.pump();
      await tapText(tester, 'Keep for Tom');
      final thought = (await storedThoughts(tester)).single;
      expect(
        (thought.note, thought.kind, thought.link),
        ('ask about the new job', IntentionKind.call, null),
      );
      expect(find.text('Kept for Tom.'), findsOneWidget);
      expect(find.text('Keep this for…'), findsNothing);
      await closeDown(tester);
    });

    testWidgets('a link goes into the link, the rest into the text', (
      tester,
    ) async {
      await start(tester);
      await openTom(tester);
      await share(
        tester,
        const SharedText('Boulder hall Altona\nhttps://example.org/hall'),
      );
      expect(find.text('example.org/hall'), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Tom'),
        ),
      );
      await tester.pump();
      await tapText(tester, 'Keep for Tom');
      final idea = (await storedIdeas(tester)).single;
      expect(
        (idea.note, idea.kind, idea.link),
        ('Boulder hall Altona', IdeaKind.toDo, 'https://example.org/hall'),
      );
      // The app stays where it was: on Tom's page, now with the idea.
      expect(find.text('IDEAS'), findsOneWidget);
      expect(find.text('Boulder hall Altona'), findsOneWidget);
      await closeDown(tester);
    });

    testWidgets('a picture becomes an idea, never a thought', (tester) async {
      final file = File('${tmp.path}/a.jpg')..writeAsBytesSync([1, 2, 3]);
      await start(tester);
      await share(tester, SharedImage(file.path));
      expect(find.text('Thought'), findsNothing);
      await tester.enterText(sheetField(0), 'this jacket');
      await tester.tap(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Tom'),
        ),
      );
      await tester.tap(find.text('Idea to talk about'));
      await tester.pump();
      await tapText(tester, 'Keep for Tom');
      final idea = (await storedIdeas(tester)).single;
      expect(
        (idea.note, idea.kind, idea.imagePath),
        ('this jacket', IdeaKind.toTalk, file.path),
      );
      expect(file.existsSync(), isTrue);
      await closeDown(tester);
    });

    testWidgets('cancelling deletes the copied picture', (tester) async {
      final file = File('${tmp.path}/b.png')..writeAsBytesSync([1, 2, 3]);
      await start(tester);
      await share(tester, SharedImage(file.path));
      await tester.tap(find.text('Cancel'));
      await settleWrite(tester);
      await tester.pumpAndSettle();
      expect(find.text('Keep this for…'), findsNothing);
      expect(await storedIdeas(tester), isEmpty);
      expect(file.existsSync(), isFalse);
      await closeDown(tester);
    });
  });
}
