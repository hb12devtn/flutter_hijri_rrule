/// Weekday number constants
/// 0 = Saturday (Islamic week start), 6 = Friday
/// Note: This differs from Dart's DateTime.weekday where 1 = Monday, 7 = Sunday
enum WeekdayNum {
  sa(0, 'SA'), // Saturday - traditional Islamic week start
  su(1, 'SU'), // Sunday
  mo(2, 'MO'), // Monday
  tu(3, 'TU'), // Tuesday
  we(4, 'WE'), // Wednesday
  th(5, 'TH'), // Thursday
  fr(6, 'FR'); // Friday - Islamic holy day

  const WeekdayNum(this.value, this.name);

  /// Numeric value (0-6)
  final int value;

  /// Two-letter string representation
  final String name;

  /// Parse a weekday string to enum value
  /// Throws [ArgumentError] if the string is not a valid weekday
  static WeekdayNum fromString(String str) {
    final upperStr = str.toUpperCase();
    for (final weekday in WeekdayNum.values) {
      if (weekday.name == upperStr) {
        return weekday;
      }
    }
    throw ArgumentError('Invalid weekday string: $str');
  }

  /// Get weekday from numeric value
  static WeekdayNum fromValue(int value) {
    for (final weekday in WeekdayNum.values) {
      if (weekday.value == value) {
        return weekday;
      }
    }
    throw ArgumentError('Invalid weekday value: $value');
  }

  /// Convert from Dart DateTime.weekday (1=Monday, 7=Sunday) to WeekdayNum
  static WeekdayNum fromDartWeekday(int dartWeekday) {
    // Dart: 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun
    // Hijri: 0=Sat, 1=Sun, 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri
    const mapping = [
      WeekdayNum.mo, // dartWeekday 1
      WeekdayNum.tu, // dartWeekday 2
      WeekdayNum.we, // dartWeekday 3
      WeekdayNum.th, // dartWeekday 4
      WeekdayNum.fr, // dartWeekday 5
      WeekdayNum.sa, // dartWeekday 6
      WeekdayNum.su, // dartWeekday 7
    ];
    if (dartWeekday < 1 || dartWeekday > 7) {
      throw ArgumentError('Invalid Dart weekday: $dartWeekday');
    }
    return mapping[dartWeekday - 1];
  }

  /// Convert to Dart DateTime.weekday (1=Monday, 7=Sunday)
  int toDartWeekday() {
    // Hijri: 0=Sat, 1=Sun, 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri
    // Dart: 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun
    const mapping = [6, 7, 1, 2, 3, 4, 5]; // sa, su, mo, tu, we, th, fr
    return mapping[value];
  }
}

/// Weekday names in English (full)
const List<String> weekdayNamesEn = [
  'Saturday',
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
];

/// Weekday names in English (short)
const List<String> weekdayNamesShortEn = [
  'Sat',
  'Sun',
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
];

/// Weekday names in Arabic
const List<String> weekdayNamesAr = [
  'السَّبْت', // Saturday
  'الأَحَد', // Sunday
  'الإِثْنَيْن', // Monday
  'الثُّلَاثَاء', // Tuesday
  'الأَرْبِعَاء', // Wednesday
  'الخَمِيس', // Thursday
  'الجُمُعَة', // Friday
];

/// Default week start for Islamic calendar
const WeekdayNum defaultWkst = WeekdayNum.su; // Sunday as per user preference
