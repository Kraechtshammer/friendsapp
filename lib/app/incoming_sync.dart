import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_settings.dart';
import '../data/contact_events_repository.dart';
import '../data/database.dart';
import '../domain/contact_event.dart';
import '../domain/incoming_contact.dart';
import '../platform/contacts.dart';
import 'providers.dart';

/// Incoming contact (02-design.md §2.6 and §6.9): keeps the optional
/// notification listener in step with the app. Optional part and a build
/// flag (lib/app/build_flags.dart); without it the listener is a no-op.
///
/// HomeShell calls [onSettings] when the settings change, [onPeople] when
/// the real people change and [onResume] when the app comes back. On: the
/// listener records, its watch list follows the real people, and its queue
/// is turned into contact events in the real database (also in demo mode,
/// like the answers from notifications). Off: the listener records nothing
/// and forgets its watch list and queue.
class IncomingSync {
  IncomingSync(this._ref);

  final WidgetRef _ref;

  /// The switch as last sent to the listener; null before the first time.
  bool? _applied;

  bool get _on => _applied ?? false;

  void onSettings(AppSettings settings) {
    if (settings.incomingOn == _applied) return;
    _applied = settings.incomingOn;
    unawaited(
      _guard(() async {
        final listener = _ref.read(incomingListenerProvider);
        await listener.setEnabled(settings.incomingOn);
        if (!settings.incomingOn) return;
        await _writeWatchList();
        await _import();
      }),
    );
  }

  void onPeople() {
    if (_on) unawaited(_guard(_writeWatchList));
  }

  void onResume() {
    if (_on) unawaited(_guard(_import));
  }

  Future<void> _writeWatchList() async {
    final people = _ref.read(realPeopleProvider).value;
    if (people == null) return; // Comes again once they are loaded.
    final list = await watchListFor(people, _ref.read(contactsSourceProvider));
    if (!_on) return; // Switched off meanwhile.
    await _ref.read(incomingListenerProvider).setWatchList(list);
  }

  Future<void> _import() async {
    final services = _ref.read(servicesProvider);
    final entries = await _ref.read(incomingListenerProvider).takeQueue();
    if (entries.isEmpty) return;
    final people = await services.peopleFor(demo: false).watchAll().first;
    await importIncoming(
      entries,
      personIds: {for (final p in people) p.id},
      events: services.contactEventsFor(demo: false),
    );
  }

  static Future<void> _guard(Future<void> Function() work) async {
    try {
      await work();
    } catch (e) {
      // No names or ids: the error type only.
      debugPrint('Incoming contact sync failed: ${e.runtimeType}');
    }
  }
}

/// The watch list for [people]: their names, plus the current display name
/// of a linked phone contact. The contacts are read only if someone is
/// linked, and never ask for access ([ContactsSource.displayNames]).
Future<List<WatchEntry>> watchListFor(
  List<Person> people,
  ContactsSource contacts,
) async {
  final linked = people.any((p) => p.contactId != null);
  final names = linked
      ? await contacts.displayNames()
      : const <String, String>{};
  return buildWatchList(people, names);
}

/// Turns the listener's [entries] into contact events "they wrote" or "they
/// called" (direction byThem, source listener) at the notification's time,
/// at most one per person, kind and local day, also counting ones entered
/// by hand. Entries of people not in [personIds] are skipped. Returns how
/// many events were added.
Future<int> importIncoming(
  List<IncomingEntry> entries, {
  required Set<String> personIds,
  required ContactEventsRepository events,
}) async {
  var added = 0;
  for (final e in entries) {
    if (!personIds.contains(e.personId)) continue;
    final event = await events.addByThemOnce(
      personId: e.personId,
      kind: e.kind,
      at: e.at,
      source: ContactSource.listener,
    );
    if (event != null) added++;
  }
  return added;
}
