import '../types/options.dart';
import '../constants/weekday.dart';
import '../constants/months.dart';
import '../calendar/hijri_date.dart';
import '../calendar/hijri_converter.dart';
import '../core/options_parser.dart';
import '../core/string_parser.dart';
import '../core/string_serializer.dart';
import '../core/iterator.dart' as iterator;
import '../core/rrule_cache.dart';
import '../nlp/to_text.dart' as nlp;

export '../weekday/hijri_weekday.dart';
export '../types/options.dart';
export '../calendar/hijri_date.dart';

/// Iterator callback function type
typedef IteratorCallback = bool? Function(DateTime date, int index);

/// Main HijriRRule class for working with Hijri calendar recurrence rules
///
/// Example:
/// ```dart
/// final rule = HijriRRule(HijriRRulePartialOptions(
///   freq: Frequency.yearly,
///   bymonth: [9],  // Ramadan
///   bymonthday: [1],
///   dtstart: HijriDate(1446, 9, 1),
///   count: 5
/// ));
///
/// final dates = rule.all();
/// ```
class HijriRRule {
  // Frequency constants
  static const Frequency yearly = Frequency.yearly;
  static const Frequency monthly = Frequency.monthly;
  static const Frequency weekly = Frequency.weekly;
  static const Frequency daily = Frequency.daily;
  static const Frequency hourly = Frequency.hourly;
  static const Frequency minutely = Frequency.minutely;
  static const Frequency secondly = Frequency.secondly;

  // Weekday constants
  static const WeekdayNum sa = WeekdayNum.sa;
  static const WeekdayNum su = WeekdayNum.su;
  static const WeekdayNum mo = WeekdayNum.mo;
  static const WeekdayNum tu = WeekdayNum.tu;
  static const WeekdayNum we = WeekdayNum.we;
  static const WeekdayNum th = WeekdayNum.th;
  static const WeekdayNum fr = WeekdayNum.fr;

  // Month constants
  static const int muharram = HijriMonth.muharram;
  static const int safar = HijriMonth.safar;
  static const int rabiAlAwwal = HijriMonth.rabiAlAwwal;
  static const int rabiAlThani = HijriMonth.rabiAlThani;
  static const int jumadaAlAwwal = HijriMonth.jumadaAlAwwal;
  static const int jumadaAlThani = HijriMonth.jumadaAlThani;
  static const int rajab = HijriMonth.rajab;
  static const int shaban = HijriMonth.shaban;
  static const int ramadan = HijriMonth.ramadan;
  static const int shawwal = HijriMonth.shawwal;
  static const int dhuAlQadah = HijriMonth.dhuAlQadah;
  static const int dhuAlHijjah = HijriMonth.dhuAlHijjah;

  /// Parsed options
  final HijriRRuleParsedOptions options;

  /// Original options passed to constructor
  final HijriRRulePartialOptions origOptions;

  /// Cache for computed results
  RRuleCache? _cache;

  /// Create a new HijriRRule
  ///
  /// [options] - Rule options
  /// [noCache] - If true, disable caching (default: false)
  HijriRRule(HijriRRulePartialOptions options, {bool noCache = false})
      : origOptions = options,
        options = parseOptions(options) {
    if (!noCache) {
      _cache = RRuleCache();
    }
  }

  /// Get all occurrences as DateTime objects
  ///
  /// [callback] - Optional callback function. If it returns false, iteration stops.
  /// Returns List of DateTime objects
  List<DateTime> all([IteratorCallback? callback]) {
    final hijriDates = allHijri(callback != null
        ? (d, i) => callback(_hijriToGreg(d), i)
        : null);

    return hijriDates.map((d) => _hijriToGreg(d)).toList();
  }

  /// Get all occurrences as HijriDate objects
  ///
  /// [callback] - Optional callback function. If it returns false, iteration stops.
  /// Returns List of HijriDate objects
  List<HijriDate> allHijri([bool? Function(HijriDate date, int index)? callback]) {
    // Check cache
    if (_cache?.hasAll() == true && callback == null) {
      return _cache!.getAll()!;
    }

    final result = <HijriDate>[];
    int index = 0;

    for (final date in iterator.iterate(options)) {
      if (callback != null) {
        final shouldContinue = callback(date, index);
        if (shouldContinue == false) {
          break;
        }
      }
      result.add(date);
      index++;
    }

    // Cache if no callback was used
    if (callback == null && _cache != null) {
      _cache!.setAll(result);
    }

    return result;
  }

  /// Get occurrences between two dates as DateTime objects
  ///
  /// [after] - Start date (exclusive by default)
  /// [before] - End date (exclusive by default)
  /// [inc] - If true, include dates equal to after/before (default: false)
  /// [callback] - Optional callback function
  /// Returns List of DateTime objects
  List<DateTime> between(
    Object after,
    Object before, {
    bool inc = false,
    IteratorCallback? callback,
  }) {
    final hijriDates = betweenHijri(
      after,
      before,
      inc: inc,
      callback: callback != null
          ? (d, i) => callback(_hijriToGreg(d), i)
          : null,
    );

    return hijriDates.map((d) => _hijriToGreg(d)).toList();
  }

