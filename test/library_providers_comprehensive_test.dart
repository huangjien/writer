import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/library/library_providers.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/services/storage_service.dart';
import 'package:writer/models/chapter_cache.dart';

void main() {
  group('LibraryProviders - downloadedNovelIdsProvider', () {
    test('returns empty set when no chapters are downloaded', () async {
      final mockStorage = MockStorageService();
      final mockRepo = LocalStorageRepository(mockStorage);

      final container = ProviderContainer(
        overrides: [localStorageRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final result = await container.read(downloadedNovelIdsProvider.future);
      expect(result, isEmpty);
    });

    test('returns novel IDs for downloaded chapters', () async {
      final mockStorage = MockStorageService();
      final mockRepo = LocalStorageRepository(mockStorage);

      // Add some downloaded chapters
      final chapter1 = ChapterCache(
        chapterId: 'c1',
        novelId: 'novel1',
        idx: 0,
        title: 'Chapter 1',
        content: 'Content 1',
        lastUpdated: DateTime.now(),
      );
      final chapter2 = ChapterCache(
        chapterId: 'c2',
        novelId: 'novel1',
        idx: 1,
        title: 'Chapter 2',
        content: 'Content 2',
        lastUpdated: DateTime.now(),
      );
      final chapter3 = ChapterCache(
        chapterId: 'c3',
        novelId: 'novel2',
        idx: 0,
        title: 'Chapter 3',
        content: 'Content 3',
        lastUpdated: DateTime.now(),
      );

      await mockRepo.saveChapter(chapter1);
      await mockRepo.saveChapter(chapter2);
      await mockRepo.saveChapter(chapter3);

      final container = ProviderContainer(
        overrides: [localStorageRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final result = await container.read(downloadedNovelIdsProvider.future);
      expect(result, contains('novel1'));
      expect(result, contains('novel2'));
      expect(result.length, 2);
    });

    test('handles chapters with missing novelId gracefully', () async {
      final mockStorage = MockStorageService();
      final mockRepo = LocalStorageRepository(mockStorage);

      // Add a chapter without novelId (malformed data)
      await mockStorage.setString(
        'chapter_malformed',
        jsonEncode({'chapterId': 'c1', 'title': 'Chapter 1'}),
      );

      // Add a valid chapter
      final validChapter = ChapterCache(
        chapterId: 'c2',
        novelId: 'novel1',
        idx: 0,
        title: 'Chapter 2',
        content: 'Content 2',
        lastUpdated: DateTime.now(),
      );
      await mockRepo.saveChapter(validChapter);

      final container = ProviderContainer(
        overrides: [localStorageRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final result = await container.read(downloadedNovelIdsProvider.future);
      expect(result, contains('novel1'));
      expect(result.length, 1);
    });

    test('handles corrupted chapter data gracefully', () async {
      final mockStorage = MockStorageService();
      final mockRepo = LocalStorageRepository(mockStorage);

      // Add corrupted chapter data
      await mockStorage.setString('chapter_corrupted', 'not valid json');
      await mockStorage.setString('chapter_corrupted2', '{invalid json}');

      final container = ProviderContainer(
        overrides: [localStorageRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final result = await container.read(downloadedNovelIdsProvider.future);
      expect(result, isEmpty);
    });

    test('updates when new chapters are added', () async {
      final mockStorage = MockStorageService();
      final mockRepo = LocalStorageRepository(mockStorage);

      final container = ProviderContainer(
        overrides: [localStorageRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      // Initially empty
      final result1 = await container.read(downloadedNovelIdsProvider.future);
      expect(result1, isEmpty);

      // Add a chapter
      final chapter = ChapterCache(
        chapterId: 'c1',
        novelId: 'novel1',
        idx: 0,
        title: 'Chapter 1',
        content: 'Content 1',
        lastUpdated: DateTime.now(),
      );
      await mockRepo.saveChapter(chapter);

      // Invalidate to trigger refresh
      container.invalidate(downloadedNovelIdsProvider);

      // Should now contain the novel ID
      final result2 = await container.read(downloadedNovelIdsProvider.future);
      expect(result2, contains('novel1'));
    });

    test('updates when chapters are removed', () async {
      final mockStorage = MockStorageService();
      final mockRepo = LocalStorageRepository(mockStorage);

      // Add a chapter
      final chapter = ChapterCache(
        chapterId: 'c1',
        novelId: 'novel1',
        idx: 0,
        title: 'Chapter 1',
        content: 'Content 1',
        lastUpdated: DateTime.now(),
      );
      await mockRepo.saveChapter(chapter);

      final container = ProviderContainer(
        overrides: [localStorageRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      // Should contain the novel ID
      final result1 = await container.read(downloadedNovelIdsProvider.future);
      expect(result1, contains('novel1'));

      // Remove the chapter
      await mockRepo.removeChapter('c1');

      // Invalidate to trigger refresh
      container.invalidate(downloadedNovelIdsProvider);

      // Should now be empty
      final result2 = await container.read(downloadedNovelIdsProvider.future);
      expect(result2, isEmpty);
    });
  });

  group('LibraryProviders - downloadStateProvider', () {
    test('has empty initial state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(downloadStateProvider), isEmpty);
    });

    test('can add download state for a novel', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(downloadStateProvider.notifier)
          .update((s) => {...s, 'novel1': true});

      expect(container.read(downloadStateProvider)['novel1'], isTrue);
    });

    test('can remove download state for a novel', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(downloadStateProvider.notifier)
          .update((s) => {...s, 'novel1': true, 'novel2': false});

      container
          .read(downloadStateProvider.notifier)
          .update((s) => {...s}..remove('novel1'));

      expect(
        container.read(downloadStateProvider).containsKey('novel1'),
        isFalse,
      );
      expect(
        container.read(downloadStateProvider).containsKey('novel2'),
        isTrue,
      );
    });

    test('can update multiple download states at once', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(downloadStateProvider.notifier)
          .update((s) => {'novel1': true, 'novel2': false, 'novel3': true});

      expect(container.read(downloadStateProvider).length, 3);
      expect(container.read(downloadStateProvider)['novel1'], isTrue);
      expect(container.read(downloadStateProvider)['novel2'], isFalse);
      expect(container.read(downloadStateProvider)['novel3'], isTrue);
    });

    test('can update download state for existing novel', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Add initial state
      container
          .read(downloadStateProvider.notifier)
          .update((s) => {...s, 'novel1': true});

      // Update state
      container
          .read(downloadStateProvider.notifier)
          .update((s) => {...s, 'novel1': false});

      expect(container.read(downloadStateProvider)['novel1'], isFalse);
    });
  });

  group('LibraryProviders - removedNovelIdsProvider', () {
    test('has empty initial state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(removedNovelIdsProvider), isEmpty);
    });

    test('can add novel ID to removed set', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(removedNovelIdsProvider.notifier)
          .update((s) => {...s, 'novel1'});

      expect(
        container.read(removedNovelIdsProvider).contains('novel1'),
        isTrue,
      );
    });

    test('can add multiple novel IDs to removed set', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(removedNovelIdsProvider.notifier)
          .update((s) => {...s, 'novel1', 'novel2', 'novel3'});

      expect(container.read(removedNovelIdsProvider).length, 3);
      expect(
        container.read(removedNovelIdsProvider).contains('novel1'),
        isTrue,
      );
      expect(
        container.read(removedNovelIdsProvider).contains('novel2'),
        isTrue,
      );
      expect(
        container.read(removedNovelIdsProvider).contains('novel3'),
        isTrue,
      );
    });

    test('can remove novel ID from removed set', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(removedNovelIdsProvider.notifier)
          .update((s) => {...s, 'novel1', 'novel2'});

      container
          .read(removedNovelIdsProvider.notifier)
          .update((s) => s..remove('novel1'));

      expect(
        container.read(removedNovelIdsProvider).contains('novel1'),
        isFalse,
      );
      expect(
        container.read(removedNovelIdsProvider).contains('novel2'),
        isTrue,
      );
    });

    test('handles duplicate additions gracefully', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Add the same novel ID multiple times
      container
          .read(removedNovelIdsProvider.notifier)
          .update((s) => {...s, 'novel1'});
      container
          .read(removedNovelIdsProvider.notifier)
          .update((s) => {...s, 'novel1'});
      container
          .read(removedNovelIdsProvider.notifier)
          .update((s) => {...s, 'novel1'});

      // Should only have one entry
      expect(container.read(removedNovelIdsProvider).length, 1);
      expect(
        container.read(removedNovelIdsProvider).contains('novel1'),
        isTrue,
      );
    });
  });

  group('LibraryProviders - downloadFeatureFlagProvider', () {
    test('returns false by default', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(downloadFeatureFlagProvider), isFalse);
    });

    test('can be overridden to true', () {
      final container = ProviderContainer(
        overrides: [downloadFeatureFlagProvider.overrideWithValue(true)],
      );
      addTearDown(container.dispose);

      expect(container.read(downloadFeatureFlagProvider), isTrue);
    });
  });

  group('LibraryProviders - Provider Interactions', () {
    test(
      'downloadStateProvider and removedNovelIdsProvider work independently',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Update download state
        container
            .read(downloadStateProvider.notifier)
            .update((s) => {...s, 'novel1': true});

        // Update removed IDs
        container
            .read(removedNovelIdsProvider.notifier)
            .update((s) => {...s, 'novel2'});

        // Both should have their own state
        expect(
          container.read(downloadStateProvider).containsKey('novel1'),
          isTrue,
        );
        expect(
          container.read(removedNovelIdsProvider).contains('novel1'),
          isFalse,
        );
        expect(
          container.read(downloadStateProvider).containsKey('novel2'),
          isFalse,
        );
        expect(
          container.read(removedNovelIdsProvider).contains('novel2'),
          isTrue,
        );
      },
    );

    test(
      'downloadedNovelIdsProvider is independent of downloadStateProvider',
      () async {
        final mockStorage = MockStorageService();
        final mockRepo = LocalStorageRepository(mockStorage);

        // Add a chapter to local storage
        final chapter = ChapterCache(
          chapterId: 'c1',
          novelId: 'novel1',
          idx: 0,
          title: 'Chapter 1',
          content: 'Content 1',
          lastUpdated: DateTime.now(),
        );
        await mockRepo.saveChapter(chapter);

        final container = ProviderContainer(
          overrides: [
            localStorageRepositoryProvider.overrideWithValue(mockRepo),
          ],
        );
        addTearDown(container.dispose);

        // downloadedNovelIdsProvider should contain novel1
        final downloadedIds = await container.read(
          downloadedNovelIdsProvider.future,
        );
        expect(downloadedIds, contains('novel1'));

        // downloadStateProvider should be empty (different state)
        expect(container.read(downloadStateProvider), isEmpty);
      },
    );
  });

  group('LibraryProviders - Edge Cases', () {
    test('handles empty novel ID in downloadStateProvider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(downloadStateProvider.notifier)
          .update((s) => {...s, '': true});

      expect(container.read(downloadStateProvider).containsKey(''), isTrue);
    });

    test('handles special characters in novel IDs', () async {
      final mockStorage = MockStorageService();
      final mockRepo = LocalStorageRepository(mockStorage);

      // Add chapters with special character IDs
      final chapter1 = ChapterCache(
        chapterId: 'c1',
        novelId: 'novel-1_with_special.chars',
        idx: 0,
        title: 'Chapter 1',
        content: 'Content 1',
        lastUpdated: DateTime.now(),
      );
      final chapter2 = ChapterCache(
        chapterId: 'c2',
        novelId: 'novel/2/path',
        idx: 0,
        title: 'Chapter 2',
        content: 'Content 2',
        lastUpdated: DateTime.now(),
      );

      await mockRepo.saveChapter(chapter1);
      await mockRepo.saveChapter(chapter2);

      final container = ProviderContainer(
        overrides: [localStorageRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final result = await container.read(downloadedNovelIdsProvider.future);
      expect(result, contains('novel-1_with_special.chars'));
      expect(result, contains('novel/2/path'));
    });

    test('handles very large number of downloaded novels', () async {
      final mockStorage = MockStorageService();
      final mockRepo = LocalStorageRepository(mockStorage);

      // Add many chapters for many novels
      for (int i = 0; i < 100; i++) {
        final chapter = ChapterCache(
          chapterId: 'c$i',
          novelId: 'novel$i',
          idx: 0,
          title: 'Chapter $i',
          content: 'Content $i',
          lastUpdated: DateTime.now(),
        );
        await mockRepo.saveChapter(chapter);
      }

      final container = ProviderContainer(
        overrides: [localStorageRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final result = await container.read(downloadedNovelIdsProvider.future);
      expect(result.length, 100);
    });

    test('handles mixed valid and invalid chapter data', () async {
      final mockStorage = MockStorageService();
      final mockRepo = LocalStorageRepository(mockStorage);

      // Add valid chapter
      final validChapter = ChapterCache(
        chapterId: 'c1',
        novelId: 'novel1',
        idx: 0,
        title: 'Chapter 1',
        content: 'Content 1',
        lastUpdated: DateTime.now(),
      );
      await mockRepo.saveChapter(validChapter);

      // Add invalid data
      await mockStorage.setString('chapter_invalid', 'not json');
      await mockStorage.setString(
        'chapter_no_novelid',
        jsonEncode({'chapterId': 'c2', 'title': 'Chapter 2'}),
      );
      await mockStorage.setString('other_key', 'some value');

      final container = ProviderContainer(
        overrides: [localStorageRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final result = await container.read(downloadedNovelIdsProvider.future);
      expect(result, contains('novel1'));
      expect(result.length, 1);
    });
  });
}

// Mock StorageService implementation
class MockStorageService implements StorageService {
  final Map<String, String> _data = {};

  @override
  String? getString(String key) {
    return _data[key];
  }

  @override
  Future<void> setString(String key, String? value) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<void> remove(String key) async {
    _data.remove(key);
  }

  @override
  Set<String> getKeys() {
    return _data.keys.toSet();
  }
}
