/// Frequency enum for recurrence rules
/// Maps to RFC 5545 FREQ property values
enum Frequency {
  yearly(0, 'YEARLY'),
  monthly(1, 'MONTHLY'),
  weekly(2, 'WEEKLY'),
  daily(3, 'DAILY'),
  hourly(4, 'HOURLY'),
  minutely(5, 'MINUTELY'),
  secondly(6, 'SECONDLY');

  const Frequency(this.value, this.name);

  /// Numeric value of the frequency
  final int value;

  /// String representation (e.g., 'YEARLY', 'MONTHLY')
  final String name;

  /// Parse a frequency string to enum value
  /// Throws [ArgumentError] if the string is not a valid frequency
  static Frequency fromString(String str) {
    final upperStr = str.toUpperCase();
    for (final freq in Frequency.values) {
      if (freq.name == upperStr) {
        return freq;
      }
    }
    throw ArgumentError('Invalid frequency string: $str');
  }

  /// Get frequency from numeric value
  static Frequency fromValue(int value) {
    for (final freq in Frequency.values) {
      if (freq.value == value) {
        return freq;
      }
    }
    throw ArgumentError('Invalid frequency value: $value');
  }
}
