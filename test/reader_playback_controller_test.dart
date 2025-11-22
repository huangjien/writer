import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/features/reader/logic/reader_playback_controller.dart';
import 'package:novel_reader/features/reader/logic/tts_driver.dart';
import 'package:novel_reader/state/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Use real AppSettingsNotifier with mock SharedPreferences

class FakeTtsDriver implements TtsDriver {
  void Function(int index)? _onProgress;
  void Function()? _onStart;
  void Function()? _onCancel;
  void Function(String message)? _onError;
  void Function()? _onAllComplete;
  @override
  bool get speaking => false;
  @override
  int get index => 0;

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
    _onCancel = onCancel;
    _onError = onError;
    _onAllComplete = onAllComplete;
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
  }) async {
    // Do nothing by default to simulate blocked autoplay
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> setLocale(String locale, {String? voiceName}) async {}

  // Test-only helpers
  void emitProgress(int idx) => _onProgress?.call(idx);
  void emitStart() => _onStart?.call();
  void emitCancel() => _onCancel?.call();
  void emitError(String msg) => _onError?.call(msg);
  void emitComplete() => _onAllComplete?.call();
}

void main() {
  testWidgets('tryAutoStart sets blocked and invokes prompt when no progress', (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final prefs = await SharedPreferences.getInstance();
    WidgetRef? captured;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              captured = ref;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    final fake = FakeTtsDriver();
    final ctrl = ReaderPlaybackController(fake, captured!);

    var blockedStates = <bool>[];
    var promptCount = 0;
    ctrl.tryAutoStart(
      content: 'hello world',
      startIndex: 0,
      setAutoplayBlocked: (b) => blockedStates.add(b),
      showAutoplayPrompt: () => promptCount += 1,
      onProgress: (_) {},
      onStart: () {},
      onCancel: () {},
      onError: (_) {},
      onComplete: () {},
    );

    await tester.pump(const Duration(seconds: 1));
    expect(blockedStates.isNotEmpty, true);
    expect(blockedStates.last, true);
    expect(promptCount, greaterThanOrEqualTo(1));
    ctrl.dispose();
  });

  testWidgets('progress unblocks autoplay and cancels retries', (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final prefs = await SharedPreferences.getInstance();
    WidgetRef? captured;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              captured = ref;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    final fake = FakeTtsDriver();
    final ctrl = ReaderPlaybackController(fake, captured!);

    var blockedStates = <bool>[];
    var promptCount = 0;
    ctrl.tryAutoStart(
      content: 'hello world',
      startIndex: 0,
      setAutoplayBlocked: (b) => blockedStates.add(b),
      showAutoplayPrompt: () => promptCount += 1,
      onProgress: (_) {},
      onStart: () {},
      onCancel: () {},
      onError: (_) {},
      onComplete: () {},
    );

    fake.emitProgress(5);
    await tester.pump(const Duration(seconds: 1));
    expect(blockedStates.isNotEmpty, true);
    expect(blockedStates.last, false);
    expect(promptCount, 0);
    ctrl.dispose();
  });
}