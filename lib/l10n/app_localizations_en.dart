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
  String messengerNotOpened(String messenger) {
    return '$messenger could not be opened.';
  }

  @override
  String get addPersonTitle => 'Add a person';

  @override
  String get editPersonTitle => 'Edit person';

  @override
  String get edit => 'Edit';

  @override
  String get save => 'Save';

  @override
  String get editLook => 'Look';

  @override
  String get editName => 'Name';

  @override
  String get nameHint => 'Their name';

  @override
  String get editClass => 'Class';

  @override
  String get reconnectingHint =>
      'For people you want to get back in touch with.';

  @override
  String get editMessenger => 'Main messenger';

  @override
  String get messengerNone => 'None';

  @override
  String get editReach => 'How to reach them';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get phoneHint => '+49…';

  @override
  String get telegramUsername => 'Telegram user name';

  @override
  String get signalLink => 'Signal link';

  @override
  String get discordUserId => 'Discord user ID';

  @override
  String get birthday => 'Birthday';

  @override
  String get birthdayDay => 'Day';

  @override
  String get birthdayMonthField => 'Month';

  @override
  String get birthdayYearOptional => 'Year (optional)';

  @override
  String get birthdayError =>
      'Enter a real day and month, or leave all three empty.';

  @override
  String get notesHint => 'Anything worth remembering';

  @override
  String get removePerson => 'Remove this person';

  @override
  String removeTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String get removeBody =>
      'Their entry and notes will be deleted. This cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get remove => 'Remove';

  @override
  String get addMenuContacts => 'From your contacts';

  @override
  String get addMenuByHand => 'By hand';

  @override
  String get addFromContacts => 'Add from contacts';

  @override
  String get addByHand => 'Add by hand';

  @override
  String get importPickTitle => 'Who do you want to keep in touch with?';

  @override
  String get importPickHint =>
      'Picking a few is enough. You can add more later.';

  @override
  String get importSearchHint => 'Search';

  @override
  String get importDenied =>
      'Kept needs to read your contacts to offer them here. Nothing leaves your phone.';

  @override
  String get importNoContacts => 'No contacts to show.';

  @override
  String get importLoadError => 'Your contacts could not be read.';

  @override
  String get openSettings => 'Open settings';

  @override
  String importNext(int count) {
    return 'Next ($count)';
  }

  @override
  String get importClassTitle => 'How close are you?';

  @override
  String get importMessengerAll => 'Main messenger for all';

  @override
  String importAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count people',
      one: 'Add 1 person',
    );
    return '$_temp0';
  }

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingDay => 'Hello';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get captureTitle => 'Who\'s on your mind?';

  @override
  String get captureHint => 'saw a bouldering video…';

  @override
  String get captureMore => 'More';

  @override
  String get kindWrite => 'Write';

  @override
  String get kindCall => 'Call';

  @override
  String get kindMeet => 'Meet';

  @override
  String get kindGame => 'Game';

  @override
  String captureSave(String name) {
    return 'Save for $name';
  }

  @override
  String captureSaved(String name) {
    return 'Saved for $name.';
  }

  @override
  String get captureNoPeople =>
      'Add the people you want to keep in touch with first.';

  @override
  String get captureAddPeople => 'Add people';

  @override
  String get onYourMind => 'On your mind';

  @override
  String get pickerSearchHint => 'Search people';

  @override
  String get pickerNoMatch => 'Nobody found.';

  @override
  String get done => 'Done';

  @override
  String get drop => 'Drop';

  @override
  String get shortcutCapture => 'Capture a thought';

  @override
  String get niceOneTitle => 'Nice one!';

  @override
  String get niceOneSubtitle => 'That\'s what counts.';

  @override
  String get activityLabel => 'What did you do?';

  @override
  String get nextTimeLabel => 'One line for next time?';

  @override
  String get nextTimeHint => 'new job in March';

  @override
  String get remindMe => 'Remind me';

  @override
  String get remindMeHelp => 'Also keeps this line as an open thought.';

  @override
  String get niceOneClose => 'Close';

  @override
  String lastTime(String note) {
    return 'Last time: $note';
  }

  @override
  String get eveningQuestion => 'Got ten minutes for someone today?';

  @override
  String get eveningYes => 'Yes';

  @override
  String get eveningNotToday => 'Not today';

  @override
  String get eveningChannel => 'Evening question';

  @override
  String get settingsEvening => 'Evening question';

  @override
  String get settingsEveningSwitch => 'Ask me in the evening';

  @override
  String get settingsEveningTime => 'Time';

  @override
  String get settingsEveningDays => 'Days';

  @override
  String get settingsNotificationsOff => 'Notifications are off for Kept.';

  @override
  String get settingsOpenNotificationSettings => 'Open notification settings';

  @override
  String get settingsOpenItems => 'Open items';

  @override
  String get settingsOpenItemsHelp => 'How many ideas Home offers for tonight.';

  @override
  String get openItemsOne => 'One';

  @override
  String get openItemsThree => 'Three';

  @override
  String get tonightsPick => 'Tonight\'s pick';

  @override
  String get anotherOne => 'Another one';

  @override
  String chatQuestionWrite(String name) {
    return 'Did you write to $name?';
  }

  @override
  String chatQuestionCall(String name) {
    return 'Did you call $name?';
  }

  @override
  String chatQuestionMeet(String name) {
    return 'Did you meet $name?';
  }

  @override
  String chatQuestionGame(String name) {
    return 'Did you game with $name?';
  }

  @override
  String chatQuestionOpened(String messenger) {
    return 'You opened $messenger a moment ago.';
  }

  @override
  String get chatQuestionYes => 'Yes';

  @override
  String get chatQuestionNotYet => 'Not yet';

  @override
  String get chatQuestionHint => 'Not yet is fine. Nothing becomes overdue.';

  @override
  String get congratulated => 'Congratulated';

  @override
  String get birthdayToday => 'Birthday today';

  @override
  String birthdayTurns(int age) {
    return 'Turns $age today';
  }

  @override
  String chatQuestionBirthday(String name) {
    return 'Did you congratulate $name?';
  }

  @override
  String birthdayNotification(String name) {
    return 'It\'s $name\'s birthday today. Congratulated yet?';
  }

  @override
  String birthdayLateNotification(String name) {
    return 'Last hour of $name\'s birthday';
  }

  @override
  String get birthdayLateNotificationBody => 'Congratulated yet?';

  @override
  String get birthdayYes => 'Yes';

  @override
  String get birthdayOpenChat => 'Open chat';

  @override
  String get birthdayChannel => 'Birthdays';

  @override
  String get congratulatedTitle => 'Who congratulated you?';

  @override
  String get congratulatedToday => 'Happy birthday!';

  @override
  String congratulatedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat(
      'd MMMM',
      localeName,
    );
    final String dateString = dateDateFormat.format(date);

    return 'Your birthday on $dateString';
  }

  @override
  String get ownBirthdayCardHint => 'Happy birthday! Note who wished you well.';

  @override
  String get settingsOwnBirthday => 'Your birthday';

  @override
  String get settingsOwnBirthdayNotSet => 'Not set';

  @override
  String get whenDate => 'Date';

  @override
  String get whenSoon => 'Soon';

  @override
  String get whenLater => 'Later';

  @override
  String get whenCondition => 'When…';

  @override
  String get whenAddTime => 'Time';

  @override
  String get whenSection => 'When';

  @override
  String get whenConditionHint => 'when it is warm again';

  @override
  String get editThought => 'Edit thought';

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
      'EEE d MMM',
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
  String get upcomingTitle => 'Coming up';

  @override
  String get upcomingSubtitle =>
      'Birthdays and dates you have set. Nothing here is ever late.';

  @override
  String get upcomingEmpty =>
      'Nothing dated yet. Birthdays and the dates you set will show up here.';

  @override
  String get groupThisWeek => 'This week';

  @override
  String get groupNextWeek => 'Next week';

  @override
  String birthdayOf(String name) {
    return '$name\'s birthday';
  }

  @override
  String turnsAge(int age) {
    return 'Turns $age';
  }

  @override
  String get noDateYet => 'No date yet';

  @override
  String get pickADate => 'Pick a date';

  @override
  String get comingUp => 'Coming up';

  @override
  String get seeAll => 'See all';

  @override
  String get didItHappen => 'Did it happen?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String wantSetDate(String name) {
    return 'Want to set a date with $name?';
  }

  @override
  String get setADate => 'Set a date';

  @override
  String get timelineToday => 'Today';

  @override
  String get youWrote => 'You wrote';

  @override
  String theyWrote(String name) {
    return '$name wrote';
  }

  @override
  String get youCalled => 'You called';

  @override
  String theyCalled(String name) {
    return '$name called';
  }

  @override
  String get youMet => 'You met';

  @override
  String get youGamed => 'You gamed together';

  @override
  String get addedToYourPeople => 'Added to your people';

  @override
  String get youCongratulated => 'You congratulated';

  @override
  String get yourBirthday => 'Your birthday';

  @override
  String congratulatedYou(String name) {
    return '$name congratulated you';
  }

  @override
  String get buttonTheyWrote => 'They wrote';

  @override
  String get buttonTheyCalled => 'They called';

  @override
  String notedTheyWrote(String name) {
    return 'Noted: $name wrote';
  }

  @override
  String notedTheyCalled(String name) {
    return 'Noted: $name called';
  }

  @override
  String get alreadyNoted => 'Already noted for today';

  @override
  String get undo => 'Undo';

  @override
  String get editEntry => 'Edit entry';

  @override
  String get entryActivity => 'Activity';

  @override
  String get entryNote => 'Note for next time';

  @override
  String get deleteEntry => 'Delete this entry';

  @override
  String get deleteEntryTitle => 'Delete this entry?';

  @override
  String get deleteEntryBody => 'It disappears from the timeline.';

  @override
  String get delete => 'Delete';

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
    return 'Still owe $name a reply?';
  }

  @override
  String get alreadyAnswered => 'Already answered';

  @override
  String get settingsIncoming => 'Incoming messages';

  @override
  String get settingsIncomingSwitch => 'Notice who wrote or called';

  @override
  String get settingsIncomingHelp =>
      'Kept reads the notifications of WhatsApp, Telegram, Signal and Discord to see who from your people wrote or called you, and when. It never reads what they wrote. Group chats and everyone else are left out.';

  @override
  String get settingsIncomingAccess => 'Notification access';

  @override
  String get settingsIncomingAccessOn => 'Allowed';

  @override
  String get settingsIncomingAccessOff => 'Not allowed yet';

  @override
  String get settingsIncomingOpenAccess => 'Open notification access';

  @override
  String get settingsReplyWait => 'Ask about a reply after';

  @override
  String replyWaitDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get shorter => 'Shorter';

  @override
  String get longer => 'Longer';
}
