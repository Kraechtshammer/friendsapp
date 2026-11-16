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
  String messengerNotOpened(String messenger) {
    return '$messenger konnte nicht geöffnet werden.';
  }

  @override
  String get addPersonTitle => 'Person hinzufügen';

  @override
  String get editPersonTitle => 'Person bearbeiten';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get save => 'Speichern';

  @override
  String get editLook => 'Aussehen';

  @override
  String get editName => 'Name';

  @override
  String get nameHint => 'Wie heißt die Person?';

  @override
  String get editClass => 'Gruppe';

  @override
  String get reconnectingHint =>
      'Für Leute, bei denen du dich wieder melden möchtest.';

  @override
  String get editMessenger => 'Haupt-Messenger';

  @override
  String get messengerNone => 'Keiner';

  @override
  String get editReach => 'So erreichst du sie';

  @override
  String get phoneNumber => 'Telefonnummer';

  @override
  String get phoneHint => '+49…';

  @override
  String get telegramUsername => 'Telegram-Nutzername';

  @override
  String get signalLink => 'Signal-Link';

  @override
  String get discordUserId => 'Discord-Nutzer-ID';

  @override
  String get birthday => 'Geburtstag';

  @override
  String get birthdayDay => 'Tag';

  @override
  String get birthdayMonthField => 'Monat';

  @override
  String get birthdayYearOptional => 'Jahr (optional)';

  @override
  String get birthdayError =>
      'Gib einen echten Tag und Monat ein oder lass alle drei leer.';

  @override
  String get notesHint => 'Alles, was du dir merken willst';

  @override
  String get removePerson => 'Diese Person entfernen';

  @override
  String removeTitle(String name) {
    return '$name entfernen?';
  }

  @override
  String get removeBody =>
      'Der Eintrag und die Notizen werden gelöscht. Das lässt sich nicht rückgängig machen.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get remove => 'Entfernen';

  @override
  String get addMenuContacts => 'Aus deinen Kontakten';

  @override
  String get addMenuByHand => 'Von Hand';

  @override
  String get addFromContacts => 'Aus Kontakten hinzufügen';

  @override
  String get addByHand => 'Von Hand hinzufügen';

  @override
  String get importPickTitle => 'Mit wem willst du in Kontakt bleiben?';

  @override
  String get importPickHint =>
      'Ein paar reichen. Mehr kannst du später hinzufügen.';

  @override
  String get importSearchHint => 'Suchen';

  @override
  String get importDenied =>
      'Kept muss deine Kontakte lesen, um sie hier anzubieten. Nichts verlässt dein Handy.';

  @override
  String get importNoContacts => 'Keine Kontakte zum Anzeigen.';

  @override
  String get importLoadError => 'Deine Kontakte konnten nicht gelesen werden.';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String importNext(int count) {
    return 'Weiter ($count)';
  }

  @override
  String get importClassTitle => 'Wie nah seid ihr euch?';

  @override
  String get importMessengerAll => 'Haupt-Messenger für alle';

  @override
  String importAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen hinzufügen',
      one: '1 Person hinzufügen',
    );
    return '$_temp0';
  }

  @override
  String get greetingMorning => 'Guten Morgen';

  @override
  String get greetingDay => 'Hallo';

  @override
  String get greetingEvening => 'Guten Abend';

  @override
  String get captureTitle => 'Wer geht dir durch den Kopf?';

  @override
  String get captureHint => 'Boulder-Video gesehen…';

  @override
  String get captureMore => 'Mehr';

  @override
  String get kindWrite => 'Schreiben';

  @override
  String get kindCall => 'Anrufen';

  @override
  String get kindMeet => 'Treffen';

  @override
  String get kindGame => 'Zocken';

  @override
  String captureSave(String name) {
    return 'Für $name speichern';
  }

  @override
  String captureSaved(String name) {
    return 'Für $name gespeichert.';
  }

  @override
  String get captureNoPeople =>
      'Füge zuerst die Menschen hinzu, mit denen du in Kontakt bleiben willst.';

  @override
  String get captureAddPeople => 'Menschen hinzufügen';

  @override
  String get onYourMind => 'Gerade im Kopf';

  @override
  String get pickerSearchHint => 'Menschen suchen';

  @override
  String get pickerNoMatch => 'Niemand gefunden.';

  @override
  String get done => 'Erledigt';

  @override
  String get drop => 'Loslassen';

  @override
  String get shortcutCapture => 'Gedanken festhalten';

  @override
  String get niceOneTitle => 'Stark!';

  @override
  String get niceOneSubtitle => 'Das zählt.';

  @override
  String get activityLabel => 'Was habt ihr gemacht?';

  @override
  String get nextTimeLabel => 'Eine Zeile für nächstes Mal?';

  @override
  String get nextTimeHint => 'neuer Job im März';

  @override
  String get remindMe => 'Erinnere mich';

  @override
  String get remindMeHelp => 'Hält die Zeile außerdem als offenen Gedanken.';

  @override
  String get niceOneClose => 'Schließen';

  @override
  String lastTime(String note) {
    return 'Letztes Mal: $note';
  }

  @override
  String get eveningQuestion => 'Hast du heute zehn Minuten für jemanden?';

  @override
  String get eveningYes => 'Ja';

  @override
  String get eveningNotToday => 'Heute nicht';

  @override
  String get eveningChannel => 'Abendfrage';

  @override
  String get settingsEvening => 'Abendfrage';

  @override
  String get settingsEveningSwitch => 'Frag mich am Abend';

  @override
  String get settingsEveningTime => 'Uhrzeit';

  @override
  String get settingsEveningDays => 'Tage';

  @override
  String get settingsNotificationsOff =>
      'Benachrichtigungen sind für Kept aus.';

  @override
  String get settingsOpenNotificationSettings => 'Benachrichtigungen öffnen';
}
