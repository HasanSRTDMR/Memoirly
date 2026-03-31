/// Canonical mood keys stored in [JournalEntry.mood] and used for filters.
const kMoodKeys = <String>[
  'peaceful',
  'reflective',
  'productive',
  'anxious',
  'grateful',
  'serene',
  'melancholic',
  'inspired',
  'quiet',
  'neutral',
  'joyful',
  'low',
  'calm',
  'stressed',
];

String moodDisplayKeyFromIndex(int sentimentIndex) {
  const map = <int, String>{
    0: 'joyful',
    1: 'calm',
    2: 'neutral',
    3: 'low',
    4: 'stressed',
  };
  return map[sentimentIndex] ?? 'neutral';
}
