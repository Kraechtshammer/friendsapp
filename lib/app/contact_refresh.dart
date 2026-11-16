import '../data/database.dart' show Person;
import '../domain/contact_refresh.dart';
import '../platform/contacts.dart';

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
