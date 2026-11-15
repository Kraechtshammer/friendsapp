import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/theme.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/ui/kept_icon.dart';
import 'package:kept/ui/material.dart';
import 'package:kept/ui/widgets/avatar.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    MaterialApp(
      theme: buildTheme(Brightness.dark),
      home: Scaffold(body: Center(child: child)),
    ),
  );

  test('the initial is the first letter, upper case', () {
    expect(Avatar.initial('tom Berger'), 'T');
    expect(Avatar.initial('  Émile'), 'É');
    expect(Avatar.initial(''), '');
  });

  testWidgets('shows the initial in every shape and colour', (tester) async {
    for (final shape in AvatarShape.values) {
      for (final color in AvatarColor.values) {
        await pump(
          tester,
          Avatar(name: 'anna', shape: shape, color: color, size: 54),
        );
        expect(find.text('A'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('the class badge builds for every class', (tester) async {
    for (final classBadge in [false, true]) {
      for (final closeness in Closeness.values) {
        for (final size in [44.0, 84.0]) {
          await pump(
            tester,
            Avatar(
              name: 'Tom',
              shape: AvatarShape.scallop,
              color: AvatarColor.mint,
              size: size,
              classBadge: classBadge,
              closeness: closeness,
            ),
          );
          expect(find.text('T'), findsOneWidget);
          expect(tester.takeException(), isNull);
          expect(find.byType(KeptIcon), findsNWidgets(classBadge ? 1 : 0));
        }
      }
    }
  });
}
