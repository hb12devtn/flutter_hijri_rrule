## 1.0.0

Initial release of flutter_hijri_rrule.

### Features

- **RFC 5545 RRULE Support**: Recurrence rules adapted for the Hijri calendar
  - FREQ: YEARLY, MONTHLY, WEEKLY, DAILY
  - INTERVAL, COUNT, UNTIL
  - BYMONTH, BYMONTHDAY, BYDAY, BYYEARDAY, BYSETPOS
  - WKST (week start day)
  - SKIP parameter (OMIT, FORWARD, BACKWARD) for handling invalid dates

- **HijriDate**: Immutable Hijri date representation
  - Bidirectional conversion between Hijri and Gregorian dates
  - Date validation and comparison operators
  - Localized date formatting (English and Arabic)

- **Calendar Support**: Two Islamic calendar calculation methods
  - Umm al-Qura calendar (official Saudi calendar)
  - Tabular Islamic calendar (30-year cycle)

- **HijriRRule**: Single recurrence rule with query operations
  - `all()` / `allHijri()`: Get all occurrences
  - `between()` / `betweenHijri()`: Occurrences in date range
  - `after()` / `afterHijri()`: Next occurrence after date
  - `before()` / `beforeHijri()`: Previous occurrence before date
  - `count()`: Total occurrence count
  - Lazy iteration with Dart generators

- **HijriRRuleSet**: Combine multiple rules
  - Inclusion rules (RRULE) and dates (RDATE)
  - Exclusion rules (EXRULE) and dates (EXDATE)

- **Natural Language Processing**: Human-readable text generation
  - English language support
  - Arabic language support

- **RRULE String Parsing**: Parse and serialize RFC 5545 compliant strings
  - Custom CALENDAR parameter for Hijri calendar type
  - Full round-trip support (parse -> modify -> serialize)
