extension StringX on String {
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String truncate(int max) =>
      length <= max ? this : '${substring(0, max).trimRight()}…';

  /// Extrae elementos de una lista en texto (líneas con -, *, • o numeradas).
  List<String> get parsedListItems {
    final items = <String>[];
    for (final rawLine in split('\n')) {
      final line = rawLine.trim();
      final match =
          RegExp(r'^(?:[-*•]|\d+[.)])\s*(?:["“]?)(.+?)(?:["”]?)\s*$')
              .firstMatch(line);
      if (match != null) {
        final value = match.group(1)!.trim();
        if (value.isNotEmpty) items.add(value);
      }
    }
    return items;
  }
}
