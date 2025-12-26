import '../types/weekday.dart';
import '../constants/weekday.dart';

/// Represents a weekday with optional nth occurrence
/// Used for rules like "first Friday" or "last Monday"
class HijriWeekday implements WeekdaySpec {
  /// The weekday (0=Saturday, 1=Sunday, ..., 6=Friday)
  @override
  final WeekdayNum weekday;

  /// Optional nth occurrence (1=first, 2=second, -1=last, -2=second last)
  @override
  final int? n;

  /// Create a new HijriWeekday
  ///
  /// [weekday] - The weekday enum value
  /// [n] - Optional nth occurrence
  const HijriWeekday(this.weekday, {this.n});

  /// Create a new HijriWeekday with nth occurrence
  /// Chainable method for fluent API
  ///
  /// Example:
  /// ```dart
  /// HijriWeekday.fr.nth(1)  // First Friday
  /// HijriWeekday.mo.nth(-1) // Last Monday
  /// ```
  @override
  HijriWeekday nth(int n) {
    return HijriWeekday(weekday, n: n);
  }

  /// Check if this weekday equals another
  bool equals(HijriWeekday other) {
    return weekday == other.weekday && n == other.n;
  }

  /// Get string representation for RRULE (e.g., "MO", "1FR", "-1TH")
  @override
  String toString() {
    final dayStr = weekday.name;
    if (n != null) {
      return '$n$dayStr';
    }
    return dayStr;
  }

  /// Format as RRULE string
  @override
  String toRRuleString() => toString();

  /// Get human-readable string
  String toText([String locale = 'en']) {
    final names = locale == 'ar' ? weekdayNamesAr : weekdayNamesEn;
    final dayName = names[weekday.value];

    if (n == null) {
      return dayName;
    }

    if (locale == 'ar') {
      return '$dayName ${_getOrdinalAr(n!)}';
    }

    final ordinal = _getOrdinalEn(n!);
    return 'the $ordinal $dayName';
  }

  /// Get ordinal string in English (e.g., "first", "second", "last")
  String _getOrdinalEn(int n) {
    if (n == -1) return 'last';
    if (n == -2) return 'second last';
    if (n == -3) return 'third last';

    const ordinals = {
      1: 'first',
      2: 'second',
      3: 'third',
      4: 'fourth',
      5: 'fifth',
    };

    return ordinals[n] ?? '${n}th';
  }

  /// Get ordinal string in Arabic
  String _getOrdinalAr(int n) {
    if (n == -1) return 'الأخير';
    if (n == -2) return 'قبل الأخير';

    const ordinals = {
      1: 'الأول',
      2: 'الثاني',
      3: 'الثالث',
      4: 'الرابع',
      5: 'الخامس',
    };

    return ordinals[n] ?? '$n';
  }

  /// Parse a weekday string like "MO", "1FR", "-1TH"
  static HijriWeekday fromString(String str) {
    final spec = WeekdaySpec.fromRRuleString(str);
    return HijriWeekday(spec.weekday, n: spec.n);
  }

  /// Get the weekday value for use in comparisons
  int valueOf() => weekday.value;

  /// Get JSON representation
  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{'weekday': weekday.value};
    if (n != null) {
      result['n'] = n;
    }
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HijriWeekday && other.weekday == weekday && other.n == n;
  }

  @override
  int get hashCode => Object.hash(weekday, n);

  // Static weekday constants for convenient access
  static const sa = HijriWeekday(WeekdayNum.sa);
  static const su = HijriWeekday(WeekdayNum.su);
  static const mo = HijriWeekday(WeekdayNum.mo);
  static const tu = HijriWeekday(WeekdayNum.tu);
  static const we = HijriWeekday(WeekdayNum.we);
  static const th = HijriWeekday(WeekdayNum.th);
  static const fr = HijriWeekday(WeekdayNum.fr);
}

// Export convenience weekday constants
const sa = HijriWeekday.sa;
const su = HijriWeekday.su;
const mo = HijriWeekday.mo;
const tu = HijriWeekday.tu;
const we = HijriWeekday.we;
const th = HijriWeekday.th;
const fr = HijriWeekday.fr;
