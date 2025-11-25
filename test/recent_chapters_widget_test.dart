import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/widgets/recent_chapters.dart';
import 'package:writer/state/novel_providers.dart';
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
      title: 'T',
      author: 'A',
      description: 'D',
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    );
    const c = Chapter(
      id: 'c1',
      novelId: 'n1',
      idx: 1,
      title: 'X',
      content: 'Y',
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
        child: const MaterialApp(home: Scaffold(body: RecentChapters())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('T'), findsOneWidget);
    expect(find.textContaining('Chapter: X'), findsOneWidget);
  });
}
