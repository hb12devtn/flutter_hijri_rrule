/// Hijri Month Names and Constants
library;

/// Hijri month constants
abstract class HijriMonth {
  static const int muharram = 1;
  static const int safar = 2;
  static const int rabiAlAwwal = 3;
  static const int rabiAlThani = 4;
  static const int jumadaAlAwwal = 5;
  static const int jumadaAlThani = 6;
  static const int rajab = 7;
  static const int shaban = 8;
  static const int ramadan = 9;
  static const int shawwal = 10;
  static const int dhuAlQadah = 11;
  static const int dhuAlHijjah = 12;
}

/// English names for Hijri months (index 0 = padding, 1-12 = months)
const List<String> monthNamesEn = [
  '', // Index 0 - not used
  'Muharram',
  'Safar',
  "Rabi' al-Awwal",
  "Rabi' al-Thani",
  'Jumada al-Awwal',
  'Jumada al-Thani',
  'Rajab',
  "Sha'ban",
  'Ramadan',
  'Shawwal',
  "Dhu al-Qa'dah",
  'Dhu al-Hijjah',
];

/// Short English names for Hijri months
const List<String> monthNamesShortEn = [
  '', // Index 0 - not used
  'Muh',
  'Saf',
  'Rb1',
  'Rb2',
  'Jm1',
  'Jm2',
  'Raj',
  'Sha',
  'Ram',
  'Shw',
  'Qad',
  'Hij',
];

/// Arabic names for Hijri months
const List<String> monthNamesAr = [
  '', // Index 0 - not used
  'مُحَرَّم',
  'صَفَر',
  'رَبِيع الأَوَّل',
  'رَبِيع الثَّانِي',
  'جُمَادَى الأُولَى',
  'جُمَادَى الآخِرَة',
  'رَجَب',
  'شَعْبَان',
  'رَمَضَان',
  'شَوَّال',
  'ذُو القَعْدَة',
  'ذُو الحِجَّة',
];

/// Ordinal suffixes for English
const Map<int, String> _ordinalSuffixes = {
  1: 'st',
  2: 'nd',
  3: 'rd',
  21: 'st',
  22: 'nd',
  23: 'rd',
  31: 'st',
};

/// Get ordinal suffix for a number
String getOrdinalSuffix(int n) {
  final lastTwo = n % 100;
  if (lastTwo >= 11 && lastTwo <= 13) {
    return 'th';
  }
  final lastDigit = n % 10;
  return _ordinalSuffixes[lastDigit] ?? 'th';
}

/// Format a day number with ordinal suffix
String formatOrdinal(int n) {
  return '$n${getOrdinalSuffix(n)}';
}
