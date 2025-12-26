import '../types/options.dart';
import 'i18n.dart';

/// Convert parsed options to human-readable text
///
/// [options] - Parsed RRULE options
/// [locale] - Language locale ('en' or 'ar')
/// Returns Human-readable text description
///
/// Example:
/// ```dart
/// final text = toText(options, 'en');
/// // "every year in Ramadan on the 1st"
///
/// final textAr = toText(options, 'ar');
/// // "كل سنة في رمضان في اليوم 1"
/// ```
String toText(HijriRRuleParsedOptions options, [String locale = 'en']) {
  final i18n = getI18n(locale);
  final parts = <String>[];

  // Build frequency phrase
  parts.add(_buildFrequencyPhrase(options, i18n, locale));

  // Add month if specified
  if (options.bymonth != null && options.bymonth!.isNotEmpty) {
    parts.add(_buildMonthPhrase(options.bymonth!, i18n, locale));
  }

  // Add day of month if specified
  if (options.bymonthday != null && options.bymonthday!.isNotEmpty) {
    parts.add(_buildMonthDayPhrase(options.bymonthday!, i18n, locale));
  }

  // Add weekday if specified
  if (options.byweekday != null && options.byweekday!.isNotEmpty) {
    parts.add(_buildWeekdayPhrase(options.byweekday!, i18n, locale));
  }

  // Add nth weekday if specified
  if (options.bynweekday != null && options.bynweekday!.isNotEmpty) {
    parts.add(_buildNthWeekdayPhrase(options.bynweekday!, i18n, locale));
  }

  // Add count if specified
  if (options.count != null) {
    parts.add(_buildCountPhrase(options.count!, i18n, locale));
  }

  // Add until if specified
  if (options.until != null) {
    parts.add(_buildUntilPhrase(options.until!, i18n, locale));
  }

  return parts.join(' ');
}

/// Build frequency phrase
String _buildFrequencyPhrase(
  HijriRRuleParsedOptions options,
  I18nStrings i18n,
  String locale,
) {
  final interval = options.interval;

  final freqWords = <Frequency, ({String singular, String plural})>{
    Frequency.yearly: (singular: i18n.year, plural: i18n.years),
    Frequency.monthly: (singular: i18n.month, plural: i18n.months),
    Frequency.weekly: (singular: i18n.week, plural: i18n.weeks),
    Frequency.daily: (singular: i18n.day, plural: i18n.days),
    Frequency.hourly: (singular: i18n.hourly, plural: i18n.hourly),
    Frequency.minutely: (singular: i18n.minutely, plural: i18n.minutely),
    Frequency.secondly: (singular: i18n.secondly, plural: i18n.secondly),
  };

  final words = freqWords[options.freq]!;

  if (locale == 'ar') {
    if (interval == 1) {
      return '${i18n.every} ${words.singular}';
    } else if (interval == 2) {
      return '${i18n.every} ${words.singular}ين'; // dual form
    } else {
      return '${i18n.every} $interval ${words.plural}';
    }
  } else {
    if (interval == 1) {
      return '${i18n.every} ${words.singular}';
    } else {
      return '${i18n.every} $interval ${words.plural}';
    }
  }
}

/// Build month phrase
String _buildMonthPhrase(
  List<int> months,
  I18nStrings i18n,
  String locale,
) {
  final monthNames = months.map((m) => i18n.monthNames[m]).toList();

  if (locale == 'ar') {
    if (monthNames.length == 1) {
      return '${i18n.inWord} ${monthNames[0]}';
    }
    return '${i18n.inWord} ${monthNames.sublist(0, monthNames.length - 1).join('، ')} ${i18n.and} ${monthNames.last}';
  } else {
    if (monthNames.length == 1) {
      return '${i18n.inWord} ${monthNames[0]}';
    }
    return '${i18n.inWord} ${monthNames.sublist(0, monthNames.length - 1).join(', ')} ${i18n.and} ${monthNames.last}';
  }
}