  /// Get occurrences between two dates as HijriDate objects
  List<HijriDate> betweenHijri(
    Object after,
    Object before, {
    bool inc = false,
    bool? Function(HijriDate date, int index)? callback,
  }) {
    final afterHijri = _toHijriDate(after);
    final beforeHijri = _toHijriDate(before);

    // Check cache
    if (callback == null) {
      final cached = _cache?.getBetween(afterHijri, beforeHijri, inc);
      if (cached != null) return cached;
    }

    final result = <HijriDate>[];
    int index = 0;

    for (final date in iterator.iterate(options)) {
      // Stop if past 'before' date
      if (inc ? date.isAfter(beforeHijri) : date.isOnOrAfter(beforeHijri)) {
        if (!date.equals(beforeHijri) || !inc) break;
      }

      // Include if within range
      final isAfterStart = inc
          ? date.isOnOrAfter(afterHijri)
          : date.isAfter(afterHijri);
      final isBeforeEnd = inc
          ? date.isOnOrBefore(beforeHijri)
          : date.isBefore(beforeHijri);

      if (isAfterStart && isBeforeEnd) {
        if (callback != null) {
          final shouldContinue = callback(date, index);
          if (shouldContinue == false) break;
        }
        result.add(date);
        index++;
      }
    }

    // Cache if no callback was used
    if (callback == null && _cache != null) {
      _cache!.setBetween(afterHijri, beforeHijri, inc, result);
    }

    return result;
  }

  /// Get the first occurrence after a date
  ///
  /// [dt] - The reference date
  /// [inc] - If true, include date if it's an occurrence (default: false)
  /// Returns DateTime or null
  DateTime? after(Object dt, {bool inc = false}) {
    final hijriDate = afterHijri(dt, inc: inc);
    return hijriDate != null ? _hijriToGreg(hijriDate) : null;
  }

  /// Get the first occurrence after a date as HijriDate
  HijriDate? afterHijri(Object dt, {bool inc = false}) {
    final dtHijri = _toHijriDate(dt);

    // Check cache
    if (_cache?.containsAfter(dtHijri, inc) == true) {
      return _cache!.getAfter(dtHijri, inc);
    }

    final result = iterator.getAfter(options, dtHijri, inclusive: inc);

    // Cache result
    if (_cache != null) {
      _cache!.setAfter(dtHijri, inc, result);
    }

    return result;
  }

  /// Get the last occurrence before a date
  ///
  /// [dt] - The reference date
  /// [inc] - If true, include date if it's an occurrence (default: false)
  /// Returns DateTime or null
  DateTime? before(Object dt, {bool inc = false}) {
    final hijriDate = beforeHijri(dt, inc: inc);
    return hijriDate != null ? _hijriToGreg(hijriDate) : null;
  }

  /// Get the last occurrence before a date as HijriDate
  HijriDate? beforeHijri(Object dt, {bool inc = false}) {
    final dtHijri = _toHijriDate(dt);

    // Check cache
    if (_cache?.containsBefore(dtHijri, inc) == true) {
      return _cache!.getBefore(dtHijri, inc);
    }

    final result = iterator.getBefore(options, dtHijri, inclusive: inc);

    // Cache result
    if (_cache != null) {
      _cache!.setBefore(dtHijri, inc, result);
    }

    return result;
  }

  /// Get the count of occurrences
  int count() {
    if (options.count != null) {
      return options.count!;
    }
    // For rules without count, we need to iterate
    return allHijri().length;
  }

  /// Convert to RRULE string representation
  @override
  String toString() {
    return optionsToString(options);
  }

  /// Convert to human-readable text
  ///
  /// [locale] - Language locale ('en' or 'ar')
  /// Returns Human-readable text description
  String toText([String locale = 'en']) {
    return nlp.toText(options, locale);
  }

  /// Clone this rule
  HijriRRule clone() {
    return HijriRRule(optionsToPartial(options), noCache: _cache == null);
  }

  /// Create an iterator for this rule
  Iterable<DateTime> iterate() sync* {
    for (final date in iterator.iterate(options)) {
      yield _hijriToGreg(date);
    }
  }

  /// Create a Hijri date iterator
  Iterable<HijriDate> iterateHijri() sync* {
    yield* iterator.iterate(options);
  }

  // Static methods

  /// Create an HijriRRule from an RRULE string
  ///
  /// [str] - RRULE string
  /// [noCache] - If true, disable caching
  /// Returns HijriRRule instance
  static HijriRRule fromString(String str, {bool noCache = false}) {
    final options = parseString(str);
    return HijriRRule(options, noCache: noCache);
  }

  /// Parse an RRULE string into options without creating an instance
  ///
  /// [str] - RRULE string
  /// Returns Partial options object
  static HijriRRulePartialOptions parseStringStatic(String str) {
    return parseString(str);
  }

  /// Convert options to RRULE string
  ///
  /// [options] - Partial or parsed options
  /// Returns RRULE string
  static String optionsToStringStatic(dynamic options) {
    return optionsToString(options);
  }

  // Helper methods

  /// Convert DateTime or HijriDateLike to HijriDate using this rule's calendar
  HijriDate _toHijriDate(Object value) {
    if (value is DateTime) {
      final components = gregorianToHijri(value, options.calendar);
      return HijriDate(components.year, components.month, components.day);
    }
    if (value is HijriDate) {
      return value;
    }
    if (value is HijriDateLike) {
      return HijriDate(value.year, value.month, value.day);
    }
    throw ArgumentError('Invalid date value: $value');
  }

  /// Convert HijriDate to DateTime using this rule's calendar
  DateTime _hijriToGreg(HijriDate hijriDate) {
    final gregorian = hijriToGregorian(
      hijriDate.year,
      hijriDate.month,
      hijriDate.day,
      options.calendar,
    );
    return DateTime(
      gregorian.year,
      gregorian.month,
      gregorian.day,
      hijriDate.hour,
      hijriDate.minute,
      hijriDate.second,
    );
  }
}
