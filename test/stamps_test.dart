import 'package:flutter_test/flutter_test.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/contact_event.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/domain/progress.dart';
import 'package:kept/domain/stamps.dart';

ContactEvent event(
  String id,
  DateTime at, {
  String person = 'p',
  ContactKind kind = ContactKind.wrote,
  ContactDirection direction = ContactDirection.byUser,
}) => ContactEvent(
  id: id,
  personId: person,
  at: at,
  kind: kind,
  direction: direction,
  source: ContactSource.manual,
  createdAt: at,
);

void main() {
  // Monday 16 November 2026.
  final monday = DateTime(2026, 11, 16, 12);
  final recently = monday.subtract(const Duration(days: 3));

  int value(
    Closeness c, {
    bool reconnecting = false,
    ContactKind kind = ContactKind.wrote,
    DateTime? previous,
    int? rhythm = 14,
    StampWeights weights = const StampWeights(),
  }) => stampValue(
    closeness: c,
    reconnecting: reconnecting,
    kind: kind,
    at: monday,
    previous: previous ?? recently,
    rhythmDays: rhythm,
    weights: weights,
  );

  group('what earns a stamp', () {
    test('contact by the user or together earns, incoming does not', () {
      expect(earnsStamp(ContactKind.wrote, ContactDirection.byUser), isTrue);
      expect(earnsStamp(ContactKind.called, ContactDirection.byUser), isTrue);
      expect(earnsStamp(ContactKind.met, ContactDirection.together), isTrue);
      expect(earnsStamp(ContactKind.gamed, ContactDirection.together), isTrue);
      expect(
        earnsStamp(ContactKind.birthdayWish, ContactDirection.byUser),
        isTrue,
      );
      expect(earnsStamp(ContactKind.wrote, ContactDirection.byThem), isFalse);
      expect(earnsStamp(ContactKind.called, ContactDirection.byThem), isFalse);
      expect(
        earnsStamp(ContactKind.birthdayWish, ContactDirection.byThem),
        isFalse,
      );
    });
  });

  group('the value', () {
    test('each class has its own weight', () {
      expect(value(Closeness.close), 1);
      expect(value(Closeness.nowAndThen), 2);
      expect(value(Closeness.fewTimesAYear), 3);
      expect(value(Closeness.family), 2);
    });

    test('getting back in touch adds one', () {
      expect(value(Closeness.close, reconnecting: true), 2);
      expect(value(Closeness.fewTimesAYear, reconnecting: true), 4);
    });

    test('a gap longer than the rhythm adds one, a gap of exactly it not', () {
      final fifteen = monday.subtract(const Duration(days: 15));
      final fourteen = monday.subtract(const Duration(days: 14));
      expect(value(Closeness.close, previous: fifteen), 2);
      expect(value(Closeness.close, previous: fourteen), 1);
    });

    test('no rhythm means no gap bonus', () {
      final long = monday.subtract(const Duration(days: 400));
      expect(value(Closeness.family, previous: long, rhythm: null), 2);
    });

    test('both bonuses add up, a meet-up doubles the total', () {
      final long = monday.subtract(const Duration(days: 100));
      expect(
        value(
          Closeness.nowAndThen,
          reconnecting: true,
          previous: long,
          rhythm: 42,
        ),
        4,
      );
      expect(
        value(
          Closeness.nowAndThen,
          reconnecting: true,
          previous: long,
          rhythm: 42,
          kind: ContactKind.met,
        ),
        8,
      );
    });

    test('gaming together doubles, calls and wishes do not', () {
      expect(value(Closeness.nowAndThen, kind: ContactKind.gamed), 4);
      expect(value(Closeness.family, kind: ContactKind.gamed), 4);
      expect(value(Closeness.fewTimesAYear, kind: ContactKind.gamed), 6);
      expect(value(Closeness.nowAndThen, kind: ContactKind.called), 2);
      expect(value(Closeness.nowAndThen, kind: ContactKind.birthdayWish), 2);
    });

    test('gaming with close friends does not multiply, by its own setting', () {
      expect(value(Closeness.close, kind: ContactKind.gamed), 1);
      expect(
        value(Closeness.close, kind: ContactKind.gamed, reconnecting: true),
        2,
      );
      // A meet-up with a close friend still doubles.
      expect(value(Closeness.close, kind: ContactKind.met), 2);
      const w = StampWeights(gameCloseMultiplier: 3, gameMultiplier: 4);
      expect(value(Closeness.close, kind: ContactKind.gamed, weights: w), 3);
      expect(value(Closeness.family, kind: ContactKind.gamed, weights: w), 8);
      expect(const StampWeights().gameCloseMultiplier, 1);
      expect(const StampWeights().family, 2);
    });

    test('every weight can be changed', () {
      const w = StampWeights(
        close: 2,
        nowAndThen: 3,
        fewTimesAYear: 5,
        family: 4,
        backInTouchBonus: 2,
        longGapBonus: 0,
        meetMultiplier: 3,
        gameMultiplier: 1,
      );
      final long = monday.subtract(const Duration(days: 100));
      expect(value(Closeness.close, weights: w), 2);
      expect(value(Closeness.family, weights: w), 4);
      expect(value(Closeness.fewTimesAYear, weights: w), 5);
      expect(value(Closeness.close, weights: w, previous: long), 2);
      expect(value(Closeness.close, weights: w, reconnecting: true), 4);
      expect(value(Closeness.close, weights: w, kind: ContactKind.met), 6);
      expect(value(Closeness.close, weights: w, kind: ContactKind.gamed), 2);
    });
  });

  group('the weekly cap', () {
    test('the first contact of a week gets its whole value', () {
      expect(stampToAdd(weekTotal: 0, value: 3), 3);
    });

    test('a later contact of the same or a lower value adds nothing', () {
      expect(stampToAdd(weekTotal: 2, value: 2), 0);
      expect(stampToAdd(weekTotal: 3, value: 1), 0);
    });

    test('a later contact worth more raises the stamp by the difference', () {
      expect(stampToAdd(weekTotal: 1, value: 2), 1);
      expect(stampToAdd(weekTotal: 2, value: 6), 4);
    });

    test('a week runs from Monday to Sunday', () {
      expect(weekStart(DateTime(2026, 11, 16, 0, 0)), DateTime(2026, 11, 16));
      expect(weekStart(DateTime(2026, 11, 22, 23, 59)), DateTime(2026, 11, 16));
      expect(weekStart(DateTime(2026, 11, 23)), DateTime(2026, 11, 23));
      expect(
        nextWeekStart(DateTime(2026, 11, 22, 23, 59)),
        DateTime(2026, 11, 23),
      );
      // Across a month and a year.
      expect(weekStart(DateTime(2027, 1, 1)), DateTime(2026, 12, 28));
      expect(nextWeekStart(DateTime(2026, 12, 31)), DateTime(2027, 1, 4));
    });
  });

  group('the Progress numbers', () {
    final now = DateTime(2026, 11, 18, 12);

    test('the people this week are the user\'s contacts, newest first', () {
      final events = [
        event('1', DateTime(2026, 11, 16, 9), person: 'a'),
        event('2', DateTime(2026, 11, 17, 9), person: 'b'),
        event('3', DateTime(2026, 11, 18, 9), person: 'a'),
        event(
          '4',
          DateTime(2026, 11, 18, 10),
          person: 'c',
          direction: ContactDirection.byThem,
        ),
        event('5', DateTime(2026, 11, 15, 22), person: 'd'),
      ];
      expect(peopleThisWeek(events, now), ['a', 'b']);
    });

    test('your numbers count this month and the Yes answers', () {
      final events = [
        event('1', DateTime(2026, 11, 2), person: 'a'),
        event('2', DateTime(2026, 11, 9), person: 'a'),
        event('3', DateTime(2026, 11, 10), person: 'b'),
        event(
          '4',
          DateTime(2026, 11, 11),
          person: 'c',
          direction: ContactDirection.byThem,
        ),
        event('5', DateTime(2026, 10, 30), person: 'd'),
      ];
      final answers = [
        DayAnswer(day: '2026-11-01', answer: DayAnswerValue.yes),
        DayAnswer(day: '2026-11-02', answer: DayAnswerValue.notToday),
        DayAnswer(day: '2026-10-02', answer: DayAnswerValue.yes),
      ];
      expect(
        yourNumbers(events, answers, now),
        const YourNumbers(
          eveningsYes: 2,
          contactsThisMonth: 3,
          peopleThisMonth: 2,
        ),
      );
    });
  });
}
