import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:writer/features/reader/logic/tts_driver.dart';

class MockFlutterTts extends FlutterTts {
  @override
  Future<dynamic> speak(String text, {bool focus = true}) async {
    // Simulate some duration for speech so we can check 'speaking' state
    await Future.delayed(const Duration(milliseconds: 100));
    return 1;
  }

  @override
  Future<dynamic> awaitSpeakCompletion(bool awaitCompletion) async {
    return 1;
  }

  @override
  void setCompletionHandler(void Function() handler) {}

  @override
  void setProgressHandler(void Function(String, int, int, String) handler) {}

  @override
  Future<dynamic> setLanguage(String language) async => 1;
  @override
  Future<dynamic> setSpeechRate(double rate) async => 1;
  @override
  Future<dynamic> setVolume(double volume) async => 1;
  @override
  Future<dynamic> setVoice(Map<String, String> voice) async => 1;
  @override
  void setStartHandler(void Function() callback) {}
  @override
  void setCancelHandler(void Function() callback) {}
  @override
  void setErrorHandler(void Function(dynamic) handler) {}
  @override
  Future<dynamic> stop() async {
    return 1;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('TtsDriver start with empty content does not speak', () async {
    final driver = TtsDriver(tts: MockFlutterTts());
    await driver.start(content: '', startIndex: 0);
    expect(driver.speaking, isFalse);
    expect(driver.index, 0);
  });

  test('TtsDriver start/stop toggles speaking state', () async {
    final driver = TtsDriver(tts: MockFlutterTts());
    await driver.start(content: 'Hello world.', startIndex: 0);

    // Should be speaking now because MockFlutterTts delays
    expect(driver.speaking, isTrue);

    await driver.stop();
    expect(driver.speaking, isFalse);
  });
}
