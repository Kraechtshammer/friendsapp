import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/incoming_sync.dart';
import 'package:kept/data/contact_events_repository.dart';
import 'package:kept/data/database.dart';
import 'package:kept/data/people_repository.dart';
import 'package:kept/domain/contact_event.dart';
import 'package:kept/domain/incoming_contact.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/platform/contacts.dart';

Person person(String id, String name, {String? contactId}) => Person(
  id: id,
  name: name,
  contactId: contactId,
  closeness: Closeness.close,
  avatarShape: AvatarShape.scallop,
  avatarColor: AvatarColor.mint,
  reconnecting: false,
  notes: '',
  createdAt: DateTime(2026),
);

class _Contacts implements ContactsSource {
  _Contacts(this.names);

  final Map<String, String> names;
  var asked = 0;

  @override
  Future<bool> hasAccess() async => true;

  @override
  Future<Map<String, String>> displayNames() async {
    asked++;
    return names;
  }

  @override
  Future<bool> requestAccess() => throw UnimplementedError();

  @override
  Future<List<PhoneContact>> load() => throw UnimplementedError();

  @override
  Future<void> openSettings() => throw UnimplementedError();
}

void main() {
  group('watch list', () {
    test('the name in the app, plus a different contact name', () {
      final list = buildWatchList(
        [
          person('j', ' Jonas ', contactId: 'c1'),
          person('a', 'Anna', contactId: 'c2'),
          person('t', 'Tom'),
          person('x', 'Ghost', contactId: 'gone'),
        ],
        {'c1': 'Jonas Wirth', 'c2': 'anna', 'c3': 'Tom Berger'},
      );
      expect(list, const [
        WatchEntry('j', ['Jonas', 'Jonas Wirth']),
        // Same name but for case: once.
        WatchEntry('a', ['Anna']),
        // Not linked: the contact named like him is not his.
        WatchEntry('t', ['Tom']),
        WatchEntry('x', ['Ghost']),
      ]);
      expect(list.first.toJson(), {
        'id': 'j',
        'names': ['Jonas', 'Jonas Wirth'],
      });
    });

    test('contacts are read only when someone is linked', () async {
      final contacts = _Contacts({'c1': 'Jonas Wirth'});
      final none = await watchListFor([person('t', 'Tom')], contacts);
      expect(contacts.asked, 0);
      expect(none, const [
        WatchEntry('t', ['Tom']),
      ]);
      final linked = await watchListFor([
        person('j', 'Jonas', contactId: 'c1'),
      ], contacts);
      expect(contacts.asked, 1);
      expect(linked.single.names, ['Jonas', 'Jonas Wirth']);
    });

    test('without contacts access only the app names', () async {
      final list = await watchListFor([
        person('j', 'Jonas', contactId: 'c1'),
      ], _Contacts(const {}));
      expect(list.single.names, ['Jonas']);
    });
  });

  test('the queue from the platform; broken entries are skipped', () {
    final time = DateTime(2026, 11, 16, 9, 30).millisecondsSinceEpoch;
    final entries = parseIncomingQueue([
      {'personId': 'j', 'kind': 'wrote', 'time': time},
      {'personId': 'a', 'kind': 'called', 'time': time},
      {'personId': 'a', 'kind': 'met', 'time': time},
      {'personId': '', 'kind': 'wrote', 'time': time},
      {'personId': 'j', 'kind': 'wrote'},
      'nonsense',
      null,
    ]);
    expect(entries.map((e) => (e.personId, e.kind, e.at)), [
      ('j', ContactKind.wrote, DateTime(2026, 11, 16, 9, 30)),
      ('a', ContactKind.called, DateTime(2026, 11, 16, 9, 30)),
    ]);
  });

  group('import', () {
    late AppDatabase db;
    late ContactEventsRepository events;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      events = ContactEventsRepository(db);
      final people = PeopleRepository(db);
      await people.replaceAll([person('j', 'Jonas'), person('a', 'Anna')]);
    });

    tearDown(() => db.close());

    test('once per person, kind and day; unknown people skipped', () async {
      final added = await importIncoming(
        [
          IncomingEntry('j', ContactKind.wrote, DateTime(2026, 11, 16, 9)),
          IncomingEntry('j', ContactKind.wrote, DateTime(2026, 11, 16, 21)),
          IncomingEntry('j', ContactKind.called, DateTime(2026, 11, 16, 10)),
          IncomingEntry('j', ContactKind.wrote, DateTime(2026, 11, 17, 8)),
          IncomingEntry('gone', ContactKind.wrote, DateTime(2026, 11, 16)),
        ],
        personIds: {'j', 'a'},
        events: events,
      );
      expect(added, 3);
      final stored = await events.watchForPerson('j').first;
      expect(stored.map((e) => (e.kind, e.at)), [
        (ContactKind.wrote, DateTime(2026, 11, 17, 8)),
        (ContactKind.called, DateTime(2026, 11, 16, 10)),
        (ContactKind.wrote, DateTime(2026, 11, 16, 9)),
      ]);
      for (final e in stored) {
        expect(e.direction, ContactDirection.byThem);
        expect(e.source, ContactSource.listener);
        expect(e.note, isNull);
      }
    });

    test('a "They wrote" entered by hand that day counts', () async {
      await events.addByThemOnce(
        personId: 'a',
        kind: ContactKind.wrote,
        at: DateTime(2026, 11, 16, 8),
      );
      final added = await importIncoming(
        [IncomingEntry('a', ContactKind.wrote, DateTime(2026, 11, 16, 12))],
        personIds: {'j', 'a'},
        events: events,
      );
      expect(added, 0);
      final stored = await events.watchForPerson('a').first;
      expect(stored.single.source, ContactSource.manual);
    });
  });
}
