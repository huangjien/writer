import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope/main.dart',
  );
});

/// Provider for StorageService
///
/// This provider can be overridden in tests with a mock implementation.
final storageServiceProvider = Provider<StorageService>((ref) {
  // Use SharedPreferences from shared_preferences package
  // In production, this would use the real SharedPreferences
  // For testing, this can be overridden with a mock
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorageService(prefs);
});

/// Internal implementation using SharedPreferences
class LocalStorageService implements StorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String? value) async {
    if (value == null) {
      await _prefs.remove(key);
    } else {
      await _prefs.setString(key, value);
    }
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  @override
  Set<String> getKeys() => _prefs.getKeys();
}
