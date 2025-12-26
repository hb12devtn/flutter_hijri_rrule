import '../constants/weekday.dart';

export '../constants/weekday.dart' show WeekdayNum;

/// Interface for a weekday with optional nth occurrence
/// e.g., WeekdaySpec(WeekdayNum.fr, n: 1) means "first Friday"
class WeekdaySpec {
  /// The weekday
  final WeekdayNum weekday;

  /// nth occurrence (positive or negative)
  /// null means "every occurrence"
  /// 1 means "first", 2 means "second", -1 means "last", etc.
  final int? n;

  const WeekdaySpec(this.weekday, {this.n});

  /// Create a WeekdaySpec for the nth occurrence
  WeekdaySpec nth(int n) => WeekdaySpec(weekday, n: n);

  /// Format as RRULE string (e.g., "MO", "1MO", "-1FR")
  String toRRuleString() {
    if (n == null) {
      return weekday.name;
    }
    return '$n${weekday.name}';
  }

  /// Parse from RRULE string (e.g., "MO", "1MO", "-1FR")
  static WeekdaySpec fromRRuleString(String str) {
    final pattern = RegExp(r'^(-?\d+)?([A-Z]{2})$', caseSensitive: false);
    final match = pattern.firstMatch(str);
    if (match == null) {
      throw ArgumentError('Invalid weekday spec string: $str');
    }

    final nStr = match.group(1);
    final weekdayStr = match.group(2)!;

    final weekday = WeekdayNum.fromString(weekdayStr);
    final n = nStr != null ? int.parse(nStr) : null;

    return WeekdaySpec(weekday, n: n);
  }

  @override
  String toString() => 'WeekdaySpec(${weekday.name}${n != null ? ', n: $n' : ''})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeekdaySpec && other.weekday == weekday && other.n == n;
  }

  @override
  int get hashCode => Object.hash(weekday, n);
}
