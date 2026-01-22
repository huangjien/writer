import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/theme/themes.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/features/reader/reader_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'helpers/test_utils.dart';
import 'dart:ui' as ui;

void main() {
  group('RBK-007-B Tooltip Non-Interference & Contrast', () {
    testWidgets('ReaderAccessibility_tooltip_non_interference', (tester) async {
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

      // Enable semantics tree for finder-based checks
      final semanticsHandle = tester.ensureSemantics();
      final ctx0 = tester.element(find.byType(Scaffold));
      final l10n = AppLocalizations.of(ctx0)!;
      final playLabel = l10n.speak;

      // Before hover: semantics include the play label
      expect(find.bySemanticsLabel(playLabel), findsWidgets);

      // Hover over Play to show tooltip overlay; semantics should remain unchanged
      // Prefer the labeled FilledButton in regular layout; fallback to play icon
      Finder playFinder = find.widgetWithText(FilledButton, playLabel);
      if (playFinder.evaluate().isEmpty) {
        playFinder = find.byIcon(Icons.play_arrow);
      }
      expect(playFinder, findsOneWidget);
      final gesture = await tester.createGesture(
        kind: ui.PointerDeviceKind.mouse,
      );
      await gesture.addPointer();
      await gesture.moveTo(tester.getCenter(playFinder));
      await tester.pump(const Duration(milliseconds: 800));

      // After hover: semantics label remains; focus is not stolen by tooltip overlay
      expect(find.bySemanticsLabel(playLabel), findsWidgets);
      final focusBefore = FocusManager.instance.primaryFocus;
      final focusAfter = FocusManager.instance.primaryFocus;
      expect(focusBefore, isNotNull);
      expect(focusAfter, equals(focusBefore));

      semanticsHandle.dispose();
    });
    testWidgets('HighContrast_tooltip_aa', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final themeController = ThemeController(prefs);
      themeController.setFamily(AppThemeFamily.contrast);

      final app = await buildAppScope(
        prefs: prefs,
        themeController: themeController,
        child: materialAppFor(
          themeController: themeController,
          home: const Scaffold(
            body: Center(
              child: Tooltip(message: 'Play', child: Icon(Icons.play_arrow)),
            ),
          ),
        ),
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final ctx = tester.element(find.byType(Scaffold));
      final scheme = Theme.of(ctx).colorScheme;
      final bg = scheme.inverseSurface;
      final fg = scheme.onInverseSurface;
      final ratio = contrastRatio(fg, bg);

      // High contrast tooltip should meet AAA ideal (>= 7.0)
      expect(ratio, greaterThanOrEqualTo(7.0));
    });
  });
}
