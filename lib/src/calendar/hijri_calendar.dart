import '../constants/calendar_constants.dart';
import '../types/calendar_types.dart';
import 'calendar_config.dart';

/// Check if a Hijri year is a leap year
///
/// [year] - The Hijri year to check
/// [calendar] - Calendar type to use (defaults to global config)
/// Returns true if the year is a leap year
///
/// Leap years in the 30-year cycle: 2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29
/// In a leap year, Dhu al-Hijjah (month 12) has 30 days instead of 29
bool isLeapYear(int year, [IslamicCalendarType? calendar]) {
  final provider = getCalendarProvider(calendar);
  return provider.isLeapYear(year);
}

/// Get the number of days in a specific Hijri month
///
/// [year] - The Hijri year
/// [month] - The Hijri month (1-12)
/// [calendar] - Calendar type to use (defaults to global config)
/// Returns Number of days in the month (29 or 30)
///
/// Odd months (1,3,5,7,9,11) have 30 days
/// Even months (2,4,6,8,10,12) have 29 days
/// Exception: Month 12 (Dhu al-Hijjah) has 30 days in leap years
int getMonthLength(int year, int month, [IslamicCalendarType? calendar]) {
  final provider = getCalendarProvider(calendar);
  return provider.getMonthLength(year, month);
}

/// Get the total number of days in a Hijri year
///
/// [year] - The Hijri year
/// [calendar] - Calendar type to use (defaults to global config)
/// Returns Number of days in the year (354 or 355)
int getYearLength(int year, [IslamicCalendarType? calendar]) {
  final provider = getCalendarProvider(calendar);
  return provider.getYearLength(year);
}

/// Get the number of days before a specific month in a year
///
/// [year] - The Hijri year
/// [month] - The Hijri month (1-12)
/// Returns Number of days before the first day of the month
int getDaysBeforeMonth(int year, int month) {
  if (month < minMonth || month > maxMonth) {
    throw ArgumentError(
        'Invalid Hijri month: $month. Must be between 1 and 12.');
  }
  return daysBeforeMonth[month - 1];
}

/// Get the day of year for a given Hijri date
///
/// [year] - The Hijri year
/// [month] - The Hijri month (1-12)
/// [day] - The day of month (1-30)
/// Returns Day of year (1-355)
int getDayOfYear(int year, int month, int day) {
  return getDaysBeforeMonth(year, month) + day;
}

/// Convert day of year to month and day
///
/// [year] - The Hijri year
/// [dayOfYear] - The day of year (1-355)
/// Returns record with month and day
({int month, int day}) dayOfYearToMonthDay(int year, int dayOfYear) {
  final yearLength = getYearLength(year);

  if (dayOfYear < 1 || dayOfYear > yearLength) {
    throw ArgumentError(
        'Invalid day of year: $dayOfYear. Must be between 1 and $yearLength.');
  }

  int remainingDays = dayOfYear;

  for (int month = 1; month <= 12; month++) {
    final monthLength = getMonthLength(year, month);
    if (remainingDays <= monthLength) {
      return (month: month, day: remainingDays);
    }
    remainingDays -= monthLength;
  }

  // Should never reach here
  return (month: 12, day: remainingDays);
}

/// Validate if a Hijri date is valid
///
/// [year] - The Hijri year
/// [month] - The Hijri month (1-12)
/// [day] - The day of month (1-30)
/// Returns true if the date is valid
bool isValidHijriDate(int year, int month, int day) {
  if (year < 1 || year != year.toInt()) {
    return false;
  }

  if (month < minMonth || month > maxMonth || month != month.toInt()) {
    return false;
  }

  if (day < minMonthDay || day != day.toInt()) {
    return false;
  }

  final maxDay = getMonthLength(year, month);
  return day <= maxDay;
}

/// Get the number of days from the start of year 1 to the start of the given year
///
/// [year] - The Hijri year
/// Returns Number of days
int getDaysBeforeYear(int year) {
  if (year < 1) {
    throw ArgumentError('Invalid Hijri year: $year. Must be >= 1.');
  }

  final y = year - 1;

  // Number of complete 30-year cycles
  final cycles = y ~/ lunarCycleYears;

  // Years within the current cycle
  final yearsInCycle = y % lunarCycleYears;

  // Days from complete cycles
  int days = cycles * lunarCycleDays;

  // Days from years within current cycle
  for (int i = 1; i <= yearsInCycle; i++) {
    days += leapYearsInCycle.contains(i) ? leapYearDays : commonYearDays;
  }

  return days;
}
