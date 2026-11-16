import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/data/database.dart';
import 'package:kept/data/day_answers_repository.dart';
import 'package:kept/domain/contact_event.dart';
import 'package:kept/domain/evening_question.dart';
import 'package:kept/platform/notifications.dart';

void main() {
  group('eveningWeekdays', () {
    test('all seven days by default, Monday first', () {
      expect(eveningWeekdays(on: true, excluded: {}), [1, 2, 3, 4, 5, 6, 7]);
    });

    test('leaves out the excluded days', () {
      expect(eveningWeekdays(on: true, excluded: {DateTime.saturday, 7}), [
        1,
        2,
        3,
        4,
        5,
      ]);
      expect(eveningWeekdays(on: true, excluded: {1, 2, 3, 4, 5, 6, 7}), []);
    });

    test('none when switched off', () {
      expect(eveningWeekdays(on: false, excluded: {}), isEmpty);
    });
  });

  group('nextEvening', () {
    // Monday 16 November 2026.
    final monday = DateTime(2026, 11, 16, 12);

    test('today if the time is still ahead', () {
      expect(
        nextEvening(monday, DateTime.monday, 19 * 60),
        DateTime(2026, 11, 16, 19),
      );
    });

    test('a week later if today\'s time has passed', () {
      expect(
        nextEvening(DateTime(2026, 11, 16, 19), DateTime.monday, 19 * 60),
        DateTime(2026, 11, 23, 19),
      );
    });

    test('the coming weekday, at the chosen minute', () {
      expect(
        nextEvening(monday, DateTime.sunday, 20 * 60 + 45),
        DateTime(2026, 11, 22, 20, 45),
      );
      expect(
        nextEvening(monday, DateTime.tuesday, 7 * 60 + 5),
        DateTime(2026, 11, 17, 7, 5),
      );
    });

    test('keeps the wall-clock time across a month end', () {
      expect(
        nextEvening(DateTime(2026, 12, 30, 22), DateTime.friday, 19 * 60),
        DateTime(2027, 1, 1, 19),
      );
    });
  });

  group('eveningAnswerFor', () {
    test('maps the buttons and a tap', () {
      expect(
        eveningAnswerFor(actionId: 'not_today', payload: eveningPayload),
        DayAnswerValue.notToday,
      );
      expect(
        eveningAnswerFor(actionId: 'yes', payload: eveningPayload),
        DayAnswerValue.yes,
      );
      expect(eveningAnswerFor(payload: eveningPayload), DayAnswerValue.yes);
    });

    test('ignores other notifications and unknown buttons', () {
      expect(eveningAnswerFor(actionId: 'yes', payload: 'birthday'), isNull);
      expect(eveningAnswerFor(actionId: 'yes'), isNull);
      expect(
        eveningAnswerFor(actionId: 'later', payload: eveningPayload),
        isNull,
      );
    });
  });

  group('recordEveningResponse', () {
    late AppDatabase db;
    late DayAnswersRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = DayAnswersRepository(db);
    });
    tearDown(() => db.close());

    final evening = DateTime(2026, 11, 16, 19, 3);

    test('stores "Not today"', () async {
      final answer = await recordEveningResponse(
        repo,
        actionId: eveningNotTodayAction,
        payload: eveningPayload,
        now: evening,
      );
      expect(answer, DayAnswerValue.notToday);
      expect((await repo.forDay(evening))?.answer, DayAnswerValue.notToday);
    });

    test('stores "Yes" for the button and for a tap', () async {
      await recordEveningResponse(
        repo,
        actionId: eveningYesAction,
        payload: eveningPayload,
        now: evening,
      );
      expect((await repo.forDay(evening))?.answer, DayAnswerValue.yes);

      final nextDay = DateTime(2026, 11, 17, 19, 1);
      await recordEveningResponse(repo, payload: eveningPayload, now: nextDay);
      expect((await repo.forDay(nextDay))?.answer, DayAnswerValue.yes);
    });

    test('stores nothing for another notification', () async {
      final answer = await recordEveningResponse(
        repo,
        actionId: eveningNotTodayAction,
        payload: 'other',
        now: evening,
      );
      expect(answer, isNull);
      expect(await repo.forDay(evening), isNull);
    });
  });
}
