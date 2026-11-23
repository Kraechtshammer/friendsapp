import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Kept.'**
  String get appTitle;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get tabTimeline;

  /// No description provided for @tabPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get tabPeople;

  /// No description provided for @tabProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get tabProgress;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsCatEveningLine.
  ///
  /// In en, this message translates to:
  /// **'Time, days off, one pick or three'**
  String get settingsCatEveningLine;

  /// No description provided for @settingsCatFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get settingsCatFriends;

  /// No description provided for @settingsCatFriendsLine.
  ///
  /// In en, this message translates to:
  /// **'Rhythms, reconnect, incoming messages'**
  String get settingsCatFriendsLine;

  /// No description provided for @settingsCatFriendsLineNoListener.
  ///
  /// In en, this message translates to:
  /// **'Rhythms, reconnect, owed replies'**
  String get settingsCatFriendsLineNoListener;

  /// No description provided for @settingsCatBirthdays.
  ///
  /// In en, this message translates to:
  /// **'Birthdays'**
  String get settingsCatBirthdays;

  /// No description provided for @settingsCatBirthdaysLine.
  ///
  /// In en, this message translates to:
  /// **'Your own birthday'**
  String get settingsCatBirthdaysLine;

  /// No description provided for @settingsCatStamps.
  ///
  /// In en, this message translates to:
  /// **'Stamps and streak'**
  String get settingsCatStamps;

  /// No description provided for @settingsCatStampsLine.
  ///
  /// In en, this message translates to:
  /// **'Stamp values, card size, streak rule'**
  String get settingsCatStampsLine;

  /// No description provided for @settingsCatLook.
  ///
  /// In en, this message translates to:
  /// **'Look'**
  String get settingsCatLook;

  /// No description provided for @settingsCatLookLine.
  ///
  /// In en, this message translates to:
  /// **'Theme and language'**
  String get settingsCatLookLine;

  /// No description provided for @settingsCatUpdatesLine.
  ///
  /// In en, this message translates to:
  /// **'Update check, what\'s new'**
  String get settingsCatUpdatesLine;

  /// No description provided for @settingsCatAboutLine.
  ///
  /// In en, this message translates to:
  /// **'Version and licences'**
  String get settingsCatAboutLine;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @nothingHereYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get nothingHereYet;

  /// No description provided for @peopleTitle.
  ///
  /// In en, this message translates to:
  /// **'Your people'**
  String get peopleTitle;

  /// No description provided for @peopleEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your people will show up here.'**
  String get peopleEmpty;

  /// No description provided for @peopleError.
  ///
  /// In en, this message translates to:
  /// **'Your people could not be loaded.'**
  String get peopleError;

  /// No description provided for @personError.
  ///
  /// In en, this message translates to:
  /// **'This person could not be loaded.'**
  String get personError;

  /// No description provided for @closenessClose.
  ///
  /// In en, this message translates to:
  /// **'Close friend'**
  String get closenessClose;

  /// No description provided for @closenessCloseGroup.
  ///
  /// In en, this message translates to:
  /// **'Close friends'**
  String get closenessCloseGroup;

  /// No description provided for @closenessNowAndThen.
  ///
  /// In en, this message translates to:
  /// **'Now and then'**
  String get closenessNowAndThen;

  /// No description provided for @closenessFewTimesAYear.
  ///
  /// In en, this message translates to:
  /// **'A few times a year'**
  String get closenessFewTimesAYear;

  /// No description provided for @closenessFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get closenessFamily;

  /// No description provided for @reconnecting.
  ///
  /// In en, this message translates to:
  /// **'Getting back in touch'**
  String get reconnecting;

  /// No description provided for @messengerSms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get messengerSms;

  /// No description provided for @openMessenger.
  ///
  /// In en, this message translates to:
  /// **'Open {messenger}'**
  String openMessenger(String messenger);

  /// No description provided for @birthdayDayMonth.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String birthdayDayMonth(DateTime date);

  /// No description provided for @birthdayFull.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String birthdayFull(DateTime date);

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @messengerNotOpened.
  ///
  /// In en, this message translates to:
  /// **'{messenger} could not be opened.'**
  String messengerNotOpened(String messenger);

  /// No description provided for @messengerNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'{name} is not installed on this phone.'**
  String messengerNotInstalled(String name);

  /// No description provided for @addPersonTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a person'**
  String get addPersonTitle;

  /// No description provided for @editPersonTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit person'**
  String get editPersonTitle;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @editLook.
  ///
  /// In en, this message translates to:
  /// **'Look'**
  String get editLook;

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get editName;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Their name'**
  String get nameHint;

  /// No description provided for @editClass.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get editClass;

  /// No description provided for @reconnectingHint.
  ///
  /// In en, this message translates to:
  /// **'A short list of people you want to get back in touch with. On the People tab you pick one for a while. Switch it off when you are back in touch.'**
  String get reconnectingHint;

  /// No description provided for @editMessenger.
  ///
  /// In en, this message translates to:
  /// **'Main messenger'**
  String get editMessenger;

  /// No description provided for @messengerNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get messengerNone;

  /// No description provided for @editReach.
  ///
  /// In en, this message translates to:
  /// **'How to reach them'**
  String get editReach;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'+49…'**
  String get phoneHint;

  /// No description provided for @chatTarget.
  ///
  /// In en, this message translates to:
  /// **'Chat link, username or ID'**
  String get chatTarget;

  /// No description provided for @editMessengerFromContact.
  ///
  /// In en, this message translates to:
  /// **'From the contact'**
  String get editMessengerFromContact;

  /// No description provided for @editMessengerOthers.
  ///
  /// In en, this message translates to:
  /// **'Other apps on this phone'**
  String get editMessengerOthers;

  /// No description provided for @chatTargetHint.
  ///
  /// In en, this message translates to:
  /// **'@name, ID or https://…'**
  String get chatTargetHint;

  /// No description provided for @chatTargetUsed.
  ///
  /// In en, this message translates to:
  /// **'Open goes straight to this chat in {name}.'**
  String chatTargetUsed(String name);

  /// No description provided for @chatTargetProfile.
  ///
  /// In en, this message translates to:
  /// **'Open shows their profile in {name}; the chat is one tap from there.'**
  String chatTargetProfile(String name);

  /// No description provided for @chatTargetNotUnderstood.
  ///
  /// In en, this message translates to:
  /// **'{name} needs a full chat link here, starting with https://.'**
  String chatTargetNotUnderstood(String name);

  /// No description provided for @chatTargetViaContact.
  ///
  /// In en, this message translates to:
  /// **'Without one, Kept. opens the chat through the phone contact.'**
  String get chatTargetViaContact;

  /// No description provided for @chatTargetViaPhone.
  ///
  /// In en, this message translates to:
  /// **'Without one, Kept. opens the chat by the phone number.'**
  String get chatTargetViaPhone;

  /// No description provided for @chatTargetHelpUsername.
  ///
  /// In en, this message translates to:
  /// **'If you have a username or chat link for this person, enter it here. Otherwise Kept. just opens {name}.'**
  String chatTargetHelpUsername(String name);

  /// No description provided for @chatTargetHelpLink.
  ///
  /// In en, this message translates to:
  /// **'If you have a chat link for this person, paste it here. Otherwise Kept. just opens {name}.'**
  String chatTargetHelpLink(String name);

  /// No description provided for @chatLinkHelpButton.
  ///
  /// In en, this message translates to:
  /// **'How do I get a chat link?'**
  String get chatLinkHelpButton;

  /// No description provided for @chatLinkHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat links'**
  String get chatLinkHelpTitle;

  /// No description provided for @chatLinkHelpIntro.
  ///
  /// In en, this message translates to:
  /// **'With a chat link or username, Open goes straight to the chat. For WhatsApp, Signal and Telegram, having the person in your phone\'s contacts with their number is usually enough.'**
  String get chatLinkHelpIntro;

  /// No description provided for @chatLinkHelpTelegram.
  ///
  /// In en, this message translates to:
  /// **'Open their profile. If they have a username, it is shown there (@name). Enter it.'**
  String get chatLinkHelpTelegram;

  /// No description provided for @chatLinkHelpDiscord.
  ///
  /// In en, this message translates to:
  /// **'Open your chat with them, hold any message and tap “Copy Message Link”. Paste it here.'**
  String get chatLinkHelpDiscord;

  /// No description provided for @chatLinkHelpLinkedin.
  ///
  /// In en, this message translates to:
  /// **'Open their profile, tap “Share profile” and copy the link. Paste it, or just the name after /in/. Open starts a new message to them.'**
  String get chatLinkHelpLinkedin;

  /// No description provided for @chatLinkHelpInstagram.
  ///
  /// In en, this message translates to:
  /// **'Open your chat with them. The username is shown at the top. Enter it.'**
  String get chatLinkHelpInstagram;

  /// No description provided for @chatLinkHelpSnapchat.
  ///
  /// In en, this message translates to:
  /// **'The username is on their profile. Snapchat has no link to a chat, so Open shows their profile.'**
  String get chatLinkHelpSnapchat;

  /// No description provided for @chatLinkHelpOthers.
  ///
  /// In en, this message translates to:
  /// **'For other apps, a link the app itself shares for a person may work. Paste it and try Open.'**
  String get chatLinkHelpOthers;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// No description provided for @birthdayDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get birthdayDay;

  /// No description provided for @birthdayMonthField.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get birthdayMonthField;

  /// No description provided for @birthdayYearOptional.
  ///
  /// In en, this message translates to:
  /// **'Year (optional)'**
  String get birthdayYearOptional;

  /// No description provided for @birthdayError.
  ///
  /// In en, this message translates to:
  /// **'Enter a real day and month, or leave all three empty.'**
  String get birthdayError;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Anything worth remembering'**
  String get notesHint;

  /// No description provided for @removePerson.
  ///
  /// In en, this message translates to:
  /// **'Remove this person'**
  String get removePerson;

  /// No description provided for @removeTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String removeTitle(String name);

  /// No description provided for @removeBody.
  ///
  /// In en, this message translates to:
  /// **'Their entry and notes will be deleted. This cannot be undone.'**
  String get removeBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @addMenuContacts.
  ///
  /// In en, this message translates to:
  /// **'From your contacts'**
  String get addMenuContacts;

  /// No description provided for @addMenuByHand.
  ///
  /// In en, this message translates to:
  /// **'By hand'**
  String get addMenuByHand;

  /// No description provided for @addFromContacts.
  ///
  /// In en, this message translates to:
  /// **'Add from contacts'**
  String get addFromContacts;

  /// No description provided for @addByHand.
  ///
  /// In en, this message translates to:
  /// **'Add by hand'**
  String get addByHand;

  /// No description provided for @importPickTitle.
  ///
  /// In en, this message translates to:
  /// **'Who do you want to keep in touch with?'**
  String get importPickTitle;

  /// No description provided for @importPickHint.
  ///
  /// In en, this message translates to:
  /// **'Picking a few is enough. You can add more later.'**
  String get importPickHint;

  /// No description provided for @importSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get importSearchHint;

  /// No description provided for @importDenied.
  ///
  /// In en, this message translates to:
  /// **'Kept needs to read your contacts to offer them here. Nothing leaves your phone.'**
  String get importDenied;

  /// No description provided for @importNoContacts.
  ///
  /// In en, this message translates to:
  /// **'No contacts to show.'**
  String get importNoContacts;

  /// No description provided for @importLoadError.
  ///
  /// In en, this message translates to:
  /// **'Your contacts could not be read.'**
  String get importLoadError;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @importNext.
  ///
  /// In en, this message translates to:
  /// **'Next ({count})'**
  String importNext(int count);

  /// No description provided for @importClassTitle.
  ///
  /// In en, this message translates to:
  /// **'How close are you?'**
  String get importClassTitle;

  /// No description provided for @importMessengerAll.
  ///
  /// In en, this message translates to:
  /// **'Main messenger for all'**
  String get importMessengerAll;

  /// No description provided for @importAdd.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Add 1 person} other{Add {count} people}}'**
  String importAdd(int count);

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingDay.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get greetingDay;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @captureTitle.
  ///
  /// In en, this message translates to:
  /// **'Who\'s on your mind?'**
  String get captureTitle;

  /// No description provided for @captureHint.
  ///
  /// In en, this message translates to:
  /// **'saw a bouldering video…'**
  String get captureHint;

  /// No description provided for @captureHint2.
  ///
  /// In en, this message translates to:
  /// **'ask how the move went…'**
  String get captureHint2;

  /// No description provided for @captureHint3.
  ///
  /// In en, this message translates to:
  /// **'send the photo from the lake…'**
  String get captureHint3;

  /// No description provided for @captureHint4.
  ///
  /// In en, this message translates to:
  /// **'a podcast they would like…'**
  String get captureHint4;

  /// No description provided for @captureHint5.
  ///
  /// In en, this message translates to:
  /// **'congratulate on the new job…'**
  String get captureHint5;

  /// No description provided for @captureHint6.
  ///
  /// In en, this message translates to:
  /// **'ask about their sister…'**
  String get captureHint6;

  /// No description provided for @captureHint7.
  ///
  /// In en, this message translates to:
  /// **'wish luck for the exam…'**
  String get captureHint7;

  /// No description provided for @captureHint8.
  ///
  /// In en, this message translates to:
  /// **'the song from the road trip…'**
  String get captureHint8;

  /// No description provided for @captureHint9.
  ///
  /// In en, this message translates to:
  /// **'ask how the new flat is…'**
  String get captureHint9;

  /// No description provided for @captureHint10.
  ///
  /// In en, this message translates to:
  /// **'send that recipe…'**
  String get captureHint10;

  /// No description provided for @captureHint11.
  ///
  /// In en, this message translates to:
  /// **'a meme they would laugh at…'**
  String get captureHint11;

  /// No description provided for @captureHint12.
  ///
  /// In en, this message translates to:
  /// **'ask how the knee is…'**
  String get captureHint12;

  /// No description provided for @captureMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get captureMore;

  /// No description provided for @kindWrite.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get kindWrite;

  /// No description provided for @kindCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get kindCall;

  /// No description provided for @kindMeet.
  ///
  /// In en, this message translates to:
  /// **'Meet'**
  String get kindMeet;

  /// No description provided for @kindGame.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get kindGame;

  /// No description provided for @captureSave.
  ///
  /// In en, this message translates to:
  /// **'Save for {name}'**
  String captureSave(String name);

  /// No description provided for @captureSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved for {name}.'**
  String captureSaved(String name);

  /// No description provided for @captureNoPeople.
  ///
  /// In en, this message translates to:
  /// **'Add the people you want to keep in touch with first.'**
  String get captureNoPeople;

  /// No description provided for @captureAddPeople.
  ///
  /// In en, this message translates to:
  /// **'Add people'**
  String get captureAddPeople;

  /// No description provided for @onYourMind.
  ///
  /// In en, this message translates to:
  /// **'On your mind'**
  String get onYourMind;

  /// No description provided for @pickerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search people'**
  String get pickerSearchHint;

  /// No description provided for @pickerNoMatch.
  ///
  /// In en, this message translates to:
  /// **'Nobody found.'**
  String get pickerNoMatch;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @drop.
  ///
  /// In en, this message translates to:
  /// **'Drop'**
  String get drop;

  /// No description provided for @shortcutCapture.
  ///
  /// In en, this message translates to:
  /// **'Capture a thought'**
  String get shortcutCapture;

  /// No description provided for @niceOneTitle.
  ///
  /// In en, this message translates to:
  /// **'Nice one!'**
  String get niceOneTitle;

  /// No description provided for @niceOneTitle2.
  ///
  /// In en, this message translates to:
  /// **'Well done!'**
  String get niceOneTitle2;

  /// No description provided for @niceOneTitle3.
  ///
  /// In en, this message translates to:
  /// **'There you go!'**
  String get niceOneTitle3;

  /// No description provided for @niceOneTitle4.
  ///
  /// In en, this message translates to:
  /// **'Look at you!'**
  String get niceOneTitle4;

  /// No description provided for @niceOneTitle5.
  ///
  /// In en, this message translates to:
  /// **'Lovely!'**
  String get niceOneTitle5;

  /// No description provided for @niceOneTitle6.
  ///
  /// In en, this message translates to:
  /// **'That\'s the way!'**
  String get niceOneTitle6;

  /// No description provided for @niceOneTitle7.
  ///
  /// In en, this message translates to:
  /// **'Good one!'**
  String get niceOneTitle7;

  /// No description provided for @niceOneTitle8.
  ///
  /// In en, this message translates to:
  /// **'Yes!'**
  String get niceOneTitle8;

  /// No description provided for @niceOneTitle9.
  ///
  /// In en, this message translates to:
  /// **'Way to go!'**
  String get niceOneTitle9;

  /// No description provided for @niceOneTitle10.
  ///
  /// In en, this message translates to:
  /// **'Beautiful!'**
  String get niceOneTitle10;

  /// No description provided for @niceOneTitle11.
  ///
  /// In en, this message translates to:
  /// **'That\'s it!'**
  String get niceOneTitle11;

  /// No description provided for @niceOneTitle12.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get niceOneTitle12;

  /// No description provided for @niceOneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'That\'s what counts.'**
  String get niceOneSubtitle;

  /// No description provided for @niceOneSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Friendships live on moments like this.'**
  String get niceOneSubtitle2;

  /// No description provided for @niceOneSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Small steps keep people close.'**
  String get niceOneSubtitle3;

  /// No description provided for @niceOneSubtitle4.
  ///
  /// In en, this message translates to:
  /// **'Someone is glad you did.'**
  String get niceOneSubtitle4;

  /// No description provided for @niceOneSubtitle5.
  ///
  /// In en, this message translates to:
  /// **'Another one kept.'**
  String get niceOneSubtitle5;

  /// No description provided for @niceOneSubtitle6.
  ///
  /// In en, this message translates to:
  /// **'That was worth it.'**
  String get niceOneSubtitle6;

  /// No description provided for @niceOneSubtitle7.
  ///
  /// In en, this message translates to:
  /// **'A little contact goes a long way.'**
  String get niceOneSubtitle7;

  /// No description provided for @niceOneSubtitle8.
  ///
  /// In en, this message translates to:
  /// **'You showed up for someone.'**
  String get niceOneSubtitle8;

  /// No description provided for @niceOneSubtitle9.
  ///
  /// In en, this message translates to:
  /// **'That keeps a friendship warm.'**
  String get niceOneSubtitle9;

  /// No description provided for @niceOneSubtitle10.
  ///
  /// In en, this message translates to:
  /// **'Nobody needs more than that.'**
  String get niceOneSubtitle10;

  /// No description provided for @niceOneSubtitle11.
  ///
  /// In en, this message translates to:
  /// **'Small, but it matters.'**
  String get niceOneSubtitle11;

  /// No description provided for @niceOneSubtitle12.
  ///
  /// In en, this message translates to:
  /// **'You made someone\'s day a bit better.'**
  String get niceOneSubtitle12;

  /// No description provided for @activityLabel.
  ///
  /// In en, this message translates to:
  /// **'What did you do?'**
  String get activityLabel;

  /// No description provided for @nextTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'One line for next time?'**
  String get nextTimeLabel;

  /// No description provided for @nextTimeHint.
  ///
  /// In en, this message translates to:
  /// **'new job in March'**
  String get nextTimeHint;

  /// No description provided for @nextTimeHint2.
  ///
  /// In en, this message translates to:
  /// **'ask about the half marathon'**
  String get nextTimeHint2;

  /// No description provided for @nextTimeHint3.
  ///
  /// In en, this message translates to:
  /// **'their cat was ill'**
  String get nextTimeHint3;

  /// No description provided for @nextTimeHint4.
  ///
  /// In en, this message translates to:
  /// **'moving to Leipzig in summer'**
  String get nextTimeHint4;

  /// No description provided for @nextTimeHint5.
  ///
  /// In en, this message translates to:
  /// **'wants to try the new ramen place'**
  String get nextTimeHint5;

  /// No description provided for @nextTimeHint6.
  ///
  /// In en, this message translates to:
  /// **'exam on Friday'**
  String get nextTimeHint6;

  /// No description provided for @nextTimeHint7.
  ///
  /// In en, this message translates to:
  /// **'back from Japan in May'**
  String get nextTimeHint7;

  /// No description provided for @nextTimeHint8.
  ///
  /// In en, this message translates to:
  /// **'started a pottery class'**
  String get nextTimeHint8;

  /// No description provided for @nextTimeHint9.
  ///
  /// In en, this message translates to:
  /// **'kid starts school in autumn'**
  String get nextTimeHint9;

  /// No description provided for @nextTimeHint10.
  ///
  /// In en, this message translates to:
  /// **'looking for a new flat'**
  String get nextTimeHint10;

  /// No description provided for @nextTimeHint11.
  ///
  /// In en, this message translates to:
  /// **'training for a triathlon'**
  String get nextTimeHint11;

  /// No description provided for @nextTimeHint12.
  ///
  /// In en, this message translates to:
  /// **'birthday party on the 12th'**
  String get nextTimeHint12;

  /// No description provided for @remindMe.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get remindMe;

  /// No description provided for @remindMeHelp.
  ///
  /// In en, this message translates to:
  /// **'Also keeps this line as an open thought.'**
  String get remindMeHelp;

  /// No description provided for @niceOneClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get niceOneClose;

  /// No description provided for @lastTime.
  ///
  /// In en, this message translates to:
  /// **'Last time: {note}'**
  String lastTime(String note);

  /// No description provided for @eveningQuestion.
  ///
  /// In en, this message translates to:
  /// **'Got ten minutes for someone today?'**
  String get eveningQuestion;

  /// The evening notification when the reconnect person is its reason. title is for example "This month: Anna".
  ///
  /// In en, this message translates to:
  /// **'{title}. Got ten minutes?'**
  String eveningReconnect(String title);

  /// No description provided for @eveningYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get eveningYes;

  /// No description provided for @eveningNotToday.
  ///
  /// In en, this message translates to:
  /// **'Not today'**
  String get eveningNotToday;

  /// No description provided for @eveningNoReply.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get eveningNoReply;

  /// No description provided for @eveningChannel.
  ///
  /// In en, this message translates to:
  /// **'Evening question'**
  String get eveningChannel;

  /// No description provided for @settingsEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening question'**
  String get settingsEvening;

  /// No description provided for @settingsEveningSwitch.
  ///
  /// In en, this message translates to:
  /// **'Ask me in the evening'**
  String get settingsEveningSwitch;

  /// No description provided for @settingsEveningTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get settingsEveningTime;

  /// No description provided for @settingsEveningDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get settingsEveningDays;

  /// No description provided for @settingsNotificationsOff.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off for Kept.'**
  String get settingsNotificationsOff;

  /// No description provided for @settingsOpenNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Open notification settings'**
  String get settingsOpenNotificationSettings;

  /// No description provided for @settingsOpenItems.
  ///
  /// In en, this message translates to:
  /// **'Open items'**
  String get settingsOpenItems;

  /// No description provided for @settingsOpenItemsHelp.
  ///
  /// In en, this message translates to:
  /// **'How many ideas Home offers for tonight.'**
  String get settingsOpenItemsHelp;

  /// No description provided for @openItemsOne.
  ///
  /// In en, this message translates to:
  /// **'One'**
  String get openItemsOne;

  /// No description provided for @openItemsThree.
  ///
  /// In en, this message translates to:
  /// **'Three'**
  String get openItemsThree;

  /// No description provided for @tonightsPick.
  ///
  /// In en, this message translates to:
  /// **'Tonight\'s pick'**
  String get tonightsPick;

  /// No description provided for @anotherOne.
  ///
  /// In en, this message translates to:
  /// **'Another one'**
  String get anotherOne;

  /// No description provided for @chatQuestionWrite.
  ///
  /// In en, this message translates to:
  /// **'Did you write to {name}?'**
  String chatQuestionWrite(String name);

  /// No description provided for @chatQuestionCall.
  ///
  /// In en, this message translates to:
  /// **'Did you call {name}?'**
  String chatQuestionCall(String name);

  /// No description provided for @chatQuestionMeet.
  ///
  /// In en, this message translates to:
  /// **'Did you meet {name}?'**
  String chatQuestionMeet(String name);

  /// No description provided for @chatQuestionGame.
  ///
  /// In en, this message translates to:
  /// **'Did you game with {name}?'**
  String chatQuestionGame(String name);

  /// No description provided for @chatQuestionOpened.
  ///
  /// In en, this message translates to:
  /// **'You opened {messenger} a moment ago.'**
  String chatQuestionOpened(String messenger);

  /// No description provided for @chatQuestionYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get chatQuestionYes;

  /// No description provided for @chatQuestionNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get chatQuestionNotYet;

  /// No description provided for @chatQuestionHint.
  ///
  /// In en, this message translates to:
  /// **'Not yet is fine. Nothing becomes overdue.'**
  String get chatQuestionHint;

  /// No description provided for @congratulated.
  ///
  /// In en, this message translates to:
  /// **'Congratulated'**
  String get congratulated;

  /// No description provided for @birthdayToday.
  ///
  /// In en, this message translates to:
  /// **'Birthday today'**
  String get birthdayToday;

  /// No description provided for @birthdayTurns.
  ///
  /// In en, this message translates to:
  /// **'Turns {age} today'**
  String birthdayTurns(int age);

  /// No description provided for @chatQuestionBirthday.
  ///
  /// In en, this message translates to:
  /// **'Did you congratulate {name}?'**
  String chatQuestionBirthday(String name);

  /// No description provided for @birthdayNotification.
  ///
  /// In en, this message translates to:
  /// **'It\'s {name}\'s birthday today. Congratulated yet?'**
  String birthdayNotification(String name);

  /// No description provided for @birthdayLateNotification.
  ///
  /// In en, this message translates to:
  /// **'Last hour of {name}\'s birthday'**
  String birthdayLateNotification(String name);

  /// No description provided for @birthdayLateNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Congratulated yet?'**
  String get birthdayLateNotificationBody;

  /// No description provided for @birthdayYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get birthdayYes;

  /// No description provided for @birthdayOpenChat.
  ///
  /// In en, this message translates to:
  /// **'Open chat'**
  String get birthdayOpenChat;

  /// No description provided for @birthdayChannel.
  ///
  /// In en, this message translates to:
  /// **'Birthdays'**
  String get birthdayChannel;

  /// No description provided for @congratulatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Who congratulated you?'**
  String get congratulatedTitle;

  /// No description provided for @congratulatedToday.
  ///
  /// In en, this message translates to:
  /// **'Happy birthday!'**
  String get congratulatedToday;

  /// No description provided for @congratulatedOn.
  ///
  /// In en, this message translates to:
  /// **'Your birthday on {date}'**
  String congratulatedOn(DateTime date);

  /// No description provided for @ownBirthdayCardHint.
  ///
  /// In en, this message translates to:
  /// **'Happy birthday! Note who wished you well.'**
  String get ownBirthdayCardHint;

  /// No description provided for @settingsOwnBirthday.
  ///
  /// In en, this message translates to:
  /// **'Your birthday'**
  String get settingsOwnBirthday;

  /// No description provided for @settingsOwnBirthdayNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get settingsOwnBirthdayNotSet;

  /// No description provided for @whenDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get whenDate;

  /// No description provided for @whenSoon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get whenSoon;

  /// No description provided for @whenLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get whenLater;

  /// No description provided for @whenCondition.
  ///
  /// In en, this message translates to:
  /// **'When…'**
  String get whenCondition;

  /// No description provided for @whenAddTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get whenAddTime;

  /// No description provided for @whenSection.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get whenSection;

  /// No description provided for @whenConditionHint.
  ///
  /// In en, this message translates to:
  /// **'when it is warm again'**
  String get whenConditionHint;

  /// No description provided for @whenConditionHint2.
  ///
  /// In en, this message translates to:
  /// **'when the exams are over'**
  String get whenConditionHint2;

  /// No description provided for @whenConditionHint3.
  ///
  /// In en, this message translates to:
  /// **'after the move'**
  String get whenConditionHint3;

  /// No description provided for @whenConditionHint4.
  ///
  /// In en, this message translates to:
  /// **'when the baby is a bit older'**
  String get whenConditionHint4;

  /// No description provided for @whenConditionHint5.
  ///
  /// In en, this message translates to:
  /// **'when the new season starts'**
  String get whenConditionHint5;

  /// No description provided for @whenConditionHint6.
  ///
  /// In en, this message translates to:
  /// **'when I am in Berlin'**
  String get whenConditionHint6;

  /// No description provided for @whenConditionHint7.
  ///
  /// In en, this message translates to:
  /// **'when the project is done'**
  String get whenConditionHint7;

  /// No description provided for @whenConditionHint8.
  ///
  /// In en, this message translates to:
  /// **'when they are back from travelling'**
  String get whenConditionHint8;

  /// No description provided for @whenConditionHint9.
  ///
  /// In en, this message translates to:
  /// **'when the evenings get longer'**
  String get whenConditionHint9;

  /// No description provided for @whenConditionHint10.
  ///
  /// In en, this message translates to:
  /// **'after the holidays'**
  String get whenConditionHint10;

  /// No description provided for @whenConditionHint11.
  ///
  /// In en, this message translates to:
  /// **'when the snow is here'**
  String get whenConditionHint11;

  /// No description provided for @whenConditionHint12.
  ///
  /// In en, this message translates to:
  /// **'when I have a free weekend'**
  String get whenConditionHint12;

  /// No description provided for @editThought.
  ///
  /// In en, this message translates to:
  /// **'Edit thought'**
  String get editThought;

  /// No description provided for @dateWeekday.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String dateWeekday(DateTime date);

  /// No description provided for @dateMonthShort.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String dateMonthShort(DateTime date);

  /// No description provided for @dateDayNumber.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String dateDayNumber(DateTime date);

  /// No description provided for @dateShort.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String dateShort(DateTime date);

  /// No description provided for @monthLabel.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String monthLabel(DateTime date);

  /// No description provided for @monthYearLabel.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String monthYearLabel(DateTime date);

  /// No description provided for @timeShort.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String timeShort(DateTime date);

  /// No description provided for @timelineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What is coming and what happened. Nothing here is ever late.'**
  String get timelineSubtitle;

  /// No description provided for @pastEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet. Calls, meet-ups, gaming and birthdays will show up here.'**
  String get pastEmpty;

  /// No description provided for @upcomingEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing dated yet. Birthdays and the dates you set will show up here.'**
  String get upcomingEmpty;

  /// No description provided for @groupThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get groupThisWeek;

  /// No description provided for @groupNextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get groupNextWeek;

  /// No description provided for @groupEarlierThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Earlier this week'**
  String get groupEarlierThisWeek;

  /// No description provided for @groupLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get groupLastWeek;

  /// No description provided for @turnedAge.
  ///
  /// In en, this message translates to:
  /// **'Turned {age}'**
  String turnedAge(int age);

  /// No description provided for @wishesFrom.
  ///
  /// In en, this message translates to:
  /// **'Wishes from {names}'**
  String wishesFrom(String names);

  /// No description provided for @birthdayOf.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s birthday'**
  String birthdayOf(String name);

  /// No description provided for @turnsAge.
  ///
  /// In en, this message translates to:
  /// **'Turns {age}'**
  String turnsAge(int age);

  /// No description provided for @noDateYet.
  ///
  /// In en, this message translates to:
  /// **'No date yet'**
  String get noDateYet;

  /// No description provided for @pickADate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get pickADate;

  /// No description provided for @comingUp.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get comingUp;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @didItHappen.
  ///
  /// In en, this message translates to:
  /// **'Did it happen?'**
  String get didItHappen;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @wantSetDate.
  ///
  /// In en, this message translates to:
  /// **'Want to set a date with {name}?'**
  String wantSetDate(String name);

  /// No description provided for @setADate.
  ///
  /// In en, this message translates to:
  /// **'Set a date'**
  String get setADate;

  /// No description provided for @timelineToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get timelineToday;

  /// No description provided for @youWrote.
  ///
  /// In en, this message translates to:
  /// **'You wrote'**
  String get youWrote;

  /// No description provided for @youTexted.
  ///
  /// In en, this message translates to:
  /// **'You texted'**
  String get youTexted;

  /// No description provided for @theyWrote.
  ///
  /// In en, this message translates to:
  /// **'{name} wrote'**
  String theyWrote(String name);

  /// No description provided for @youCalled.
  ///
  /// In en, this message translates to:
  /// **'You called'**
  String get youCalled;

  /// No description provided for @theyCalled.
  ///
  /// In en, this message translates to:
  /// **'{name} called'**
  String theyCalled(String name);

  /// No description provided for @youMet.
  ///
  /// In en, this message translates to:
  /// **'You met'**
  String get youMet;

  /// No description provided for @youGamed.
  ///
  /// In en, this message translates to:
  /// **'You gamed together'**
  String get youGamed;

  /// No description provided for @addedToYourPeople.
  ///
  /// In en, this message translates to:
  /// **'Added to your people'**
  String get addedToYourPeople;

  /// No description provided for @youCongratulatedAndTexted.
  ///
  /// In en, this message translates to:
  /// **'You congratulated and texted'**
  String get youCongratulatedAndTexted;

  /// No description provided for @youCongratulated.
  ///
  /// In en, this message translates to:
  /// **'You congratulated'**
  String get youCongratulated;

  /// No description provided for @yourBirthday.
  ///
  /// In en, this message translates to:
  /// **'Your birthday'**
  String get yourBirthday;

  /// No description provided for @congratulatedYou.
  ///
  /// In en, this message translates to:
  /// **'{name} congratulated you'**
  String congratulatedYou(String name);

  /// No description provided for @buttonTheyWrote.
  ///
  /// In en, this message translates to:
  /// **'They wrote'**
  String get buttonTheyWrote;

  /// No description provided for @buttonTheyCalled.
  ///
  /// In en, this message translates to:
  /// **'They called'**
  String get buttonTheyCalled;

  /// No description provided for @buttonWeWereInTouch.
  ///
  /// In en, this message translates to:
  /// **'We were in touch'**
  String get buttonWeWereInTouch;

  /// No description provided for @logContactTitle.
  ///
  /// In en, this message translates to:
  /// **'I was in touch with {name}'**
  String logContactTitle(String name);

  /// No description provided for @logContactWhat.
  ///
  /// In en, this message translates to:
  /// **'What'**
  String get logContactWhat;

  /// No description provided for @logContactWith.
  ///
  /// In en, this message translates to:
  /// **'With'**
  String get logContactWith;

  /// No description provided for @logAddPerson.
  ///
  /// In en, this message translates to:
  /// **'Add person'**
  String get logAddPerson;

  /// No description provided for @logPickPeople.
  ///
  /// In en, this message translates to:
  /// **'Who else was there?'**
  String get logPickPeople;

  /// No description provided for @namesAnd.
  ///
  /// In en, this message translates to:
  /// **'{rest} and {last}'**
  String namesAnd(String rest, String last);

  /// No description provided for @logKindWrote.
  ///
  /// In en, this message translates to:
  /// **'Texted'**
  String get logKindWrote;

  /// No description provided for @logKindCalled.
  ///
  /// In en, this message translates to:
  /// **'Called'**
  String get logKindCalled;

  /// No description provided for @logKindMet.
  ///
  /// In en, this message translates to:
  /// **'Met'**
  String get logKindMet;

  /// No description provided for @logKindGamed.
  ///
  /// In en, this message translates to:
  /// **'Gamed'**
  String get logKindGamed;

  /// No description provided for @logDayYesterdayShort.
  ///
  /// In en, this message translates to:
  /// **'Yday'**
  String get logDayYesterdayShort;

  /// No description provided for @logDayPickShort.
  ///
  /// In en, this message translates to:
  /// **'Pick'**
  String get logDayPickShort;

  /// No description provided for @pickerChosen.
  ///
  /// In en, this message translates to:
  /// **'{count} chosen'**
  String pickerChosen(int count);

  /// No description provided for @capturePickPeople.
  ///
  /// In en, this message translates to:
  /// **'Pick people'**
  String get capturePickPeople;

  /// No description provided for @logDayYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get logDayYesterday;

  /// No description provided for @logDayPick.
  ///
  /// In en, this message translates to:
  /// **'Pick a day'**
  String get logDayPick;

  /// No description provided for @notedTheyWrote.
  ///
  /// In en, this message translates to:
  /// **'Noted: {name} wrote'**
  String notedTheyWrote(String name);

  /// No description provided for @notedTheyCalled.
  ///
  /// In en, this message translates to:
  /// **'Noted: {name} called'**
  String notedTheyCalled(String name);

  /// No description provided for @alreadyNoted.
  ///
  /// In en, this message translates to:
  /// **'Already noted for today'**
  String get alreadyNoted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @editEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get editEntry;

  /// No description provided for @entryActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get entryActivity;

  /// No description provided for @entryNote.
  ///
  /// In en, this message translates to:
  /// **'Note for next time'**
  String get entryNote;

  /// No description provided for @deleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry'**
  String get deleteEntry;

  /// No description provided for @deleteEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get deleteEntryTitle;

  /// No description provided for @deleteEntryBody.
  ///
  /// In en, this message translates to:
  /// **'It disappears from the timeline.'**
  String get deleteEntryBody;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @dateDayMonth.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String dateDayMonth(DateTime date);

  /// No description provided for @dateDayMonthYear.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String dateDayMonthYear(DateTime date);

  /// No description provided for @stillOweReply.
  ///
  /// In en, this message translates to:
  /// **'Still owe {name} a reply?'**
  String stillOweReply(String name);

  /// No description provided for @alreadyAnswered.
  ///
  /// In en, this message translates to:
  /// **'Already answered'**
  String get alreadyAnswered;

  /// No description provided for @settingsIncoming.
  ///
  /// In en, this message translates to:
  /// **'Incoming messages'**
  String get settingsIncoming;

  /// No description provided for @settingsIncomingSwitch.
  ///
  /// In en, this message translates to:
  /// **'Notice who wrote or called'**
  String get settingsIncomingSwitch;

  /// No description provided for @settingsIncomingHelp.
  ///
  /// In en, this message translates to:
  /// **'Kept reads the notifications of WhatsApp, Telegram, Signal and Discord to see who from your people wrote or called you, and when. It never reads what they wrote. Group chats and everyone else are left out.'**
  String get settingsIncomingHelp;

  /// No description provided for @settingsIncomingAccess.
  ///
  /// In en, this message translates to:
  /// **'Notification access'**
  String get settingsIncomingAccess;

  /// No description provided for @settingsIncomingAccessOn.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get settingsIncomingAccessOn;

  /// No description provided for @settingsIncomingAccessOff.
  ///
  /// In en, this message translates to:
  /// **'Not allowed yet'**
  String get settingsIncomingAccessOff;

  /// No description provided for @settingsIncomingOpenAccess.
  ///
  /// In en, this message translates to:
  /// **'Open notification access'**
  String get settingsIncomingOpenAccess;

  /// No description provided for @settingsReplyWait.
  ///
  /// In en, this message translates to:
  /// **'Ask about a reply after'**
  String get settingsReplyWait;

  /// No description provided for @replyWaitDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String replyWaitDays(int count);

  /// No description provided for @shorter.
  ///
  /// In en, this message translates to:
  /// **'Shorter'**
  String get shorter;

  /// No description provided for @longer.
  ///
  /// In en, this message translates to:
  /// **'Longer'**
  String get longer;

  /// No description provided for @settingsRhythms.
  ///
  /// In en, this message translates to:
  /// **'Rhythms'**
  String get settingsRhythms;

  /// No description provided for @settingsRhythmsHelp.
  ///
  /// In en, this message translates to:
  /// **'How long it can be before Kept suggests getting in touch. It only ever gives a gentle hint.'**
  String get settingsRhythmsHelp;

  /// No description provided for @rhythmNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get rhythmNone;

  /// No description provided for @rhythmLikeClass.
  ///
  /// In en, this message translates to:
  /// **'Like the class'**
  String get rhythmLikeClass;

  /// No description provided for @rhythmWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 week} other{{count} weeks}}'**
  String rhythmWeeks(int count);

  /// No description provided for @rhythmMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month} other{{count} months}}'**
  String rhythmMonths(int count);

  /// No description provided for @rhythmDaysCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String rhythmDaysCount(int count);

  /// No description provided for @editRhythm.
  ///
  /// In en, this message translates to:
  /// **'Rhythm'**
  String get editRhythm;

  /// No description provided for @editRhythmHelp.
  ///
  /// In en, this message translates to:
  /// **'How often you would like to be in touch. It only gives a gentle hint, never a deadline.'**
  String get editRhythmHelp;

  /// No description provided for @hintPick.
  ///
  /// In en, this message translates to:
  /// **'It\'s been a while with {name}'**
  String hintPick(String name);

  /// No description provided for @reconnectThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week: {name}'**
  String reconnectThisWeek(String name);

  /// No description provided for @reconnectChoose.
  ///
  /// In en, this message translates to:
  /// **'Who do you want to get back in touch with now?'**
  String get reconnectChoose;

  /// No description provided for @reconnectCardHint.
  ///
  /// In en, this message translates to:
  /// **'Old friends pick up where they left off.'**
  String get reconnectCardHint;

  /// No description provided for @someoneElse.
  ///
  /// In en, this message translates to:
  /// **'Someone else'**
  String get someoneElse;

  /// No description provided for @reconnectDone.
  ///
  /// In en, this message translates to:
  /// **'You got in touch with {name}.'**
  String reconnectDone(String name);

  /// No description provided for @backInTouchTitle.
  ///
  /// In en, this message translates to:
  /// **'You and {name} are back in touch.'**
  String backInTouchTitle(String name);

  /// No description provided for @backInTouchKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep as getting back in touch'**
  String get backInTouchKeep;

  /// No description provided for @progressStampsLine.
  ///
  /// In en, this message translates to:
  /// **'Stamps so far. This number only ever grows.'**
  String get progressStampsLine;

  /// No description provided for @stampCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Treat stamp card'**
  String get stampCardTitle;

  /// No description provided for @myTreats.
  ///
  /// In en, this message translates to:
  /// **'My treats'**
  String get myTreats;

  /// No description provided for @stampCardChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose your next treat'**
  String get stampCardChoose;

  /// No description provided for @stampCardChooseHint.
  ///
  /// In en, this message translates to:
  /// **'Stamps you earn now wait for the card you start.'**
  String get stampCardChooseHint;

  /// No description provided for @stampCardLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{One more stamp and it is yours.} other{{count} more stamps and it is yours.}}'**
  String stampCardLeft(int count);

  /// No description provided for @stampCardSemantics.
  ///
  /// In en, this message translates to:
  /// **'{filled} of {total} stamps'**
  String stampCardSemantics(int filled, int total);

  /// No description provided for @progressThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get progressThisWeek;

  /// No description provided for @progressThisWeekEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nobody yet this week. The week is still long.'**
  String get progressThisWeekEmpty;

  /// No description provided for @weeksInARow.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 week in a row} other{{count} weeks in a row}}'**
  String weeksInARow(int count);

  /// No description provided for @weeksNote.
  ///
  /// In en, this message translates to:
  /// **'This week counts.'**
  String get weeksNote;

  /// No description provided for @weeksPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused this week so far. Nothing is lost.'**
  String get weeksPaused;

  /// No description provided for @weeksNone.
  ///
  /// In en, this message translates to:
  /// **'No weeks yet. Your first contact starts them.'**
  String get weeksNone;

  /// No description provided for @treatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Treats'**
  String get treatsTitle;

  /// No description provided for @treatStamps.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 stamp} other{{count} stamps}}'**
  String treatStamps(int count);

  /// No description provided for @treatsWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get treatsWaiting;

  /// No description provided for @treatsEarned.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get treatsEarned;

  /// No description provided for @treatsEnjoyed.
  ///
  /// In en, this message translates to:
  /// **'Enjoyed'**
  String get treatsEnjoyed;

  /// No description provided for @treatStart.
  ///
  /// In en, this message translates to:
  /// **'Start this card'**
  String get treatStart;

  /// No description provided for @treatEnjoyedButton.
  ///
  /// In en, this message translates to:
  /// **'Enjoyed'**
  String get treatEnjoyedButton;

  /// No description provided for @treatEarnedTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} is yours!'**
  String treatEarnedTitle(String name);

  /// No description provided for @treatEarnedBody.
  ///
  /// In en, this message translates to:
  /// **'You filled the card. Go and enjoy it.'**
  String get treatEarnedBody;

  /// No description provided for @treatFull.
  ///
  /// In en, this message translates to:
  /// **'Full!'**
  String get treatFull;

  /// No description provided for @treatAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a treat'**
  String get treatAdd;

  /// No description provided for @treatEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit treat'**
  String get treatEdit;

  /// No description provided for @treatNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get treatNameLabel;

  /// No description provided for @treatStampsLabel.
  ///
  /// In en, this message translates to:
  /// **'Stamps needed'**
  String get treatStampsLabel;

  /// No description provided for @treatMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get treatMoveUp;

  /// No description provided for @treatMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get treatMoveDown;

  /// No description provided for @treatDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete treat'**
  String get treatDelete;

  /// No description provided for @yourNumbers.
  ///
  /// In en, this message translates to:
  /// **'Your numbers'**
  String get yourNumbers;

  /// No description provided for @numberEveningsYes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{evening answered Yes} other{evenings answered Yes}}'**
  String numberEveningsYes(int count);

  /// No description provided for @numberContacts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{contact by you this month} other{contacts by you this month}}'**
  String numberContacts(int count);

  /// No description provided for @numberPeople.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{person this month} other{different people this month}}'**
  String numberPeople(int count);

  /// No description provided for @niceOneStampsCard.
  ///
  /// In en, this message translates to:
  /// **'Stamps for the card'**
  String get niceOneStampsCard;

  /// No description provided for @niceOneStampsLoose.
  ///
  /// In en, this message translates to:
  /// **'They wait for your next treat.'**
  String get niceOneStampsLoose;

  /// No description provided for @settingsStamps.
  ///
  /// In en, this message translates to:
  /// **'Stamps'**
  String get settingsStamps;

  /// No description provided for @settingsStampsHelp.
  ///
  /// In en, this message translates to:
  /// **'What a contact is worth. You can rebalance these any time.'**
  String get settingsStampsHelp;

  /// No description provided for @stampBackInTouch.
  ///
  /// In en, this message translates to:
  /// **'Getting back in touch, extra'**
  String get stampBackInTouch;

  /// No description provided for @stampLongGap.
  ///
  /// In en, this message translates to:
  /// **'After a longer gap, extra'**
  String get stampLongGap;

  /// No description provided for @stampMeetUp.
  ///
  /// In en, this message translates to:
  /// **'Meet-up, times'**
  String get stampMeetUp;

  /// No description provided for @stampGaming.
  ///
  /// In en, this message translates to:
  /// **'Gaming together, times'**
  String get stampGaming;

  /// No description provided for @stampCardSize.
  ///
  /// In en, this message translates to:
  /// **'Default card size'**
  String get stampCardSize;

  /// No description provided for @stampLess.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get stampLess;

  /// No description provided for @stampMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get stampMore;

  /// No description provided for @defaultTreat1.
  ///
  /// In en, this message translates to:
  /// **'Favourite takeaway'**
  String get defaultTreat1;

  /// No description provided for @defaultTreat2.
  ///
  /// In en, this message translates to:
  /// **'Cinema evening'**
  String get defaultTreat2;

  /// No description provided for @defaultTreat3.
  ///
  /// In en, this message translates to:
  /// **'Cake from the good bakery'**
  String get defaultTreat3;

  /// No description provided for @defaultTreat4.
  ///
  /// In en, this message translates to:
  /// **'A new book or game'**
  String get defaultTreat4;

  /// No description provided for @defaultTreat5.
  ///
  /// In en, this message translates to:
  /// **'A lazy morning with nothing planned'**
  String get defaultTreat5;

  /// No description provided for @defaultTreat6.
  ///
  /// In en, this message translates to:
  /// **'A day trip'**
  String get defaultTreat6;

  /// No description provided for @defaultTreat7.
  ///
  /// In en, this message translates to:
  /// **'A concert or event ticket'**
  String get defaultTreat7;

  /// No description provided for @defaultTreat8.
  ///
  /// In en, this message translates to:
  /// **'Cook something really fancy'**
  String get defaultTreat8;

  /// No description provided for @defaultTreat9.
  ///
  /// In en, this message translates to:
  /// **'Bake something new'**
  String get defaultTreat9;

  /// No description provided for @defaultTreat10.
  ///
  /// In en, this message translates to:
  /// **'A new plant or something for the flat'**
  String get defaultTreat10;

  /// No description provided for @defaultTreat11.
  ///
  /// In en, this message translates to:
  /// **'Start a small project you have been putting off'**
  String get defaultTreat11;

  /// No description provided for @defaultTreat12.
  ///
  /// In en, this message translates to:
  /// **'A class or workshop'**
  String get defaultTreat12;

  /// No description provided for @ideasSection.
  ///
  /// In en, this message translates to:
  /// **'Ideas'**
  String get ideasSection;

  /// No description provided for @ideaToDo.
  ///
  /// In en, this message translates to:
  /// **'Do together'**
  String get ideaToDo;

  /// No description provided for @ideaToTalk.
  ///
  /// In en, this message translates to:
  /// **'Talk about'**
  String get ideaToTalk;

  /// No description provided for @ideaAddHint.
  ///
  /// In en, this message translates to:
  /// **'Add an idea…'**
  String get ideaAddHint;

  /// No description provided for @ideaAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get ideaAdd;

  /// No description provided for @ideasDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 done} other{{count} done}}'**
  String ideasDone(int count);

  /// No description provided for @ideaTickOff.
  ///
  /// In en, this message translates to:
  /// **'Tick off'**
  String get ideaTickOff;

  /// No description provided for @ideaReopen.
  ///
  /// In en, this message translates to:
  /// **'Open again'**
  String get ideaReopen;

  /// No description provided for @editIdea.
  ///
  /// In en, this message translates to:
  /// **'Edit idea'**
  String get editIdea;

  /// No description provided for @ideaTextHint.
  ///
  /// In en, this message translates to:
  /// **'bouldering hall in Altona…'**
  String get ideaTextHint;

  /// No description provided for @ideaTextHint2.
  ///
  /// In en, this message translates to:
  /// **'board game café…'**
  String get ideaTextHint2;

  /// No description provided for @ideaTextHint3.
  ///
  /// In en, this message translates to:
  /// **'the jazz night on Thursdays…'**
  String get ideaTextHint3;

  /// No description provided for @ideaTextHint4.
  ///
  /// In en, this message translates to:
  /// **'a walk around the lake…'**
  String get ideaTextHint4;

  /// No description provided for @ideaTextHint5.
  ///
  /// In en, this message translates to:
  /// **'cook that curry together…'**
  String get ideaTextHint5;

  /// No description provided for @ideaTextHint6.
  ///
  /// In en, this message translates to:
  /// **'the new Pixar film…'**
  String get ideaTextHint6;

  /// No description provided for @ideaTextHint7.
  ///
  /// In en, this message translates to:
  /// **'the flea market on Sunday…'**
  String get ideaTextHint7;

  /// No description provided for @ideaTextHint8.
  ///
  /// In en, this message translates to:
  /// **'karaoke bar…'**
  String get ideaTextHint8;

  /// No description provided for @ideaTextHint9.
  ///
  /// In en, this message translates to:
  /// **'go swimming in the lake…'**
  String get ideaTextHint9;

  /// No description provided for @ideaTextHint10.
  ///
  /// In en, this message translates to:
  /// **'the Christmas market…'**
  String get ideaTextHint10;

  /// No description provided for @ideaTextHint11.
  ///
  /// In en, this message translates to:
  /// **'escape room…'**
  String get ideaTextHint11;

  /// No description provided for @ideaTextHint12.
  ///
  /// In en, this message translates to:
  /// **'a picnic in the park…'**
  String get ideaTextHint12;

  /// No description provided for @linkHint.
  ///
  /// In en, this message translates to:
  /// **'Link (optional)'**
  String get linkHint;

  /// No description provided for @openLink.
  ///
  /// In en, this message translates to:
  /// **'Open link'**
  String get openLink;

  /// No description provided for @linkNotOpened.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the link.'**
  String get linkNotOpened;

  /// No description provided for @ideaPicture.
  ///
  /// In en, this message translates to:
  /// **'Picture'**
  String get ideaPicture;

  /// No description provided for @ideaOnPick.
  ///
  /// In en, this message translates to:
  /// **'Idea: {text}'**
  String ideaOnPick(String text);

  /// No description provided for @shareTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep this for…'**
  String get shareTitle;

  /// No description provided for @shareKeepAs.
  ///
  /// In en, this message translates to:
  /// **'Keep it as'**
  String get shareKeepAs;

  /// No description provided for @shareIdeaToDo.
  ///
  /// In en, this message translates to:
  /// **'Idea to do'**
  String get shareIdeaToDo;

  /// No description provided for @shareIdeaToTalk.
  ///
  /// In en, this message translates to:
  /// **'Idea to talk about'**
  String get shareIdeaToTalk;

  /// No description provided for @shareThought.
  ///
  /// In en, this message translates to:
  /// **'Thought'**
  String get shareThought;

  /// No description provided for @shareTextHint.
  ///
  /// In en, this message translates to:
  /// **'What about it?'**
  String get shareTextHint;

  /// No description provided for @shareSave.
  ///
  /// In en, this message translates to:
  /// **'Keep for {name}'**
  String shareSave(String name);

  /// No description provided for @shareSaved.
  ///
  /// In en, this message translates to:
  /// **'Kept for {name}.'**
  String shareSaved(String name);

  /// No description provided for @reconnectTwoWeeks.
  ///
  /// In en, this message translates to:
  /// **'These two weeks: {name}'**
  String reconnectTwoWeeks(String name);

  /// No description provided for @reconnectThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month: {name}'**
  String reconnectThisMonth(String name);

  /// No description provided for @reconnectTwoMonths.
  ///
  /// In en, this message translates to:
  /// **'These two months: {name}'**
  String reconnectTwoMonths(String name);

  /// No description provided for @reconnectThreeMonths.
  ///
  /// In en, this message translates to:
  /// **'These three months: {name}'**
  String reconnectThreeMonths(String name);

  /// No description provided for @settingsReconnectSpan.
  ///
  /// In en, this message translates to:
  /// **'Reconnect person for'**
  String get settingsReconnectSpan;

  /// No description provided for @settingsReconnectSpanHelp.
  ///
  /// In en, this message translates to:
  /// **'How long the person you chose to get back in touch with stays on the People tab before it asks again.'**
  String get settingsReconnectSpanHelp;

  /// No description provided for @weeksInTouch.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 week in touch} other{{count} weeks in touch}}'**
  String weeksInTouch(int count);

  /// No description provided for @weeksLongest.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Longest so far: 1 week} other{Longest so far: {count} weeks}}'**
  String weeksLongest(int count);

  /// No description provided for @weeksWho.
  ///
  /// In en, this message translates to:
  /// **'Counts weeks with someone beyond your close friends.'**
  String get weeksWho;

  /// No description provided for @weeksOpen.
  ///
  /// In en, this message translates to:
  /// **'This week is still open.'**
  String get weeksOpen;

  /// No description provided for @weeksEnded.
  ///
  /// In en, this message translates to:
  /// **'That run is over. The next week with someone beyond your close friends starts a new one.'**
  String get weeksEnded;

  /// No description provided for @settingsStreak.
  ///
  /// In en, this message translates to:
  /// **'Weeks in a row'**
  String get settingsStreak;

  /// No description provided for @settingsStreakHelp.
  ///
  /// In en, this message translates to:
  /// **'A week counts when you were in touch with someone beyond your close friends.'**
  String get settingsStreakHelp;

  /// No description provided for @streakStrict.
  ///
  /// In en, this message translates to:
  /// **'Strict'**
  String get streakStrict;

  /// No description provided for @streakFriendly.
  ///
  /// In en, this message translates to:
  /// **'Friendly'**
  String get streakFriendly;

  /// No description provided for @streakStrictHelp.
  ///
  /// In en, this message translates to:
  /// **'A finished week without such a contact ends the run. The next one starts at 1, and the longest run stays.'**
  String get streakStrictHelp;

  /// No description provided for @streakFriendlyHelp.
  ///
  /// In en, this message translates to:
  /// **'A week without such a contact only pauses the count. It never goes down.'**
  String get streakFriendlyHelp;

  /// No description provided for @stampGamingClose.
  ///
  /// In en, this message translates to:
  /// **'Gaming with close friends, times'**
  String get stampGamingClose;

  /// No description provided for @didItNewDate.
  ///
  /// In en, this message translates to:
  /// **'New date'**
  String get didItNewDate;

  /// No description provided for @nicePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Planning to meet up?'**
  String get nicePlanTitle;

  /// No description provided for @nicePlanAction.
  ///
  /// In en, this message translates to:
  /// **'Plan it'**
  String get nicePlanAction;

  /// No description provided for @nicePlanHint.
  ///
  /// In en, this message translates to:
  /// **'What? (optional)'**
  String get nicePlanHint;

  /// No description provided for @firstStartSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get firstStartSkip;

  /// No description provided for @fsWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Kept.'**
  String get fsWelcomeTitle;

  /// No description provided for @fsWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Kept. helps you stay in touch with friends and find your way back to old ones. It nudges you gently, so nobody slips away.'**
  String get fsWelcomeBody;

  /// No description provided for @fsWelcomePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Everything you enter stays on this phone. No account, no server. The only thing Kept. ever fetches is the version check from GitHub, and only if you switch it on.'**
  String get fsWelcomePrivacy;

  /// No description provided for @fsStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go'**
  String get fsStart;

  /// No description provided for @fsPeopleTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your people'**
  String get fsPeopleTitle;

  /// No description provided for @fsPeopleBody.
  ///
  /// In en, this message translates to:
  /// **'Kept. can read your contacts to copy names, numbers and birthdays. Android asks you for permission first. Nothing is sent anywhere, and you can always add people by hand instead.'**
  String get fsPeopleBody;

  /// No description provided for @fsByHandLater.
  ///
  /// In en, this message translates to:
  /// **'Add by hand later'**
  String get fsByHandLater;

  /// No description provided for @classLegendHint.
  ///
  /// In en, this message translates to:
  /// **'Pick one icon for each person:'**
  String get classLegendHint;

  /// No description provided for @fsEveningTitle.
  ///
  /// In en, this message translates to:
  /// **'A question in the evening'**
  String get fsEveningTitle;

  /// No description provided for @fsEveningBody.
  ///
  /// In en, this message translates to:
  /// **'Each evening Kept. can ask you one question: is there someone you would like to write to? It comes as a notification at the time you choose.'**
  String get fsEveningBody;

  /// No description provided for @fsEveningOff.
  ///
  /// In en, this message translates to:
  /// **'Without it, everything waits on Home for when you open the app.'**
  String get fsEveningOff;

  /// No description provided for @fsEveningAsk.
  ///
  /// In en, this message translates to:
  /// **'Switching it on makes Android ask whether Kept. may show notifications.'**
  String get fsEveningAsk;

  /// No description provided for @fsContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get fsContinue;

  /// No description provided for @fsIncomingTitle.
  ///
  /// In en, this message translates to:
  /// **'Notice who wrote or called'**
  String get fsIncomingTitle;

  /// No description provided for @fsIncomingBody.
  ///
  /// In en, this message translates to:
  /// **'Optional. Kept. can notice when someone from your people writes or calls you in WhatsApp, Telegram, Signal or Discord. It reads who and when, never the text. It needs a special access that you grant in the system settings. Nothing is sent anywhere.'**
  String get fsIncomingBody;

  /// No description provided for @incomingWithout.
  ///
  /// In en, this message translates to:
  /// **'Without it, you tap “They wrote” or “They called” on a person\'s page yourself.'**
  String get incomingWithout;

  /// No description provided for @fsNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get fsNotNow;

  /// No description provided for @fsDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'You are all set'**
  String get fsDoneTitle;

  /// No description provided for @fsDoneBody.
  ///
  /// In en, this message translates to:
  /// **'You can change all of this later in Settings, under Permissions and privacy.'**
  String get fsDoneBody;

  /// No description provided for @fsDoneButton.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get fsDoneButton;

  /// No description provided for @permTitle.
  ///
  /// In en, this message translates to:
  /// **'Permissions and privacy'**
  String get permTitle;

  /// No description provided for @permRowHelp.
  ///
  /// In en, this message translates to:
  /// **'What Kept. may use, and what for'**
  String get permRowHelp;

  /// No description provided for @permNothingLeaves.
  ///
  /// In en, this message translates to:
  /// **'Everything you enter stays on this phone. No account, no server. The only thing Kept. ever fetches is the version check from GitHub, and only if you switch it on.'**
  String get permNothingLeaves;

  /// No description provided for @permNothingSent.
  ///
  /// In en, this message translates to:
  /// **'Nothing is sent anywhere.'**
  String get permNothingSent;

  /// No description provided for @permStateAllowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get permStateAllowed;

  /// No description provided for @permStateNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Not allowed'**
  String get permStateNotAllowed;

  /// No description provided for @permStateOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get permStateOn;

  /// No description provided for @permStateOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get permStateOff;

  /// No description provided for @permStateAlways.
  ///
  /// In en, this message translates to:
  /// **'Always allowed'**
  String get permStateAlways;

  /// No description provided for @permContactsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contacts (read only)'**
  String get permContactsTitle;

  /// No description provided for @permContactsUse.
  ///
  /// In en, this message translates to:
  /// **'Used to import people and to refresh their names, numbers and birthdays. Your contacts are never changed.'**
  String get permContactsUse;

  /// No description provided for @permContactsWithout.
  ///
  /// In en, this message translates to:
  /// **'Without it: add and edit people by hand.'**
  String get permContactsWithout;

  /// No description provided for @permContactsAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow contacts'**
  String get permContactsAllow;

  /// No description provided for @permNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get permNotifTitle;

  /// No description provided for @permNotifUse.
  ///
  /// In en, this message translates to:
  /// **'Used for the evening question and for birthday reminders. They are made on this phone.'**
  String get permNotifUse;

  /// No description provided for @permNotifWithout.
  ///
  /// In en, this message translates to:
  /// **'Without them, everything shows on Home when you open the app.'**
  String get permNotifWithout;

  /// No description provided for @permBootTitle.
  ///
  /// In en, this message translates to:
  /// **'Start after a restart'**
  String get permBootTitle;

  /// No description provided for @permBootUse.
  ///
  /// In en, this message translates to:
  /// **'Lets the reminders come back after you restart the phone. Android always allows this, so there is no question.'**
  String get permBootUse;

  /// No description provided for @permBootWithout.
  ///
  /// In en, this message translates to:
  /// **'Without it, reminders would return when you next open the app.'**
  String get permBootWithout;

  /// No description provided for @permAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification access'**
  String get permAccessTitle;

  /// No description provided for @permAccessUse.
  ///
  /// In en, this message translates to:
  /// **'Used to notice who wrote or called you in WhatsApp, Telegram, Signal or Discord. It reads who and when, never the text. Groups and everyone not in your people are left out. A special access that you grant in the system settings.'**
  String get permAccessUse;

  /// No description provided for @permRefreshTitle.
  ///
  /// In en, this message translates to:
  /// **'Refresh people from contacts'**
  String get permRefreshTitle;

  /// No description provided for @permRefreshUse.
  ///
  /// In en, this message translates to:
  /// **'Checks the people you imported against your contacts and takes over only the changes you accept.'**
  String get permRefreshUse;

  /// No description provided for @permRefreshButton.
  ///
  /// In en, this message translates to:
  /// **'Refresh people'**
  String get permRefreshButton;

  /// No description provided for @permNotUsedTitle.
  ///
  /// In en, this message translates to:
  /// **'What Kept. does not use'**
  String get permNotUsedTitle;

  /// No description provided for @permNotUsedList.
  ///
  /// In en, this message translates to:
  /// **'Location, microphone, camera, storage and your call log. Kept. never asks for them.'**
  String get permNotUsedList;

  /// No description provided for @refreshTitle.
  ///
  /// In en, this message translates to:
  /// **'Refresh from contacts'**
  String get refreshTitle;

  /// No description provided for @refreshPersonButton.
  ///
  /// In en, this message translates to:
  /// **'Refresh from contact'**
  String get refreshPersonButton;

  /// No description provided for @refreshNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing to update. This person matches the contact.'**
  String get refreshNothing;

  /// No description provided for @refreshGone.
  ///
  /// In en, this message translates to:
  /// **'This contact is not in your address book any more.'**
  String get refreshGone;

  /// No description provided for @refreshFieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get refreshFieldName;

  /// No description provided for @refreshFieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get refreshFieldPhone;

  /// No description provided for @refreshFieldBirthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get refreshFieldBirthday;

  /// No description provided for @refreshOld.
  ///
  /// In en, this message translates to:
  /// **'In Kept.'**
  String get refreshOld;

  /// No description provided for @refreshNew.
  ///
  /// In en, this message translates to:
  /// **'In contacts'**
  String get refreshNew;

  /// No description provided for @refreshNone.
  ///
  /// In en, this message translates to:
  /// **'none'**
  String get refreshNone;

  /// No description provided for @refreshApply.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get refreshApply;

  /// No description provided for @refreshSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get refreshSkip;

  /// No description provided for @refreshAcceptAll.
  ///
  /// In en, this message translates to:
  /// **'Accept all'**
  String get refreshAcceptAll;

  /// No description provided for @refreshAllIntro.
  ///
  /// In en, this message translates to:
  /// **'Differences found in your contacts. Nothing changes until you accept.'**
  String get refreshAllIntro;

  /// No description provided for @refreshAllNothing.
  ///
  /// In en, this message translates to:
  /// **'Everyone is up to date.'**
  String get refreshAllNothing;

  /// No description provided for @refreshAllDone.
  ///
  /// In en, this message translates to:
  /// **'All done.'**
  String get refreshAllDone;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About and licences'**
  String get settingsAbout;

  /// No description provided for @permVibrateTitle.
  ///
  /// In en, this message translates to:
  /// **'Vibrate'**
  String get permVibrateTitle;

  /// No description provided for @permVibrateUse.
  ///
  /// In en, this message translates to:
  /// **'So a reminder can vibrate. Android always allows this, so there is no question.'**
  String get permVibrateUse;

  /// No description provided for @permVibrateWithout.
  ///
  /// In en, this message translates to:
  /// **'Without it, reminders would only make a sound.'**
  String get permVibrateWithout;

  /// No description provided for @updateSection.
  ///
  /// In en, this message translates to:
  /// **'App update'**
  String get updateSection;

  /// No description provided for @updateSwitch.
  ///
  /// In en, this message translates to:
  /// **'Check GitHub for new versions'**
  String get updateSwitch;

  /// No description provided for @updateOff.
  ///
  /// In en, this message translates to:
  /// **'The check is off. Kept. makes no internet requests. You can update by hand from the releases page.'**
  String get updateOff;

  /// No description provided for @updateReleasesPage.
  ///
  /// In en, this message translates to:
  /// **'Releases on GitHub'**
  String get updateReleasesPage;

  /// No description provided for @updateReleasesPageHint.
  ///
  /// In en, this message translates to:
  /// **'Opens the browser. Download the newest APK there to update by hand.'**
  String get updateReleasesPageHint;

  /// No description provided for @updateAskTitle.
  ///
  /// In en, this message translates to:
  /// **'Check GitHub for new versions?'**
  String get updateAskTitle;

  /// No description provided for @updateAskBody.
  ///
  /// In en, this message translates to:
  /// **'Kept. can ask GitHub which version is the newest, and download and install it for you. Only that request goes out; none of your data is ever sent. You can always update by hand from GitHub instead. Android will ask once whether Kept. may install apps.'**
  String get updateAskBody;

  /// No description provided for @updateCheck.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get updateCheck;

  /// No description provided for @updateStatusChecked.
  ///
  /// In en, this message translates to:
  /// **'Version {version} · up to date, checked {time}'**
  String updateStatusChecked(String version, String time);

  /// No description provided for @updateStatusNotChecked.
  ///
  /// In en, this message translates to:
  /// **'Version {version} · not checked yet'**
  String updateStatusNotChecked(String version);

  /// No description provided for @updateChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates…'**
  String get updateChecking;

  /// No description provided for @updateUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Kept. is up to date.'**
  String get updateUpToDate;

  /// No description provided for @updateAvailableTile.
  ///
  /// In en, this message translates to:
  /// **'Update to version {version}'**
  String updateAvailableTile(String version);

  /// No description provided for @updateAvailableHint.
  ///
  /// In en, this message translates to:
  /// **'See what\'s new and install'**
  String get updateAvailableHint;

  /// No description provided for @updateDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading… {percent}%'**
  String updateDownloading(int percent);

  /// No description provided for @updateInstalling.
  ///
  /// In en, this message translates to:
  /// **'Confirm the installation in the Android window. Kept. closes meanwhile; just open it again afterwards.'**
  String get updateInstalling;

  /// No description provided for @updateCloseHint.
  ///
  /// In en, this message translates to:
  /// **'Kept. closes during the update. Just open it again afterwards.'**
  String get updateCloseHint;

  /// No description provided for @updateRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart update'**
  String get updateRestart;

  /// No description provided for @updateRestartHint.
  ///
  /// In en, this message translates to:
  /// **'If the installation got stuck or failed'**
  String get updateRestartHint;

  /// No description provided for @updateDeleteFile.
  ///
  /// In en, this message translates to:
  /// **'Delete update file'**
  String get updateDeleteFile;

  /// No description provided for @updateFileSize.
  ///
  /// In en, this message translates to:
  /// **'Uses {size}'**
  String updateFileSize(String size);

  /// No description provided for @updateNoFile.
  ///
  /// In en, this message translates to:
  /// **'No file stored'**
  String get updateNoFile;

  /// No description provided for @updateFileDeleted.
  ///
  /// In en, this message translates to:
  /// **'Update file deleted'**
  String get updateFileDeleted;

  /// No description provided for @updateDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Update to version {version}'**
  String updateDialogTitle(String version);

  /// No description provided for @updateNotesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Small improvements behind the scenes.'**
  String get updateNotesEmpty;

  /// No description provided for @notesNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get notesNew;

  /// No description provided for @notesFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get notesFixed;

  /// No description provided for @notesImproved.
  ///
  /// In en, this message translates to:
  /// **'Improved'**
  String get notesImproved;

  /// No description provided for @updateInstall.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateInstall;

  /// No description provided for @updateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLater;

  /// No description provided for @updateClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get updateClose;

  /// No description provided for @updateCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'GitHub can\'t be reached right now. Try again later.'**
  String get updateCheckFailed;

  /// No description provided for @updateDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'The download didn\'t work. Please try again.'**
  String get updateDownloadFailed;

  /// No description provided for @updateNoPermission.
  ///
  /// In en, this message translates to:
  /// **'Kept. isn\'t allowed to install apps yet. Allow it in Android\'s settings, then tap “Update” again.'**
  String get updateNoPermission;

  /// No description provided for @updateAborted.
  ///
  /// In en, this message translates to:
  /// **'Update cancelled.'**
  String get updateAborted;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Android refused the update.'**
  String get updateFailed;

  /// No description provided for @whatsNewTile.
  ///
  /// In en, this message translates to:
  /// **'What\'s new'**
  String get whatsNewTile;

  /// No description provided for @whatsNewTileHint.
  ///
  /// In en, this message translates to:
  /// **'The changes in version {version}'**
  String whatsNewTileHint(String version);

  /// No description provided for @whatsNewTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s new in version {version}'**
  String whatsNewTitle(String version);

  /// No description provided for @whatsNewFailed.
  ///
  /// In en, this message translates to:
  /// **'The changes can\'t be loaded right now. Try again later.'**
  String get whatsNewFailed;

  /// No description provided for @whatsNewEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier versions'**
  String get whatsNewEarlier;

  /// No description provided for @whatsNewVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String whatsNewVersion(String version);

  /// No description provided for @permUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update check'**
  String get permUpdateTitle;

  /// No description provided for @permUpdateUse.
  ///
  /// In en, this message translates to:
  /// **'Asks GitHub which version of Kept. is the newest, on start and when you come back to the app, at most every 30 minutes. Uses two permissions: internet access, and installing apps, which Android asks for when the first update is installed.'**
  String get permUpdateUse;

  /// No description provided for @permUpdateSent.
  ///
  /// In en, this message translates to:
  /// **'Only that request goes to GitHub. None of your data is ever sent.'**
  String get permUpdateSent;

  /// No description provided for @permUpdateWithout.
  ///
  /// In en, this message translates to:
  /// **'Without it: download the newest APK from GitHub yourself (Settings, Releases on GitHub).'**
  String get permUpdateWithout;

  /// No description provided for @editNickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get editNickname;

  /// No description provided for @nicknameHint.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get nicknameHint;

  /// No description provided for @nicknameHelper.
  ///
  /// In en, this message translates to:
  /// **'Shown instead of the name.'**
  String get nicknameHelper;

  /// No description provided for @choosePicture.
  ///
  /// In en, this message translates to:
  /// **'Choose picture'**
  String get choosePicture;

  /// No description provided for @pictureFromContact.
  ///
  /// In en, this message translates to:
  /// **'From contact'**
  String get pictureFromContact;

  /// No description provided for @removePicture.
  ///
  /// In en, this message translates to:
  /// **'Remove picture'**
  String get removePicture;

  /// No description provided for @pictureTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: share a photo from any app into Kept. to use it as someone\'s picture.'**
  String get pictureTip;

  /// No description provided for @refreshFieldPicture.
  ///
  /// In en, this message translates to:
  /// **'Picture'**
  String get refreshFieldPicture;

  /// No description provided for @refreshPictureFromContact.
  ///
  /// In en, this message translates to:
  /// **'The contact\'s picture'**
  String get refreshPictureFromContact;

  /// No description provided for @pictureCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Add pictures from your contacts?'**
  String get pictureCardTitle;

  /// No description provided for @pictureCardBody.
  ///
  /// In en, this message translates to:
  /// **'Kept. takes the picture of each linked contact that has one. Nothing leaves your phone.'**
  String get pictureCardBody;

  /// No description provided for @pictureCardAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get pictureCardAdd;

  /// No description provided for @pictureCardNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get pictureCardNotNow;

  /// No description provided for @picturesAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No pictures found in your contacts} =1{Added 1 picture} other{Added {count} pictures}}'**
  String picturesAdded(int count);

  /// No description provided for @cropTitle.
  ///
  /// In en, this message translates to:
  /// **'Fit the picture'**
  String get cropTitle;

  /// No description provided for @cropHint.
  ///
  /// In en, this message translates to:
  /// **'Drag and pinch. Double-tap to zoom.'**
  String get cropHint;

  /// No description provided for @cropUse.
  ///
  /// In en, this message translates to:
  /// **'Use picture'**
  String get cropUse;

  /// No description provided for @cropSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get cropSaving;

  /// No description provided for @cropFailed.
  ///
  /// In en, this message translates to:
  /// **'That picture could not be read.'**
  String get cropFailed;

  /// No description provided for @sharePictureTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s this picture for?'**
  String get sharePictureTitle;

  /// No description provided for @shareUseAsPicture.
  ///
  /// In en, this message translates to:
  /// **'Use as someone\'s picture'**
  String get shareUseAsPicture;

  /// No description provided for @shareUseAsPictureLine.
  ///
  /// In en, this message translates to:
  /// **'Pick a friend, fit it, done'**
  String get shareUseAsPictureLine;

  /// No description provided for @shareKeepAsIdea.
  ///
  /// In en, this message translates to:
  /// **'Keep as an idea'**
  String get shareKeepAsIdea;

  /// No description provided for @shareKeepAsIdeaLine.
  ///
  /// In en, this message translates to:
  /// **'Save it with a note on a friend\'s page'**
  String get shareKeepAsIdeaLine;

  /// No description provided for @shareLastTime.
  ///
  /// In en, this message translates to:
  /// **'Last time'**
  String get shareLastTime;

  /// No description provided for @shareWhoseTitle.
  ///
  /// In en, this message translates to:
  /// **'Whose picture is this?'**
  String get shareWhoseTitle;

  /// No description provided for @shareFindFriend.
  ///
  /// In en, this message translates to:
  /// **'Find a friend'**
  String get shareFindFriend;

  /// No description provided for @shareNoPictureYet.
  ///
  /// In en, this message translates to:
  /// **'No picture yet'**
  String get shareNoPictureYet;

  /// No description provided for @shareHasPicture.
  ///
  /// In en, this message translates to:
  /// **'Has a picture'**
  String get shareHasPicture;

  /// No description provided for @shareNobodyFound.
  ///
  /// In en, this message translates to:
  /// **'Nobody found.'**
  String get shareNobodyFound;

  /// No description provided for @shareDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Looks good!'**
  String get shareDoneTitle;

  /// No description provided for @shareDoneLine.
  ///
  /// In en, this message translates to:
  /// **'{name} has a new picture.'**
  String shareDoneLine(String name);

  /// No description provided for @shareStillNoPicture.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 friend still has no picture} other{{count} friends still have no picture}}'**
  String shareStillNoPicture(num count);

  /// No description provided for @shareAllHavePicture.
  ///
  /// In en, this message translates to:
  /// **'Everyone has a picture now.'**
  String get shareAllHavePicture;

  /// No description provided for @shareDoneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get shareDoneButton;

  /// No description provided for @tipSharePicture.
  ///
  /// In en, this message translates to:
  /// **'Tip: share a photo from your gallery into Kept. to use it as someone\'s picture.'**
  String get tipSharePicture;

  /// No description provided for @tipStepPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get tipStepPhoto;

  /// No description provided for @tipStepShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get tipStepShare;

  /// No description provided for @fsDonePictureTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: share a photo from your gallery into Kept. to give a friend a picture.'**
  String get fsDonePictureTip;

  /// No description provided for @shareDoneTag.
  ///
  /// In en, this message translates to:
  /// **'New!'**
  String get shareDoneTag;

  /// No description provided for @partnerLabel.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get partnerLabel;

  /// No description provided for @partnerLink.
  ///
  /// In en, this message translates to:
  /// **'Link a partner'**
  String get partnerLink;

  /// No description provided for @partnerHelp.
  ///
  /// In en, this message translates to:
  /// **'Two people who are linked show as a couple. Both stay separate people.'**
  String get partnerHelp;

  /// No description provided for @partnerUnlink.
  ///
  /// In en, this message translates to:
  /// **'Unlink'**
  String get partnerUnlink;

  /// No description provided for @partnerUnlinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlink {a} and {b}?'**
  String partnerUnlinkTitle(String a, String b);

  /// No description provided for @partnerUnlinkBody.
  ///
  /// In en, this message translates to:
  /// **'They show as two people again. Open thoughts for both of them go to each of them. Meetings you logged together stay on both timelines.'**
  String get partnerUnlinkBody;

  /// No description provided for @coupleWith.
  ///
  /// In en, this message translates to:
  /// **'with {name}'**
  String coupleWith(String name);

  /// No description provided for @coupleAlsoChanges.
  ///
  /// In en, this message translates to:
  /// **'Also changes {name}\'s timeline'**
  String coupleAlsoChanges(String name);

  /// No description provided for @coupleThoughtForBoth.
  ///
  /// In en, this message translates to:
  /// **'Thought for both'**
  String get coupleThoughtForBoth;

  /// No description provided for @coupleWeMet.
  ///
  /// In en, this message translates to:
  /// **'We met'**
  String get coupleWeMet;

  /// No description provided for @coupleTogether.
  ///
  /// In en, this message translates to:
  /// **'Time together'**
  String get coupleTogether;

  /// No description provided for @coupleNothingTogether.
  ///
  /// In en, this message translates to:
  /// **'Nothing together yet.'**
  String get coupleNothingTogether;

  /// No description provided for @coupleOpenChat.
  ///
  /// In en, this message translates to:
  /// **'Open chat'**
  String get coupleOpenChat;

  /// No description provided for @coupleChatWho.
  ///
  /// In en, this message translates to:
  /// **'Who do you want to message?'**
  String get coupleChatWho;

  /// No description provided for @removeCoupleLine.
  ///
  /// In en, this message translates to:
  /// **'Their link as a couple goes too.'**
  String get removeCoupleLine;

  /// No description provided for @niceOneStampsOf.
  ///
  /// In en, this message translates to:
  /// **'{name} +{count}'**
  String niceOneStampsOf(String name, int count);

  /// No description provided for @activityIconButton.
  ///
  /// In en, this message translates to:
  /// **'Icon for the activity'**
  String get activityIconButton;

  /// No description provided for @activityIconPick.
  ///
  /// In en, this message translates to:
  /// **'Pick an icon'**
  String get activityIconPick;

  /// No description provided for @activityIconNone.
  ///
  /// In en, this message translates to:
  /// **'No icon'**
  String get activityIconNone;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
