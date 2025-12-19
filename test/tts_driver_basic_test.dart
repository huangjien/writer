import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:writer/features/reader/logic/tts_driver.dart';

class MockFlutterTts extends FlutterTts {
  void Function()? _completionHandler;
  void Function()? _cancelHandler;
  void Function(dynamic)? _errorHandler;
  void Function(String, int, int, String)? _progressHandler;
  void Function()? _startHandler;

  final List<String> speakCalls = [];
  bool completeAfterSpeak = true;
  bool fireProgressOnSpeak = false;
  int progressStartIndex = 0;

  @override
  Future<dynamic> speak(String text, {bool focus = true}) async {
    speakCalls.add(text);
    _startHandler?.call();
    if (fireProgressOnSpeak && _progressHandler != null) {
      _progressHandler!(text, progressStartIndex, progressStartIndex + 1, '');
    }
    await Future.delayed(const Duration(milliseconds: 20));
    if (completeAfterSpeak) _completionHandler?.call();
    return 1;
  }

  @override
  Future<dynamic> awaitSpeakCompletion(bool awaitCompletion) async {
    return 1;
  }

  @override
  void setCompletionHandler(void Function() handler) {
    _completionHandler = handler;
  }

  @override
  void setProgressHandler(void Function(String, int, int, String) handler) {
    _progressHandler = handler;
  }

  @override
  Future<dynamic> setLanguage(String language) async => 1;
  @override
  Future<dynamic> setSpeechRate(double rate) async => 1;
  @override
  Future<dynamic> setVolume(double volume) async => 1;
  @override
  Future<dynamic> setVoice(Map<String, String> voice) async => 1;
  @override
  void setStartHandler(void Function() callback) {
    _startHandler = callback;
  }

  @override
  void setCancelHandler(void Function() callback) {
    _cancelHandler = callback;
  }

  @override
  void setErrorHandler(void Function(dynamic) handler) {
    _errorHandler = handler;
  }

  @override
  Future<dynamic> stop() async {
    _cancelHandler?.call();
    return 1;
  }

  @override
  Future<dynamic> pause() async {
    _cancelHandler?.call();
    return 1;
  }

  void triggerError(dynamic message) {
    _errorHandler?.call(message);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('TtsDriver start with empty content does not speak', () async {
    final driver = TtsDriver(tts: MockFlutterTts());
    await driver.configure(
      voiceName: null,
      voiceLocale: null,
      defaultLocale: 'en-US',
    );
    await driver.start(content: '', startIndex: 0);
    expect(driver.speaking, isFalse);
    expect(driver.index, 0);
  });

  test('TtsDriver start/stop toggles speaking state', () async {
    final mockTts = MockFlutterTts();
    final driver = TtsDriver(tts: mockTts);
    // Must configure to set handlers
    await driver.configure(
      voiceName: null,
      voiceLocale: null,
      defaultLocale: 'en-US',
    );

    await driver.start(content: 'Hello world.', startIndex: 0);

    // Should be speaking now because MockFlutterTts delays
    expect(driver.speaking, isTrue);

    // Stop should trigger cancel handler and complete the future
    await driver.stop();
    expect(driver.speaking, isFalse);
  });

  test('TtsDriver splits content into chunks and speaks each', () async {
    final mockTts = MockFlutterTts();
    final allComplete = Completer<void>();

    final driver = TtsDriver(tts: mockTts);
    await driver.configure(
      voiceName: null,
      voiceLocale: null,
      defaultLocale: 'en-US',
      onAllComplete: () {
        if (!allComplete.isCompleted) allComplete.complete();
      },
    );

    await driver.start(
      content: 'Hello. World. Again.',
      startIndex: 0,
      chunkMaxLen: 6,
    );

    await allComplete.future.timeout(const Duration(seconds: 2));
    expect(mockTts.speakCalls, ['Hello.', 'World.', 'Again.']);
    expect(driver.speaking, isFalse);
  });

  test('TtsDriver progress handler reports baseStart + start', () async {
    final mockTts = MockFlutterTts()
      ..fireProgressOnSpeak = true
      ..progressStartIndex = 1;
    final indices = <int>[];
    final allComplete = Completer<void>();

    final driver = TtsDriver(tts: mockTts);
    await driver.configure(
      voiceName: null,
      voiceLocale: null,
      defaultLocale: 'en-US',
      onProgress: indices.add,
      onAllComplete: () {
        if (!allComplete.isCompleted) allComplete.complete();
      },
    );

    await driver.start(content: 'xxHello.', startIndex: 2, chunkMaxLen: 100);

    await allComplete.future.timeout(const Duration(seconds: 2));
    expect(indices, contains(3));
  });

  test('TtsDriver timeout proceeds when completion is not fired', () async {
    final mockTts = MockFlutterTts()..completeAfterSpeak = false;
    final allComplete = Completer<void>();

    final driver = TtsDriver(tts: mockTts);
    await driver.configure(
      voiceName: null,
      voiceLocale: null,
      defaultLocale: 'en-US',
      onAllComplete: () {
        if (!allComplete.isCompleted) allComplete.complete();
      },
    );

    await driver.start(
      content: 'Hello.',
      startIndex: 0,
      chunkMaxLen: 100,
      baseTimeoutMs: 5,
      charTimeoutMs: 0,
    );

    await allComplete.future.timeout(const Duration(seconds: 2));
    expect(driver.speaking, isFalse);
    expect(mockTts.speakCalls, ['Hello.']);
  });

  test('TtsDriver stops when error handler is triggered', () async {
    final mockTts = MockFlutterTts()..completeAfterSpeak = false;
    final errors = <String>[];

    final driver = TtsDriver(tts: mockTts);
    await driver.configure(
      voiceName: null,
      voiceLocale: null,
      defaultLocale: 'en-US',
      onError: errors.add,
    );

    await driver.start(
      content: 'Hello.',
      startIndex: 0,
      chunkMaxLen: 100,
      baseTimeoutMs: 500,
      charTimeoutMs: 0,
    );

    await Future<void>.delayed(const Duration(milliseconds: 10));
    mockTts.triggerError('boom');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(errors, contains('boom'));
    expect(driver.speaking, isFalse);
  });
}
