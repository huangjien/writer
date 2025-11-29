import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _appLanguageKey = 'app_language';

class AppSettingsNotifier extends StateNotifier<Locale> {
  AppSettingsNotifier(this._prefs)
    : super(Locale(_prefs.getString(_appLanguageKey) ?? 'en'));

  final SharedPreferences _prefs;

  Future<void> setLanguage(String languageCode) async {
    await _prefs.setString(_appLanguageKey, languageCode);
    state = Locale(languageCode);
  }
}

final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, Locale>((
  ref,
) {
  // This will be overridden in main.dart
  throw UnimplementedError();
});
