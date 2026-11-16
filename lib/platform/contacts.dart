import 'dart:typed_data';

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
    this.photo,
  });

  final String id;
  final String name;
  final List<String> phones;
  final int? birthdayMonth;
  final int? birthdayDay;
  final int? birthdayYear;

  /// The contact's picture as raw bytes (full size, else thumbnail), in
  /// whatever format the address book holds. Only filled when asked for.
  final Uint8List? photo;
}

/// The phone's contacts, behind an interface so tests can fake them.
abstract class ContactsSource {
  /// Asks for the read-only contacts permission. False if denied.
  Future<bool> requestAccess();

  /// Whether the read permission is granted now. Never asks.
  Future<bool> hasAccess();

  /// All contacts that have a name, sorted by name. Pictures are large, so
  /// [PhoneContact.photo] is only filled with [withPhotos].
  Future<List<PhoneContact>> load({bool withPhotos = false});

  /// The picture of one contact (full size, else thumbnail), or null if it
  /// has none, access is missing or anything fails.
  Future<Uint8List?> photoFor(String contactId);

  /// Opens the app settings, for when access was denied for good.
  Future<void> openSettings();

  /// The display name of every contact, by contact id. Never asks for
  /// access: without it, or on any error, the map is empty.
  Future<Map<String, String>> displayNames();
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
  Future<bool> hasAccess() async {
    try {
      return await FlutterContacts.permissions.has(PermissionType.read);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<PhoneContact>> load({bool withPhotos = false}) async {
    final contacts = await FlutterContacts.getAll(
      properties: {
        ContactProperty.name,
        ContactProperty.phone,
        ContactProperty.event,
        if (withPhotos) ...{
          ContactProperty.photoThumbnail,
          ContactProperty.photoFullRes,
        },
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
          photo: withPhotos ? _photoBytes(c.photo) : null,
        ),
      );
    }
    result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return result;
  }

  @override
  Future<Uint8List?> photoFor(String contactId) async {
    try {
      final c = await FlutterContacts.get(
        contactId,
        properties: {
          ContactProperty.photoThumbnail,
          ContactProperty.photoFullRes,
        },
      );
      return _photoBytes(c?.photo);
    } catch (_) {
      return null;
    }
  }

  static Uint8List? _photoBytes(Photo? p) {
    final full = p?.fullSize;
    if (full != null && full.isNotEmpty) return full;
    final thumb = p?.thumbnail;
    return thumb != null && thumb.isNotEmpty ? thumb : null;
  }

  @override
  Future<void> openSettings() => FlutterContacts.permissions.openSettings();

  @override
  Future<Map<String, String>> displayNames() async {
    try {
      if (!await FlutterContacts.permissions.has(PermissionType.read)) {
        return const {};
      }
      final contacts = await FlutterContacts.getAll(
        properties: {ContactProperty.name},
      );
      return {
        for (final c in contacts)
          if (c.id case final id?)
            if (c.displayName?.trim() case final name? when name.isNotEmpty)
              id: name,
      };
    } catch (_) {
      return const {};
    }
  }
}
