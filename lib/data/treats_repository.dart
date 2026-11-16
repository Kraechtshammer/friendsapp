import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/stamps.dart';
import '../domain/treat.dart';
import '../domain/rhythm.dart' show rhythmDaysFor;
import 'app_settings.dart';
import 'database.dart';

/// Treats and stamps of one database: the real one or, in demo mode, the
/// demo one (AppServices.treatsFor). The stamp rule is in
/// `domain/stamps.dart`; this class stores its result (02-design.md §3,
/// §6.9, §6.10).
///
/// Stamps are awarded in one place only: [awardFor], called by
/// ContactEventsRepository in the transaction that stores the event (and by
/// [backfill]). Nothing here ever removes a stamp or lowers its value, and
/// a stamp survives the deletion of its person, event or treat.
///
/// A stamp row is a piece of a stamp: the value that fits onto one card.
/// When a stamp is worth more than the room left on the card, it is cut
/// into a piece for the card and a loose piece with the rest (`treatId`
/// null), which goes onto the next card the user chooses. A raise within a
/// week is a piece too. So the week's value of a person is the sum of their
/// pieces of that week, and the user's count is the sum of all pieces.
class TreatsRepository {
  TreatsRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  // Reading.

  /// All treats: by state's order of use, then position.
  Stream<List<Treat>> watchAll() =>
      (_db.select(_db.treats)..orderBy([
            (t) => OrderingTerm.asc(t.position),
            (t) => OrderingTerm.asc(t.createdAt),
            (t) => OrderingTerm.asc(t.id),
          ]))
          .watch();

  /// All stamps, oldest first.
  Stream<List<Stamp>> watchStamps() =>
      (_db.select(_db.stamps)..orderBy(_oldestFirst)).watch();

  /// The stamps that one contact event earned (it can be more than one
  /// piece), oldest first.
  Stream<List<Stamp>> watchForEvent(String eventId) =>
      (_db.select(_db.stamps)
            ..where((t) => t.contactEventId.equals(eventId))
            ..orderBy(_oldestFirst))
          .watch();

  // Awarding.

