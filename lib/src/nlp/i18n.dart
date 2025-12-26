/// Internationalization strings for NLP module
library;

/// Interface for i18n strings
class I18nStrings {
  // Frequency words
  final String every;
  final String yearly;
  final String monthly;
  final String weekly;
  final String daily;
  final String hourly;
  final String minutely;
  final String secondly;

  // Interval words
  final String year;
  final String years;
  final String month;
  final String months;
  final String week;
  final String weeks;
  final String day;
  final String days;

  // Conjunction
  final String and;
  final String or;
  final String on;
  final String inWord; // 'in' is a reserved keyword in Dart
  final String the;
  final String of;

  // Time words
  final String forWord; // 'for' is a reserved keyword in Dart
  final String times;
  final String time;
  final String until;

  // Ordinals
  final String first;
  final String second;
  final String third;
  final String fourth;
  final String fifth;
  final String last;
  final String secondLast;

  // Weekdays
  final List<String> weekdays;

  // Months
  final List<String> monthNames;

  // Day formatting
  final String dayPrefix;

  const I18nStrings({
    required this.every,
    required this.yearly,
    required this.monthly,
    required this.weekly,
    required this.daily,
    required this.hourly,
    required this.minutely,
    required this.secondly,
    required this.year,
    required this.years,
    required this.month,
    required this.months,
    required this.week,
    required this.weeks,
    required this.day,
    required this.days,
    required this.and,
    required this.or,
    required this.on,
    required this.inWord,
    required this.the,
    required this.of,
    required this.forWord,
    required this.times,
    required this.time,
    required this.until,
    required this.first,
    required this.second,
    required this.third,
    required this.fourth,
    required this.fifth,
    required this.last,
    required this.secondLast,
    required this.weekdays,
    required this.monthNames,
    required this.dayPrefix,
  });
}

/// English strings
const I18nStrings en = I18nStrings(
  every: 'every',
  yearly: 'year',
  monthly: 'month',
  weekly: 'week',
  daily: 'day',
  hourly: 'hour',
  minutely: 'minute',
  secondly: 'second',
  year: 'year',
  years: 'years',
  month: 'month',
  months: 'months',
  week: 'week',
  weeks: 'weeks',
  day: 'day',
  days: 'days',
  and: 'and',
  or: 'or',
  on: 'on',
  inWord: 'in',
  the: 'the',
  of: 'of',
  forWord: 'for',
  times: 'times',
  time: 'time',
  until: 'until',
  first: 'first',
  second: 'second',
  third: 'third',
  fourth: 'fourth',
  fifth: 'fifth',
  last: 'last',
  secondLast: 'second last',
  weekdays: [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ],
  monthNames: [
    '',
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
  ],
  dayPrefix: 'day',
);

/// Arabic strings
const I18nStrings ar = I18nStrings(
  every: 'كل',
  yearly: 'سنة',
  monthly: 'شهر',
  weekly: 'أسبوع',
  daily: 'يوم',
  hourly: 'ساعة',
  minutely: 'دقيقة',
  secondly: 'ثانية',
  year: 'سنة',
  years: 'سنوات',
  month: 'شهر',
  months: 'أشهر',
  week: 'أسبوع',
  weeks: 'أسابيع',
  day: 'يوم',
  days: 'أيام',
  and: 'و',
  or: 'أو',
  on: 'في',
  inWord: 'في',
  the: '',
  of: 'من',
  forWord: 'لمدة',
  times: 'مرات',
  time: 'مرة',
  until: 'حتى',
  first: 'الأول',
  second: 'الثاني',
  third: 'الثالث',
  fourth: 'الرابع',
  fifth: 'الخامس',
  last: 'الأخير',
  secondLast: 'قبل الأخير',
  weekdays: [
    'السبت',
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
  ],
  monthNames: [
    '',
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
  ],
  dayPrefix: 'اليوم',
);

/// Get I18n strings for a locale
I18nStrings getI18n(String locale) {
  return locale == 'ar' ? ar : en;
}
