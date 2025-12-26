import '../types/calendar_types.dart';
import 'calendar_config.dart';
import 'hijri_date.dart';
import '../constants/calendar_constants.dart';

/// Convert a Gregorian DateTime to Hijri date components
///
/// [date] - Gregorian DateTime object
/// [calendar] - Calendar type to use (defaults to global config)
/// Returns HijriDateComponents with year, month, day
HijriDateComponents gregorianToHijri(DateTime date,
    [IslamicCalendarType? calendar]) {
  final provider = getCalendarProvider(calendar);
  return provider.gregorianToHijri(date);
}

/// Convert Hijri date components to a Gregorian DateTime
///
/// [year] - Hijri year
/// [month] - Hijri month (1-12)
/// [day] - Hijri day (1-30)
/// [calendar] - Calendar type to use (defaults to global config)
/// Returns Gregorian DateTime object
DateTime hijriToGregorian(int year, int month, int day,
    [IslamicCalendarType? calendar]) {
  final provider = getCalendarProvider(calendar);
  return provider.hijriToGregorian(year, month, day);
}

/// Convert a HijriDate to Julian Day Number
double hijriToJulianDay(HijriDate date, [IslamicCalendarType? calendar]) {
  final calendarType = calendar ?? getCalendarConfig().defaultCalendar;

  // Complete 30-year cycles
  final cycles = (date.year - 1) ~/ lunarCycleYears;
  final yearsInCycle = ((date.year - 1) % lunarCycleYears) + 1;

  // Days from complete cycles
  double days = (cycles * lunarCycleDays).toDouble();

  // Days from years within current cycle
  final provider = getCalendarProvider(calendarType);
  for (int y = 1; y < yearsInCycle; y++) {
    // For accurate calculation within the lookup range, use the provider
    days += provider.getYearLength(cycles * lunarCycleYears + y);
  }

  // Days from months in current year
  for (int m = 1; m < date.month; m++) {
    days += provider.getMonthLength(date.year, m);
  }

  // Add day of month (minus 1 because epoch is day 1)
  days += date.day - 1;

  // Add time fraction
  final timeFraction =
      (date.hour / 24.0) + (date.minute / 1440.0) + (date.second / 86400.0);

  return hijriEpochJd + days + timeFraction;
}

/// Convert a Julian Day Number to HijriDate
HijriDate julianDayToHijri(double jdn, [IslamicCalendarType? calendar]) {
  final calendarType = calendar ?? getCalendarConfig().defaultCalendar;
  final provider = getCalendarProvider(calendarType);

  // Get date components from provider
  final date = DateTime.fromMillisecondsSinceEpoch(
      ((jdn - 2440587.5) * 86400000).round(),
      isUtc: true);
  final components = provider.gregorianToHijri(date);

  // Extract time from fractional JDN
  final fractionalDay = (jdn + 0.5) - (jdn + 0.5).floor();
  final totalSeconds = (fractionalDay * 86400).round();
  final hour = totalSeconds ~/ 3600;
  final minute = (totalSeconds % 3600) ~/ 60;
  final second = totalSeconds % 60;

  return HijriDate(
    components.year,
    components.month,
    components.day,
    hour,
    minute,
    second,
  );
}

/// Get the day of week for a Hijri date
///
/// [date] - HijriDate
/// Returns weekday number (0=Saturday, 1=Sunday, ..., 6=Friday)
int hijriDayOfWeek(HijriDate date, [IslamicCalendarType? calendar]) {
  final jdn = hijriToJulianDay(date, calendar);
  // Julian Day 0 was a Monday
  // JDN % 7: 0=Mon, 1=Tue, 2=Wed, 3=Thu, 4=Fri, 5=Sat, 6=Sun
  // Our system: 0=Sat, 1=Sun, 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri
  final jdnMod = (jdn + 0.5).floor() % 7;
  // Convert: JDN 5=Sat->0, 6=Sun->1, 0=Mon->2, etc.
  return (jdnMod + 2) % 7;
}
