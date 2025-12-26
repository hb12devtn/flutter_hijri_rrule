/// A comprehensive RFC 5545 recurrence rule library for the Hijri (Islamic) calendar.
///
/// This library provides functionality for working with recurring events in
/// the Hijri calendar system, supporting both Umm al-Qura and Tabular Islamic
/// calendars.
///
/// ## Basic Usage
///
/// ```dart
/// import 'package:flutter_hijri_rrule/flutter_hijri_rrule.dart';
///
/// // Create a rule for the 1st of Ramadan every year
/// final rule = HijriRRule(HijriRRulePartialOptions(
///   freq: Frequency.yearly,
///   bymonth: [HijriMonth.ramadan],
///   bymonthday: [1],
///   dtstart: HijriDate(1446, 9, 1),
///   count: 5,
/// ));
///
/// // Get all occurrences
/// final dates = rule.allHijri();
/// for (final date in dates) {
///   print('${date.year}/${date.month}/${date.day}');
/// }
/// ```
///
/// ## Features
///
/// - Full RFC 5545 RRULE support adapted for Hijri calendar
/// - Support for both Umm al-Qura and Tabular Islamic calendars
/// - Lazy iteration with Dart generators
/// - Human-readable text output in English and Arabic
/// - Bidirectional conversion between Hijri and Gregorian dates
library;

// Calendar types
export 'src/types/calendar_types.dart' show IslamicCalendarType;

// Date types
export 'src/calendar/hijri_date.dart' show HijriDate;
export 'src/types/options.dart' show HijriDateLike;

// Frequency and weekday constants
export 'src/constants/frequency.dart' show Frequency;
export 'src/constants/weekday.dart' show WeekdayNum;
export 'src/constants/months.dart' show HijriMonth, monthNamesEn, monthNamesAr;

// Weekday class
export 'src/weekday/hijri_weekday.dart';

// Options
export 'src/types/options.dart' show HijriRRulePartialOptions, HijriRRuleParsedOptions, Skip;
export 'src/types/weekday.dart' show WeekdaySpec;

// Main RRULE classes
export 'src/rrule/hijri_rrule.dart' show HijriRRule, IteratorCallback;
export 'src/rrule/hijri_rrule_set.dart' show HijriRRuleSet;

// Calendar configuration
export 'src/calendar/calendar_config.dart' show CalendarConfig;

// Conversion utilities
export 'src/calendar/hijri_converter.dart' show gregorianToHijri, hijriToGregorian;

// NLP
export 'src/nlp/to_text.dart' show toText;
export 'src/nlp/i18n.dart' show I18nStrings, getI18n, en, ar;
