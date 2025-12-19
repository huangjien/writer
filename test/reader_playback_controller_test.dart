import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/reader/logic/reader_playback_controller.dart';
import 'package:writer/features/reader/logic/tts_driver.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Use real AppSettingsNotifier with mock SharedPreferences

class FakeTtsDriver implements TtsDriver {
  void Function(int index)? _onProgress;
  void Function()? _onStart;
  void Function()? _onCancel;
  void Function(String message)? _onError;
  void Function()? _onAllComplete;

  bool _speaking = false;
  int _index = 0;

  @override
  bool get speaking => _speaking;

  void setSpeaking(bool value) {
    _speaking = value;
  }

  @override
  int get index => _index;

  void setIndex(int value) {
    _index = value;
  }

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
    int baseTimeoutMs = 5000,
    int charTimeoutMs = 200,
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

final refProvider = Provider((ref) => ref);

void main() {
  testWidgets('tryAutoStart sets blocked and invokes prompt when no progress', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const {});
    final prefs = await SharedPreferences.getInstance();
    Ref? captured;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              captured = ref.read(refProvider);
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
    Ref? captured;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              captured = ref.read(refProvider);
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
