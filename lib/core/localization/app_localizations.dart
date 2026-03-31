import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
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
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'The Archive'**
  String get appTitle;

  /// No description provided for @onboardingHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your thoughts.\nOnly yours.'**
  String get onboardingHeadline;

  /// No description provided for @onboardingSub.
  ///
  /// In en, this message translates to:
  /// **'Encrypted sync. Your journal stays yours.'**
  String get onboardingSub;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'GET STARTED'**
  String get getStarted;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In en, this message translates to:
  /// **'Write freely'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Body.
  ///
  /// In en, this message translates to:
  /// **'Capture moods, tags, and moments in a calm editorial space.'**
  String get onboardingPage2Body;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In en, this message translates to:
  /// **'Find & reflect'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Body.
  ///
  /// In en, this message translates to:
  /// **'Search the archive, browse the calendar, and read your insights.'**
  String get onboardingPage3Body;

  /// No description provided for @archiveTitle.
  ///
  /// In en, this message translates to:
  /// **'The Archive'**
  String get archiveTitle;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, Journaler'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, Journaler'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, Journaler'**
  String get goodEvening;

  /// No description provided for @captureThoughts.
  ///
  /// In en, this message translates to:
  /// **'Capture your thoughts'**
  String get captureThoughts;

  /// No description provided for @captureThoughtsBody.
  ///
  /// In en, this message translates to:
  /// **'A blank page is an invitation to clarity. What\'s on your mind?'**
  String get captureThoughtsBody;

  /// No description provided for @startWriting.
  ///
  /// In en, this message translates to:
  /// **'Start Writing'**
  String get startWriting;

  /// No description provided for @reflectToday.
  ///
  /// In en, this message translates to:
  /// **'Reflect on today'**
  String get reflectToday;

  /// No description provided for @recentArchive.
  ///
  /// In en, this message translates to:
  /// **'The Recent Archive'**
  String get recentArchive;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @newEntry.
  ///
  /// In en, this message translates to:
  /// **'New Entry'**
  String get newEntry;

  /// No description provided for @autoSaving.
  ///
  /// In en, this message translates to:
  /// **'Auto-saving…'**
  String get autoSaving;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @writeThoughts.
  ///
  /// In en, this message translates to:
  /// **'Write your thoughts…'**
  String get writeThoughts;

  /// No description provided for @mood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get mood;

  /// No description provided for @addTags.
  ///
  /// In en, this message translates to:
  /// **'Add #tags…'**
  String get addTags;

  /// No description provided for @entryDetail.
  ///
  /// In en, this message translates to:
  /// **'Entry'**
  String get entryDetail;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get deleteConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @timelineView.
  ///
  /// In en, this message translates to:
  /// **'Timeline view'**
  String get timelineView;

  /// No description provided for @entriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 ENTRIES} =1{1 ENTRY} other{{count} ENTRIES}}'**
  String entriesCount(int count);

  /// No description provided for @searchYourThoughts.
  ///
  /// In en, this message translates to:
  /// **'Search your thoughts…'**
  String get searchYourThoughts;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @silenceInLibrary.
  ///
  /// In en, this message translates to:
  /// **'Silence in the library…'**
  String get silenceInLibrary;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No entries match your search. Try broader keywords.'**
  String get noSearchResults;

  /// No description provided for @popularMoods.
  ///
  /// In en, this message translates to:
  /// **'Popular moods'**
  String get popularMoods;

  /// No description provided for @recentExplorations.
  ///
  /// In en, this message translates to:
  /// **'Recent explorations'**
  String get recentExplorations;

  /// No description provided for @weeklyOverview.
  ///
  /// In en, this message translates to:
  /// **'Weekly overview'**
  String get weeklyOverview;

  /// No description provided for @weeklyWroteDays.
  ///
  /// In en, this message translates to:
  /// **'You wrote {days} days this week.'**
  String weeklyWroteDays(int days);

  /// No description provided for @weeklyConsistency.
  ///
  /// In en, this message translates to:
  /// **'Your reflections are becoming more consistent.'**
  String get weeklyConsistency;

  /// No description provided for @moodRhythm.
  ///
  /// In en, this message translates to:
  /// **'Mood rhythm'**
  String get moodRhythm;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @avgWordsPerDay.
  ///
  /// In en, this message translates to:
  /// **'Avg words / day'**
  String get avgWordsPerDay;

  /// No description provided for @words.
  ///
  /// In en, this message translates to:
  /// **'words'**
  String get words;

  /// No description provided for @themes.
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get themes;

  /// No description provided for @frequentlyTagged.
  ///
  /// In en, this message translates to:
  /// **'Frequently tagged'**
  String get frequentlyTagged;

  /// No description provided for @totalEntries.
  ///
  /// In en, this message translates to:
  /// **'Total entries'**
  String get totalEntries;

  /// No description provided for @moodDistribution.
  ///
  /// In en, this message translates to:
  /// **'Mood distribution'**
  String get moodDistribution;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure your private sanctuary'**
  String get settingsSubtitle;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @passcodeLock.
  ///
  /// In en, this message translates to:
  /// **'Passcode lock'**
  String get passcodeLock;

  /// No description provided for @passcodeLockDesc.
  ///
  /// In en, this message translates to:
  /// **'Require a PIN to open the app'**
  String get passcodeLockDesc;

  /// No description provided for @biometricAuth.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication'**
  String get biometricAuth;

  /// No description provided for @biometricAuthDesc.
  ///
  /// In en, this message translates to:
  /// **'Use Face ID or Touch ID'**
  String get biometricAuthDesc;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageTurkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data management'**
  String get dataManagement;

  /// No description provided for @exportTxt.
  ///
  /// In en, this message translates to:
  /// **'Export as TXT'**
  String get exportTxt;

  /// No description provided for @resetLocalData.
  ///
  /// In en, this message translates to:
  /// **'Reset local data'**
  String get resetLocalData;

  /// No description provided for @resetLocalDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove all journal entries stored on this device? This cannot be undone.'**
  String get resetLocalDataConfirm;

  /// No description provided for @privacyFirst.
  ///
  /// In en, this message translates to:
  /// **'Privacy first'**
  String get privacyFirst;

  /// No description provided for @privacyQuote.
  ///
  /// In en, this message translates to:
  /// **'Your journal is designed to stay under your control.'**
  String get privacyQuote;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Memoirly v{version}'**
  String versionLabel(String version);

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter passcode to unlock your thoughts'**
  String get enterPin;

  /// No description provided for @useBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics'**
  String get useBiometrics;

  /// No description provided for @forgotPin.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN'**
  String get forgotPin;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @setPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Create PIN'**
  String get setPinTitle;

  /// No description provided for @confirmPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPinTitle;

  /// No description provided for @pinsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match'**
  String get pinsDoNotMatch;

  /// No description provided for @wrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN'**
  String get wrongPin;

  /// No description provided for @faceId.
  ///
  /// In en, this message translates to:
  /// **'Face ID'**
  String get faceId;

  /// No description provided for @signInAnonymously.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get signInAnonymously;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in. Check network and Firebase configuration.'**
  String get authError;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @privateSanctuary.
  ///
  /// In en, this message translates to:
  /// **'Private sanctuary'**
  String get privateSanctuary;

  /// No description provided for @entryNo.
  ///
  /// In en, this message translates to:
  /// **'Entry no. {n}'**
  String entryNo(int n);

  /// No description provided for @shareEntry.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareEntry;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @moodPeaceful.
  ///
  /// In en, this message translates to:
  /// **'Peaceful'**
  String get moodPeaceful;

  /// No description provided for @moodReflective.
  ///
  /// In en, this message translates to:
  /// **'Reflective'**
  String get moodReflective;

  /// No description provided for @moodProductive.
  ///
  /// In en, this message translates to:
  /// **'Productive'**
  String get moodProductive;

  /// No description provided for @moodAnxious.
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get moodAnxious;

  /// No description provided for @moodGrateful.
  ///
  /// In en, this message translates to:
  /// **'Grateful'**
  String get moodGrateful;

  /// No description provided for @moodSerene.
  ///
  /// In en, this message translates to:
  /// **'Serene'**
  String get moodSerene;

  /// No description provided for @moodMelancholic.
  ///
  /// In en, this message translates to:
  /// **'Melancholic'**
  String get moodMelancholic;

  /// No description provided for @moodInspired.
  ///
  /// In en, this message translates to:
  /// **'Inspired'**
  String get moodInspired;

  /// No description provided for @moodQuiet.
  ///
  /// In en, this message translates to:
  /// **'Quiet'**
  String get moodQuiet;

  /// No description provided for @moodNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get moodNeutral;

  /// No description provided for @moodJoyful.
  ///
  /// In en, this message translates to:
  /// **'Joyful'**
  String get moodJoyful;

  /// No description provided for @moodLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get moodLow;

  /// No description provided for @moodCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get moodCalm;

  /// No description provided for @moodStressed.
  ///
  /// In en, this message translates to:
  /// **'Stressed'**
  String get moodStressed;

  /// No description provided for @selectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select month'**
  String get selectMonth;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @emptyJournal.
  ///
  /// In en, this message translates to:
  /// **'No entries yet. Start writing.'**
  String get emptyJournal;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'Title (optional)'**
  String get titleHint;
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
