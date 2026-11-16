import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/avatar_pick.dart';
import '../domain/person.dart';
import 'database.dart';

/// Reads and writes the people of one database: the real one or, in demo
/// mode, the demo one (AppServices.peopleFor). See docs/02-design.md §3.
class PeopleRepository {
  PeopleRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// Everyone, ordered by name without regard to case.
  Stream<List<Person>> watchAll() =>
      (_db.select(_db.people)..orderBy([
            (t) => OrderingTerm(expression: t.name.lower()),
            (t) => OrderingTerm(expression: t.id),
          ]))
          .watch();

  /// One person; null once deleted.
  Stream<Person?> watch(String id) => (_db.select(
    _db.people,
  )..where((t) => t.id.equals(id))).watchSingleOrNull();

  /// Adds a person with a new id and an avatar that differs from the
  /// others (domain/avatar_pick.dart). [now] is for tests.
  Future<Person> add({
    required String name,
    required Closeness closeness,
    String? contactId,
    bool reconnecting = false,
    int? rhythmDays,
    Messenger? mainMessenger,
    String? phone,
    String? telegramUsername,
    String? signalLink,
    String? discordUserId,
    int? birthdayMonth,
    int? birthdayDay,
    int? birthdayYear,
    String notes = '',
    DateTime? now,
  }) => _db.transaction(() async {
    // In the transaction, so two quick adds see each other's avatar.
    final used = await _db
        .select(_db.people)
        .map((p) => (shape: p.avatarShape, color: p.avatarColor))
        .get();
    final avatar = pickAvatar(used);
    // drift stores whole seconds; cut here so the returned person equals
    // the stored one.
    final created = now ?? DateTime.now();
    final person = Person(
      id: _uuid.v4(),
      name: name,
      contactId: contactId,
      closeness: closeness,
      reconnecting: reconnecting,
      rhythmDays: rhythmDays,
      mainMessenger: mainMessenger,
      phone: phone,
      telegramUsername: telegramUsername,
      signalLink: signalLink,
      discordUserId: discordUserId,
      birthdayMonth: birthdayMonth,
      birthdayDay: birthdayDay,
      birthdayYear: birthdayYear,
      avatarShape: avatar.shape,
      avatarColor: avatar.color,
      notes: notes,
      createdAt: created.subtract(
        Duration(
          milliseconds: created.millisecond,
          microseconds: created.microsecond,
        ),
      ),
    );
    await _db.into(_db.people).insert(person);
    return person;
  });

  /// Saves all fields of [person] (found by its id). Change fields with
  /// `person.copyWith(...)`; nullable ones take `Value(null)` to clear.
  Future<void> update(Person person) => _db.update(_db.people).replace(person);

  /// Sets only `replyClearedAt` of person [id] to [at]: "Already answered"
  /// or the chat was opened (02-design.md §2.6). Nothing else changes, so a
  /// stale copy of the person cannot overwrite newer fields.
  Future<void> setReplyClearedAt(String id, DateTime at) =>
      (_db.update(_db.people)..where((t) => t.id.equals(id))).write(
        PeopleCompanion(
          replyClearedAt: Value(
            at.subtract(
              Duration(
                milliseconds: at.millisecond,
                microseconds: at.microsecond,
              ),
            ),
          ),
        ),
      );

  Future<void> delete(String id) =>
      (_db.delete(_db.people)..where((t) => t.id.equals(id))).go();

  /// Replaces everyone with [people] in one step. For the demo database.
  Future<void> replaceAll(List<Person> people) => _db.transaction(() async {
    await _db.delete(_db.people).go();
    await _db.batch((b) => b.insertAll(_db.people, people));
  });
}
