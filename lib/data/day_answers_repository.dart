import 'package:drift/drift.dart';

import '../domain/contact_event.dart';
import 'database.dart';

/// Reads and writes the user's answer per local day, in one database: the
/// real one or, in demo mode, the demo one (AppServices.dayAnswersFor).
class DayAnswersRepository {
  DayAnswersRepository(this._db);

  final AppDatabase _db;

  /// Sets the answer for today (the local day of [now]), replacing an
  /// earlier one. `answeredAt` is [now]. [now] is for tests.
  Future<DayAnswer> setToday(DayAnswerValue answer, {DateTime? now}) async {
    final time = _wholeSeconds(now ?? DateTime.now());
    final row = DayAnswer(day: dayKey(time), answer: answer, answeredAt: time);
    await _db.into(_db.dayAnswers).insertOnConflictUpdate(row);
    return row;
  }

  /// The answer for the local day of [day]; null if there is none.
  Future<DayAnswer?> forDay(DateTime day) => (_db.select(
    _db.dayAnswers,
  )..where((t) => t.day.equals(dayKey(day)))).getSingleOrNull();

  /// Every answer, oldest first. For the numbers on the Progress tab.
  Stream<List<DayAnswer>> watchAll() => (_db.select(
    _db.dayAnswers,
  )..orderBy([(t) => OrderingTerm.asc(t.day)])).watch();

  /// Replaces all answers with [answers] in one step. For the demo
  /// database.
  Future<void> replaceAll(List<DayAnswer> answers) => _db.transaction(() async {
    await _db.delete(_db.dayAnswers).go();
    await _db.batch((b) => b.insertAll(_db.dayAnswers, answers));
  });

  /// drift stores whole seconds; cut here so a returned row equals the
  /// stored one.
  static DateTime _wholeSeconds(DateTime t) => t.subtract(
    Duration(milliseconds: t.millisecond, microseconds: t.microsecond),
  );
}
