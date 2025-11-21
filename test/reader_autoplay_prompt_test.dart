import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:novel_reader/models/chapter.dart';
import 'package:novel_reader/features/reader/chapter_reader_screen.dart';
import 'package:novel_reader/features/reader/logic/tts_driver.dart';
import 'helpers/test_utils.dart';

class FakeTtsDriver extends TtsDriver {
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
  }) async {}

  @override
  Future<void> setRate(double rate) async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> start({
    required String content,
    required int startIndex,
    int chunkMaxLen = 1200,
  }) async {}
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Auto-play blocked shows SnackBar and inline card', (
    tester,
  ) async {
    final chapters = [
      const Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'Ch1',
        content: 'A',
      ),
    ];

    final app = await buildAppScope(
      child: ProviderScope(
        overrides: [ttsDriverProvider.overrideWithValue(FakeTtsDriver())],
        child: materialAppFor(
          home: ChapterReaderScreen(
            chapterId: 'c1',
            title: 'Ch1',
            content: 'A',
            novelId: 'n1',
            allChapters: chapters,
            currentIdx: 0,
            autoStartTts: true,
          ),
        ),
      ),
    );

    await tester.pumpWidget(app);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(
      find.text('Auto-play blocked. Tap Continue to start.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Auto-play is blocked by the browser. Tap Continue to start reading.',
      ),
      findsOneWidget,
    );
  });
}
