import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/reader/chapter_reader_screen.dart';
import 'package:writer/features/reader/logic/tts_driver.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/shared/widgets/neumorphic_button.dart';
import 'helpers/test_utils.dart';

class FakeTtsDriver extends TtsDriver {
  TtsProgress? _onProgress;
  TtsFlag? _onStart;
  var _firstStartAttempt = true;

  @override
  Future<void> configure({
    required String? voiceName,
    required String? voiceLocale,
    required String defaultLocale,
    TtsProgress? onProgress,
    TtsFlag? onStart,
    TtsFlag? onCancel,
    TtsError? onError,
    TtsFlag? onAllComplete,
  }) async {
    _onProgress = onProgress;
    _onStart = onStart;
  }

  @override
  Future<void> setRate(double rate) async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> start({
    required String content,
    required int startIndex,
    int chunkMaxLen = 1200,
    int baseTimeoutMs = 5000,
    int charTimeoutMs = 200,
  }) async {
    if (_firstStartAttempt) {
      _firstStartAttempt = false;
      return;
    }
    _onStart?.call();
    _onProgress?.call(startIndex);
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Autoplay inline Continue starts TTS and hides card', (
    tester,
  ) async {
    final oldPhysicalSize = tester.view.physicalSize;
    final oldDevicePixelRatio = tester.view.devicePixelRatio;
    addTearDown(() {
      tester.view.physicalSize = oldPhysicalSize;
      tester.view.devicePixelRatio = oldDevicePixelRatio;
    });
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;

    const chapters = [
      Chapter(id: 'c1', novelId: 'n1', idx: 1, title: 'Ch1', content: 'Hello'),
    ];

    final app = await buildAppScope(
      child: ProviderScope(
        overrides: [ttsDriverProvider.overrideWithValue(FakeTtsDriver())],
        child: materialAppFor(
          home: const ChapterReaderScreen(
            chapterId: 'c1',
            title: 'Ch1',
            content: 'Hello',
            novelId: 'n1',
            allChapters: chapters,
            currentIdx: 0,
            autoStartTts: true,
          ),
        ),
      ),
    );

    await tester.pumpWidget(app);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Auto-play is blocked by the browser. Tap Continue to start reading.',
      ),
      findsOneWidget,
    );

    final continueButton = find.descendant(
      of: find.byTooltip('Continue'),
      matching: find.byType(NeumorphicButton),
    );
    expect(continueButton, findsOneWidget);
    final onPressed = tester.widget<NeumorphicButton>(continueButton).onPressed;
    expect(onPressed, isNotNull);
    onPressed!.call();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(
      find.text(
        'Auto-play is blocked by the browser. Tap Continue to start reading.',
      ),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('btn_stop')), findsOneWidget);
  });
}
