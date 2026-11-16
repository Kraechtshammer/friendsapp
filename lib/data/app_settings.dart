import 'package:flutter/foundation.dart' show setEquals;

/// Dark, light or as the phone says.
enum AppThemeMode { system, light, dark }

/// How many open items Home offers for tonight (02-design.md §2.3).
enum OpenItemsMode { one, three }

/// All settings, with their defaults. Stored as text in the settings table
/// of the real database (02-design.md §3).
class AppSettings {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.demoMode = false,
    this.eveningOn = true,
    this.eveningMinute = defaultEveningMinute,
    this.eveningExcludedDays = const {},
    this.notificationPermissionAsked = false,
    this.openItems = OpenItemsMode.one,
  });

  /// 19:00, as minutes after midnight.
  static const defaultEveningMinute = 19 * 60;

  final AppThemeMode themeMode;

  /// Development builds only: people come from the demo database
  /// (02-design.md §8). The real data is not touched.
  final bool demoMode;

  /// The evening question (02-design.md §2.2) is asked.
  final bool eveningOn;

  /// When the evening question comes, in minutes after local midnight.
  final int eveningMinute;

  /// Weekdays without the evening question, numbered as in [DateTime]
  /// (Monday 1 to Sunday 7).
  final Set<int> eveningExcludedDays;

  /// The app has asked for the notification permission once. It does not
  /// ask again by itself; switching the evening question on asks again.
  final bool notificationPermissionAsked;

  /// One item with "Another one" (the start value) or a list of three.
  final OpenItemsMode openItems;

  /// Reads settings from the stored key-value pairs. Unknown or broken
  /// values fall back to the defaults.
  factory AppSettings.fromMap(Map<String, String> m) {
    const d = AppSettings();
    T pick<T extends Enum>(List<T> values, String key, T fallback) =>
        values.asNameMap()[m[key]] ?? fallback;
    bool flag(String key, bool fallback) => switch (m[key]) {
      'true' => true,
      'false' => false,
      _ => fallback,
    };
    return AppSettings(
      themeMode: pick(AppThemeMode.values, 'themeMode', d.themeMode),
      demoMode: m['demoMode'] == 'true',
      eveningOn: flag('eveningOn', d.eveningOn),
      eveningMinute: _parseTime(m['eveningTime']) ?? d.eveningMinute,
      eveningExcludedDays: _parseDays(m['eveningExcludedDays']),
      notificationPermissionAsked: m['notificationPermissionAsked'] == 'true',
      openItems: pick(OpenItemsMode.values, 'openItems', d.openItems),
    );
  }

  /// The stored form. A null value removes the key.
  Map<String, String?> toMap() => {
    'themeMode': themeMode.name,
    'demoMode': '$demoMode',
    'eveningOn': '$eveningOn',
    'eveningTime': _formatTime(eveningMinute),
    'eveningExcludedDays': (eveningExcludedDays.toList()..sort()).join(','),
    'notificationPermissionAsked': '$notificationPermissionAsked',
    'openItems': openItems.name,
  };

  AppSettings copyWith({
    AppThemeMode? themeMode,
    bool? demoMode,
    bool? eveningOn,
    int? eveningMinute,
    Set<int>? eveningExcludedDays,
    bool? notificationPermissionAsked,
    OpenItemsMode? openItems,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    demoMode: demoMode ?? this.demoMode,
    eveningOn: eveningOn ?? this.eveningOn,
    eveningMinute: eveningMinute ?? this.eveningMinute,
    eveningExcludedDays: eveningExcludedDays ?? this.eveningExcludedDays,
    notificationPermissionAsked:
        notificationPermissionAsked ?? this.notificationPermissionAsked,
    openItems: openItems ?? this.openItems,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.themeMode == themeMode &&
      other.demoMode == demoMode &&
      other.eveningOn == eveningOn &&
      other.eveningMinute == eveningMinute &&
      setEquals(other.eveningExcludedDays, eveningExcludedDays) &&
      other.notificationPermissionAsked == notificationPermissionAsked &&
      other.openItems == openItems;

  @override
  int get hashCode => Object.hash(
    themeMode,
    demoMode,
    eveningOn,
    eveningMinute,
    Object.hashAllUnordered(eveningExcludedDays),
    notificationPermissionAsked,
    openItems,
  );
}

/// "HH:MM", 24 hours.
String _formatTime(int minute) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(minute ~/ 60)}:${two(minute % 60)}';
}

int? _parseTime(String? text) {
  final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(text ?? '');
  if (match == null) return null;
  final hour = int.parse(match[1]!);
  final minute = int.parse(match[2]!);
  if (hour > 23 || minute > 59) return null;
  return hour * 60 + minute;
}

/// "6,7"; anything that is not a weekday number is left out.
Set<int> _parseDays(String? text) => {
  for (final part in (text ?? '').split(','))
    if (int.tryParse(part.trim()) case final d?
        when d >= DateTime.monday && d <= DateTime.sunday)
      d,
};
