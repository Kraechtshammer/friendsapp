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
      'A short list of people you want to get back in touch with. On the People tab you pick one for a while. Switch it off when you are back in touch.';

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

  @override
  String get settingsRhythms => 'Rhythms';

  @override
  String get settingsRhythmsHelp =>
      'How long it can be before Kept suggests getting in touch. It only ever gives a gentle hint.';

  @override
  String get rhythmNone => 'None';

  @override
  String get rhythmLikeClass => 'Like the class';

  @override
  String rhythmWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks',
      one: '1 week',
    );
    return '$_temp0';
  }

  @override
  String rhythmMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String rhythmDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get editRhythm => 'Rhythm';

  @override
  String get editRhythmHelp =>
      'How often you would like to be in touch. It only gives a gentle hint, never a deadline.';

  @override
  String hintPick(String name) {
    return 'It\'s been a while with $name';
  }

  @override
  String reconnectThisWeek(String name) {
    return 'This week: $name';
  }

  @override
  String get reconnectChoose =>
      'Who do you want to get back in touch with now?';

  @override
  String get reconnectCardHint => 'Old friends pick up where they left off.';

  @override
  String get someoneElse => 'Someone else';

  @override
  String reconnectDone(String name) {
    return 'You got in touch with $name.';
  }

  @override
  String backInTouchTitle(String name) {
    return 'You and $name are back in touch.';
  }

  @override
  String get backInTouchKeep => 'Keep as getting back in touch';

  @override
  String get progressStampsLine =>
      'Stamps so far. This number only ever grows.';

  @override
  String get stampCardTitle => 'Treat stamp card';

  @override
  String get myTreats => 'My treats';

  @override
  String get stampCardChoose => 'Choose your next treat';

  @override
  String get stampCardChooseHint =>
      'Stamps you earn now wait for the card you start.';

  @override
  String stampCardLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more stamps and it is yours.',
      one: 'One more stamp and it is yours.',
    );
    return '$_temp0';
  }

  @override
  String stampCardSemantics(int filled, int total) {
    return '$filled of $total stamps';
  }

  @override
  String get progressThisWeek => 'This week';

  @override
  String get progressThisWeekEmpty =>
      'Nobody yet this week. The week is still long.';

  @override
  String weeksInARow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks in a row',
      one: '1 week in a row',
    );
    return '$_temp0';
  }

  @override
  String get weeksNote => 'This week counts.';

  @override
  String get weeksPaused => 'Paused this week so far. Nothing is lost.';

  @override
  String get weeksNone => 'No weeks yet. Your first contact starts them.';

  @override
  String get treatsTitle => 'Treats';

  @override
  String treatStamps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stamps',
      one: '1 stamp',
    );
    return '$_temp0';
  }

  @override
  String get treatCurrentTag => 'Current card';

  @override
  String get treatsWaiting => 'Waiting';

  @override
  String get treatsEarned => 'Earned';

  @override
  String get treatsEnjoyed => 'Enjoyed';

  @override
  String get treatStart => 'Start this card';

  @override
  String get treatEnjoyedButton => 'Enjoyed';

  @override
  String treatEarnedTitle(String name) {
    return '$name is yours!';
  }

  @override
  String get treatEarnedBody => 'You filled the card. Go and enjoy it.';

  @override
  String get treatFull => 'Full!';

  @override
  String get treatAdd => 'Add a treat';

  @override
  String get treatEdit => 'Edit treat';

  @override
  String get treatNameLabel => 'Name';

  @override
  String get treatStampsLabel => 'Stamps needed';

  @override
  String get treatMoveUp => 'Move up';

  @override
  String get treatMoveDown => 'Move down';

  @override
  String get treatDelete => 'Delete treat';

  @override
  String get yourNumbers => 'Your numbers';

  @override
  String numberEveningsYes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'evenings answered Yes',
      one: 'evening answered Yes',
    );
    return '$_temp0';
  }

  @override
  String numberContacts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'contacts by you this month',
      one: 'contact by you this month',
    );
    return '$_temp0';
  }

  @override
  String numberPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'different people this month',
      one: 'person this month',
    );
    return '$_temp0';
  }

  @override
  String get niceOneStampsCard => 'Stamps for the card';

  @override
  String get niceOneStampsLoose => 'They wait for your next treat.';

  @override
  String get settingsStamps => 'Stamps';

  @override
  String get settingsStampsHelp =>
      'What a contact is worth. You can rebalance these any time.';

  @override
  String get stampBackInTouch => 'Getting back in touch, extra';

  @override
  String get stampLongGap => 'After a longer gap, extra';

  @override
  String get stampMeetUp => 'Meet-up, times';

  @override
  String get stampGaming => 'Gaming together, times';

  @override
  String get stampCardSize => 'Default card size';

  @override
  String get stampLess => 'Less';

  @override
  String get stampMore => 'More';

  @override
  String get defaultTreat1 => 'Favourite takeaway';

  @override
  String get defaultTreat2 => 'Cinema evening';

  @override
  String get defaultTreat3 => 'Cake from the good bakery';

  @override
  String get defaultTreat4 => 'A new book or game';

  @override
  String get defaultTreat5 => 'A lazy morning with nothing planned';

  @override
  String get defaultTreat6 => 'A day trip';

  @override
  String get defaultTreat7 => 'A concert or event ticket';

  @override
  String get defaultTreat8 => 'Cook something really fancy';

  @override
  String get defaultTreat9 => 'Bake something new';

  @override
  String get defaultTreat10 => 'A new plant or something for the flat';

  @override
  String get defaultTreat11 =>
      'Start a small project you have been putting off';

  @override
  String get defaultTreat12 => 'A class or workshop';

  @override
  String get ideasSection => 'Ideas';

  @override
  String get ideaToDo => 'Do together';

  @override
  String get ideaToTalk => 'Talk about';

  @override
  String get ideaAddHint => 'Add an idea…';

  @override
  String get ideaAdd => 'Add';

  @override
  String ideasDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count done',
      one: '1 done',
    );
    return '$_temp0';
  }

  @override
  String get ideaTickOff => 'Tick off';

  @override
  String get ideaReopen => 'Open again';

  @override
  String get editIdea => 'Edit idea';

  @override
  String get ideaTextHint => 'bouldering hall in Altona…';

  @override
  String get linkHint => 'Link (optional)';

  @override
  String get openLink => 'Open link';

  @override
  String get linkNotOpened => 'Couldn\'t open the link.';

  @override
  String get ideaPicture => 'Picture';

  @override
  String ideaOnPick(String text) {
    return 'Idea: $text';
  }

  @override
  String get shareTitle => 'Keep this for…';

  @override
  String get shareKeepAs => 'Keep it as';

  @override
  String get shareIdeaToDo => 'Idea to do';

  @override
  String get shareIdeaToTalk => 'Idea to talk about';

  @override
  String get shareThought => 'Thought';

  @override
  String get shareTextHint => 'What about it?';

  @override
  String shareSave(String name) {
    return 'Keep for $name';
  }

  @override
  String shareSaved(String name) {
    return 'Kept for $name.';
  }

  @override
  String reconnectTwoWeeks(String name) {
    return 'These two weeks: $name';
  }

  @override
  String reconnectThisMonth(String name) {
    return 'This month: $name';
  }

  @override
  String reconnectTwoMonths(String name) {
    return 'These two months: $name';
  }

  @override
  String reconnectThreeMonths(String name) {
    return 'These three months: $name';
  }

  @override
  String get settingsReconnectSpan => 'Reconnect person for';

  @override
  String get settingsReconnectSpanHelp =>
      'How long the person you chose to get back in touch with stays on the People tab before it asks again.';

  @override
  String weeksInTouch(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks in touch',
      one: '1 week in touch',
    );
    return '$_temp0';
  }

  @override
  String weeksLongest(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Longest so far: $count weeks',
      one: 'Longest so far: 1 week',
    );
    return '$_temp0';
  }

  @override
  String get weeksWho => 'Counts weeks with someone beyond your close friends.';

  @override
  String get weeksOpen => 'This week is still open.';

  @override
  String get weeksEnded =>
      'That run is over. The next week with someone beyond your close friends starts a new one.';

  @override
  String get settingsStreak => 'Weeks in a row';

  @override
  String get settingsStreakHelp =>
      'A week counts when you were in touch with someone beyond your close friends.';

  @override
  String get streakStrict => 'Strict';

  @override
  String get streakFriendly => 'Friendly';

  @override
  String get streakStrictHelp =>
      'A finished week without such a contact ends the run. The next one starts at 1, and the longest run stays.';

  @override
  String get streakFriendlyHelp =>
      'A week without such a contact only pauses the count. It never goes down.';

  @override
  String get stampGamingClose => 'Gaming with close friends, times';

  @override
  String get didItNewDate => 'New date';

  @override
  String get nicePlanTitle => 'Planning to meet up?';

  @override
  String get nicePlanAction => 'Plan it';

  @override
  String get nicePlanHint => 'What? (optional)';

  @override
  String get firstStartSkip => 'Skip';

  @override
  String get fsWelcomeTitle => 'Welcome to Kept.';

  @override
  String get fsWelcomeBody =>
      'Kept. helps you stay in touch with friends and find your way back to old ones. It nudges you gently, so nobody slips away.';

  @override
  String get fsWelcomePrivacy =>
      'Everything you enter stays on this phone. No account, no server.';

  @override
  String get fsStart => 'Let\'s go';

  @override
  String get fsPeopleTitle => 'Add your people';

  @override
  String get fsPeopleBody =>
      'Kept. can read your contacts to copy names, numbers and birthdays. Android asks you for permission first. Nothing is sent anywhere, and you can always add people by hand instead.';

  @override
  String get fsByHandLater => 'Add by hand later';

  @override
  String get classLegendHint => 'Pick one icon for each person:';

  @override
  String get fsEveningTitle => 'A question in the evening';

  @override
  String get fsEveningBody =>
      'Each evening Kept. can ask you one question: is there someone you would like to write to? It comes as a notification at the time you choose.';

  @override
  String get fsEveningOff =>
      'Without it, everything waits on Home for when you open the app.';

  @override
  String get fsEveningAsk =>
      'Switching it on makes Android ask whether Kept. may show notifications.';

  @override
  String get fsContinue => 'Continue';

  @override
  String get fsIncomingTitle => 'Notice who wrote or called';

  @override
  String get fsIncomingBody =>
      'Optional. Kept. can notice when someone from your people writes or calls you in WhatsApp, Telegram, Signal or Discord. It reads who and when, never the text. It needs a special access that you grant in the system settings. Nothing is sent anywhere.';

  @override
  String get incomingWithout =>
      'Without it, you tap “They wrote” or “They called” on a person\'s page yourself.';

  @override
  String get fsNotNow => 'Not now';

  @override
  String get fsDoneTitle => 'You are all set';

  @override
  String get fsDoneBody =>
      'You can change all of this later in Settings, under Permissions and privacy.';

  @override
  String get fsDoneButton => 'Go to Home';

  @override
  String get permTitle => 'Permissions and privacy';

  @override
  String get permRowHelp => 'What Kept. may use, and what for';

  @override
  String get permNothingLeaves =>
      'Everything you enter stays on this phone. No account, no server.';

  @override
  String get permNothingSent => 'Nothing is sent anywhere.';

  @override
  String get permStateAllowed => 'Allowed';

  @override
  String get permStateNotAllowed => 'Not allowed';

  @override
  String get permStateOn => 'On';

  @override
  String get permStateOff => 'Off';

  @override
  String get permStateAlways => 'Always allowed';

  @override
  String get permContactsTitle => 'Contacts (read only)';

  @override
  String get permContactsUse =>
      'Used to import people and to refresh their names, numbers and birthdays. Your contacts are never changed.';

  @override
  String get permContactsWithout => 'Without it: add and edit people by hand.';

  @override
  String get permContactsAllow => 'Allow contacts';

  @override
  String get permNotifTitle => 'Notifications';

  @override
  String get permNotifUse =>
      'Used for the evening question and for birthday reminders. They are made on this phone.';

  @override
  String get permNotifWithout =>
      'Without them, everything shows on Home when you open the app.';

  @override
  String get permBootTitle => 'Start after a restart';

  @override
  String get permBootUse =>
      'Lets the reminders come back after you restart the phone. Android always allows this, so there is no question.';

  @override
  String get permBootWithout =>
      'Without it, reminders would return when you next open the app.';

  @override
  String get permAccessTitle => 'Notification access';

  @override
  String get permAccessUse =>
      'Used to notice who wrote or called you in WhatsApp, Telegram, Signal or Discord. It reads who and when, never the text. Groups and everyone not in your people are left out. A special access that you grant in the system settings.';

  @override
  String get permRefreshTitle => 'Refresh people from contacts';

  @override
  String get permRefreshUse =>
      'Checks the people you imported against your contacts and takes over only the changes you accept.';

  @override
  String get permRefreshButton => 'Refresh people';

  @override
  String get permNotUsedTitle => 'What Kept. does not use';

  @override
  String get permNotUsedList =>
      'Location, microphone, camera, storage and your call log. Kept. never asks for them.';

  @override
  String get refreshTitle => 'Refresh from contacts';

  @override
  String get refreshPersonButton => 'Refresh from contact';

  @override
  String get refreshNothing =>
      'Nothing to update. This person matches the contact.';

  @override
  String get refreshGone =>
      'This contact is not in your address book any more.';

  @override
  String get refreshFieldName => 'Name';

  @override
  String get refreshFieldPhone => 'Phone number';

  @override
  String get refreshFieldBirthday => 'Birthday';

  @override
  String get refreshOld => 'In Kept.';

  @override
  String get refreshNew => 'In contacts';

  @override
  String get refreshNone => 'none';

  @override
  String get refreshApply => 'Update';

  @override
  String get refreshSkip => 'Skip';

  @override
  String get refreshAcceptAll => 'Accept all';

  @override
  String get refreshAllIntro =>
      'Differences found in your contacts. Nothing changes until you accept.';

  @override
  String get refreshAllNothing => 'Everyone is up to date.';

  @override
  String get refreshAllDone => 'All done.';

  @override
  String get settingsAbout => 'About and licences';

  @override
  String get permVibrateTitle => 'Vibrate';

  @override
  String get permVibrateUse =>
      'So a reminder can vibrate. Android always allows this, so there is no question.';

  @override
  String get permVibrateWithout =>
      'Without it, reminders would only make a sound.';
}
