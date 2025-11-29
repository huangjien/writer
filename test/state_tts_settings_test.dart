import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/state/tts_settings.dart';

void main() {
  test('initialize loads defaults', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        ttsSettingsProvider.overrideWith((_) => TtsSettingsNotifier(prefs)),
      ],
    );
    addTearDown(container.dispose);

    final state = container.read(ttsSettingsProvider);
    expect(state.rate, 0.45);
    expect(state.volume, 1.0);
    expect(state.voiceName, null);
    expect(state.voiceLocale, null);
  });

  test('setVoice persists name and locale', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        ttsSettingsProvider.overrideWith((_) => TtsSettingsNotifier(prefs)),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(ttsSettingsProvider.notifier);
    await notifier.setVoice(name: 'Alex', locale: 'en-US');
    expect(prefs.getString('tts_voice_name'), 'Alex');
    expect(prefs.getString('tts_voice_locale'), 'en-US');
  });

  test('rate and volume persist', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        ttsSettingsProvider.overrideWith((_) => TtsSettingsNotifier(prefs)),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(ttsSettingsProvider.notifier);
    await notifier.setRate(0.6);
    await notifier.setVolume(0.8);
    expect(prefs.getDouble('tts_rate'), 0.6);
    expect(prefs.getDouble('tts_volume'), 0.8);
  });
}
