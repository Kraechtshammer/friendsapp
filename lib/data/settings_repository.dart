import 'package:flutter/foundation.dart' show mapEquals;

import 'app_settings.dart';
import '../domain/stamps.dart';
import 'database.dart';

/// Reads and writes [AppSettings] in the settings table.
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  Future<AppSettings> load() async =>
      AppSettings.fromMap(_toMap(await _db.select(_db.settings).get()));

  Stream<AppSettings> watch() => _db
      .select(_db.settings)
      .watch()
      // Status entries change often and are no settings: they must not
      // rebuild the screens.
      .map((rows) => _toMap(rows)..removeWhere((k, _) => k.startsWith(_status)))
      .distinct(mapEquals)
      .map(AppSettings.fromMap);

  /// Applies [change] to the current settings and saves the result.
  Future<AppSettings> update(AppSettings Function(AppSettings) change) {
    // Load inside the transaction, so two quick updates can't lose one.
    return _db.transaction(() async {
      final next = change(await load());
      for (final MapEntry(:key, :value) in next.toMap().entries) {
        if (value == null) {
          await (_db.delete(
            _db.settings,
          )..where((s) => s.key.equals(key))).go();
        } else {
          await _db
              .into(_db.settings)
              .insertOnConflictUpdate(
                SettingsCompanion.insert(key: key, value: value),
              );
        }
      }
      return next;
    });
  }

  /// Once: older builds stored the Family stamp weight as 1 on every save,
  /// also when the user never changed it. Family counts 2 now, so a stored
  /// 1 is removed and the start value applies. Remembered in the settings.
  Future<void> fixFamilyStampWeight() => update((s) {
    if (s.familyWeightFixed) return s;
    final weights = s.stampWeights;
    return s.copyWith(
      familyWeightFixed: true,
      // A weight equal to its start value is not stored (see AppSettings).
      stampWeights: weights.family == 1
          ? weights.copyWith(family: const StampWeights().family)
          : null,
    );
  });

  /// Status entries of the in-app update (02-design.md §8): the time of the
  /// last check, the version the popup was shown for, the version that ran
  /// last (for "What's new") and the cached notes. Stored in the settings
  /// table under keys starting with `status.`, outside [AppSettings].
  static const lastUpdateCheck = '${_status}lastUpdateCheck';
  static const updatePopupShown = '${_status}updatePopupShown';
  static const lastRunVersion = '${_status}lastRunVersion';
  static const whatsNew = '${_status}whatsNew';
  static const _status = 'status.';

  /// A status entry; null if not stored.
  Future<String?> status(String key) async => (await (_db.select(
    _db.settings,
  )..where((s) => s.key.equals(key))).getSingleOrNull())?.value;

  Future<void> setStatus(String key, String value) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));

  Map<String, String> _toMap(List<SettingEntry> rows) => {
    for (final row in rows) row.key: row.value,
  };
}
