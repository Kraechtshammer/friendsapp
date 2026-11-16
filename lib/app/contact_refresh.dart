import '../data/database.dart' show Person;
import '../data/people_repository.dart';
import '../domain/contact_refresh.dart';
import '../platform/contacts.dart';
import '../platform/photo_store.dart';

/// How a look at the phone's contacts went.
enum RefreshStatus { ok, denied, failed }

/// The outcome of [refreshPeople]: [diffs] holds only people whose contact
/// differs; [gone] counts linked people whose contact was not found.
class RefreshResult {
  const RefreshResult(this.status, {this.diffs = const [], this.gone = 0});

  final RefreshStatus status;
  final List<ContactDiff> diffs;
  final int gone;
}

/// Reads the contacts (asking for access if not yet given, since the user
/// pressed a button for it) and compares every linked person in [people].
/// Changes nothing.
Future<RefreshResult> refreshPeople(
  ContactsSource source,
  List<Person> people,
) async {
  try {
    if (!await source.requestAccess()) {
      return const RefreshResult(RefreshStatus.denied);
    }
    final contacts = {for (final c in await source.load()) c.id: c};
    // Pictures are large: ask for them one by one, and only for people who
    // have none.
    for (final p in people) {
      final contact = contacts[p.contactId];
      if (contact == null || p.photo != null) continue;
      final bytes = await source.photoFor(contact.id);
      if (bytes != null) contacts[contact.id] = contact.withPhoto(bytes);
    }
    final linked = people.where((p) => p.contactId != null);
    return RefreshResult(
      RefreshStatus.ok,
      diffs: compareAll(people, contacts),
      gone: linked.where((p) => !contacts.containsKey(p.contactId)).length,
    );
  } on Object {
    return const RefreshResult(RefreshStatus.failed);
  }
}

/// Stores what the user accepted: the picture first (centre crop), then the
/// person with all proposed values. A picture that cannot be stored is left
/// out; the rest is still applied.
Future<Person> applyContactDiff(
  PhotoStore store,
  PeopleRepository repo,
  ContactDiff diff,
) async {
  String? photoName;
  final bytes = diff.photo;
  if (bytes != null) {
    try {
      photoName = await store.saveSquare(bytes);
    } on Object {
      photoName = null;
    }
  }
  final person = diff.apply(photoName: photoName);
  await repo.update(person);
  return person;
}
