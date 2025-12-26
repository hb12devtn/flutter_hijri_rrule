/// Supported Islamic calendar types
///
/// - `islamicUmalqura`: Saudi Arabian official calendar based on Umm al-Qura (DEFAULT)
/// - `islamicTbla`: Tabular Islamic Calendar with fixed month patterns
enum IslamicCalendarType {
  islamicUmalqura('islamic-umalqura'),
  islamicTbla('islamic-tbla');

  const IslamicCalendarType(this.value);

  /// String value for serialization
  final String value;

  /// Parse a calendar type string to enum value
  static IslamicCalendarType fromString(String str) {
    final lowerStr = str.toLowerCase();
    for (final type in IslamicCalendarType.values) {
      if (type.value == lowerStr) {
        return type;
      }
    }
    // Also support alternative names
    switch (lowerStr) {
      case 'hijri-um-al-qura':
      case 'umm-al-qura':
      case 'umalqura':
        return IslamicCalendarType.islamicUmalqura;
      case 'hijri-tabular':
      case 'tabular':
      case 'tbla':
        return IslamicCalendarType.islamicTbla;
      default:
        throw ArgumentError('Invalid calendar type: $str');
    }
  }
}

/// Simple Hijri date components
class HijriDateComponents {
  final int year;
  final int month;
  final int day;

  const HijriDateComponents({
    required this.year,
    required this.month,
    required this.day,
  });

  @override
  String toString() => 'HijriDateComponents($year-$month-$day)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HijriDateComponents &&
        other.year == year &&
        other.month == month &&
        other.day == day;
  }

  @override
  int get hashCode => Object.hash(year, month, day);
}

/// Calendar Provider Interface
///
/// Abstraction for different Islamic calendar calculation algorithms.
/// Implements Strategy pattern to allow switching between
/// Umm al-Qura and Tabular calendar implementations.
abstract class CalendarProvider {
  /// Calendar type identifier
  IslamicCalendarType get type;

  /// Get the number of days in a specific Hijri month
  /// [year] - Hijri year
  /// [month] - Hijri month (1-12)
  /// Returns Number of days (29 or 30)
  int getMonthLength(int year, int month);

  /// Check if a Hijri year is a leap year (355 days)
  /// [year] - Hijri year
  /// Returns true if leap year
  bool isLeapYear(int year);

  /// Get the total number of days in a Hijri year
  /// [year] - Hijri year
  /// Returns 354 (normal) or 355 (leap)
  int getYearLength(int year);

  /// Convert a Gregorian date to Hijri date components
  /// [date] - Gregorian DateTime object
  /// Returns Hijri year, month, and day
  HijriDateComponents gregorianToHijri(DateTime date);

  /// Convert Hijri date components to a Gregorian DateTime
  /// [year] - Hijri year
  /// [month] - Hijri month (1-12)
  /// [day] - Hijri day (1-30)
  /// Returns Gregorian DateTime object
  DateTime hijriToGregorian(int year, int month, int day);

  /// Validate if a Hijri date is valid
  /// [year] - Hijri year
  /// [month] - Hijri month (1-12)
  /// [day] - Hijri day
  /// Returns true if valid date
  bool isValidDate(int year, int month, int day);
}
