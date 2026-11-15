import 'package:flutter/foundation.dart' show mapEquals;

import 'app_settings.dart';
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
      .map(_toMap)
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

  Map<String, String> _toMap(List<SettingEntry> rows) => {
    for (final row in rows) row.key: row.value,
  };
}
