import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hijri_rrule/flutter_hijri_rrule.dart';

void main() {
  group('HijriDate', () {
    test('creates valid date', () {
      final date = HijriDate(1446, 9, 1);
      expect(date.year, 1446);
      expect(date.month, 9);
      expect(date.day, 1);
    });

    test('throws on invalid date', () {
      expect(() => HijriDate(1446, 13, 1), throwsArgumentError);
      expect(() => HijriDate(1446, 9, 31), throwsArgumentError);
    });

    test('formats toString correctly', () {
      final date = HijriDate(1446, 9, 1);
      expect(date.toString(), '1446-09-01');
    });

    test('compares dates correctly', () {
      final date1 = HijriDate(1446, 9, 1);
      final date2 = HijriDate(1446, 9, 2);
      final date3 = HijriDate(1446, 9, 1);

      expect(date1.isBefore(date2), isTrue);
      expect(date2.isAfter(date1), isTrue);
      expect(date1.equals(date3), isTrue);
    });
  });

  group('HijriRRule', () {
    test('generates yearly occurrences', () {
      final rule = HijriRRule(HijriRRulePartialOptions(
        freq: Frequency.yearly,
        bymonth: [HijriMonth.ramadan],
        bymonthday: [1],
        dtstart: HijriDate(1446, 9, 1),
        count: 3,
      ));

      final dates = rule.allHijri();
      expect(dates.length, 3);
      expect(dates[0].year, 1446);
      expect(dates[1].year, 1447);
      expect(dates[2].year, 1448);
    });

    test('generates monthly occurrences', () {
      final rule = HijriRRule(HijriRRulePartialOptions(
        freq: Frequency.monthly,
        bymonthday: [15],
        dtstart: HijriDate(1446, 1, 15),
        count: 3,
      ));

      final dates = rule.allHijri();
      expect(dates.length, 3);
      expect(dates.every((d) => d.day == 15), isTrue);
    });

    test('parses RRULE string', () {
      final rule = HijriRRule.fromString(
        'DTSTART;CALENDAR=HIJRI-TABULAR:14460101\nRRULE:FREQ=MONTHLY;COUNT=5;BYMONTHDAY=1',
      );

      final dates = rule.allHijri();
      expect(dates.length, 5);
    });

    test('converts to text in English', () {
      final rule = HijriRRule(HijriRRulePartialOptions(
        freq: Frequency.yearly,
        bymonth: [HijriMonth.ramadan],
        bymonthday: [1],
        dtstart: HijriDate(1446, 9, 1),
        count: 5,
      ));

      final text = rule.toText('en');
      expect(text, contains('every'));
      expect(text, contains('year'));
      expect(text, contains('Ramadan'));
    });

    test('converts to text in Arabic', () {
      final rule = HijriRRule(HijriRRulePartialOptions(
        freq: Frequency.yearly,
        bymonth: [HijriMonth.ramadan],
        bymonthday: [1],
        dtstart: HijriDate(1446, 9, 1),
        count: 5,
      ));

      final text = rule.toText('ar');
      expect(text, contains('كل'));
      expect(text, contains('سنة'));
      expect(text, contains('رَمَضَان'));
    });
  });

  group('HijriRRuleSet', () {
    test('combines rules and dates', () {
      final ruleSet = HijriRRuleSet();

      ruleSet.rrule(HijriRRule(HijriRRulePartialOptions(
        freq: Frequency.monthly,
        bymonthday: [1],
        dtstart: HijriDate(1446, 1, 1),
        count: 3,
      )));

      ruleSet.rdate(HijriDate(1446, 6, 15));
      ruleSet.exdate(HijriDate(1446, 2, 1));

      final dates = ruleSet.allHijri();
      // Should have: 1446-01-01, 1446-03-01, 1446-06-15
      // (1446-02-01 is excluded)
      expect(dates.length, 3);
      expect(dates.any((d) => d.equals(HijriDate(1446, 2, 1))), isFalse);
      expect(dates.any((d) => d.equals(HijriDate(1446, 6, 15))), isTrue);
    });
  });

  group('HijriWeekday', () {
    test('creates weekday with nth occurrence', () {
      final firstFriday = HijriWeekday.fr.nth(1);
      expect(firstFriday.weekday, WeekdayNum.fr);
      expect(firstFriday.n, 1);
    });

    test('formats weekday as RRULE string', () {
      expect(HijriWeekday.fr.toString(), 'FR');
      expect(HijriWeekday.fr.nth(1).toString(), '1FR');
      expect(HijriWeekday.mo.nth(-1).toString(), '-1MO');
    });
  });

  group('Calendar conversion', () {
    test('converts Hijri to Gregorian', () {
      final gregorian = hijriToGregorian(1446, 1, 1);
      expect(gregorian.year, isPositive);
      expect(gregorian.month, inInclusiveRange(1, 12));
      expect(gregorian.day, inInclusiveRange(1, 31));
    });

    test('converts Gregorian to Hijri', () {
      final gregorian = DateTime(2024, 7, 7);
      final hijri = gregorianToHijri(gregorian);
      expect(hijri.year, isPositive);
      expect(hijri.month, inInclusiveRange(1, 12));
      expect(hijri.day, inInclusiveRange(1, 30));
    });

    test('round-trips correctly', () {
      final original = HijriDate(1446, 5, 15);
      final gregorian = original.toGregorian();
      final roundTripped = HijriDate.fromGregorian(gregorian);
      expect(roundTripped.equals(original), isTrue);
    });
  });
}
