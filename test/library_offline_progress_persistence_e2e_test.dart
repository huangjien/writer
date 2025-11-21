import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novel_reader/features/reader/logic/tts_driver.dart';
import 'package:novel_reader/features/reader/chapter_reader_screen.dart';
import 'package:novel_reader/models/chapter.dart';
import 'helpers/test_utils.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Offline: Stop shows not-saved snackbar', (tester) async {
    final prefs = await SharedPreferences.getInstance();

    final chapters = <Chapter>[
      const Chapter(
        id: 'c1',
        novelId: 'novel-001',
        idx: 1,
        title: 'Into the Woods',
        content: 'A',
      ),
      const Chapter(
        id: 'c2',
        novelId: 'novel-001',
        idx: 2,
        title: 'The River',
        content: 'B',
      ),
    ];

    final scope = await buildAppScope(
      prefs: prefs,
      child: ProviderScope(
        overrides: [ttsDriverProvider.overrideWithValue(_FakeStartTtsDriver())],
        child: materialAppFor(
          home: ChapterReaderScreen(
            chapterId: 'c1',
            title: 'Into the Woods',
            content: 'A',
            novelId: 'novel-001',
            allChapters: chapters,
            currentIdx: 0,
          ),
        ),
      ),
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();

    expect(find.byTooltip('Speak'), findsOneWidget);
    await tester.tap(find.byTooltip('Speak'));
    await tester.pump();
    expect(find.byTooltip('Stop TTS'), findsOneWidget);
    await tester.tap(find.byTooltip('Stop TTS'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(
      find.text('Supabase not configured; progress not saved'),
      findsOneWidget,
    );

    await tester.pumpWidget(materialAppFor(home: const SizedBox.shrink()));
    await tester.pumpAndSettle();
  }, skip: true);
}

class _FakeStartTtsDriver extends TtsDriver {
  TtsFlag? _onStart;
  TtsFlag? _onCancel;
  // ignore: unused_field
  TtsError? _onError;
  // ignore: unused_field
  TtsFlag? _onAllComplete;

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
    _onStart = onStart;
    _onCancel = onCancel;
    _onError = onError;
    _onAllComplete = onAllComplete;
    // Immediately signal start to flip UI state to speaking.
    _onStart?.call();
  }

  @override
  Future<void> start({
    required String content,
    required int startIndex,
    int chunkMaxLen = 1200,
  }) async {}

  @override
  Future<void> stop() async {
    _onCancel?.call();
  }
}