  /// Awards what [event] is worth, if anything: nothing for incoming
  /// contact, for a person that is gone, or when the week already has a
  /// stamp of the same or a higher value for that person. Creates the
  /// stamp or raises the week's one. Returns the value added (0 for none).
  /// Call it inside the transaction that stores [event]. [now] is the time
  /// of `createdAt` and of a card that becomes earned.
  Future<int> awardFor(
    ContactEvent event,
    AppSettings settings, {
    DateTime? now,
  }) async {
    if (!earnsStamp(event.kind, event.direction)) return 0;
    final person = await (_db.select(
      _db.people,
    )..where((t) => t.id.equals(event.personId))).getSingleOrNull();
    if (person == null) return 0;
    // The contact before this one: any direction, strictly earlier.
    final earlier =
        await (_db.select(_db.contactEvents)
              ..where(
                (t) =>
                    t.personId.equals(person.id) &
                    t.at.isSmallerThanValue(event.at) &
                    t.id.equals(event.id).not(),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.at)])
              ..limit(1))
            .getSingleOrNull();
    final value = stampValue(
      closeness: person.closeness,
      reconnecting: person.reconnecting,
      kind: event.kind,
      at: event.at,
      previous: earlier?.at ?? person.createdAt,
      rhythmDays: rhythmDaysFor(person, settings.classRhythms),
      weights: settings.stampWeights,
    );
    final from = weekStart(event.at);
    final until = nextWeekStart(event.at);
    final week =
        await (_db.select(_db.stamps)..where(
              (t) =>
                  t.personId.equals(person.id) &
                  t.at.isBiggerOrEqualValue(from) &
                  t.at.isSmallerThanValue(until),
            ))
            .get();
    final add = stampToAdd(
      weekTotal: week.fold(0, (sum, s) => sum + s.value),
      value: value,
    );
    if (add <= 0) return 0;
    await _place(
      value: add,
      at: event.at,
      personId: person.id,
      eventId: event.id,
      now: now ?? DateTime.now(),
    );
    return add;
  }

  /// Runs the rule over every stored contact event, oldest first, so the
  /// history earns its stamps. The caller makes sure it runs once
  /// (AppServices.ensureStampsReady). Returns the number of events that
  /// earned or raised a stamp.
  Future<int> backfill(AppSettings settings, {DateTime? now}) async {
    final events =
        await (_db.select(_db.contactEvents)..orderBy([
              (t) => OrderingTerm.asc(t.at),
              (t) => OrderingTerm.asc(t.createdAt),
              (t) => OrderingTerm.asc(t.id),
            ]))
            .get();
    var awarded = 0;
    for (final e in events) {
      if (await awardFor(e, settings, now: now) > 0) awarded++;
    }
    return awarded;
  }

  /// Puts [value] onto the current card, piece by piece. A card that
  /// becomes full is earned; what is left over stays loose.
  Future<void> _place({
    required int value,
    required DateTime at,
    required String personId,
    required String eventId,
    required DateTime now,
  }) async {
    var left = value;
    var current = await _current();
    while (left > 0) {
      if (current == null) {
        await _insertStamp(left, at, personId, eventId, null, now);
        return;
      }
      final room = current.stampsNeeded - await _filled(current.id);
      if (room <= 0) {
        await _earn(current.id, now);
        current = null;
        continue;
      }
      final take = left < room ? left : room;
      await _insertStamp(take, at, personId, eventId, current.id, now);
      left -= take;
      if (take == room) {
        await _earn(current.id, now);
        current = null;
      }
    }
  }

  Future<Treat?> _current() => (_db.select(
    _db.treats,
  )..where((t) => t.state.equalsValue(TreatState.current))).getSingleOrNull();

  Future<int> _filled(String treatId) async {
    final sum = _db.stamps.value.sum();
    final row =
        await (_db.selectOnly(_db.stamps)
              ..addColumns([sum])
              ..where(_db.stamps.treatId.equals(treatId)))
            .getSingle();
    return row.read(sum) ?? 0;
  }

  Future<void> _earn(String treatId, DateTime now) =>
      (_db.update(_db.treats)..where((t) => t.id.equals(treatId))).write(
        TreatsCompanion(
          state: const Value(TreatState.earned),
          earnedAt: Value(_whole(now)),
        ),
      );

  Future<void> _insertStamp(
    int value,
    DateTime at,
    String? personId,
    String? eventId,
    String? treatId,
    DateTime now,
  ) => _db
      .into(_db.stamps)
      .insert(
        Stamp(
          id: _uuid.v4(),
          at: _whole(at),
          value: value,
          personId: personId,
          contactEventId: eventId,
          treatId: treatId,
          createdAt: _whole(now),
        ),
      );

  // Treats.

  /// Adds the default treats (name, stamps), all waiting, in order, after
  /// the ones that exist. For the first start (AppServices) and the demo.
  Future<void> insertDefaults(List<(String, int)> treats, {DateTime? now}) =>
      _db.transaction(() async {
        final time = now ?? DateTime.now();
        for (final (name, stamps) in treats) {
          await add(name, stamps, now: time);
        }
      });

  /// Adds a waiting treat at the end of the queue.
  Future<Treat> add(String name, int stampsNeeded, {DateTime? now}) async {
    final last = await _maxPosition();
    final treat = Treat(
      id: _uuid.v4(),
      name: name.trim(),
      stampsNeeded: stampsNeeded < 1 ? 1 : stampsNeeded,
      state: TreatState.waiting,
      position: last + 1,
      createdAt: _whole(now ?? DateTime.now()),
      earnedAt: null,
      enjoyedAt: null,
    );
    await _db.into(_db.treats).insert(treat);
    return treat;
  }

  Future<int> _maxPosition() async {
    final max = _db.treats.position.max();
    final row = await (_db.selectOnly(
      _db.treats,
    )..addColumns([max])).getSingle();
    return row.read(max) ?? -1;
  }

  /// Renames a waiting treat. Other treats are left alone.
  Future<void> rename(String id, String name) =>
      (_db.update(_db.treats)..where(
            (t) => t.id.equals(id) & t.state.equalsValue(TreatState.waiting),
          ))
          .write(TreatsCompanion(name: Value(name.trim())));

  /// Changes the stamp number of a waiting treat (at least 1).
  Future<void> setStampsNeeded(String id, int stamps) =>
      (_db.update(_db.treats)..where(
            (t) => t.id.equals(id) & t.state.equalsValue(TreatState.waiting),
          ))
          .write(TreatsCompanion(stampsNeeded: Value(stamps < 1 ? 1 : stamps)));

  /// Moves a waiting treat one place up ([up] true) or down in the queue.
  Future<void> move(String id, {required bool up}) => _db.transaction(() async {
    final waiting =
        await (_db.select(_db.treats)
              ..where((t) => t.state.equalsValue(TreatState.waiting))
              ..orderBy([
                (t) => OrderingTerm.asc(t.position),
                (t) => OrderingTerm.asc(t.createdAt),
                (t) => OrderingTerm.asc(t.id),
              ]))
            .get();
    final ids = [for (final t in waiting) t.id];
    final i = ids.indexOf(id);
    final j = up ? i - 1 : i + 1;
    if (i < 0 || j < 0 || j >= ids.length) return;
    ids.insert(j, ids.removeAt(i));
    // Whole queue renumbered, so positions stay distinct.
    for (final (n, treatId) in ids.indexed) {
      await (_db.update(_db.treats)..where((t) => t.id.equals(treatId))).write(
        TreatsCompanion(position: Value(n)),
      );
    }
  });

  /// Deletes a waiting treat. A treat with a card, earned or enjoyed, is
  /// kept: it belongs to the user's history.
  Future<void> delete(String id) =>
      (_db.delete(_db.treats)..where(
            (t) => t.id.equals(id) & t.state.equalsValue(TreatState.waiting),
          ))
          .go();

  /// Makes a waiting treat the current card, when there is none, and puts
  /// the loose stamps onto it, oldest first. A loose stamp that is worth
  /// more than the room left is cut; the card that fills is earned and the
  /// rest stays loose. Returns false when nothing was changed (the treat is
  /// not waiting, or another card is current).
  Future<bool> setCurrent(String id, {DateTime? now}) =>
      _db.transaction(() async {
        final treat = await (_db.select(
          _db.treats,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        if (treat == null ||
            treat.state != TreatState.waiting ||
            await _current() != null) {
          return false;
        }
        final time = now ?? DateTime.now();
        await (_db.update(_db.treats)..where((t) => t.id.equals(id))).write(
          const TreatsCompanion(state: Value(TreatState.current)),
        );
        final loose =
            await (_db.select(_db.stamps)
                  ..where((t) => t.treatId.isNull())
                  ..orderBy(_oldestFirst))
                .get();
        var room = treat.stampsNeeded;
        for (final s in loose) {
          if (room <= 0) break;
          if (s.value <= room) {
            await (_db.update(_db.stamps)..where((t) => t.id.equals(s.id)))
                .write(StampsCompanion(treatId: Value(id)));
            room -= s.value;
          } else {
            await (_db.update(_db.stamps)..where((t) => t.id.equals(s.id)))
                .write(StampsCompanion(treatId: Value(id), value: Value(room)));
            await _insertStamp(
              s.value - room,
              s.at,
              s.personId,
              s.contactEventId,
              null,
              s.createdAt,
            );
            room = 0;
          }
        }
        if (room <= 0) await _earn(id, time);
        return true;
      });

  /// Marks an earned treat as enjoyed.
  Future<void> markEnjoyed(String id, {DateTime? now}) =>
      (_db.update(_db.treats)..where(
            (t) => t.id.equals(id) & t.state.equalsValue(TreatState.earned),
          ))
          .write(
            TreatsCompanion(
              state: const Value(TreatState.enjoyed),
              enjoyedAt: Value(_whole(now ?? DateTime.now())),
            ),
          );

  /// Replaces all treats and stamps. For the demo database; the people
  /// and events they refer to must be there already.
  Future<void> replaceAll(List<Treat> treats, List<Stamp> stamps) =>
      _db.transaction(() async {
        await _db.delete(_db.stamps).go();
        await _db.delete(_db.treats).go();
        await _db.batch((b) {
          b.insertAll(_db.treats, treats);
          b.insertAll(_db.stamps, stamps);
        });
      });

  static final _oldestFirst = <OrderClauseGenerator<$StampsTable>>[
    (t) => OrderingTerm.asc(t.at),
    (t) => OrderingTerm.asc(t.createdAt),
    (t) => OrderingTerm.asc(t.id),
  ];

  /// drift stores whole seconds; cut here so a returned row equals the
  /// stored one.
  static DateTime _whole(DateTime t) => t.subtract(
    Duration(milliseconds: t.millisecond, microseconds: t.microsecond),
  );
}
