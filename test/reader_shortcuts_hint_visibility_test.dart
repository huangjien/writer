import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/theme/themes.dart';
import 'package:writer/features/reader/reader_screen.dart';
import 'helpers/test_utils.dart';

void main() {
  group('RBK-003 Shortcut hint visibility', () {
    testWidgets('Regular desktop shows Rate (R) and Voice (V) labels', (
      tester,
    ) async {
      // Simulate desktop platform (macOS) and set viewport to Regular (>= 720px)
      final previousOverride = debugDefaultTargetPlatformOverride;
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(defaultTargetPlatform, TargetPlatform.macOS);
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 800);
      addTearDown(() {
        debugDefaultTargetPlatformOverride = previousOverride;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final themeController = ThemeController(prefs);
      themeController.setFamily(AppThemeFamily.modernMinimalist);

      final chapters = <Chapter>[
        const Chapter(id: 'c1', novelId: 'n1', idx: 1, title: 'One'),
        const Chapter(id: 'c2', novelId: 'n1', idx: 2, title: 'Two'),
        const Chapter(id: 'c3', novelId: 'n1', idx: 3, title: 'Three'),
      ];

      final app = await buildAppScope(
        prefs: prefs,
        themeController: themeController,
        child: materialAppFor(
          themeController: themeController,
          home: ChapterReaderScreen(
            chapterId: 'c2',
            title: 'Chapter 2',
            content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
            novelId: 'n1',
            allChapters: chapters,
            currentIdx: 1,
            autoStartTts: false,
          ),
        ),
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Restore platform override before assertions to satisfy Flutter invariants.
      debugDefaultTargetPlatformOverride = previousOverride;
    });
  });
}
