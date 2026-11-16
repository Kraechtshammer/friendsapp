import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/foundation.dart';

import '../data/contact_events_repository.dart';
import '../data/database.dart';
import '../data/database_connection.dart';
import '../data/day_answers_repository.dart';
import '../data/ideas_repository.dart';
import '../data/intentions_repository.dart';
import '../data/people_repository.dart';
import '../data/treats_repository.dart';
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
       _realIntentions = IntentionsRepository(db),
       _realTreats = TreatsRepository(db),
       _realDayAnswers = DayAnswersRepository(db),
       _realIdeas = IdeasRepository(db) {
    _realContactEvents = ContactEventsRepository(
      db,
      loadSettings: settings.load,
    );
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
  late final ContactEventsRepository _realContactEvents;
  final TreatsRepository _realTreats;
  final DayAnswersRepository _realDayAnswers;
  final IdeasRepository _realIdeas;
  AppDatabase? _demoDb;
  IdeasRepository? _demoIdeas;
  PeopleRepository? _demoPeople;
  IntentionsRepository? _demoIntentions;
  ContactEventsRepository? _demoContactEvents;
  DayAnswersRepository? _demoDayAnswers;
  TreatsRepository? _demoTreats;

  /// Opens the real database file. Can't throw: the database opens lazily,
  /// so a broken file only shows up in later queries and the app still
  /// opens (as in akai-timetrack).
  static Future<AppServices> create() async {
    final services = AppServices(
      db: openAppDatabase(),
      openDemo: openDemoDatabase,
    );
    try {
      await services.settings.fixFamilyStampWeight();
    } catch (e) {
      debugPrint('Family stamp weight not fixed: ${e.runtimeType}');
    }
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

  /// The contact events of the same content database as [peopleFor].
  ContactEventsRepository contactEventsFor({required bool demo}) =>
      demo && allowDemo
      ? _demoContactEvents ??= ContactEventsRepository(
          _demoDatabase(),
          // The weights are settings, and settings are in the real database.
          loadSettings: settings.load,
        )
      : _realContactEvents;

  /// The treats and stamps of the same content database as [peopleFor].
  TreatsRepository treatsFor({required bool demo}) => demo && allowDemo
      ? _demoTreats ??= TreatsRepository(_demoDatabase())
      : _realTreats;

  /// The day answers of the same content database as [peopleFor].
  DayAnswersRepository dayAnswersFor({required bool demo}) => demo && allowDemo
      ? _demoDayAnswers ??= DayAnswersRepository(_demoDatabase())
      : _realDayAnswers;

  /// The ideas of the same content database as [peopleFor].
  IdeasRepository ideasFor({required bool demo}) => demo && allowDemo
      ? _demoIdeas ??= IdeasRepository(_demoDatabase())
      : _realIdeas;

  /// The picture paths of the ideas in the real database and, with
  /// [demo] on (and allowed), the demo one. For the start-up cleanup of
  /// `shared/`.
  Future<List<String>> ideaPicturePaths({required bool demo}) async => [
    ...await _realIdeas.imagePaths(),
    if (demo && allowDemo) ...await ideasFor(demo: true).imagePaths(),
  ];

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
        await contactEventsFor(demo: true).replaceAll(demoContactEvents(day));
        await dayAnswersFor(demo: true).replaceAll(demoDayAnswers(day));
        await ideasFor(demo: true).replaceAll(demoIdeas(day));
        await _seedDemoTreats(day);
      });
    }
    await settings.update((s) => s.copyWith(demoMode: on));
  }

  /// The demo treats: the default list in English, the first one a small
  /// card that the demo history fills (earned), the sixth (a day trip) the
  /// current card, partly filled by the rest. Uses the rule and the real settings
  /// like the real database does, so the demo shows what the app does.
  Future<void> _seedDemoTreats(DateTime day) async {
    final treats = treatsFor(demo: true);
    await treats.replaceAll(const [], const []);
    final names = demoTreatNames();
    await treats.insertDefaults(names, now: day);
    final all = await treats.watchAll().first;
    await treats.setStampsNeeded(all[0].id, demoFirstCardStamps);
    await treats.setCurrent(all[0].id, now: day);
    await treats.backfill(await settings.load(), now: day);
    await treats.setCurrent(all[5].id, now: day);
  }

  /// Prepares the stamps of the real database once, in one
  /// transaction with the two flags in the settings, so it cannot run
  /// twice: first the default treats ([defaultTreats], names in the
  /// language of the app now; all waiting), then the stamp rule over the
  /// contact events that exist (the backfill). Never touches the demo
  /// database. Does nothing if both are done.
  Future<void> ensureStampsReady(
    List<(String, int)> defaultTreats, {
    DateTime? now,
  }) => db.transaction(() async {
    final current = await settings.load();
    if (current.defaultTreatsInserted && current.stampsBackfilled) return;
    if (!current.defaultTreatsInserted) {
      await _realTreats.insertDefaults(defaultTreats, now: now);
    }
    if (!current.stampsBackfilled) {
      await _realTreats.backfill(current, now: now);
    }
    await settings.update(
      (s) => s.copyWith(defaultTreatsInserted: true, stampsBackfilled: true),
    );
  });

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
