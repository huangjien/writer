import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/state/tts_settings.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('initialize loads defaults', () async {
    final notifier = TtsSettingsNotifier();
    await notifier.initialize();
    expect(notifier.state.rate, 0.45);
    expect(notifier.state.volume, 1.0);
    expect(notifier.state.voiceName, null);
    expect(notifier.state.voiceLocale, null);
  });

  test('setVoice persists name and locale', () async {
    final notifier = TtsSettingsNotifier();
    await notifier.setVoice(name: 'Alex', locale: 'en-US');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('tts_voice_name'), 'Alex');
    expect(prefs.getString('tts_voice_locale'), 'en-US');
  });

  test('rate and volume persist', () async {
    final notifier = TtsSettingsNotifier();
    await notifier.setRate(0.6);
    await notifier.setVolume(0.8);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getDouble('tts_rate'), 0.6);
    expect(prefs.getDouble('tts_volume'), 0.8);
  });
}
