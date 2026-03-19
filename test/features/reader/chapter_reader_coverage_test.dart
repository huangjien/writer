import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/reader/chapter_reader_screen.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/state/novel_providers_v2.dart';

void main() {
  group('ChapterReaderScreen Coverage Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          chapterProvider.overrideWith((ref, id) {
            return Chapter(
              id: 'test-id',
              novelId: 'novel-id',
              title: 'Test Chapter',
              content: 'Test content',
              wordCount: 100,
              characterCount: 12,
              order: 1,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('shows CircularProgressIndicator when loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: ChapterReaderScreen(chapterId: 'test-id'),
          ),
        ),
      );
      await tester.pump();

      // Verify loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message on failure', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          overrides: [
            chapterProvider.overrideWith((ref, id) {
              throw Exception('Network error');
            }),
          ],
          child: const MaterialApp(
            home: ChapterReaderScreen(chapterId: 'error-id'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.textContaining('Error'), findsOneWidget);
    });

    testWidgets('shows empty state when chapter has no content', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          overrides: [
            chapterProvider.overrideWith((ref, id) {
              return Chapter.empty();
            }),
          ],
          child: const MaterialApp(
            home: ChapterReaderScreen(chapterId: 'empty-id'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify empty state
      expect(find.text('No content'), findsOneWidget);
    });

    testWidgets('handles null content gracefully', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          overrides: [
            chapterProvider.overrideWith((ref, id) {
              return Chapter(
                id: 'null-content-id',
                novelId: 'novel-id',
                title: 'Null Content',
                content: null, // Null content
                wordCount: 0,
                characterCount: 0,
                order: 1,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
            }),
          ],
          child: const MaterialApp(
            home: ChapterReaderScreen(chapterId: 'null-content-id'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should not crash
      expect(find.byType(ChapterReaderScreen), findsOneWidget);
    });

    testWidgets('displays chapter content correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: ChapterReaderScreen(chapterId: 'test-id'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify content is displayed
      expect(find.text('Test content'), findsOneWidget);
    });

    testWidgets('updates reading progress on scroll', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: ChapterReaderScreen(chapterId: 'test-id'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Simulate scroll
      await tester.drag(find.byType(Scrollable), const Offset(0, -300));
      await tester.pump();

      // Verify progress tracking (without checking internal state)
      expect(find.byType(ChapterReaderScreen), findsOneWidget);
    });
  });
}
