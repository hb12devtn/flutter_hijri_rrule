import '../types/options.dart';
import '../types/weekday.dart';
import '../constants/weekday.dart';
import '../calendar/hijri_date.dart';
import '../calendar/hijri_converter.dart';
import '../calendar/calendar_config.dart';
import '../weekday/hijri_weekday.dart';

/// Normalize a value to a list
List<T>? toList<T>(dynamic value) {
  if (value == null) return null;
  if (value is List) return value.cast<T>();
  return [value as T];
}

/// Normalize weekday input to WeekdaySpec list
List<WeekdaySpec>? normalizeWeekdays(List<Object>? value) {
  if (value == null) return null;

  return value.map((v) {
    if (v is WeekdayNum) {
      return WeekdaySpec(v);
    }
    if (v is HijriWeekday) {
      return WeekdaySpec(v.weekday, n: v.n);
    }
    if (v is WeekdaySpec) {
      return v;
    }
    throw ArgumentError('Invalid weekday value: $v');
  }).toList();
}

/// Convert a DateTime or HijriDateLike to HijriDate
HijriDate toHijriDate(Object value) {
  if (value is DateTime) {
    final components = gregorianToHijri(value);
    return HijriDate(
      components.year,
      components.month,
      components.day,
      value.hour,
      value.minute,
      value.second,
    );
  }
  if (value is HijriDate) {
    return value;
  }
  if (value is HijriDateLike) {
    return HijriDate(value.year, value.month, value.day);
  }
  throw ArgumentError('Invalid date value: $value');
}

/// Separate positive and negative bymonthday values
({List<int>? positive, List<int>? negative}) separateMonthDays(List<int>? days) {
  if (days == null) return (positive: null, negative: null);

  final positive = <int>[];
  final negative = <int>[];

  for (final day in days) {
    if (day > 0) {
      positive.add(day);
    } else if (day < 0) {
      negative.add(day);
    }
  }

  return (
    positive: positive.isNotEmpty ? positive : null,
    negative: negative.isNotEmpty ? negative : null,
  );
}

/// Separate weekdays with and without n (nth occurrence)
({List<WeekdaySpec>? simple, List<WeekdaySpec>? nth}) separateWeekdays(
    List<WeekdaySpec>? weekdays) {
  if (weekdays == null) return (simple: null, nth: null);

  final simple = <WeekdaySpec>[];
  final nth = <WeekdaySpec>[];

  for (final wd in weekdays) {
    if (wd.n != null) {
      nth.add(wd);
    } else {
      simple.add(wd);
    }
  }

  return (
    simple: simple.isNotEmpty ? simple : null,
    nth: nth.isNotEmpty ? nth : null,
  );
}

/// Validate options
void validateOptions(HijriRRulePartialOptions options) {
  // Validate interval
  if (options.interval != null) {
    if (options.interval! < 1) {
      throw ArgumentError(
          'Invalid interval: ${options.interval}. Must be a positive integer.');
    }
  }

  // Validate count
  if (options.count != null) {
    if (options.count! < 0) {
      throw ArgumentError(
          'Invalid count: ${options.count}. Must be a non-negative integer.');
    }
  }

  // Validate bymonth (1-12)
  final bymonth = options.bymonth;
  if (bymonth != null) {
    for (final m in bymonth) {
      if (m < 1 || m > 12) {
        throw ArgumentError(
            'Invalid bymonth: $m. Must be between 1 and 12.');
      }
    }
  }

  // Validate bymonthday (-30 to -1, 1 to 30)
  final bymonthday = options.bymonthday;
  if (bymonthday != null) {
    for (final d in bymonthday) {
      if (d == 0 || d < -30 || d > 30) {
        throw ArgumentError(
            'Invalid bymonthday: $d. Must be between -30 and 30 (excluding 0).');
      }
    }
  }

  // Validate byyearday (-355 to -1, 1 to 355)
  final byyearday = options.byyearday;
  if (byyearday != null) {
    for (final d in byyearday) {
      if (d == 0 || d < -355 || d > 355) {
        throw ArgumentError(
            'Invalid byyearday: $d. Must be between -355 and 355 (excluding 0).');
      }
    }
  }

  // Validate bysetpos
  final bysetpos = options.bysetpos;
  if (bysetpos != null) {
    for (final p in bysetpos) {
      if (p == 0 || p < -366 || p > 366) {
        throw ArgumentError('Invalid bysetpos: $p.');
      }
    }
  }

  // Validate byhour (0-23)
  final byhour = options.byhour;
  if (byhour != null) {
    for (final h in byhour) {
      if (h < 0 || h > 23) {
        throw ArgumentError(
            'Invalid byhour: $h. Must be between 0 and 23.');
      }
    }
  }

  // Validate byminute (0-59)
  final byminute = options.byminute;
  if (byminute != null) {
    for (final m in byminute) {
      if (m < 0 || m > 59) {
        throw ArgumentError(
            'Invalid byminute: $m. Must be between 0 and 59.');
      }
    }
  }

  // Validate bysecond (0-59)
  final bysecond = options.bysecond;
  if (bysecond != null) {
    for (final s in bysecond) {
      if (s < 0 || s > 59) {
        throw ArgumentError(
            'Invalid bysecond: $s. Must be between 0 and 59.');
      }
    }
  }
}

