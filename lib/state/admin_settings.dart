import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _adminModeKey = 'admin_mode';
const bool _defaultAdminMode = bool.fromEnvironment(
  'ADMIN_MODE',
  defaultValue: false,
);

class AdminModeNotifier extends StateNotifier<bool> {
  AdminModeNotifier(this._prefs)
    : super(_prefs.getBool(_adminModeKey) ?? _defaultAdminMode);

  final SharedPreferences _prefs;

  Future<void> setAdmin(bool value) async {
    await _prefs.setBool(_adminModeKey, value);
    state = value;
  }

  Future<void> enable() => setAdmin(true);
  Future<void> disable() => setAdmin(false);
  Future<void> resetToDefault() => setAdmin(_defaultAdminMode);
}

final adminModeProvider = StateNotifierProvider<AdminModeNotifier, bool>((
  ref,
) {
  // This will be overridden in main.dart
  throw UnimplementedError();
});
