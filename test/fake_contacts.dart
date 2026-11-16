import 'dart:typed_data';

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
  Future<List<PhoneContact>> load({bool withPhotos = false}) async => [
    for (final c in contacts)
      if (withPhotos || c.photo == null)
        c
      else
        PhoneContact(
          id: c.id,
          name: c.name,
          phones: c.phones,
          birthdayMonth: c.birthdayMonth,
          birthdayDay: c.birthdayDay,
          birthdayYear: c.birthdayYear,
        ),
  ];

  @override
  Future<Uint8List?> photoFor(String contactId) async {
    for (final c in contacts) {
      if (c.id == contactId) return c.photo;
    }
    return null;
  }

  @override
  Future<void> openSettings() async => settingsOpened++;

  @override
  Future<Map<String, String>> displayNames() async => {
    for (final c in contacts) c.id: c.name,
  };
}