/// Parse and normalize options for HijriRRule
///
/// [options] - Partial options from user
/// Returns Fully parsed and normalized options
HijriRRuleParsedOptions parseOptions(HijriRRulePartialOptions options) {
  // Validate first
  validateOptions(options);

  // Parse dtstart
  HijriDate dtstart;
  if (options.dtstart != null) {
    dtstart = toHijriDate(options.dtstart!);
  } else {
    // Default to current date in Hijri
    dtstart = HijriDate.now();
  }

  // Parse until
  HijriDate? until;
  if (options.until != null) {
    until = toHijriDate(options.until!);
  }

  // Separate bymonthday into positive and negative
  final monthDays = separateMonthDays(options.bymonthday);

  // Normalize and separate byweekday
  final normalizedWeekdays = normalizeWeekdays(options.byweekday);
  final weekdays = separateWeekdays(normalizedWeekdays);

  return HijriRRuleParsedOptions(
    freq: options.freq,
    dtstart: dtstart,
    interval: options.interval ?? 1,
    wkst: options.wkst ?? defaultWkst,
    count: options.count,
    until: until,
    tzid: options.tzid,
    bysetpos: options.bysetpos,
    bymonth: options.bymonth,
    bymonthday: monthDays.positive,
    bynmonthday: monthDays.negative,
    byyearday: options.byyearday,
    byweekno: options.byweekno,
    byweekday: weekdays.simple,
    bynweekday: weekdays.nth,
    byhour: options.byhour,
    byminute: options.byminute,
    bysecond: options.bysecond,
    skip: options.skip ?? Skip.omit,
    calendar: options.calendar ?? getCalendarConfig().defaultCalendar,
  );
}

/// Convert ParsedOptions back to PartialOptions
/// Useful for cloning rules
HijriRRulePartialOptions optionsToPartial(HijriRRuleParsedOptions parsed) {
  // Combine positive and negative monthdays
  List<int>? bymonthday;
  if (parsed.bymonthday != null || parsed.bynmonthday != null) {
    bymonthday = [
      ...?parsed.bymonthday,
      ...?parsed.bynmonthday,
    ];
  }

  // Combine simple and nth weekdays
  List<Object>? byweekday;
  if (parsed.byweekday != null || parsed.bynweekday != null) {
    byweekday = [
      ...?parsed.byweekday,
      ...?parsed.bynweekday,
    ];
  }

  return HijriRRulePartialOptions(
    freq: parsed.freq,
    dtstart: parsed.dtstart,
    interval: parsed.interval,
    wkst: parsed.wkst,
    count: parsed.count,
    until: parsed.until,
    tzid: parsed.tzid,
    bysetpos: parsed.bysetpos,
    bymonth: parsed.bymonth,
    bymonthday: bymonthday,
    byyearday: parsed.byyearday,
    byweekno: parsed.byweekno,
    byweekday: byweekday,
    byhour: parsed.byhour,
    byminute: parsed.byminute,
    bysecond: parsed.bysecond,
    skip: parsed.skip,
    calendar: parsed.calendar,
  );
}
