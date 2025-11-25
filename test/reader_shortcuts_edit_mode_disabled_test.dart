import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/features/reader/reader_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/repositories/chapter_port.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/state/chapter_edit_controller.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/theme/themes.dart';
import 'package:writer/state/edit_permissions.dart';

import 'helpers/test_utils.dart';

/// Minimal fake repository to satisfy ChapterEditController dependencies in tests.
class FakeChapterPort implements ChapterPort {
  @override
  Future<List<Chapter>> getChapters(String novelId) async => const [];

  @override
  Future<Chapter> getChapter(Chapter chapter) async => chapter;

  @override
  Future<void> updateChapter(Chapter chapter) async {}

  @override
  Future<int> getNextIdx(String novelId) async => 1;

  @override
  Future<Chapter> createChapter({
    required String novelId,
    required int idx,
    String? title,
    String? content,
  }) async {
    return Chapter(
      id: 'fake-$novelId-$idx',
      novelId: novelId,
      idx: idx,
      title: title ?? 'Chapter $idx',
      content: content ?? '',
    );
  }

  @override
  Future<void> deleteChapter(String chapterId) async {}
}

void main() {
  group('RBK-004 Shortcuts disabled in Edit Mode', () {
    testWidgets('ArrowRight does not advance chapter in Edit Mode', (
      tester,
    ) async {
      // Compact layout to avoid toolbar overflow and use icon controls
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(420, 800);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final themeController = ThemeController(prefs);
      themeController.setFamily(AppThemeFamily.defaultFamily);

      final chapters = <Chapter>[
        const Chapter(id: 'c1', novelId: 'n1', idx: 1, title: 'One'),
        const Chapter(id: 'c2', novelId: 'n1', idx: 2, title: 'Two'),
        const Chapter(id: 'c3', novelId: 'n1', idx: 3, title: 'Three'),
      ];

      final app = await buildAppScope(
        prefs: prefs,
        themeController: themeController,
        child: ProviderScope(
          overrides: [
            // Show Edit toggle regardless of Supabase state
            editPermissionsProvider.overrideWith((ref, novelId) async => true),
            // Avoid Supabase dependency when Edit Mode constructs controller
            chapterRepositoryProvider.overrideWithValue(FakeChapterPort()),
            // Stub ChapterEditController family to avoid reading repository from a mismatched container
            chapterEditControllerProvider.overrideWith(
              (ref, initial) =>
                  ChapterEditController(initial, FakeChapterPort()),
            ),
          ],
          child: materialAppFor(
            themeController: themeController,
            home: ChapterReaderScreen(
              chapterId: 'c2',
              title: 'Chapter 2',
              content:
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
              novelId: 'n1',
              allChapters: chapters,
              currentIdx: 1,
              autoStartTts: false,
            ),
          ),
        ),
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Verify starting chapter title
      expect(find.text('Chapter 2'), findsOneWidget);

      // Enter Edit Mode via the compact edit icon
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      // Ensure the reader bar Focus has primary focus
      final focusElt = tester.element(
        find.byKey(const ValueKey('reader_bar_focus')),
      );
      Focus.of(focusElt).requestFocus();
      await tester.pump();

      // Press ArrowRight; shortcuts should be disabled in Edit Mode
      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      // Title remains unchanged; no navigation occurred
      expect(find.text('Chapter 2'), findsOneWidget);
      expect(find.text('Three'), findsNothing);
    });

    testWidgets('Space does not toggle Play/Stop while in Edit Mode', (
      tester,
    ) async {
      // Compact layout to avoid toolbar overflow and use icon controls
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(420, 800);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final themeController = ThemeController(prefs);
      themeController.setFamily(AppThemeFamily.defaultFamily);

      final app = await buildAppScope(
        prefs: prefs,
        themeController: themeController,
        child: ProviderScope(
          overrides: [
            editPermissionsProvider.overrideWith((ref, novelId) async => true),
            chapterRepositoryProvider.overrideWithValue(FakeChapterPort()),
            chapterEditControllerProvider.overrideWith(
              (ref, initial) =>
                  ChapterEditController(initial, FakeChapterPort()),
            ),
          ],
          child: materialAppFor(
            themeController: themeController,
            home: const ChapterReaderScreen(
              chapterId: 'c1',
              title: 'Chapter 1',
              content: 'Hello world',
              novelId: 'n1',
              currentIdx: 0,
              autoStartTts: false,
            ),
          ),
        ),
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // In View mode, Play button should be visible
      expect(find.byKey(const ValueKey('btn_play')), findsOneWidget);

      // Enter Edit Mode via the compact edit icon
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      // Ensure Focus is on the reader bar
      final focusElt = tester.element(
        find.byKey(const ValueKey('reader_bar_focus')),
      );
      Focus.of(focusElt).requestFocus();
      await tester.pump();

      // Press Space; shortcuts are disabled in Edit Mode
      await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.space);
      await tester.pump();

      // Exit Edit Mode back to View via the close icon
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Play should remain available; Stop should not appear
      expect(find.byKey(const ValueKey('btn_play')), findsOneWidget);
      expect(find.byKey(const ValueKey('btn_stop')), findsNothing);
      expect(
        find.text(
          AppLocalizations.of(tester.element(find.byType(Scaffold)))!.stopTTS,
        ),
        findsNothing,
      );
    });

    testWidgets('R/V do not navigate to Settings while in Edit Mode', (
      tester,
    ) async {
      // Compact layout to avoid overflow and use icon-based Edit toggle
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(420, 800);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final themeController = ThemeController(prefs);
      themeController.setFamily(AppThemeFamily.defaultFamily);

      // Record navigation attempts
      final recordingObserver = _RecordingNavigatorObserver();

      // Minimal router with reader at root and a settings route
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const ChapterReaderScreen(
              chapterId: 'c1',
              title: 'Chapter 1',
              content: 'Hello world',
              novelId: 'n1',
              currentIdx: 0,
              autoStartTts: false,
            ),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Settings'))),
          ),
        ],
        observers: [recordingObserver],
      );

      final app = await buildAppScope(
        prefs: prefs,
        themeController: themeController,
        child: ProviderScope(
          overrides: [
            editPermissionsProvider.overrideWith((ref, novelId) async => true),
            chapterRepositoryProvider.overrideWithValue(FakeChapterPort()),
            chapterEditControllerProvider.overrideWith(
              (ref, initial) =>
                  ChapterEditController(initial, FakeChapterPort()),
            ),
          ],
          child: MaterialApp.router(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Enter Edit Mode via the compact edit icon
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      // Ensure Focus is on the reader bar
      final focusElt = tester.element(
        find.byKey(const ValueKey('reader_bar_focus')),
      );
      Focus.of(focusElt).requestFocus();
      await tester.pump();

      // Press R (Rate) and V (Voice); shortcuts disabled in Edit Mode
      final baselinePushCount = recordingObserver.pushCount;
      await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
      await tester.pumpAndSettle();

      // No additional navigation should have occurred
      expect(recordingObserver.pushCount, baselinePushCount);
    });
  });
}

class _RecordingNavigatorObserver extends NavigatorObserver {
  int pushCount = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushCount++;
    super.didPush(route, previousRoute);
  }
}
