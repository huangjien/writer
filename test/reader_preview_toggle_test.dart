import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/theme/themes.dart';
import 'package:writer/features/reader/reader_screen.dart';
import 'helpers/test_utils.dart';
import 'package:writer/state/edit_permissions.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'helpers/fake_chapter_port.dart';

void main() {
  testWidgets('Preview button enables when dirty and toggles panel', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final themeController = ThemeController(prefs);
    themeController.setFamily(AppThemeFamily.defaultFamily);

    final chapters = <Chapter>[
      const Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'One',
        content: 'Alpha\nBeta',
      ),
    ];

    final app = await buildAppScope(
      prefs: prefs,
      themeController: themeController,
      extraOverrides: [
        editRoleProvider.overrideWith((ref, novelId) async => EditRole.owner),
        chapterRepositoryProvider.overrideWithValue(FakeChapterPort()),
      ],
      child: materialAppFor(
        themeController: themeController,
        home: ChapterReaderScreen(
          chapterId: 'c1',
          title: 'One',
          content: 'Alpha\nBeta',
          novelId: 'n1',
          allChapters: chapters,
          currentIdx: 0,
          autoStartTts: false,
        ),
      ),
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    final previewBtn = find.byKey(const ValueKey('btn_preview'));
    expect(previewBtn, findsOneWidget);

    expect(tester.widget<IconButton>(previewBtn).onPressed, isNull);

    await tester.enterText(find.byType(TextFormField).first, 'Changed Title');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Alpha updated\nBeta',
    );
    await tester.pump();

    expect(tester.widget<IconButton>(previewBtn).onPressed, isNotNull);

    await tester.tap(previewBtn);
    await tester.pump();
    expect(find.byKey(const ValueKey('preview_row_0')), findsOneWidget);
    expect(find.byKey(const ValueKey('draft_cell_0')), findsOneWidget);
    expect(find.byKey(const ValueKey('orig_cell_0')), findsOneWidget);
    expect(find.byKey(const ValueKey('unchanged_cell_1')), findsOneWidget);
  });
}
