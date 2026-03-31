import 'package:memoirly/core/localization/app_localizations.dart';

String moodLabel(AppLocalizations l, String key) {
  switch (key) {
    case 'peaceful':
      return l.moodPeaceful;
    case 'reflective':
      return l.moodReflective;
    case 'productive':
      return l.moodProductive;
    case 'anxious':
      return l.moodAnxious;
    case 'grateful':
      return l.moodGrateful;
    case 'serene':
      return l.moodSerene;
    case 'melancholic':
      return l.moodMelancholic;
    case 'inspired':
      return l.moodInspired;
    case 'quiet':
      return l.moodQuiet;
    case 'neutral':
      return l.moodNeutral;
    case 'joyful':
      return l.moodJoyful;
    case 'low':
      return l.moodLow;
    case 'calm':
      return l.moodCalm;
    case 'stressed':
      return l.moodStressed;
    default:
      return key;
  }
}
