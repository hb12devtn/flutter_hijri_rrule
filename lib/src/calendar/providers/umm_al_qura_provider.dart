/// Umm al-Qura Islamic Calendar Provider
///
/// Uses a lookup table for the Saudi Arabian official calendar.
/// The Umm al-Qura calendar is observation-based and cannot be
/// calculated algorithmically with full accuracy.
///
/// This implementation covers Hijri years 1356-1500 AH (1937-2076 CE).
library;

import '../../constants/calendar_constants.dart';
import '../../types/calendar_types.dart';
import 'tabular_provider.dart';

/// Umm al-Qura month length lookup table
/// Key: Hijri year (1356-1500)
/// Value: List of 12 month lengths (29 or 30)
///
/// Data generated with Intl.DateTimeFormat('en-u-ca-islamic-umalqura')
/// For years outside this range, falls back to tabular calendar.
const Map<int, List<int>> _ummAlQuraMonthLengths = {
  1356: [29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 30, 30],
  1357: [29, 29, 30, 29, 30, 29, 29, 30, 29, 30, 30, 30],
  1358: [29, 30, 29, 30, 29, 30, 29, 29, 30, 29, 30, 30],
  1359: [29, 30, 30, 29, 30, 29, 30, 29, 29, 29, 30, 30],
  1360: [29, 30, 30, 30, 29, 30, 29, 30, 29, 29, 30, 29],
  1361: [30, 29, 30, 30, 29, 30, 30, 29, 29, 30, 29, 30],
  1362: [29, 30, 29, 30, 29, 30, 30, 29, 30, 29, 30, 29],
  1363: [30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 30],
  1364: [29, 30, 29, 30, 29, 29, 30, 29, 30, 29, 30, 30],
  1365: [30, 30, 29, 29, 30, 29, 29, 30, 29, 30, 29, 30],
  1366: [30, 30, 29, 30, 29, 30, 29, 29, 30, 29, 30, 29],
  1367: [30, 30, 29, 30, 30, 29, 30, 29, 29, 30, 29, 30],
  1368: [29, 30, 29, 30, 30, 30, 29, 29, 30, 29, 30, 29],
  1369: [30, 29, 30, 29, 30, 30, 29, 30, 29, 30, 30, 29],
  1370: [30, 29, 29, 30, 29, 30, 29, 30, 29, 30, 30, 30],
  1371: [29, 30, 29, 29, 30, 29, 30, 29, 30, 29, 30, 30],
  1372: [30, 29, 29, 30, 29, 30, 29, 29, 30, 29, 30, 30],
  1373: [30, 29, 30, 29, 30, 29, 30, 29, 29, 30, 29, 30],
  1374: [30, 29, 30, 30, 29, 30, 29, 30, 29, 29, 30, 29],
  1375: [30, 29, 30, 30, 29, 30, 30, 29, 30, 29, 30, 29],
  1376: [29, 30, 29, 30, 29, 30, 30, 30, 29, 30, 29, 30],
  1377: [29, 29, 30, 29, 29, 30, 30, 30, 29, 30, 30, 29],
  1378: [30, 29, 29, 29, 30, 29, 30, 30, 29, 30, 30, 30],
  1379: [29, 30, 29, 29, 29, 30, 29, 30, 30, 29, 30, 30],
  1380: [29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30],
  1381: [29, 30, 29, 30, 30, 29, 30, 29, 30, 29, 29, 30],
  1382: [29, 30, 29, 30, 30, 29, 30, 30, 29, 30, 29, 29],
  1383: [30, 29, 29, 30, 30, 30, 29, 30, 30, 29, 30, 29],
  1384: [29, 30, 29, 29, 30, 30, 29, 30, 30, 30, 29, 30],
  1385: [29, 29, 30, 29, 29, 30, 30, 29, 30, 30, 30, 29],
  1386: [30, 29, 29, 30, 29, 29, 30, 30, 29, 30, 30, 29],
  1387: [30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29],
  1388: [30, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 29],
  1389: [30, 30, 29, 30, 30, 29, 30, 30, 29, 29, 30, 29],
  1390: [29, 30, 29, 30, 30, 30, 29, 30, 29, 30, 29, 30],
  1391: [29, 29, 30, 29, 30, 30, 29, 30, 30, 29, 30, 29],
  1392: [30, 29, 29, 30, 29, 30, 29, 30, 30, 29, 30, 30],
  1393: [29, 30, 29, 29, 30, 29, 30, 29, 30, 29, 30, 30],
  1394: [30, 29, 30, 29, 29, 30, 29, 30, 29, 30, 29, 30],
  1395: [30, 29, 30, 30, 29, 30, 29, 29, 30, 29, 29, 30],
  1396: [30, 29, 30, 30, 29, 30, 30, 29, 29, 30, 29, 29],
  1397: [30, 29, 30, 30, 29, 30, 30, 30, 29, 29, 29, 30],
  1398: [29, 30, 29, 30, 30, 29, 30, 30, 29, 30, 29, 29],
  1399: [30, 29, 30, 29, 30, 29, 30, 30, 29, 30, 29, 30],
  1400: [30, 29, 30, 29, 29, 30, 29, 30, 29, 30, 29, 30],
  1401: [30, 30, 29, 30, 29, 29, 30, 29, 29, 30, 29, 30],
  1402: [30, 30, 30, 29, 30, 29, 29, 30, 29, 29, 30, 29],
  1403: [30, 30, 30, 29, 30, 30, 29, 29, 30, 29, 29, 30],
  1404: [29, 30, 30, 29, 30, 30, 29, 30, 29, 30, 29, 29],
  1405: [30, 29, 30, 29, 30, 30, 30, 29, 30, 29, 29, 30],
  1406: [30, 29, 29, 30, 29, 30, 30, 29, 30, 29, 30, 30],
  1407: [29, 30, 29, 29, 30, 29, 30, 29, 30, 29, 30, 30],
  1408: [30, 29, 30, 29, 30, 29, 29, 30, 29, 29, 30, 30],
  1409: [30, 30, 29, 30, 29, 30, 29, 29, 30, 29, 29, 30],
  1410: [30, 30, 29, 30, 30, 29, 30, 29, 29, 30, 29, 29],
  1411: [30, 30, 29, 30, 30, 29, 30, 30, 29, 29, 30, 29],
  1412: [30, 29, 30, 29, 30, 29, 30, 30, 30, 29, 29, 30],
  1413: [29, 30, 29, 29, 30, 29, 30, 30, 30, 29, 30, 29],
  1414: [30, 29, 30, 29, 29, 30, 29, 30, 30, 29, 30, 30],
  1415: [29, 30, 29, 30, 29, 29, 30, 29, 30, 29, 30, 30],
  1416: [30, 29, 30, 29, 30, 29, 29, 30, 29, 30, 29, 30],
  1417: [30, 29, 30, 30, 29, 29, 30, 29, 30, 29, 30, 29],
  1418: [30, 29, 30, 30, 29, 30, 29, 30, 29, 30, 29, 30],
  1419: [29, 30, 29, 30, 29, 30, 29, 30, 30, 30, 29, 29],
  1420: [29, 30, 29, 29, 30, 29, 30, 30, 30, 30, 29, 30],
  1421: [29, 29, 30, 29, 29, 29, 30, 30, 30, 30, 29, 30],
  1422: [30, 29, 29, 30, 29, 29, 29, 30, 30, 30, 29, 30],
  1423: [30, 29, 30, 29, 30, 29, 29, 30, 29, 30, 29, 30],
  1424: [30, 29, 30, 30, 29, 30, 29, 29, 30, 29, 30, 29],
  1425: [30, 29, 30, 30, 29, 30, 29, 30, 30, 29, 30, 29],
  1426: [29, 30, 29, 30, 29, 30, 30, 29, 30, 30, 29, 30],
  1427: [29, 29, 30, 29, 30, 29, 30, 30, 29, 30, 30, 29],
  1428: [30, 29, 29, 30, 29, 29, 30, 30, 30, 29, 30, 30],
  1429: [29, 30, 29, 29, 30, 29, 29, 30, 30, 29, 30, 30],
  1430: [29, 30, 30, 29, 29, 30, 29, 30, 29, 30, 29, 30],
  1431: [29, 30, 30, 29, 30, 29, 30, 29, 30, 29, 29, 30],
  1432: [29, 30, 30, 30, 29, 30, 29, 30, 29, 30, 29, 29],
  1433: [30, 29, 30, 30, 29, 30, 30, 29, 30, 29, 30, 29],
  1434: [29, 30, 29, 30, 29, 30, 30, 29, 30, 30, 29, 29],
  1435: [30, 29, 30, 29, 30, 29, 30, 29, 30, 30, 29, 30],
  1436: [29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30],
  1437: [30, 29, 30, 30, 29, 29, 30, 29, 30, 29, 29, 30],
  1438: [30, 29, 30, 30, 30, 29, 29, 30, 29, 29, 30, 29],
  1439: [30, 29, 30, 30, 30, 29, 30, 29, 30, 29, 29, 30],
  1440: [29, 30, 29, 30, 30, 30, 29, 30, 29, 30, 29, 29],
  1441: [30, 29, 30, 29, 30, 30, 29, 30, 30, 29, 30, 29],
  1442: [29, 30, 29, 30, 29, 30, 29, 30, 30, 29, 30, 29],
  1443: [30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 30],
  1444: [29, 30, 29, 30, 30, 29, 29, 30, 29, 30, 29, 30],
  1445: [29, 30, 30, 30, 29, 30, 29, 29, 30, 29, 29, 30],
  1446: [29, 30, 30, 30, 29, 30, 30, 29, 29, 30, 29, 29],
  1447: [30, 29, 30, 30, 30, 29, 30, 29, 30, 29, 30, 29],
  1448: [29, 30, 29, 30, 30, 29, 30, 30, 29, 30, 29, 30],
  1449: [29, 29, 30, 29, 30, 29, 30, 30, 29, 30, 30, 29],
  1450: [30, 29, 30, 29, 29, 30, 29, 30, 29, 30, 30, 29],
  1451: [30, 30, 30, 29, 29, 30, 29, 29, 30, 30, 29, 30],
  1452: [30, 29, 30, 30, 29, 29, 30, 29, 29, 30, 29, 30],
  1453: [30, 29, 30, 30, 29, 30, 29, 30, 29, 29, 30, 29],
  1454: [30, 29, 30, 30, 29, 30, 30, 29, 30, 29, 30, 29],
  1455: [29, 30, 29, 30, 30, 29, 30, 29, 30, 30, 29, 30],
  1456: [29, 29, 30, 29, 30, 29, 30, 29, 30, 30, 30, 29],
  1457: [30, 29, 29, 30, 29, 29, 30, 29, 30, 30, 30, 30],
  1458: [29, 30, 29, 29, 30, 29, 29, 30, 29, 30, 30, 30],
  1459: [29, 30, 30, 29, 29, 30, 29, 29, 30, 29, 30, 30],
  1460: [29, 30, 30, 29, 30, 29, 30, 29, 29, 30, 29, 30],
  1461: [29, 30, 30, 29, 30, 29, 30, 29, 30, 30, 29, 29],
  1462: [30, 29, 30, 29, 30, 30, 29, 30, 29, 30, 30, 29],
  1463: [29, 30, 29, 30, 29, 30, 29, 30, 30, 30, 29, 30],
  1464: [29, 30, 29, 29, 30, 29, 29, 30, 30, 30, 29, 30],
  1465: [30, 29, 30, 29, 29, 30, 29, 29, 30, 30, 29, 30],
  1466: [30, 30, 29, 30, 29, 29, 29, 30, 29, 30, 30, 29],
  1467: [30, 30, 29, 30, 30, 29, 29, 30, 29, 30, 29, 30],
  1468: [29, 30, 29, 30, 30, 29, 30, 29, 30, 29, 30, 29],
  1469: [29, 30, 29, 30, 30, 29, 30, 30, 29, 30, 29, 30],
  1470: [29, 29, 30, 29, 30, 30, 29, 30, 30, 29, 30, 29],
  1471: [30, 29, 29, 30, 29, 30, 29, 30, 30, 29, 30, 30],
  1472: [29, 30, 29, 29, 30, 29, 30, 29, 30, 30, 29, 30],
  1473: [29, 30, 29, 30, 30, 29, 29, 30, 29, 30, 29, 30],
  1474: [29, 30, 30, 29, 30, 30, 29, 29, 30, 29, 30, 29],
  1475: [29, 30, 30, 29, 30, 30, 30, 29, 29, 30, 29, 29],
  1476: [30, 29, 30, 29, 30, 30, 30, 29, 30, 29, 30, 29],
  1477: [29, 30, 29, 29, 30, 30, 30, 30, 29, 30, 29, 30],
  1478: [29, 29, 30, 29, 30, 29, 30, 30, 29, 30, 30, 29],
  1479: [30, 29, 29, 30, 29, 30, 29, 30, 29, 30, 30, 29],
  1480: [30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29],
  1481: [30, 29, 30, 30, 29, 30, 29, 30, 29, 30, 29, 29],
  1482: [30, 29, 30, 30, 30, 30, 29, 30, 29, 29, 30, 29],
  1483: [29, 30, 29, 30, 30, 30, 29, 30, 30, 29, 29, 30],
  1484: [29, 29, 30, 29, 30, 30, 30, 29, 30, 29, 30, 29],
  1485: [30, 29, 29, 30, 29, 30, 30, 29, 30, 30, 29, 30],
  1486: [29, 30, 29, 29, 30, 29, 30, 29, 30, 30, 29, 30],
  1487: [30, 29, 30, 29, 30, 29, 29, 30, 29, 30, 29, 30],
  1488: [30, 29, 30, 30, 29, 30, 29, 29, 30, 29, 30, 29],
  1489: [30, 29, 30, 30, 30, 29, 30, 29, 29, 30, 29, 30],
  1490: [29, 30, 29, 30, 30, 29, 30, 30, 29, 29, 30, 29],
  1491: [30, 29, 29, 30, 30, 29, 30, 30, 29, 30, 29, 30],
  1492: [29, 30, 29, 29, 30, 30, 29, 30, 29, 30, 30, 29],
  1493: [30, 29, 30, 29, 30, 29, 29, 30, 29, 30, 30, 30],
  1494: [29, 30, 29, 30, 29, 30, 29, 29, 29, 30, 30, 30],
  1495: [29, 30, 30, 29, 30, 29, 29, 30, 29, 29, 30, 30],
  1496: [29, 30, 30, 30, 29, 30, 29, 29, 30, 29, 29, 30],
  1497: [30, 29, 30, 30, 29, 30, 29, 30, 29, 30, 29, 30],
  1498: [29, 30, 29, 30, 29, 30, 30, 29, 30, 29, 30, 29],
  1499: [30, 29, 30, 29, 29, 30, 30, 29, 30, 29, 30, 30],
  1500: [29, 30, 29, 30, 29, 29, 30, 29, 30, 29, 30, 30]
};

