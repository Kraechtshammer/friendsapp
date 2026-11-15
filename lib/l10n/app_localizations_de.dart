// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Kept.';

  @override
  String get tabHome => 'Start';

  @override
  String get tabUpcoming => 'Demnächst';

  @override
  String get tabPeople => 'Leute';

  @override
  String get tabProgress => 'Fortschritt';

  @override
  String get settings => 'Einstellungen';

  @override
  String get settingsTheme => 'Design';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get nothingHereYet => 'Hier ist noch nichts.';

  @override
  String get peopleTitle => 'Deine Leute';

  @override
  String get peopleEmpty => 'Hier erscheinen bald deine Leute.';

  @override
  String get peopleError => 'Deine Leute konnten nicht geladen werden.';

  @override
  String get personError => 'Diese Person konnte nicht geladen werden.';

  @override
  String get closenessClose => 'Eng befreundet';

  @override
  String get closenessCloseGroup => 'Eng befreundet';

  @override
  String get closenessNowAndThen => 'Ab und zu';

  @override
  String get closenessFewTimesAYear => 'Ein paar Mal im Jahr';

  @override
  String get closenessFamily => 'Familie';

  @override
  String get reconnecting => 'Wieder in Kontakt kommen';

  @override
  String get messengerWhatsapp => 'WhatsApp';

  @override
  String get messengerTelegram => 'Telegram';

  @override
  String get messengerSignal => 'Signal';

  @override
  String get messengerDiscord => 'Discord';

  @override
  String openMessenger(String messenger) {
    return '$messenger öffnen';
  }

  @override
  String birthdayDayMonth(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat(
      'd. MMMM',
      localeName,
    );
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String birthdayFull(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat(
      'd. MMMM y',
      localeName,
    );
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get notes => 'Notizen';

  @override
  String get comingSoon => 'Kommt bald';
}
