import 'package:kept/platform/contacts.dart';

/// [ContactsSource] without the platform. [contacts] is the address book.
class FakeContacts implements ContactsSource {
  FakeContacts(this.contacts, {this.granted = true});

  List<PhoneContact> contacts;

  /// What [hasAccess] and [requestAccess] say.
  bool granted;

  var settingsOpened = 0;
  var requests = 0;

  @override
  Future<bool> hasAccess() async => granted;

  @override
  Future<bool> requestAccess() async {
    requests++;
    return granted;
  }

  @override
  Future<List<PhoneContact>> load() async => contacts;

  @override
  Future<void> openSettings() async => settingsOpened++;

  @override
  Future<Map<String, String>> displayNames() async => {
    for (final c in contacts) c.id: c.name,
  };
}
