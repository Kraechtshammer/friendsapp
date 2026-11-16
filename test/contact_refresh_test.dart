import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/app.dart';
import 'package:kept/app/providers.dart';
import 'package:kept/app/services.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/contact_refresh.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/platform/contacts.dart';
import 'package:kept/ui/material.dart';
import 'package:kept/ui/people/edit_person_screen.dart';
import 'package:kept/ui/people/refresh_contacts_screen.dart';

import 'fake_contacts.dart';
import 'fake_notifications.dart';

Person _person({
  String name = 'Anna Adler',
  String? phone = '+491701234567',
  int? month = 5,
  int? day = 17,
  int? year = 1990,
  String? contactId = 'c1',
}) => Person(
  id: 'p1',
  name: name,
  closeness: Closeness.close,
  contactId: contactId,
  phone: phone,
  birthdayMonth: month,
  birthdayDay: day,
  birthdayYear: year,
  avatarShape: AvatarShape.scallop,
  avatarColor: AvatarColor.coral,
  reconnecting: false,
  notes: '',
  createdAt: DateTime(2026),
  replyClearedAt: null,
  rhythmDays: null,
  mainMessenger: null,
  telegramUsername: null,
  signalLink: null,
  discordUserId: null,
);

void main() {
  group('compareWithContact', () {
    const same = PhoneContact(
      id: 'c1',
      name: 'Anna Adler',
      phones: ['0170 1234567'],
      birthdayMonth: 5,
      birthdayDay: 17,
      birthdayYear: 1990,
    );

    test('equal gives nothing to update', () {
      expect(compareWithContact(_person(), same).isEmpty, isTrue);
    });

    test('name, number and birthday differences are found', () {
      final diff = compareWithContact(
        _person(),
        const PhoneContact(
          id: 'c1',
          name: 'Anna Berger',
          phones: ['0171 9999999', '0170 1234568'],
          birthdayMonth: 6,
          birthdayDay: 1,
        ),
      );
      expect(diff.name, 'Anna Berger');
      expect(diff.phone, '+491719999999');
      expect((diff.birthday!.month, diff.birthday!.day), (6, 1));
      final updated = diff.apply();
      expect(updated.name, 'Anna Berger');
      expect(updated.phone, '+491719999999');
      expect(updated.birthdayMonth, 6);
      expect(updated.birthdayYear, isNull);
    });

    test('any of several numbers matching counts as equal', () {
      final diff = compareWithContact(
        _person(),
        const PhoneContact(
          id: 'c1',
          name: 'Anna Adler',
          phones: ['0171 9999999', '0170 1234567'],
        ),
      );
      expect(diff.isEmpty, isTrue);
    });

    test('empty fields in the contact never erase what the person has', () {
      final diff = compareWithContact(
        _person(),
        const PhoneContact(id: 'c1', name: 'Anna Adler'),
      );
      expect(diff.isEmpty, isTrue);
    });

    test('a contact birthday without a year keeps the known year', () {
      final diff = compareWithContact(
        _person(),
        const PhoneContact(
          id: 'c1',
          name: 'Anna Adler',
          birthdayMonth: 5,
          birthdayDay: 17,
        ),
      );
      expect(diff.isEmpty, isTrue);
    });

    test('compareAll skips unlinked people, gone contacts and equal ones', () {
      final list = compareAll(
        [_person(), _person(contactId: null), _person(contactId: 'zz')],
        {'c1': same},
      );
      expect(list, isEmpty);
      expect(
        compareAll(
          [_person()],
          {'c1': const PhoneContact(id: 'c1', name: 'Anna X')},
        ),
        hasLength(1),
      );
    });
  });

  group('screens', () {
    late AppServices services;
    late FakeContacts contacts;

    setUp(() {
      services = AppServices(
        db: AppDatabase(NativeDatabase.memory()),
        openDemo: () => AppDatabase(NativeDatabase.memory()),
      );
    });

    Future<void> start(WidgetTester tester, Widget Function() home) async {
      tester.view.physicalSize = const Size(400, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            servicesProvider.overrideWithValue(services),
            firstStartEnabledProvider.overrideWithValue(false),
            notificationsProvider.overrideWithValue(FakeNotifications()),
            contactsSourceProvider.overrideWithValue(contacts),
          ],
          child: KeptApp(home: home()),
        ),
      );
      await settle(tester);
    }

    Future<void> closeDown(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      await tester.runAsync(services.close);
    }

    Future<void> addLinked(WidgetTester tester) async {
      await tester.runAsync(() async {
        await services
            .peopleFor(demo: false)
            .add(
              name: 'Anna Adler',
              closeness: Closeness.close,
              contactId: 'c1',
              phone: '+491701234567',
            );
        await services
            .peopleFor(demo: false)
            .add(
              name: 'Ben Bauer',
              closeness: Closeness.close,
              contactId: 'c2',
            );
      });
    }

    Future<List<Person>> people(WidgetTester tester) async => (await tester
        .runAsync(() => services.peopleFor(demo: false).watchAll().first))!;

    testWidgets('all: lists differences, accepts one, skips another', (
      tester,
    ) async {
      contacts = FakeContacts(const [
        PhoneContact(id: 'c1', name: 'Anna Adler-Berger'),
        PhoneContact(id: 'c2', name: 'Benjamin Bauer'),
      ]);
      await addLinked(tester);
      await start(tester, () => const RefreshContactsScreen());
      expect(find.text('Anna Adler'), findsWidgets);
      expect(find.text('Anna Adler-Berger'), findsOneWidget);
      expect(find.text('Accept all'), findsOneWidget);
      // Nothing changed yet.
      expect((await people(tester)).map((p) => p.name), [
        'Anna Adler',
        'Ben Bauer',
      ]);
      await tester.tap(find.text('Update').first);
      await settle(tester);
      await tester.tap(find.text('Skip').first);
      await settle(tester);
      expect((await people(tester)).map((p) => p.name), [
        'Anna Adler-Berger',
        'Ben Bauer',
      ]);
      expect(find.text('All done.'), findsOneWidget);
      await closeDown(tester);
    });

    testWidgets('all: Accept all takes every difference', (tester) async {
      contacts = FakeContacts(const [
        PhoneContact(id: 'c1', name: 'Anna A.'),
        PhoneContact(id: 'c2', name: 'Benjamin Bauer'),
      ]);
      await addLinked(tester);
      await start(tester, () => const RefreshContactsScreen());
      await tester.tap(find.text('Accept all'));
      await settle(tester);
      expect((await people(tester)).map((p) => p.name), [
        'Anna A.',
        'Benjamin Bauer',
      ]);
      await closeDown(tester);
    });

    testWidgets('all: up to date and permission missing are calm', (
      tester,
    ) async {
      contacts = FakeContacts(const [
        PhoneContact(id: 'c1', name: 'Anna Adler'),
        PhoneContact(id: 'c2', name: 'Ben Bauer'),
      ]);
      await addLinked(tester);
      await start(tester, () => const RefreshContactsScreen());
      expect(find.text('Everyone is up to date.'), findsOneWidget);
      await closeDown(tester);
    });

    testWidgets('all: without permission', (tester) async {
      contacts = FakeContacts(const [], granted: false);
      await addLinked(tester);
      await start(tester, () => const RefreshContactsScreen());
      expect(
        find.textContaining('needs to read your contacts'),
        findsOneWidget,
      );
      await tester.tap(find.text('Open settings'));
      expect(contacts.settingsOpened, 1);
      await closeDown(tester);
    });

    testWidgets('one person: confirm changes name and the form follows', (
      tester,
    ) async {
      contacts = FakeContacts(const [
        PhoneContact(
          id: 'c1',
          name: 'Anna Berger',
          phones: ['0170 1234567'],
          birthdayMonth: 6,
          birthdayDay: 2,
        ),
      ]);
      await addLinked(tester);
      final anna = (await people(tester)).first;
      await start(tester, () => EditPersonScreen(id: anna.id));
      await tester.tap(find.text('Refresh from contact'));
      await settle(tester);
      expect(find.text('Anna Berger'), findsOneWidget);
      await tester.tap(find.text('Update'));
      await settle(tester);
      final now = (await people(tester)).first;
      expect(now.name, 'Anna Berger');
      expect(now.birthdayMonth, 6);
      expect(now.phone, '+491701234567');
      // The form shows the new name, so Save keeps it.
      expect(find.text('Anna Berger'), findsOneWidget);
      await closeDown(tester);
    });

    testWidgets('one person: nothing to update, and gone contact', (
      tester,
    ) async {
      contacts = FakeContacts(const [
        PhoneContact(id: 'c1', name: 'Anna Adler', phones: ['0170 1234567']),
      ]);
      await addLinked(tester);
      final all = await people(tester);
      await start(tester, () => EditPersonScreen(id: all[0].id));
      await tester.tap(find.text('Refresh from contact'));
      await settle(tester);
      expect(find.textContaining('Nothing to update'), findsOneWidget);
      await closeDown(tester);

      services = AppServices(
        db: AppDatabase(NativeDatabase.memory()),
        openDemo: () => AppDatabase(NativeDatabase.memory()),
      );
      contacts = FakeContacts(const []);
      await addLinked(tester);
      final again = await people(tester);
      await start(tester, () => EditPersonScreen(id: again[0].id));
      await tester.tap(find.text('Refresh from contact'));
      await settle(tester);
      expect(find.textContaining('not in your address book'), findsOneWidget);
      await closeDown(tester);
    });

    testWidgets('a person without a contact link has no refresh button', (
      tester,
    ) async {
      contacts = FakeContacts(const []);
      final p = await tester.runAsync(
        () => services
            .peopleFor(demo: false)
            .add(name: 'Cora', closeness: Closeness.close),
      );
      await start(tester, () => EditPersonScreen(id: p!.id));
      expect(find.text('Refresh from contact'), findsNothing);
      await closeDown(tester);
    });
  });
}

Future<void> settle(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}
