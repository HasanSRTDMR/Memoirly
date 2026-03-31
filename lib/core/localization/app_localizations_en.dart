// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'The Archive';

  @override
  String get onboardingHeadline => 'Your thoughts.\nOnly yours.';

  @override
  String get onboardingSub => 'Encrypted sync. Your journal stays yours.';

  @override
  String get skip => 'SKIP';

  @override
  String get next => 'NEXT';

  @override
  String get getStarted => 'GET STARTED';

  @override
  String get onboardingPage2Title => 'Write freely';

  @override
  String get onboardingPage2Body =>
      'Capture moods, tags, and moments in a calm editorial space.';

  @override
  String get onboardingPage3Title => 'Find & reflect';

  @override
  String get onboardingPage3Body =>
      'Search the archive, browse the calendar, and read your insights.';

  @override
  String get archiveTitle => 'The Archive';

  @override
  String get menu => 'Menu';

  @override
  String get account => 'Account';

  @override
  String get goodMorning => 'Good morning, Journaler';

  @override
  String get goodAfternoon => 'Good afternoon, Journaler';

  @override
  String get goodEvening => 'Good evening, Journaler';

  @override
  String get captureThoughts => 'Capture your thoughts';

  @override
  String get captureThoughtsBody =>
      'A blank page is an invitation to clarity. What\'s on your mind?';

  @override
  String get startWriting => 'Start Writing';

  @override
  String get reflectToday => 'Reflect on today';

  @override
  String get recentArchive => 'The Recent Archive';

  @override
  String get home => 'Home';

  @override
  String get search => 'Search';

  @override
  String get calendar => 'Calendar';

  @override
  String get insights => 'Insights';

  @override
  String get settings => 'Settings';

  @override
  String get newEntry => 'New Entry';

  @override
  String get entrySaving => 'Saving…';

  @override
  String get entrySaved => 'Saved';

  @override
  String get entryAutoSaveHint => 'Saves as you write';

  @override
  String get doneClose => 'Done';

  @override
  String get save => 'Save';

  @override
  String get writeThoughts => 'Write your thoughts…';

  @override
  String get mood => 'Mood';

  @override
  String get addTags => '#tag or comma-separated (e.g. tatil, yaz)';

  @override
  String get addImage => 'Add image';

  @override
  String get textColor => 'Text color';

  @override
  String get textColorDefault => 'Default';

  @override
  String get entryDetail => 'Entry';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get deleteConfirmTitle => 'Delete entry?';

  @override
  String get deleteConfirmBody => 'This cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get timelineView => 'Timeline view';

  @override
  String entriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ENTRIES',
      one: '1 ENTRY',
      zero: '0 ENTRIES',
    );
    return '$_temp0';
  }

  @override
  String get searchYourThoughts => 'Search your thoughts…';

  @override
  String get tags => 'Tags';

  @override
  String get date => 'Date';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get silenceInLibrary => 'Silence in the library…';

  @override
  String get noSearchResults =>
      'No entries match your search. Try broader keywords.';

  @override
  String get popularMoods => 'Popular moods';

  @override
  String get recentExplorations => 'Recent explorations';

  @override
  String get weeklyOverview => 'Weekly overview';

  @override
  String weeklyWroteDays(int days) {
    return 'You wrote $days days this week.';
  }

  @override
  String get weeklyConsistency =>
      'Your reflections are becoming more consistent.';

  @override
  String get moodRhythm => 'Mood rhythm';

  @override
  String get last7Days => 'Last 7 days';

  @override
  String get volume => 'Volume';

  @override
  String get avgWordsPerDay => 'Avg words / day';

  @override
  String get words => 'words';

  @override
  String get themes => 'Themes';

  @override
  String get frequentlyTagged => 'Frequently tagged';

  @override
  String get totalEntries => 'Total entries';

  @override
  String get moodDistribution => 'Mood distribution';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Configure your private sanctuary';

  @override
  String get security => 'Security';

  @override
  String get passcodeLock => 'Passcode lock';

  @override
  String get passcodeLockDesc => 'Require a PIN to open the app';

  @override
  String get biometricAuth => 'Biometric authentication';

  @override
  String get biometricAuthDesc => 'Use Face ID or Touch ID';

  @override
  String get appearance => 'Appearance';

  @override
  String get lightMode => 'Light mode';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get dataManagement => 'Data management';

  @override
  String get exportTxt => 'Export as TXT';

  @override
  String get resetLocalData => 'Reset local data';

  @override
  String get resetLocalDataConfirm =>
      'Remove all journal entries stored on this device? This cannot be undone.';

  @override
  String get privacyFirst => 'Privacy first';

  @override
  String get privacyQuote =>
      'Your journal is designed to stay under your control.';

  @override
  String versionLabel(String version) {
    return 'Memoirly v$version';
  }

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get enterPin => 'Enter passcode to unlock your thoughts';

  @override
  String get useBiometrics => 'Use biometrics';

  @override
  String get forgotPin => 'Forgot PIN';

  @override
  String get emergency => 'Emergency';

  @override
  String get setPinTitle => 'Create PIN';

  @override
  String get confirmPinTitle => 'Confirm PIN';

  @override
  String get pinsDoNotMatch => 'PINs do not match';

  @override
  String get wrongPin => 'Wrong PIN';

  @override
  String get faceId => 'Face ID';

  @override
  String get signInAnonymously => 'Continue';

  @override
  String get authError =>
      'Could not sign in. Check network and Firebase configuration.';

  @override
  String get explore => 'Explore';

  @override
  String get privateSanctuary => 'Private sanctuary';

  @override
  String entryNo(int n) {
    return 'Entry no. $n';
  }

  @override
  String get shareEntry => 'Share';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get today => 'Today';

  @override
  String get moodPeaceful => 'Peaceful';

  @override
  String get moodReflective => 'Reflective';

  @override
  String get moodProductive => 'Productive';

  @override
  String get moodAnxious => 'Anxious';

  @override
  String get moodGrateful => 'Grateful';

  @override
  String get moodSerene => 'Serene';

  @override
  String get moodMelancholic => 'Melancholic';

  @override
  String get moodInspired => 'Inspired';

  @override
  String get moodQuiet => 'Quiet';

  @override
  String get moodNeutral => 'Neutral';

  @override
  String get moodJoyful => 'Joyful';

  @override
  String get moodLow => 'Low';

  @override
  String get moodCalm => 'Calm';

  @override
  String get moodStressed => 'Stressed';

  @override
  String get selectMonth => 'Select month';

  @override
  String get ok => 'OK';

  @override
  String get loading => 'Loading…';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get imagePickerError =>
      'Could not open the photo picker. Stop the app completely, run it again (not hot restart), or try a device with Google Play services.';

  @override
  String get emptyJournal => 'No entries yet. Start writing.';

  @override
  String get titleHint => 'Title (optional)';

  @override
  String get firestoreApiDisabled =>
      'Cloud Firestore API is not enabled for this Google Cloud project. Open Google Cloud Console, enable \"Cloud Firestore API\", wait a minute, then retry.';

  @override
  String get firestoreRulesHint =>
      'If the API is already enabled, check Firestore security rules and that Anonymous sign-in is allowed in Firebase Authentication.';

  @override
  String get quickNavTitle => 'Navigate';

  @override
  String get accountSheetTitle => 'Your session';

  @override
  String get anonymousSessionCloud =>
      'Signed in anonymously. Entries sync to Firebase for this user.';

  @override
  String get anonymousSessionLocal =>
      'Local mode: entries stay on this device only.';

  @override
  String get userIdLabel => 'User ID';

  @override
  String get forgotPinMessage =>
      'PINs cannot be recovered from the app. To reset access you can clear app storage in Android settings (local journal data will be removed).';

  @override
  String get emergencyMessage =>
      'This app is a private journal. For real emergencies use your device’s emergency or medical features.';

  @override
  String get close => 'Close';
}
