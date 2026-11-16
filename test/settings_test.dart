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

  test('the evening question starts on, at 19:00, every day', () async {
    final settings = await repo.load();
    expect(settings.eveningOn, isTrue);
    expect(settings.eveningMinute, 19 * 60);
    expect(settings.eveningExcludedDays, isEmpty);
    expect(settings.notificationPermissionAsked, isFalse);
  });

  test('the evening question settings are stored', () async {
    await repo.update(
      (s) => s.copyWith(
        eveningOn: false,
        eveningMinute: 20 * 60 + 30,
        eveningExcludedDays: {7, 6},
        notificationPermissionAsked: true,
      ),
    );
    final settings = await repo.load();
    expect(settings.eveningOn, isFalse);
    expect(settings.eveningMinute, 20 * 60 + 30);
    expect(settings.eveningExcludedDays, {6, 7});
    expect(settings.notificationPermissionAsked, isTrue);
    expect(settings.toMap()['eveningTime'], '20:30');
    expect(settings.toMap()['eveningExcludedDays'], '6,7');
    expect(await repo.watch().first, settings);

    await repo.update(
      (s) => s.copyWith(eveningOn: true, eveningExcludedDays: {}),
    );
    final back = await repo.load();
    expect(back.eveningOn, isTrue);
    expect(back.eveningExcludedDays, isEmpty);
    expect(back.eveningMinute, 20 * 60 + 30);
  });

  test('broken evening values fall back to the defaults', () {
    final settings = AppSettings.fromMap({
      'eveningOn': 'perhaps',
      'eveningTime': '25:00',
      'eveningExcludedDays': '0,3,x,8, 6',
    });
    expect(settings.eveningOn, isTrue);
    expect(settings.eveningMinute, 19 * 60);
    expect(settings.eveningExcludedDays, {3, 6});
  });
}
