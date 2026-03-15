import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/recent_progress_details.dart';
import 'package:writer/models/user_progress.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/widgets/recent_chapters.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RecentChapters Widget Tests', () {
    testWidgets('RecentChaptersLoadingState shows CircularProgressIndicator', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: RecentChaptersLoadingState())),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('RecentChaptersEmptyState shows empty message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: RecentChaptersEmptyState()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('RecentChaptersErrorState shows error message', (tester) async {
      const testError = 'Test error message';

      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: RecentChaptersErrorState(error: testError)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('RecentChapters shows loading state', (tester) async {
      final testProvider = ProviderScope(
        overrides: [
          recentProgressDetailsProvider.overrideWithValue(
            const AsyncValue.loading(),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: RecentChapters())),
      );

      await tester.pumpWidget(testProvider);
      await tester.pump();

      expect(find.byType(RecentChaptersLoadingState), findsOneWidget);
    });

    testWidgets('RecentChapters shows empty state', (tester) async {
      final testProvider = ProviderScope(
        overrides: [
          recentProgressDetailsProvider.overrideWithValue(
            const AsyncValue.data([]),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: RecentChapters()),
        ),
      );

      await tester.pumpWidget(testProvider);
      await tester.pumpAndSettle();

      expect(find.byType(RecentChaptersEmptyState), findsOneWidget);
    });

    testWidgets('RecentChapters shows error state', (tester) async {
      final testProvider = ProviderScope(
        overrides: [
          recentProgressDetailsProvider.overrideWithValue(
            const AsyncValue.error('Test error', StackTrace.empty),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: RecentChapters()),
        ),
      );

      await tester.pumpWidget(testProvider);
      await tester.pumpAndSettle();

      expect(find.byType(RecentChaptersErrorState), findsOneWidget);
    });

    testWidgets('RecentChapters shows list with data', (tester) async {
      final testDetails = RecentProgressDetails(
        novel: const Novel(
          id: '1',
          title: 'Test Novel',
          languageCode: 'en',
          isPublic: true,
        ),
        chapter: const Chapter(
          id: '1',
          novelId: '1',
          idx: 1,
          title: 'Test Chapter',
          content: 'Content',
        ),
        userProgress: UserProgress(
          userId: 'user1',
          novelId: '1',
          chapterId: '1',
          scrollOffset: 0.0,
          ttsCharIndex: 0,
          updatedAt: DateTime.now(),
        ),
      );

      final testProvider = ProviderScope(
        overrides: [
          recentProgressDetailsProvider.overrideWithValue(
            AsyncValue.data([testDetails]),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(width: 400, height: 800, child: RecentChapters()),
          ),
        ),
      );

      await tester.pumpWidget(testProvider);
      await tester.pumpAndSettle();

      expect(find.byType(RecentChaptersList), findsOneWidget);
    });

    testWidgets('RecentChapterTile displays correct content', (tester) async {
      final testDetails = RecentProgressDetails(
        novel: const Novel(
          id: '1',
          title: 'Test Novel',
          languageCode: 'en',
          isPublic: true,
        ),
        chapter: const Chapter(
          id: '1',
          novelId: '1',
          idx: 1,
          title: 'Test Chapter',
          content: 'Content',
        ),
        userProgress: UserProgress(
          userId: 'user1',
          novelId: '1',
          chapterId: '1',
          scrollOffset: 0.0,
          ttsCharIndex: 0,
          updatedAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: RecentChapterTile(details: testDetails)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('Test Novel'), findsOneWidget);
    });
  });
}
