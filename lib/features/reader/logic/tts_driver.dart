import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'package:writer/features/reader/tts_chunker.dart';
import 'package:writer/shared/constants.dart';
import 'dart:math' as math;

typedef TtsProgress = void Function(int index);
typedef TtsFlag = void Function();
typedef TtsError = void Function(String message);

class TtsDriver {
  FlutterTts? _tts;
  bool _configured = false;
  bool _speaking = false;
  int _index = 0;
  List<TtsChunk> _chunks = const [];
  bool _completedHandled = false;
  int _baseStart = 0;
  Completer<void>? _chunkCompleter;
  int _baseTimeoutMs = kTtsBaseTimeoutMs;
  int _charTimeoutMs = kTtsCharTimeoutMs;
  int _currentChunkStart = 0;
  int _currentChunkLen = 0;

  TtsDriver({FlutterTts? tts}) : _tts = tts;

  TtsProgress? _onProgress;
  TtsFlag? _onStart;
  TtsFlag? _onCancel;
  TtsError? _onError;
  TtsFlag? _onAllComplete;

  bool get speaking => _speaking;
  int get index => _index;

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

    _tts ??= FlutterTts();
    if (!_configured) {
      try {
        _tts!.setProgressHandler((
          String? text,
          int? start,
          int? end,
          String? word,
        ) {
          if (start != null) {
            final safeLocal = _currentChunkLen <= 0
                ? 0
                : math.min(start, _currentChunkLen - 1);
            _index = _currentChunkStart + safeLocal;
            _speaking = true;
            _onProgress?.call(_index);
          }
        });
        _tts!.setStartHandler(() {
          _speaking = true;
          _onStart?.call();
        });
        _tts!.setCancelHandler(() {
          _speaking = false;
          _onCancel?.call();
          if (_chunkCompleter != null && !_chunkCompleter!.isCompleted) {
            _chunkCompleter!.complete();
          }
        });
        _tts!.setErrorHandler((msg) {
          _speaking = false;
          _onError?.call(msg ?? '');
          if (_chunkCompleter != null && !_chunkCompleter!.isCompleted) {
            _chunkCompleter!.complete();
          }
        });
        // Use manual completion handler to drive chunks
        _tts!.setCompletionHandler(() {
          if (_chunkCompleter != null && !_chunkCompleter!.isCompleted) {
            _chunkCompleter!.complete();
          }
        });
      } catch (_) {}
      try {
        // Disable awaitSpeakCompletion to use manual flow
        await _tts!.awaitSpeakCompletion(false);
      } catch (_) {}
      _configured = true;
    }
    final locale = voiceLocale ?? defaultLocale;
    try {
      if (voiceName != null && voiceName.isNotEmpty) {
        await _tts!.setVoice({'name': voiceName, 'locale': locale});
      } else {
        await _tts!.setLanguage(locale);
      }
    } catch (_) {
      try {
        await _tts!.setLanguage(locale);
      } catch (_) {}
    }
  }

  Future<void> setRate(double rate) async {
    try {
      await _tts?.setSpeechRate(rate);
    } catch (_) {}
  }

  Future<void> setVolume(double volume) async {
    try {
      await _tts?.setVolume(volume);
    } catch (_) {}
  }

  Future<void> start({
    required String content,
    required int startIndex,
    int chunkMaxLen = kTtsChunkMaxLen,
    int baseTimeoutMs = kTtsBaseTimeoutMs,
    int charTimeoutMs = kTtsCharTimeoutMs,
  }) async {
    _speaking = true;
    _completedHandled = false;
    _baseStart = startIndex.clamp(0, content.length);
    _baseTimeoutMs = baseTimeoutMs;
    _charTimeoutMs = charTimeoutMs;
    final remaining = content.substring(_baseStart);
    _chunks = chunkTextWithOffsets(
      remaining,
      baseOffset: _baseStart,
      maxLen: chunkMaxLen,
    );
    if (_chunks.isEmpty) {
      _speaking = false;
      _onAllComplete?.call();
      return;
    }

    // Do not await the loop; let it run in background
    _processChunks();
  }

  Future<void> _processChunks() async {
    for (var i = 0; i < _chunks.length; i++) {
      if (!_speaking) break;
      final chunk = _chunks[i];
      final part = chunk.text;
      _currentChunkStart = chunk.start;
      _currentChunkLen = part.length;
      _index = _currentChunkStart;
      _onProgress?.call(_index);

      try {
        _chunkCompleter = Completer();
        // speak returns immediately (mostly) when awaitSpeakCompletion is false
        await _tts?.speak(part);

        // Wait for completion handler with a safety timeout
        // Calculate timeout based on length (conservative estimate: 1s per 5 chars + 5s base)
        final timeoutMs = _baseTimeoutMs + (part.length * _charTimeoutMs);
        await _chunkCompleter!.future.timeout(
          Duration(milliseconds: timeoutMs),
          onTimeout: () {
            // If timeout, we assume finished or stuck and proceed to next chunk
            if (!_chunkCompleter!.isCompleted) {
              _chunkCompleter!.complete();
            }
          },
        );
      } catch (e) {
        if (!_speaking) break;
        // _onError?.call(e.toString()); // Error might be already handled by handler
        // If critical error, stop. But for timeout we continue.
        if (e is! TimeoutException) {
          _speaking = false;
          break;
        }
      } finally {
        _chunkCompleter = null;
      }

      if (!_speaking) break;

      // Ensure we end on a position inside the current chunk to avoid a
      // temporary "no paragraph highlighted" state between chunks.
      if (part.isNotEmpty) {
        final endInChunk = _currentChunkStart + part.length - 1;
        if (_index < endInChunk) {
          _index = endInChunk;
          _onProgress?.call(_index);
        }
      }
    }

    if (_speaking) {
      // Finished all chunks naturally
      _speaking = false;
      if (!_completedHandled) {
        _completedHandled = true;
        _onAllComplete?.call();
      }
    }
  }

  Future<void> stop() async {
    try {
      await _tts?.stop();
    } catch (_) {}
    _speaking = false;
    final c = _chunkCompleter;
    if (c != null && !c.isCompleted) {
      c.complete();
    }
    _chunkCompleter = null;
    _chunks = const [];
    _currentChunkStart = 0;
    _currentChunkLen = 0;
  }

  Future<void> pause() async {
    try {
      await _tts?.pause();
    } catch (_) {}
    _speaking = false;
    final c = _chunkCompleter;
    if (c != null && !c.isCompleted) {
      c.complete();
    }
    _chunkCompleter = null;
    _currentChunkStart = 0;
    _currentChunkLen = 0;
  }

  Future<void> setLocale(String locale, {String? voiceName}) async {
    try {
      if (voiceName != null && voiceName.isNotEmpty) {
        await _tts?.setVoice({'name': voiceName, 'locale': locale});
      } else {
        await _tts?.setLanguage(locale);
      }
    } catch (_) {}
  }
}

final ttsDriverProvider = Provider<TtsDriver>((ref) => TtsDriver());
