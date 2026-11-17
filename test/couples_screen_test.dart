import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/services.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/contact_event.dart';
import 'package:kept/domain/intention.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/ui/material.dart';
import 'package:kept/ui/people/couple_screen.dart';
import 'package:kept/ui/people/person_screen.dart';

import 'support/fakes.dart';
import 'support/pump_app.dart';

void main() {
  late AppServices services;
  late FakeChatOpener opener;
  late Person anna, tom;
  final now = DateTime(2026, 11, 16, 14);

  setUp(() {
    opener = FakeChatOpener();
    services = AppServices(
      db: AppDatabase(NativeDatabase.memory()),
      openDemo: () => AppDatabase(NativeDatabase.memory()),
    );
  });

  /// Anna Roth and Tom Berger (both Telegram), Eva Lund alone; the first
  /// two are a couple if [linked].
  Future<void> seed(WidgetTester tester, {bool linked = true}) =>
      tester.runAsync(() async {
        final people = services.peopleFor(demo: false);
        anna = await people.add(
          name: 'Anna Roth',
          closeness: Closeness.close,
          mainMessenger: Messenger.telegram,
          telegramUsername: 'anna',
        );
        tom = await people.add(
          name: 'Tom Berger',
          closeness: Closeness.nowAndThen,
          mainMessenger: Messenger.telegram,
          telegramUsername: 'tom',
        );
        await people.add(name: 'Eva Lund', closeness: Closeness.close);
        if (linked) {
          await services.groupsFor(demo: false).createCouple(anna.id, tom.id);
        }
      });

  Future<void> start(WidgetTester tester) async {
    await pumpKeptApp(
      tester,
      services: services,
      clock: () => now,
      viewSize: const Size(800, 2400),
      opener: opener,
    );
    await tester.pumpAndSettle();
  }

  Future<void> closeDown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(services.close);
  }

  Future<void> openCouplePage(WidgetTester tester) async {
    await tester.tap(find.text('People'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Anna & Tom'));
    await tester.pumpAndSettle();
  }

  testWidgets('the edit page links and unlinks a partner', (tester) async {
    await seed(tester, linked: false);
    await start(tester);
    await tester.tap(find.text('People'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tom'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Link a partner'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Link a partner'));
    await tester.pumpAndSettle();
    // The picker offers the others, not Tom himself.
    expect(
      find.descendant(
        of: find.byType(ListTile),
        matching: find.text('Tom Berger'),
      ),
      findsNothing,
    );
    await tester.tap(find.text('Anna Roth'));
    await tester.pumpAndSettle();
    expect(find.text('Unlink'), findsOneWidget);
    final couple = await tester.runAsync(
      () => services.groupsFor(demo: false).coupleOf(tom.id),
    );
    expect(couple!.members.map((p) => p.id), [tom.id, anna.id]);

    await tester.tap(find.text('Unlink'));
    await tester.pumpAndSettle();
    expect(find.textContaining('go to each of them'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Unlink'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Link a partner'), findsOneWidget);
    expect(
      await tester.runAsync(
        () => services.groupsFor(demo: false).coupleOf(tom.id),
      ),
      isNull,
    );
    await closeDown(tester);
  });

  testWidgets('the People tab shows a couple as one row', (tester) async {
    await seed(tester);
    await start(tester);
    await tester.tap(find.text('People'));
    await tester.pumpAndSettle();
    expect(find.text('Anna & Tom'), findsOneWidget);
    expect(find.text('Anna'), findsNothing);
    expect(find.text('Tom'), findsNothing);
    expect(find.text('Eva'), findsOneWidget);
    await closeDown(tester);
  });

  testWidgets('capture for a couple stores the group id', (tester) async {
    await seed(tester);
    await start(tester);
    await tester.tap(find.text('Anna & Tom'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'bouldering');
    await tester.tap(find.text('Save for Anna & Tom'));
    await tester.pumpAndSettle();
    final all = await tester.runAsync(
      () => services.intentionsFor(demo: false).watchOpen().first,
    );
    final i = all!.single;
    expect(i.personId, isNull);
    expect(i.groupId, isNotNull);
    expect(i.kind, IntentionKind.meet);
    await closeDown(tester);
  });

  testWidgets('a couple thought shows on Home and on both person pages', (
    tester,
  ) async {
    await seed(tester);
    await tester.runAsync(() async {
      final couple = await services.groupsFor(demo: false).coupleOf(anna.id);
      await services
          .intentionsFor(demo: false)
          .add(groupId: couple!.group.id, note: 'climbing day');
    });
    await start(tester);
    expect(find.text('climbing day'), findsWidgets);
    expect(find.text('Anna & Tom'), findsWidgets);

    // Tapping it on Home opens the couple page.
    expect(find.text('ON YOUR MIND'), findsOneWidget);
    await tester.tap(find.text('climbing day').last);
    await tester.pumpAndSettle();
    expect(find.byType(CoupleScreen), findsOneWidget);

    for (final name in ['Anna', 'Tom']) {
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
      expect(find.byType(PersonScreen), findsOneWidget);
      expect(find.text('climbing day'), findsWidgets);
      expect(
        find.text(name == 'Anna' ? 'with Tom' : 'with Anna'),
        findsWidgets,
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
    await closeDown(tester);
  });

  testWidgets('we met writes two rows with one shared id and two stamps', (
    tester,
  ) async {
    await seed(tester);
    await start(tester);
    await openCouplePage(tester);
    await tester.tap(find.text('We met'));
    await tester.pumpAndSettle();
    expect(find.text('Nice one!'), findsOneWidget);

    final events = (await tester.runAsync(
      () => services.contactEventsFor(demo: false).watchAll().first,
    ))!;
    expect(events, hasLength(2));
    expect({for (final e in events) e.personId}, {anna.id, tom.id});
    expect(events.map((e) => e.sharedId).toSet(), hasLength(1));
    expect(events.first.sharedId, isNotNull);
    expect(events.every((e) => e.kind == ContactKind.met), isTrue);
    for (final e in events) {
      final stamps = await tester.runAsync(
        () => services.treatsFor(demo: false).watchForEvent(e.id).first,
      );
      expect(stamps, isNotEmpty);
    }
    // Both names with their stamps.
    expect(find.textContaining('Anna +'), findsOneWidget);
    expect(find.textContaining('Tom +'), findsOneWidget);
    await closeDown(tester);
  });

  testWidgets('Open chat on a couple thought asks whom', (tester) async {
    await seed(tester);
    await tester.runAsync(() async {
      final couple = await services.groupsFor(demo: false).coupleOf(anna.id);
      await services
          .intentionsFor(demo: false)
          .add(groupId: couple!.group.id, note: 'say hi');
    });
    await start(tester);
    await tester.tap(find.text('Open chat'));
    await tester.pumpAndSettle();
    expect(find.text('Who do you want to message?'), findsOneWidget);
    expect(opener.opened, isEmpty);
    await tester.tap(find.text('Tom').last);
    await tester.pumpAndSettle();
    expect(opener.opened.single.uri.toString(), contains('tom'));
    await closeDown(tester);
  });

  testWidgets('writing to one of the two stores a contact for that one only', (
    tester,
  ) async {
    await seed(tester);
    late String intentionId;
    await tester.runAsync(() async {
      final couple = await services.groupsFor(demo: false).coupleOf(anna.id);
      final i = await services
          .intentionsFor(demo: false)
          .add(groupId: couple!.group.id, kind: IntentionKind.write);
      intentionId = i.id;
      await services
          .contactEventsFor(demo: false)
          .completeIntention(intentionId, onlyPersonId: tom.id);
    });
    final events = (await tester.runAsync(
      () => services.contactEventsFor(demo: false).watchAll().first,
    ))!;
    expect(events.single.personId, tom.id);
    expect(events.single.kind, ContactKind.wrote);
    expect(events.single.sharedId, isNull);
    await closeDown(tester);
  });
}
