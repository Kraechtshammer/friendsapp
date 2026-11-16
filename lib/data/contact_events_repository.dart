import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/contact_event.dart';
import '../domain/intention.dart';
import 'database.dart';

/// Reads and writes the contact events of one database: the real one or,
/// in demo mode, the demo one (AppServices.contactEventsFor). See
/// docs/02-design.md §3.
class ContactEventsRepository {
  ContactEventsRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// Adds an event with a new id. [now] (for `createdAt`) is for tests.
  Future<ContactEvent> add({
    required String personId,
    required DateTime at,
    required ContactKind kind,
    required ContactDirection direction,
    required ContactSource source,
    String? activity,
    String? note,
    String? intentionId,
    DateTime? now,
  }) async {
    final event = ContactEvent(
      id: _uuid.v4(),
      personId: personId,
      at: _wholeSeconds(at),
      kind: kind,
      direction: direction,
      source: source,
      activity: activity,
      note: note,
      intentionId: intentionId,
      createdAt: _wholeSeconds(now ?? DateTime.now()),
    );
    await _db.into(_db.contactEvents).insert(event);
    return event;
  }

  /// All events of one person, newest first.
  Stream<List<ContactEvent>> watchForPerson(String personId) =>
      (_db.select(_db.contactEvents)
            ..where((t) => t.personId.equals(personId))
            ..orderBy(_newestFirst))
          .watch();

  /// The note of the person's newest event that has a non-empty one; null
  /// if there is none.
  Stream<String?> watchLatestNote(String personId) =>
      (_db.select(_db.contactEvents)
            ..where(
              (t) =>
                  t.personId.equals(personId) &
                  t.note.isNotNull() &
                  t.note.trim().equals('').not(),
            )
            ..orderBy(_newestFirst)
            ..limit(1))
          .watchSingleOrNull()
          .map((e) => e?.note);

  /// Marks the intention [intentionId] done and adds the contact event that
  /// did it, linked to it, in one transaction. Kind and direction follow
  /// from the intention's kind (contactKindFor, contactDirectionFor).
  /// [at] defaults to now; [now] is for tests.
  Future<ContactEvent> completeIntention(
    String intentionId, {
    ContactSource source = ContactSource.confirmed,
    DateTime? at,
    String? activity,
    String? note,
    DateTime? now,
  }) {
    final time = now ?? DateTime.now();
    return _db.transaction(() async {
      final intention = await (_db.select(
        _db.intentions,
      )..where((t) => t.id.equals(intentionId))).getSingle();
      await (_db.update(
        _db.intentions,
      )..where((t) => t.id.equals(intentionId))).write(
        IntentionsCompanion(
          state: const Value(IntentionState.done),
          closedAt: Value(_wholeSeconds(time)),
        ),
      );
      return add(
        personId: intention.personId,
        at: at ?? time,
        kind: contactKindFor(intention.kind),
        direction: contactDirectionFor(intention.kind),
        source: source,
        activity: activity,
        note: note,
        intentionId: intentionId,
        now: time,
      );
    });
  }

  Future<void> delete(String id) =>
      (_db.delete(_db.contactEvents)..where((t) => t.id.equals(id))).go();

  static final _newestFirst = <OrderClauseGenerator<$ContactEventsTable>>[
    (t) => OrderingTerm.desc(t.at),
    (t) => OrderingTerm.desc(t.createdAt),
    // drift stores whole seconds; the id keeps the order stable.
    (t) => OrderingTerm.desc(t.id),
  ];

  /// drift stores whole seconds; cut here so a returned row equals the
  /// stored one.
  static DateTime _wholeSeconds(DateTime t) => t.subtract(
    Duration(milliseconds: t.millisecond, microseconds: t.microsecond),
  );
}