/// Build month day phrase
String _buildMonthDayPhrase(
  List<int> days,
  I18nStrings i18n,
  String locale,
) {
  if (locale == 'ar') {
    final dayStrs = days.map((d) => d.toString()).toList();
    if (dayStrs.length == 1) {
      return '${i18n.on} ${i18n.dayPrefix} ${dayStrs[0]}';
    }
    return '${i18n.on} ${i18n.dayPrefix} ${dayStrs.sublist(0, dayStrs.length - 1).join('، ')} ${i18n.and} ${dayStrs.last}';
  } else {
    final dayStrs = days.map((d) => '${i18n.the} ${_formatOrdinal(d)}').toList();
    if (dayStrs.length == 1) {
      return '${i18n.on} ${dayStrs[0]}';
    }
    return '${i18n.on} ${dayStrs.sublist(0, dayStrs.length - 1).join(', ')} ${i18n.and} ${dayStrs.last}';
  }
}

/// Build weekday phrase
String _buildWeekdayPhrase(
  List<WeekdaySpec> weekdays,
  I18nStrings i18n,
  String locale,
) {
  final dayNames = weekdays.map((wd) => i18n.weekdays[wd.weekday.value]).toList();

  if (locale == 'ar') {
    if (dayNames.length == 1) {
      return '${i18n.inWord} ${dayNames[0]}';
    }
    return '${i18n.inWord} ${dayNames.sublist(0, dayNames.length - 1).join('، ')} ${i18n.and} ${dayNames.last}';
  } else {
    if (dayNames.length == 1) {
      return '${i18n.on} ${dayNames[0]}';
    }
    return '${i18n.on} ${dayNames.sublist(0, dayNames.length - 1).join(', ')} ${i18n.and} ${dayNames.last}';
  }
}

/// Build nth weekday phrase (e.g., "first Friday")
String _buildNthWeekdayPhrase(
  List<WeekdaySpec> weekdays,
  I18nStrings i18n,
  String locale,
) {
  final phrases = weekdays.map((wd) {
    final dayName = i18n.weekdays[wd.weekday.value];
    final ordinal = _getOrdinal(wd.n ?? 1, i18n, locale);

    if (locale == 'ar') {
      return '$dayName $ordinal';
    } else {
      return '${i18n.the} $ordinal $dayName';
    }
  }).toList();

  if (locale == 'ar') {
    if (phrases.length == 1) {
      return '${i18n.inWord} ${phrases[0]}';
    }
    return '${i18n.inWord} ${phrases.sublist(0, phrases.length - 1).join('، ')} ${i18n.and} ${phrases.last}';
  } else {
    if (phrases.length == 1) {
      return '${i18n.on} ${phrases[0]}';
    }
    return '${i18n.on} ${phrases.sublist(0, phrases.length - 1).join(', ')} ${i18n.and} ${phrases.last}';
  }
}

/// Get ordinal string
String _getOrdinal(int n, I18nStrings i18n, String locale) {
  if (n == -1) return i18n.last;
  if (n == -2) return i18n.secondLast;

  switch (n) {
    case 1:
      return i18n.first;
    case 2:
      return i18n.second;
    case 3:
      return i18n.third;
    case 4:
      return i18n.fourth;
    case 5:
      return i18n.fifth;
    default:
      if (locale == 'ar') {
        return n.toString();
      }
      return _formatOrdinal(n);
  }
}

/// Format a number as an ordinal (e.g., 1 -> "1st", 2 -> "2nd")
String _formatOrdinal(int n) {
  if (n <= 0) return n.toString();

  final remainder = n % 100;

  if (remainder >= 11 && remainder <= 13) {
    return '${n}th';
  }

  switch (n % 10) {
    case 1:
      return '${n}st';
    case 2:
      return '${n}nd';
    case 3:
      return '${n}rd';
    default:
      return '${n}th';
  }
}

/// Build count phrase
String _buildCountPhrase(
  int count,
  I18nStrings i18n,
  String locale,
) {
  if (locale == 'ar') {
    if (count == 1) {
      return '${i18n.forWord} ${i18n.time} واحدة';
    } else if (count == 2) {
      return '${i18n.forWord} مرتين';
    } else {
      return '${i18n.forWord} $count ${i18n.times}';
    }
  } else {
    if (count == 1) {
      return '${i18n.forWord} 1 ${i18n.time}';
    }
    return '${i18n.forWord} $count ${i18n.times}';
  }
}

/// Build until phrase
String _buildUntilPhrase(
  HijriDateLike until,
  I18nStrings i18n,
  String locale,
) {
  final monthName = i18n.monthNames[until.month];

  if (locale == 'ar') {
    return '${i18n.until} ${until.day} $monthName ${until.year}';
  } else {
    return '${i18n.until} ${_formatOrdinal(until.day)} $monthName ${until.year} AH';
  }
}
