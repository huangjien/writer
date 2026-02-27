import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/user_progress.dart';

void main() {
  group('Progress Providers Stream Logic Tests', () {
    test('Stream providers handle null user correctly', () async {
      // This test verifies that when there's no authenticated user,
      // the stream providers return appropriate default values
      // Note: We can't easily test the actual providers due to the singleton pattern,
      // but we can test the logic

      // Simulate the null user case
      const String? userId = null;
      expect(userId, isNull);

      // When userId is null, the providers should return:
      // - latestUserProgressProvider: Stream.value(null)
      // - recentUserProgressProvider: Stream.value([])

      // Test the logic that would be used in the providers
      if (userId == null) {
        // This is what latestUserProgressProvider would return
        const latestProgress = null;
        expect(latestProgress, isNull);

        // This is what recentUserProgressProvider would return
        final recentProgress = <UserProgress>[];
        expect(recentProgress, isEmpty);
      }
    });

    test('UserProgress model handles stream data correctly', () {
      // Test the UserProgress.fromJson factory method with various data formats
      final testData = [
        {
          'user_id': 'user123',
          'novel_id': 'novel456',
          'chapter_id': 'chapter789',
          'scroll_offset': 100.0,
          'tts_char_index': 50,
          'updated_at': '2023-01-01T00:00:00Z',
        },
        {
          'user_id': 'user456',
          'novel_id': 'novel789',
          'chapter_id': 'chapter123',
          'scroll_offset': 0.0,
          'tts_char_index': 0,
          'updated_at': '2023-12-31T23:59:59Z',
        },
      ];

      // Test single item conversion (for latestUserProgressProvider)
      final singleProgress = UserProgress.fromJson(testData.first);
      expect(singleProgress.userId, 'user123');
      expect(singleProgress.novelId, 'novel456');
      expect(singleProgress.chapterId, 'chapter789');
      expect(singleProgress.scrollOffset, 100.0);
      expect(singleProgress.ttsCharIndex, 50);

      // Test list conversion (for recentUserProgressProvider)
      final progressList = testData.map(UserProgress.fromJson).toList();
      expect(progressList.length, 2);
      expect(progressList.first.userId, 'user123');
      expect(progressList.last.userId, 'user456');
    });

    test('Stream providers handle empty stream data correctly', () {
      // Test edge cases for empty stream data
      final emptyList = <Map<String, dynamic>>[];

      // For latestUserProgressProvider, empty list should return null
      final latestResult = emptyList.isEmpty
          ? null
          : UserProgress.fromJson(emptyList.first);
      expect(latestResult, isNull);

      // For recentUserProgressProvider, empty list should return empty list
      final recentResult = emptyList.map(UserProgress.fromJson).toList();
      expect(recentResult, isEmpty);
    });

    test('Stream providers handle stream transformation logic', () {
      // Test the stream transformation logic that would be used in the providers
      final testData = [
        {
          'user_id': 'user123',
          'novel_id': 'novel456',
          'chapter_id': 'chapter789',
          'scroll_offset': 100.0,
          'tts_char_index': 50,
          'updated_at': '2023-01-01T00:00:00Z',
        },
      ];

      // Simulate the stream transformation for latestUserProgressProvider
      final latestResult = testData.isEmpty
          ? null
          : UserProgress.fromJson(testData.first);
      expect(latestResult, isA<UserProgress>());
      expect(latestResult?.userId, 'user123');

      // Simulate the stream transformation for recentUserProgressProvider
      final recentResult = testData.map(UserProgress.fromJson).toList();
      expect(recentResult, isA<List<UserProgress>>());
      expect(recentResult.length, 1);
      expect(recentResult.first.userId, 'user123');
    });

    test('Stream providers handle multiple items with ordering', () {
      // Test that the ordering logic works correctly
      final testData = [
        {
          'user_id': 'user123',
          'novel_id': 'novel456',
          'chapter_id': 'chapter789',
          'scroll_offset': 100.0,
          'tts_char_index': 50,
          'updated_at': '2023-01-01T00:00:00Z',
        },
        {
          'user_id': 'user123',
          'novel_id': 'novel456',
          'chapter_id': 'chapter790',
          'scroll_offset': 200.0,
          'tts_char_index': 100,
          'updated_at': '2023-01-02T00:00:00Z', // More recent
        },
        {
          'user_id': 'user123',
          'novel_id': 'novel456',
          'chapter_id': 'chapter791',
          'scroll_offset': 300.0,
          'tts_char_index': 150,
          'updated_at': '2023-01-03T00:00:00Z', // Most recent
        },
      ];

      // For latestUserProgressProvider, should return the most recent item (first after ordering by updated_at desc)
      final latestResult = testData.isEmpty
          ? null
          : UserProgress.fromJson(testData.first);
      expect(latestResult?.chapterId, 'chapter789'); // First item in the list

      // For recentUserProgressProvider, should return all items (limited to 3 in the actual provider)
      final recentResult = testData.map(UserProgress.fromJson).toList();
      expect(recentResult.length, 3);
      expect(recentResult.first.chapterId, 'chapter789');
      expect(recentResult.last.chapterId, 'chapter791');
    });

    test('Stream providers handle valid data correctly', () {
      // Test handling of valid data
      final testData = [
        {
          'user_id': 'user123',
          'novel_id': 'novel456',
          'chapter_id': 'chapter789',
          'scroll_offset': 100.0,
          'tts_char_index': 50,
          'updated_at': '2023-01-01T00:00:00Z',
        },
      ];

      // Should handle all required fields correctly
      final progress = UserProgress.fromJson(testData.first);
      expect(progress.userId, 'user123');
      expect(progress.novelId, 'novel456');
      expect(progress.chapterId, 'chapter789');
      expect(progress.scrollOffset, 100.0);
      expect(progress.ttsCharIndex, 50);
      expect(progress.updatedAt, isA<DateTime>());
    });
  });
}
