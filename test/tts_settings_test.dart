import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/state/tts_settings.dart';

void main() {
  group('TtsSettingsNotifier', () {
    test('initialize loads defaults when no prefs set', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          ttsSettingsProvider.overrideWith((_) => TtsSettingsNotifier(prefs)),
        ],
      );
      final state = container.read(ttsSettingsProvider);

      expect(state.voiceName, isNull);
      expect(state.voiceLocale, isNull);
      expect(state.rate, 0.45);
      expect(state.volume, 1.0);
    });

    test('initialize loads persisted values', () async {
      SharedPreferences.setMockInitialValues({
        'tts_voice_name': 'Samantha',
        'tts_voice_locale': 'en-US',
        'tts_rate': 0.9,
        'tts_volume': 0.7,
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          ttsSettingsProvider.overrideWith((_) => TtsSettingsNotifier(prefs)),
        ],
      );
      final state = container.read(ttsSettingsProvider);

      expect(state.voiceName, 'Samantha');
      expect(state.voiceLocale, 'en-US');
      expect(state.rate, closeTo(0.9, 0.0001));
      expect(state.volume, closeTo(0.7, 0.0001));
    });

    test('setters update state and persist to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          ttsSettingsProvider.overrideWith((_) => TtsSettingsNotifier(prefs)),
        ],
      );
      final notifier = container.read(ttsSettingsProvider.notifier);

      await notifier.setVoice(name: 'Alex', locale: 'en-GB');
      await notifier.setRate(0.6);
      await notifier.setVolume(0.8);

      expect(prefs.getString('tts_voice_name'), 'Alex');
      expect(prefs.getString('tts_voice_locale'), 'en-GB');
      expect(prefs.getDouble('tts_rate'), closeTo(0.6, 0.0001));
      expect(prefs.getDouble('tts_volume'), closeTo(0.8, 0.0001));

      final state = container.read(ttsSettingsProvider);
      expect(state.voiceName, 'Alex');
      expect(state.voiceLocale, 'en-GB');
      expect(state.rate, closeTo(0.6, 0.0001));
      expect(state.volume, closeTo(0.8, 0.0001));
    });
  });
}
