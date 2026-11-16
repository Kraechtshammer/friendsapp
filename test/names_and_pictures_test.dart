import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/providers.dart';
import 'package:kept/app/services.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/platform/contacts.dart';
import 'package:kept/ui/material.dart';
import 'package:kept/ui/people/class_chooser.dart';
import 'package:kept/ui/widgets/avatar.dart';

import 'fake_contacts.dart';
import 'fake_photo_store.dart';
import 'support/pump_app.dart';

/// A 1 x 1 PNG.
final _png = Uint8List.fromList(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA'
    '60e6kgAAAABJRU5ErkJggg==',
  ),
);

void main() {
  late AppServices services;
  late FakePhotoStore store;

  setUp(() {
    store = FakePhotoStore();
    services = AppServices(
      db: AppDatabase(NativeDatabase.memory()),
      openDemo: () => AppDatabase(NativeDatabase.memory()),
    );
  });

  Future<void> openPeopleTab(
    WidgetTester tester, {
    ContactsSource? contacts,
  }) async {
    await pumpKeptApp(
      tester,
      services: services,
      clock: () => DateTime(2026, 11, 16, 10),
      viewSize: const Size(800, 1600),
      overrides: [
        photoStoreProvider.overrideWithValue(store),
        if (contacts != null)
          contactsSourceProvider.overrideWithValue(contacts),
      ],
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

  Future<List<Person>> allPeople(WidgetTester tester) async => (await tester
      .runAsync(() => services.peopleFor(demo: false).watchAll().first))!;

  testWidgets('colliding first names show the last initial, a nickname wins', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final repo = services.peopleFor(demo: false);
      await repo.add(name: 'Max Müller', closeness: Closeness.close);
      await repo.add(name: 'Max Fischer', closeness: Closeness.close);
      await repo.add(name: 'Anna Adler', closeness: Closeness.close);
      await repo.add(
        name: 'Robert Roth',
        closeness: Closeness.close,
        nickname: 'Bob',
      );
    });
    await openPeopleTab(tester);
    expect(find.text('Max M'), findsOneWidget);
    expect(find.text('Max F'), findsOneWidget);
    expect(find.text('Anna'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Robert'), findsNothing);

    // The person page: short name large, full name small.
    await tester.tap(find.text('Max M'));
    await tester.pumpAndSettle();
    expect(find.text('Max M'), findsOneWidget);
    expect(find.text('Max Müller'), findsOneWidget);
    await closeDown(tester);
  });

  testWidgets('the nickname goes through the edit page and back', (
    tester,
  ) async {
    await tester.runAsync(
      () => services
          .peopleFor(demo: false)
          .add(name: 'Lena Fox', closeness: Closeness.close),
    );
    await openPeopleTab(tester);
    await tester.tap(find.text('Lena'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();
    final field = find.byKey(const ValueKey('nickname'));
    await tester.scrollUntilVisible(
      field,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(field, '  Lenny ');
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Save'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect((await allPeople(tester)).single.nickname, 'Lenny');
    expect(find.text('Lenny'), findsWidgets);
    expect(find.text('Lena Fox'), findsOneWidget);

    // Emptied: stored as null.
    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      field,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      tester
          .widget<TextField>(
            find.descendant(of: field, matching: find.byType(TextField)),
          )
          .controller!
          .text,
      'Lenny',
    );
    await tester.enterText(field, '   ');
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Save'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect((await allPeople(tester)).single.nickname, isNull);
    await closeDown(tester);
  });

  testWidgets(
    'an avatar with a picture shows it, one without shows the initial',
    (tester) async {
      store.files['p.jpg'] = _png;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [photoStoreProvider.overrideWithValue(store)],
          child: MaterialApp(
            home: Column(
              children: const [
                Avatar(
                  name: 'Anna',
                  shape: AvatarShape.scallop,
                  color: AvatarColor.mint,
                  photo: 'p.jpg',
                ),
                Avatar(
                  name: 'Ben',
                  shape: AvatarShape.arch,
                  color: AvatarColor.sky,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      // The initial stays under the picture while it is shown (and when the
      // file is missing the initial is all there is).
      expect(find.text('A'), findsOneWidget);
    },
  );

  test('import takes the picture of each imported contact only', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final services = AppServices(db: db, openDemo: () => db);
    final repo = services.peopleFor(demo: false);
    final contacts = FakeContacts([
      PhoneContact(id: 'c1', name: 'Anna Adler', photo: _png),
      const PhoneContact(id: 'c2', name: 'Ben Bauer'),
      PhoneContact(id: 'c3', name: 'Cora Carl', photo: _png),
    ]);
    await addContactsAsPeople(
      repo,
      contacts.contacts.take(2).toList(),
      {},
      null,
      source: contacts,
      photos: store,
    );
    final people = await repo.watchAll().first;
    expect(people.map((p) => p.photo != null), [true, false]);
    // Cora was not imported, so her picture was never stored.
    expect(store.files, hasLength(1));
  });

  testWidgets('removing a picture deletes the file', (tester) async {
    store.files['old.jpg'] = _png;
    await tester.runAsync(
      () => services
          .peopleFor(demo: false)
          .add(name: 'Lena Fox', closeness: Closeness.close, photo: 'old.jpg'),
    );
    await openPeopleTab(tester);
    await tester.tap(find.text('Lena'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove picture'));
    await tester.pumpAndSettle();
    expect(store.files, isEmpty);
    expect((await allPeople(tester)).single.photo, isNull);
    expect(find.text('Remove picture'), findsNothing);
    await closeDown(tester);
  });

  group('the one-time card on the People tab', () {
    Future<void> addLinked(WidgetTester tester) => tester.runAsync(
      () => services
          .peopleFor(demo: false)
          .add(name: 'Lena Fox', closeness: Closeness.close, contactId: 'c1'),
    );

    testWidgets('Add fills the pictures and the card does not come back', (
      tester,
    ) async {
      await addLinked(tester);
      final contacts = FakeContacts([
        PhoneContact(id: 'c1', name: 'Lena Fox', photo: _png),
      ]);
      await openPeopleTab(tester, contacts: contacts);
      expect(find.text('Add pictures from your contacts?'), findsOneWidget);
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect((await allPeople(tester)).single.photo, isNotNull);
      expect(find.text('Add pictures from your contacts?'), findsNothing);
      expect(find.text('Added 1 picture'), findsOneWidget);
      final settings = await tester.runAsync(
        () => services.settings.watch().first,
      );
      expect(settings!.picturesCatchUpAsked, isTrue);
      await closeDown(tester);
    });

    testWidgets('Not now hides it and changes no picture', (tester) async {
      await addLinked(tester);
      final contacts = FakeContacts([
        PhoneContact(id: 'c1', name: 'Lena Fox', photo: _png),
      ]);
      await openPeopleTab(tester, contacts: contacts);
      await tester.tap(find.text('Not now'));
      // The settings write is real async work.
      for (var i = 0; i < 5; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Add pictures from your contacts?'), findsNothing);
      expect((await allPeople(tester)).single.photo, isNull);
      expect(store.files, isEmpty);
      await closeDown(tester);
    });

    testWidgets('without contacts access it stays hidden', (tester) async {
      await addLinked(tester);
      final contacts = FakeContacts([
        PhoneContact(id: 'c1', name: 'Lena Fox', photo: _png),
      ], granted: false);
      await openPeopleTab(tester, contacts: contacts);
      expect(find.text('Add pictures from your contacts?'), findsNothing);
      await closeDown(tester);
    });

    testWidgets('nobody linked without a picture: no card', (tester) async {
      await tester.runAsync(
        () => services
            .peopleFor(demo: false)
            .add(name: 'Lena Fox', closeness: Closeness.close),
      );
      await openPeopleTab(tester, contacts: FakeContacts([]));
      expect(find.text('Add pictures from your contacts?'), findsNothing);
      await closeDown(tester);
    });
  });
}
