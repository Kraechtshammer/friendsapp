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

  /// All events of everyone, newest first. For the owed replies
  /// (domain/owed_reply.dart).
  Stream<List<ContactEvent>> watchAll() =>
      (_db.select(_db.contactEvents)..orderBy(_newestFirst)).watch();

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

  /// The birthday wishes in [direction] on the local day of [day], of
  /// everyone, oldest first.
  Stream<List<ContactEvent>> watchBirthdayWishes(
    ContactDirection direction,
    DateTime day,
  ) {
    final start = DateTime(day.year, day.month, day.day);
    final end = DateTime(day.year, day.month, day.day + 1);
    return (_db.select(_db.contactEvents)
          ..where(
            (t) =>
                t.kind.equalsValue(ContactKind.birthdayWish) &
                t.direction.equalsValue(direction) &
                t.at.isBiggerOrEqualValue(start) &
                t.at.isSmallerThanValue(end),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.at),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .watch();
  }

  /// "You congratulated" [personId] on the local day of [day]: adds a
  /// birthday wish by the user, unless one is already stored for that day;
  /// then that one is returned and nothing is added. [at] defaults to now;
  /// it is moved into [day] if it falls outside (a late answer after
  /// midnight still counts for the birthday).
  Future<ContactEvent> addBirthdayWishOnce({
    required String personId,
    required DateTime day,
    required ContactSource source,
    DateTime? at,
    DateTime? now,
  }) {
    final time = now ?? DateTime.now();
    var when = at ?? time;
    if (dayKey(when) != dayKey(day)) {
      when = DateTime(day.year, day.month, day.day, 23, 59);
    }
    return _db.transaction(() async {
      final existing = await (_db.select(
        _db.contactEvents,
      )..where((t) => t.personId.equals(personId))).get();
      for (final e in existing) {
        if (e.kind == ContactKind.birthdayWish &&
            e.direction == ContactDirection.byUser &&
            dayKey(e.at) == dayKey(day)) {
          return e;
        }
      }
      return add(
        personId: personId,
        at: when,
        kind: ContactKind.birthdayWish,
        direction: ContactDirection.byUser,
        source: source,
        now: time,
      );
    });
  }

  /// "They congratulated you": stores ([on] true) or removes ([on] false)
  /// [personId]'s birthday wish to the user on the local day of [day]. At
  /// most one is stored per person and day. [at] is the time of a new one.
  Future<void> setWishFrom(
    String personId,
    DateTime day, {
    required bool on,
    required DateTime at,
  }) {
    final start = DateTime(day.year, day.month, day.day);
    final end = DateTime(day.year, day.month, day.day + 1);
    return _db.transaction(() async {
      final query = _db.select(_db.contactEvents)
        ..where(
          (t) =>
              t.personId.equals(personId) &
              t.kind.equalsValue(ContactKind.birthdayWish) &
              t.direction.equalsValue(ContactDirection.byThem) &
              t.at.isBiggerOrEqualValue(start) &
              t.at.isSmallerThanValue(end),
        );
      final existing = await query.get();
      if (!on) {
        for (final e in existing) {
          await delete(e.id);
        }
        return;
      }
      if (existing.isNotEmpty) return;
      await add(
        personId: personId,
        at: at,
        kind: ContactKind.birthdayWish,
        direction: ContactDirection.byThem,
        source: ContactSource.manual,
      );
    });
  }

  /// "They wrote" or "They called": adds an event of [kind] from the
  /// person (direction byThem, by default source manual) at [at], unless
  /// one of that kind is already stored from them on the same local day,
  /// from any source; then null is returned and nothing is added. So a
  /// second tap on a day does nothing, and the notification listener
  /// ([ContactSource.listener]) adds at most one per person, kind and day.
  Future<ContactEvent?> addByThemOnce({
    required String personId,
    required ContactKind kind,
    required DateTime at,
    ContactSource source = ContactSource.manual,
    DateTime? now,
  }) {
    final start = DateTime(at.year, at.month, at.day);
    final end = DateTime(at.year, at.month, at.day + 1);
    return _db.transaction(() async {
      final existing =
          await (_db.select(_db.contactEvents)..where(
                (t) =>
                    t.personId.equals(personId) &
                    t.kind.equalsValue(kind) &
                    t.direction.equalsValue(ContactDirection.byThem) &
                    t.at.isBiggerOrEqualValue(start) &
                    t.at.isSmallerThanValue(end),
              ))
              .get();
      if (existing.isNotEmpty) return null;
      return add(
        personId: personId,
        at: at,
        kind: kind,
        direction: ContactDirection.byThem,
        source: source,
        now: now,
      );
    });
  }

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

  /// Sets the activity and the note of an event. Both are replaced, so
  /// null clears one. Nothing else of an event can change.
  Future<void> update(String id, {String? activity, String? note}) =>
      (_db.update(_db.contactEvents)..where((t) => t.id.equals(id))).write(
        ContactEventsCompanion(activity: Value(activity), note: Value(note)),
      );

  Future<void> delete(String id) =>
      (_db.delete(_db.contactEvents)..where((t) => t.id.equals(id))).go();

  /// Replaces all events with [events] in one step. For the demo database;
  /// the people they refer to must be there already.
  Future<void> replaceAll(List<ContactEvent> events) =>
      _db.transaction(() async {
        await _db.delete(_db.contactEvents).go();
        await _db.batch((b) => b.insertAll(_db.contactEvents, events));
      });

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
