import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/app.dart';
import 'package:kept/app/providers.dart';
import 'package:kept/app/services.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/ui/material.dart';
import 'package:kept/ui/people/person_screen.dart';

void main() {
  late AppServices services;

  setUp(() {
    services = AppServices(
      db: AppDatabase(NativeDatabase.memory()),
      openDemo: () => AppDatabase(NativeDatabase.memory()),
    );
  });

  Future<void> openPeopleTab(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [servicesProvider.overrideWithValue(services)],
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
    await tester.runAsync(() async {
      final people = services.peopleFor(demo: false);
      await people.add(
        name: 'Tom Berger',
        closeness: Closeness.close,
        mainMessenger: Messenger.whatsapp,
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
    double top(String text) => tester.getTopLeft(find.text(text)).dy;

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

    await tester.tap(find.text('Tom'));
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
    expect(find.text('Coming soon'), findsOneWidget);

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
