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

  /// No description provided for @tabUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get tabUpcoming;

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

  /// No description provided for @messengerWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get messengerWhatsapp;

  /// No description provided for @messengerTelegram.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get messengerTelegram;

  /// No description provided for @messengerSignal.
  ///
  /// In en, this message translates to:
  /// **'Signal'**
  String get messengerSignal;

  /// No description provided for @messengerDiscord.
  ///
  /// In en, this message translates to:
  /// **'Discord'**
  String get messengerDiscord;

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

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

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
  /// **'For people you want to get back in touch with.'**
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

  /// No description provided for @telegramUsername.
  ///
  /// In en, this message translates to:
  /// **'Telegram user name'**
  String get telegramUsername;

  /// No description provided for @signalLink.
  ///
  /// In en, this message translates to:
  /// **'Signal link'**
  String get signalLink;

  /// No description provided for @discordUserId.
  ///
  /// In en, this message translates to:
  /// **'Discord user ID'**
  String get discordUserId;

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
