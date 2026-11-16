import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:kept/app/providers.dart';
import 'package:kept/app/services.dart';
import 'package:kept/data/app_settings.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/platform/share_receiver.dart';
import 'package:kept/ui/material.dart';

import 'fake_photo_store.dart';
import 'fake_share_receiver.dart';
import 'support/pump_app.dart';

/// Sharing one picture into the app: the choice, "whose picture", the crop
/// and the confirmation.
void main() {
  late AppServices services;
  late FakeShareReceiver shares;
  late FakePhotoStore store;
  late Directory tmp;
  late File shared;
  late Person tom;
  late Person anna;
  late Person zoe;

  setUp(() async {
    services = AppServices(
      db: AppDatabase(NativeDatabase.memory()),
      openDemo: () => AppDatabase(NativeDatabase.memory()),
    );
    tmp = Directory.systemTemp.createTempSync('kept_sharepic_');
    shares = FakeShareReceiver(directory: tmp);
    store = FakePhotoStore();
    final png = img.fill(
      img.Image(width: 80, height: 60),
      color: img.ColorRgb8(200, 90, 90),
    );
    shared = File('${tmp.path}/shared.png')
      ..writeAsBytesSync(Uint8List.fromList(img.encodePng(png)));
  });
  tearDown(() {
    if (tmp.existsSync()) tmp.deleteSync(recursive: true);
  });

  Future<void> start(WidgetTester tester) async {
    await tester.runAsync(() async {
      final people = services.peopleFor(demo: false);
      Future<Person> add(String name) => people.add(
        name: name,
        closeness: Closeness.close,
        mainMessenger: Messenger.whatsapp,
        phone: '+4900000000101',
      );
      tom = await add('Tom Berger');
      anna = await add('Anna Weiss');
      zoe = await add('Zoe Klein');
      store.files['old.jpg'] = Uint8List.fromList([1]);
      await people.setPhoto(anna.id, 'old.jpg');
    });
    await pumpKeptApp(
      tester,
      services: services,
      clock: () => DateTime(2026, 11, 16, 10),
      viewSize: const Size(800, 1600),
      overrides: [
        shareReceiverProvider.overrideWithValue(shares),
        photoStoreProvider.overrideWithValue(store),
      ],
    );
    await tester.pumpAndSettle();
  }

  Future<void> closeDown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(services.close);
  }

  Future<void> share(WidgetTester tester) async {
    shares.send(SharedImage(shared.path));
    await tester.pump();
    await tester.pumpAndSettle();
  }

  /// Waits for the crop screen to be there and to finish decoding the photo
  /// (file reading and decoding are real work, outside the fake clock).
  Future<void> waitDecoded(WidgetTester tester) async {
    for (var i = 0; i < 100; i++) {
      if (find.text('Use picture').evaluate().isNotEmpty &&
          find.byType(CircularProgressIndicator).evaluate().isEmpty) {
        return;
      }
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
  }

  /// Lets the real work (database, files) finish, then the animations.
  Future<void> settle(WidgetTester tester, {String? until}) async {
    for (var i = 0; i < 100; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
      if (until == null || find.text(until).evaluate().isNotEmpty) break;
    }
    await tester.pumpAndSettle();
  }

  Future<Person> stored(WidgetTester tester, String id) => tester
      .runAsync(() => services.peopleFor(demo: false).watchAll().first)
      .then((all) => all!.firstWhere((p) => p.id == id));

  testWidgets('a picture for a person: choose, crop, saved, Done', (
    tester,
  ) async {
    await start(tester);
    await share(tester);
    expect(find.text("What's this picture for?"), findsOneWidget);
    await tester.tap(find.text("Use as someone's picture"));
    await tester.pumpAndSettle();
    expect(find.text('Whose picture is this?'), findsOneWidget);

    // Those without a picture come first, the one with a picture last.
    double top(String name) => tester.getTopLeft(find.text(name)).dy;
    expect(top('Tom'), lessThan(top('Anna')));
    expect(top('Zoe'), lessThan(top('Anna')));
    expect(find.text('NO PICTURE YET · 2'), findsOneWidget);

    await tester.tap(find.text('Anna'));
    await tester.pumpAndSettle();
    await waitDecoded(tester);
    expect(find.text('Use picture'), findsOneWidget);
    await tester.tap(find.text('Use picture'));
    await settle(tester, until: 'Looks good!');

    expect(find.text('Looks good!'), findsOneWidget);
    expect(find.text('Anna has a new picture.'), findsOneWidget);
    expect(find.text('2 friends still have no picture'), findsOneWidget);
    final anna2 = await stored(tester, anna.id);
    expect(anna2.photo, 'fake-0.jpg');
    // The old picture and the copied shared file are gone.
    expect(store.files.keys, ['fake-0.jpg']);
    expect(shared.existsSync(), isFalse);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(shares.finished, 1);
    expect(find.text('Looks good!'), findsNothing);
    await closeDown(tester);
  });

  testWidgets('a person without a picture: the line counts the others', (
    tester,
  ) async {
    await start(tester);
    await share(tester);
    await tester.tap(find.text("Use as someone's picture"));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tom'));
    await tester.pumpAndSettle();
    await waitDecoded(tester);
    await tester.tap(find.text('Use picture'));
    await settle(tester, until: 'Looks good!');
    expect(find.text('1 friend still has no picture'), findsOneWidget);
    expect((await stored(tester, tom.id)).photo, isNotNull);
    expect((await stored(tester, zoe.id)).photo, isNull);
    // The other person's picture stays.
    expect(store.files.containsKey('old.jpg'), isTrue);
    await closeDown(tester);
  });

  testWidgets('the search narrows the list', (tester) async {
    await start(tester);
    await share(tester);
    await tester.tap(find.text("Use as someone's picture"));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'zo');
    await tester.pumpAndSettle();
    expect(find.text('Zoe'), findsOneWidget);
    expect(find.text('Tom'), findsNothing);
    await tester.enterText(find.byType(TextField), 'nobody');
    await tester.pumpAndSettle();
    expect(find.text('Nobody found.'), findsOneWidget);
    await closeDown(tester);
  });

  testWidgets('cancelling the crop keeps everything as it was', (tester) async {
    await start(tester);
    await share(tester);
    await tester.tap(find.text("Use as someone's picture"));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zoe'));
    await tester.pumpAndSettle();
    await waitDecoded(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Whose picture is this?'), findsOneWidget);
    expect((await stored(tester, zoe.id)).photo, isNull);
    expect(shared.existsSync(), isTrue);
    await closeDown(tester);
  });

  testWidgets('the last choice is remembered and comes first', (tester) async {
    await start(tester);
    await share(tester);
    double top(String t) => tester.getTopLeft(find.text(t)).dy;
    // Start value: the picture first, with the "Last time" tag.
    expect(top("Use as someone's picture"), lessThan(top('Keep as an idea')));
    expect(find.text('Last time'), findsOneWidget);

    await tester.tap(find.text('Keep as an idea'));
    await settle(tester);
    // The keep sheet follows, the picture file stays for the idea.
    expect(find.text('Keep this for…'), findsOneWidget);
    expect(shared.existsSync(), isTrue);
    final s = await tester.runAsync(services.settings.load);
    expect(s!.shareImageChoice, ShareImageChoice.idea);
    await tester.tap(find.text('Cancel'));
    await settle(tester);

    await share(tester);
    expect(top('Keep as an idea'), lessThan(top("Use as someone's picture")));
    await closeDown(tester);
  });

  testWidgets('cancelling the choice deletes the copied picture', (
    tester,
  ) async {
    await start(tester);
    await share(tester);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(find.text("What's this picture for?"), findsNothing);
    expect(shared.existsSync(), isFalse);
    await closeDown(tester);
  });
}
