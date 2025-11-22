import 'package:flutter_test/flutter_test.dart';
import 'package:novel_reader/features/reader/logic/tts_driver.dart';

void main() {
  test('TtsDriver start with empty content does not speak', () async {
    final driver = TtsDriver();
    await driver.start(content: '', startIndex: 0);
    expect(driver.speaking, isFalse);
    expect(driver.index, 0);
  });

  test('TtsDriver start/stop toggles speaking state', () async {
    final driver = TtsDriver();
    await driver.start(content: 'Hello world.', startIndex: 0);
    expect(driver.speaking, isTrue);
    await driver.stop();
    expect(driver.speaking, isFalse);
  });
}
