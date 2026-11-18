import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:kept/domain/chat_link.dart';
import 'package:kept/domain/contact_route.dart';
import 'package:kept/platform/app_shortcuts.dart';
import 'package:kept/platform/chat_opener.dart';
import 'package:kept/platform/contact_entries.dart';
import 'package:kept/platform/installed_apps.dart';

/// [AppShortcuts] that does nothing.
class NoShortcuts implements AppShortcuts {
  @override
  Future<void> setUp({
    required String captureTitle,
    required VoidCallback onCapture,
  }) async {}
}

/// [ChatOpener] that records the links. [result] is what [open] returns.
class FakeChatOpener implements ChatOpener {
  final opened = <ChatLink>[];
  bool result = true;

  @override
  Future<bool> open(ChatLink link) async {
    opened.add(link);
    return result;
  }
}

/// [ContactEntries] with fixed [entries] per contact id; records what was
/// opened. [result] is what [open] returns.
class FakeContactEntries implements ContactEntries {
  final entries = <String, List<ContactEntry>>{};
  final asked = <String>[];
  final opened = <ContactEntry>[];
  bool result = true;

  @override
  Future<List<ContactEntry>> entriesOf(String contactId) async {
    asked.add(contactId);
    return entries[contactId] ?? const [];
  }

  @override
  Future<bool> open(ContactEntry entry) async {
    opened.add(entry);
    return result;
  }
}

/// [InstalledApps] that answers [apps]; everything by default.
class FakeInstalledApps implements InstalledApps {
  InstalledChatApps apps = InstalledChatApps.all;

  @override
  Future<InstalledChatApps> chatApps() async => apps;
}
