import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/progress_dashboard/services/progress_analytics_service.dart';
import 'package:writer/models/writing_progress.dart';

void main() {
  late ProgressAnalyticsService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    service = ProgressAnalyticsService();
  });

  tearDown(() {
    service.clearCache();
  });

  group('ProgressAnalyticsService - Stats Calculation', () {
    test('should calculate stats with no data', () async {
      final stats = await service.calculateStats();

      expect(stats.totalWords, 0);
      expect(stats.totalTimeMinutes, 0);
      expect(stats.totalSessions, 0);
      expect(stats.averageWordsPerDay, 0);
      expect(stats.currentStreak, 0);
      expect(stats.longestStreak, 0);
    });

    test('should calculate stats for default period', () async {
      final stats = await service.calculateStats();

      expect(stats.periodStart, isNotNull);
      expect(stats.periodEnd, isNotNull);
      expect(stats.totalDays, greaterThanOrEqualTo(0));
    });

    test('should calculate stats for custom period', () async {
      final start = DateTime(2026, 3, 1);
      final end = DateTime(2026, 3, 7);

      final stats = await service.calculateStats(
        startDate: start,
        endDate: end,
      );

      expect(stats.periodStart, start);
      expect(stats.periodEnd, end);
      expect(stats.totalDays, greaterThanOrEqualTo(0));
    });

    test('should calculate average words per minute correctly', () async {
      final stats = WritingStats(
        totalWords: 3000,
        totalTimeMinutes: 60,
        totalSessions: 2,
        averageWordsPerDay: 500,
        averageWordsPerSession: 1500,
        currentStreak: 1,
        longestStreak: 1,
        totalDays: 1,
        productiveDays: 1,
        periodStart: DateTime(2026, 3, 29),
        periodEnd: DateTime(2026, 3, 29),
      );

      expect(stats.averageWordsPerMinute, 50);
    });

    test('should calculate productivity rate correctly', () async {
      final stats = WritingStats(
        totalWords: 5000,
        totalTimeMinutes: 300,
        totalSessions: 10,
        averageWordsPerDay: 500,
        averageWordsPerSession: 500,
        currentStreak: 5,
        longestStreak: 5,
        totalDays: 10,
        productiveDays: 7,
        periodStart: DateTime(2026, 3, 20),
        periodEnd: DateTime(2026, 3, 29),
      );

      expect(stats.productivityRate, 0.7);
    });
  });

  group('ProgressAnalyticsService - Writing Trends', () {
    test('should get writing trend for default period', () async {
      final trend = await service.getWritingTrend();

      expect(trend, isList);
      expect(trend.length, greaterThanOrEqualTo(0));
    });

    test('should get writing trend for custom days', () async {
      final trend = await service.getWritingTrend(days: 7);

      expect(trend.length, lessThanOrEqualTo(7));
    });

    test('should get weekly word counts', () async {
      final weeklyMap = await service.getWeeklyWordCounts(weeks: 4);

      expect(weeklyMap, isMap);
    });
  });

  group('ProgressAnalyticsService - Productivity Patterns', () {
    test('should return patterns with insufficient data', () async {
      final patterns = await service.getProductivityPatterns();

      expect(patterns['best_hour'], 'Not enough data');
      expect(patterns['best_day'], 'Not enough data');
      expect(patterns['total_days_analyzed'], 0);
    });

    test('should identify best writing day', () async {
      final patterns = await service.getProductivityPatterns();

      expect(patterns.containsKey('best_day'), true);
      expect(patterns.containsKey('best_day_words'), true);
    });

    test('should identify best writing hour', () async {
      final patterns = await service.getProductivityPatterns();

      expect(patterns.containsKey('best_hour'), true);
      expect(patterns.containsKey('best_hour_words'), true);
    });
  });

  group('ProgressAnalyticsService - Achievements', () {
    test('should initialize default achievements', () async {
      final achievements = await service.getAchievements();

      expect(achievements, isNotEmpty);
      expect(achievements.any((a) => a.id == 'first_words'), true);
      expect(achievements.any((a) => a.id == 'thousand_words'), true);
      expect(achievements.any((a) => a.id == 'week_streak'), true);
      expect(achievements.any((a) => a.id == 'month_streak'), true);
    });

    test('should have correct achievement types', () async {
      final achievements = await service.getAchievements();

      expect(
        achievements.where((a) => a.type == AchievementType.wordCount),
        isNotEmpty,
      );
      expect(
        achievements.where((a) => a.type == AchievementType.streak),
        isNotEmpty,
      );
      expect(
        achievements.where((a) => a.type == AchievementType.consistency),
        isNotEmpty,
      );
    });

    test('should cache achievements in memory', () async {
      final achievements1 = await service.getAchievements();
      final achievements2 = await service.getAchievements();

      expect(identical(achievements1, achievements2), false);
      expect(achievements1.length, achievements2.length);
    });

    test('should unlock achievement manually', () async {
      final achievements = await service.getAchievements();
      final firstAchievement = achievements.first;

      expect(firstAchievement.isUnlocked, false);

      await service.unlockAchievement(firstAchievement.id);

      final updated = await service.getAchievements();
      final unlocked = updated.firstWhere((a) => a.id == firstAchievement.id);

      expect(unlocked.isUnlocked, true);
      expect(unlocked.unlockedAt, isNotNull);
    });

    test('should update achievement progress', () async {
      await service.updateAchievementProgress();

      final achievements = await service.getAchievements();
      expect(achievements, isNotEmpty);
    });

    test('should persist achievements across service instances', () async {
      final achievements1 = await service.getAchievements();
      final firstId = achievements1.first.id;

      await service.unlockAchievement(firstId);

      final newService = ProgressAnalyticsService();
      final achievements2 = await newService.getAchievements();
      final unlocked = achievements2.firstWhere((a) => a.id == firstId);

      expect(unlocked.isUnlocked, true);
    });

    test('should search achievements by title', () async {
      final results = await service.searchAchievements('words');

      expect(results, isNotEmpty);
      expect(
        results.every(
          (a) =>
              a.title.toLowerCase().contains('words') ||
              a.description.toLowerCase().contains('words'),
        ),
        true,
      );
    });

    test('should search achievements by type', () async {
      final results = await service.searchAchievements('streak');

      expect(results, isNotEmpty);
    });

    test('should return empty list for non-matching search', () async {
      final results = await service.searchAchievements('nonexistent');

      expect(results, isEmpty);
    });
  });

  group('ProgressAnalyticsService - Export', () {
    test('should export data to CSV format', () async {
      final csv = await service.exportToCSV();

      expect(csv, isNotEmpty);
      expect(
        csv.contains(
          'Date,Words Written,Writing Time (min),Sessions,Words per Minute',
        ),
        true,
      );
    });

    test('should include header row in CSV export', () async {
      final csv = await service.exportToCSV();

      final lines = csv.split('\n');
      expect(lines.first, contains('Date'));
      expect(lines.first, contains('Words Written'));
    });

    test('should generate summary report', () async {
      final report = await service.generateSummaryReport();

      expect(report, isNotEmpty);
      expect(report.contains('# Writing Progress Report'), true);
      expect(report.contains('## 30-Day Overview'), true);
      expect(report.contains('## Productivity Patterns'), true);
      expect(report.contains('## Achievements'), true);
    });

    test('should include achievement status in report', () async {
      final report = await service.generateSummaryReport();

      expect(report.contains('Achievements'), true);
      expect(report.contains('Unlocked:'), true);
    });

    test('should clear cache', () async {
      await service.getAchievements();

      service.clearCache();

      final achievements = await service.getAchievements();
      expect(achievements, isNotEmpty);
    });
  });
}
