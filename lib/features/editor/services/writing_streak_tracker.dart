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

      final lastDate = DateTime.tryParse(last);
      if (lastDate == null) return 0;

      final today = _dateOnly(DateTime.now());
      final diff = today.difference(_dateOnly(lastDate)).inDays;
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
      final today = _dateOnly(DateTime.now());
      final todayKey = _formatDate(today);

      final last = storage.getString(_lastWriteDateKey);
      final streakRaw = storage.getString(_streakDaysKey);
      final currentStreak = int.tryParse(streakRaw ?? '') ?? 0;

      if (last == null) {
        await storage.setString(_lastWriteDateKey, todayKey);
        await storage.setString(_streakDaysKey, '1');
        return 1;
      }

      final lastDate = DateTime.tryParse(last);
      if (lastDate == null) {
        await storage.setString(_lastWriteDateKey, todayKey);
        await storage.setString(_streakDaysKey, '1');
        return 1;
      }

      final diff = today.difference(_dateOnly(lastDate)).inDays;
      if (diff == 0) return currentStreak;

      final next = diff == 1 ? (currentStreak <= 0 ? 2 : currentStreak + 1) : 1;
      await storage.setString(_lastWriteDateKey, todayKey);
      await storage.setString(_streakDaysKey, '$next');
      return next;
    } catch (_) {
      return null;
    }
  }

  static DateTime _dateOnly(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  static String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
