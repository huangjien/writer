import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:writer/features/reader/logic/tts_driver.dart';

class MockFlutterTts extends Mock implements FlutterTts {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, String>{});
  });

  test('configure sets language when voiceName is empty', () async {
    final tts = MockFlutterTts();
    when(() => tts.setProgressHandler(any())).thenAnswer((_) {});
    when(() => tts.setStartHandler(any())).thenAnswer((_) {});
    when(() => tts.setCancelHandler(any())).thenAnswer((_) {});
    when(() => tts.setErrorHandler(any())).thenAnswer((_) {});
    when(() => tts.setCompletionHandler(any())).thenAnswer((_) {});
    when(() => tts.awaitSpeakCompletion(false)).thenAnswer((_) async {});
    when(() => tts.setLanguage(any())).thenAnswer((_) async {});

    final driver = TtsDriver(tts: tts);
    await driver.configure(
      voiceName: '',
      voiceLocale: 'en-US',
      defaultLocale: 'en-US',
    );
    verify(() => tts.setLanguage('en-US')).called(1);
  });

  test('configure sets voice when voiceName provided', () async {
    final tts = MockFlutterTts();
    when(() => tts.setProgressHandler(any())).thenAnswer((_) {});
    when(() => tts.setStartHandler(any())).thenAnswer((_) {});
    when(() => tts.setCancelHandler(any())).thenAnswer((_) {});
    when(() => tts.setErrorHandler(any())).thenAnswer((_) {});
    when(() => tts.setCompletionHandler(any())).thenAnswer((_) {});
    when(() => tts.awaitSpeakCompletion(false)).thenAnswer((_) async {});
    when(() => tts.setVoice(any())).thenAnswer((_) async {});

    final driver = TtsDriver(tts: tts);
    await driver.configure(
      voiceName: 'Alice',
      voiceLocale: 'zh-CN',
      defaultLocale: 'en-US',
    );
    verify(() => tts.setVoice({'name': 'Alice', 'locale': 'zh-CN'})).called(1);
  });

  test('setLocale sets language or voice appropriately', () async {
    final tts = MockFlutterTts();
    when(() => tts.setLanguage(any())).thenAnswer((_) async {});
    when(() => tts.setVoice(any())).thenAnswer((_) async {});
    final driver = TtsDriver(tts: tts);
    await driver.setLocale('en-GB');
    verify(() => tts.setLanguage('en-GB')).called(1);
    await driver.setLocale('zh-CN', voiceName: 'Alice');
    verify(() => tts.setVoice({'name': 'Alice', 'locale': 'zh-CN'})).called(1);
  });

  test('setRate and setVolume forward to FlutterTts', () async {
    final tts = MockFlutterTts();
    when(() => tts.setSpeechRate(any())).thenAnswer((_) async {});
    when(() => tts.setVolume(any())).thenAnswer((_) async {});
    final driver = TtsDriver(tts: tts);
    await driver.setRate(0.8);
    await driver.setVolume(0.9);
    verify(() => tts.setSpeechRate(0.8)).called(1);
    verify(() => tts.setVolume(0.9)).called(1);
  });

  test(
    'stop and pause call underlying FlutterTts and toggle speaking',
    () async {
      final tts = MockFlutterTts();
      final driver = TtsDriver(tts: tts);
      when(tts.stop).thenAnswer((_) async {});
      when(tts.pause).thenAnswer((_) async {});
      await driver.stop();
      expect(driver.speaking, false);
      await driver.pause();
      expect(driver.speaking, false);
      verify(tts.stop).called(1);
      verify(tts.pause).called(1);
    },
  );
}
