import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/app_settings.dart';
import '../../../state/tts_settings.dart';
import 'tts_driver.dart';
import '../tts_chunker.dart';

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
  int _totalLen = 0;
  int _lastIndex = 0;

  @visibleForTesting
  DateTime Function() nowProvider = () => DateTime.now();

  int computeTotalLen(String content, int startIndex) {
    final base = startIndex.clamp(0, content.length);
    final remaining = content.substring(base);
    final chunks = chunkText(remaining);
    final spokenLen = chunks.fold<int>(0, (sum, s) => sum + s.length);
    return base + spokenLen;
  }

  int get totalLen => _totalLen;

  ReaderPlaybackController(this._driver, this._ref);

  Future<void> start({
    required String content,
    required int startIndex,
    required ProgressCb onProgress,
    ProgressCb? onVisualProgress,
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
        onVisualProgress?.call(i);
        if (_lastIndex != _index) {
          _lastIndex = _index;
        }
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
    _totalLen = computeTotalLen(content, startIndex);
    await _driver.start(content: content, startIndex: startIndex);

    _index = startIndex;
    onVisualProgress?.call(_index);
  }

  void tryAutoStart({
    required String content,
    required int startIndex,
    required void Function(bool blocked) setAutoplayBlocked,
    required void Function() showAutoplayPrompt,
    required ProgressCb onProgress,
    ProgressCb? onVisualProgress,
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
      onVisualProgress: onVisualProgress,
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
    ProgressCb? onVisualProgress,
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
      final started = _speaking;
      if (started) {
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
        onVisualProgress: onVisualProgress,
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
        onVisualProgress: onVisualProgress,
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
