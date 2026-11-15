import 'dart:io';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'database.dart';

const _realName = 'kept';
const _demoName = 'kept_demo';

/// The real database file: settings and the user's own data.
AppDatabase openAppDatabase() => _open(_realName);

/// The demo database file, for development builds (02-design.md §8).
AppDatabase openDemoDatabase() => _open(_demoName);

AppDatabase _open(String name) => AppDatabase(
  driftDatabase(
    name: name,
    // Later the notification buttons run in a background isolate; sharing
    // one connection keeps the screens up to date (as in akai-timetrack).
    native: const DriftNativeOptions(shareAcrossIsolates: true),
  ),
);

/// Deletes the demo database file. Only call it while the demo database is
/// not open. drift_flutter keeps files as `<documents>/<name>.sqlite`.
Future<void> deleteDemoDatabaseFile() async {
  final dir = await getApplicationDocumentsDirectory();
  for (final suffix in ['', '-wal', '-shm', '-journal']) {
    final file = File('${dir.path}/$_demoName.sqlite$suffix');
    if (await file.exists()) await file.delete();
  }
}
