// ignore_for_file: avoid_print
import 'package:flutter_hijri_rrule/flutter_hijri_rrule.dart';

void main() {
  // Example 1: Create a yearly recurrence for the 1st of Ramadan
  print('=== Example 1: Yearly Ramadan Rule ===');
  final ramadanRule = HijriRRule(HijriRRulePartialOptions(
    freq: Frequency.yearly,
    bymonth: [HijriMonth.ramadan],
    bymonthday: [1],
    dtstart: HijriDate(1446, 9, 1),
    count: 5,
  ));

  print('Rule: ${ramadanRule.toString()}');
  print('Human readable (EN): ${ramadanRule.toText("en")}');
  print('Human readable (AR): ${ramadanRule.toText("ar")}');
  print('Occurrences:');
  for (final date in ramadanRule.allHijri()) {
    print('  ${date.toLocaleDateString("en")}');
  }
  print('');

  // Example 2: Monthly recurrence on the 15th
  print('=== Example 2: Monthly on 15th ===');
  final monthlyRule = HijriRRule(HijriRRulePartialOptions(
    freq: Frequency.monthly,
    bymonthday: [15],
    dtstart: HijriDate(1446, 1, 15),
    count: 6,
  ));

  print('Rule: ${monthlyRule.toString()}');
  print('Occurrences:');
  for (final date in monthlyRule.allHijri()) {
    print('  ${date.toString()} (${date.toLocaleDateString("en")})');
  }
  print('');

  // Example 3: Weekly on Friday (Jumu'ah)
  print('=== Example 3: Weekly on Friday ===');
  final fridayRule = HijriRRule(HijriRRulePartialOptions(
    freq: Frequency.weekly,
    byweekday: [HijriWeekday.fr],
    dtstart: HijriDate(1446, 1, 1),
    count: 4,
  ));

  print('Rule: ${fridayRule.toString()}');
  print('Human readable: ${fridayRule.toText()}');
  print('Occurrences (Gregorian):');
  for (final date in fridayRule.all()) {
    print('  $date');
  }
  print('');

  // Example 4: First Friday of each month (Jumu'ah tul-Awwal)
  print('=== Example 4: First Friday of Each Month ===');
  final firstFridayRule = HijriRRule(HijriRRulePartialOptions(
    freq: Frequency.monthly,
    byweekday: [HijriWeekday.fr.nth(1)],
    dtstart: HijriDate(1446, 1, 1),
    count: 6,
  ));

  print('Rule: ${firstFridayRule.toString()}');
  print('Human readable: ${firstFridayRule.toText()}');
  print('Occurrences:');
  for (final date in firstFridayRule.allHijri()) {
    print('  ${date.toLocaleDateString()}');
  }
  print('');

  // Example 5: Parse an RRULE string
  print('=== Example 5: Parse RRULE String ===');
  final parsed = HijriRRule.fromString(
    'DTSTART;CALENDAR=HIJRI-TABULAR:14460901\n'
    'RRULE:FREQ=YEARLY;BYMONTH=9;BYMONTHDAY=1;COUNT=3',
  );

  print('Parsed rule: ${parsed.toString()}');
  print('Occurrences:');
  for (final date in parsed.allHijri()) {
    print('  ${date.toLocaleDateString()}');
  }
  print('');

  // Example 6: HijriRRuleSet with inclusions and exclusions
  print('=== Example 6: RuleSet with Exclusions ===');
  final ruleSet = HijriRRuleSet();

  // Add a rule for 1st of every month
  ruleSet.rrule(HijriRRule(HijriRRulePartialOptions(
    freq: Frequency.monthly,
    bymonthday: [1],
    dtstart: HijriDate(1446, 1, 1),
    count: 6,
  )));

  // Add an extra date
  ruleSet.rdate(HijriDate(1446, 3, 15));

  // Exclude the 1st of month 2
  ruleSet.exdate(HijriDate(1446, 2, 1));

  print('RuleSet:\n${ruleSet.toString()}');
  print('Occurrences:');
  for (final date in ruleSet.allHijri()) {
    print('  ${date.toLocaleDateString()}');
  }
  print('');

  // Example 7: Date conversion
  print('=== Example 7: Date Conversion ===');
  final today = DateTime.now();
  final todayHijri = HijriDate.fromGregorian(today);
  print('Today (Gregorian): $today');
  print('Today (Hijri): ${todayHijri.toLocaleDateString("en")}');
  print('Today (Hijri Arabic): ${todayHijri.toLocaleDateString("ar")}');

  final backToGregorian = todayHijri.toGregorian();
  print('Back to Gregorian: $backToGregorian');
  print('');

  // Example 8: Using between() to get occurrences in a range
  print('=== Example 8: Occurrences Between Dates ===');
  final rule = HijriRRule(HijriRRulePartialOptions(
    freq: Frequency.monthly,
    bymonthday: [1, 15],
    dtstart: HijriDate(1446, 1, 1),
    until: HijriDate(1446, 12, 29),
  ));

  final occurrencesInRange = rule.betweenHijri(
    HijriDate(1446, 3, 1),
    HijriDate(1446, 6, 1),
    inc: true,
  );

  print('Occurrences between 1446-03-01 and 1446-06-01:');
  for (final date in occurrencesInRange) {
    print('  ${date.toString()}');
  }
  print('');

  // Example 9: Using after() and before()
  print('=== Example 9: After and Before ===');
  final nextOccurrence = rule.afterHijri(HijriDate(1446, 5, 10));
  final prevOccurrence = rule.beforeHijri(HijriDate(1446, 5, 10));
  print('Reference date: 1446-05-10');
  print('Next occurrence: ${nextOccurrence?.toString() ?? "none"}');
  print('Previous occurrence: ${prevOccurrence?.toString() ?? "none"}');

  // Example 10: Parse an RRULE string
  print('=== Example 5: Parse RRULE String ===');
  final lastRamadanDay = HijriRRule.fromString(
    'DTSTART;CALENDAR=HIJRI-UM-AL-QURA:14460901\n'
    'RRULE:FREQ=YEARLY;WKST=SU;COUNT=10;BYMONTHDAY=30;SKIP=BACKWARD',
  );

  print('Parsed rule: ${parsed.toString()}');
  print('Occurrences:');
  for (final date in lastRamadanDay.allHijri()) {
    print('  ${date.toLocaleDateString()}');
  }
  print('');
}