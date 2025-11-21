import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novel_reader/state/tts_settings.dart';

void main() {
  group('TtsSettingsNotifier', () {
    test('initialize loads defaults when no prefs set', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = TtsSettingsNotifier();
      await notifier.initialize();

      expect(notifier.state.voiceName, isNull);
      expect(notifier.state.voiceLocale, isNull);
      expect(notifier.state.rate, 0.45);
      expect(notifier.state.volume, 1.0);
    });

    test('initialize loads persisted values', () async {
      SharedPreferences.setMockInitialValues({
        'tts_voice_name': 'Samantha',
        'tts_voice_locale': 'en-US',
        'tts_rate': 0.9,
        'tts_volume': 0.7,
      });
      final notifier = TtsSettingsNotifier();
      await notifier.initialize();

      expect(notifier.state.voiceName, 'Samantha');
      expect(notifier.state.voiceLocale, 'en-US');
      expect(notifier.state.rate, closeTo(0.9, 0.0001));
      expect(notifier.state.volume, closeTo(0.7, 0.0001));
    });

    test('setters update state and persist to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = TtsSettingsNotifier();
      await notifier.initialize();

      await notifier.setVoice(name: 'Alex', locale: 'en-GB');
      await notifier.setRate(0.6);
      await notifier.setVolume(0.8);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('tts_voice_name'), 'Alex');
      expect(prefs.getString('tts_voice_locale'), 'en-GB');
      expect(prefs.getDouble('tts_rate'), closeTo(0.6, 0.0001));
      expect(prefs.getDouble('tts_volume'), closeTo(0.8, 0.0001));

      expect(notifier.state.voiceName, 'Alex');
      expect(notifier.state.voiceLocale, 'en-GB');
      expect(notifier.state.rate, closeTo(0.6, 0.0001));
      expect(notifier.state.volume, closeTo(0.8, 0.0001));
    });
  });
}
