/// Groups of people: for now only couples (02-design.md §8, 2026-11-16).
/// The enum is stored as text by name (`textEnum`), so values can be added
/// but never renamed. Added in schema version 5.
library;

import '../data/database.dart';

/// What kind of group it is. Friend circles may follow.
enum GroupKind {
  /// Two people who are usually met together. A person is in at most one
  /// couple; a couple with fewer than two members is dissolved.
  couple,
}

/// A group with its members, in their order (`group_members.position`).
class GroupWithMembers {
  const GroupWithMembers(this.group, this.members);

  final PersonGroup group;
  final List<Person> members;

  /// The group's own name, or the members' names joined with " & ". A plain
  /// fallback until the couple UI comes.
  String get label {
    final own = group.name?.trim();
    if (own != null && own.isNotEmpty) return own;
    return members.map((p) => p.name).join(' & ');
  }
}

/// Thrown when a person who is already in a couple is put into another.
class AlreadyInCoupleException implements Exception {
  const AlreadyInCoupleException(this.personId, this.groupId);

  final String personId;

  /// The couple the person is in.
  final String groupId;

  @override
  String toString() =>
      'AlreadyInCoupleException: person $personId is already in couple '
      '$groupId';
}
