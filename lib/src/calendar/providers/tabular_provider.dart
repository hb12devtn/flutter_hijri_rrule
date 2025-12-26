/// Tabular Islamic Calendar Provider
///
/// Uses the fixed Tabular Islamic Calendar algorithm (Type IIa)
/// with a 30-year cycle containing 11 leap years.
///
/// This is the traditional calculational calendar and matches
/// the Intl `islamic-tbla` calendar type.
library;

import '../../constants/calendar_constants.dart';
import '../../types/calendar_types.dart';

/// Tabular Islamic Calendar Provider
///
/// Implements the CalendarProvider interface using the fixed
/// tabular algorithm with 30-year cycles.
class TabularCalendarProvider implements CalendarProvider {
  @override
  final IslamicCalendarType type = IslamicCalendarType.islamicTbla;

  /// Check if a Hijri year is a leap year
  /// Leap years in the 30-year cycle: 2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29
  @override
  bool isLeapYear(int year) {
    int yearInCycle = year % lunarCycleYears;
    if (yearInCycle <= 0) {
      yearInCycle += lunarCycleYears;
    }
    return leapYearsInCycle.contains(yearInCycle);
  }

  /// Get the number of days in a Hijri month
  /// Odd months have 30 days, even months have 29 days
  /// Exception: Month 12 has 30 days in leap years
  @override
  int getMonthLength(int year, int month) {
    if (month < minMonth || month > maxMonth) {
      throw ArgumentError(
          'Invalid Hijri month: $month. Must be between 1 and 12.');
    }

    // Month 12 (Dhu al-Hijjah) has 30 days in leap years
    if (month == 12 && isLeapYear(year)) {
      return 30;
    }

    return monthDays[month - 1];
  }

  /// Get the total number of days in a Hijri year
  @override
  int getYearLength(int year) {
    return isLeapYear(year) ? leapYearDays : commonYearDays;
  }

  /// Convert a Gregorian Date to Hijri date components
  @override
  HijriDateComponents gregorianToHijri(DateTime date) {
    final jdn = _gregorianToJulianDay(date);
    return _julianDayToHijri(jdn);
  }

  /// Convert Hijri date components to a Gregorian Date
  @override
  DateTime hijriToGregorian(int year, int month, int day) {
    final jdn = _hijriToJulianDay(year, month, day);
    return _julianDayToGregorian(jdn);
  }

  /// Validate if a Hijri date exists
  @override
  bool isValidDate(int year, int month, int day) {
    if (year < 1 || year != year.toInt()) {
      return false;
    }

    if (month < minMonth || month > maxMonth || month != month.toInt()) {
      return false;
    }

    if (day < 1 || day != day.toInt()) {
      return false;
    }

    final maxDay = getMonthLength(year, month);
    return day <= maxDay;
  }

  // ========== Internal conversion methods ==========

  double _gregorianToJulianDay(DateTime date) {
    final year = date.year;
    final month = date.month;
    final day = date.day;

    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;

    return (day +
            ((153 * m + 2) ~/ 5) +
            365 * y +
            (y ~/ 4) -
            (y ~/ 100) +
            (y ~/ 400) -
            32045)
        .toDouble();
  }

  DateTime _julianDayToGregorian(double jdn) {
    final z = (jdn + 0.5).floor();
    int a = z;

    if (z >= 2299161) {
      final alpha = ((z - 1867216.25) / 36524.25).floor();
      a = z + 1 + alpha - (alpha ~/ 4);
    }

    final b = a + 1524;
    final c = ((b - 122.1) / 365.25).floor();
    final d = (365.25 * c).floor();
    final e = ((b - d) / 30.6001).floor();

    final day = b - d - (30.6001 * e).floor();
    final month = e < 14 ? e - 1 : e - 13;
    final year = month > 2 ? c - 4716 : c - 4715;

    return DateTime.utc(year, month, day, 12, 0, 0);
  }

  double _hijriToJulianDay(int year, int month, int day) {
    // Complete 30-year cycles
    final cycles = (year - 1) ~/ lunarCycleYears;
    final yearsInCycle = ((year - 1) % lunarCycleYears) + 1;

    // Days from complete cycles
    double days = (cycles * lunarCycleDays).toDouble();

    // Days from years within current cycle
    for (int y = 1; y < yearsInCycle; y++) {
      days += leapYearsInCycle.contains(y) ? leapYearDays : commonYearDays;
    }

    // Days from months in current year
    for (int m = 1; m < month; m++) {
      days += getMonthLength(year, m);
    }

    // Add day of month (minus 1 because epoch is day 1)
    days += day - 1;

    return hijriEpochJd + days;
  }

  HijriDateComponents _julianDayToHijri(double jdn) {
    final daysSinceEpoch = (jdn - hijriEpochJd + 0.5).floor();

    if (daysSinceEpoch < 0) {
      throw ArgumentError('Date is before Hijri epoch (1 Muharram 1 AH)');
    }

    // Calculate 30-year cycles
    final cycles = daysSinceEpoch ~/ lunarCycleDays;
    int remainingDays = daysSinceEpoch % lunarCycleDays;

    // Calculate year within cycle
    int year = cycles * lunarCycleYears;
    for (int y = 1; y <= lunarCycleYears; y++) {
      final yearLength =
          leapYearsInCycle.contains(y) ? leapYearDays : commonYearDays;

      if (remainingDays < yearLength) {
        year += y;
        break;
      }
      remainingDays -= yearLength;

      if (y == lunarCycleYears) {
        year += lunarCycleYears;
        remainingDays = 0;
      }
    }

    // Calculate month and day
    int month = 1;
    for (int m = 1; m <= 12; m++) {
      final monthLength = getMonthLength(year, m);
      if (remainingDays < monthLength) {
        month = m;
        break;
      }
      remainingDays -= monthLength;

      if (m == 12) {
        month = 12;
      }
    }

    final day = remainingDays + 1;

    return HijriDateComponents(year: year, month: month, day: day);
  }
}

/// Singleton instance
TabularCalendarProvider? _instance;

/// Get the TabularCalendarProvider singleton
TabularCalendarProvider getTabularProvider() {
  _instance ??= TabularCalendarProvider();
  return _instance!;
}
