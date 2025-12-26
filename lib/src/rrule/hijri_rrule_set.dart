import '../calendar/hijri_converter.dart';
import '../core/rrule_cache.dart';
import 'hijri_rrule.dart';

/// HijriRRuleSet - Combines multiple RRules, RDATEs, EXRULEs, and EXDATEs
///
/// Allows for complex recurrence patterns with inclusions and exclusions.
///
/// Example:
/// ```dart
/// final ruleSet = HijriRRuleSet();
///
/// // Add a rule for 1st of every month
/// ruleSet.rrule(HijriRRule(HijriRRulePartialOptions(
///   freq: Frequency.monthly,
///   bymonthday: [1],
///   dtstart: HijriDate(1446, 1, 1)
/// )));
///
/// // Add specific dates
/// ruleSet.rdate(HijriDate(1446, 6, 15));
///
/// // Exclude certain dates
/// ruleSet.exdate(HijriDate(1446, 3, 1));
///
/// final dates = ruleSet.all();
/// ```
class HijriRRuleSet {
  final List<HijriRRule> _rrules = [];
  final List<HijriDate> _rdates = [];
  final List<HijriRRule> _exrules = [];
  final List<HijriDate> _exdates = [];
  String? _tzid;
  RRuleCache? _cache;

  /// Create a new HijriRRuleSet
  ///
  /// [noCache] - If true, disable caching (default: false)
  HijriRRuleSet({bool noCache = false}) {
    if (!noCache) {
      _cache = RRuleCache();
    }
  }

  /// Add an RRule to the set
  void rrule(HijriRRule rule) {
    _rrules.add(rule);
    _clearCache();
  }

  /// Add a date to the set
  void rdate(Object date) {
    _rdates.add(_toHijriDate(date));
    _clearCache();
  }

  /// Add an exclusion rule to the set
  void exrule(HijriRRule rule) {
    _exrules.add(rule);
    _clearCache();
  }

  /// Add an exclusion date to the set
  void exdate(Object date) {
    _exdates.add(_toHijriDate(date));
    _clearCache();
  }

  /// Set or get the timezone
  String? tzid([String? tz]) {
    if (tz != null) {
      _tzid = tz;
    }
    return _tzid;
  }

  /// Get all RRules
  List<HijriRRule> rrules() => List.unmodifiable(_rrules);

  /// Get all RDATEs as HijriDate
  List<HijriDate> rdatesHijri() => List.unmodifiable(_rdates);

  /// Get all RDATEs as DateTime
  List<DateTime> rdates() => _rdates.map((d) => d.toGregorian()).toList();

  /// Get all EXRULEs
  List<HijriRRule> exrules() => List.unmodifiable(_exrules);

  /// Get all EXDATEs as HijriDate
  List<HijriDate> exdatesHijri() => List.unmodifiable(_exdates);

  /// Get all EXDATEs as DateTime
  List<DateTime> exdates() => _exdates.map((d) => d.toGregorian()).toList();

  /// Get all occurrences as DateTime objects
  ///
  /// [callback] - Optional callback function
  /// Returns List of DateTime objects
  List<DateTime> all([IteratorCallback? callback]) {
    final hijriDates = allHijri(
      callback != null
          ? (d, i) => callback(d.toGregorian(), i)
          : null,
    );
    return hijriDates.map((d) => d.toGregorian()).toList();
  }

  /// Get all occurrences as HijriDate objects
  List<HijriDate> allHijri([bool? Function(HijriDate date, int index)? callback]) {
    // Check cache
    if (_cache?.hasAll() == true && callback == null) {
      return _cache!.getAll()!;
    }

    final result = _generateOccurrences();

    if (callback != null) {
      final filtered = <HijriDate>[];
      for (int i = 0; i < result.length; i++) {
        final shouldContinue = callback(result[i], i);
        if (shouldContinue == false) break;
        filtered.add(result[i]);
      }
      return filtered;
    }

    // Cache if no callback
    if (_cache != null) {
      _cache!.setAll(result);
    }

    return result;
  }

