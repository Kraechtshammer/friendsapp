// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kept.';

  @override
  String get tabHome => 'Home';

  @override
  String get tabUpcoming => 'Upcoming';

  @override
  String get tabPeople => 'People';

  @override
  String get tabProgress => 'Progress';

  @override
  String get settings => 'Settings';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get nothingHereYet => 'Nothing here yet.';

  @override
  String get peopleTitle => 'Your people';

  @override
  String get peopleEmpty => 'Your people will show up here.';

  @override
  String get peopleError => 'Your people could not be loaded.';

  @override
  String get personError => 'This person could not be loaded.';

  @override
  String get closenessClose => 'Close friend';

  @override
  String get closenessCloseGroup => 'Close friends';

  @override
  String get closenessNowAndThen => 'Now and then';

  @override
  String get closenessFewTimesAYear => 'A few times a year';

  @override
  String get closenessFamily => 'Family';

  @override
  String get reconnecting => 'Getting back in touch';

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
    return 'Open $messenger';
  }

  @override
  String birthdayDayMonth(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat(
      'd MMMM',
      localeName,
    );
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String birthdayFull(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat(
      'd MMMM y',
      localeName,
    );
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get notes => 'Notes';

  @override
  String get comingSoon => 'Coming soon';
}
