import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/app.dart';
import 'package:kept/app/providers.dart';
import 'package:kept/app/services.dart';
import 'package:kept/domain/chat_link.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/ui/material.dart';
import 'package:kept/ui/people/person_screen.dart';

import 'fake_notifications.dart';
import 'support/fakes.dart';

void main() {
  late AppServices services;

  final opener = FakeChatOpener();

  setUp(() {
    opener
      ..opened.clear()
      ..result = true;
    services = AppServices(
      db: AppDatabase(NativeDatabase.memory()),
      openDemo: () => AppDatabase(NativeDatabase.memory()),
    );
  });

  Future<void> openPeopleTab(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          servicesProvider.overrideWithValue(services),
          firstStartEnabledProvider.overrideWithValue(false),
          notificationsProvider.overrideWithValue(FakeNotifications()),
          chatOpenerProvider.overrideWithValue(opener),
        ],
        child: const KeptApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('People'));
    await tester.pumpAndSettle();
  }

  /// Drift closes its streams with a timer; closing the database needs real
  /// async (see test/widget_test.dart).
  Future<void> closeDown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(services.close);
  }

  testWidgets('groups people by class and opens a person', (tester) async {
    // Tall, so the reconnect card at the top does not push anyone off.
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      final people = services.peopleFor(demo: false);
      await people.add(
        name: 'Tom Berger',
        closeness: Closeness.close,
        chatApp: ChatApp.whatsapp,
        phone: '+491701234567',
        birthdayMonth: 3,
        birthdayDay: 3,
        reconnecting: true,
        notes: 'Training for a half marathon.',
      );
      await people.add(name: 'Anna Roth', closeness: Closeness.close);
      await people.add(name: 'Grandpa', closeness: Closeness.family);
      await people.add(name: 'Nora Lind', closeness: Closeness.fewTimesAYear);
    });
    await openPeopleTab(tester);
    // Tom is also on the reconnect card at the top; the group comes last.
    double top(String text) => tester.getTopLeft(find.text(text).last).dy;

    expect(find.text('Your people'), findsOneWidget);
    // Nobody is "now and then", so that group is left out.
    expect(find.text('NOW AND THEN'), findsNothing);
    final close = top('CLOSE FRIENDS');
    final few = top('A FEW TIMES A YEAR');
    final family = top('FAMILY');
    expect(close < few && few < family, isTrue);
    // Each person sits under their own group, by first name.
    for (final name in ['Tom', 'Anna']) {
      expect(top(name) > close && top(name) < few, isTrue, reason: name);
    }
    expect(top('Nora') > few && top('Nora') < family, isTrue);
    expect(top('Grandpa') > family, isTrue);

    await tester.tap(find.text('Tom').last);
    await tester.pumpAndSettle();
    expect(find.byType(PersonScreen), findsOneWidget);
    for (final text in [
      'Tom Berger',
      'Close friend',
      'Getting back in touch',
      'WhatsApp',
      '3 March',
      'Open WhatsApp',
      'NOTES',
      'Training for a half marathon.',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }

    await tester.tap(find.text('Open WhatsApp'));
    await tester.pump();
    expect(opener.opened, [
      const ChatLink(
        package: 'com.whatsapp',
        uri: 'https://wa.me/491701234567',
      ),
    ]);
    expect(find.text('WhatsApp could not be opened.'), findsNothing);

    opener.result = false;
    await tester.tap(find.text('Open WhatsApp'));
    await tester.pump();
    expect(find.text('WhatsApp could not be opened.'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(PersonScreen), findsNothing);

    // Someone without messenger, birthday or notes shows the class only.
    await tester.tap(find.text('Grandpa'));
    await tester.pumpAndSettle();
    expect(find.text('Family'), findsOneWidget);
    expect(find.textContaining('Open'), findsNothing);
    expect(find.text('NOTES'), findsNothing);

    await closeDown(tester);
  });

  testWidgets('shows a hint when there is nobody', (tester) async {
    await openPeopleTab(tester);
    expect(find.text('Your people will show up here.'), findsOneWidget);
    await closeDown(tester);
  });
}
