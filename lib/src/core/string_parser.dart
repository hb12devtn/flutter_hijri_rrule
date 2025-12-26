import '../types/options.dart';
import '../types/weekday.dart';
import '../calendar/hijri_date.dart';

/// Parse an RRULE string into options
///
/// Supports formats:
/// - "FREQ=YEARLY;BYMONTH=9;BYMONTHDAY=1"
/// - "RRULE:FREQ=YEARLY;BYMONTH=9"
/// - "DTSTART:14460901\nRRULE:FREQ=YEARLY"
///
/// [str] - RRULE string to parse
/// Returns Partial options object
HijriRRulePartialOptions parseString(String str) {
  final lines = str.split(RegExp(r'[\r\n]+')).where((line) => line.trim().isNotEmpty);

  HijriDate? dtstart;
  IslamicCalendarType? calendar;
  String rruleStr = '';

  for (final line in lines) {
    final trimmed = line.trim();

    if (trimmed.startsWith('DTSTART')) {
      final result = _parseDtstart(trimmed);
      dtstart = result.date;
      calendar = result.calendar;
    } else if (trimmed.startsWith('RRULE:')) {
      rruleStr = trimmed.substring(6);
    } else if (trimmed.contains('FREQ=')) {
      // Bare RRULE without prefix
      rruleStr = trimmed;
    }
  }

  if (rruleStr.isEmpty) {
    throw ArgumentError('No RRULE found in string');
  }

  final options = _parseRRuleProperties(rruleStr);

  return HijriRRulePartialOptions(
    freq: options.freq,
    dtstart: dtstart ?? options.dtstart,
    interval: options.interval,
    wkst: options.wkst,
    count: options.count,
    until: options.until,
    tzid: options.tzid,
    bysetpos: options.bysetpos,
    bymonth: options.bymonth,
    bymonthday: options.bymonthday,
    byyearday: options.byyearday,
    byweekno: options.byweekno,
    byweekday: options.byweekday,
    byhour: options.byhour,
    byminute: options.byminute,
    bysecond: options.bysecond,
    skip: options.skip,
    calendar: calendar ?? options.calendar,
  );
}

/// Parse DTSTART line
({HijriDate date, IslamicCalendarType? calendar}) _parseDtstart(String line) {
  // Extract calendar type from CALENDAR parameter
  IslamicCalendarType? calendar;

  if (line.contains('HIJRI-UM-AL-QURA')) {
    calendar = IslamicCalendarType.islamicUmalqura;
  } else if (line.contains('HIJRI-TABULAR')) {
    calendar = IslamicCalendarType.islamicTbla;
  }

  // Extract the date value after the last colon
  final colonIndex = line.lastIndexOf(':');
  if (colonIndex == -1) {
    throw ArgumentError('Invalid DTSTART line: $line');
  }

  final dateStr = line.substring(colonIndex + 1).trim();

  // Remove trailing Z if present (we ignore timezone for now)
  final cleanStr = dateStr.replaceAll(RegExp(r'Z$'), '');

  return (date: HijriDate.fromRRuleString(cleanStr), calendar: calendar);
}

/// Parse RRULE properties string
HijriRRulePartialOptions _parseRRuleProperties(String str) {
  Frequency? freq;
  int? interval;
  WeekdayNum? wkst;
  int? count;
  HijriDate? until;
  String? tzid;
  List<int>? bysetpos;
  List<int>? bymonth;
  List<int>? bymonthday;
  List<int>? byyearday;
  List<int>? byweekno;
  List<Object>? byweekday;
  List<int>? byhour;
  List<int>? byminute;
  List<int>? bysecond;
  Skip? skip;

  final parts = str.split(';').where((p) => p.trim().isNotEmpty);

  for (final part in parts) {
    final eqIndex = part.indexOf('=');
    if (eqIndex == -1) continue;

    final key = part.substring(0, eqIndex).toUpperCase();
    final value = part.substring(eqIndex + 1);

    switch (key) {
      case 'FREQ':
        freq = Frequency.fromString(value);
        break;

      case 'INTERVAL':
        interval = int.parse(value);
        break;

      case 'COUNT':
        count = int.parse(value);
        break;

      case 'UNTIL':
        until = _parseUntil(value);
        break;

      case 'WKST':
        wkst = WeekdayNum.fromString(value);
        break;

      case 'BYSETPOS':
        bysetpos = _parseIntList(value);
        break;

      case 'BYMONTH':
        bymonth = _parseIntList(value);
        break;

      case 'BYMONTHDAY':
        bymonthday = _parseIntList(value);
        break;

      case 'BYYEARDAY':
        byyearday = _parseIntList(value);
        break;

      case 'BYWEEKNO':
        byweekno = _parseIntList(value);
        break;

      case 'BYDAY':
      case 'BYWEEKDAY':
        byweekday = _parseByDay(value);
        break;

      case 'BYHOUR':
        byhour = _parseIntList(value);
        break;

      case 'BYMINUTE':
        byminute = _parseIntList(value);
        break;

      case 'BYSECOND':
        bysecond = _parseIntList(value);
        break;

      case 'TZID':
        tzid = value;
        break;

      case 'SKIP':
        skip = Skip.fromString(value);
        break;
    }
  }

  if (freq == null) {
    throw ArgumentError('FREQ is required in RRULE');
  }

  return HijriRRulePartialOptions(
    freq: freq,
    interval: interval,
    wkst: wkst,
    count: count,
    until: until,
    tzid: tzid,
    bysetpos: bysetpos,
    bymonth: bymonth,
    bymonthday: bymonthday,
    byyearday: byyearday,
    byweekno: byweekno,
    byweekday: byweekday,
    byhour: byhour,
    byminute: byminute,
    bysecond: bysecond,
    skip: skip,
  );
}

/// Parse UNTIL value
HijriDate _parseUntil(String value) {
  // Remove trailing Z if present
  final cleanValue = value.replaceAll(RegExp(r'Z$'), '');
  return HijriDate.fromRRuleString(cleanValue);
}

/// Parse comma-separated integer list
List<int> _parseIntList(String value) {
  return value.split(',').map((v) {
    final num = int.tryParse(v.trim());
    if (num == null) {
      throw ArgumentError('Invalid integer in list: $v');
    }
    return num;
  }).toList();
}

/// Parse BYDAY value
///
/// Formats:
/// - "MO,TU,WE" - Simple weekdays
/// - "1MO" - First Monday
/// - "-1FR" - Last Friday
/// - "1MO,2TU,-1FR" - Mixed
List<WeekdaySpec> _parseByDay(String value) {
  final parts = value.split(',').map((p) => p.trim());
  final result = <WeekdaySpec>[];

  for (final part in parts) {
    final match = RegExp(r'^(-?\d+)?([A-Z]{2})$', caseSensitive: false).firstMatch(part);
    if (match == null) {
      throw ArgumentError('Invalid BYDAY value: $part');
    }

    final nStr = match.group(1);
    final dayStr = match.group(2)!;

    final weekday = WeekdayNum.fromString(dayStr);
    final n = nStr != null ? int.parse(nStr) : null;

    result.add(WeekdaySpec(weekday, n: n));
  }

  return result;
}

/// Try to parse a string as either an RRULE or just the properties
/// Returns null if parsing fails
HijriRRulePartialOptions? tryParseString(String str) {
  try {
    return parseString(str);
  } catch (_) {
    return null;
  }
}
