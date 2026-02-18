import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _appLanguageKey = 'app_language';
const Set<String> _supportedLocales = {
  'en',
  'zh',
  'zh-TW',
  'de',
  'es',
  'fr',
  'it',
  'ja',
  'ko',
};

class AppSettingsNotifier extends StateNotifier<Locale> {
  AppSettingsNotifier(this._prefs) : super(_initializeLocale(_prefs));

  final SharedPreferences _prefs;

  static Locale _initializeLocale(SharedPreferences prefs) {
    final savedLocale = prefs.getString(_appLanguageKey) ?? 'en';
    if (_supportedLocales.contains(savedLocale)) {
      return _parseLocale(savedLocale);
    }
    prefs.remove(_appLanguageKey);
    return const Locale('en');
  }

  static Locale _parseLocale(String localeString) {
    final parts = localeString.split('-');
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(localeString);
  }

  Future<void> setLanguage(String languageCode) async {
    await _prefs.setString(_appLanguageKey, languageCode);
    state = _parseLocale(languageCode);
  }
}

final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, Locale>((
  ref,
) {
  // This will be overridden in main.dart
  throw UnimplementedError(
    'appSettingsProvider must be overridden in ProviderScope/main.dart',
  );
});
