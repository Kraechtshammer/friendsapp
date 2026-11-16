import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/foundation.dart';

import '../data/database.dart';
import '../data/database_connection.dart';
import '../data/intentions_repository.dart';
import '../data/people_repository.dart';
import '../data/settings_repository.dart';
import '../domain/demo_data.dart';

/// Everything the app works with, created once in main().
///
/// There are two databases (02-design.md §8, demo data). [db] is the real
/// one: it always holds the settings, and the user's own people. The demo
/// database holds invented people and is used for content only while the
/// setting `demoMode` is on, in development builds. The real content is
/// never touched in demo mode.
class AppServices {
  /// [openDemo] opens the demo database when it is first needed; tests pass
  /// in-memory databases for both. [allowDemo] is false in release builds,
  /// so a stored `demoMode` there has no effect.
  AppServices({
    required this.db,
    required this._openDemo,
    this.allowDemo = kDebugMode,
  }) : settings = SettingsRepository(db),
       _realPeople = PeopleRepository(db),
       _realIntentions = IntentionsRepository(db) {
    // Two AppDatabase instances on two files are intended here; drift
    // warns about any second instance in debug builds.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  }

  final AppDatabase db;
  final SettingsRepository settings;
  final bool allowDemo;

  final AppDatabase Function() _openDemo;
  final PeopleRepository _realPeople;
  final IntentionsRepository _realIntentions;
  AppDatabase? _demoDb;
  PeopleRepository? _demoPeople;
  IntentionsRepository? _demoIntentions;

  /// Opens the real database file. Can't throw: the database opens lazily,
  /// so a broken file only shows up in later queries and the app still
  /// opens (as in akai-timetrack).
  static Future<AppServices> create() async {
    final services = AppServices(
      db: openAppDatabase(),
      openDemo: openDemoDatabase,
    );
    try {
      // A demo file left from a session that ended with demo mode off is
      // not needed any more. Switching demo mode on fills it from scratch.
      final demo = (await services.settings.load()).demoMode;
      if (!demo || !services.allowDemo) await deleteDemoDatabaseFile();
    } catch (e, stack) {
      debugPrint('Demo database cleanup failed: $e\n$stack');
    }
    return services;
  }

  /// The people of the content database: the demo one if [demo] (and
  /// allowed), otherwise the real one. Read it through the providers,
  /// which pass the current `demoMode`.
  PeopleRepository peopleFor({required bool demo}) =>
      demo && allowDemo ? _demoRepository() : _realPeople;

  /// The intentions of the same content database as [peopleFor].
  IntentionsRepository intentionsFor({required bool demo}) =>
      demo && allowDemo ? _demoIntentionsRepository() : _realIntentions;

  /// Switches demo mode. On: the demo database is filled with the demo set
  /// (people, then their intentions) from scratch first, so the screens
  /// switch straight to it. Off: back
  /// to the real database; the demo file is deleted at the next start.
  Future<void> setDemoMode(bool on, {DateTime? today}) async {
    if (on && !allowDemo) return;
    if (on) {
      final day = today ?? DateTime.now();
      await _demoDatabase().transaction(() async {
        // Replacing the people removes their old intentions (cascade).
        await _demoRepository().replaceAll(demoPeople(day));
        await _demoIntentionsRepository().replaceAll(demoIntentions(day));
      });
    }
    await settings.update((s) => s.copyWith(demoMode: on));
  }

  AppDatabase _demoDatabase() => _demoDb ??= _openDemo();

  PeopleRepository _demoRepository() =>
      _demoPeople ??= PeopleRepository(_demoDatabase());

  IntentionsRepository _demoIntentionsRepository() =>
      _demoIntentions ??= IntentionsRepository(_demoDatabase());

  /// Closes both databases. For tests.
  Future<void> close() async {
    await _demoDb?.close();
    await db.close();
  }
}
