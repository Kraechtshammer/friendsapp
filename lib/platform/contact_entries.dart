import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../domain/contact_route.dart';

/// Reads and opens the ways to reach a person that their phone contact
/// holds (02-design.md §8, 2026-11-18). Behind an interface so tests can
/// fake it. Native side: ContactEntriesChannel.kt.
abstract class ContactEntries {
  /// The contact's messenger and Website entries; empty if there are none
  /// or the contact cannot be read.
  Future<List<ContactEntry>> entriesOf(String contactId);

  /// Opens the chat behind [entry]. False if nothing answered.
  Future<bool> open(ContactEntry entry);
}

/// [ContactEntries] over the method channel `de.gartenpa.kept/contactEntries`.
class AndroidContactEntries implements ContactEntries {
  const AndroidContactEntries();

  static const _channel = MethodChannel('de.gartenpa.kept/contactEntries');

  @override
  Future<List<ContactEntry>> entriesOf(String contactId) async {
    try {
      final rows = await _channel.invokeListMethod<Map<Object?, Object?>>(
        'entries',
        {'contactId': contactId},
      );
      return [
        for (final r in rows ?? const <Map<Object?, Object?>>[])
          ContactEntry(
            id: '${r['id']}',
            mimeType: '${r['mimeType']}',
            value: r['value'] as String?,
            label: r['label'] as String?,
          ),
      ];
    } catch (e) {
      // No permission, no contact, or no channel (tests): no entries.
      debugPrint('Contact entries not read: ${e.runtimeType}');
      return const [];
    }
  }

  @override
  Future<bool> open(ContactEntry entry) async {
    try {
      return await _channel.invokeMethod<bool>('open', {
            'id': entry.id,
            'mimeType': entry.mimeType,
          }) ??
          false;
    } catch (e) {
      return false;
    }
  }
}
