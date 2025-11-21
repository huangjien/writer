import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novel_reader/models/chapter.dart';
import 'package:novel_reader/state/motion_settings.dart';
import 'helpers/test_utils.dart';
import 'package:novel_reader/features/reader/chapter_reader_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Horizontal swipe respects min velocity threshold', (
    tester,
  ) async {
    final previousOverride = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    final chapters = [
      Chapter(id: 'c1', novelId: 'n1', idx: 1, title: 'Ch1', content: 'A'),
      Chapter(id: 'c2', novelId: 'n1', idx: 2, title: 'Ch2', content: 'B'),
    ];

    final fixedMotion = MotionSettingsNotifier.lazy();
    fixedMotion.setSwipeMinVelocity(200.0);

    final app = await buildAppScope(
      extraOverrides: [
        motionSettingsProvider.overrideWith((ref) => fixedMotion),
      ],
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

    final detector = tester.widget<GestureDetector>(
      find.byType(GestureDetector).first,
    );

    detector.onHorizontalDragEnd?.call(
      DragEndDetails(
        primaryVelocity: 150,
        velocity: const Velocity(pixelsPerSecond: Offset(150, 0)),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Ch1'),
      findsOneWidget,
      reason: 'Below threshold should not navigate',
    );

    detector.onHorizontalDragEnd?.call(
      DragEndDetails(
        primaryVelocity: -300,
        velocity: const Velocity(pixelsPerSecond: Offset(-300, 0)),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Ch2'),
      findsOneWidget,
      reason: 'Swipe left (negative) should go next',
    );

    detector.onHorizontalDragEnd?.call(
      DragEndDetails(
        primaryVelocity: 300,
        velocity: const Velocity(pixelsPerSecond: Offset(300, 0)),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Ch1'),
      findsOneWidget,
      reason: 'Swipe right (positive) should go prev',
    );

    debugDefaultTargetPlatformOverride = previousOverride;
  });
}
