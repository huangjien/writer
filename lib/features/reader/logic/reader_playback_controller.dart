import 'dart:async';
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
  Timer? _progressFallback;
  int _attempts = 0;
  bool _speaking = false;
  int _index = 0;
  final int _maxAttempts = 5;
  bool _gotDriverProgress = false;
  int _totalLen = 0;
  DateTime _lastProgressAt = DateTime.fromMillisecondsSinceEpoch(0);
  bool _sessionActive = false;
  int _lastIndex = 0;
  DateTime _lastIndexAt = DateTime.fromMillisecondsSinceEpoch(0);

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
    bool enableFallback = true,
  }) async {
    final current = _ref.read(ttsSettingsProvider);
    final appLocale = _ref.read(appSettingsProvider);
    final mapped = switch (appLocale.languageCode) {
      'zh' => 'zh-CN',
      'en' => 'en-US',
      _ => 'en-US',
    };
    _gotDriverProgress = false;
    _sessionActive = true;
    await _driver.configure(
      voiceName: current.voiceName,
      voiceLocale: current.voiceLocale,
      defaultLocale: mapped,
      onProgress: (i) {
        _index = i;
        _speaking = true;
        _gotDriverProgress = true;
        _lastProgressAt = DateTime.now();
        onProgress(i);
        onVisualProgress?.call(i);
        if (_lastIndex != _index) {
          _lastIndex = _index;
          _lastIndexAt = DateTime.now();
        }
      },
      onStart: () {
        _speaking = true;
        onStart();
      },
      onCancel: () {
        _speaking = false;
        _sessionActive = false;
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

    _progressFallback?.cancel();
    if (enableFallback) {
      _index = startIndex;
      onVisualProgress?.call(_index);
      _lastProgressAt = DateTime.now();
      _progressFallback = Timer.periodic(const Duration(milliseconds: 500), (
        t,
      ) {
        if (!_sessionActive) {
          t.cancel();
          return;
        }
        final now = DateTime.now();
        final staleMs = now.difference(_lastProgressAt).inMilliseconds;
        final shouldTick = !_gotDriverProgress || staleMs >= 1200;
        if (!shouldTick) return;
        if (staleMs >= 2000 && !_driver.speaking) {
          final maxLen = _totalLen > 0 ? _totalLen : content.length;
          _index = maxLen;
          onProgress(maxLen);
          _speaking = false;
          _sessionActive = false;
          try {
            _driver.stop();
          } catch (_) {}
          onComplete();
          t.cancel();
          return;
        }
        final next = _index + 12;
        final maxLen = _totalLen > 0 ? _totalLen : content.length;
        _index = next > maxLen ? maxLen : next;
        onVisualProgress?.call(_index);
        if (_lastIndex != _index) {
          _lastIndex = _index;
          _lastIndexAt = DateTime.now();
        }
        final stagnantMs = now.difference(_lastIndexAt).inMilliseconds;
        if (stagnantMs >= 3000 &&
            (_index >= (maxLen - 24) || (_index.toDouble() / maxLen) >= 0.95)) {
          onProgress(maxLen);
          _speaking = false;
          _sessionActive = false;
          try {
            _driver.stop();
          } catch (_) {}
          onComplete();
          t.cancel();
          return;
        }
        if (_index >= maxLen) {
          onProgress(maxLen);
          _speaking = false;
          _sessionActive = false;
          try {
            _driver.stop();
          } catch (_) {}
          onComplete();
          t.cancel();
        }
      });
    }
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
      enableFallback: true,
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
      final hasRealProgress = _gotDriverProgress;
      final started = _speaking;
      if (started || hasRealProgress) {
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
    _sessionActive = false;
    _progressFallback?.cancel();
  }

  void dispose() {
    _autoStartRetry?.cancel();
    _progressFallback?.cancel();
    _sessionActive = false;
  }
}
