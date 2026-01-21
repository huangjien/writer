import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/state/motion_settings.dart';
import 'helpers/test_utils.dart';
import 'package:writer/features/reader/chapter_reader_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Reader disables GestureDetector when gesturesEnabled is false', (
    tester,
  ) async {
    final previousOverride = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    final chapters = [
      const Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'Ch1',
        content: 'A',
      ),
      const Chapter(
        id: 'c2',
        novelId: 'n1',
        idx: 2,
        title: 'Ch2',
        content: 'B',
      ),
    ];

    final motion = MotionSettingsNotifier.lazy();
    motion.setGesturesEnabled(false);

    final app = await buildAppScope(
      extraOverrides: [motionSettingsProvider.overrideWith((ref) => motion)],
      child: materialAppFor(
        home: ChapterReaderScreen(
          chapterId: 'c1',
          title: 'Ch1',
          content: 'A',
          novelId: 'n1',
          allChapters: chapters,
          currentIdx: 0,
          autoStartTts: false,
        ),
      ),
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.text('Ch1'), findsOneWidget);
    // Ensure the main reader ListView is not wrapped by a GestureDetector.
    final listViewFinder = find.byType(ListView);
    expect(listViewFinder, findsOneWidget);
    final gestureAncestor = find.ancestor(
      of: listViewFinder,
      matching: find.byType(GestureDetector),
    );
    expect(gestureAncestor, findsNothing);

    debugDefaultTargetPlatformOverride = previousOverride;
  });
}
