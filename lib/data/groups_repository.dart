import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/group.dart';
import 'database.dart';
import 'whole_seconds.dart';

/// Reads and writes the groups of one database: the real one or, in demo
/// mode, the demo one (AppServices.groupsFor). For now a group is a couple
/// (GroupKind.couple; 02-design.md §8, 2026-11-16).
///
/// Rules kept here: a person is in at most one couple, and a couple with
/// fewer than two members is dissolved. Dissolving moves the couple's
/// intentions to its first remaining member, so no thought is lost; the
/// contact events keep their rows (their `groupId` is cleared, `sharedId`
/// still ties them together).
class GroupsRepository {
  GroupsRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// All couples with their members in order, oldest couple first.
  Stream<List<GroupWithMembers>> watchCouples() =>
      _membersQuery(_db.groups.kind.equalsValue(GroupKind.couple))
          .watch()
          .map(_collect);

  /// The couple [personId] is in; null if none.
  Stream<GroupWithMembers?> watchCoupleOf(String personId) =>
      watchCouples().map(
        (all) => all
            .where((c) => c.members.any((p) => p.id == personId))
            .firstOrNull,
      );

  /// The members of group [groupId] in order; empty once it is gone.
  Stream<List<Person>> watchMembers(String groupId) =>
      _membersQuery(_db.groups.id.equals(groupId))
          .watch()
          .map((rows) => [for (final r in rows) r.readTable(_db.people)]);

  /// The members of group [groupId] in order.
  Future<List<Person>> members(String groupId) =>
      _membersQuery(_db.groups.id.equals(groupId))
          .get()
          .then((rows) => [for (final r in rows) r.readTable(_db.people)]);

  /// The couple [personId] is in, with its members; null if none.
  Future<GroupWithMembers?> coupleOf(String personId) async {
    final groupId = await _coupleIdOf(personId);
    if (groupId == null) return null;
    final rows = await _membersQuery(_db.groups.id.equals(groupId)).get();
    return _collect(rows).firstOrNull;
  }

  /// Makes [firstId] and [secondId] a couple, in that order. [name] null
  /// means the members' names are shown. Throws an [ArgumentError] for the
  /// same person twice and an [AlreadyInCoupleException] if either is in a
  /// couple already. [now] is for tests.
  Future<PersonGroup> createCouple(
    String firstId,
    String secondId, {
    String? name,
    DateTime? now,
  }) {
    if (firstId == secondId) {
      throw ArgumentError('A couple needs two different people: $firstId');
    }
    return _db.transaction(() async {
      for (final personId in [firstId, secondId]) {
        final existing = await _coupleIdOf(personId);
        if (existing != null) {
          throw AlreadyInCoupleException(personId, existing);
        }
      }
      final group = PersonGroup(
        id: _uuid.v4(),
        kind: GroupKind.couple,
        name: name,
        createdAt: wholeSeconds(now ?? DateTime.now()),
      );
      await _db.into(_db.groups).insert(group);
      await _db.batch(
        (b) => b.insertAll(_db.groupMembers, [
          GroupMember(groupId: group.id, personId: firstId, position: 0),
          GroupMember(groupId: group.id, personId: secondId, position: 1),
        ]),
      );
      return group;
    });
  }

  /// Ends group [groupId] in one transaction: its intentions move to the
  /// first remaining member (with none left they are deleted with the
  /// group), its contact events stay on every timeline without the group,
  /// and the memberships go.
  Future<void> dissolve(String groupId) => _db.transaction(() async {
    final members = await this.members(groupId);
    if (members.isNotEmpty) {
      await (_db.update(
        _db.intentions,
      )..where((t) => t.groupId.equals(groupId))).write(
        IntentionsCompanion(
          personId: Value(members.first.id),
          groupId: const Value(null),
        ),
      );
    }
    await (_db.delete(_db.groups)..where((t) => t.id.equals(groupId))).go();
  });

  /// The ids of the couples [personId] is in. For PeopleRepository.delete,
  /// which calls [dissolveIfTooSmall] with them after the person is gone.
  Future<List<String>> groupIdsOf(String personId) =>
      (_db.selectOnly(_db.groupMembers)
            ..addColumns([_db.groupMembers.groupId])
            ..where(_db.groupMembers.personId.equals(personId)))
          .map((r) => r.read(_db.groupMembers.groupId)!)
          .get();

  /// Dissolves each of [groupIds] that is a couple with fewer than two
  /// members left. Call it inside the transaction that removed a member.
  Future<void> dissolveIfTooSmall(Iterable<String> groupIds) =>
      _db.transaction(() async {
        for (final id in groupIds) {
          final group = await (_db.select(
            _db.groups,
          )..where((t) => t.id.equals(id))).getSingleOrNull();
          if (group == null || group.kind != GroupKind.couple) continue;
          if ((await members(id)).length < 2) await dissolve(id);
        }
      });

  /// Removes every group. For the demo database, before its people are
  /// replaced.
  Future<void> deleteAll() => _db.delete(_db.groups).go();

  Future<String?> _coupleIdOf(String personId) async {
    final row =
        await (_db.select(_db.groupMembers).join([
                innerJoin(
                  _db.groups,
                  _db.groups.id.equalsExp(_db.groupMembers.groupId),
                ),
              ])
              ..where(
                _db.groupMembers.personId.equals(personId) &
                    _db.groups.kind.equalsValue(GroupKind.couple),
              )
              ..limit(1))
            .getSingleOrNull();
    return row?.readTable(_db.groupMembers).groupId;
  }

  JoinedSelectStatement<HasResultSet, dynamic> _membersQuery(
    Expression<bool> where,
  ) =>
      _db.select(_db.groups).join([
          innerJoin(
            _db.groupMembers,
            _db.groupMembers.groupId.equalsExp(_db.groups.id),
          ),
          innerJoin(
            _db.people,
            _db.people.id.equalsExp(_db.groupMembers.personId),
          ),
        ])
        ..where(where)
        ..orderBy([
          OrderingTerm.asc(_db.groups.createdAt),
          OrderingTerm.asc(_db.groups.id),
          OrderingTerm.asc(_db.groupMembers.position),
        ]);

  List<GroupWithMembers> _collect(List<TypedResult> rows) {
    final groups = <String, PersonGroup>{};
    final members = <String, List<Person>>{};
    for (final r in rows) {
      final group = r.readTable(_db.groups);
      groups[group.id] = group;
      (members[group.id] ??= []).add(r.readTable(_db.people));
    }
    return [
      for (final e in groups.entries)
        GroupWithMembers(e.value, members[e.key]!),
    ];
  }
}
