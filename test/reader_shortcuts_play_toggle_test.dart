import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/theme/themes.dart';
import 'package:writer/features/reader/reader_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'helpers/test_utils.dart';

void main() {
  group('RBK-002/003 Keyboard Space toggles Play/Stop', () {
    testWidgets('Cozy_layout_space_toggles_play_stop', (tester) async {
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

      final ctx = tester.element(find.byType(Scaffold));
      final l10n = AppLocalizations.of(ctx)!;
      final stopLabel = l10n.stopTTS;

      // Seed focus by tapping the actual Play control inside the Semantics labeled with Speak
      // Prefer the FilledButton used in cozy/regular layouts; fallback to IconButton for compact
      Finder playButton = find.byType(FilledButton);
      if (playButton.evaluate().isEmpty) {
        playButton = find.byType(IconButton);
      }
      // Ensure the reader bar Focus has primary focus
      final focusElt = tester.element(
        find.byKey(const ValueKey('reader_bar_focus')),
      );
      Focus.of(focusElt).requestFocus();
      await tester.pump();

      // Press Space to toggle to Stop; use key down/up for reliability
      await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.space);
      await tester.pump();
      Finder stopFinder = find.widgetWithText(FilledButton, stopLabel);
      if (stopFinder.evaluate().isEmpty) {
        stopFinder = find.widgetWithText(FilledButton, 'Stop');
      }
      if (stopFinder.evaluate().isEmpty) {
        stopFinder = find.byIcon(Icons.stop);
      }
      expect(stopFinder, findsOneWidget);

      // Stop here for single toggle verification in cozy layout
    });

    testWidgets('Regular_layout_space_toggles_play_stop', (tester) async {
      // Set viewport to regular (>= 720px)
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 800);
      addTearDown(() {
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

      final ctx = tester.element(find.byType(Scaffold));
      final l10n = AppLocalizations.of(ctx)!;
      final stopLabel = l10n.stopTTS;

      // Seed focus by tapping the actual Play control inside the Semantics labeled with Speak
      // Prefer the FilledButton used in cozy/regular layouts; fallback to IconButton for compact
      Finder playButton = find.byType(FilledButton);
      if (playButton.evaluate().isEmpty) {
        playButton = find.byType(IconButton);
      }
      // Reader bar should be present; next icon visible
      expect(find.byIcon(Icons.skip_next), findsOneWidget);
      // Ensure the reader bar Focus has primary focus
      final focusElt2 = tester.element(
        find.byKey(const ValueKey('reader_bar_focus')),
      );
      Focus.of(focusElt2).requestFocus();
      await tester.pump();

      // Press Space to toggle to Stop; use key down/up for reliability
      await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.space);
      await tester.pump();
      Finder regStopFinder = find.widgetWithText(FilledButton, stopLabel);
      if (regStopFinder.evaluate().isEmpty) {
        regStopFinder = find.widgetWithText(FilledButton, 'Stop');
      }
      if (regStopFinder.evaluate().isEmpty) {
        regStopFinder = find.byIcon(Icons.stop);
      }
      expect(regStopFinder, findsOneWidget);

      // Stop here for single toggle verification in regular layout
    });
  });
}
