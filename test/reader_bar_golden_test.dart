import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/theme/themes.dart';
import 'package:writer/features/reader/reader_screen.dart';
import 'helpers/test_utils.dart';

void main() {
  late GoldenFileComparator prevComparator;
  setUpAll(() {
    prevComparator = goldenFileComparator;
    goldenFileComparator = TolerantGoldenComparator(
      Platform.script,
      pixelDiffTolerance: 0.03,
    );
  });
  tearDownAll(() {
    goldenFileComparator = prevComparator;
  });
  group('RBK-001 Compact Layout', () {
    testWidgets('ReaderBarCompact_layout_golden', (tester) async {
      // Set viewport to compact (< 480px)
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(470, 800);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final themeController = ThemeController(prefs);
      await themeController.setFamily(AppThemeFamily.defaultFamily);

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

      final bar = find.byKey(const ValueKey('reader_bottom_bar'));
      expect(bar, findsOneWidget);

      await expectLater(
        bar,
        matchesGoldenFile('goldens/reader_bar_compact.png'),
      );
    });
    testWidgets(
      'ReaderBarCompact_tapTargets_200',
      (tester) async {},
      skip: true,
    );
    testWidgets(
      'ReaderBarCompact_accessibility_sr',
      (tester) async {},
      skip: true,
    );
  });

  group('RBK-002 Cozy Layout', () {
    testWidgets('ReaderBarCozy_labels_density', (tester) async {
      // Set viewport to cozy (>= 480px and < 720px)
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(600, 800);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final themeController = ThemeController(prefs);
      await themeController.setFamily(AppThemeFamily.defaultFamily);

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

      // Cozy layout uses icon-only buttons
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.text('Speak'), findsNothing);
    });
    testWidgets(
      'ReaderBarCozy_shortcuts_space_r_v',
      (tester) async {},
      skip: true,
    );
  });

  group('RBK-003 Regular Layout', () {
    testWidgets('ReaderBarRegular_layout_golden', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 600);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Use default theme family; width 800 -> Regular layout
      final themeController = ThemeController(prefs);
      await themeController.setFamily(AppThemeFamily.defaultFamily);

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

      // Capture the bottom SafeArea containing the reader bar.
      final bar = find.byKey(const ValueKey('reader_bottom_bar'));
      expect(bar, findsOneWidget);

      await expectLater(
        bar,
        matchesGoldenFile('goldens/reader_bar_regular.png'),
      );
    });

    testWidgets('ReaderBarRegular_progress_percentage', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final themeController = ThemeController(prefs);
      await themeController.setFamily(AppThemeFamily.defaultFamily);

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

      // Default progress is 0%, should be visible in regular layout
      expect(find.text('0%'), findsOneWidget);
    });
  });
}
