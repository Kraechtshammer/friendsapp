import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/data/app_settings.dart';
import 'package:kept/data/database.dart';
import 'package:kept/data/settings_repository.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SettingsRepository(db);
  });
  tearDown(() => db.close());

  test('an empty database gives the defaults', () async {
    final settings = await repo.load();
    expect(settings.themeMode, AppThemeMode.system);
    expect(settings.demoMode, isFalse);
    expect(await repo.watch().first, const AppSettings());
  });

  test('theme mode and demo mode are stored', () async {
    await repo.update((s) => s.copyWith(themeMode: AppThemeMode.dark));
    await repo.update((s) => s.copyWith(demoMode: true));
    final settings = await repo.load();
    expect(settings.themeMode, AppThemeMode.dark);
    expect(settings.demoMode, isTrue);
    expect(await repo.watch().first, settings);

    await repo.update(
      (s) => s.copyWith(themeMode: AppThemeMode.light, demoMode: false),
    );
    expect(await repo.load(), const AppSettings(themeMode: AppThemeMode.light));
  });

  test('broken values fall back to the defaults', () {
    final settings = AppSettings.fromMap({
      'themeMode': 'purple',
      'demoMode': 'maybe',
    });
    expect(settings, const AppSettings());
  });
}
