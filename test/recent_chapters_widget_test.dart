import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/widgets/recent_chapters.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/models/user_progress.dart';
import 'package:writer/models/recent_progress_details.dart';

void main() {
  testWidgets('RecentChapters shows list of recent items', (tester) async {
    final p = UserProgress(
      userId: 'u',
      novelId: 'n1',
      chapterId: 'c1',
      scrollOffset: 0,
      ttsCharIndex: 0,
      updatedAt: DateTime.utc(2024, 1, 1),
    );
    final n = Novel(
      id: 'n1',
      title: 'Sample Novel',
      author: 'Author',
      description: 'Desc',
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    );
    const c = Chapter(
      id: 'c1',
      novelId: 'n1',
      idx: 1,
      title: 'Chapter One',
      content: 'Content',
    );
    final details = RecentProgressDetails(
      userProgress: p,
      novel: n,
      chapter: c,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recentProgressDetailsProvider.overrideWith((ref) async => [details]),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: RecentChapters()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sample Novel'), findsOneWidget);
    expect(find.textContaining('Chapter: Chapter One'), findsOneWidget);
  });

  testWidgets('RecentChapters shows empty message when no data', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recentProgressDetailsProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: RecentChapters()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No recent chapters'), findsOneWidget);
  });

  testWidgets('RecentChapters shows loading indicator initially', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recentProgressDetailsProvider.overrideWith((ref) {
            return Future.delayed(const Duration(seconds: 1), () => []);
          }),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: RecentChapters()),
        ),
      ),
    );
    // Initial pump (loading state)
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Finish future
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('RecentChapters shows error message on failure', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recentProgressDetailsProvider.overrideWith(
            (ref) async => throw Exception('Failed'),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: RecentChapters()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Error: Exception: Failed'), findsOneWidget);
  });
}
