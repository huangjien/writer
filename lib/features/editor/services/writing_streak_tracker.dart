import 'package:writer/services/storage_service.dart';

class WritingStreakTracker {
  static const String _lastWriteDateKey = 'writer.editor.last_write_date';
  static const String _streakDaysKey = 'writer.editor.streak_days';

  const WritingStreakTracker();

  Future<int> loadStreak(StorageService storage) async {
    try {
      final last = storage.getString(_lastWriteDateKey);
      final streakRaw = storage.getString(_streakDaysKey);
      final storedStreak = int.tryParse(streakRaw ?? '') ?? 0;

      if (last == null) return 0;

      final lastDate = _parseStoredDate(last);
      if (lastDate == null) return 0;

      final diff = _calendarDayDiff(DateTime.now(), lastDate);
      return (diff == 0 || diff == 1) ? storedStreak : 0;
    } catch (_) {
      return 0;
    }
  }

  Future<int?> recordWritingSessionIfNeeded(
    StorageService storage, {
    required int words,
  }) async {
    if (words <= 0) return null;

    try {
      final today = DateTime.now();
      final todayKey = _formatDate(today);

      final last = storage.getString(_lastWriteDateKey);
      final streakRaw = storage.getString(_streakDaysKey);
      final currentStreak = int.tryParse(streakRaw ?? '') ?? 0;

      if (last == null) {
        await storage.setString(_lastWriteDateKey, todayKey);
        await storage.setString(_streakDaysKey, '1');
        return 1;
      }

      final lastDate = _parseStoredDate(last);
      if (lastDate == null) {
        await storage.setString(_lastWriteDateKey, todayKey);
        await storage.setString(_streakDaysKey, '1');
        return 1;
      }

      final diff = _calendarDayDiff(today, lastDate);

      if (diff == 0) {
        await storage.setString(_lastWriteDateKey, todayKey);
        return currentStreak;
      }

      final next = diff == 1 ? (currentStreak <= 0 ? 2 : currentStreak + 1) : 1;
      await storage.setString(_lastWriteDateKey, todayKey);
      await storage.setString(_streakDaysKey, '$next');
      return next;
    } catch (_) {
      return null;
    }
  }

  /// Parse a stored date string to a date-only DateTime.
  /// Handles both ISO 8601 (with time) and date-only strings.
  static DateTime? _parseStoredDate(String dateStr) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return null;
    return DateTime(dt.year, dt.month, dt.day);
  }

  /// Calculate calendar day difference, immune to DST transitions.
  /// Uses Julian day numbers to avoid time-based comparison issues.
  static int _calendarDayDiff(DateTime a, DateTime b) {
    final aDate = DateTime(a.year, a.month, a.day);
    final bDate = DateTime(b.year, b.month, b.day);
    // Convert to Julian day number for reliable calendar math
    return _toJulianDay(aDate) - _toJulianDay(bDate);
  }

  /// Convert DateTime (date-only) to Julian day number.
  static int _toJulianDay(DateTime dt) {
    final y = dt.year;
    final m = dt.month;
    final d = dt.day;
    final a = (14 - m) ~/ 12;
    final y2 = y + 4800 - a;
    final m2 = m + 12 * a - 3;
    return d +
        ((153 * m2 + 2) ~/ 5) +
        365 * y2 +
        y2 ~/ 4 -
        y2 ~/ 100 +
        y2 ~/ 400 -
        32045;
  }

  static String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
