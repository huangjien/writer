import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/library/library_screen.dart';
import 'package:writer/models/user_progress.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/progress_providers.dart';
import 'helpers/test_utils.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Golden: Determinate ring row (en)', (tester) async {
    final prevComparator = goldenFileComparator;
    goldenFileComparator = TolerantGoldenComparator(
      Platform.script,
      pixelDiffTolerance: 0.06,
    );
    addTearDown(() {
      goldenFileComparator = prevComparator;
    });
    // Standardize viewport for stable golden rendering (matches 768px width goldens)
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(768, 1200);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final prefs = await SharedPreferences.getInstance();

    // Known content length for deterministic ring value (e.g., 1000 chars).
    final chapterContent = List.filled(1000, 'x').join();

    final app = await buildAppScope(
      prefs: prefs,
      extraOverrides: [
        libraryNovelsProvider.overrideWith(
          (ref) async => [
            const Novel(
              id: 'novel-001',
              title: 'The Whispering Forest',
              author: 'A. Storyteller',
              description: 'A gentle adventure through a mysterious forest.',
              coverUrl: null,
              languageCode: 'en',
              isPublic: true,
            ),
          ],
        ),
        chaptersProvider.overrideWith(
          (ref, novelId) async => [
            const Chapter(
              id: 'chap-001-01',
              novelId: 'novel-001',
              idx: 1,
              title: 'Into the Woods',
              content: null,
            ),
            Chapter(
              id: 'chap-001-02',
              novelId: 'novel-001',
              idx: 2,
              title: 'Hidden Creek',
              content: chapterContent,
            ),
          ],
        ),
        lastProgressProvider.overrideWith(
          (ref, novelId) async => UserProgress(
            userId: 'u-1',
            novelId: 'novel-001',
            chapterId: 'chap-001-02',
            scrollOffset: 0.0,
            ttsCharIndex: 250,
            updatedAt: DateTime(2024, 1, 1),
          ),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Roboto',
          platform: TargetPlatform.android,
          visualDensity: VisualDensity.standard,
          listTileTheme: const ListTileThemeData(
            contentPadding: EdgeInsets.zero,
          ),
        ),
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(textScaler: TextScaler.noScaling),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const LibraryScreen(),
      ),
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    // Expect continue text for the resolved chapter.
    final continueText = find.text('Continue at chapter • Hidden Creek');
    expect(continueText, findsOneWidget);

    final firstTile = find.widgetWithText(ListTile, 'The Whispering Forest');
    expect(firstTile, findsOneWidget);
    final fullRowEn = find.ancestor(
      of: firstTile,
      matching: find.byWidgetPredicate(
        (w) =>
            w is Shortcuts &&
            w.shortcuts.containsKey(
              const SingleActivator(LogicalKeyboardKey.delete),
            ),
      ),
    );
    expect(fullRowEn, findsOneWidget);
    await expectLater(
      fullRowEn,
      matchesGoldenFile('goldens/library_determinate_ring_row_en.png'),
    );
  });

  testWidgets('Golden: Determinate ring row (zh)', (tester) async {
    final prevComparator = goldenFileComparator;
    goldenFileComparator = TolerantGoldenComparator(
      Platform.script,
      pixelDiffTolerance: 0.06,
    );
    addTearDown(() {
      goldenFileComparator = prevComparator;
    });
    // Standardize viewport for stable golden rendering (matches 768px width goldens)
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(768, 1200);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final prefs = await SharedPreferences.getInstance();

    final chapterContent = List.filled(1000, 'x').join();

    final app = await buildAppScope(
      prefs: prefs,
      extraOverrides: [
        libraryNovelsProvider.overrideWith(
          (ref) async => [
            const Novel(
              id: 'novel-001',
              title: 'The Whispering Forest',
              author: 'A. Storyteller',
              description: 'A gentle adventure through a mysterious forest.',
              coverUrl: null,
              languageCode: 'en',
              isPublic: true,
            ),
          ],
        ),
        chaptersProvider.overrideWith(
          (ref, novelId) async => [
            const Chapter(
              id: 'chap-001-01',
              novelId: 'novel-001',
              idx: 1,
              title: 'Into the Woods',
              content: null,
            ),
            Chapter(
              id: 'chap-001-02',
              novelId: 'novel-001',
              idx: 2,
              title: 'Hidden Creek',
              content: chapterContent,
            ),
          ],
        ),
        lastProgressProvider.overrideWith(
          (ref, novelId) async => UserProgress(
            userId: 'u-1',
            novelId: 'novel-001',
            chapterId: 'chap-001-02',
            scrollOffset: 0.0,
            ttsCharIndex: 250,
            updatedAt: DateTime(2024, 1, 1),
          ),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Roboto',
          platform: TargetPlatform.android,
          visualDensity: VisualDensity.standard,
          listTileTheme: const ListTileThemeData(
            contentPadding: EdgeInsets.zero,
          ),
        ),
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(textScaler: TextScaler.noScaling),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const LibraryScreen(),
      ),
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    final continueTextZh = find.text('继续阅读章节 • Hidden Creek');
    expect(continueTextZh, findsOneWidget);

    final firstTileZh = find.widgetWithText(ListTile, 'The Whispering Forest');
    expect(firstTileZh, findsOneWidget);
    final fullRowZh = find.ancestor(
      of: firstTileZh,
      matching: find.byWidgetPredicate(
        (w) =>
            w is Shortcuts &&
            w.shortcuts.containsKey(
              const SingleActivator(LogicalKeyboardKey.delete),
            ),
      ),
    );
    expect(fullRowZh, findsOneWidget);
    await expectLater(
      fullRowZh,
      matchesGoldenFile('goldens/library_determinate_ring_row_zh.png'),
    );
  });
}
