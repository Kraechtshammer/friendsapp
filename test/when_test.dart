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
import 'package:kept/platform/app_shortcuts.dart';
import 'package:kept/ui/home/nice_one_screen.dart';
import 'package:kept/ui/material.dart';
import 'package:kept/ui/people/person_screen.dart';

import 'fake_notifications.dart';

/// Monday 16 November 2026, 14:00.
final now = DateTime(2026, 11, 16, 14);

void main() {
  late AppServices services;
  late Person tom;

  setUp(() {
    services = AppServices(
      db: AppDatabase(NativeDatabase.memory()),
      openDemo: () => AppDatabase(NativeDatabase.memory()),
    );
  });

  /// Tom (WhatsApp) and Anna (birthday on 19 November). [seed] adds
  /// thoughts; [mode] is the open items setting.
  Future<void> start(
    WidgetTester tester, {
    Future<void> Function(
      Future<Intention> Function(
        String note, {
        Person? who,
        IntentionKind kind,
        When when,
        DateTime? created,
      })
      add,
    )?
    seed,
    OpenItemsMode mode = OpenItemsMode.three,
    bool birthday = true,
  }) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      final people = services.peopleFor(demo: false);
      tom = await people.add(
        name: 'Tom Berger',
        closeness: Closeness.close,
        mainMessenger: Messenger.whatsapp,
        phone: '+4900000000101',
      );
      await people.add(
        name: 'Anna Keller',
        closeness: Closeness.nowAndThen,
        birthdayMonth: birthday ? 11 : null,
        birthdayDay: birthday ? 19 : null,
        birthdayYear: birthday ? 1990 : null,
      );
      await services.settings.update((s) => s.copyWith(openItems: mode));
      await seed?.call(
        (
          note, {
          who,
          kind = IntentionKind.meet,
          when = const When.none(),
          created,
        }) => services
            .intentionsFor(demo: false)
            .add(
              personId: (who ?? tom).id,
              note: note,
              kind: kind,
              when: when,
              now: created ?? DateTime(2026, 11, 10, 12),
            ),
      );
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          servicesProvider.overrideWithValue(services),
          firstStartEnabledProvider.overrideWithValue(false),
          notificationsProvider.overrideWithValue(FakeNotifications()),
          clockProvider.overrideWithValue(() => now),
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

  Future<List<Intention>> all(WidgetTester tester) => tester
      .runAsync(
        () => services.intentionsFor(demo: false).watchForPerson(tom.id).first,
      )
      .then((v) => v!);

  Future<List<ContactEvent>> events(WidgetTester tester) => tester
      .runAsync(
        () =>
            services.contactEventsFor(demo: false).watchForPerson(tom.id).first,
      )
      .then((v) => v!);

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  /// Picks day [day] of the month the date picker opens on, and confirms.
  Future<void> pickDay(WidgetTester tester, String day) async {
    await tester.tap(find.text(day));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }

  Future<void> goToUpcoming(WidgetTester tester) async {
    await tester.tap(find.text('Upcoming'));
    await tester.pumpAndSettle();
  }

  group('capture', () {
    /// Types a note, picks Tom, runs [choose], saves.
    Future<Intention> capture(
      WidgetTester tester,
      Future<void> Function() choose,
    ) async {
      await tester.enterText(find.byType(TextField).first, 'hike');
      await tapText(tester, 'Tom');
      await choose();
      await tapText(tester, 'Save for Tom');
      final rows = await all(tester);
      expect(rows, hasLength(1));
      return rows.single;
    }

    testWidgets('the row of chips is there once a person is chosen', (
      tester,
    ) async {
      await start(tester);
      expect(find.text('Soon'), findsNothing);
      await tapText(tester, 'Tom');
      for (final label in ['Date', 'Soon', 'Later', 'When…']) {
        expect(find.text(label), findsOneWidget);
      }
      // Nothing chosen: no condition field, only the note field.
      expect(find.byType(TextField), findsOneWidget);
      await closeDown(tester);
    });

    testWidgets('without a when it stores none', (tester) async {
      await start(tester);
      final i = await capture(tester, () async {});
      expect(whenFields(i), (null, null, null));
      await closeDown(tester);
    });

    testWidgets('a date without a time is stored at midnight', (tester) async {
      await start(tester);
      final i = await capture(tester, () async {
        await tapText(tester, 'Date');
        await pickDay(tester, '20');
        // The chip now shows the day, and a Time chip offers the time.
        expect(find.text('Fri 20 Nov'), findsOneWidget);
        expect(find.text('Time'), findsOneWidget);
        expect(find.text('Soon'), findsNothing);
      });
      expect(whenFields(i), (DateTime(2026, 11, 20), null, null));
      expect(When.date(i.date!).hasTime, isFalse);
      await closeDown(tester);
    });

    testWidgets('a date with a time', (tester) async {
      await start(tester);
      final i = await capture(tester, () async {
        await tapText(tester, 'Date');
        await pickDay(tester, '20');
        await tapText(tester, 'Time');
        // The time picker opens at 12:00; OK takes it.
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        expect(find.textContaining('12:00'), findsOneWidget);
      });
      expect(i.date, DateTime(2026, 11, 20, 12));
      await closeDown(tester);
    });

    testWidgets('cancelling the date picker changes nothing', (tester) async {
      await start(tester);
      final i = await capture(tester, () async {
        await tapText(tester, 'Date');
        await tapText(tester, 'Cancel');
        expect(find.text('Date'), findsOneWidget);
      });
      expect(i.date, isNull);
      await closeDown(tester);
    });

    testWidgets('Soon and Later', (tester) async {
      await start(tester);
      var i = await capture(tester, () => tapText(tester, 'Soon'));
      expect(whenFields(i), (null, Horizon.soon, null));
      await closeDown(tester);

      services = AppServices(
        db: AppDatabase(NativeDatabase.memory()),
        openDemo: () => AppDatabase(NativeDatabase.memory()),
      );
      await start(tester);
      i = await capture(tester, () => tapText(tester, 'Later'));
      expect(whenFields(i), (null, Horizon.later, null));
      await closeDown(tester);
    });

    testWidgets('When… with a condition; tapping again clears it', (
      tester,
    ) async {
      await start(tester);
      final i = await capture(tester, () async {
        await tapText(tester, 'When…');
        expect(find.byType(TextField), findsNWidgets(2));
        await tester.enterText(
          find.byType(TextField).last,
          'when it is warm again',
        );
        await tester.pump();
      });
      expect(whenFields(i), (
        null,
        Horizon.whenCondition,
        'when it is warm again',
      ));
      await closeDown(tester);
    });

    testWidgets('a chosen chip is cleared by a second tap', (tester) async {
      await start(tester);
      final i = await capture(tester, () async {
        await tapText(tester, 'Soon');
        await tapText(tester, 'Soon');
      });
      expect(whenFields(i), (null, null, null));
      await closeDown(tester);
    });

    testWidgets('the row is empty again after saving', (tester) async {
      await start(tester);
      await capture(tester, () => tapText(tester, 'Soon'));
      await tester.tap(find.text('Tom').first);
      await tester.pumpAndSettle();
      // Selected chips have the sun fill; none is selected now.
      final soon = tester.widget<Material>(
        find
            .ancestor(of: find.text('Soon'), matching: find.byType(Material))
            .first,
      );
      expect(soon.color, Colors.transparent);
      await closeDown(tester);
    });
  });

  group('a thought row on Home', () {
    testWidgets('the row opens the person, the three dots edit', (
      tester,
    ) async {
      await start(
        tester,
        mode: OpenItemsMode.one,
        seed: (add) async {
          await add('Bouldering', created: DateTime(2026, 11, 1));
          await add('Cinema');
        },
      );
      expect(find.byTooltip('Edit thought'), findsNWidgets(2));
      expect(find.text('Done'), findsWidgets);
      await tester.tap(find.text('Cinema').last);
      await tester.pumpAndSettle();
      expect(find.byType(PersonScreen), findsOneWidget);
      expect(find.text('Edit thought'), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit thought').first);
      await tester.pumpAndSettle();
      expect(find.text('Edit thought'), findsOneWidget);
      expect(find.byType(PersonScreen), findsNothing);
      await closeDown(tester);
    });

    testWidgets('fits at 360 px wide with long German labels', (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('de')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      await start(
        tester,
        seed: (add) => add(
          'Donaudampfschifffahrtsgesellschaft besuchen und danach lange reden',
          when: When.date(DateTime(2026, 11, 21, 11)),
        ),
      );
      tester.view.physicalSize = const Size(360, 2400);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Gedanke bearbeiten'), findsOneWidget);
      expect(find.text('Erledigt'), findsWidgets);
      expect(tester.takeException(), isNull);
      await closeDown(tester);
    });
  });

  group('the edit sheet', () {
    Future<void> openSheet(WidgetTester tester, String note) async {
      await tester.tap(find.byTooltip('Edit thought').last);
      await tester.pumpAndSettle();
      expect(find.text('Edit thought'), findsOneWidget);
    }

    testWidgets('changes text, kind and when', (tester) async {
      await start(
        tester,
        seed: (add) => add('Bouldering', kind: IntentionKind.write),
      );
      await openSheet(tester, 'Bouldering');
      await tester.enterText(
        find.widgetWithText(TextField, 'Bouldering'),
        'Bouldering on Friday',
      );
      await tester.tap(find.text('Meet').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Date').last);
      await tester.pumpAndSettle();
      await pickDay(tester, '20');
      await tapText(tester, 'Save');
      expect(find.text('Edit thought'), findsNothing);

      final i = (await all(tester)).single;
      expect(i.note, 'Bouldering on Friday');
      expect(i.kind, IntentionKind.meet);
      expect(i.date, DateTime(2026, 11, 20));
      expect(find.text('Fri 20 Nov'), findsWidgets);
      await closeDown(tester);
    });

    testWidgets('shows the stored when and can clear it', (tester) async {
      await start(
        tester,
        seed: (add) => add('Pottery', when: const When.horizon(Horizon.later)),
      );
      await openSheet(tester, 'Pottery');
      // Later is chosen; tap again to clear.
      await tester.tap(find.text('Later').last);
      await tester.pumpAndSettle();
      await tapText(tester, 'Save');
      final i = (await all(tester)).single;
      expect(whenFields(i), (null, null, null));
      await closeDown(tester);
    });

    testWidgets('a condition is stored trimmed and only for When…', (
      tester,
    ) async {
      await start(tester, seed: (add) => add('Barbecue'));
      await openSheet(tester, 'Barbecue');
      await tester.tap(find.text('When…').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, '  when it is warm ');
      await tester.pump();
      await tapText(tester, 'Save');
      expect(whenFields((await all(tester)).single), (
        null,
        Horizon.whenCondition,
        'when it is warm',
      ));
      await closeDown(tester);
    });

    testWidgets('Done stores the changes and a contact, then Nice one', (
      tester,
    ) async {
      await start(tester, seed: (add) => add('Bouldering'));
      await openSheet(tester, 'Bouldering');
      await tester.enterText(
        find.widgetWithText(TextField, 'Bouldering'),
        'Bouldering at the hall',
      );
      await tester.tap(find.text('Done').last);
      await tester.pumpAndSettle();
      expect(find.byType(NiceOneScreen), findsOneWidget);
      final i = (await all(tester)).single;
      expect(i.state, IntentionState.done);
      expect(i.note, 'Bouldering at the hall');
      final e = (await events(tester)).single;
      expect(e.kind, ContactKind.met);
      expect(e.source, ContactSource.manual);
      await closeDown(tester);
    });

    testWidgets('Drop drops it and stores no contact', (tester) async {
      await start(tester, seed: (add) => add('Bouldering'));
      await openSheet(tester, 'Bouldering');
      await tester.tap(find.text('Drop').last);
      await tester.pumpAndSettle();
      expect((await all(tester)).single.state, IntentionState.dropped);
      expect(await events(tester), isEmpty);
      expect(find.text('Bouldering'), findsNothing);
      await closeDown(tester);
    });

    testWidgets('the person page opens it too', (tester) async {
      await start(tester, seed: (add) => add('Bouldering'));
      await tapText(tester, 'People');
      await tapText(tester, 'Tom');
      await tester.tap(find.text('Bouldering'));
      await tester.pumpAndSettle();
      expect(find.text('Edit thought'), findsOneWidget);
      await closeDown(tester);
    });
  });

  group('the Upcoming tab', () {
    testWidgets('says so calmly when there is nothing', (tester) async {
      await start(tester, birthday: false);
      await goToUpcoming(tester);
      expect(find.text('Coming up'), findsOneWidget);
      expect(
        find.text(
          'Nothing dated yet. Birthdays and the dates you set will show up '
          'here.',
        ),
        findsOneWidget,
      );
      expect(find.text('NO DATE YET'), findsNothing);
      await closeDown(tester);
    });

    testWidgets('lists birthdays and dated thoughts under their groups', (
      tester,
    ) async {
      await start(
        tester,
        seed: (add) async {
          await add('Bouldering', when: When.date(DateTime(2026, 11, 21, 11)));
          await add('Aunt visits', when: When.date(DateTime(2026, 12, 6)));
          // A date that has passed never shows.
          await add('Old plan', when: When.date(DateTime(2026, 11, 2)));
        },
      );
      await goToUpcoming(tester);
      expect(find.text('THIS WEEK'), findsOneWidget);
      expect(find.text("Anna's birthday"), findsOneWidget);
      expect(find.text('Turns 36'), findsOneWidget);
      expect(find.text('Bouldering'), findsOneWidget);
      expect(find.textContaining('Tom · Meet · 11:00'), findsOneWidget);
      expect(find.text('DECEMBER'), findsOneWidget);
      expect(find.text('Aunt visits'), findsOneWidget);
      expect(find.text('Old plan'), findsNothing);
      // Soonest first.
      final y = [
        for (final t in ["Anna's birthday", 'Bouldering', 'Aunt visits'])
          tester.getTopLeft(find.text(t)).dy,
      ];
      expect(y, orderedEquals([...y]..sort()));
      await closeDown(tester);
    });

    testWidgets('the undated plans are in three groups', (tester) async {
      await start(
        tester,
        seed: (add) async {
          await add('Ramen night', when: const When.horizon(Horizon.soon));
          await add('Coast trip', when: const When.horizon(Horizon.later));
          await add(
            'Barbecue',
            when: const When.horizon(
              Horizon.whenCondition,
              condition: 'when it is warm again',
            ),
          );
        },
      );
      await goToUpcoming(tester);
      expect(find.text('NO DATE YET'), findsOneWidget);
      for (final t in ['Soon', 'Later', 'When…']) {
        expect(find.text(t), findsOneWidget);
      }
      expect(find.text('Tom · when it is warm again'), findsOneWidget);
      expect(find.text('Pick a date'), findsNWidgets(3));
      await closeDown(tester);
    });

    testWidgets('Pick a date moves a plan onto the timeline', (tester) async {
      await start(
        tester,
        seed: (add) =>
            add('Ramen night', when: const When.horizon(Horizon.soon)),
      );
      await goToUpcoming(tester);
      await tapText(tester, 'Pick a date');
      await pickDay(tester, '24');
      expect(find.text('NO DATE YET'), findsNothing);
      expect(find.text('NEXT WEEK'), findsOneWidget);
      expect(find.text('Ramen night'), findsOneWidget);
      final i = (await all(tester)).single;
      expect(whenFields(i), (DateTime(2026, 11, 24), null, null));
      await closeDown(tester);
    });

    testWidgets('tapping a thought opens the sheet', (tester) async {
      await start(
        tester,
        seed: (add) =>
            add('Bouldering', when: When.date(DateTime(2026, 11, 21))),
      );
      await goToUpcoming(tester);
      await tapText(tester, 'Bouldering');
      expect(find.text('Edit thought'), findsOneWidget);
      await closeDown(tester);
    });
  });

  group('coming up on Home', () {
    testWidgets('shows the next two dated things', (tester) async {
      await start(
        tester,
        seed: (add) async {
          await add('Bouldering', when: When.date(DateTime(2026, 11, 21)));
          await add('Aunt visits', when: When.date(DateTime(2026, 12, 6)));
        },
      );
      expect(find.text('COMING UP'), findsOneWidget);
      expect(find.text("Anna's birthday"), findsOneWidget);
      expect(find.text('Bouldering, Tom'), findsOneWidget);
      expect(find.text('Aunt visits, Tom'), findsNothing);
      await closeDown(tester);
    });

    testWidgets('See all leads to the Upcoming tab', (tester) async {
      await start(tester);
      await tapText(tester, 'See all');
      expect(find.text('THIS WEEK'), findsOneWidget);
      expect(find.text('Coming up'), findsOneWidget);
      await closeDown(tester);
    });

    testWidgets('a thought card opens the thought', (tester) async {
      await start(
        tester,
        seed: (add) =>
            add('Bouldering', when: When.date(DateTime(2026, 11, 18))),
      );
      await tapText(tester, 'Bouldering, Tom');
      expect(find.text('Edit thought'), findsOneWidget);
      await closeDown(tester);
    });
  });

  group('Did it happen?', () {
    Future<void> seedPassed(
      Future<Intention> Function(
        String note, {
        Person? who,
        IntentionKind kind,
        When when,
        DateTime? created,
      })
      add,
    ) async {
      await add('Bouldering', when: When.date(DateTime(2026, 11, 14)));
    }

    testWidgets('asks about a thought once its day is over', (tester) async {
      await start(tester, seed: seedPassed);
      expect(find.text('Did it happen?'), findsOneWidget);
      expect(find.text('Tom · Bouldering · Sat 14 Nov'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      await closeDown(tester);
    });

    testWidgets('not before: a thought of today is not asked about', (
      tester,
    ) async {
      await start(
        tester,
        seed: (add) =>
            add('Bouldering', when: When.date(DateTime(2026, 11, 16))),
      );
      expect(find.text('Did it happen?'), findsNothing);
      await closeDown(tester);
    });

    testWidgets('Yes completes it as a contact at the planned date', (
      tester,
    ) async {
      await start(tester, seed: seedPassed);
      await tapText(tester, 'Yes');
      expect(find.byType(NiceOneScreen), findsOneWidget);
      final i = (await all(tester)).single;
      expect(i.state, IntentionState.done);
      final e = (await events(tester)).single;
      expect(e.kind, ContactKind.met);
      expect(e.source, ContactSource.confirmed);
      expect(e.at, DateTime(2026, 11, 14));
      expect(e.intentionId, i.id);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Did it happen?'), findsNothing);
      await closeDown(tester);
    });

    testWidgets('three buttons: Yes, New date and No', (tester) async {
      await start(tester, seed: seedPassed);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('New date'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      await closeDown(tester);
    });

    testWidgets('New date asks for a day and a time, stores it, card goes', (
      tester,
    ) async {
      await start(tester, seed: seedPassed);
      await tapText(tester, 'New date');
      await pickDay(tester, '20');
      // The time is optional: closing the picker keeps the day alone.
      expect(find.text('Cancel'), findsOneWidget);
      await tapText(tester, 'Cancel');
      final i = (await all(tester)).single;
      expect(i.state, IntentionState.open);
      expect(i.date, DateTime(2026, 11, 20));
      expect(i.horizon, isNull);
      expect(await events(tester), isEmpty);
      expect(find.text('Did it happen?'), findsNothing);
      await closeDown(tester);
    });

    testWidgets('New date cancelled at the date changes nothing', (
      tester,
    ) async {
      await start(tester, seed: seedPassed);
      await tapText(tester, 'New date');
      await tapText(tester, 'Cancel');
      expect((await all(tester)).single.date, DateTime(2026, 11, 14));
      expect(find.text('Did it happen?'), findsOneWidget);
      await closeDown(tester);
    });

    testWidgets('No moves it back to the plans as Soon, nothing else', (
      tester,
    ) async {
      await start(tester, seed: seedPassed);
      await tapText(tester, 'No');
      expect(find.text('Did it happen?'), findsNothing);
      final i = (await all(tester)).single;
      expect(i.state, IntentionState.open);
      expect(whenFields(i), (null, Horizon.soon, null));
      expect(i.note, 'Bouldering');
      expect(await events(tester), isEmpty);
      // It shows under "No date yet", not on the timeline.
      await goToUpcoming(tester);
      expect(find.text('NO DATE YET'), findsOneWidget);
      expect(find.text('Bouldering'), findsOneWidget);
      await closeDown(tester);
    });

    testWidgets('several: oldest first, two at most, the next after an '
        'answer', (tester) async {
      await start(
        tester,
        seed: (add) async {
          await add('Third', when: When.date(DateTime(2026, 11, 13)));
          await add('First', when: When.date(DateTime(2026, 11, 3)));
          await add('Second', when: When.date(DateTime(2026, 11, 8)));
        },
      );
      expect(find.text('Did it happen?'), findsNWidgets(2));
      expect(find.textContaining('Tom · First'), findsOneWidget);
      expect(find.textContaining('Tom · Second'), findsOneWidget);
      expect(find.textContaining('Tom · Third'), findsNothing);
      final ys = [
        tester.getTopLeft(find.textContaining('Tom · First')).dy,
        tester.getTopLeft(find.textContaining('Tom · Second')).dy,
      ];
      expect(ys[0], lessThan(ys[1]));
      await tester.tap(find.text('No').first);
      await tester.pumpAndSettle();
      expect(find.textContaining('Tom · Third'), findsOneWidget);
      expect(find.text('Did it happen?'), findsNWidgets(2));
      await closeDown(tester);
    });

    testWidgets('a timed thought is asked three hours after', (tester) async {
      await start(
        tester,
        seed: (add) =>
            add('Lunch', when: When.date(DateTime(2026, 11, 16, 10))),
      );
      expect(find.text('Did it happen?'), findsOneWidget);
      expect(
        find.textContaining('Tom · Lunch · Mon 16 Nov · 10:00'),
        findsOneWidget,
      );
      await closeDown(tester);
    });
  });

  group('plans as picks', () {
    testWidgets('a due plan asks to set a date; Set a date stores it', (
      tester,
    ) async {
      await start(
        tester,
        mode: OpenItemsMode.one,
        seed: (add) => add(
          'Ramen night',
          when: const When.horizon(Horizon.soon),
          created: DateTime(2026, 11, 1, 12),
        ),
      );
      expect(find.text('Want to set a date with Tom?'), findsOneWidget);
      expect(find.text('Ramen night'), findsWidgets);
      expect(find.text('Open WhatsApp'), findsOneWidget);
      await tapText(tester, 'Set a date');
      await pickDay(tester, '25');
      expect(find.text('Want to set a date with Tom?'), findsNothing);
      expect(whenFields((await all(tester)).single), (
        DateTime(2026, 11, 25),
        null,
        null,
      ));
      await closeDown(tester);
    });

    testWidgets('a plan that is not due yet is no pick', (tester) async {
      await start(
        tester,
        mode: OpenItemsMode.one,
        seed: (add) => add(
          'Ramen night',
          when: const When.horizon(Horizon.soon),
          created: DateTime(2026, 11, 10, 12),
        ),
      );
      expect(find.text('Want to set a date with Tom?'), findsNothing);
      expect(find.text("Tonight's pick"), findsNothing);
      await closeDown(tester);
    });

    testWidgets('in the list of three it has a calendar button', (
      tester,
    ) async {
      await start(
        tester,
        seed: (add) => add(
          'Ramen night',
          when: const When.horizon(Horizon.soon),
          created: DateTime(2026, 11, 1, 12),
        ),
      );
      expect(find.text('Want to set a date with Tom?'), findsOneWidget);
      expect(find.byTooltip('Set a date'), findsOneWidget);
      await closeDown(tester);
    });
  });
}

/// The three fields of the "when", for short expectations.
(DateTime?, Horizon?, String?) whenFields(Intention i) =>
    (i.date, i.horizon, i.condition);

class _NoShortcuts implements AppShortcuts {
  @override
  Future<void> setUp({
    required String captureTitle,
    required VoidCallback onCapture,
  }) async {}
}
