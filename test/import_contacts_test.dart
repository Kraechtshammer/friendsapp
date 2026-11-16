import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/app.dart';
import 'package:kept/app/providers.dart';
import 'package:kept/app/services.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/platform/contacts.dart';
import 'package:kept/ui/material.dart';
import 'package:kept/ui/people/import_contacts_screen.dart';
import 'package:kept/ui/people/people_screen.dart';

import 'fake_notifications.dart';

class _FakeContacts implements ContactsSource {
  _FakeContacts({this.granted = true});

  final bool granted;
  var settingsOpened = false;

  @override
  Future<bool> requestAccess() async => granted;

  @override
  Future<List<PhoneContact>> load() async => const [
    PhoneContact(
      id: 'c1',
      name: 'Anna Adler',
      phones: ['0170 1234567'],
      birthdayMonth: 5,
      birthdayDay: 17,
      birthdayYear: 1990,
    ),
    PhoneContact(id: 'c2', name: 'Ben Bauer', phones: ['+43 660 1234567']),
    PhoneContact(id: 'c3', name: 'Cora Carl'),
  ];

  @override
  Future<void> openSettings() async => settingsOpened = true;

  @override
  Future<Map<String, String>> displayNames() async => const {};
}

void main() {
  late AppServices services;

  setUp(() {
    services = AppServices(
      db: AppDatabase(NativeDatabase.memory()),
      openDemo: () => AppDatabase(NativeDatabase.memory()),
    );
  });

  Future<void> openPeopleTab(WidgetTester tester, _FakeContacts fake) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          servicesProvider.overrideWithValue(services),
          notificationsProvider.overrideWithValue(FakeNotifications()),
          contactsSourceProvider.overrideWithValue(fake),
        ],
        child: const KeptApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('People'));
    await tester.pumpAndSettle();
  }

  Future<void> closeDown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(services.close);
  }

  testWidgets('denied shows the explanation and the settings button', (
    tester,
  ) async {
    final fake = _FakeContacts(granted: false);
    await openPeopleTab(tester, fake);
    await tester.tap(find.text('Add from contacts'));
    await tester.pumpAndSettle();
    expect(find.byType(ImportContactsScreen), findsOneWidget);
    expect(find.textContaining('needs to read your contacts'), findsOneWidget);
    expect(find.textContaining('Next'), findsNothing);
    await tester.tap(find.text('Open settings'));
    expect(fake.settingsOpened, isTrue);
    await closeDown(tester);
  });

  testWidgets('imports two of three contacts into their classes', (
    tester,
  ) async {
    await openPeopleTab(tester, _FakeContacts());
    await tester.tap(find.byTooltip('Add a person'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('From your contacts'));
    await tester.pumpAndSettle();
    expect(find.text('Anna Adler'), findsOneWidget);
    expect(find.text('0170 1234567'), findsOneWidget);
    await tester.tap(find.text('Anna Adler'));
    await tester.tap(find.text('Ben Bauer'));
    await tester.pump();
    await tester.tap(find.text('Next (2)'));
    await tester.pumpAndSettle();

    expect(find.text('Cora Carl'), findsNothing);
    await tester.tap(
      find.descendant(
        of: find
            .ancestor(of: find.text('Anna Adler'), matching: find.byType(Row))
            .first,
        matching: find.byTooltip('Close friend'),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Add 2 people'));
    await tester.pumpAndSettle();

    expect(find.byType(PeopleScreen), findsOneWidget);
    expect(find.text('CLOSE FRIENDS'), findsOneWidget);
    expect(find.text('NOW AND THEN'), findsOneWidget);
    final people = (await tester.runAsync(
      () => services.peopleFor(demo: false).watchAll().first,
    ))!;
    final anna = people.firstWhere((p) => p.name == 'Anna Adler');
    final ben = people.firstWhere((p) => p.name == 'Ben Bauer');
    expect(anna.closeness, Closeness.close);
    expect(anna.contactId, 'c1');
    expect(anna.phone, '+491701234567');
    expect(
      (anna.birthdayMonth, anna.birthdayDay, anna.birthdayYear),
      (5, 17, 1990),
    );
    expect(anna.mainMessenger, Messenger.whatsapp);
    expect(ben.closeness, Closeness.nowAndThen);
    expect(ben.phone, '+436601234567');
    expect(ben.birthdayDay, isNull);

    // Both are imported now, so only the third is offered.
    await tester.tap(find.byTooltip('Add a person'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('From your contacts'));
    await tester.pumpAndSettle();
    expect(find.text('Anna Adler'), findsNothing);
    expect(find.text('Ben Bauer'), findsNothing);
    expect(find.text('Cora Carl'), findsOneWidget);
    await closeDown(tester);
  });
}
