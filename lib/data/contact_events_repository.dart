import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/contact_event.dart';
import '../domain/intention.dart';
import 'app_settings.dart';
import 'database.dart';
import 'settings_repository.dart';
import 'treats_repository.dart';
import 'whole_seconds.dart';

/// Reads and writes the contact events of one database: the real one or,
/// in demo mode, the demo one (AppServices.contactEventsFor). See
/// docs/02-design.md §3.
class ContactEventsRepository {
  /// [loadSettings] gives the stamp weights; in demo mode they come from
  /// the real database (AppServices), otherwise from this one.
  ContactEventsRepository(
    this._db, {
    Future<AppSettings> Function()? loadSettings,
  }) : _loadSettings = loadSettings ?? SettingsRepository(_db).load,
       _treats = TreatsRepository(_db);

  final AppDatabase _db;
  final Future<AppSettings> Function() _loadSettings;
  final TreatsRepository _treats;
  static const _uuid = Uuid();

  /// Adds an event with a new id. [now] (for `createdAt`) is for tests.
  ///
  /// This is the one place where a stamp is awarded: every event added by
  /// the app (Done, "Did you write?", "Did it happen?", birthday wishes,
  /// the reconnect pick, "They wrote", the listener) comes through here,
  /// and the stamp is created or raised in the same transaction
  /// (TreatsRepository.awardFor). Deleting the event later keeps it.
  Future<ContactEvent> add({
    required String personId,
    required DateTime at,
    required ContactKind kind,
    required ContactDirection direction,
    required ContactSource source,
    String? activity,
    String? note,
    String? intentionId,
    String? groupId,
    String? sharedId,
    DateTime? now,
  }) async {
    final event = ContactEvent(
      id: _uuid.v4(),
      personId: personId,
      at: wholeSeconds(at),
      kind: kind,
      direction: direction,
      source: source,
      activity: activity,
      note: note,
      intentionId: intentionId,
      createdAt: wholeSeconds(now ?? DateTime.now()),
      groupId: groupId,
      sharedId: sharedId,
    );
    final settings = await _loadSettings();
    await _db.transaction(() async {
      await _db.into(_db.contactEvents).insert(event);
      await _treats.awardFor(event, settings, now: event.createdAt);
    });
    return event;
  }

  /// A contact with a group (meeting a couple): one row per member, in the
  /// members' order, all with the same time, kind, note, [groupId] and a
  /// new `sharedId`, in one transaction. Each row goes through [add], so
  /// every member's timeline shows it and each gets their stamp by the one
  /// rule. Throws a [StateError] if the group has no members.
  Future<List<ContactEvent>> addForGroup({
    required String groupId,
    required DateTime at,
    required ContactKind kind,
    required ContactDirection direction,
    required ContactSource source,
    String? activity,
    String? note,
    String? intentionId,
    DateTime? now,
  }) {
    final time = now ?? DateTime.now();
    final sharedId = _uuid.v4();
    return _db.transaction(() async {
      final members =
          await (_db.select(_db.groupMembers)
                ..where((m) => m.groupId.equals(groupId))
                ..orderBy([(m) => OrderingTerm.asc(m.position)]))
              .get();
      if (members.isEmpty) {
        throw StateError('Group $groupId has no members');
      }
      return [
        for (final m in members)
          await add(
            personId: m.personId,
            at: at,
            kind: kind,
            direction: direction,
            source: source,
            activity: activity,
            note: note,
            intentionId: intentionId,
            groupId: groupId,
            sharedId: sharedId,
            now: time,
          ),
      ];
    });
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
  /// from the intention's kind (contactKindFor, contactDirectionFor). A
  /// couple's intention adds the event for the group ([addForGroup]) and
  /// returns the first member's row, unless [onlyPersonId] is given: then
  /// one plain event for that member only (writing or calling one of the
  /// two; ui rule in 04-architecture.md, "Couples"). [at] defaults to now;
  /// [now] is for tests.
  Future<ContactEvent> completeIntention(
    String intentionId, {
    ContactSource source = ContactSource.confirmed,
    DateTime? at,
    String? activity,
    String? note,
    String? onlyPersonId,
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
          closedAt: Value(wholeSeconds(time)),
        ),
      );
      final groupId = intention.groupId;
      if (groupId != null && onlyPersonId == null) {
        final rows = await addForGroup(
          groupId: groupId,
          at: at ?? time,
          kind: contactKindFor(intention.kind),
          direction: contactDirectionFor(intention.kind),
          source: source,
          activity: activity,
          note: note,
          intentionId: intentionId,
          now: time,
        );
        return rows.first;
      }
      return add(
        personId: onlyPersonId ?? intention.personId!,
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
  /// null clears one. Nothing else of an event can change. For a shared
  /// event (a meeting with a couple) every row of it changes, so all
  /// timelines show the same.
  Future<void> update(String id, {String? activity, String? note}) =>
      _db.transaction(() async {
        final ids = await sharedRowIds(id);
        await (_db.update(
          _db.contactEvents,
        )..where((t) => t.id.isIn(ids))).write(
          ContactEventsCompanion(activity: Value(activity), note: Value(note)),
        );
      });

  /// Deletes an event; for a shared event every row of it. Stamps stay.
  Future<void> delete(String id) => _db.transaction(() async {
    final ids = await sharedRowIds(id);
    await (_db.delete(_db.contactEvents)..where((t) => t.id.isIn(ids))).go();
  });

  /// The ids of all rows of the event [id]: the rows with its `sharedId`,
  /// or only [id] for an event with one person (or an unknown id).
  Future<List<String>> sharedRowIds(String id) async {
    final row = await (_db.select(
      _db.contactEvents,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    final sharedId = row?.sharedId;
    if (sharedId == null) return [id];
    return (_db.selectOnly(_db.contactEvents)
          ..addColumns([_db.contactEvents.id])
          ..where(_db.contactEvents.sharedId.equals(sharedId)))
        .map((r) => r.read(_db.contactEvents.id)!)
        .get();
  }

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
}