  /// Get occurrences between two dates
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
          ? (d, i) => callback(d.toGregorian(), i)
          : null,
    );
    return hijriDates.map((d) => d.toGregorian()).toList();
  }

  /// Get occurrences between two dates as HijriDate
  List<HijriDate> betweenHijri(
    Object after,
    Object before, {
    bool inc = false,
    bool? Function(HijriDate date, int index)? callback,
  }) {
    final afterHijri = _toHijriDate(after);
    final beforeHijri = _toHijriDate(before);

    final all = allHijri();
    final result = <HijriDate>[];
    int index = 0;

    for (final date in all) {
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

      // Stop if past the end
      if (date.isAfter(beforeHijri)) break;
    }

    return result;
  }

  /// Get the first occurrence after a date
  DateTime? after(Object dt, {bool inc = false}) {
    final hijriDate = afterHijri(dt, inc: inc);
    return hijriDate?.toGregorian();
  }

  /// Get the first occurrence after a date as HijriDate
  HijriDate? afterHijri(Object dt, {bool inc = false}) {
    final dtHijri = _toHijriDate(dt);
    final all = allHijri();

    for (final date in all) {
      if (inc ? date.isOnOrAfter(dtHijri) : date.isAfter(dtHijri)) {
        return date;
      }
    }

    return null;
  }

  /// Get the last occurrence before a date
  DateTime? before(Object dt, {bool inc = false}) {
    final hijriDate = beforeHijri(dt, inc: inc);
    return hijriDate?.toGregorian();
  }

  /// Get the last occurrence before a date as HijriDate
  HijriDate? beforeHijri(Object dt, {bool inc = false}) {
    final dtHijri = _toHijriDate(dt);
    final all = allHijri();

    HijriDate? last;

    for (final date in all) {
      if (inc ? date.isOnOrBefore(dtHijri) : date.isBefore(dtHijri)) {
        last = date;
      } else {
        break;
      }
    }

    return last;
  }

  /// Get string representation of all rules
  List<String> valueOf() {
    final result = <String>[];

    for (final rule in _rrules) {
      result.add(rule.toString());
    }

    for (final date in _rdates) {
      result.add('RDATE;CALENDAR=HIJRI:${date.toRRuleString()}');
    }

    for (final rule in _exrules) {
      result.add(rule.toString().replaceFirst('RRULE:', 'EXRULE:'));
    }

    for (final date in _exdates) {
      result.add('EXDATE;CALENDAR=HIJRI:${date.toRRuleString()}');
    }

    return result;
  }

  /// Get single string representation
  @override
  String toString() {
    return valueOf().join('\n');
  }

  /// Clone this rule set
  HijriRRuleSet clone() {
    final cloned = HijriRRuleSet(noCache: _cache == null);

    for (final rule in _rrules) {
      cloned.rrule(rule.clone());
    }

    for (final date in _rdates) {
      cloned.rdate(date.clone());
    }

    for (final rule in _exrules) {
      cloned.exrule(rule.clone());
    }

    for (final date in _exdates) {
      cloned.exdate(date.clone());
    }

    if (_tzid != null) {
      cloned.tzid(_tzid);
    }

    return cloned;
  }

  // Private methods

  /// Generate all occurrences from rules and dates, minus exclusions
  List<HijriDate> _generateOccurrences() {
    // Collect all inclusion dates
    final inclusions = <String, HijriDate>{};

    // Add RDATEs
    for (final date in _rdates) {
      inclusions[date.toString()] = date;
    }

    // Add dates from RRULEs
    for (final rule in _rrules) {
      final dates = rule.allHijri();
      for (final date in dates) {
        inclusions[date.toString()] = date;
      }
    }

    // Collect all exclusion dates
    final exclusions = <String>{};

    // Add EXDATEs
    for (final date in _exdates) {
      exclusions.add(date.toString());
    }

    // Add dates from EXRULEs
    for (final rule in _exrules) {
      final dates = rule.allHijri();
      for (final date in dates) {
        exclusions.add(date.toString());
      }
    }

    // Filter out exclusions and sort
    final result = <HijriDate>[];
    for (final entry in inclusions.entries) {
      if (!exclusions.contains(entry.key)) {
        result.add(entry.value);
      }
    }

    // Sort by date
    result.sort((a, b) => a.compare(b));

    return result;
  }

  /// Convert DateTime or HijriDateLike to HijriDate
  HijriDate _toHijriDate(Object value) {
    if (value is DateTime) {
      final components = gregorianToHijri(value);
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

  /// Clear the cache
  void _clearCache() {
    _cache?.clear();
  }
}
