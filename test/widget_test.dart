import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/app.dart';
import 'package:kept/app/theme.dart';
import 'package:kept/ui/material.dart';

void main() {
  testWidgets('shows the four tabs and opens settings from the gear', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: KeptApp()));
    await tester.pumpAndSettle();

    expect(find.text('Kept.'), findsOneWidget);
    for (final tab in ['Home', 'Upcoming', 'People', 'Progress']) {
      expect(find.text(tab), findsWidgets);
    }

    await tester.tap(find.text('People'));
    await tester.pumpAndSettle();
    expect(find.text('Kept.'), findsNothing);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);

    // The theme choice switches the app to dark and back to light.
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    final context = tester.element(find.text('Settings'));
    expect(Theme.of(context).extension<KeptColors>(), KeptColors.dark);
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Settings'))).extension<KeptColors>(),
      KeptColors.light,
    );
  });
}
