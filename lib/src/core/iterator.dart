import '../types/options.dart';
import '../calendar/hijri_date.dart';
import '../calendar/hijri_calendar.dart';
import '../calendar/hijri_date_math.dart';

/// Generate recurrence occurrences based on parsed options
///
/// [options] - Parsed RRULE options
/// Yields HijriDate occurrences
Iterable<HijriDate> iterate(HijriRRuleParsedOptions options) sync* {
  int count = 0;
  HijriDate current = HijriDate.from(options.dtstart);

  // Maximum iterations to prevent infinite loops
  final maxIterations = options.count != null ? options.count! * 100 : 100000;
  int iterations = 0;

  while (iterations < maxIterations) {
    iterations++;

    // Generate candidates for this period
    final candidates = _generateCandidates(current, options);

    // Apply bysetpos if specified
    final filtered = options.bysetpos != null
        ? _applyBySetPos(candidates, options.bysetpos!)
        : candidates;

    // Yield valid occurrences
    for (final candidate in filtered) {
      // Skip if before dtstart
      if (candidate.isBefore(options.dtstart)) {
        continue;
      }

      // Check if past UNTIL
      if (options.until != null && candidate.isAfter(options.until!)) {
        return;
      }

      yield candidate;
      count++;

      // Check COUNT limit
      if (options.count != null && count >= options.count!) {
        return;
      }
    }

    // Advance to next period
    current = _advancePeriod(current, options.freq, options.interval);

    // Safety check: if we've gone too far past UNTIL, stop
    if (options.until != null && current.isAfter(options.until!)) {
      // Generate one more set of candidates to catch edge cases
      final lastCandidates = _generateCandidates(current, options);
      for (final candidate in lastCandidates) {
        if (candidate.isOnOrBefore(options.until!) &&
            candidate.isOnOrAfter(options.dtstart)) {
          yield candidate;
          count++;
          if (options.count != null && count >= options.count!) {
            return;
          }
        }
      }
      return;
    }
  }
}

/// Generate candidate dates for a period
List<HijriDate> _generateCandidates(
  HijriDate periodStart,
  HijriRRuleParsedOptions options,
) {
  switch (options.freq) {
    case Frequency.yearly:
      return _generateYearlyCandidates(periodStart, options);
    case Frequency.monthly:
      return _generateMonthlyCandidates(periodStart, options);
    case Frequency.weekly:
      return _generateWeeklyCandidates(periodStart, options);
    case Frequency.daily:
      return _generateDailyCandidates(periodStart, options);
    default:
      // For higher frequencies, just return the current date
      return [periodStart];
  }
}

/// Generate candidates for YEARLY frequency
List<HijriDate> _generateYearlyCandidates(
  HijriDate periodStart,
  HijriRRuleParsedOptions options,
) {
  final year = periodStart.year;
  var candidates = <HijriDate>[];

  // If BYMONTH is specified
  if (options.bymonth != null && options.bymonth!.isNotEmpty) {
    for (final month in options.bymonth!) {
      // If BYMONTHDAY is specified
      if (options.bymonthday != null && options.bymonthday!.isNotEmpty) {
        for (final day in options.bymonthday!) {
          final date = _tryCreateDate(year, month, day, options.skip, options.calendar);
          if (date != null) candidates.add(date);
        }
      }
      // If negative BYMONTHDAY (e.g., -1 = last day)
      else if (options.bynmonthday != null && options.bynmonthday!.isNotEmpty) {
        for (final nday in options.bynmonthday!) {
          final maxDay = getMonthLength(year, month, options.calendar);
          final day = maxDay + nday + 1; // -1 becomes maxDay, -2 becomes maxDay-1
          if (day >= 1) {
            candidates.add(HijriDate(year, month, day));
          }
        }
      }
      // If BYDAY with nth weekday (e.g., 1FR = first Friday)
      else if (options.bynweekday != null && options.bynweekday!.isNotEmpty) {
        for (final wd in options.bynweekday!) {
          if (wd.n != null) {
            final date = nthWeekdayOfMonth(year, month, wd.weekday, wd.n!);
            if (date != null) candidates.add(date);
          }
        }
      }
      // If simple BYDAY (e.g., MO, TU)
      else if (options.byweekday != null && options.byweekday!.isNotEmpty) {
        // Get all matching weekdays in the month
        final monthLength = getMonthLength(year, month, options.calendar);
        for (int d = 1; d <= monthLength; d++) {
          final date = HijriDate(year, month, d);
          final dow = dayOfWeek(date);
          if (options.byweekday!.any((wd) => wd.weekday == dow)) {
            candidates.add(date);
          }
        }
      }
      // Default: same day as dtstart
      else {
        final day = periodStart.day.clamp(1, getMonthLength(year, month, options.calendar));
        candidates.add(HijriDate(year, month, day));
      }
    }
  }
  // If only BYMONTHDAY (without BYMONTH)
  else if (options.bymonthday != null && options.bymonthday!.isNotEmpty) {
    // Apply to dtstart month only
    final month = periodStart.month;
    for (final day in options.bymonthday!) {
      final date = _tryCreateDate(year, month, day, options.skip, options.calendar);
      if (date != null) candidates.add(date);
    }
  }
  // If BYYEARDAY
  else if (options.byyearday != null && options.byyearday!.isNotEmpty) {
    final yearLength = getYearLength(year, options.calendar);
    for (final yday in options.byyearday!) {
      final actualDay = yday > 0 ? yday : yearLength + yday + 1;
      if (actualDay >= 1 && actualDay <= yearLength) {
        final date = _dayOfYearToDate(year, actualDay, options.calendar);
        if (date != null) candidates.add(date);
      }
    }
  }
  // Default: same day as dtstart
  else {
    final day = periodStart.day.clamp(1, getMonthLength(year, periodStart.month, options.calendar));
    candidates.add(HijriDate(year, periodStart.month, day));
  }

  // Apply BYDAY filter if specified without nth
  if (options.byweekday != null && options.byweekday!.isNotEmpty && options.bymonth == null) {
    candidates = candidates.where((c) {
      final dow = dayOfWeek(c);
      return options.byweekday!.any((wd) => wd.weekday == dow);
    }).toList();
  }

  // Sort and deduplicate
  return _sortAndDedupe(candidates);
}

