import '../types/options.dart';
import '../calendar/hijri_date.dart';
import '../calendar/hijri_converter.dart';

/// Helper to convert DateTime or HijriDateLike to HijriDate
HijriDate _toHijriDate(Object value) {
  if (value is HijriDate) {
    return value;
  }
  if (value is DateTime) {
    final components = gregorianToHijri(value);
    return HijriDate(components.year, components.month, components.day);
  }
  if (value is HijriDateLike) {
    return HijriDate(value.year, value.month, value.day);
  }
  throw ArgumentError('Invalid date value: $value');
}

/// Convert options to RRULE string
///
/// [options] - Parsed or partial options
/// [includeDtstart] - Whether to include DTSTART line (default: true)
/// Returns RRULE string
String optionsToString(dynamic options, {bool includeDtstart = true}) {
  final parts = <String>[];

  final dtstart = options.dtstart;
  final calendar = options.calendar;

  // DTSTART line
  if (includeDtstart && dtstart != null) {
    final hijriDate = _toHijriDate(dtstart);
    final calendarStr = calendar == IslamicCalendarType.islamicTbla
        ? 'HIJRI-TABULAR'
        : 'HIJRI-UM-AL-QURA';
    parts.add('DTSTART;CALENDAR=$calendarStr:${hijriDate.toRRuleString()}');
  }

  // Build RRULE properties
  final rruleParts = <String>[];

  // FREQ (required)
  rruleParts.add('FREQ=${options.freq.name}');

  // INTERVAL
  final interval = options.interval;
  if (interval != null && interval != 1) {
    rruleParts.add('INTERVAL=$interval');
  }

  // WKST
  final wkst = options.wkst;
  if (wkst != null) {
    rruleParts.add('WKST=${wkst.name}');
  }

  // COUNT
  final count = options.count;
  if (count != null) {
    rruleParts.add('COUNT=$count');
  }

  // UNTIL
  final until = options.until;
  if (until != null) {
    final hijriUntil = _toHijriDate(until);
    rruleParts.add('UNTIL=${hijriUntil.toRRuleString()}');
  }

  // Handle HijriRRuleParsedOptions specific fields
  if (options is HijriRRuleParsedOptions) {
    // BYSETPOS
    final bysetpos = options.bysetpos;
    if (bysetpos != null && bysetpos.isNotEmpty) {
      rruleParts.add('BYSETPOS=${bysetpos.join(',')}');
    }

    // BYMONTH
    final bymonth = options.bymonth;
    if (bymonth != null && bymonth.isNotEmpty) {
      rruleParts.add('BYMONTH=${bymonth.join(',')}');
    }

    // BYMONTHDAY (combine positive and negative)
    final bymonthday = options.bymonthday ?? <int>[];
    final bynmonthday = options.bynmonthday ?? <int>[];
    final allMonthDays = [...bymonthday, ...bynmonthday];
    if (allMonthDays.isNotEmpty) {
      rruleParts.add('BYMONTHDAY=${allMonthDays.join(',')}');
    }

    // BYYEARDAY
    final byyearday = options.byyearday;
    if (byyearday != null && byyearday.isNotEmpty) {
      rruleParts.add('BYYEARDAY=${byyearday.join(',')}');
    }

    // BYWEEKNO
    final byweekno = options.byweekno;
    if (byweekno != null && byweekno.isNotEmpty) {
      rruleParts.add('BYWEEKNO=${byweekno.join(',')}');
    }

    // BYDAY (combine simple and nth weekdays)
    final byweekday = options.byweekday ?? <WeekdaySpec>[];
    final bynweekday = options.bynweekday ?? <WeekdaySpec>[];
    final allWeekdays = [...byweekday, ...bynweekday];
    if (allWeekdays.isNotEmpty) {
      final dayStrs = allWeekdays.map(_formatWeekdaySpec);
      rruleParts.add('BYDAY=${dayStrs.join(',')}');
    }

    // BYHOUR
    final byhour = options.byhour;
    if (byhour != null && byhour.isNotEmpty) {
      rruleParts.add('BYHOUR=${byhour.join(',')}');
    }

    // BYMINUTE
    final byminute = options.byminute;
    if (byminute != null && byminute.isNotEmpty) {
      rruleParts.add('BYMINUTE=${byminute.join(',')}');
    }

    // BYSECOND
    final bysecond = options.bysecond;
    if (bysecond != null && bysecond.isNotEmpty) {
      rruleParts.add('BYSECOND=${bysecond.join(',')}');
    }

    // SKIP (only if not default 'omit')
    final skip = options.skip;
    if (skip != Skip.omit) {
      rruleParts.add('SKIP=${skip.value.toUpperCase()}');
    }
  } else if (options is HijriRRulePartialOptions) {
    // Handle HijriRRulePartialOptions
    final bysetpos = options.bysetpos;
    if (bysetpos != null && bysetpos.isNotEmpty) {
      rruleParts.add('BYSETPOS=${bysetpos.join(',')}');
    }

    final bymonth = options.bymonth;
    if (bymonth != null && bymonth.isNotEmpty) {
      rruleParts.add('BYMONTH=${bymonth.join(',')}');
    }

    final bymonthday = options.bymonthday;
    if (bymonthday != null && bymonthday.isNotEmpty) {
      rruleParts.add('BYMONTHDAY=${bymonthday.join(',')}');
    }

    final byyearday = options.byyearday;
    if (byyearday != null && byyearday.isNotEmpty) {
      rruleParts.add('BYYEARDAY=${byyearday.join(',')}');
    }

    final byweekno = options.byweekno;
    if (byweekno != null && byweekno.isNotEmpty) {
      rruleParts.add('BYWEEKNO=${byweekno.join(',')}');
    }

    final byweekday = options.byweekday;
    if (byweekday != null && byweekday.isNotEmpty) {
      final dayStrs = byweekday.map((wd) {
        if (wd is WeekdaySpec) return _formatWeekdaySpec(wd);
        return wd.toString();
      });
      rruleParts.add('BYDAY=${dayStrs.join(',')}');
    }

    final byhour = options.byhour;
    if (byhour != null && byhour.isNotEmpty) {
      rruleParts.add('BYHOUR=${byhour.join(',')}');
    }

    final byminute = options.byminute;
    if (byminute != null && byminute.isNotEmpty) {
      rruleParts.add('BYMINUTE=${byminute.join(',')}');
    }

    final bysecond = options.bysecond;
    if (bysecond != null && bysecond.isNotEmpty) {
      rruleParts.add('BYSECOND=${bysecond.join(',')}');
    }

    final skip = options.skip;
    if (skip != null && skip != Skip.omit) {
      rruleParts.add('SKIP=${skip.value.toUpperCase()}');
    }
  }

  // TZID
  final tzid = options.tzid;
  if (tzid != null) {
    rruleParts.add('TZID=$tzid');
  }

  parts.add('RRULE:${rruleParts.join(';')}');

  return parts.join('\n');
}

/// Format a WeekdaySpec as string
String _formatWeekdaySpec(WeekdaySpec spec) {
  final dayStr = spec.weekday.name;
  if (spec.n != null) {
    return '${spec.n}$dayStr';
  }
  return dayStr;
}

/// Convert options to RRULE string without DTSTART
String rruleToString(dynamic options) {
  final fullStr = optionsToString(options, includeDtstart: true);
  final lines = fullStr.split('\n');

  // Return only the RRULE line
  final rruleLine = lines.where((line) => line.startsWith('RRULE:')).firstOrNull;
  return rruleLine ?? '';
}

/// Get the RRULE property string only (without RRULE: prefix)
String getPropertiesString(dynamic options) {
  final rruleLine = rruleToString(options);
  return rruleLine.replaceFirst(RegExp(r'^RRULE:'), '');
}
