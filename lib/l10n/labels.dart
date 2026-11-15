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

/// Signal and Discord have no drawn icon yet; they use the chat bubble.
KeptIcons messengerIcon(Messenger messenger) => switch (messenger) {
  Messenger.whatsapp => KeptIcons.whatsapp,
  Messenger.telegram => KeptIcons.telegram,
  Messenger.signal || Messenger.discord => KeptIcons.chat,
};

/// A birthday as day and month, with the year only when it is known.
String birthdayLabel(int month, int day, int? year, AppLocalizations l10n) =>
    year == null
    // 2000 is a leap year, so 29 February works.
    ? l10n.birthdayDayMonth(DateTime(2000, month, day))
    : l10n.birthdayFull(DateTime(year, month, day));
