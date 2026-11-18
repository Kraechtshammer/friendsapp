import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/app.dart';
import 'package:kept/app/providers.dart';
import 'package:kept/app/services.dart';
import 'package:drift/drift.dart' show Value;
import 'package:kept/domain/chat_link.dart';
import 'package:kept/domain/contact_route.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/platform/installed_apps.dart';
import 'package:kept/ui/material.dart';
import 'package:kept/ui/people/person_screen.dart';

import 'fake_notifications.dart';
import 'support/fakes.dart';

void main() {
  late AppServices services;

  final opener = FakeChatOpener();
  final contact = FakeContactEntries();
  final installed = FakeInstalledApps();

  setUp(() {
    opener
      ..opened.clear()
      ..result = true;
    installed.apps = InstalledChatApps.all;
    contact
      ..entries.clear()
      ..asked.clear()
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
          contactEntriesProvider.overrideWithValue(contact),
          installedAppsProvider.overrideWithValue(installed),
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

  testWidgets('Open chat tries the target, the contact, then the number', (
    tester,
  ) async {
    const signalEntry = ContactEntry(
      id: '41',
      mimeType:
          'vnd.android.cursor.item/vnd.org.thoughtcrime.securesms.contact',
      label: 'Message +49 170 1234567',
    );
    contact.entries['c1'] = [
      const ContactEntry(
        id: '40',
        mimeType: ContactEntry.websiteMimeType,
        value: 'example.org',
      ),
      signalEntry,
    ];
    late Person eva;
    await tester.runAsync(() async {
      eva = await services
          .peopleFor(demo: false)
          .add(
            name: 'Eva Lund',
            closeness: Closeness.close,
            contactId: 'c1',
            chatApp: ChatApp.signal,
            phone: '+491701234567',
          );
    });
    await openPeopleTab(tester);
    await tester.tap(find.text('Eva').last);
    await tester.pumpAndSettle();

    // No target: the contact's Signal entry opens the chat.
    await tester.tap(find.text('Open Signal'));
    await tester.pump();
    expect(contact.asked, ['c1']);
    expect(contact.opened.map((e) => e.id), ['41']);
    expect(opener.opened, isEmpty);

    // The entry does not open: the link from the number.
    contact.result = false;
    await tester.tap(find.text('Open Signal'));
    await tester.pump();
    expect(opener.opened, [
      const ChatLink(
        package: 'org.thoughtcrime.securesms',
        uri: 'https://signal.me/#p/+491701234567',
      ),
    ]);

    // A chat target wins; the contact is not even read.
    await tester.runAsync(
      () => services
          .peopleFor(demo: false)
          .update(
            eva.copyWith(chatTarget: const Value('https://signal.me/#eu/x')),
          ),
    );
    await tester.pumpAndSettle();
    contact.asked.clear();
    opener.opened.clear();
    await tester.tap(find.text('Open Signal'));
    await tester.pump();
    expect(contact.asked, isEmpty);
    expect(opener.opened.single.uri, 'https://signal.me/#eu/x');

    await closeDown(tester);
  });

  testWidgets('a messenger that is not installed says so', (tester) async {
    installed.apps = const InstalledChatApps({'com.whatsapp.w4b'}, sms: true);
    await tester.runAsync(() async {
      final people = services.peopleFor(demo: false);
      await people.add(
        name: 'Eva Lund',
        closeness: Closeness.close,
        chatApp: ChatApp.signal,
      );
      await people.add(
        name: 'Tom Berger',
        closeness: Closeness.close,
        chatApp: ChatApp.whatsapp,
        phone: '+491701234567',
      );
    });
    await openPeopleTab(tester);
    await tester.tap(find.text('Eva').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Signal'));
    await tester.pump();
    expect(find.text('Signal is not installed on this phone.'), findsOneWidget);
    expect(opener.opened, isEmpty);

    // Only WhatsApp Business is there: it opens with that package.
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tom').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open WhatsApp'));
    await tester.pump();
    expect(opener.opened, [
      const ChatLink(
        package: 'com.whatsapp.w4b',
        uri: 'https://wa.me/491701234567',
      ),
    ]);
    await closeDown(tester);
  });

  testWidgets('shows a hint when there is nobody', (tester) async {
    await openPeopleTab(tester);
    expect(find.text('Your people will show up here.'), findsOneWidget);
    await closeDown(tester);
  });
}
