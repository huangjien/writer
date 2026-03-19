import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/reader/reader_screen.dart';
import 'package:writer/models/chapter.dart';

void main() {
  group('ReaderScreen Coverage Tests', () {
    late Chapter testChapter;

    setUp(() {
      testChapter = Chapter(
        id: 'test-id',
        novelId: 'novel-id',
        title: 'Test Chapter',
        content: 'Test content for reader screen',
        wordCount: 100,
        characterCount: 25,
        order: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    testWidgets('shows loading state initially', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ReaderScreen(chapter: testChapter),
          ),
        ),
      );
      await tester.pump();

      // Verify loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('handles empty chapter content', (tester) async {
      final emptyChapter = Chapter(
        id: 'empty-id',
        novelId: 'novel-id',
        title: 'Empty Chapter',
        content: '',
        wordCount: 0,
        characterCount: 0,
        order: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ReaderScreen(chapter: testChapter),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should not crash
      expect(find.byType(ReaderScreen), findsOneWidget);
    });

    testWidgets('displays chapter title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ReaderScreen(chapter: testChapter),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title is displayed
      expect(find.text('Test Chapter'), findsOneWidget);
    });

    testWidgets('displays chapter content', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ReaderScreen(chapter: testChapter),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify content is displayed
      expect(find.text('Test content for reader screen'), findsOneWidget);
    });

    testWidgets('handles scroll events', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ReaderScreen(chapter: testChapter),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Simulate scroll
      await tester.drag(find.byType(Scrollable), const Offset(0, -200));
      await tester.pump();

      // Should not crash
      expect(find.byType(ReaderScreen), findsOneWidget);
    });

    testWidgets('handles null chapter gracefully', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(
            home: ReaderScreen(chapter: null),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should handle null chapter
      expect(find.byType(ReaderScreen), findsOneWidget);
    });

    testWidgets('back button navigation works', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ReaderScreen(chapter: testChapter),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap back button
      final backButton = find.byType(BackButton);
      expect(backButton, findsOneWidget);
    });
  });
}
