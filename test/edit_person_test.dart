import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/app.dart';
import 'package:kept/app/providers.dart';
import 'package:kept/app/services.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/ui/material.dart';
import 'package:kept/ui/people/edit_person_screen.dart';
import 'package:kept/ui/people/people_screen.dart';
import 'package:kept/ui/people/person_screen.dart';

import 'package:kept/domain/contact_route.dart';

import 'fake_notifications.dart';
import 'support/fakes.dart';

void main() {
  late AppServices services;
  late FakeContactEntries contact;

  setUp(() {
    contact = FakeContactEntries();
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
          contactEntriesProvider.overrideWithValue(contact),
          installedAppsProvider.overrideWithValue(FakeInstalledApps()),
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

  Future<void> openForm(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Add a person'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('By hand'));
    await tester.pumpAndSettle();
  }

  /// The form is a lazy list: scroll until the widget is built.
  Future<void> scrollTo(WidgetTester tester, Finder finder) =>
      tester.scrollUntilVisible(
        finder,
        200,
        scrollable: find.byType(Scrollable).first,
      );

  Future<void> type(WidgetTester tester, String key, String text) async {
    await scrollTo(tester, find.byKey(ValueKey(key)));
    await tester.enterText(find.byKey(ValueKey(key)), text);
    await tester.pump();
  }

  Future<void> tapScrolled(WidgetTester tester, Finder finder) async {
    await scrollTo(tester, finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  bool saveEnabled(WidgetTester tester) =>
      tester.widget<InkWell>(find.widgetWithText(InkWell, 'Save')).onTap !=
      null;

  testWidgets('adds a person into the right group', (tester) async {
    await openPeopleTab(tester);
    expect(find.text('Your people will show up here.'), findsOneWidget);
    await openForm(tester);
    expect(find.byType(EditPersonScreen), findsOneWidget);
    expect(find.text('Remove this person'), findsNothing);

    await type(tester, 'name', 'Lena Fox');
    await tapScrolled(tester, find.text('Close friends'));
    await tapScrolled(tester, find.text('WhatsApp'));
    await type(tester, 'phone', '+491234');
    await tapScrolled(tester, find.text('Save'));

    expect(find.byType(EditPersonScreen), findsNothing);
    expect(find.byType(PeopleScreen), findsOneWidget);
    expect(find.text('CLOSE FRIENDS'), findsOneWidget);
    expect(find.text('Lena'), findsOneWidget);
    final people = await tester.runAsync(
      () => services.peopleFor(demo: false).watchAll().first,
    );
    final lena = people!.single;
    expect(lena.closeness, Closeness.close);
    expect(lena.chatApp, ChatApp.whatsapp);
    expect(lena.phone, '+491234');
    expect(lena.chatTarget, isNull);
    expect(lena.birthdayDay, isNull);
    await closeDown(tester);
  });

  testWidgets('Save is off without a name', (tester) async {
    await openPeopleTab(tester);
    await openForm(tester);
    expect(saveEnabled(tester), isFalse);
    await type(tester, 'name', '   ');
    expect(saveEnabled(tester), isFalse);
    await type(tester, 'name', 'Ann');
    expect(saveEnabled(tester), isTrue);
    await closeDown(tester);
  });

  testWidgets('a half-filled birthday blocks Save', (tester) async {
    await openPeopleTab(tester);
    await openForm(tester);
    await type(tester, 'name', 'Ann');
    await type(tester, 'day', '12');
    expect(find.textContaining('Enter a real day'), findsOneWidget);
    expect(saveEnabled(tester), isFalse);
    await type(tester, 'month', '13');
    expect(saveEnabled(tester), isFalse);
    await type(tester, 'month', '2');
    expect(saveEnabled(tester), isTrue);
    await type(tester, 'day', '30');
    expect(saveEnabled(tester), isFalse);
    await type(tester, 'day', '29');
    expect(saveEnabled(tester), isTrue);
    // 29 February needs a leap year once the year is given.
    await type(tester, 'year', '2001');
    expect(saveEnabled(tester), isFalse);
    await type(tester, 'year', '2000');
    expect(saveEnabled(tester), isTrue);
    await closeDown(tester);
  });

  testWidgets('the messenger section: contact first, then what Open does', (
    tester,
  ) async {
    contact.entries['c1'] = [
      const ContactEntry(
        id: '9',
        mimeType:
            'vnd.android.cursor.item/vnd.org.thoughtcrime.securesms.contact',
      ),
    ];
    await tester.runAsync(
      () => services
          .peopleFor(demo: false)
          .add(
            name: 'Eva Lund',
            closeness: Closeness.close,
            contactId: 'c1',
            phone: '+491701234567',
          ),
    );
    await openPeopleTab(tester);
    await tester.tap(find.text('Eva'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();

    await scrollTo(tester, find.text('From the contact'));
    expect(find.text('Other apps on this phone'), findsOneWidget);
    // Signal and SMS (by the contact's number) come before the others.
    double top(String text) => tester.getTopLeft(find.text(text).first).dy;
    final others = top('Other apps on this phone');
    expect(top('Signal') < others && top('SMS') < others, isTrue);
    expect(top('Telegram') > others, isTrue);
    expect(find.byKey(const ValueKey('chatTarget')), findsNothing);
    await tapScrolled(tester, find.text('Signal').first);
    expect(
      find.text('Without one, Kept. opens the chat through the phone contact.'),
      findsOneWidget,
    );
    await type(tester, 'chatTarget', 'eva.42');
    expect(
      find.text('Signal needs a full chat link here, starting with https://.'),
      findsOneWidget,
    );
    await type(tester, 'chatTarget', 'https://signal.me/#eu/eva');
    expect(
      find.text('Open goes straight to this chat in Signal.'),
      findsOneWidget,
    );
    await tapScrolled(tester, find.text('Telegram'));
    await type(tester, 'chatTarget', '');
    expect(
      find.text('Without one, Kept. opens the chat by the phone number.'),
      findsOneWidget,
    );
    await tapScrolled(tester, find.text('Discord'));
    expect(
      find.text(
        'If you have a username or chat link for this person, enter it '
        'here. Otherwise Kept. just opens Discord.',
      ),
      findsOneWidget,
    );
    // The help page, with Discord first.
    await tapScrolled(tester, find.text('How do I get a chat link?'));
    expect(find.text('Chat links'), findsOneWidget);
    final discord = tester.getTopLeft(find.text('Discord')).dy;
    final telegram = tester.getTopLeft(find.text('Telegram')).dy;
    expect(discord < telegram, isTrue);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tapScrolled(tester, find.text('Save'));
    final eva = await tester.runAsync(
      () => services.peopleFor(demo: false).watchAll().first,
    );
    expect(eva!.single.chatApp, ChatApp.discord);
    expect(eva.single.chatTarget, isNull);
    await closeDown(tester);
  });

  testWidgets('edits a person and the page changes', (tester) async {
    await tester.runAsync(
      () => services
          .peopleFor(demo: false)
          .add(name: 'Tom Berger', closeness: Closeness.close),
    );
    await openPeopleTab(tester);
    await tester.tap(find.text('Tom'));
    await tester.pumpAndSettle();
    expect(find.text('Close friend'), findsOneWidget);
    expect(find.text('WhatsApp'), findsNothing);

    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit person'), findsOneWidget);
    expect(find.text('Tom Berger'), findsOneWidget);
    await type(tester, 'name', 'Tom Berger-Smith');
    await tapScrolled(tester, find.text('A few times a year'));
    await tapScrolled(tester, find.text('Telegram'));
    await tapScrolled(tester, find.text('Save'));

    expect(find.byType(PersonScreen), findsOneWidget);
    expect(find.text('Tom Berger-Smith'), findsOneWidget);
    expect(find.text('A few times a year'), findsOneWidget);
    expect(find.text('Open Telegram'), findsOneWidget);
    await closeDown(tester);
  });

  testWidgets('removing asks first and returns to the People tab', (
    tester,
  ) async {
    await tester.runAsync(
      () => services
          .peopleFor(demo: false)
          .add(name: 'Tom Berger', closeness: Closeness.close),
    );
    await openPeopleTab(tester);
    await tester.tap(find.text('Tom'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();

    await tapScrolled(tester, find.text('Remove this person'));
    expect(find.text('Remove Tom Berger?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(EditPersonScreen), findsOneWidget);

    await tapScrolled(tester, find.text('Remove this person'));
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(find.byType(EditPersonScreen), findsNothing);
    expect(find.byType(PersonScreen), findsNothing);
    expect(find.byType(PeopleScreen), findsOneWidget);
    expect(find.text('Tom'), findsNothing);
    expect(find.text('Your people will show up here.'), findsOneWidget);
    await closeDown(tester);
  });
}
