import '../domain/greeting.dart';
import '../domain/idea.dart';
import '../domain/intention.dart';
import '../domain/person.dart';
import '../domain/reconnect_week.dart';
import '../domain/rhythm.dart';
import '../domain/treat.dart';
import '../ui/kept_icon.dart';
import 'app_localizations.dart';

/// Translated names for enum values.

/// The class of one person, as on their tag ("Close friend").
String closenessLabel(Closeness closeness, AppLocalizations l10n) =>
    switch (closeness) {
      Closeness.close => l10n.closenessClose,
      Closeness.nowAndThen => l10n.closenessNowAndThen,
      Closeness.fewTimesAYear => l10n.closenessFewTimesAYear,
      Closeness.family => l10n.closenessFamily,
    };

/// The class as a group heading on the People tab ("Close friends").
String closenessGroupLabel(Closeness closeness, AppLocalizations l10n) =>
    switch (closeness) {
      Closeness.close => l10n.closenessCloseGroup,
      _ => closenessLabel(closeness, l10n),
    };

String messengerLabel(Messenger messenger, AppLocalizations l10n) =>
    switch (messenger) {
      Messenger.whatsapp => l10n.messengerWhatsapp,
      Messenger.telegram => l10n.messengerTelegram,
      Messenger.signal => l10n.messengerSignal,
      Messenger.discord => l10n.messengerDiscord,
    };

/// The class as an icon: a plant that grows with the class, and a house for
/// family (02-design.md §8). Used on the avatar badge and the group headers.
KeptIcons closenessIcon(Closeness closeness) => switch (closeness) {
  Closeness.close => KeptIcons.flower,
  Closeness.nowAndThen => KeptIcons.bud,
  Closeness.fewTimesAYear => KeptIcons.sprout,
  Closeness.family => KeptIcons.cottage,
};

KeptIcons messengerIcon(Messenger messenger) => switch (messenger) {
  Messenger.whatsapp => KeptIcons.whatsapp,
  Messenger.telegram => KeptIcons.telegram,
  Messenger.signal => KeptIcons.signal,
  Messenger.discord => KeptIcons.discord,
};

/// A birthday as day and month, with the year only when it is known.
String birthdayLabel(int month, int day, int? year, AppLocalizations l10n) =>
    year == null
    // 2000 is a leap year, so 29 February works.
    ? l10n.birthdayDayMonth(DateTime(2000, month, day))
    : l10n.birthdayFull(DateTime(year, month, day));

String greetingLabel(Greeting greeting, AppLocalizations l10n) =>
    switch (greeting) {
      Greeting.morning => l10n.greetingMorning,
      Greeting.day => l10n.greetingDay,
      Greeting.evening => l10n.greetingEvening,
    };

String kindLabel(IntentionKind kind, AppLocalizations l10n) => switch (kind) {
  IntentionKind.write => l10n.kindWrite,
  IntentionKind.call => l10n.kindCall,
  IntentionKind.meet => l10n.kindMeet,
  IntentionKind.game => l10n.kindGame,
};

KeptIcons kindIcon(IntentionKind kind) => switch (kind) {
  IntentionKind.write => KeptIcons.chat,
  IntentionKind.call => KeptIcons.phone,
  IntentionKind.meet => KeptIcons.people,
  IntentionKind.game => KeptIcons.controller,
};

/// The kind of an idea, as a group heading and a chip ("Do together").
String ideaKindLabel(IdeaKind kind, AppLocalizations l10n) => switch (kind) {
  IdeaKind.toDo => l10n.ideaToDo,
  IdeaKind.toTalk => l10n.ideaToTalk,
};

/// Doing together has the meet-up's icon, talking the chat bubble.
KeptIcons ideaKindIcon(IdeaKind kind) => switch (kind) {
  IdeaKind.toDo => KeptIcons.people,
  IdeaKind.toTalk => KeptIcons.chat,
};

String horizonLabel(Horizon horizon, AppLocalizations l10n) =>
    switch (horizon) {
      Horizon.soon => l10n.whenSoon,
      Horizon.later => l10n.whenLater,
      Horizon.whenCondition => l10n.whenCondition,
    };

/// The "when" as one short line: "Sat 21 Nov · 11:00" (no time for a day
/// without one), "Soon", "Later", or the condition the user wrote ("when
/// it is warm again"). Empty for no "when".
String whenText(When when, AppLocalizations l10n) {
  final date = when.date;
  if (date != null) {
    return [
      l10n.dateShort(date),
      if (when.hasTime) l10n.timeShort(date),
    ].join(' · ');
  }
  return switch (when.horizon) {
    null => '',
    Horizon.whenCondition =>
      (when.condition?.trim().isNotEmpty ?? false)
          ? when.condition!.trim()
          : l10n.whenCondition,
    final h => horizonLabel(h, l10n),
  };
}

/// "This month: Anna": the reconnect person with the words of the span.
String reconnectTitle(ReconnectSpan span, String name, AppLocalizations l10n) =>
    switch (span) {
      ReconnectSpan.week => l10n.reconnectThisWeek(name),
      ReconnectSpan.twoWeeks => l10n.reconnectTwoWeeks(name),
      ReconnectSpan.month => l10n.reconnectThisMonth(name),
      ReconnectSpan.twoMonths => l10n.reconnectTwoMonths(name),
      ReconnectSpan.threeMonths => l10n.reconnectThreeMonths(name),
    };

/// The length of a reconnect span as text ("2 weeks", "1 month").
String reconnectSpanLabel(ReconnectSpan span, AppLocalizations l10n) =>
    span.months > 0
    ? l10n.rhythmMonths(span.months)
    : l10n.rhythmWeeks(span.days ~/ 7);

/// A rhythm span as text: weeks up to 8 weeks, months from 3 months on
/// ([rhythmMonths]), and plain days for a value that is neither (an own
/// rhythm set by an older version or by hand).
String rhythmLabel(int days, AppLocalizations l10n) {
  if (rhythmSpans.contains(days)) {
    return days >= 90
        ? l10n.rhythmMonths(rhythmMonths(days))
        : l10n.rhythmWeeks(days ~/ 7);
  }
  return l10n.rhythmDaysCount(days);
}

/// The twelve default treats with their stamp numbers, named in the
/// language of [l10n]. They are stored that way when first inserted
/// (02-design.md §6.9, §6.10).
List<(String, int)> defaultTreatNames(AppLocalizations l10n) {
  final names = [
    l10n.defaultTreat1,
    l10n.defaultTreat2,
    l10n.defaultTreat3,
    l10n.defaultTreat4,
    l10n.defaultTreat5,
    l10n.defaultTreat6,
    l10n.defaultTreat7,
    l10n.defaultTreat8,
    l10n.defaultTreat9,
    l10n.defaultTreat10,
    l10n.defaultTreat11,
    l10n.defaultTreat12,
  ];
  return [for (final (i, n) in names.indexed) (n, defaultTreatStamps[i])];
}
