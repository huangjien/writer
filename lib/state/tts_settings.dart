import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TtsSettings {
  final String? voiceName;
  final String? voiceLocale;
  final double rate;
  final double volume;
  const TtsSettings({
    this.voiceName,
    this.voiceLocale,
    this.rate = 0.45,
    this.volume = 1.0,
  });

  TtsSettings copyWith({
    String? voiceName,
    String? voiceLocale,
    double? rate,
    double? volume,
  }) => TtsSettings(
    voiceName: voiceName ?? this.voiceName,
    voiceLocale: voiceLocale ?? this.voiceLocale,
    rate: rate ?? this.rate,
    volume: volume ?? this.volume,
  );
}

class TtsSettingsNotifier extends StateNotifier<TtsSettings> {
  static const _keyVoiceName = 'tts_voice_name';
  static const _keyVoiceLocale = 'tts_voice_locale';
  static const _keyRate = 'tts_rate';
  static const _keyVolume = 'tts_volume';

  final SharedPreferences _prefs;

  TtsSettingsNotifier(this._prefs) : super(const TtsSettings()) {
    _initialize();
  }

  void _initialize() {
    final name = _prefs.getString(_keyVoiceName);
    final locale = _prefs.getString(_keyVoiceLocale);
    final rate = _prefs.getDouble(_keyRate) ?? 0.45;
    final volume = _prefs.getDouble(_keyVolume) ?? 1.0;
    state = TtsSettings(
      voiceName: name,
      voiceLocale: locale,
      rate: rate,
      volume: volume,
    );
  }

  Future<void> setVoice({required String name, required String locale}) async {
    state = TtsSettings(voiceName: name, voiceLocale: locale);
    await _prefs.setString(_keyVoiceName, name);
    await _prefs.setString(_keyVoiceLocale, locale);
  }

  Future<void> setLocale(String locale) async {
    state = state.copyWith(voiceLocale: locale);
    await _prefs.setString(_keyVoiceLocale, locale);
  }

  Future<void> setRate(double rate) async {
    state = state.copyWith(rate: rate);
    await _prefs.setDouble(_keyRate, rate);
  }

  Future<void> setVolume(double volume) async {
    state = state.copyWith(volume: volume);
    await _prefs.setDouble(_keyVolume, volume);
  }
}

final ttsSettingsProvider =
    StateNotifierProvider<TtsSettingsNotifier, TtsSettings>((ref) {
      throw UnimplementedError('Must be overridden');
    });
