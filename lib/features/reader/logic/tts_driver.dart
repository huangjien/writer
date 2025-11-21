import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import '../tts_chunker.dart';

typedef TtsProgress = void Function(int index);
typedef TtsFlag = void Function();
typedef TtsError = void Function(String message);

class TtsDriver {
  FlutterTts? _tts;
  bool _configured = false;
  bool _speaking = false;
  int _index = 0;
  List<String> _chunks = const [];
  int _chunkIndex = 0;
  bool _completedHandled = false;
  int _baseStart = 0;
  int _consumedLength = 0;

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
            _index = _baseStart + _consumedLength + start;
            _speaking = true;
            onProgress?.call(_index);
          }
        });
        _tts!.setStartHandler(() {
          _speaking = true;
          onStart?.call();
        });
        _tts!.setCancelHandler(() {
          _speaking = false;
          onCancel?.call();
        });
        _tts!.setErrorHandler((msg) {
          onError?.call(msg ?? '');
        });
        _tts!.setCompletionHandler(() {
          if (!_speaking) return;
          if (_chunkIndex < _chunks.length) {
            _consumedLength += _chunks[_chunkIndex].length;
            _index = _baseStart + _consumedLength;
          }
          _chunkIndex++;
          if (_chunkIndex < _chunks.length) {
            final part = _chunks[_chunkIndex];
            _tts!.speak(part);
          } else {
            if (!_completedHandled) {
              _completedHandled = true;
              _speaking = false;
              onAllComplete?.call();
            }
          }
        });
      } catch (_) {}
      try {
        await _tts!.awaitSpeakCompletion(!kIsWeb);
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
    int chunkMaxLen = 1200,
  }) async {
    _speaking = true;
    _completedHandled = false;
    _baseStart = startIndex.clamp(0, content.length);
    _consumedLength = 0;
    final remaining = content.substring(_baseStart);
    _chunks = chunkText(remaining, maxLen: chunkMaxLen);
    _chunkIndex = 0;
    if (_chunks.isEmpty) {
      _speaking = false;
      return;
    }
    await _tts?.speak(_chunks[_chunkIndex]);
  }

  Future<void> stop() async {
    try {
      await _tts?.stop();
    } catch (_) {}
    _speaking = false;
    _chunks = const [];
    _chunkIndex = 0;
  }

  Future<void> pause() async {
    try {
      await _tts?.pause();
    } catch (_) {}
    _speaking = false;
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
