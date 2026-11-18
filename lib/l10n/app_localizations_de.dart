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
  String get tabTimeline => 'Zeitleiste';

  @override
  String get tabPeople => 'Leute';

  @override
  String get tabProgress => 'Fortschritt';

  @override
  String get settings => 'Einstellungen';

  @override
  String get settingsCatEveningLine => 'Uhrzeit, freie Tage, einer oder drei';

  @override
  String get settingsCatFriends => 'Freunde';

  @override
  String get settingsCatFriendsLine =>
      'Rhythmen, wieder in Kontakt, eingehende Nachrichten';

  @override
  String get settingsCatFriendsLineNoListener =>
      'Rhythmen, wieder in Kontakt, offene Antworten';

  @override
  String get settingsCatBirthdays => 'Geburtstage';

  @override
  String get settingsCatBirthdaysLine => 'Dein Geburtstag';

  @override
  String get settingsCatStamps => 'Stempel und Wochen in Folge';

  @override
  String get settingsCatStampsLine =>
      'Stempelwerte, Kartengröße, Regel für Wochen in Folge';

  @override
  String get settingsCatLook => 'Design';

  @override
  String get settingsCatLookLine => 'Design und Sprache';

  @override
  String get settingsCatUpdatesLine => 'Update-Suche, Was ist neu?';

  @override
  String get settingsCatAboutLine => 'Version und Lizenzen';

  @override
  String get settingsTheme => 'Design';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGerman => 'Deutsch';

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
  String get messengerSms => 'SMS';

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
  String messengerNotInstalled(String name) {
    return '$name ist auf diesem Handy nicht installiert.';
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
      'Eine kurze Liste von Leuten, bei denen du dich wieder melden möchtest. Im Leute-Tab wählst du für eine Weile eine aus. Schalte es aus, wenn ihr wieder in Kontakt seid.';

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
  String get chatTarget => 'Chat-Link, Nutzername oder ID';

  @override
  String get editMessengerFromContact => 'Aus dem Kontakt';

  @override
  String get editMessengerOthers => 'Andere Apps auf diesem Handy';

  @override
  String get chatTargetHint => '@name, ID oder https://…';

  @override
  String chatTargetUsed(String name) {
    return '„Öffnen“ führt direkt zu diesem Chat in $name.';
  }

  @override
  String chatTargetProfile(String name) {
    return '„Öffnen“ zeigt ihr Profil in $name; von dort ist der Chat einen Tipp entfernt.';
  }

  @override
  String chatTargetNotUnderstood(String name) {
    return '$name braucht hier einen vollständigen Chat-Link, der mit https:// beginnt.';
  }

  @override
  String get chatTargetViaContact =>
      'Ohne öffnet Kept. den Chat über den Kontakt im Handy.';

  @override
  String get chatTargetViaPhone =>
      'Ohne öffnet Kept. den Chat über die Telefonnummer.';

  @override
  String chatTargetHelpUsername(String name) {
    return 'Wenn du einen Nutzernamen oder Chat-Link für diese Person hast, trag ihn hier ein. Sonst öffnet Kept. einfach $name.';
  }

  @override
  String chatTargetHelpLink(String name) {
    return 'Wenn du einen Chat-Link für diese Person hast, füg ihn hier ein. Sonst öffnet Kept. einfach $name.';
  }

  @override
  String get chatLinkHelpButton => 'Wie komme ich an einen Chat-Link?';

  @override
  String get chatLinkHelpTitle => 'Chat-Links';

  @override
  String get chatLinkHelpIntro =>
      'Mit einem Chat-Link oder Nutzernamen führt „Öffnen“ direkt zum Chat. Bei WhatsApp, Signal und Telegram reicht meist, dass die Person mit ihrer Nummer in deinen Kontakten steht.';

  @override
  String get chatLinkHelpTelegram =>
      'Öffne ihr Profil. Wenn sie einen Nutzernamen hat, steht er dort (@name). Trag ihn ein.';

  @override
  String get chatLinkHelpDiscord =>
      'Öffne euren Chat, halte eine Nachricht gedrückt und tippe auf „Nachrichtenlink kopieren“. Füg ihn hier ein.';

  @override
  String get chatLinkHelpLinkedin =>
      'Öffne ihr Profil, tippe auf „Profil teilen“ und kopiere den Link. Füg ihn ein oder nur den Namen nach /in/. „Öffnen“ beginnt eine neue Nachricht an sie.';

  @override
  String get chatLinkHelpInstagram =>
      'Öffne euren Chat. Der Nutzername steht oben. Trag ihn ein.';

  @override
  String get chatLinkHelpSnapchat =>
      'Der Nutzername steht in ihrem Profil. Snapchat hat keinen Link zu einem Chat, darum zeigt „Öffnen“ ihr Profil.';

  @override
  String get chatLinkHelpOthers =>
      'Bei anderen Apps kann ein Link funktionieren, den die App selbst für eine Person teilt. Füg ihn ein und probier „Öffnen“.';

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
  String eveningReconnect(String title) {
    return '$title. Hast du zehn Minuten?';
  }

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
  String get timelineSubtitle =>
      'Was kommt und was war. Hier ist nie etwas überfällig.';

  @override
  String get pastEmpty =>
      'Noch nichts. Anrufe, Treffen, Zocken und Geburtstage erscheinen hier.';

  @override
  String get upcomingEmpty =>
      'Noch nichts mit Datum. Geburtstage und Termine, die du setzt, erscheinen hier.';

  @override
  String get groupThisWeek => 'Diese Woche';

  @override
  String get groupNextWeek => 'Nächste Woche';

  @override
  String get groupEarlierThisWeek => 'Früher diese Woche';

  @override
  String get groupLastWeek => 'Letzte Woche';

  @override
  String turnedAge(int age) {
    return 'Wurde $age';
  }

  @override
  String wishesFrom(String names) {
    return 'Glückwünsche von $names';
  }

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
  String get buttonWeWereInTouch => 'Wir hatten Kontakt';

  @override
  String logContactTitle(String name) {
    return 'Kontakt mit $name';
  }

  @override
  String get logContactWhat => 'Was';

  @override
  String get logKindWrote => 'Geschrieben';

  @override
  String get logKindCalled => 'Telefoniert';

  @override
  String get logKindMet => 'Getroffen';

  @override
  String get logKindGamed => 'Gezockt';

  @override
  String get logDayYesterday => 'Gestern';

  @override
  String get captureAlreadyHappened => 'Schon passiert';

  @override
  String get logDayPick => 'Tag wählen';

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

  @override
  String get settingsRhythms => 'Rhythmen';

  @override
  String get settingsRhythmsHelp =>
      'Wie lange es dauern darf, bis Kept vorschlägt, sich zu melden. Mehr als ein sanfter Hinweis ist das nie.';

  @override
  String get rhythmNone => 'Keiner';

  @override
  String get rhythmLikeClass => 'Wie die Gruppe';

  @override
  String rhythmWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Wochen',
      one: '1 Woche',
    );
    return '$_temp0';
  }

  @override
  String rhythmMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Monate',
      one: '1 Monat',
    );
    return '$_temp0';
  }

  @override
  String rhythmDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage',
      one: '1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get editRhythm => 'Rhythmus';

  @override
  String get editRhythmHelp =>
      'Wie oft du dich melden möchtest. Das ist nur ein sanfter Hinweis, nie eine Frist.';

  @override
  String hintPick(String name) {
    return 'Mit $name ist es eine Weile her';
  }

  @override
  String reconnectThisWeek(String name) {
    return 'Diese Woche: $name';
  }

  @override
  String get reconnectChoose => 'Bei wem möchtest du dich jetzt wieder melden?';

  @override
  String get reconnectCardHint =>
      'Alte Freunde knüpfen da an, wo sie aufgehört haben.';

  @override
  String get someoneElse => 'Jemand anderes';

  @override
  String reconnectDone(String name) {
    return 'Du hast dich bei $name gemeldet.';
  }

  @override
  String backInTouchTitle(String name) {
    return '$name und du seid wieder in Kontakt.';
  }

  @override
  String get backInTouchKeep => 'Weiter bei „Wieder in Kontakt kommen“ lassen';

  @override
  String get progressStampsLine =>
      'Stempel bisher. Diese Zahl wird nur größer.';

  @override
  String get stampCardTitle => 'Stempelkarte';

  @override
  String get myTreats => 'Meine Belohnungen';

  @override
  String get stampCardChoose => 'Such dir die nächste Belohnung aus';

  @override
  String get stampCardChooseHint =>
      'Stempel, die du jetzt bekommst, warten auf die Karte, die du startest.';

  @override
  String stampCardLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count Stempel, dann gehört sie dir.',
      one: 'Noch ein Stempel, dann gehört sie dir.',
    );
    return '$_temp0';
  }

  @override
  String stampCardSemantics(int filled, int total) {
    return '$filled von $total Stempeln';
  }

  @override
  String get progressThisWeek => 'Diese Woche';

  @override
  String get progressThisWeekEmpty =>
      'Diese Woche noch niemand. Die Woche ist noch lang.';

  @override
  String weeksInARow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Wochen in Folge',
      one: '1 Woche in Folge',
    );
    return '$_temp0';
  }

  @override
  String get weeksNote => 'Diese Woche zählt.';

  @override
  String get weeksPaused =>
      'Diese Woche pausiert bisher. Nichts geht verloren.';

  @override
  String get weeksNone => 'Noch keine Wochen. Dein erster Kontakt startet sie.';

  @override
  String get treatsTitle => 'Belohnungen';

  @override
  String treatStamps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stempel',
      one: '1 Stempel',
    );
    return '$_temp0';
  }

  @override
  String get treatsWaiting => 'Warten';

  @override
  String get treatsEarned => 'Verdient';

  @override
  String get treatsEnjoyed => 'Genossen';

  @override
  String get treatStart => 'Karte starten';

  @override
  String get treatEnjoyedButton => 'Genossen';

  @override
  String treatEarnedTitle(String name) {
    return '$name gehört dir!';
  }

  @override
  String get treatEarnedBody => 'Du hast die Karte voll. Viel Spaß damit!';

  @override
  String get treatFull => 'Voll!';

  @override
  String get treatAdd => 'Belohnung hinzufügen';

  @override
  String get treatEdit => 'Belohnung bearbeiten';

  @override
  String get treatNameLabel => 'Name';

  @override
  String get treatStampsLabel => 'Nötige Stempel';

  @override
  String get treatMoveUp => 'Nach oben';

  @override
  String get treatMoveDown => 'Nach unten';

  @override
  String get treatDelete => 'Belohnung löschen';

  @override
  String get yourNumbers => 'Deine Zahlen';

  @override
  String numberEveningsYes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Abende mit Ja beantwortet',
      one: 'Abend mit Ja beantwortet',
    );
    return '$_temp0';
  }

  @override
  String numberContacts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kontakte von dir diesen Monat',
      one: 'Kontakt von dir diesen Monat',
    );
    return '$_temp0';
  }

  @override
  String numberPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'verschiedene Personen diesen Monat',
      one: 'Person diesen Monat',
    );
    return '$_temp0';
  }

  @override
  String get niceOneStampsCard => 'Stempel für die Karte';

  @override
  String get niceOneStampsLoose => 'Sie warten auf deine nächste Belohnung.';

  @override
  String get settingsStamps => 'Stempel';

  @override
  String get settingsStampsHelp =>
      'Was ein Kontakt zählt. Du kannst das jederzeit neu einstellen.';

  @override
  String get stampBackInTouch => 'Wieder in Kontakt, extra';

  @override
  String get stampLongGap => 'Nach längerer Pause, extra';

  @override
  String get stampMeetUp => 'Treffen, mal';

  @override
  String get stampGaming => 'Zusammen zocken, mal';

  @override
  String get stampCardSize => 'Standard-Kartengröße';

  @override
  String get stampLess => 'Weniger';

  @override
  String get stampMore => 'Mehr';

  @override
  String get defaultTreat1 => 'Lieblingsessen vom Lieferdienst';

  @override
  String get defaultTreat2 => 'Kinoabend';

  @override
  String get defaultTreat3 => 'Kuchen von der guten Bäckerei';

  @override
  String get defaultTreat4 => 'Ein neues Buch oder Spiel';

  @override
  String get defaultTreat5 => 'Ein fauler Morgen ohne Pläne';

  @override
  String get defaultTreat6 => 'Ein Tagesausflug';

  @override
  String get defaultTreat7 => 'Ein Konzert- oder Veranstaltungsticket';

  @override
  String get defaultTreat8 => 'Etwas richtig Feines kochen';

  @override
  String get defaultTreat9 => 'Etwas Neues backen';

  @override
  String get defaultTreat10 => 'Eine neue Pflanze oder etwas für die Wohnung';

  @override
  String get defaultTreat11 =>
      'Ein kleines Projekt starten, das du aufgeschoben hast';

  @override
  String get defaultTreat12 => 'Ein Kurs oder Workshop';

  @override
  String get ideasSection => 'Ideen';

  @override
  String get ideaToDo => 'Zusammen machen';

  @override
  String get ideaToTalk => 'Darüber reden';

  @override
  String get ideaAddHint => 'Idee hinzufügen…';

  @override
  String get ideaAdd => 'Hinzufügen';

  @override
  String ideasDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count erledigt',
      one: '1 erledigt',
    );
    return '$_temp0';
  }

  @override
  String get ideaTickOff => 'Abhaken';

  @override
  String get ideaReopen => 'Wieder öffnen';

  @override
  String get editIdea => 'Idee bearbeiten';

  @override
  String get ideaTextHint => 'Boulderhalle in Altona…';

  @override
  String get linkHint => 'Link (optional)';

  @override
  String get openLink => 'Link öffnen';

  @override
  String get linkNotOpened => 'Der Link ließ sich nicht öffnen.';

  @override
  String get ideaPicture => 'Bild';

  @override
  String ideaOnPick(String text) {
    return 'Idee: $text';
  }

  @override
  String get shareTitle => 'Behalten für…';

  @override
  String get shareKeepAs => 'Behalten als';

  @override
  String get shareIdeaToDo => 'Idee zum Machen';

  @override
  String get shareIdeaToTalk => 'Idee zum Reden';

  @override
  String get shareThought => 'Gedanke';

  @override
  String get shareTextHint => 'Worum geht\'s?';

  @override
  String shareSave(String name) {
    return 'Für $name behalten';
  }

  @override
  String shareSaved(String name) {
    return 'Für $name behalten.';
  }

  @override
  String reconnectTwoWeeks(String name) {
    return 'Diese zwei Wochen: $name';
  }

  @override
  String reconnectThisMonth(String name) {
    return 'Diesen Monat: $name';
  }

  @override
  String reconnectTwoMonths(String name) {
    return 'Diese zwei Monate: $name';
  }

  @override
  String reconnectThreeMonths(String name) {
    return 'Diese drei Monate: $name';
  }

  @override
  String get settingsReconnectSpan => 'Wieder melden bei jemandem für';

  @override
  String get settingsReconnectSpanHelp =>
      'Wie lange die Person, bei der du dich wieder melden willst, im Leute-Tab bleibt, bevor es neu fragt.';

  @override
  String weeksInTouch(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Wochen in Kontakt',
      one: '1 Woche in Kontakt',
    );
    return '$_temp0';
  }

  @override
  String weeksLongest(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bisher am längsten: $count Wochen',
      one: 'Bisher am längsten: 1 Woche',
    );
    return '$_temp0';
  }

  @override
  String get weeksWho =>
      'Es zählen Wochen mit jemandem außerhalb deiner engen Freunde.';

  @override
  String get weeksOpen => 'Diese Woche ist noch offen.';

  @override
  String get weeksEnded =>
      'Diese Serie ist vorbei. Die nächste Woche mit jemandem außerhalb deiner engen Freunde startet eine neue.';

  @override
  String get settingsStreak => 'Wochen in Folge';

  @override
  String get settingsStreakHelp =>
      'Eine Woche zählt, wenn du mit jemandem außerhalb deiner engen Freunde in Kontakt warst.';

  @override
  String get streakStrict => 'Streng';

  @override
  String get streakFriendly => 'Freundlich';

  @override
  String get streakStrictHelp =>
      'Eine vorbeigegangene Woche ohne so einen Kontakt beendet die Serie. Die nächste beginnt bei 1, die längste bleibt gespeichert.';

  @override
  String get streakFriendlyHelp =>
      'Eine Woche ohne so einen Kontakt pausiert nur die Zählung. Sie sinkt nie.';

  @override
  String get stampGamingClose => 'Zocken mit engen Freunden, mal';

  @override
  String get didItNewDate => 'Neuer Termin';

  @override
  String get nicePlanTitle => 'Triffst du dich bald?';

  @override
  String get nicePlanAction => 'Planen';

  @override
  String get nicePlanHint => 'Was? (optional)';

  @override
  String get firstStartSkip => 'Überspringen';

  @override
  String get fsWelcomeTitle => 'Willkommen bei Kept.';

  @override
  String get fsWelcomeBody =>
      'Kept. hilft dir, mit Freunden in Kontakt zu bleiben und zu alten wieder zu finden. Es erinnert dich sanft, damit niemand verloren geht.';

  @override
  String get fsWelcomePrivacy =>
      'Alles, was du eingibst, bleibt auf diesem Handy. Kein Konto, kein Server. Das Einzige, was Kept. je abruft, ist die Versionsprüfung bei GitHub, und nur, wenn du sie einschaltest.';

  @override
  String get fsStart => 'Los geht\'s';

  @override
  String get fsPeopleTitle => 'Füge deine Leute hinzu';

  @override
  String get fsPeopleBody =>
      'Kept. kann deine Kontakte lesen, um Namen, Nummern und Geburtstage zu übernehmen. Vorher fragt Android dich um Erlaubnis. Nichts wird irgendwohin gesendet, und du kannst Leute immer auch von Hand hinzufügen.';

  @override
  String get fsByHandLater => 'Später von Hand hinzufügen';

  @override
  String get classLegendHint => 'Wähle für jede Person ein Symbol:';

  @override
  String get fsEveningTitle => 'Eine Frage am Abend';

  @override
  String get fsEveningBody =>
      'Jeden Abend kann Kept. dir eine Frage stellen: Möchtest du jemandem schreiben? Sie kommt als Benachrichtigung zur Uhrzeit, die du wählst.';

  @override
  String get fsEveningOff =>
      'Ohne sie wartet alles auf der Startseite, wenn du die App öffnest.';

  @override
  String get fsEveningAsk =>
      'Beim Einschalten fragt Android, ob Kept. Benachrichtigungen zeigen darf.';

  @override
  String get fsContinue => 'Weiter';

  @override
  String get fsIncomingTitle => 'Merken, wer geschrieben oder angerufen hat';

  @override
  String get fsIncomingBody =>
      'Optional. Kept. kann bemerken, wenn jemand aus deinen Leuten dir in WhatsApp, Telegram, Signal oder Discord schreibt oder dich anruft. Es liest, wer und wann, nie den Text. Dafür braucht es einen besonderen Zugriff, den du in den Systemeinstellungen erteilst. Nichts wird irgendwohin gesendet.';

  @override
  String get incomingWithout =>
      'Ohne das tippst du auf der Seite einer Person selbst auf „Hat geschrieben“ oder „Hat angerufen“.';

  @override
  String get fsNotNow => 'Jetzt nicht';

  @override
  String get fsDoneTitle => 'Alles bereit';

  @override
  String get fsDoneBody =>
      'Das kannst du später alles in den Einstellungen ändern, unter Berechtigungen und Datenschutz.';

  @override
  String get fsDoneButton => 'Zur Startseite';

  @override
  String get permTitle => 'Berechtigungen und Datenschutz';

  @override
  String get permRowHelp => 'Was Kept. nutzen darf und wofür';

  @override
  String get permNothingLeaves =>
      'Alles, was du eingibst, bleibt auf diesem Handy. Kein Konto, kein Server. Das Einzige, was Kept. je abruft, ist die Versionsprüfung bei GitHub, und nur, wenn du sie einschaltest.';

  @override
  String get permNothingSent => 'Nichts wird irgendwohin gesendet.';

  @override
  String get permStateAllowed => 'Erlaubt';

  @override
  String get permStateNotAllowed => 'Nicht erlaubt';

  @override
  String get permStateOn => 'An';

  @override
  String get permStateOff => 'Aus';

  @override
  String get permStateAlways => 'Immer erlaubt';

  @override
  String get permContactsTitle => 'Kontakte (nur lesen)';

  @override
  String get permContactsUse =>
      'Wird gebraucht, um Leute zu importieren und ihre Namen, Nummern und Geburtstage zu aktualisieren. Deine Kontakte werden nie verändert.';

  @override
  String get permContactsWithout =>
      'Ohne: Leute von Hand hinzufügen und bearbeiten.';

  @override
  String get permContactsAllow => 'Kontakte erlauben';

  @override
  String get permNotifTitle => 'Benachrichtigungen';

  @override
  String get permNotifUse =>
      'Für die Abendfrage und die Geburtstagserinnerungen. Sie entstehen auf diesem Handy.';

  @override
  String get permNotifWithout =>
      'Ohne sie steht alles auf der Startseite, wenn du die App öffnest.';

  @override
  String get permBootTitle => 'Start nach einem Neustart';

  @override
  String get permBootUse =>
      'Damit die Erinnerungen nach einem Neustart des Handys zurückkommen. Android erlaubt das immer, es gibt keine Abfrage.';

  @override
  String get permBootWithout =>
      'Ohne das kämen Erinnerungen erst zurück, wenn du die App das nächste Mal öffnest.';

  @override
  String get permAccessTitle => 'Zugriff auf Benachrichtigungen';

  @override
  String get permAccessUse =>
      'Wird gebraucht, um zu merken, wer dir in WhatsApp, Telegram, Signal oder Discord geschrieben oder dich angerufen hat. Es liest, wer und wann, nie den Text. Gruppen und alle, die nicht zu deinen Leuten gehören, bleiben außen vor. Ein besonderer Zugriff, den du in den Systemeinstellungen erteilst.';

  @override
  String get permRefreshTitle => 'Leute aus den Kontakten aktualisieren';

  @override
  String get permRefreshUse =>
      'Vergleicht die importierten Leute mit deinen Kontakten und übernimmt nur die Änderungen, die du annimmst.';

  @override
  String get permRefreshButton => 'Leute aktualisieren';

  @override
  String get permNotUsedTitle => 'Was Kept. nicht nutzt';

  @override
  String get permNotUsedList =>
      'Standort, Mikrofon, Kamera, Speicher und deine Anrufliste. Kept. fragt nie danach.';

  @override
  String get refreshTitle => 'Aus Kontakten aktualisieren';

  @override
  String get refreshPersonButton => 'Aus Kontakt aktualisieren';

  @override
  String get refreshNothing =>
      'Nichts zu aktualisieren. Diese Person stimmt mit dem Kontakt überein.';

  @override
  String get refreshGone =>
      'Dieser Kontakt ist nicht mehr in deinem Adressbuch.';

  @override
  String get refreshFieldName => 'Name';

  @override
  String get refreshFieldPhone => 'Telefonnummer';

  @override
  String get refreshFieldBirthday => 'Geburtstag';

  @override
  String get refreshOld => 'In Kept.';

  @override
  String get refreshNew => 'In den Kontakten';

  @override
  String get refreshNone => 'keine Angabe';

  @override
  String get refreshApply => 'Übernehmen';

  @override
  String get refreshSkip => 'Überspringen';

  @override
  String get refreshAcceptAll => 'Alle übernehmen';

  @override
  String get refreshAllIntro =>
      'Unterschiede in deinen Kontakten gefunden. Nichts ändert sich, bevor du zustimmst.';

  @override
  String get refreshAllNothing => 'Alle sind aktuell.';

  @override
  String get refreshAllDone => 'Alles erledigt.';

  @override
  String get settingsAbout => 'Über Kept. und Lizenzen';

  @override
  String get permVibrateTitle => 'Vibrieren';

  @override
  String get permVibrateUse =>
      'Damit eine Erinnerung vibrieren kann. Android erlaubt das immer, es gibt keine Abfrage.';

  @override
  String get permVibrateWithout =>
      'Ohne das würden Erinnerungen nur einen Ton machen.';

  @override
  String get updateSection => 'App-Update';

  @override
  String get updateSwitch => 'Bei GitHub nach neuen Versionen sehen';

  @override
  String get updateOff =>
      'Die Prüfung ist aus. Kept. stellt keine Anfragen ins Internet. Du kannst von der Release-Seite selbst aktualisieren.';

  @override
  String get updateReleasesPage => 'Releases auf GitHub';

  @override
  String get updateReleasesPageHint =>
      'Öffnet den Browser. Lade dort die neueste APK herunter, um selbst zu aktualisieren.';

  @override
  String get updateAskTitle => 'Bei GitHub nach neuen Versionen sehen?';

  @override
  String get updateAskBody =>
      'Kept. kann bei GitHub nachfragen, welche Version die neueste ist, und sie für dich herunterladen und installieren. Nur diese Anfrage geht raus; deine Daten werden nie gesendet. Du kannst stattdessen jederzeit selbst von GitHub aktualisieren. Android fragt einmal, ob Kept. Apps installieren darf.';

  @override
  String get updateCheck => 'Nach Updates suchen';

  @override
  String updateStatusChecked(String version, String time) {
    return 'Version $version · aktuell, geprüft $time';
  }

  @override
  String updateStatusNotChecked(String version) {
    return 'Version $version · noch nicht geprüft';
  }

  @override
  String get updateChecking => 'Suche nach Updates …';

  @override
  String get updateUpToDate => 'Kept. ist auf dem neuesten Stand.';

  @override
  String updateAvailableTile(String version) {
    return 'Update auf Version $version';
  }

  @override
  String get updateAvailableHint => 'Neuerungen ansehen und installieren';

  @override
  String updateDownloading(int percent) {
    return 'Wird heruntergeladen … $percent %';
  }

  @override
  String get updateInstalling =>
      'Bestätige die Installation im Android-Fenster. Kept. schließt sich dabei; öffne es danach einfach wieder.';

  @override
  String get updateCloseHint =>
      'Kept. schließt sich während des Updates. Öffne es danach einfach wieder.';

  @override
  String get updateRestart => 'Update neu starten';

  @override
  String get updateRestartHint =>
      'Falls die Installation hängt oder nicht geklappt hat';

  @override
  String get updateDeleteFile => 'Update-Datei löschen';

  @override
  String updateFileSize(String size) {
    return 'Belegt $size';
  }

  @override
  String get updateNoFile => 'Keine Datei gespeichert';

  @override
  String get updateFileDeleted => 'Update-Datei gelöscht';

  @override
  String updateDialogTitle(String version) {
    return 'Update auf Version $version';
  }

  @override
  String get updateNotesEmpty => 'Kleine Verbesserungen im Hintergrund.';

  @override
  String get notesNew => 'Neu';

  @override
  String get notesFixed => 'Behoben';

  @override
  String get notesImproved => 'Verbessert';

  @override
  String get updateInstall => 'Aktualisieren';

  @override
  String get updateLater => 'Später';

  @override
  String get updateClose => 'Schließen';

  @override
  String get updateCheckFailed =>
      'GitHub ist gerade nicht erreichbar. Versuch es später noch einmal.';

  @override
  String get updateDownloadFailed =>
      'Der Download hat nicht geklappt. Versuch es noch einmal.';

  @override
  String get updateNoPermission =>
      'Kept. darf noch keine Apps installieren. Erlaube es in den Android-Einstellungen und tippe dann noch einmal auf „Aktualisieren“.';

  @override
  String get updateAborted => 'Update abgebrochen.';

  @override
  String get updateFailed => 'Android hat das Update abgelehnt.';

  @override
  String get whatsNewTile => 'Was ist neu?';

  @override
  String whatsNewTileHint(String version) {
    return 'Die Änderungen in Version $version';
  }

  @override
  String whatsNewTitle(String version) {
    return 'Neu in Version $version';
  }

  @override
  String get whatsNewFailed =>
      'Die Neuerungen lassen sich gerade nicht laden. Versuch es später noch einmal.';

  @override
  String get whatsNewEarlier => 'Frühere Versionen';

  @override
  String whatsNewVersion(String version) {
    return 'Version $version';
  }

  @override
  String get permUpdateTitle => 'Update-Prüfung';

  @override
  String get permUpdateUse =>
      'Fragt bei GitHub nach, welche Version von Kept. die neueste ist, beim Start und wenn du zur App zurückkommst, höchstens alle 30 Minuten. Nutzt zwei Berechtigungen: Internetzugriff und das Installieren von Apps, nach dem Android fragt, wenn das erste Update installiert wird.';

  @override
  String get permUpdateSent =>
      'Nur diese Anfrage geht an GitHub. Deine Daten werden nie gesendet.';

  @override
  String get permUpdateWithout =>
      'Ohne sie: Lade die neueste APK selbst von GitHub herunter (Einstellungen, Releases auf GitHub).';

  @override
  String get editNickname => 'Spitzname';

  @override
  String get nicknameHint => 'Optional';

  @override
  String get nicknameHelper => 'Wird statt des Namens angezeigt.';

  @override
  String get choosePicture => 'Bild wählen';

  @override
  String get pictureFromContact => 'Aus Kontakt';

  @override
  String get removePicture => 'Bild entfernen';

  @override
  String get pictureTip =>
      'Tipp: Teile ein Foto aus einer beliebigen App mit Kept., um es als Bild einer Person zu nutzen.';

  @override
  String get refreshFieldPicture => 'Bild';

  @override
  String get refreshPictureFromContact => 'Das Bild des Kontakts';

  @override
  String get pictureCardTitle => 'Bilder aus deinen Kontakten hinzufügen?';

  @override
  String get pictureCardBody =>
      'Kept. übernimmt das Bild jedes verknüpften Kontakts, der eines hat. Nichts verlässt dein Handy.';

  @override
  String get pictureCardAdd => 'Hinzufügen';

  @override
  String get pictureCardNotNow => 'Nicht jetzt';

  @override
  String picturesAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bilder hinzugefügt',
      one: '1 Bild hinzugefügt',
      zero: 'Keine Bilder in deinen Kontakten gefunden',
    );
    return '$_temp0';
  }

  @override
  String get cropTitle => 'Bild zurechtrücken';

  @override
  String get cropHint => 'Ziehen und zoomen. Doppeltippen vergrößert.';

  @override
  String get cropUse => 'Bild verwenden';

  @override
  String get cropSaving => 'Speichern…';

  @override
  String get cropFailed => 'Dieses Bild konnte nicht gelesen werden.';

  @override
  String get sharePictureTitle => 'Wofür ist dieses Bild?';

  @override
  String get shareUseAsPicture => 'Als Bild für jemanden nutzen';

  @override
  String get shareUseAsPictureLine => 'Freund wählen, zuschneiden, fertig';

  @override
  String get shareKeepAsIdea => 'Als Idee behalten';

  @override
  String get shareKeepAsIdeaLine =>
      'Mit einer Notiz auf der Seite eines Freundes ablegen';

  @override
  String get shareLastTime => 'Zuletzt';

  @override
  String get shareWhoseTitle => 'Wer ist das?';

  @override
  String get shareFindFriend => 'Freund suchen';

  @override
  String get shareNoPictureYet => 'Noch kein Bild';

  @override
  String get shareHasPicture => 'Hat ein Bild';

  @override
  String get shareNobodyFound => 'Niemand gefunden.';

  @override
  String get shareDoneTitle => 'Sieht gut aus!';

  @override
  String shareDoneLine(String name) {
    return '$name hat ein neues Bild.';
  }

  @override
  String shareStillNoPicture(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count Freunde ohne Bild',
      one: 'Noch 1 Freund ohne Bild',
    );
    return '$_temp0';
  }

  @override
  String get shareAllHavePicture => 'Alle haben jetzt ein Bild.';

  @override
  String get shareDoneButton => 'Fertig';

  @override
  String get tipSharePicture =>
      'Tipp: Teile ein Foto aus deiner Galerie mit Kept., um es als Bild für jemanden zu nutzen.';

  @override
  String get tipStepPhoto => 'Foto';

  @override
  String get tipStepShare => 'Teilen';

  @override
  String get fsDonePictureTip =>
      'Tipp: Teile ein Foto aus deiner Galerie mit Kept., um einem Freund ein Bild zu geben.';

  @override
  String get shareDoneTag => 'Neu!';

  @override
  String get partnerLabel => 'Partner';

  @override
  String get partnerLink => 'Partner verknüpfen';

  @override
  String get partnerHelp =>
      'Wer verknüpft ist, erscheint als Paar. Beide bleiben eigene Personen.';

  @override
  String get partnerUnlink => 'Trennen';

  @override
  String partnerUnlinkTitle(String a, String b) {
    return 'Verknüpfung von $a und $b lösen?';
  }

  @override
  String get partnerUnlinkBody =>
      'Beide erscheinen wieder einzeln. Offene Gedanken an beide bekommt jeder von beiden. Gemeinsame Treffen bleiben in beiden Verläufen.';

  @override
  String coupleWith(String name) {
    return 'mit $name';
  }

  @override
  String coupleAlsoChanges(String name) {
    return 'Ändert auch den Verlauf von $name';
  }

  @override
  String get coupleThoughtForBoth => 'Gedanke an beide';

  @override
  String get coupleWeMet => 'Wir haben uns getroffen';

  @override
  String get coupleTogether => 'Gemeinsame Zeit';

  @override
  String get coupleNothingTogether => 'Noch nichts gemeinsam.';

  @override
  String get coupleOpenChat => 'Chat öffnen';

  @override
  String get coupleChatWho => 'Wen möchtest du anschreiben?';

  @override
  String get removeCoupleLine =>
      'Die Verknüpfung als Paar wird ebenfalls gelöst.';

  @override
  String niceOneStampsOf(String name, int count) {
    return '$name +$count';
  }
}
