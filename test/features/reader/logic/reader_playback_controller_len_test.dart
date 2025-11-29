import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/features/reader/logic/reader_playback_controller.dart';
import 'package:writer/features/reader/logic/tts_driver.dart';

class MockTtsDriver extends Mock implements TtsDriver {}

void main() {
  test('computeTotalLen respects base index and trimmed length', () {
    final driver = MockTtsDriver();
    final container = ProviderContainer();
    final refProvider = Provider((ref) => ref);
    final ctrl = ReaderPlaybackController(driver, container.read(refProvider));
    final content = '  Hello world.  ';
    final len = ctrl.computeTotalLen(content, 2);
    expect(len, greaterThanOrEqualTo(2));
    expect(len, 2 + 'Hello world.'.length);
  });
}
