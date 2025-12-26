import '../constants/frequency.dart';
import 'calendar_types.dart';
import 'weekday.dart';

export '../constants/frequency.dart' show Frequency;
export 'calendar_types.dart' show IslamicCalendarType;
export 'weekday.dart' show WeekdaySpec;

/// Forward declaration interface for HijriDate to avoid circular dependency
abstract class HijriDateLike {
  int get year;
  int get month;
  int get day;
  int get hour;
  int get minute;
  int get second;
  DateTime toGregorian();
}

/// Strategy for handling days that don't exist in a month
/// e.g., day 30 in a 29-day month
enum Skip {
  /// Omit/skip the occurrence (default)
  omit('omit'),

  /// Move forward to next valid day (1st of next month)
  forward('forward'),

  /// Move backward to last valid day of the month
  backward('backward');

  const Skip(this.value);

  final String value;

  static Skip fromString(String str) {
    final lowerStr = str.toLowerCase();
    for (final skip in Skip.values) {
      if (skip.value == lowerStr) {
        return skip;
      }
    }
    throw ArgumentError('Invalid skip strategy: $str');
  }
}

/// Options that can be passed to HijriRRule constructor
/// Partial options - not all fields are required
class HijriRRulePartialOptions {
  /// Recurrence frequency (required)
  final Frequency freq;

  /// Start date of the recurrence in Hijri calendar
  final Object? dtstart; // HijriDateLike or DateTime

  /// Interval between each freq iteration (default: 1)
  final int? interval;

  /// Week start day (default: Sunday for Islamic convention)
  final WeekdayNum? wkst;

  /// Total number of occurrences to generate
  final int? count;

  /// End date limit for recurrence
  final Object? until; // HijriDateLike or DateTime

  /// Timezone identifier (IANA format)
  final String? tzid;

  /// Position within the frequency period
  final List<int>? bysetpos;

  /// Months to apply recurrence (1-12, where 1=Muharram, 9=Ramadan, 12=Dhu al-Hijjah)
  final List<int>? bymonth;

  /// Days of month to apply recurrence (1-30 or -1 to -30)
  final List<int>? bymonthday;

  /// Days of year to apply recurrence (1-355 or -1 to -355)
  final List<int>? byyearday;

  /// Week numbers to apply recurrence
  final List<int>? byweekno;

  /// Weekdays to apply recurrence
  final List<Object>? byweekday; // WeekdayNum or WeekdaySpec

  /// Hours to apply recurrence (0-23)
  final List<int>? byhour;

  /// Minutes to apply recurrence (0-59)
  final List<int>? byminute;

  /// Seconds to apply recurrence (0-59)
  final List<int>? bysecond;

  /// Strategy for handling invalid days (default: omit)
  final Skip? skip;

  /// Islamic calendar type to use for calculations
  /// - 'islamic-umalqura': Saudi official calendar (default)
  /// - 'islamic-tbla': Tabular Islamic Calendar
  final IslamicCalendarType? calendar;

  const HijriRRulePartialOptions({
    required this.freq,
    this.dtstart,
    this.interval,
    this.wkst,
    this.count,
    this.until,
    this.tzid,
    this.bysetpos,
    this.bymonth,
    this.bymonthday,
    this.byyearday,
    this.byweekno,
    this.byweekday,
    this.byhour,
    this.byminute,
    this.bysecond,
    this.skip,
    this.calendar,
  });

  /// Create a copy with modified values
  HijriRRulePartialOptions copyWith({
    Frequency? freq,
    Object? dtstart,
    int? interval,
    WeekdayNum? wkst,
    int? count,
    Object? until,
    String? tzid,
    List<int>? bysetpos,
    List<int>? bymonth,
    List<int>? bymonthday,
    List<int>? byyearday,
    List<int>? byweekno,
    List<Object>? byweekday,
    List<int>? byhour,
    List<int>? byminute,
    List<int>? bysecond,
    Skip? skip,
    IslamicCalendarType? calendar,
  }) {
    return HijriRRulePartialOptions(
      freq: freq ?? this.freq,
      dtstart: dtstart ?? this.dtstart,
      interval: interval ?? this.interval,
      wkst: wkst ?? this.wkst,
      count: count ?? this.count,
      until: until ?? this.until,
      tzid: tzid ?? this.tzid,
      bysetpos: bysetpos ?? this.bysetpos,
      bymonth: bymonth ?? this.bymonth,
      bymonthday: bymonthday ?? this.bymonthday,
      byyearday: byyearday ?? this.byyearday,
      byweekno: byweekno ?? this.byweekno,
      byweekday: byweekday ?? this.byweekday,
      byhour: byhour ?? this.byhour,
      byminute: byminute ?? this.byminute,
      bysecond: bysecond ?? this.bysecond,
      skip: skip ?? this.skip,
      calendar: calendar ?? this.calendar,
    );
  }
}

/// Fully parsed and normalized options
/// All arrays are normalized, defaults are applied
class HijriRRuleParsedOptions {
  /// Recurrence frequency
  final Frequency freq;

  /// Start date of the recurrence (HijriDate)
  final HijriDateLike dtstart;

  /// Interval between each freq iteration
  final int interval;

  /// Week start day
  final WeekdayNum wkst;

  /// Total number of occurrences to generate
  final int? count;

  /// End date limit for recurrence
  final HijriDateLike? until;

  /// Timezone identifier
  final String? tzid;

  /// Position within the frequency period (always list)
  final List<int>? bysetpos;

  /// Months to apply recurrence (always list)
  final List<int>? bymonth;

  /// Days of month to apply recurrence (always list, positive only)
  final List<int>? bymonthday;

  /// Negative days of month (e.g., -1 = last day)
  final List<int>? bynmonthday;

  /// Days of year to apply recurrence (always list)
  final List<int>? byyearday;

  /// Week numbers to apply recurrence (always list)
  final List<int>? byweekno;

  /// Weekdays to apply recurrence (always list of WeekdaySpec, without n)
  final List<WeekdaySpec>? byweekday;

  /// Nth weekdays (weekdays with n specified)
  final List<WeekdaySpec>? bynweekday;

  /// Hours to apply recurrence (always list)
  final List<int>? byhour;

  /// Minutes to apply recurrence (always list)
  final List<int>? byminute;

  /// Seconds to apply recurrence (always list)
  final List<int>? bysecond;

  /// Strategy for handling invalid days
  final Skip skip;

  /// Islamic calendar type used for calculations
  final IslamicCalendarType calendar;

  const HijriRRuleParsedOptions({
    required this.freq,
    required this.dtstart,
    required this.interval,
    required this.wkst,
    this.count,
    this.until,
    this.tzid,
    this.bysetpos,
    this.bymonth,
    this.bymonthday,
    this.bynmonthday,
    this.byyearday,
    this.byweekno,
    this.byweekday,
    this.bynweekday,
    this.byhour,
    this.byminute,
    this.bysecond,
    required this.skip,
    required this.calendar,
  });
}

/// Options for rrulestr parser
class RRuleStrOptions {
  /// Enable caching
  final bool cache;

  /// Default dtstart if not in string
  final Object? dtstart; // HijriDateLike or DateTime

  /// Unfold lines per RFC
  final bool unfold;

  /// Force return of RRuleSet even for single rule
  final bool forceset;

  /// RFC-compatible mode
  final bool compatible;

  /// Default timezone if not in string
  final String? tzid;

  const RRuleStrOptions({
    this.cache = true,
    this.dtstart,
    this.unfold = false,
    this.forceset = false,
    this.compatible = false,
    this.tzid,
  });
}
