import 'package:flutter_test/flutter_test.dart';
import 'package:kept/domain/demo_data.dart';
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
}
