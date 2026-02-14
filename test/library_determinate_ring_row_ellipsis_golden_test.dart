import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/features/library/screens/library_screen.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/user_progress.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/novel_providers_v2.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'helpers/test_utils.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  setUpAll(() async {
    await ensureTestFontsLoaded();
  });

  testWidgets('Golden: Determinate ellipsis row (en)', (tester) async {
    final prevComparator = goldenFileComparator;
    goldenFileComparator = TolerantGoldenComparator(
      Platform.script,
      pixelDiffTolerance: 0.12,
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

    // Very long chapter title to force ellipsis at typical widths
    const longTitle =
        'Hidden Creek with an Exceedingly Long Title That Surely Ellipsizes When Space Is Limited';

    final novels = [
      const Novel(
        id: 'n-1',
        title: 'The Whispering Forest',
        author: 'A. Storyteller',
        description: 'A gentle adventure through a mysterious forest.',
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
    ];

    final chapters = [
      const Chapter(
        id: 'c-1',
        novelId: 'n-1',
        idx: 1,
        title: 'Into the Woods',
        content: null,
      ),
      // Provide long content to compute a determinate ring value
      Chapter(
        id: 'c-2',
        novelId: 'n-1',
        idx: 2,
        title: longTitle,
        content: List.filled(2000, 'x').join(),
      ),
    ];

    final appNotifier = AppSettingsNotifier(prefs);
    final themeController = ThemeController(prefs);
    final storageService = LocalStorageService(prefs);

    // Single ProviderScope with all overrides to avoid nested scopes.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => appNotifier),
          themeControllerProvider.overrideWith((_) => themeController),
          libraryNovelsProviderV2.overrideWith((ref) async => novels),
          chaptersProviderV2.overrideWith((ref, novelId) async => chapters),
          lastProgressProvider.overrideWith((ref, novelId) async {
            return UserProgress(
              userId: 'u-1',
              novelId: novelId,
              chapterId: 'c-2',
              scrollOffset: 0.0,
              ttsCharIndex: 500,
              updatedAt: DateTime(2024, 1, 1),
            );
          }),
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWithValue(
            LocalStorageRepository(storageService),
          ),
          sessionProvider.overrideWith(
            (ref) => SessionNotifier(storageService),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Roboto',
            fontFamilyFallback: const ['Noto Sans SC', 'Noto Sans'],
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
      ),
    );

    await tester.pumpAndSettle();

    final firstTile = find.widgetWithText(ListTile, 'The Whispering Forest');
    expect(firstTile, findsOneWidget);

    // Capture the full row (Actions ancestor) for consistent 768px width
    final fullRowEn = find.ancestor(
      of: firstTile,
      matching: find.byWidgetPredicate(
        (w) =>
            w is Shortcuts &&
            w.shortcuts.length == 3 &&
            w.shortcuts.containsKey(
              const SingleActivator(LogicalKeyboardKey.keyD),
            ) &&
            w.shortcuts.containsKey(
              const SingleActivator(LogicalKeyboardKey.enter),
            ) &&
            w.shortcuts.containsKey(
              const SingleActivator(LogicalKeyboardKey.delete),
            ),
      ),
    );
    expect(fullRowEn, findsOneWidget);
    await expectLater(
      fullRowEn,
      matchesGoldenFile('goldens/library_determinate_ring_row_ellipsis_en.png'),
    );
  });

  testWidgets('Golden: Determinate ellipsis row (zh)', (tester) async {
    final prevComparator = goldenFileComparator;
    goldenFileComparator = TolerantGoldenComparator(
      Platform.script,
      pixelDiffTolerance: 0.12,
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

    const longTitle =
        'Hidden Creek with an Exceedingly Long Title That Surely Ellipsizes When Space Is Limited';

    final novels = [
      const Novel(
        id: 'n-1',
        title: 'The Whispering Forest',
        author: 'A. Storyteller',
        description: 'A gentle adventure through a mysterious forest.',
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
    ];

    final chapters = [
      const Chapter(
        id: 'c-1',
        novelId: 'n-1',
        idx: 1,
        title: 'Into the Woods',
        content: null,
      ),
      Chapter(
        id: 'c-2',
        novelId: 'n-1',
        idx: 2,
        title: longTitle,
        content: List.filled(2000, 'x').join(),
      ),
    ];

    final appNotifier = AppSettingsNotifier(prefs);
    final themeController = ThemeController(prefs);
    final storageService = LocalStorageService(prefs);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => appNotifier),
          themeControllerProvider.overrideWith((_) => themeController),
          libraryNovelsProviderV2.overrideWith((ref) async => novels),
          chaptersProviderV2.overrideWith((ref, novelId) async => chapters),
          lastProgressProvider.overrideWith((ref, novelId) async {
            return UserProgress(
              userId: 'u-1',
              novelId: novelId,
              chapterId: 'c-2',
              scrollOffset: 0.0,
              ttsCharIndex: 500,
              updatedAt: DateTime(2024, 1, 1),
            );
          }),
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWithValue(
            LocalStorageRepository(storageService),
          ),
          sessionProvider.overrideWith(
            (ref) => SessionNotifier(storageService),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Roboto',
            fontFamilyFallback: const ['Noto Sans SC', 'Noto Sans'],
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
      ),
    );

    await tester.pumpAndSettle();

    final firstTile = find.widgetWithText(ListTile, 'The Whispering Forest');
    expect(firstTile, findsOneWidget);
    // Capture the full row (Actions ancestor) for consistent 768px width
    final fullRowZh = find.ancestor(
      of: firstTile,
      matching: find.byWidgetPredicate(
        (w) =>
            w is Shortcuts &&
            w.shortcuts.length == 3 &&
            w.shortcuts.containsKey(
              const SingleActivator(LogicalKeyboardKey.keyD),
            ) &&
            w.shortcuts.containsKey(
              const SingleActivator(LogicalKeyboardKey.enter),
            ) &&
            w.shortcuts.containsKey(
              const SingleActivator(LogicalKeyboardKey.delete),
            ),
      ),
    );
    expect(fullRowZh, findsOneWidget);
    await expectLater(
      fullRowZh,
      matchesGoldenFile('goldens/library_determinate_ring_row_ellipsis_zh.png'),
    );
  });
}
