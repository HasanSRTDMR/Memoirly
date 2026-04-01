/// Valence in [-1, 1] for each canonical mood key ([JournalEntry.mood]).
/// Used to derive an aggregate “tone” / well-being score from chosen moods.
const kMoodValence = <String, double>{
  'joyful': 1.0,
  'grateful': 0.92,
  'inspired': 0.88,
  'peaceful': 0.82,
  'serene': 0.8,
  'calm': 0.65,
  'productive': 0.45,
  'reflective': 0.08,
  'quiet': 0.1,
  'neutral': 0.0,
  'anxious': -0.55,
  'stressed': -0.82,
  'melancholic': -0.72,
  'low': -0.78,
};

/// Returns null if [mood] is empty or not a known key (ignored in averages).
double? moodValenceForKey(String? mood) {
  if (mood == null || mood.isEmpty) return null;
  return kMoodValence[mood.toLowerCase().trim()];
}
