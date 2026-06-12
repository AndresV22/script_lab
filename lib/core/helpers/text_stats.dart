/// Utilidades de conteo y estimaciones para textos de guion.
abstract class TextStats {
  static int words(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return RegExp(r'\S+').allMatches(trimmed).length;
  }

  static int chars(String text) => text.length;

  static Duration narrationTime(int wordCount, int wordsPerMinute) {
    if (wordCount == 0 || wordsPerMinute <= 0) return Duration.zero;
    return Duration(seconds: (wordCount / wordsPerMinute * 60).round());
  }

  static String formatDuration(Duration d) {
    if (d.inSeconds < 60) return '${d.inSeconds} s';
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    if (minutes < 60) {
      return seconds == 0 ? '$minutes min' : '$minutes min $seconds s';
    }
    final hours = d.inHours;
    final remMinutes = minutes % 60;
    return '$hours h $remMinutes min';
  }
}
