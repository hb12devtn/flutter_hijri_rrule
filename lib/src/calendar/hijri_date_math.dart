import '../constants/weekday.dart';
import 'hijri_date.dart';
import 'hijri_calendar.dart';
import 'hijri_converter.dart';

/// Add days to a Hijri date
///
/// [date] - Starting HijriDate
/// [days] - Number of days to add (can be negative)
/// Returns New HijriDate
HijriDate addDays(HijriDate date, int days) {
  if (days == 0) return date.clone();

  final jdn = hijriToJulianDay(date);
  final newJdn = jdn + days;
  final result = julianDayToHijri(newJdn);

  // Preserve time from original date
  return HijriDate(
    result.year,
    result.month,
    result.day,
    date.hour,
    date.minute,
    date.second,
  );
}

/// Add months to a Hijri date
///
/// [date] - Starting HijriDate
/// [months] - Number of months to add (can be negative)
/// [clampDay] - If true, clamp day to max days in target month (default: true)
/// Returns New HijriDate, or null if clampDay is false and day doesn't exist
HijriDate? addMonths(HijriDate date, int months, {bool clampDay = true}) {
  if (months == 0) return date.clone();

  // Calculate new year and month
  final totalMonths = (date.year - 1) * 12 + (date.month - 1) + months;
  int newYear = totalMonths ~/ 12 + 1;
  int newMonth = (totalMonths % 12) + 1;

  // Handle negative months
  if (newMonth <= 0) {
    newMonth += 12;
    newYear -= 1;
  }

  if (newYear < 1) {
    throw ArgumentError('Resulting date is before Hijri epoch');
  }

  // Check if day is valid in target month
  final maxDay = getMonthLength(newYear, newMonth);
  int newDay = date.day;

  if (date.day > maxDay) {
    if (clampDay) {
      newDay = maxDay;
    } else {
      return null; // Day doesn't exist in target month
    }
  }

  return HijriDate(
    newYear,
    newMonth,
    newDay,
    date.hour,
    date.minute,
    date.second,
  );
}

/// Add years to a Hijri date
///
/// [date] - Starting HijriDate
/// [years] - Number of years to add (can be negative)
/// [clampDay] - If true, clamp day to max days in target month (default: true)
/// Returns New HijriDate, or null if clampDay is false and day doesn't exist
HijriDate? addYears(HijriDate date, int years, {bool clampDay = true}) {
  if (years == 0) return date.clone();

  final newYear = date.year + years;

  if (newYear < 1) {
    throw ArgumentError('Resulting date is before Hijri epoch');
  }

  // Check if day is valid in target month of new year
  final maxDay = getMonthLength(newYear, date.month);
  int newDay = date.day;

  if (date.day > maxDay) {
    if (clampDay) {
      newDay = maxDay;
    } else {
      return null; // Day doesn't exist (e.g., 30 Dhu al-Hijjah in non-leap year)
    }
  }

  return HijriDate(
    newYear,
    date.month,
    newDay,
    date.hour,
    date.minute,
    date.second,
  );
}

/// Calculate the difference in days between two Hijri dates
///
/// [date1] - First date
/// [date2] - Second date
/// Returns Number of days (date1 - date2), positive if date1 > date2
int diffDays(HijriDate date1, HijriDate date2) {
  final jdn1 = hijriToJulianDay(date1);
  final jdn2 = hijriToJulianDay(date2);
  return (jdn1 - jdn2).round();
}

/// Calculate the difference in months between two Hijri dates
/// Only counts complete months
///
/// [date1] - First date
/// [date2] - Second date
/// Returns Number of months (date1 - date2)
int diffMonths(HijriDate date1, HijriDate date2) {
  final months1 = (date1.year - 1) * 12 + (date1.month - 1);
  final months2 = (date2.year - 1) * 12 + (date2.month - 1);
  return months1 - months2;
}

/// Calculate the difference in years between two Hijri dates
/// Only counts complete years
///
/// [date1] - First date
/// [date2] - Second date
/// Returns Number of years (date1 - date2)
int diffYears(HijriDate date1, HijriDate date2) {
  return date1.year - date2.year;
}

/// Get the day of week for a Hijri date
///
/// [date] - HijriDate
/// Returns WeekdayNum (0=Saturday, 1=Sunday, ..., 6=Friday)
WeekdayNum dayOfWeek(HijriDate date) {
  return WeekdayNum.fromValue(hijriDayOfWeek(date));
}

/// Get the first day of the month
///
/// [date] - HijriDate
/// Returns New HijriDate on the first day of the month
HijriDate startOfMonth(HijriDate date) {
  return HijriDate(
    date.year,
    date.month,
    1,
    date.hour,
    date.minute,
    date.second,
  );
}

