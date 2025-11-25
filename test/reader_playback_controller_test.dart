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
  testWidgets('tryAutoStart sets blocked and invokes prompt when no progress', (
    tester,
  ) async {
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

  group('Fallback Timer Logic', () {
    testWidgets(
      'Staleness check 1: 2000ms no progress + not speaking forces completion',
      (tester) async {
        SharedPreferences.setMockInitialValues(const {});
        final prefs = await SharedPreferences.getInstance();
        WidgetRef? captured;
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appSettingsProvider.overrideWith(
                (ref) => AppSettingsNotifier(prefs),
              ),
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

        // Override time
        var currentTime = DateTime.now();
        ctrl.nowProvider = () => currentTime;

        bool completed = false;
        await ctrl.start(
          content: 'hello world',
          startIndex: 0,
          onProgress: (_) {},
          onStart: () {},
          onCancel: () {},
          onError: (_) {},
          onComplete: () => completed = true,
        );

        // Initially speaking=false in fake driver.
        // Wait > 2000ms.
        // We advance time and pump
        currentTime = currentTime.add(const Duration(milliseconds: 2500));
        await tester.pump(const Duration(milliseconds: 3000));

        expect(completed, true);
        ctrl.dispose();
      },
    );

    testWidgets(
      'Staleness check 2: 3000ms stagnant index near end forces completion',
      (tester) async {
        SharedPreferences.setMockInitialValues(const {});
        final prefs = await SharedPreferences.getInstance();
        WidgetRef? captured;
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appSettingsProvider.overrideWith(
                (ref) => AppSettingsNotifier(prefs),
              ),
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

        var currentTime = DateTime.now();
        ctrl.nowProvider = () => currentTime;

        bool completed = false;
        // Short content
        final content = 'short content';
        final totalLen = ctrl.computeTotalLen(content, 0);

        await ctrl.start(
          content: content,
          startIndex: 0,
          onProgress: (_) {},
          onStart: () {},
          onCancel: () {},
          onError: (_) {},
          onComplete: () => completed = true,
        );

        // Simulate driver speaking and progress to near end
        fake.setSpeaking(true);
        // We need to trigger onProgress in controller to set _gotDriverProgress = true
        // and update _index and _lastIndexAt.

        // Emit progress near end (e.g. totalLen)
        fake.emitProgress(totalLen);

        // Update time slightly so it registers as "now"
        currentTime = currentTime.add(const Duration(milliseconds: 100));
        // Re-emit to update _lastIndexAt
        fake.emitProgress(totalLen);

        // Now wait > 3000ms with no further progress updates
        currentTime = currentTime.add(const Duration(milliseconds: 3500));
        await tester.pump(const Duration(milliseconds: 4000));

        expect(completed, true);
        ctrl.dispose();
      },
    );

    testWidgets('Session active flag: stop() cancels fallback timer effects', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(const {});
      final prefs = await SharedPreferences.getInstance();
      WidgetRef? captured;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsProvider.overrideWith(
              (ref) => AppSettingsNotifier(prefs),
            ),
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

      var currentTime = DateTime.now();
      ctrl.nowProvider = () => currentTime;

      bool completed = false;
      await ctrl.start(
        content: 'hello world',
        startIndex: 0,
        onProgress: (_) {},
        onStart: () {},
        onCancel: () {},
        onError: (_) {},
        onComplete: () => completed = true,
      );

      // Stop immediately
      await ctrl.stop();

      // Wait > 2000ms (which would trigger staleness check 1 if session was active)
      currentTime = currentTime.add(const Duration(milliseconds: 2500));
      await tester.pump(const Duration(milliseconds: 3000));

      expect(completed, false);
      ctrl.dispose();
    });
  });
}
