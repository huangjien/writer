import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart' as ph;

class VoiceInputService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  bool _isInitialized = false;
  bool _isListening = false;
  String _lastWords = '';
  String _localeId = 'en_US';
  double _confidence = 0.0;

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  String get lastWords => _lastWords;
  String get localeId => _localeId;
  double get confidence => _confidence;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      final hasPermission = await _requestMicrophonePermission();
      if (!hasPermission) {
        debugPrint('VoiceInputService: Microphone permission denied');
        return false;
      }

      _isInitialized = await _speechToText.initialize(
        onError: (error) {
          debugPrint('VoiceInputService error: ${error.errorMsg}');
          _isListening = false;
        },
        onStatus: (status) {
          debugPrint('VoiceInputService status: $status');
          _isListening = status == 'listening';
        },
      );

      if (_isInitialized) {
        final systemLocale = await _speechToText.systemLocale();
        _localeId = systemLocale?.localeId ?? 'en_US';
      }

      return _isInitialized;
    } catch (e) {
      debugPrint('VoiceInputService initialization error: $e');
      return false;
    }
  }

  Future<bool> _requestMicrophonePermission() async {
    if (kIsWeb) return true;

    final status = await ph.Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> checkPermissionStatus() async {
    if (kIsWeb) return true;

    final status = await ph.Permission.microphone.status;
    return status.isGranted;
  }

  Future<void> startListening({
    required void Function(String) onResult,
    VoidCallback? onListeningStart,
    VoidCallback? onListeningEnd,
    String? localeId,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        throw Exception('Speech recognition failed to initialize');
      }
    }

    if (_isListening) {
      debugPrint('VoiceInputService: Already listening');
      return;
    }

    final hasPermission = await checkPermissionStatus();
    if (!hasPermission) {
      throw Exception('Microphone permission not granted');
    }

    await _speechToText.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;
        _confidence = result.confidence;
        onResult(_lastWords);

        if (result.finalResult) {
          _isListening = false;
          onListeningEnd?.call();
        }
      },
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 5),
      localeId: localeId ?? _localeId,
      listenOptions: stt.SpeechListenOptions(
        cancelOnError: true,
        partialResults: true,
        listenMode: stt.ListenMode.confirmation,
      ),
    );

    _isListening = true;
    _lastWords = '';
    onListeningStart?.call();
  }

  Future<void> stopListening() async {
    if (!_isListening) return;

    await _speechToText.stop();
    _isListening = false;
  }

  Future<void> cancelListening() async {
    if (!_isListening) return;

    await _speechToText.cancel();
    _isListening = false;
  }

  Future<List<stt.LocaleName>> getAvailableLanguages() async {
    if (!_isInitialized) {
      await initialize();
    }
    return await _speechToText.locales();
  }

  Future<void> setLocale(String localeId) async {
    _localeId = localeId;
  }

  void dispose() {
    _speechToText.cancel();
  }
}
