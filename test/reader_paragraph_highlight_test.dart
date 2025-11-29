import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/theme/themes.dart';
import 'package:writer/features/reader/reader_screen.dart';
import 'helpers/test_utils.dart';

void main() {
  group('Reader paragraph highlighting follows TTS index', () {
    testWidgets('Highlights first then second paragraph by initialTtsIndex', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final themeController = ThemeController(prefs);
      await themeController.setFamily(AppThemeFamily.defaultFamily);

      final chapters = <Chapter>[
        const Chapter(id: 'c1', novelId: 'n1', idx: 1, title: 'One'),
      ];

      final content = 'First paragraph line.\n\nSecond paragraph line.';
      final secondStartIndex =
          'First paragraph line.'.length + 2; // account for two newlines

      final app1 = await buildAppScope(
        prefs: prefs,
        themeController: themeController,
        child: materialAppFor(
          themeController: themeController,
          home: ChapterReaderScreen(
            chapterId: 'c1',
            title: 'Chapter 1',
            content: content,
            novelId: 'n1',
            allChapters: chapters,
            currentIdx: 0,
            initialTtsIndex: 0,
            autoStartTts: false,
          ),
        ),
      );

      await tester.pumpWidget(app1);
      await tester.pumpAndSettle();

      // First paragraph highlighted
      expect(find.byKey(const ValueKey('current_paragraph')), findsOneWidget);
      // Ensure it contains the first paragraph text
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('current_paragraph')),
          matching: find.textContaining('First paragraph'),
        ),
        findsOneWidget,
      );

      // Rebuild with initial index pointing into second paragraph
      final app2 = await buildAppScope(
        prefs: prefs,
        themeController: themeController,
        child: materialAppFor(
          themeController: themeController,
          home: ChapterReaderScreen(
            chapterId: 'c1',
            title: 'Chapter 1',
            content: content,
            novelId: 'n1',
            allChapters: chapters,
            currentIdx: 0,
            initialTtsIndex: secondStartIndex,
            autoStartTts: false,
          ),
        ),
      );

      await tester.pumpWidget(app2);
      await tester.pumpAndSettle();

      // Second paragraph highlighted
      expect(find.byKey(const ValueKey('current_paragraph')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('current_paragraph')),
          matching: find.textContaining('Second paragraph'),
        ),
        findsOneWidget,
      );
    });
  });
}