/// Minimum supported year for Umm al-Qura lookup
const int _minYear = 1356;

/// Maximum supported year for Umm al-Qura lookup
const int _maxYear = 1500;

/// Umm al-Qura Islamic Calendar Provider
///
/// Implements the CalendarProvider interface using a lookup table
/// for accurate Umm al-Qura calendar calculations.
class UmmAlQuraCalendarProvider implements CalendarProvider {
  @override
  final IslamicCalendarType type = IslamicCalendarType.islamicUmalqura;

  /// Fallback provider for years outside lookup table range
  final TabularCalendarProvider _fallback = TabularCalendarProvider();

  /// Cache for year start Julian Day Numbers
  final Map<int, double> _yearStartJdCache = {};

  /// Check if year is within lookup table range
  bool _isInRange(int year) => year >= _minYear && year <= _maxYear;

  /// Check if a Hijri year is a leap year (355 days)
  @override
  bool isLeapYear(int year) {
    return getYearLength(year) == 355;
  }

  /// Get the number of days in a Hijri month
  @override
  int getMonthLength(int year, int month) {
    if (month < minMonth || month > maxMonth) {
      throw ArgumentError(
          'Invalid Hijri month: $month. Must be between 1 and 12.');
    }

    if (_isInRange(year)) {
      return _ummAlQuraMonthLengths[year]![month - 1];
    }

    return _fallback.getMonthLength(year, month);
  }

