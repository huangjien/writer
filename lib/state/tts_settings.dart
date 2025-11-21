import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  TtsSettingsNotifier() : super(const TtsSettings());

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyVoiceName);
    final locale = prefs.getString(_keyVoiceLocale);
    final rate = prefs.getDouble(_keyRate) ?? 0.45;
    final volume = prefs.getDouble(_keyVolume) ?? 1.0;
    state = TtsSettings(
      voiceName: name,
      voiceLocale: locale,
      rate: rate,
      volume: volume,
    );
  }

  Future<void> setVoice({required String name, required String locale}) async {
    state = TtsSettings(voiceName: name, voiceLocale: locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyVoiceName, name);
    await prefs.setString(_keyVoiceLocale, locale);
  }

  Future<void> setLocale(String locale) async {
    state = state.copyWith(voiceLocale: locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyVoiceLocale, locale);
  }

  Future<void> setRate(double rate) async {
    state = state.copyWith(rate: rate);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyRate, rate);
  }

  Future<void> setVolume(double volume) async {
    state = state.copyWith(volume: volume);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyVolume, volume);
  }
}

final ttsSettingsProvider =
    StateNotifierProvider<TtsSettingsNotifier, TtsSettings>((ref) {
      final notifier = TtsSettingsNotifier();
      // Fire and forget initialization; consumers will get updated state once loaded
      notifier.initialize();
      return notifier;
    });
