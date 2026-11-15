/// Dark, light or as the phone says.
enum AppThemeMode { system, light, dark }

/// All settings, with their defaults. Stored as text in the settings table
/// of the real database (02-design.md §3).
class AppSettings {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.demoMode = false,
  });

  final AppThemeMode themeMode;

  /// Development builds only: people come from the demo database
  /// (02-design.md §8). The real data is not touched.
  final bool demoMode;

  /// Reads settings from the stored key-value pairs. Unknown or broken
  /// values fall back to the defaults.
  factory AppSettings.fromMap(Map<String, String> m) {
    const d = AppSettings();
    T pick<T extends Enum>(List<T> values, String key, T fallback) =>
        values.asNameMap()[m[key]] ?? fallback;
    return AppSettings(
      themeMode: pick(AppThemeMode.values, 'themeMode', d.themeMode),
      demoMode: m['demoMode'] == 'true',
    );
  }

  /// The stored form. A null value removes the key.
  Map<String, String?> toMap() => {
    'themeMode': themeMode.name,
    'demoMode': '$demoMode',
  };

  AppSettings copyWith({AppThemeMode? themeMode, bool? demoMode}) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        demoMode: demoMode ?? this.demoMode,
      );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.themeMode == themeMode &&
      other.demoMode == demoMode;

  @override
  int get hashCode => Object.hash(themeMode, demoMode);
}
