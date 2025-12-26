import '../calendar/hijri_date.dart';

/// Simple cache for storing computed recurrence results
class RRuleCache {
  List<HijriDate>? _allCache;
  final Map<String, HijriDate?> _afterCache = {};
  final Map<String, HijriDate?> _beforeCache = {};
  final Map<String, List<HijriDate>> _betweenCache = {};

  /// Check if we have cached 'all' results
  bool hasAll() => _allCache != null;

  /// Get cached 'all' results
  List<HijriDate>? getAll() => _allCache;

  /// Set cached 'all' results
  void setAll(List<HijriDate> dates) {
    _allCache = dates;
  }

  /// Get cached 'after' result
  /// Returns null if not in cache, use containsAfter to check
  HijriDate? getAfter(HijriDate dt, bool inclusive) {
    final key = _makeKey(dt, inclusive);
    return _afterCache[key];
  }

  /// Check if 'after' result is cached
  bool containsAfter(HijriDate dt, bool inclusive) {
    final key = _makeKey(dt, inclusive);
    return _afterCache.containsKey(key);
  }

  /// Set cached 'after' result
  void setAfter(HijriDate dt, bool inclusive, HijriDate? result) {
    final key = _makeKey(dt, inclusive);
    _afterCache[key] = result;
  }

  /// Get cached 'before' result
  HijriDate? getBefore(HijriDate dt, bool inclusive) {
    final key = _makeKey(dt, inclusive);
    return _beforeCache[key];
  }

  /// Check if 'before' result is cached
  bool containsBefore(HijriDate dt, bool inclusive) {
    final key = _makeKey(dt, inclusive);
    return _beforeCache.containsKey(key);
  }

  /// Set cached 'before' result
  void setBefore(HijriDate dt, bool inclusive, HijriDate? result) {
    final key = _makeKey(dt, inclusive);
    _beforeCache[key] = result;
  }

  /// Get cached 'between' result
  List<HijriDate>? getBetween(HijriDate after, HijriDate before, bool inclusive) {
    final key = _makeBetweenKey(after, before, inclusive);
    return _betweenCache[key];
  }

  /// Set cached 'between' result
  void setBetween(
    HijriDate after,
    HijriDate before,
    bool inclusive,
    List<HijriDate> result,
  ) {
    final key = _makeBetweenKey(after, before, inclusive);
    _betweenCache[key] = result;
  }

  /// Clear all cached data
  void clear() {
    _allCache = null;
    _afterCache.clear();
    _beforeCache.clear();
    _betweenCache.clear();
  }

  /// Create a cache key from date and inclusive flag
  String _makeKey(HijriDate dt, bool inclusive) {
    return '${dt.toString()}_$inclusive';
  }

  /// Create a cache key for between queries
  String _makeBetweenKey(HijriDate after, HijriDate before, bool inclusive) {
    return '${after.toString()}_${before.toString()}_$inclusive';
  }
}
