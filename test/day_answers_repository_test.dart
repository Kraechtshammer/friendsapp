import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/data/database.dart';
import 'package:kept/data/day_answers_repository.dart';
import 'package:kept/domain/contact_event.dart';

void main() {
  late AppDatabase db;
  late DayAnswersRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DayAnswersRepository(db);
  });
  tearDown(() => db.close());

  test('dayKey is the local day as YYYY-MM-DD', () {
    expect(dayKey(DateTime(2026, 3, 7, 23, 59)), '2026-03-07');
    expect(dayKey(DateTime(987, 12, 31)), '0987-12-31');
  });

  test('sets today\'s answer and reads it back', () async {
    final now = DateTime(2026, 11, 16, 21, 4, 5, 600);
    expect(await repo.forDay(now), isNull);
    final set = await repo.setToday(DayAnswerValue.notToday, now: now);
    expect(set.day, '2026-11-16');
    expect(set.answeredAt, DateTime(2026, 11, 16, 21, 4, 5));
    expect(await repo.forDay(DateTime(2026, 11, 16, 8)), set);
    expect(await repo.forDay(DateTime(2026, 11, 17)), isNull);
  });

  test('a second answer on the same day replaces the first', () async {
    await repo.setToday(
      DayAnswerValue.notToday,
      now: DateTime(2026, 11, 16, 9),
    );
    await repo.setToday(DayAnswerValue.yes, now: DateTime(2026, 11, 16, 22));
    final row = await repo.forDay(DateTime(2026, 11, 16));
    expect(row?.answer, DayAnswerValue.yes);
    expect(row?.answeredAt, DateTime(2026, 11, 16, 22));
    expect(await db.select(db.dayAnswers).get(), hasLength(1));
  });

  test('stores the answer as its name', () async {
    await repo.setToday(DayAnswerValue.none, now: DateTime(2026, 11, 16));
    final row = await db
        .customSelect('SELECT answer FROM day_answers')
        .getSingle();
    expect(row.read<String>('answer'), 'none');
  });
}
