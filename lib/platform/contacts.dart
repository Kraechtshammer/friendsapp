import 'package:flutter_contacts/flutter_contacts.dart';

/// One entry of the phone's address book, reduced to what Kept uses.
class PhoneContact {
  const PhoneContact({
    required this.id,
    required this.name,
    this.phones = const [],
    this.birthdayMonth,
    this.birthdayDay,
    this.birthdayYear,
  });

  final String id;
  final String name;
  final List<String> phones;
  final int? birthdayMonth;
  final int? birthdayDay;
  final int? birthdayYear;
}

/// The phone's contacts, behind an interface so tests can fake them.
abstract class ContactsSource {
  /// Asks for the read-only contacts permission. False if denied.
  Future<bool> requestAccess();

  /// All contacts that have a name, sorted by name.
  Future<List<PhoneContact>> load();

  /// Opens the app settings, for when access was denied for good.
  Future<void> openSettings();
}

/// [ContactsSource] on top of `flutter_contacts` 2.x (read only).
class DeviceContacts implements ContactsSource {
  const DeviceContacts();

  @override
  Future<bool> requestAccess() async {
    final status = await FlutterContacts.permissions.request(
      PermissionType.read,
    );
    return status == PermissionStatus.granted ||
        status == PermissionStatus.limited;
  }

  @override
  Future<List<PhoneContact>> load() async {
    final contacts = await FlutterContacts.getAll(
      properties: {
        ContactProperty.name,
        ContactProperty.phone,
        ContactProperty.event,
      },
    );
    final result = <PhoneContact>[];
    for (final c in contacts) {
      final id = c.id;
      final name = c.displayName?.trim();
      if (id == null || name == null || name.isEmpty) continue;
      Event? birthday;
      for (final e in c.events) {
        if (e.label.label == EventLabel.birthday) {
          birthday = e;
          break;
        }
      }
      final year = birthday?.year;
      result.add(
        PhoneContact(
          id: id,
          name: name,
          phones: [
            for (final p in c.phones)
              if (p.number.trim().isNotEmpty) p.number.trim(),
          ],
          birthdayMonth: birthday?.month,
          birthdayDay: birthday?.day,
          // Some address books store a dummy year when it is unknown.
          birthdayYear: year != null && year >= 1900 ? year : null,
        ),
      );
    }
    result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return result;
  }

  @override
  Future<void> openSettings() => FlutterContacts.permissions.openSettings();
}
