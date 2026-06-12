const _months = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

extension DateFormatting on DateTime {
  String get shortDate => '$day ${_months[month - 1]} $year';

  String get shortDateTime {
    final hh = hour.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    return '$shortDate, $hh:$mm';
  }

  String get relative {
    final diff = DateTime.now().difference(this);
    if (diff.inMinutes < 1) return 'hace un momento';
    if (diff.inHours < 1) return 'hace ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'hace ${diff.inHours} h';
    if (diff.inDays < 7) {
      return diff.inDays == 1 ? 'ayer' : 'hace ${diff.inDays} días';
    }
    return shortDate;
  }
}
