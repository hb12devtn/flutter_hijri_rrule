import '../types/calendar_types.dart';
import 'providers/tabular_provider.dart';
import 'providers/umm_al_qura_provider.dart';

/// Global calendar configuration
class CalendarConfig {
  /// Default calendar type for new HijriRRule instances
  /// Default: islamicUmalqura
  final IslamicCalendarType defaultCalendar;

  /// Fallback calendar when primary fails
  /// Default: islamicTbla
  final IslamicCalendarType fallbackCalendar;

  /// Cache configuration
  final CacheConfig cache;

  const CalendarConfig({
    this.defaultCalendar = IslamicCalendarType.islamicUmalqura,
    this.fallbackCalendar = IslamicCalendarType.islamicTbla,
    this.cache = const CacheConfig(),
  });

  CalendarConfig copyWith({
    IslamicCalendarType? defaultCalendar,
    IslamicCalendarType? fallbackCalendar,
    CacheConfig? cache,
  }) {
    return CalendarConfig(
      defaultCalendar: defaultCalendar ?? this.defaultCalendar,
      fallbackCalendar: fallbackCalendar ?? this.fallbackCalendar,
      cache: cache ?? this.cache,
    );
  }
}

/// Cache configuration
class CacheConfig {
  /// Enable caching for calendar calculations
  final bool enabled;

  /// Maximum cache entries
  final int maxSize;

  const CacheConfig({
    this.enabled = true,
    this.maxSize = 1000,
  });
}

/// Default configuration
const _defaultConfig = CalendarConfig();

/// Current global configuration
CalendarConfig _globalConfig = _defaultConfig;

/// Get the current calendar configuration
CalendarConfig getCalendarConfig() {
  return _globalConfig;
}

/// Set global calendar configuration
///
/// Example:
/// ```dart
/// setCalendarConfig(CalendarConfig(
///   defaultCalendar: IslamicCalendarType.islamicTbla,
/// ));
/// ```
void setCalendarConfig(CalendarConfig config) {
  _globalConfig = config;
}

/// Reset configuration to defaults
void resetCalendarConfig() {
  _globalConfig = _defaultConfig;
}

/// Get the calendar provider for a given type
CalendarProvider getCalendarProvider([IslamicCalendarType? type]) {
  final calendarType = type ?? _globalConfig.defaultCalendar;

  switch (calendarType) {
    case IslamicCalendarType.islamicUmalqura:
      return getUmmAlQuraProvider();
    case IslamicCalendarType.islamicTbla:
      return getTabularProvider();
  }
}