  /// Get the total number of days in a Hijri year
  @override
  int getYearLength(int year) {
    if (_isInRange(year)) {
      return _ummAlQuraMonthLengths[year]!.reduce((a, b) => a + b);
    }
    return _fallback.getYearLength(year);
  }

  /// Get the Julian Day Number for the start of a Hijri year
  double _getYearStartJd(int year) {
    if (_yearStartJdCache.containsKey(year)) {
      return _yearStartJdCache[year]!;
    }

    double jd;
    if (year <= _minYear) {
      // Calculate from epoch for years before lookup range
      jd = hijriEpochJd;
      for (int y = 1; y < year; y++) {
        jd += _fallback.getYearLength(y);
      }
    } else if (year > _maxYear) {
      // Calculate forward from max year
      jd = _getYearStartJd(_maxYear);
      for (int y = _maxYear; y < year; y++) {
        jd += _fallback.getYearLength(y);
      }
    } else {
      // Within range - calculate from minimum year
      jd = _getYearStartJd(_minYear);
      for (int y = _minYear; y < year; y++) {
        jd += getYearLength(y);
      }
    }

    _yearStartJdCache[year] = jd;
    return jd;
  }

  /// Convert a Gregorian Date to Hijri date components
  @override
  HijriDateComponents gregorianToHijri(DateTime date) {
    final jd = _gregorianToJulianDay(date);

    // Binary search for year
    int lo = _minYear;
    int hi = _maxYear;

    // Adjust search range based on JD
    final minYearJd = _getYearStartJd(_minYear);
    if (jd < minYearJd) {
      return _fallback.gregorianToHijri(date);
    }

    final maxYearEndJd = _getYearStartJd(_maxYear) + getYearLength(_maxYear);
    if (jd >= maxYearEndJd) {
      return _fallback.gregorianToHijri(date);
    }

    while (lo < hi) {
      final mid = (lo + hi + 1) ~/ 2;
      if (_getYearStartJd(mid) <= jd) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }

    final year = lo;
    double remaining = jd - _getYearStartJd(year);

    // Find month
    int month = 1;
    for (int m = 1; m <= 12; m++) {
      final monthLength = getMonthLength(year, m);
      if (remaining < monthLength) {
        month = m;
        break;
      }
      remaining -= monthLength;
    }

    final day = remaining.floor() + 1;

    return HijriDateComponents(year: year, month: month, day: day);
  }

  /// Convert Hijri date components to a Gregorian Date
  @override
  DateTime hijriToGregorian(int year, int month, int day) {
    if (!_isInRange(year)) {
      return _fallback.hijriToGregorian(year, month, day);
    }

    double jd = _getYearStartJd(year);

    // Add days for complete months
    for (int m = 1; m < month; m++) {
      jd += getMonthLength(year, m);
    }

    // Add day of month (minus 1 because epoch is day 1)
    jd += day - 1;

    return _julianDayToGregorian(jd);
  }

  /// Validate if a Hijri date is valid
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
}

/// Singleton instance
UmmAlQuraCalendarProvider? _instance;

/// Get the UmmAlQuraCalendarProvider singleton
UmmAlQuraCalendarProvider getUmmAlQuraProvider() {
  _instance ??= UmmAlQuraCalendarProvider();
  return _instance!;
}
