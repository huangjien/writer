import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/reader/reader_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/state/novel_providers.dart';

class FakeChapterRepository implements ChapterRepository {
  @override
  Future<Chapter> createChapter({
    required String novelId,
    required int idx,
    String? title,
    String? content,
  }) async {
    return Chapter(
      id: 'c$idx',
      novelId: novelId,
      idx: idx,
      title: title,
      content: content,
    );
  }

  @override
  Future<void> deleteChapter(String chapterId) async {}

  @override
  Future<void> bulkShiftIdx(String novelId, int fromIdx, int delta) async {}

  @override
  Future<Chapter> getChapter(Chapter chapter) async => chapter;

  @override
  Future<List<Chapter>> getChapters(String novelId) async => <Chapter>[];

  @override
  Future<int> getNextIdx(String novelId) async => 1;

  @override
  Future<void> updateChapter(Chapter chapter) async {}

  @override
  Future<void> updateChapterIdx(String chapterId, int newIdx) async {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ReaderScreen refresh button shows and hides spinner', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chapterRepositoryProvider.overrideWithValue(FakeChapterRepository()),
          chaptersProvider.overrideWith(
            (ref, novelId) async => Future.delayed(
              const Duration(milliseconds: 50),
              () => [
                Chapter(
                  id: 'c1',
                  novelId: novelId,
                  idx: 1,
                  title: 'One',
                  content: 'Hello',
                ),
              ],
            ),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ReaderScreen(novelId: 'novel-001'),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 60));
    expect(find.byIcon(Icons.refresh), findsOneWidget);

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);

    await tester.pump(const Duration(milliseconds: 60));
    await tester.pump();

    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('ReaderScreen generates PDF without throwing', (tester) async {
    const MethodChannel printing = MethodChannel('net.nfet.printing');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(printing, (MethodCall methodCall) async {
          if (methodCall.method == 'sharePdf') {
            return true;
          }
          return null;
        });

    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(printing, null);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chapterRepositoryProvider.overrideWithValue(FakeChapterRepository()),
          chaptersProvider.overrideWith(
            (ref, novelId) async => Future.delayed(
              const Duration(milliseconds: 50),
              () => [
                Chapter(
                  id: 'c1',
                  novelId: novelId,
                  idx: 1,
                  title: 'One',
                  content: 'Hello',
                ),
              ],
            ),
          ),
          novelProvider.overrideWith(
            (ref, novelId) async => Novel(
              id: novelId,
              title: 'Test Novel',
              author: 'Author',
              description: null,
              coverUrl: null,
              languageCode: 'en',
              isPublic: true,
            ),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ReaderScreen(novelId: 'novel-001'),
        ),
      ),
    );

    expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);

    await tester.tap(find.byIcon(Icons.picture_as_pdf));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
    expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
  });
}
