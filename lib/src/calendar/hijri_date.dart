import '../constants/months.dart';
import '../types/options.dart';
import 'hijri_calendar.dart';
import 'hijri_converter.dart' as converter;

/// Immutable value object representing a date in the Hijri calendar
class HijriDate implements HijriDateLike, Comparable<HijriDate> {
  /// The Hijri year (1+)
  @override
  final int year;

  /// The Hijri month (1-12, where 1=Muharram, 9=Ramadan, 12=Dhu al-Hijjah)
  @override
  final int month;

  /// The day of the month (1-30)
  @override
  final int day;

  /// Hour (0-23), defaults to 0
  @override
  final int hour;

  /// Minute (0-59), defaults to 0
  @override
  final int minute;

  /// Second (0-59), defaults to 0
  @override
  final int second;

  /// Create a new HijriDate
  ///
  /// [year] - The Hijri year (must be >= 1)
  /// [month] - The Hijri month (1-12)
  /// [day] - The day of the month (1-30)
  /// [hour] - Hour (0-23), defaults to 0
  /// [minute] - Minute (0-59), defaults to 0
  /// [second] - Second (0-59), defaults to 0
  HijriDate(
    this.year,
    this.month,
    this.day, [
    this.hour = 0,
    this.minute = 0,
    this.second = 0,
  ]) {
    if (!isValidHijriDate(year, month, day)) {
      final maxDay = (month >= 1 && month <= 12) ? getMonthLength(year, month) : 30;
      throw ArgumentError(
          'Invalid Hijri date: $year-$month-$day. '
          'Month $month in year $year has $maxDay days.');
    }

    if (hour < 0 || hour > 23) {
      throw ArgumentError('Invalid hour: $hour. Must be between 0 and 23.');
    }

    if (minute < 0 || minute > 59) {
      throw ArgumentError('Invalid minute: $minute. Must be between 0 and 59.');
    }

    if (second < 0 || second > 59) {
      throw ArgumentError('Invalid second: $second. Must be between 0 and 59.');
    }
  }

  /// Create a HijriDate from a plain object
  factory HijriDate.from(HijriDateLike obj) {
    if (obj is HijriDate) {
      return obj;
    }
    return HijriDate(obj.year, obj.month, obj.day, obj.hour, obj.minute, obj.second);
  }

  /// Create a HijriDate from a Gregorian DateTime
  factory HijriDate.fromGregorian(DateTime date, [IslamicCalendarType? calendar]) {
    final components = converter.gregorianToHijri(date, calendar);
    return HijriDate(
      components.year,
      components.month,
      components.day,
      date.hour,
      date.minute,
      date.second,
    );
  }

  /// Create a HijriDate for the current moment
  factory HijriDate.now([IslamicCalendarType? calendar]) {
    return HijriDate.fromGregorian(DateTime.now(), calendar);
  }

  /// Create from RRULE format string: YYYYMMDD or YYYYMMDDTHHMMSS
  factory HijriDate.fromRRuleString(String str) {
    final datePattern = RegExp(r'^(\d{4})(\d{2})(\d{2})(T(\d{2})(\d{2})(\d{2}))?$');
    final match = datePattern.firstMatch(str);

    if (match == null) {
      throw ArgumentError('Invalid RRULE date string: $str');
    }

    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final hour = match.group(5) != null ? int.parse(match.group(5)!) : 0;
    final minute = match.group(6) != null ? int.parse(match.group(6)!) : 0;
    final second = match.group(7) != null ? int.parse(match.group(7)!) : 0;

    return HijriDate(year, month, day, hour, minute, second);
  }

  /// Convert to Gregorian DateTime
  @override
  DateTime toGregorian([IslamicCalendarType? calendar]) {
    final gregorian = converter.hijriToGregorian(year, month, day, calendar);
    return DateTime(
      gregorian.year,
      gregorian.month,
      gregorian.day,
      hour,
      minute,
      second,
    );
  }

  /// Create a copy of this date
  HijriDate clone() {
    return HijriDate(year, month, day, hour, minute, second);
  }

  /// Create a copy with some values changed
  HijriDate copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
  }) {
    return HijriDate(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
    );
  }

  /// Check if this date equals another date (ignores time)
  bool equals(HijriDateLike other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Check if this date is before another date
  bool isBefore(HijriDateLike other) {
    if (year != other.year) return year < other.year;
    if (month != other.month) return month < other.month;
    return day < other.day;
  }

  /// Check if this date is after another date
  bool isAfter(HijriDateLike other) {
    if (year != other.year) return year > other.year;
    if (month != other.month) return month > other.month;
    return day > other.day;
  }

  /// Check if this date is on or before another date
  bool isOnOrBefore(HijriDateLike other) {
    return equals(other) || isBefore(other);
  }

  /// Check if this date is on or after another date
  bool isOnOrAfter(HijriDateLike other) {
    return equals(other) || isAfter(other);
  }

  /// Compare this date with another date
  /// Returns negative if this < other, 0 if equal, positive if this > other
  int compare(HijriDateLike other) {
    if (year != other.year) return year - other.year;
    if (month != other.month) return month - other.month;
    return day - other.day;
  }

  @override
  int compareTo(HijriDate other) => compare(other);

  /// Get day of year (1-355)
  int getDayOfYear() {
    return getDayOfYear2(year, month, day);
  }

  /// Get the number of days in this month
  int getDaysInMonth() {
    return getMonthLength(year, month);
  }

  /// Get the number of days in this year
  int getDaysInYear() {
    return getYearLength(year);
  }

  /// Format as ISO-like string: YYYY-MM-DD
  @override
  String toString() {
    final y = year.toString().padLeft(4, '0');
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Format as ISO-like string with time: YYYY-MM-DDTHH:MM:SS
  String toISOString() {
    final date = toString();
    final h = hour.toString().padLeft(2, '0');
    final min = minute.toString().padLeft(2, '0');
    final s = second.toString().padLeft(2, '0');
    return '${date}T$h:$min:$s';
  }

  /// Format with month name
  /// e.g., "1 Ramadan 1446 AH" or "1 رمضان 1446" (Arabic)
  String toLocaleDateString([String locale = 'en']) {
    final monthNames = locale == 'ar' ? monthNamesAr : monthNamesEn;
    final monthName = monthNames[month];

    if (locale == 'ar') {
      return '$day $monthName $year';
    }
    return '$day $monthName $year AH';
  }

  /// Format for RRULE DTSTART: YYYYMMDD or YYYYMMDDTHHMMSS
  String toRRuleString([bool includeTime = false]) {
    final y = year.toString().padLeft(4, '0');
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');

    if (!includeTime && hour == 0 && minute == 0 && second == 0) {
      return '$y$m$d';
    }

    final hh = hour.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    final ss = second.toString().padLeft(2, '0');
    return '$y$m${d}T$hh$mm$ss';
  }

  /// Get a JSON representation
  Map<String, int> toJson() {
    return {
      'year': year,
      'month': month,
      'day': day,
    };
  }

  /// Value of the date (for comparisons)
  /// Format: YYYYMMDD as a number
  int valueOf() {
    return year * 10000 + month * 100 + day;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HijriDate && equals(other);
  }

  @override
  int get hashCode => Object.hash(year, month, day);
}

/// Helper function to create a HijriDate
HijriDate hijriDate(
  int year,
  int month,
  int day, [
  int hour = 0,
  int minute = 0,
  int second = 0,
]) {
  return HijriDate(year, month, day, hour, minute, second);
}

// Private helper to avoid naming conflict
int getDayOfYear2(int year, int month, int day) {
  return getDayOfYear(year, month, day);
}
