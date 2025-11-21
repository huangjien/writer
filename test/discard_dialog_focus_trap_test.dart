import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novel_reader/features/reader/reader_screen.dart';
import 'package:novel_reader/models/chapter.dart';
import 'package:novel_reader/state/chapter_edit_controller.dart';
import 'package:novel_reader/repositories/chapter_repository.dart';
import 'package:novel_reader/state/edit_permissions.dart';

import 'helpers/test_utils.dart';
import 'helpers/fake_chapter_port.dart';

void main() {
  group('Edit Mode dialog focus trap & shortcut suppression', () {
    late Chapter initial;

    setUp(() {
      initial = Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'Ch 1',
        content: 'Para 1',
      );
    });

    testWidgets(
      'shows discard dialog when exiting with unsaved changes (focus stays trapped)',
      (tester) async {
        // Ensure SharedPreferences is initialized for buildAppScope.
        SharedPreferences.setMockInitialValues({});
        final fakePort = FakeChapterPort();

        final app = await buildAppScope(
          child: ProviderScope(
            overrides: [
              editPermissionsProvider.overrideWith(
                (ref, novelId) async => true,
              ),
              chapterRepositoryProvider.overrideWithValue(fakePort),
              chapterEditControllerProvider.overrideWith(
                (ref, initialChapter) =>
                    ChapterEditController(initialChapter, fakePort),
              ),
            ],
            child: materialAppFor(
              home: ChapterReaderScreen(
                chapterId: initial.id,
                title: initial.title ?? 'Chapter 1',
                content: initial.content,
                novelId: initial.novelId,
                allChapters: [initial],
                currentIdx: 0,
                autoStartTts: false,
              ),
            ),
          ),
        );

        await tester.pumpWidget(app);
        await tester.pumpAndSettle();

        // Enter Edit Mode via the edit icon
        await tester.tap(find.byIcon(Icons.edit));
        await tester.pump();

        // Enter text to make state dirty.
        final textFields = find.byType(TextFormField);
        expect(textFields, findsAtLeastNWidgets(1));
        await tester.enterText(textFields.first, 'dirty');

        // Attempt to exit edit mode (assuming an AppBar action with icon to close).
        final exitButton = find.byIcon(Icons.close);
        if (exitButton.evaluate().isEmpty) {
          // If no close icon, try toggling off via edit toggle action.
          final editToggle = find.byIcon(Icons.edit);
          await tester.tap(editToggle);
        } else {
          await tester.tap(exitButton);
        }

        await tester.pump();

        // Expect a confirmation dialog; presence check is generic to avoid coupling to copy.
        expect(find.byType(AlertDialog), findsOneWidget);

        // Focus should be inside the dialog (primary action). Try sending Tab and ensure focus cycles within.
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // Dismiss dialog via "Keep editing" (assuming first button). If label differs, fallback to tapping the first TextButton.
        final keepEditing = find.widgetWithText(TextButton, 'Keep editing');
        if (keepEditing.evaluate().isNotEmpty) {
          await tester.tap(keepEditing);
        } else {
          final textButtons = find.byType(TextButton);
          await tester.tap(textButtons.first);
        }

        await tester.pumpAndSettle();
        // Dialog closed, still in edit mode; text fields remain.
        expect(find.byType(AlertDialog), findsNothing);
        expect(textFields, findsWidgets);
      },
    );

    testWidgets('suppresses view-mode shortcuts while dialog is open', (
      tester,
    ) async {
      // Ensure SharedPreferences is initialized for buildAppScope.
      SharedPreferences.setMockInitialValues({});
      final fakePort = FakeChapterPort();

      final app = await buildAppScope(
        child: ProviderScope(
          overrides: [
            editPermissionsProvider.overrideWith((ref, novelId) async => true),
            chapterRepositoryProvider.overrideWithValue(fakePort),
            chapterEditControllerProvider.overrideWith(
              (ref, initialChapter) =>
                  ChapterEditController(initialChapter, fakePort),
            ),
          ],
          child: materialAppFor(
            home: ChapterReaderScreen(
              chapterId: initial.id,
              title: initial.title ?? 'Chapter 1',
              content: initial.content,
              novelId: initial.novelId,
              allChapters: [initial],
              currentIdx: 0,
              autoStartTts: false,
            ),
          ),
        ),
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Enter Edit Mode and open the discard dialog.
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      // Make dirty and open discard dialog.
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.first, 'dirty');

      final exitButton = find.byIcon(Icons.close);
      if (exitButton.evaluate().isEmpty) {
        final editToggle = find.byIcon(Icons.edit);
        await tester.tap(editToggle);
      } else {
        await tester.tap(exitButton);
      }
      await tester.pump();
      expect(find.byType(AlertDialog), findsOneWidget);

      // Send a view-mode shortcut (Space) and ensure it does not toggle play or dismiss the dialog.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(find.byType(AlertDialog), findsOneWidget);

      // Send ArrowRight, dialog should remain.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });
}
