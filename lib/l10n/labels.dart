import '../domain/greeting.dart';
import '../domain/intention.dart';
import '../domain/person.dart';
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
  IntentionKind.meet => KeptIcons.mountain,
  // TODO(M3): own game icon
  IntentionKind.game => KeptIcons.mountain,
};
