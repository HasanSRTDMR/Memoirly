import 'package:flutter/material.dart';
import 'package:memoirly/domain/entities/journal_entry.dart';

/// Ana sayfa satırı için seçenekler — ilk sürümdeki emoji şekilleri (Material ikon değil).
const kArchiveListEmojiChoices = <String>[
  '📔',
  '📓',
  '✍️',
  '🌿',
  '🙏',
  '😰',
  '⚡',
  '💭',
  '🌙',
  '☕',
  '🎵',
  '💡',
  '❤️',
  '🌅',
  '🌧️',
  '✨',
  '🦋',
  '📝',
];

/// Eski sürümden kalan ASCII ikon anahtarları (book, stories, …) — kayıtta kalmış olabilir.
bool _looksLikeStoredIconKey(String s) {
  return RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(s);
}

String _emojiFromMood(String? m) {
  if (m == null) return '📔';
  const map = {
    'peaceful': '🌿',
    'grateful': '🙏',
    'anxious': '😰',
    'productive': '⚡',
    'reflective': '💭',
    'serene': '🌙',
  };
  return map[m] ?? '📓';
}

/// Ana satırda gösterilecek emoji (özel seçim veya ruh hâli).
String emojiForHomeArchiveList(JournalEntry e) {
  final custom = e.cardEmoji?.trim();
  if (custom != null && custom.isNotEmpty) {
    if (_looksLikeStoredIconKey(custom)) {
      return _emojiFromMood(e.mood);
    }
    return custom;
  }
  return _emojiFromMood(e.mood);
}

/// Yazma ekranında bir hücrenin “seçili” sayılması (Otomatik dışında).
bool isPickedArchiveListEmoji(String? value) {
  final v = value?.trim();
  if (v == null || v.isEmpty) return false;
  if (_looksLikeStoredIconKey(v)) return false;
  return true;
}

/// Grayscale + modulate sonrası çok koyu görünmesin diye [onSurface] yerine açık gri tonlar.
Color archiveEmojiModulateColor(ColorScheme scheme, {bool emphasized = false}) {
  if (emphasized) {
    return Color.lerp(scheme.primary, scheme.surface, 0.22)!;
  }
  return Color.lerp(scheme.onSurfaceVariant, scheme.surface, 0.32)!;
}

/// Parlak emoji yerine: önce gri ton, sonra [color] ile çarpım — Archive paletiyle uyum.
Widget themedArchiveListEmoji(
  String emoji, {
  required Color color,
  double size = 22,
}) {
  return ColorFiltered(
    colorFilter: const ColorFilter.matrix(<double>[
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    child: ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.modulate),
      child: Text(
        emoji,
        style: TextStyle(fontSize: size, height: 1.1),
      ),
    ),
  );
}

Widget themedArchiveListLeading(
  JournalEntry entry, {
  required Color color,
  double size = 22,
}) {
  return themedArchiveListEmoji(
    emojiForHomeArchiveList(entry),
    color: color,
    size: size,
  );
}
