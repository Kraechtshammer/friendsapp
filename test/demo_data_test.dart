import 'package:flutter_test/flutter_test.dart';
import 'package:kept/domain/contact_event.dart';
import 'package:kept/domain/demo_data.dart';
import 'package:kept/domain/intention.dart';
import 'package:kept/domain/person.dart';

void main() {
  final today = DateTime(2026, 12, 30, 14, 5);
  final people = demoPeople(today);

  test('has about 16 people spread over the classes', () {
    int count(Closeness c) => people.where((p) => p.closeness == c).length;
    expect(people, hasLength(16));
    expect(count(Closeness.close), 4);
    expect(count(Closeness.nowAndThen), 5);
    expect(count(Closeness.fewTimesAYear), 4);
    expect(count(Closeness.family), 3);
    final reconnecting = people.where((p) => p.reconnecting).toList();
    expect(reconnecting, hasLength(2));
    expect(
      reconnecting.map((p) => p.closeness),
      isNot(contains(Closeness.family)),
    );
    expect(people.where((p) => p.mainMessenger == null), hasLength(1));
    expect(people.where((p) => p.notes.isNotEmpty).length, greaterThan(1));
  });

  test('is the same for the same day', () {
    expect(demoPeople(DateTime(2026, 12, 30, 8)), people);
  });

  test('one birthday is today and one in three days', () {
    final lena = people.singleWhere((p) => p.name == 'Lena Hartwig');
    expect((lena.birthdayMonth, lena.birthdayDay), (12, 30));
    // Three days after 30 December is 2 January.
    final sofia = people.singleWhere((p) => p.name == 'Sofia Lindqvist');
    expect((sofia.birthdayMonth, sofia.birthdayDay), (1, 2));
    expect(sofia.birthdayYear, isNull);
  });

  test('has no duplicate ids or names', () {
    expect(people.map((p) => p.id).toSet(), hasLength(people.length));
    expect(people.map((p) => p.name).toSet(), hasLength(people.length));
  });

  test('uses only fake numbers and handles', () {
    for (final p in people) {
      if (p.phone != null) expect(p.phone, matches(r'^\+4900000001\d\d$'));
      if (p.telegramUsername != null) {
        expect(p.telegramUsername, startsWith('demo_'));
      }
      if (p.discordUserId != null) {
        expect(p.discordUserId, matches(r'^0000\d{14}$'));
      }
    }
  });

  test('about two thirds have a birthday, some without year', () {
    final withBirthday = people.where((p) => p.birthdayMonth != null);
    expect(withBirthday.length, inInclusiveRange(10, 12));
    expect(withBirthday.where((p) => p.birthdayYear == null), isNotEmpty);
  });

  group('intentions', () {
    final intentions = demoIntentions(today);

    test('ten thoughts and seven plans, mixed kinds', () {
      expect(intentions, hasLength(17));
      int count(IntentionState s) =>
          intentions.where((i) => i.state == s).length;
      expect(count(IntentionState.open), 14);
      expect(count(IntentionState.done), 3);
      // Four with a date, one of them passed; three with a horizon.
      expect(intentions.where((i) => i.date != null), hasLength(4));
      expect(
        intentions.where((i) => i.date != null && i.date!.isBefore(today)),
        hasLength(1),
      );
      expect(intentions.where((i) => i.horizon != null), hasLength(3));
      expect(
        intentions.map((i) => i.kind).toSet(),
        IntentionKind.values.toSet(),
      );
      expect(intentions.map((i) => i.id).toSet(), hasLength(17));
    });

    test('refer only to demo people', () {
      final ids = people.map((p) => p.id).toSet();
      for (final i in intentions) {
        expect(ids, contains(i.personId));
      }
    });

    test('lie a few days back; done ones closed after they were made', () {
      for (final i in intentions) {
        expect(i.createdAt.isBefore(today), isTrue);
        // The "soon" plan is 15 days old on purpose: it is due.
        expect(today.difference(i.createdAt).inDays, lessThan(16));
        if (i.state == IntentionState.done) {
          expect(i.closedAt!.isAfter(i.createdAt), isTrue);
          expect(i.closedAt!.isBefore(today), isTrue);
        } else {
          expect(i.closedAt, isNull);
        }
      }
    });

    test('is the same for the same day', () {
      expect(demoIntentions(DateTime(2026, 12, 30, 8)), intentions);
    });
  });

  group('contact events', () {
    final events = demoContactEvents(today);

    test('both directions, several kinds, for a few people', () {
      expect(events, hasLength(greaterThan(15)));
      expect(events.map((e) => e.personId).toSet(), hasLength(5));
      expect(
        events.map((e) => e.direction).toSet(),
        ContactDirection.values.toSet(),
      );
      expect(events.map((e) => e.kind).toSet(), ContactKind.values.toSet());
      expect(events.map((e) => e.id).toSet(), hasLength(events.length));
    });

    test('refer to demo people and lie in the past', () {
      final ids = people.map((p) => p.id).toSet();
      for (final e in events) {
        expect(ids, contains(e.personId));
        expect(e.at.isBefore(today), isTrue);
      }
    });

    test('is the same for the same day', () {
      expect(demoContactEvents(DateTime(2026, 12, 30, 8)), events);
    });
  });
}
