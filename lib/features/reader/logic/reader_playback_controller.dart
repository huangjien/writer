import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/app_settings.dart';
import '../../../state/tts_settings.dart';
import 'tts_driver.dart';

typedef ProgressCb = void Function(int index);
typedef FlagCb = void Function();
typedef ErrorCb = void Function(String message);

class ReaderPlaybackController {
  final TtsDriver _driver;
  final WidgetRef _ref;
  Timer? _autoStartRetry;
  int _attempts = 0;
  bool _speaking = false;
  int _index = 0;
  final int _maxAttempts = 5;

  ReaderPlaybackController(this._driver, this._ref);

  Future<void> start({
    required String content,
    required int startIndex,
    required ProgressCb onProgress,
    required FlagCb onStart,
    required FlagCb onCancel,
    required ErrorCb onError,
    required FlagCb onComplete,
  }) async {
    final current = _ref.read(ttsSettingsProvider);
    final appLocale = _ref.read(appSettingsProvider);
    final mapped = switch (appLocale.languageCode) {
      'zh' => 'zh-CN',
      'en' => 'en-US',
      _ => 'en-US',
    };
    await _driver.configure(
      voiceName: current.voiceName,
      voiceLocale: current.voiceLocale,
      defaultLocale: mapped,
      onProgress: (i) {
        _index = i;
        _speaking = true;
        onProgress(i);
      },
      onStart: () {
        _speaking = true;
        onStart();
      },
      onCancel: () {
        _speaking = false;
        onCancel();
      },
      onError: (msg) {
        onError(msg);
      },
      onAllComplete: onComplete,
    );
    await _driver.setRate(current.rate);
    await _driver.setVolume(current.volume);
    await _driver.start(content: content, startIndex: startIndex);
  }

  void tryAutoStart({
    required String content,
    required int startIndex,
    required void Function(bool blocked) setAutoplayBlocked,
    required void Function() showAutoplayPrompt,
    required ProgressCb onProgress,
    required FlagCb onStart,
    required FlagCb onCancel,
    required ErrorCb onError,
    required FlagCb onComplete,
  }) {
    _attempts = 0;
    _autoStartRetry?.cancel();
    start(
      content: content,
      startIndex: startIndex,
      onProgress: onProgress,
      onStart: onStart,
      onCancel: onCancel,
      onError: onError,
      onComplete: onComplete,
    );
    _scheduleAutoStartRetry(
      content: content,
      startIndex: startIndex,
      setAutoplayBlocked: setAutoplayBlocked,
      showAutoplayPrompt: showAutoplayPrompt,
      onProgress: onProgress,
      onStart: onStart,
      onCancel: onCancel,
      onError: onError,
      onComplete: onComplete,
    );
  }

  void _scheduleAutoStartRetry({
    required String content,
    required int startIndex,
    required void Function(bool blocked) setAutoplayBlocked,
    required void Function() showAutoplayPrompt,
    required ProgressCb onProgress,
    required FlagCb onStart,
    required FlagCb onCancel,
    required ErrorCb onError,
    required FlagCb onComplete,
  }) {
    _autoStartRetry?.cancel();
    final delays = <Duration>[
      const Duration(seconds: 1),
      const Duration(seconds: 2),
      const Duration(seconds: 4),
      const Duration(seconds: 8),
      const Duration(seconds: 8),
    ];
    final idx = _attempts.clamp(0, delays.length - 1);
    final delay = delays[idx];
    _autoStartRetry = Timer(delay, () {
      final hasProgress = _index > 0;
      if (_speaking || hasProgress) {
        _autoStartRetry?.cancel();
        setAutoplayBlocked(false);
        return;
      }
      _attempts += 1;
      if (_attempts >= 1) {
        setAutoplayBlocked(true);
        showAutoplayPrompt();
      }
      if (_attempts > _maxAttempts) {
        _autoStartRetry?.cancel();
        return;
      }
      start(
        content: content,
        startIndex: startIndex,
        onProgress: onProgress,
        onStart: onStart,
        onCancel: onCancel,
        onError: onError,
        onComplete: onComplete,
      );
      _scheduleAutoStartRetry(
        content: content,
        startIndex: startIndex,
        setAutoplayBlocked: setAutoplayBlocked,
        showAutoplayPrompt: showAutoplayPrompt,
        onProgress: onProgress,
        onStart: onStart,
        onCancel: onCancel,
        onError: onError,
        onComplete: onComplete,
      );
    });
  }

  Future<void> stop() async {
    await _driver.stop();
    _speaking = false;
    _index = 0;
  }

  void dispose() {
    _autoStartRetry?.cancel();
  }
}
