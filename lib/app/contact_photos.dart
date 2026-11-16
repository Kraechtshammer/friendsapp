import '../data/database.dart' show Person;
import '../data/people_repository.dart';
import '../platform/contacts.dart';
import '../platform/photo_store.dart';

/// Reads the picture of contact [contactId] and stores it with the centre
/// crop (no crop screen). Null when the contact has no picture or anything
/// fails: a missing picture is never an error for the caller.
Future<String?> storeContactPhoto(
  ContactsSource contacts,
  PhotoStore store,
  String contactId,
) async {
  try {
    final bytes = await contacts.photoFor(contactId);
    if (bytes == null || bytes.isEmpty) return null;
    return await store.saveSquare(bytes);
  } on Object {
    return null;
  }
}

/// The one-time catch-up (02-design.md §8, 2026-11-16): gives every person
/// who is linked to a contact and has no picture the contact's picture.
/// Returns how many were added. Contacts are read one by one, so only the
/// people who need one cost anything. Without contacts access nothing
/// happens and the result is 0.
Future<int> fillMissingPictures({
  required List<Person> people,
  required PeopleRepository repo,
  required ContactsSource contacts,
  required PhotoStore store,
}) async {
  try {
    if (!await contacts.hasAccess()) return 0;
  } on Object {
    return 0;
  }
  var added = 0;
  for (final p in people) {
    final contactId = p.contactId;
    if (contactId == null || p.photo != null) continue;
    final name = await storeContactPhoto(contacts, store, contactId);
    if (name == null) continue;
    await repo.setPhoto(p.id, name);
    added++;
  }
  return added;
}