/// Generate candidates for MONTHLY frequency
List<HijriDate> _generateMonthlyCandidates(
  HijriDate periodStart,
  HijriRRuleParsedOptions options,
) {
  final year = periodStart.year;
  final month = periodStart.month;
  final candidates = <HijriDate>[];

  // If BYMONTHDAY
  if (options.bymonthday != null && options.bymonthday!.isNotEmpty) {
    for (final day in options.bymonthday!) {
      final date = _tryCreateDate(year, month, day, options.skip, options.calendar);
      if (date != null) candidates.add(date);
    }
  }
  // If negative BYMONTHDAY
  else if (options.bynmonthday != null && options.bynmonthday!.isNotEmpty) {
    final maxDay = getMonthLength(year, month, options.calendar);
    for (final nday in options.bynmonthday!) {
      final day = maxDay + nday + 1;
      if (day >= 1) {
        candidates.add(HijriDate(year, month, day));
      }
    }
  }
  // If BYDAY with nth
  else if (options.bynweekday != null && options.bynweekday!.isNotEmpty) {
    for (final wd in options.bynweekday!) {
      if (wd.n != null) {
        final date = nthWeekdayOfMonth(year, month, wd.weekday, wd.n!);
        if (date != null) candidates.add(date);
      }
    }
  }
  // If simple BYDAY
  else if (options.byweekday != null && options.byweekday!.isNotEmpty) {
    final monthLength = getMonthLength(year, month, options.calendar);
    for (int d = 1; d <= monthLength; d++) {
      final date = HijriDate(year, month, d);
      final dow = dayOfWeek(date);
      if (options.byweekday!.any((wd) => wd.weekday == dow)) {
        candidates.add(date);
      }
    }
  }
  // Default: same day as dtstart
  else {
    final day = periodStart.day.clamp(1, getMonthLength(year, month, options.calendar));
    candidates.add(HijriDate(year, month, day));
  }

  return _sortAndDedupe(candidates);
}

/// Generate candidates for WEEKLY frequency
List<HijriDate> _generateWeeklyCandidates(
  HijriDate periodStart,
  HijriRRuleParsedOptions options,
) {
  final candidates = <HijriDate>[];

  // If BYDAY is specified
  if (options.byweekday != null && options.byweekday!.isNotEmpty) {
    // Find all matching days in this week
    for (int i = 0; i < 7; i++) {
      final date = addDays(periodStart, i);
      final dow = dayOfWeek(date);
      if (options.byweekday!.any((wd) => wd.weekday == dow)) {
        candidates.add(date);
      }
    }
  } else {
    // Default: same weekday as dtstart
    candidates.add(periodStart);
  }

  return _sortAndDedupe(candidates);
}

/// Generate candidates for DAILY frequency
List<HijriDate> _generateDailyCandidates(
  HijriDate periodStart,
  HijriRRuleParsedOptions options,
) {
  // For daily, the candidate is just the current day
  final candidate = periodStart;

  // Apply BYMONTH filter
  if (options.bymonth != null && options.bymonth!.isNotEmpty) {
    if (!options.bymonth!.contains(candidate.month)) {
      return [];
    }
  }

  // Apply BYMONTHDAY filter
  if (options.bymonthday != null && options.bymonthday!.isNotEmpty) {
    if (!options.bymonthday!.contains(candidate.day)) {
      return [];
    }
  }

  // Apply BYDAY filter
  if (options.byweekday != null && options.byweekday!.isNotEmpty) {
    final dow = dayOfWeek(candidate);
    if (!options.byweekday!.any((wd) => wd.weekday == dow)) {
      return [];
    }
  }

  return [candidate];
}

