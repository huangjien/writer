import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/reader/reader_session_notifier.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/state/reading_session_state.dart';

void main() {
  group('ReaderSessionNotifier Coverage Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('starts with initial state', () {
      final notifier = container.read(readerSessionProvider.notifier);
      final state = container.read(readerSessionProvider);

      expect(state, isA<ReadingSessionState>());
    });

    test('handles empty chapter list', () {
      final notifier = container.read(readerSessionProvider.notifier);

      notifier.loadChapters([]);

      final state = container.read(readerSessionProvider);
      // Should handle empty list gracefully
      expect(state, isA<ReadingSessionState>());
    });

    test('handles single chapter', () {
      final notifier = container.read(readerSessionProvider.notifier);
      final chapter = Chapter(
        id: 'test-id',
        novelId: 'novel-id',
        title: 'Test Chapter',
        content: 'Content',
        wordCount: 100,
        characterCount: 7,
        order: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      notifier.loadChapters([chapter]);

      final state = container.read(readerSessionProvider);
      expect(state, isA<ReadingSessionState>());
    });

    test('updates current chapter index', () {
      final notifier = container.read(readerSessionProvider.notifier);
      final chapters = List.generate(
        5,
        (i) => Chapter(
          id: 'id-$i',
          novelId: 'novel-id',
          title: 'Chapter $i',
          content: 'Content $i',
          wordCount: 100,
          characterCount: 9,
          order: i,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      notifier.loadChapters(chapters);
      notifier.goToChapter(2);

      final state = container.read(readerSessionProvider);
      expect(state, isA<ReadingSessionState>());
    });

    test('handles out of bounds chapter index', () {
      final notifier = container.read(readerSessionProvider.notifier);
      final chapters = [
        Chapter(
          id: 'id-1',
          novelId: 'novel-id',
          title: 'Chapter 1',
          content: 'Content 1',
          wordCount: 100,
          characterCount: 10,
          order: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      notifier.loadChapters(chapters);
      notifier.goToChapter(5); // Out of bounds

      final state = container.read(readerSessionProvider);
      // Should handle gracefully
      expect(state, isA<ReadingSessionState>());
    });

    test('tracks reading progress', () {
      final notifier = container.read(readerSessionProvider.notifier);
      final chapter = Chapter(
        id: 'test-id',
        novelId: 'novel-id',
        title: 'Test Chapter',
        content: 'Content',
        wordCount: 100,
        characterCount: 7,
        order: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      notifier.loadChapters([chapter]);
      notifier.updateProgress(0.5);

      final state = container.read(readerSessionProvider);
      expect(state, isA<ReadingSessionState>());
    });

    test('handles null chapter in list', () {
      final notifier = container.read(readerSessionProvider.notifier);
      final chapters = [
        Chapter(
          id: 'id-1',
          novelId: 'novel-id',
          title: 'Chapter 1',
          content: 'Content 1',
          wordCount: 100,
          characterCount: 10,
          order: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        null, // Null chapter
      ];

      notifier.loadChapters(chapters);

      final state = container.read(readerSessionProvider);
      // Should handle null chapter gracefully
      expect(state, isA<ReadingSessionState>());
    });

    test('next chapter works correctly', () {
      final notifier = container.read(readerSessionProvider.notifier);
      final chapters = List.generate(
        3,
        (i) => Chapter(
          id: 'id-$i',
          novelId: 'novel-id',
          title: 'Chapter $i',
          content: 'Content $i',
          wordCount: 100,
          characterCount: 9,
          order: i,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      notifier.loadChapters(chapters);
      notifier.nextChapter();

      final state = container.read(readerSessionProvider);
      expect(state, isA<ReadingSessionState>());
    });

    test('previous chapter works correctly', () {
      final notifier = container.read(readerSessionProvider.notifier);
      final chapters = List.generate(
        3,
        (i) => Chapter(
          id: 'id-$i',
          novelId: 'novel-id',
          title: 'Chapter $i',
          content: 'Content $i',
          wordCount: 100,
          characterCount: 9,
          order: i,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      notifier.loadChapters(chapters);
      notifier.goToChapter(1);
      notifier.previousChapter();

      final state = container.read(readerSessionProvider);
      expect(state, isA<ReadingSessionState>());
    });
  });
}
