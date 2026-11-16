import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/providers.dart';
import 'package:kept/app/services.dart';
import 'package:kept/data/database.dart';

import 'support/pump_app.dart';

void main() {
  late AppServices services;

  setUp(() {
    services = AppServices(
      db: AppDatabase(NativeDatabase.memory()),
      openDemo: () => AppDatabase(NativeDatabase.memory()),
    );
  });

  Future<void> openSettings(WidgetTester tester, {bool builtIn = true}) async {
    await pumpKeptApp(
      tester,
      services: services,
      clock: () => DateTime(2026, 11, 16, 14),
      viewSize: const Size(412, 1400),
      overrides: [incomingBuiltInProvider.overrideWithValue(builtIn)],
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(services.close);
  }

  testWidgets('Settings lists the categories and opens one', (tester) async {
    await openSettings(tester);
    for (final title in [
      'Evening question',
      'Friends',
      'Birthdays',
      'Stamps and streak',
      'Look',
      'Permissions and privacy',
      'App update',
      'About and licences',
    ]) {
      expect(find.text(title), findsOneWidget, reason: title);
    }
    expect(find.text('Time'), findsNothing);
    await tester.tap(find.text('Evening question'));
    await tester.pumpAndSettle();
    expect(find.text('Time'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('without the listener the Friends line says owed replies', (
    tester,
  ) async {
    await openSettings(tester, builtIn: false);
    expect(find.text('Rhythms, reconnect, owed replies'), findsOneWidget);
    expect(find.textContaining('incoming messages'), findsNothing);
    await finish(tester);
  });
}
