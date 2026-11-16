import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/app.dart';
import 'package:kept/app/providers.dart';
import 'package:kept/app/services.dart';
import 'package:kept/data/app_settings.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/chat_link.dart';
import 'package:kept/domain/contact_event.dart';
import 'package:kept/domain/intention.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/domain/reconnect_week.dart';
import 'package:kept/l10n/app_localizations.dart';
import 'package:kept/l10n/app_localizations_de.dart';
import 'package:kept/l10n/app_localizations_en.dart';
import 'package:kept/l10n/labels.dart';
import 'package:kept/platform/app_shortcuts.dart';
import 'package:kept/platform/chat_opener.dart';
import 'package:kept/ui/material.dart';
import 'package:kept/ui/people/edit_person_screen.dart';

import 'fake_notifications.dart';

void main() {
  late AppServices services;
  late DateTime now;
  final opener = _FakeOpener();

  setUp(() {
    opener.opened.clear();
    // Wednesday 18 November 2026; its Monday is the 16th.
    now = DateTime(2026, 11, 18, 12);
    services = AppServices(
      db: AppDatabase(NativeDatabase.memory()),
      openDemo: () => AppDatabase(NativeDatabase.memory()),
    );
  });

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          servicesProvider.overrideWithValue(services),
          firstStartEnabledProvider.overrideWithValue(false),
          notificationsProvider.overrideWithValue(FakeNotifications()),
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

  /// Runs [body] with real async (the database is on a real isolate).
  Future<T> real<T>(WidgetTester tester, Future<T> Function() body) =>
      tester.runAsync(body).then((v) => v as T);

  Future<Person> add(
    WidgetTester tester,
    String name, {
    Closeness closeness = Closeness.nowAndThen,
    bool reconnecting = false,
    Messenger? messenger = Messenger.whatsapp,
    DateTime? added,
  }) => real(
    tester,
    () => services
        .peopleFor(demo: false)
        .add(
          name: name,
          closeness: closeness,
          reconnecting: reconnecting,
          mainMessenger: messenger,
          phone: '+4900000000101',
          now: added ?? DateTime(2026, 11, 10),
        ),
  );

  Future<void> contact(
    WidgetTester tester,
    Person p,
    DateTime at, {
    ContactDirection direction = ContactDirection.byUser,
    ContactKind kind = ContactKind.wrote,
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

  Future<AppSettings> settings(WidgetTester tester) =>
      real(tester, services.settings.load);

  Future<void> openPeople(WidgetTester tester) async {
    await tester.tap(find.text('People'));
    await tester.pumpAndSettle();
  }

  group('settings', () {
    testWidgets('the Rhythms section: start values, steppers, none', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('RHYTHMS'), 100);
      expect(find.text('RHYTHMS'), findsOneWidget);
      expect(find.text('2 weeks'), findsOneWidget);
      expect(find.text('6 weeks'), findsOneWidget);
      expect(find.text('3 months'), findsOneWidget);
      expect(find.text('None'), findsOneWidget);

      // Rows in the order of the classes; the steppers likewise.
      final longer = find.byTooltip('Longer');
      final shorter = find.byTooltip('Shorter');
      await tester.tap(longer.at(0));
      await tester.pumpAndSettle();
      expect(find.text('3 weeks'), findsOneWidget);
      await tester.tap(shorter.at(1));
      await tester.pumpAndSettle();
      expect(find.text('4 weeks'), findsOneWidget);
      // 3 months is followed by 4, 6 and 12 months, then none.
      for (var i = 0; i < 3; i++) {
        await tester.tap(longer.at(2));
        await tester.pumpAndSettle();
      }
      expect(find.text('12 months'), findsOneWidget);
      await tester.tap(longer.at(2));
      await tester.pumpAndSettle();
      expect(find.text('None'), findsNWidgets(2));
      // Family gets one: one step shorter than none.
      await tester.tap(shorter.at(3));
      await tester.pumpAndSettle();
      expect(find.text('12 months'), findsOneWidget);

      final s = await settings(tester);
      expect(s.rhythmOf(Closeness.close), 21);
      expect(s.rhythmOf(Closeness.nowAndThen), 28);
      expect(s.rhythmOf(Closeness.fewTimesAYear), isNull);
      expect(s.rhythmOf(Closeness.family), 365);
      await closeDown(tester);
    });
  });

  group('reconnect span', () {
    test('the texts follow the span, in English and German', () {
      final en = AppLocalizationsEn(), de = AppLocalizationsDe();
      String t(ReconnectSpan s, AppLocalizations l) =>
          reconnectTitle(s, 'Kenji', l);
      expect(t(ReconnectSpan.week, en), 'This week: Kenji');
      expect(t(ReconnectSpan.twoWeeks, en), 'These two weeks: Kenji');
      expect(t(ReconnectSpan.month, en), 'This month: Kenji');
      expect(t(ReconnectSpan.twoMonths, en), 'These two months: Kenji');
      expect(t(ReconnectSpan.threeMonths, en), 'These three months: Kenji');
      expect(t(ReconnectSpan.week, de), 'Diese Woche: Kenji');
      expect(t(ReconnectSpan.twoWeeks, de), 'Diese zwei Wochen: Kenji');
      expect(t(ReconnectSpan.month, de), 'Diesen Monat: Kenji');
      expect(t(ReconnectSpan.twoMonths, de), 'Diese zwei Monate: Kenji');
      expect(t(ReconnectSpan.threeMonths, de), 'Diese drei Monate: Kenji');
    });

    testWidgets('the Rhythms section has a span row, a month at start', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Reconnect person for'), 100);
      expect(find.text('1 month'), findsOneWidget);
      // Class rhythms come first: the span stepper is the fifth.
      await tester.tap(find.byTooltip('Longer').at(4));
      await tester.pumpAndSettle();
      expect(find.text('2 months'), findsOneWidget);
      expect((await settings(tester)).reconnectSpan, ReconnectSpan.twoMonths);
      await tester.tap(find.byTooltip('Shorter').at(4));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Shorter').at(4));
      await tester.pumpAndSettle();
      expect(find.text('2 weeks'), findsWidgets);
      expect((await settings(tester)).reconnectSpan, ReconnectSpan.twoWeeks);
      await closeDown(tester);
    });
  });

  group('edit person', () {
    testWidgets('own rhythm: like the class, or a span; and the switch', (
      tester,
    ) async {
      final tom = await add(tester, 'Tom Berger', closeness: Closeness.close);
      await pumpApp(tester);
      await openPeople(tester);
      await tester.tap(find.text('Tom'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('RHYTHM'),
        100,
        scrollable: find
            .descendant(
              of: find.byType(EditPersonScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.text('Like the class · 2 weeks'), findsOneWidget);
      await tester.tap(find.byTooltip('Longer'));
      await tester.pumpAndSettle();
      expect(find.text('1 week'), findsOneWidget);
      await tester.tap(find.byTooltip('Longer'));
      await tester.pumpAndSettle();
      expect(find.text('2 weeks'), findsOneWidget);

      // The switch is its own card with a plain explanation.
      expect(find.text('Getting back in touch'), findsOneWidget);
      expect(find.textContaining('pick one for a while'), findsOneWidget);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final stored = await real(
        tester,
        () => services.peopleFor(demo: false).watch(tom.id).first,
      );
      expect(stored!.rhythmDays, 14);
      expect(stored.reconnecting, isTrue);
      await closeDown(tester);
    });

    testWidgets('going back to "like the class" clears the own rhythm', (
      tester,
    ) async {
      final tom = await add(tester, 'Tom Berger', closeness: Closeness.close);
      await real(
        tester,
        () => services
            .peopleFor(demo: false)
            .update(tom.copyWith(rhythmDays: const Value(7))),
      );
      await pumpApp(tester);
      await openPeople(tester);
      await tester.tap(find.text('Tom'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('RHYTHM'),
        100,
        scrollable: find
            .descendant(
              of: find.byType(EditPersonScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.text('1 week'), findsOneWidget);
      await tester.tap(find.byTooltip('Shorter'));
      await tester.pumpAndSettle();
      expect(find.text('Like the class · 2 weeks'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final stored = await real(
        tester,
        () => services.peopleFor(demo: false).watch(tom.id).first,
      );
      expect(stored!.rhythmDays, isNull);
      await closeDown(tester);
    });

    testWidgets('switching it on again lets the back in touch card ask again', (
      tester,
    ) async {
      final kenji = await add(tester, 'Kenji Moreau');
      await real(
        tester,
        () => services.settings.update(
          (s) => s.copyWith(backInTouchAnswered: {kenji.id, 'other'}),
        ),
      );
      await pumpApp(tester);
      await openPeople(tester);
      await tester.tap(find.text('Kenji').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('RHYTHM'),
        100,
        scrollable: find
            .descendant(
              of: find.byType(EditPersonScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect((await settings(tester)).backInTouchAnswered, {'other'});
      await closeDown(tester);
    });
  });

  group('People tab card', () {
    testWidgets('nobody in the state: no card', (tester) async {
      await add(tester, 'Tom Berger');
      await pumpApp(tester);
      await openPeople(tester);
      expect(find.text('Getting back in touch'), findsNothing);
      expect(find.textContaining('this week'), findsNothing);
      await closeDown(tester);
    });

    testWidgets('choose, open, change, and the calm done state', (
      tester,
    ) async {
      await add(tester, 'Tom Berger');
      final kenji = await add(tester, 'Kenji Moreau', reconnecting: true);
      final ingrid = await add(
        tester,
        'Ingrid Solberg',
        reconnecting: true,
        messenger: null,
      );
      await pumpApp(tester);
      await openPeople(tester);

      // Nobody chosen: the question, with the two as avatars.
      expect(
        find.text('Who do you want to get back in touch with now?'),
        findsOneWidget,
      );
      expect(find.text('Getting back in touch'), findsOneWidget);
      expect(find.text('Kenji'), findsNWidgets(2));
      expect(find.text('Ingrid'), findsNWidgets(2));
      // Tom is not in the state, so he is only in the groups.
      expect(find.text('Tom'), findsOneWidget);

      await tester.tap(find.text('Kenji').first);
      await tester.pumpAndSettle();
      var s = await settings(tester);
      expect(s.reconnectPersonId, kenji.id);
      expect(s.reconnectStart, DateTime(2026, 11, 18));
      expect(find.text('This month: Kenji'), findsOneWidget);
      expect(find.text('Open WhatsApp'), findsOneWidget);
      expect(find.text('Someone else'), findsOneWidget);
      expect(find.textContaining('Who do you want'), findsNothing);

      await tester.tap(find.text('Open WhatsApp'));
      await tester.pumpAndSettle();
      expect(opener.opened, hasLength(1));

      // A way to change the person.
      await tester.tap(find.text('Someone else'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Who do you want'), findsOneWidget);
      expect((await settings(tester)).reconnectPersonId, isNull);
      await tester.tap(find.text('Ingrid').first);
      await tester.pumpAndSettle();
      expect(find.text('This month: Ingrid'), findsOneWidget);
      // No messenger, no Open button.
      expect(find.textContaining('Open '), findsNothing);

      // The user gets in touch: a calm done state, no buttons.
      await contact(tester, ingrid, DateTime(2026, 11, 18, 9));
      await tester.pumpAndSettle();
      expect(find.text('You got in touch with Ingrid.'), findsOneWidget);
      expect(find.text('This month: Ingrid'), findsNothing);
      expect(find.text('Someone else'), findsNothing);
      await closeDown(tester);
    });

    testWidgets('something that only came in does not end the week', (
      tester,
    ) async {
      final kenji = await add(tester, 'Kenji Moreau', reconnecting: true);
      await real(
        tester,
        () => services.settings.update(
          (s) => s.withReconnect(kenji.id, DateTime(2026, 11, 16)),
        ),
      );
      await contact(
        tester,
        kenji,
        DateTime(2026, 11, 17, 9),
        direction: ContactDirection.byThem,
      );
      await pumpApp(tester);
      await openPeople(tester);
      expect(find.text('This month: Kenji'), findsOneWidget);
      await closeDown(tester);
    });

    testWidgets('a span that is over asks again, with nothing about the last', (
      tester,
    ) async {
      final kenji = await add(tester, 'Kenji Moreau', reconnecting: true);
      await add(tester, 'Ingrid Solberg', reconnecting: true);
      await real(
        tester,
        () => services.settings.update(
          (s) => s
              .withReconnect(kenji.id, DateTime(2026, 11, 16))
              .copyWith(reconnectSpan: ReconnectSpan.week),
        ),
      );
      await contact(tester, kenji, DateTime(2026, 11, 19, 9));
      // Sunday night: still done.
      now = DateTime(2026, 11, 22, 23, 59);
      await pumpApp(tester);
      await openPeople(tester);
      expect(
        find.textContaining('You got in touch with Kenji'),
        findsOneWidget,
      );
      await closeDown(tester);

      // Monday morning: the question again, no word on last week.
      services = AppServices(
        db: AppDatabase(NativeDatabase.memory()),
        openDemo: () => AppDatabase(NativeDatabase.memory()),
      );
      final k2 = await add(tester, 'Kenji Moreau', reconnecting: true);
      await add(tester, 'Ingrid Solberg', reconnecting: true);
      await real(
        tester,
        () => services.settings.update(
          (s) => s
              .withReconnect(k2.id, DateTime(2026, 11, 16))
              .copyWith(reconnectSpan: ReconnectSpan.week),
        ),
      );
      await contact(tester, k2, DateTime(2026, 11, 19, 9));
      now = DateTime(2026, 11, 23, 0, 1);
      await pumpApp(tester);
      await openPeople(tester);
      expect(find.textContaining('Who do you want'), findsOneWidget);
      expect(find.textContaining('You got in touch'), findsNothing);
      expect(find.textContaining('This week: '), findsNothing);
      await closeDown(tester);
    });
  });

  group('Home', () {
    testWidgets('the hint: no number, Open, Another one, no Done', (
      tester,
    ) async {
      await add(
        tester,
        'Tom Berger',
        closeness: Closeness.close,
        added: DateTime(2026, 9, 1),
      );
      await pumpApp(tester);
      expect(find.text("Tonight's pick"), findsOneWidget);
      expect(find.text("It's been a while with Tom"), findsOneWidget);
      expect(find.textContaining('days'), findsNothing);
      expect(find.textContaining('weeks'), findsNothing);
      expect(find.text('Open WhatsApp'), findsOneWidget);
      // One pick only: no Another one, and nothing to tick off.
      expect(find.text('Another one'), findsNothing);
      expect(find.text('Done'), findsNothing);

      await tester.tap(find.text('Open WhatsApp'));
      await tester.pumpAndSettle();
      expect(opener.opened, hasLength(1));
      await closeDown(tester);
    });

    testWidgets('no hint when the last contact is within the rhythm, or for '
        'Family with no rhythm', (tester) async {
      final tom = await add(
        tester,
        'Tom Berger',
        closeness: Closeness.close,
        added: DateTime(2026, 9, 1),
      );
      await add(
        tester,
        'Mum',
        closeness: Closeness.family,
        added: DateTime(2026, 1, 1),
      );
      await contact(tester, tom, DateTime(2026, 11, 10));
      await pumpApp(tester);
      expect(find.text("Tonight's pick"), findsNothing);
      expect(find.textContaining("It's been a while"), findsNothing);
      await closeDown(tester);
    });

    testWidgets(
      'the hint with another pick: Another one, still no Done on it',
      (tester) async {
        final tom = await add(
          tester,
          'Tom Berger',
          closeness: Closeness.close,
          added: DateTime(2026, 9, 1),
        );
        final anna = await add(
          tester,
          'Anna Keller',
          closeness: Closeness.close,
          added: DateTime(2026, 9, 1),
        );
        await real(
          tester,
          () => services
              .intentionsFor(demo: false)
              .add(
                personId: anna.id,
                note: 'New flat',
                kind: IntentionKind.write,
                now: DateTime(2026, 11, 1),
              ),
        );
        await pumpApp(tester);
        // The thought first; Tom is the hint.
        expect(find.text('New flat'), findsWidgets);
        expect(find.text('Done'), findsWidgets);
        await tester.tap(find.text('Another one'));
        await tester.pumpAndSettle();
        expect(find.text("It's been a while with Tom"), findsOneWidget);
        expect(find.text('Another one'), findsOneWidget);
        expect(tom.id, isNotEmpty);
        // The only Done left is Anna's, in the list of thoughts below.
        expect(find.text('Done'), findsOneWidget);
        await closeDown(tester);
      },
    );

    testWidgets('the reconnect person of the week is a pick until contact', (
      tester,
    ) async {
      final kenji = await add(tester, 'Kenji Moreau', reconnecting: true);
      await real(
        tester,
        () => services.settings.update(
          (s) => s.withReconnect(kenji.id, DateTime(2026, 11, 16)),
        ),
      );
      await pumpApp(tester);
      expect(find.text('This month: Kenji'), findsOneWidget);
      expect(find.text('Open WhatsApp'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      await contact(tester, kenji, DateTime(2026, 11, 18, 9));
      await tester.pumpAndSettle();
      expect(find.text('This month: Kenji'), findsNothing);
      await closeDown(tester);
    });

    testWidgets('a reconnect person who was chosen last week is no pick', (
      tester,
    ) async {
      final kenji = await add(tester, 'Kenji Moreau', reconnecting: true);
      await real(
        tester,
        () => services.settings.update(
          (s) => s
              .withReconnect(kenji.id, DateTime(2026, 11, 9))
              .copyWith(reconnectSpan: ReconnectSpan.week),
        ),
      );
      await pumpApp(tester);
      expect(find.textContaining('This week'), findsNothing);
      await closeDown(tester);
    });

    testWidgets('Done on the reconnect pick stores a contact', (tester) async {
      final kenji = await add(tester, 'Kenji Moreau', reconnecting: true);
      await real(
        tester,
        () => services.settings.update(
          (s) => s.withReconnect(kenji.id, DateTime(2026, 11, 16)),
        ),
      );
      await pumpApp(tester);
      await tester.tap(find.text('Done').first);
      await tester.pumpAndSettle();
      final events = await real(
        tester,
        () => services
            .contactEventsFor(demo: false)
            .watchForPerson(kenji.id)
            .first,
      );
      expect(events.single.kind, ContactKind.wrote);
      expect(events.single.direction, ContactDirection.byUser);
      await closeDown(tester);
    });
  });

  group('back in touch', () {
    Future<Person> exchange(WidgetTester tester) async {
      final kenji = await add(tester, 'Kenji Moreau', reconnecting: true);
      await contact(tester, kenji, DateTime(2026, 11, 10, 20));
      await contact(
        tester,
        kenji,
        DateTime(2026, 11, 12, 9),
        direction: ContactDirection.byThem,
      );
      return kenji;
    }

    testWidgets('asks once; Keep leaves the state on and does not come back', (
      tester,
    ) async {
      final kenji = await exchange(tester);
      await pumpApp(tester);
      expect(find.text('You and Kenji are back in touch.'), findsOneWidget);
      expect(find.text('Keep as getting back in touch'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      await tester.tap(find.text('Keep as getting back in touch'));
      await tester.pumpAndSettle();
      expect(find.textContaining('back in touch.'), findsNothing);
      expect((await settings(tester)).backInTouchAnswered, {kenji.id});
      final stored = await real(
        tester,
        () => services.peopleFor(demo: false).watch(kenji.id).first,
      );
      expect(stored!.reconnecting, isTrue);
      await closeDown(tester);
    });

    testWidgets('Done switches the state off, the class stays', (tester) async {
      final kenji = await exchange(tester);
      await pumpApp(tester);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.textContaining('back in touch.'), findsNothing);
      expect((await settings(tester)).backInTouchAnswered, {kenji.id});
      final stored = await real(
        tester,
        () => services.peopleFor(demo: false).watch(kenji.id).first,
      );
      expect(stored!.reconnecting, isFalse);
      expect(stored.closeness, Closeness.nowAndThen);
      await closeDown(tester);
    });

    testWidgets('an answered person is not asked again', (tester) async {
      final kenji = await exchange(tester);
      await real(
        tester,
        () => services.settings.update(
          (s) => s.copyWith(backInTouchAnswered: {kenji.id}),
        ),
      );
      await pumpApp(tester);
      expect(find.textContaining('back in touch.'), findsNothing);
      await closeDown(tester);
    });

    testWidgets('no card without a first exchange', (tester) async {
      final kenji = await add(tester, 'Kenji Moreau', reconnecting: true);
      await contact(tester, kenji, DateTime(2026, 11, 10, 20));
      await pumpApp(tester);
      expect(find.textContaining('back in touch.'), findsNothing);
      await closeDown(tester);
    });
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
