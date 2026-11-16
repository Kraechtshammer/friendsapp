import 'package:flutter/foundation.dart' show mapEquals, setEquals;

import '../domain/birthdays.dart';
import '../domain/owed_reply.dart';
import '../domain/person.dart';
import '../domain/rhythm.dart';
import '../domain/stamps.dart';

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
    this.ownBirthday,
    this.incomingOn = false,
    this.replyWaitDays = defaultReplyWaitDays,
    this.classRhythms = defaultClassRhythms,
    this.reconnectPersonId,
    this.reconnectWeek,
    this.backInTouchAnswered = const {},
    this.stampWeights = const StampWeights(),
    this.defaultTreatsInserted = false,
    this.stampsBackfilled = false,
  });

  /// The shortest and longest waiting time for owed replies, in days.
  static const minReplyWaitDays = 1;
  static const maxReplyWaitDays = 14;

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

  /// The user's own birthday (02-design.md §8, birthdays M4); null when not
  /// set. Stored as `MM-DD` or `YYYY-MM-DD` under `ownBirthday`.
  final Birthday? ownBirthday;

  /// The optional notification listener records who wrote or called
  /// (02-design.md §2.6, M7). Off at start.
  final bool incomingOn;

  /// Days after an incoming message before a reply counts as owed.
  final int replyWaitDays;

  /// The rhythm of each class in days; null is no rhythm (02-design.md
  /// §6.9). Stored as `rhythm_<class>`: a number of days, or `none`.
  final Map<Closeness, int?> classRhythms;

  /// The class's rhythm; null is none.
  int? rhythmOf(Closeness closeness) => classRhythms[closeness];

  /// The person the user chose to get back in touch with, and the Monday
  /// (local midnight) of the week they chose them (01-research.md §9.8,
  /// F13). Both null when nobody is chosen. A week that has passed counts
  /// as nobody ([reconnectWeekState]).
  final String? reconnectPersonId;
  final DateTime? reconnectWeek;

  /// People whose "You and X are back in touch" card was answered, so it
  /// does not come back.
  final Set<String> backInTouchAnswered;

  /// The weights of the stamp rule and the default card size (02-design.md
  /// §6.10, M9). Stored as `stamp*` keys.
  final StampWeights stampWeights;

  /// The default treats were put into the real database once (M9). Never
  /// put back, so a treat the user deleted stays gone.
  final bool defaultTreatsInserted;

  /// The stamp rule was run over the existing contact events once (M9).
  final bool stampsBackfilled;

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
    int ranged(String key, int fallback, int min, int max) =>
        switch (int.tryParse(m[key] ?? '')) {
          final v? when v >= min && v <= max => v,
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
      ownBirthday: Birthday.parse(m['ownBirthday']),
      incomingOn: flag('incomingOn', d.incomingOn),
      replyWaitDays: switch (int.tryParse(m['replyWaitDays'] ?? '')) {
        final v? when v >= minReplyWaitDays && v <= maxReplyWaitDays => v,
        _ => d.replyWaitDays,
      },
      classRhythms: {
        for (final c in Closeness.values)
          c: switch (m['rhythm_${c.name}']) {
            'none' => null,
            final v? when _validRhythm(int.tryParse(v)) => int.parse(v),
            _ => defaultClassRhythms[c],
          },
      },
      reconnectPersonId: _parseDay(m['reconnectWeek']) == null
          ? null
          : m['reconnectPerson'],
      reconnectWeek: _parseDay(m['reconnectWeek']),
      backInTouchAnswered: {
        for (final id in (m['backInTouchAnswered'] ?? '').split(','))
          if (id.trim().isNotEmpty) id.trim(),
      },
      stampWeights: StampWeights(
        close: ranged(
          'stampClose',
          d.stampWeights.close,
          StampWeights.minClass,
          StampWeights.maxClass,
        ),
        nowAndThen: ranged(
          'stampNowAndThen',
          d.stampWeights.nowAndThen,
          StampWeights.minClass,
          StampWeights.maxClass,
        ),
        fewTimesAYear: ranged(
          'stampFewTimesAYear',
          d.stampWeights.fewTimesAYear,
          StampWeights.minClass,
          StampWeights.maxClass,
        ),
        family: ranged(
          'stampFamily',
          d.stampWeights.family,
          StampWeights.minClass,
          StampWeights.maxClass,
        ),
        backInTouchBonus: ranged(
          'stampBackInTouch',
          d.stampWeights.backInTouchBonus,
          StampWeights.minBonus,
          StampWeights.maxBonus,
        ),
        longGapBonus: ranged(
          'stampLongGap',
          d.stampWeights.longGapBonus,
          StampWeights.minBonus,
          StampWeights.maxBonus,
        ),
        meetMultiplier: ranged(
          'stampMeet',
          d.stampWeights.meetMultiplier,
          StampWeights.minMultiplier,
          StampWeights.maxMultiplier,
        ),
        gameMultiplier: ranged(
          'stampGame',
          d.stampWeights.gameMultiplier,
          StampWeights.minMultiplier,
          StampWeights.maxMultiplier,
        ),
        cardSize: ranged(
          'stampCardSize',
          d.stampWeights.cardSize,
          StampWeights.minCardSize,
          StampWeights.maxCardSize,
        ),
      ),
      defaultTreatsInserted: m['defaultTreatsInserted'] == 'true',
      stampsBackfilled: m['stampsBackfilled'] == 'true',
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
    'ownBirthday': ownBirthday?.format(),
    'incomingOn': '$incomingOn',
    'replyWaitDays': '$replyWaitDays',
    for (final c in Closeness.values)
      'rhythm_${c.name}': classRhythms[c]?.toString() ?? 'none',
    'reconnectPerson': reconnectPersonId,
    'reconnectWeek': reconnectWeek == null ? null : _formatDay(reconnectWeek!),
    'backInTouchAnswered': (backInTouchAnswered.toList()..sort()).join(','),
    'stampClose': '${stampWeights.close}',
    'stampNowAndThen': '${stampWeights.nowAndThen}',
    'stampFewTimesAYear': '${stampWeights.fewTimesAYear}',
    'stampFamily': '${stampWeights.family}',
    'stampBackInTouch': '${stampWeights.backInTouchBonus}',
    'stampLongGap': '${stampWeights.longGapBonus}',
    'stampMeet': '${stampWeights.meetMultiplier}',
    'stampGame': '${stampWeights.gameMultiplier}',
    'stampCardSize': '${stampWeights.cardSize}',
    'defaultTreatsInserted': '$defaultTreatsInserted',
    'stampsBackfilled': '$stampsBackfilled',
  };

  AppSettings copyWith({
    AppThemeMode? themeMode,
    bool? demoMode,
    bool? eveningOn,
    int? eveningMinute,
    Set<int>? eveningExcludedDays,
    bool? notificationPermissionAsked,
    OpenItemsMode? openItems,
    bool? incomingOn,
    int? replyWaitDays,
    Map<Closeness, int?>? classRhythms,
    Set<String>? backInTouchAnswered,
    StampWeights? stampWeights,
    bool? defaultTreatsInserted,
    bool? stampsBackfilled,
  }) => _copy(
    themeMode: themeMode,
    demoMode: demoMode,
    eveningOn: eveningOn,
    eveningMinute: eveningMinute,
    eveningExcludedDays: eveningExcludedDays,
    notificationPermissionAsked: notificationPermissionAsked,
    openItems: openItems,
    incomingOn: incomingOn,
    replyWaitDays: replyWaitDays,
    classRhythms: classRhythms,
    backInTouchAnswered: backInTouchAnswered,
    stampWeights: stampWeights,
    defaultTreatsInserted: defaultTreatsInserted,
    stampsBackfilled: stampsBackfilled,
  );

  /// A copy with [birthday] as the user's own birthday; null clears it.
  AppSettings withOwnBirthday(Birthday? birthday) =>
      _copy(ownBirthday: birthday);

  /// A copy with [personId] as the reconnect person of the week that
  /// starts on [week] (a Monday); both null clears the choice.
  AppSettings withReconnectOfWeek(String? personId, DateTime? week) =>
      _copy(reconnectPersonId: personId, reconnectWeek: week);

  /// A copy with [classRhythms] changed for one class; null days is none.
  AppSettings withClassRhythm(Closeness closeness, int? days) =>
      copyWith(classRhythms: {...classRhythms, closeness: days});

  /// Nullable fields are replaced with whatever is passed, even null,
  /// unless left out ([_keep]).
  AppSettings _copy({
    AppThemeMode? themeMode,
    bool? demoMode,
    bool? eveningOn,
    int? eveningMinute,
    Set<int>? eveningExcludedDays,
    bool? notificationPermissionAsked,
    OpenItemsMode? openItems,
    Object? ownBirthday = _keep,
    bool? incomingOn,
    int? replyWaitDays,
    Map<Closeness, int?>? classRhythms,
    Object? reconnectPersonId = _keep,
    Object? reconnectWeek = _keep,
    Set<String>? backInTouchAnswered,
    StampWeights? stampWeights,
    bool? defaultTreatsInserted,
    bool? stampsBackfilled,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    demoMode: demoMode ?? this.demoMode,
    eveningOn: eveningOn ?? this.eveningOn,
    eveningMinute: eveningMinute ?? this.eveningMinute,
    eveningExcludedDays: eveningExcludedDays ?? this.eveningExcludedDays,
    notificationPermissionAsked:
        notificationPermissionAsked ?? this.notificationPermissionAsked,
    openItems: openItems ?? this.openItems,
    ownBirthday: identical(ownBirthday, _keep)
        ? this.ownBirthday
        : ownBirthday as Birthday?,
    incomingOn: incomingOn ?? this.incomingOn,
    replyWaitDays: replyWaitDays ?? this.replyWaitDays,
    classRhythms: classRhythms ?? this.classRhythms,
    reconnectPersonId: identical(reconnectPersonId, _keep)
        ? this.reconnectPersonId
        : reconnectPersonId as String?,
    reconnectWeek: identical(reconnectWeek, _keep)
        ? this.reconnectWeek
        : reconnectWeek as DateTime?,
    backInTouchAnswered: backInTouchAnswered ?? this.backInTouchAnswered,
    stampWeights: stampWeights ?? this.stampWeights,
    defaultTreatsInserted: defaultTreatsInserted ?? this.defaultTreatsInserted,
    stampsBackfilled: stampsBackfilled ?? this.stampsBackfilled,
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
      other.openItems == openItems &&
      other.ownBirthday == ownBirthday &&
      other.incomingOn == incomingOn &&
      other.replyWaitDays == replyWaitDays &&
      mapEquals(other.classRhythms, classRhythms) &&
      other.reconnectPersonId == reconnectPersonId &&
      other.reconnectWeek == reconnectWeek &&
      setEquals(other.backInTouchAnswered, backInTouchAnswered) &&
      other.stampWeights == stampWeights &&
      other.defaultTreatsInserted == defaultTreatsInserted &&
      other.stampsBackfilled == stampsBackfilled;

  @override
  int get hashCode => Object.hash(
    themeMode,
    demoMode,
    eveningOn,
    eveningMinute,
    Object.hashAllUnordered(eveningExcludedDays),
    notificationPermissionAsked,
    openItems,
    ownBirthday,
    incomingOn,
    replyWaitDays,
    Object.hashAll([for (final c in Closeness.values) classRhythms[c]]),
    reconnectPersonId,
    reconnectWeek,
    Object.hashAllUnordered(backInTouchAnswered),
    stampWeights,
    defaultTreatsInserted,
    stampsBackfilled,
  );
}

const _keep = Object();

bool _validRhythm(int? days) => days != null && days >= 1 && days <= 3650;

/// "YYYY-MM-DD".
String _formatDay(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year.toString().padLeft(4, '0')}-${two(d.month)}-${two(d.day)}';
}

/// A stored "YYYY-MM-DD" as local midnight; null if it is not one.
DateTime? _parseDay(String? text) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text ?? '');
  if (m == null) return null;
  final y = int.parse(m[1]!), mo = int.parse(m[2]!), d = int.parse(m[3]!);
  final day = DateTime(y, mo, d);
  return day.month == mo && day.day == d ? day : null;
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
