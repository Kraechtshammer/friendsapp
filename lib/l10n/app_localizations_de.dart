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

  @override
  String get settingsOpenItems => 'Offene Punkte';

  @override
  String get settingsOpenItemsHelp =>
      'Wie viele Ideen Home für heute Abend zeigt.';

  @override
  String get openItemsOne => 'Einer';

  @override
  String get openItemsThree => 'Drei';

  @override
  String get tonightsPick => 'Heute Abend dran';

  @override
  String get anotherOne => 'Eine andere';

  @override
  String chatQuestionWrite(String name) {
    return 'Hast du $name geschrieben?';
  }

  @override
  String chatQuestionCall(String name) {
    return 'Hast du $name angerufen?';
  }

  @override
  String chatQuestionMeet(String name) {
    return 'Hast du $name getroffen?';
  }

  @override
  String chatQuestionGame(String name) {
    return 'Hast du mit $name gezockt?';
  }

  @override
  String chatQuestionOpened(String messenger) {
    return 'Du hast gerade $messenger geöffnet.';
  }

  @override
  String get chatQuestionYes => 'Ja';

  @override
  String get chatQuestionNotYet => 'Noch nicht';

  @override
  String get chatQuestionHint =>
      'Noch nicht ist in Ordnung. Nichts ist überfällig.';

  @override
  String get congratulated => 'Gratuliert';

  @override
  String get birthdayToday => 'Hat heute Geburtstag';

  @override
  String birthdayTurns(int age) {
    return 'Wird heute $age';
  }

  @override
  String chatQuestionBirthday(String name) {
    return 'Hast du $name gratuliert?';
  }

  @override
  String birthdayNotification(String name) {
    return '$name hat heute Geburtstag. Schon gratuliert?';
  }

  @override
  String birthdayLateNotification(String name) {
    return '$name hat nur noch eine Stunde Geburtstag';
  }

  @override
  String get birthdayLateNotificationBody => 'Schon gratuliert?';

  @override
  String get birthdayYes => 'Ja';

  @override
  String get birthdayOpenChat => 'Chat öffnen';

  @override
  String get birthdayChannel => 'Geburtstage';

  @override
  String get congratulatedTitle => 'Wer hat dir gratuliert?';

  @override
  String get congratulatedToday => 'Alles Gute zum Geburtstag!';

  @override
  String congratulatedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat(
      'd. MMMM',
      localeName,
    );
    final String dateString = dateDateFormat.format(date);

    return 'Dein Geburtstag am $dateString';
  }

  @override
  String get ownBirthdayCardHint =>
      'Alles Gute! Halte fest, wer dir gratuliert hat.';

  @override
  String get settingsOwnBirthday => 'Dein Geburtstag';

  @override
  String get settingsOwnBirthdayNotSet => 'Nicht eingetragen';

  @override
  String get whenDate => 'Datum';

  @override
  String get whenSoon => 'Bald';

  @override
  String get whenLater => 'Später';

  @override
  String get whenCondition => 'Wenn…';

  @override
  String get whenAddTime => 'Uhrzeit';

  @override
  String get whenSection => 'Wann';

  @override
  String get whenConditionHint => 'wenn es wieder warm ist';

  @override
  String get editThought => 'Gedanke bearbeiten';

  @override
  String dateWeekday(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat('EEE', localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String dateDayNumber(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.d(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String dateShort(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat(
      'EEE, d. MMM',
      localeName,
    );
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String monthLabel(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMM(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String monthYearLabel(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat(
      'MMMM y',
      localeName,
    );
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String timeShort(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.jm(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get upcomingTitle => 'Demnächst';

  @override
  String get upcomingSubtitle =>
      'Geburtstage und Termine, die du gesetzt hast. Hier ist nie etwas überfällig.';

  @override
  String get upcomingEmpty =>
      'Noch nichts mit Datum. Geburtstage und Termine, die du setzt, erscheinen hier.';

  @override
  String get groupThisWeek => 'Diese Woche';

  @override
  String get groupNextWeek => 'Nächste Woche';

  @override
  String birthdayOf(String name) {
    return 'Geburtstag von $name';
  }

  @override
  String turnsAge(int age) {
    return 'Wird $age';
  }

  @override
  String get noDateYet => 'Noch kein Datum';

  @override
  String get pickADate => 'Datum wählen';

  @override
  String get comingUp => 'Demnächst';

  @override
  String get seeAll => 'Alle ansehen';

  @override
  String get didItHappen => 'Hat es geklappt?';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String wantSetDate(String name) {
    return 'Möchtest du ein Datum mit $name festlegen?';
  }

  @override
  String get setADate => 'Datum festlegen';

  @override
  String get timelineToday => 'Heute';

  @override
  String get youWrote => 'Du hast geschrieben';

  @override
  String theyWrote(String name) {
    return '$name hat geschrieben';
  }

  @override
  String get youCalled => 'Du hast angerufen';

  @override
  String theyCalled(String name) {
    return '$name hat angerufen';
  }

  @override
  String get youMet => 'Ihr habt euch getroffen';

  @override
  String get youGamed => 'Ihr habt zusammen gezockt';

  @override
  String get addedToYourPeople => 'Zu deinen Leuten hinzugefügt';

  @override
  String get youCongratulated => 'Du hast gratuliert';

  @override
  String get yourBirthday => 'Dein Geburtstag';

  @override
  String congratulatedYou(String name) {
    return '$name hat dir gratuliert';
  }

  @override
  String get buttonTheyWrote => 'Hat geschrieben';

  @override
  String get buttonTheyCalled => 'Hat angerufen';

  @override
  String notedTheyWrote(String name) {
    return 'Notiert: $name hat geschrieben';
  }

  @override
  String notedTheyCalled(String name) {
    return 'Notiert: $name hat angerufen';
  }

  @override
  String get alreadyNoted => 'Heute schon notiert';

  @override
  String get undo => 'Rückgängig';

  @override
  String get editEntry => 'Eintrag bearbeiten';

  @override
  String get entryActivity => 'Aktivität';

  @override
  String get entryNote => 'Notiz fürs nächste Mal';

  @override
  String get deleteEntry => 'Diesen Eintrag löschen';

  @override
  String get deleteEntryTitle => 'Diesen Eintrag löschen?';

  @override
  String get deleteEntryBody => 'Er verschwindet aus dem Verlauf.';

  @override
  String get delete => 'Löschen';

  @override
  String dateDayMonth(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat('d MMM', localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String dateDayMonthYear(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat(
      'd MMM yy',
      localeName,
    );
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String stillOweReply(String name) {
    return 'Schuldest du $name noch eine Antwort?';
  }

  @override
  String get alreadyAnswered => 'Schon geantwortet';

  @override
  String get settingsIncoming => 'Eingehende Nachrichten';

  @override
  String get settingsIncomingSwitch =>
      'Merken, wer geschrieben oder angerufen hat';

  @override
  String get settingsIncomingHelp =>
      'Kept liest die Benachrichtigungen von WhatsApp, Telegram, Signal und Discord, um zu sehen, wer von deinen Leuten dir geschrieben oder dich angerufen hat und wann. Was geschrieben wurde, liest Kept nie. Gruppenchats und alle anderen bleiben außen vor.';

  @override
  String get settingsIncomingAccess => 'Zugriff auf Benachrichtigungen';

  @override
  String get settingsIncomingAccessOn => 'Erlaubt';

  @override
  String get settingsIncomingAccessOff => 'Noch nicht erlaubt';

  @override
  String get settingsIncomingOpenAccess =>
      'Zugriff auf Benachrichtigungen öffnen';

  @override
  String get settingsReplyWait => 'Nach einer Antwort fragen nach';

  @override
  String replyWaitDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage',
      one: '1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get shorter => 'Kürzer';

  @override
  String get longer => 'Länger';
}
