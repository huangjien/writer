import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/reader/logic/reader_shortcuts.dart';
import 'package:flutter/widgets.dart';

void main() {
  test('shortcut intents are Intent subclasses', () {
    expect(const ToggleSpeakIntent(), isA<Intent>());
    expect(const PrevIntent(), isA<Intent>());
    expect(const NextIntent(), isA<Intent>());
    expect(const OpenRateIntent(), isA<Intent>());
    expect(const OpenVoiceIntent(), isA<Intent>());
  });
}
