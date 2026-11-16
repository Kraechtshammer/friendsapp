import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/app.dart';
import 'package:kept/app/providers.dart';
import 'package:kept/app/services.dart';
import 'package:kept/data/app_settings.dart';
import 'package:kept/data/database.dart';
import 'package:kept/app/theme.dart';
import 'package:kept/ui/kept_icon.dart';
import 'package:kept/ui/material.dart';

import 'fake_notifications.dart';

void main() {
  testWidgets('shows the four tabs and opens settings from the gear', (
    tester,
  ) async {
    final services = AppServices(
      db: AppDatabase(NativeDatabase.memory()),
      openDemo: () => AppDatabase(NativeDatabase.memory()),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          servicesProvider.overrideWithValue(services),
          firstStartEnabledProvider.overrideWithValue(false),
          notificationsProvider.overrideWithValue(FakeNotifications()),
          clockProvider.overrideWithValue(() => DateTime(2026, 11, 16, 14)),
        ],
        child: const KeptApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hello'), findsOneWidget);
    for (final tab in ['Home', 'Upcoming', 'People', 'Progress']) {
      expect(find.text(tab), findsWidgets);
    }

    // The four tab icons and the gear are the app's own.
    expect(find.byType(KeptIcon), findsNWidgets(5));

    await tester.tap(find.text('People'));
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsNothing);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    await tester.tap(find.text('Look'));
    await tester.pumpAndSettle();

    // The theme choice switches the app to dark and back to light.
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    final context = tester.element(find.text('Look'));
    expect(Theme.of(context).extension<KeptColors>(), KeptColors.dark);
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Look'))).extension<KeptColors>(),
      KeptColors.light,
    );
    // The choice is stored in the database.
    expect((await services.settings.load()).themeMode, AppThemeMode.light);

    // The language choice switches the texts to German.
    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();
    expect(find.text('SPRACHE'), findsOneWidget);
    expect((await services.settings.load()).language, AppLanguage.de);

    // Drift closes its streams with a timer; let it run before the end.
    // Closing the database needs real async, not the test's fake clock.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(services.close);
  });
}