/// Get the last day of the month
///
/// [date] - HijriDate
/// Returns New HijriDate on the last day of the month
HijriDate endOfMonth(HijriDate date) {
  final lastDay = getMonthLength(date.year, date.month);
  return HijriDate(
    date.year,
    date.month,
    lastDay,
    date.hour,
    date.minute,
    date.second,
  );
}

/// Get the first day of the year
///
/// [date] - HijriDate
/// Returns New HijriDate on 1 Muharram of the same year
HijriDate startOfYear(HijriDate date) {
  return HijriDate(date.year, 1, 1, date.hour, date.minute, date.second);
}

/// Get the last day of the year
///
/// [date] - HijriDate
/// Returns New HijriDate on 29/30 Dhu al-Hijjah of the same year
HijriDate endOfYear(HijriDate date) {
  final lastDay = getMonthLength(date.year, 12);
  return HijriDate(date.year, 12, lastDay, date.hour, date.minute, date.second);
}

/// Get the start of the week containing the given date
///
/// [date] - HijriDate
/// [weekStart] - The day that starts the week (default: Sunday)
/// Returns New HijriDate on the first day of the week
HijriDate startOfWeek(HijriDate date, [WeekdayNum weekStart = WeekdayNum.su]) {
  final currentDay = dayOfWeek(date);
  final daysToSubtract = (currentDay.value - weekStart.value + 7) % 7;
  return addDays(date, -daysToSubtract);
}

/// Get the end of the week containing the given date
///
/// [date] - HijriDate
/// [weekStart] - The day that starts the week (default: Sunday)
/// Returns New HijriDate on the last day of the week
HijriDate endOfWeek(HijriDate date, [WeekdayNum weekStart = WeekdayNum.su]) {
  final weekEnd = (weekStart.value + 6) % 7;
  final currentDay = dayOfWeek(date);
  final daysToAdd = (weekEnd - currentDay.value + 7) % 7;
  return addDays(date, daysToAdd);
}

/// Get the nth weekday of a month
///
/// [year] - Hijri year
/// [month] - Hijri month (1-12)
/// [weekday] - Day of week (0-6)
/// [n] - Which occurrence (1=first, 2=second, -1=last, -2=second last)
/// Returns HijriDate or null if not found
HijriDate? nthWeekdayOfMonth(
  int year,
  int month,
  WeekdayNum weekday,
  int n,
) {
  if (n == 0) return null;

  final monthLength = getMonthLength(year, month);

  if (n > 0) {
    // Find nth occurrence from the start
    int count = 0;
    for (int day = 1; day <= monthLength; day++) {
      final date = HijriDate(year, month, day);
      if (dayOfWeek(date) == weekday) {
        count++;
        if (count == n) {
          return date;
        }
      }
    }
  } else {
    // Find nth occurrence from the end
    int count = 0;
    for (int day = monthLength; day >= 1; day--) {
      final date = HijriDate(year, month, day);
      if (dayOfWeek(date) == weekday) {
        count--;
        if (count == n) {
          return date;
        }
      }
    }
  }

  return null; // Not enough occurrences
}

/// Get the week number within the year
///
/// [date] - HijriDate
/// [weekStart] - The day that starts the week (default: Sunday)
/// Returns Week number (1-52 or 53)
int weekOfYear(HijriDate date, [WeekdayNum weekStart = WeekdayNum.su]) {
  final firstDayOfYear = HijriDate(date.year, 1, 1);
  final firstDayWeekday = dayOfWeek(firstDayOfYear);

  // Days until the first full week starts
  final daysUntilFirstFullWeek =
      (weekStart.value - firstDayWeekday.value + 7) % 7;

  final dayOfYear = date.getDayOfYear();

  if (dayOfYear <= daysUntilFirstFullWeek) {
    // Day is in "week 0" (partial first week) - count as week 1
    return 1;
  }

  // Subtract the partial first week and calculate week number
  final daysInFullWeeks = dayOfYear - daysUntilFirstFullWeek;
  return (daysInFullWeeks / 7).ceil() + (daysUntilFirstFullWeek > 0 ? 1 : 0);
}

/// Check if two dates are in the same year
bool isSameYear(HijriDate date1, HijriDate date2) {
  return date1.year == date2.year;
}

/// Check if two dates are in the same month
bool isSameMonth(HijriDate date1, HijriDate date2) {
  return date1.year == date2.year && date1.month == date2.month;
}

/// Check if two dates are in the same week
bool isSameWeek(HijriDate date1, HijriDate date2,
    [WeekdayNum weekStart = WeekdayNum.su]) {
  final start1 = startOfWeek(date1, weekStart);
  final start2 = startOfWeek(date2, weekStart);
  return start1.equals(start2);
}

/// Check if two dates are the same day
bool isSameDay(HijriDate date1, HijriDate date2) {
  return date1.equals(date2);
}
