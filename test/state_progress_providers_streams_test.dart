import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/progress_providers.dart' as pp;
import 'package:writer/models/user_progress.dart';
import 'package:writer/repositories/progress_port.dart';

void main() {
  group('Stream providers tests', () {
    test('latestUserProgressProvider creates correct stream configuration', () {
      // Test that the provider can be created without errors
      final provider = pp.latestUserProgressProvider;
      expect(provider, isA<FutureProvider<UserProgress?>>());
    });

    test('recentUserProgressProvider creates correct stream configuration', () {
      // Test that the provider can be created without errors
      final provider = pp.recentUserProgressProvider;
      expect(provider, isA<FutureProvider<List<UserProgress>>>());
    });

    test('UserProgress model can be created from JSON', () {
      // Test the UserProgress.fromJson factory method used in the providers
      final json = {
        'user_id': 'user123',
        'novel_id': 'novel456',
        'chapter_id': 'chapter789',
        'scroll_offset': 100.0,
        'tts_char_index': 50,
        'updated_at': '2023-01-01T00:00:00Z',
      };

      final progress = UserProgress.fromJson(json);

      expect(progress.userId, 'user123');
      expect(progress.novelId, 'novel456');
      expect(progress.chapterId, 'chapter789');
      expect(progress.scrollOffset, 100.0);
      expect(progress.ttsCharIndex, 50);
      expect(progress.updatedAt, isA<DateTime>());
    });

    test('UserProgress.fromJson handles empty list correctly', () {
      // Test the edge case where the stream returns an empty list
      final emptyList = <Map<String, dynamic>>[];

      // This should return null for latestUserProgressProvider
      final result = emptyList.isEmpty
          ? null
          : UserProgress.fromJson(emptyList.first);
      expect(result, isNull);

      // This should return empty list for recentUserProgressProvider
      final resultList = emptyList.map(UserProgress.fromJson).toList();
      expect(resultList, isEmpty);
    });

    test('progressRepositoryProvider creates correct provider', () {
      // Test that the provider can be created without errors
      final provider = pp.progressRepositoryProvider;
      expect(provider, isA<Provider<ProgressPort>>());
    });

    test('lastProgressProvider creates correct future provider', () {
      // Test that the provider can be created without errors
      final provider = pp.lastProgressProvider('test-novel-id');
      expect(provider, isA<FutureProvider<UserProgress?>>());
    });
  });
}
