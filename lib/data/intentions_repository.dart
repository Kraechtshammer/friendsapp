import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/intention.dart';
import 'database.dart';
import 'whole_seconds.dart';

/// Reads and writes the intentions of one database: the real one or, in
/// demo mode, the demo one (AppServices.intentionsFor). See
/// docs/02-design.md §2.1 and §3.
class IntentionsRepository {
  IntentionsRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// The open intentions of everyone, newest first.
  Stream<List<Intention>> watchOpen() =>
      (_db.select(_db.intentions)
            ..where((t) => t.state.equalsValue(IntentionState.open))
            ..orderBy(_newestFirst))
          .watch();

  /// All intentions of one person, in every state, newest first.
  Stream<List<Intention>> watchForPerson(String personId) =>
      (_db.select(_db.intentions)
            ..where((t) => t.personId.equals(personId))
            ..orderBy(_newestFirst))
          .watch();

  static final _newestFirst = <OrderClauseGenerator<$IntentionsTable>>[
    (t) => OrderingTerm.desc(t.createdAt),
    // drift stores whole seconds; the id keeps the order stable.
    (t) => OrderingTerm.desc(t.id),
  ];

  /// Adds an open intention with a new id. [now] is for tests.
  Future<Intention> add({
    required String personId,
    String note = '',
    IntentionKind kind = IntentionKind.write,
    When when = const When.none(),
    String? link,
    DateTime? now,
  }) async {
    final intention = Intention(
      id: _uuid.v4(),
      personId: personId,
      note: note,
      kind: kind,
      state: IntentionState.open,
      date: when.date == null ? null : wholeSeconds(when.date!),
      horizon: when.horizon,
      condition: _condition(when),
      link: _link(link),
      createdAt: wholeSeconds(now ?? DateTime.now()),
    );
    await _db.into(_db.intentions).insert(intention);
    return intention;
  }

  /// Changes the text, the kind, the "when" and the link of an intention in
  /// one step, as the edit sheet does. A date and a horizon never go
  /// together; the condition is kept only for "when…" and only if it has
  /// text. An empty [link] is stored as null.
  Future<void> update(
    String id, {
    required String note,
    required IntentionKind kind,
    required When when,
    String? link,
  }) => (_db.update(_db.intentions)..where((t) => t.id.equals(id))).write(
    IntentionsCompanion(
      note: Value(note),
      kind: Value(kind),
      link: Value(_link(link)),
      date: Value(when.date == null ? null : wholeSeconds(when.date!)),
      horizon: Value(when.horizon),
      condition: Value(_condition(when)),
    ),
  );

  /// Sets only the "when" ("Set a date", "Pick a date").
  Future<void> setWhen(String id, When when) =>
      (_db.update(_db.intentions)..where((t) => t.id.equals(id))).write(
        IntentionsCompanion(
          date: Value(when.date == null ? null : wholeSeconds(when.date!)),
          horizon: Value(when.horizon),
          condition: Value(_condition(when)),
        ),
      );

  /// "Did it happen?" answered No: the date is cleared and the horizon is
  /// Soon, so the thought is an undated plan again. Nothing else is stored.
  Future<void> moveBackToPlans(String id) =>
      setWhen(id, const When.horizon(Horizon.soon));

  static String? _link(String? link) {
    final text = link?.trim();
    return text == null || text.isEmpty ? null : text;
  }

  static String? _condition(When when) {
    final text = when.condition?.trim();
    return when.horizon == Horizon.whenCondition &&
            text != null &&
            text.isNotEmpty
        ? text
        : null;
  }

  /// Moves an intention to [state]. Leaving `open` sets `closedAt`; going
  /// back to `open` clears it. [now] is for tests.
  Future<void> setState(String id, IntentionState state, {DateTime? now}) =>
      (_db.update(_db.intentions)..where((t) => t.id.equals(id))).write(
        IntentionsCompanion(
          state: Value(state),
          closedAt: Value(
            state == IntentionState.open
                ? null
                : wholeSeconds(now ?? DateTime.now()),
          ),
        ),
      );

  Future<void> delete(String id) =>
      (_db.delete(_db.intentions)..where((t) => t.id.equals(id))).go();

  /// Replaces all intentions with [intentions] in one step. For the demo
  /// database; the people they refer to must be there already.
  Future<void> replaceAll(List<Intention> intentions) =>
      _db.transaction(() async {
        await _db.delete(_db.intentions).go();
        await _db.batch((b) => b.insertAll(_db.intentions, intentions));
      });
}