/// Advance to the next period based on frequency
HijriDate _advancePeriod(
  HijriDate current,
  Frequency freq,
  int interval,
) {
  switch (freq) {
    case Frequency.yearly:
      return addYears(current, interval, clampDay: true) ?? current;
    case Frequency.monthly:
      return addMonths(current, interval, clampDay: true) ?? current;
    case Frequency.weekly:
      return addDays(current, interval * 7);
    case Frequency.daily:
      return addDays(current, interval);
    default:
      return addDays(current, 1);
  }
}

/// Apply BYSETPOS filter to candidates
List<HijriDate> _applyBySetPos(List<HijriDate> candidates, List<int> positions) {
  final result = <HijriDate>[];
  final len = candidates.length;

  for (final pos in positions) {
    int index;
    if (pos > 0) {
      index = pos - 1; // 1-based to 0-based
    } else {
      index = len + pos; // Negative index from end
    }

    if (index >= 0 && index < len) {
      result.add(candidates[index]);
    }
  }

  return _sortAndDedupe(result);
}

/// Try to create a HijriDate, handling invalid day numbers
/// Returns null if day doesn't exist and strategy is OMIT
HijriDate? _tryCreateDate(
  int year,
  int month,
  int day,
  Skip strategy,
  IslamicCalendarType calendar,
) {
  final maxDay = getMonthLength(year, month, calendar);

  if (day < 1) {
    return null;
  }

  if (day > maxDay) {
    switch (strategy) {
      case Skip.omit:
        return null;
      case Skip.backward:
        // Move backward to last valid day of the month
        return HijriDate(year, month, maxDay);
      case Skip.forward:
        // Move forward to 1st of next month
        if (month == 12) {
          return HijriDate(year + 1, 1, 1);
        }
        return HijriDate(year, month + 1, 1);
    }
  }

  try {
    return HijriDate(year, month, day);
  } catch (_) {
    return null;
  }
}

/// Convert day of year to HijriDate
HijriDate? _dayOfYearToDate(int year, int dayOfYear, IslamicCalendarType calendar) {
  try {
    int remainingDays = dayOfYear;
    for (int month = 1; month <= 12; month++) {
      final monthLength = getMonthLength(year, month, calendar);
      if (remainingDays <= monthLength) {
        return HijriDate(year, month, remainingDays);
      }
      remainingDays -= monthLength;
    }
    return null;
  } catch (_) {
    return null;
  }
}

/// Sort dates and remove duplicates
List<HijriDate> _sortAndDedupe(List<HijriDate> dates) {
  if (dates.isEmpty) return dates;

  // Sort by date
  dates.sort((a, b) => a.compare(b));

  // Remove duplicates
  final result = <HijriDate>[dates.first];
  for (int i = 1; i < dates.length; i++) {
    if (!result.last.equals(dates[i])) {
      result.add(dates[i]);
    }
  }

  return result;
}

/// Get all occurrences up to a limit
List<HijriDate> getAll(HijriRRuleParsedOptions options, {int limit = 1000}) {
  final result = <HijriDate>[];
  int count = 0;

  for (final date in iterate(options)) {
    result.add(date);
    count++;
    if (count >= limit) break;
  }

  return result;
}

/// Get occurrences between two dates
List<HijriDate> getBetween(
  HijriRRuleParsedOptions options,
  HijriDate after,
  HijriDate before, {
  bool inclusive = false,
}) {
  final result = <HijriDate>[];

  for (final date in iterate(options)) {
    // Stop if past 'before' date
    if (inclusive ? date.isAfter(before) : date.isOnOrAfter(before)) {
      if (!date.equals(before)) break;
    }

    // Include if after 'after' date
    final isAfterStart = inclusive ? date.isOnOrAfter(after) : date.isAfter(after);

    if (isAfterStart) {
      final isBeforeEnd = inclusive ? date.isOnOrBefore(before) : date.isBefore(before);

      if (isBeforeEnd) {
        result.add(date);
      }
    }
  }

  return result;
}

/// Get first occurrence after a date
HijriDate? getAfter(HijriRRuleParsedOptions options, HijriDate dt, {bool inclusive = false}) {
  for (final date in iterate(options)) {
    if (inclusive ? date.isOnOrAfter(dt) : date.isAfter(dt)) {
      return date;
    }
  }
  return null;
}

/// Get last occurrence before a date
HijriDate? getBefore(HijriRRuleParsedOptions options, HijriDate dt, {bool inclusive = false}) {
  HijriDate? last;

  for (final date in iterate(options)) {
    if (inclusive ? date.isOnOrBefore(dt) : date.isBefore(dt)) {
      last = date;
    } else {
      break;
    }
  }

  return last;
}
