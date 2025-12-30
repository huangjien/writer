/// Abstract interface for storage operations
///
/// This abstraction allows for easy testing by providing mock implementations.
abstract class StorageService {
  /// Get a string value by key
  String? getString(String key);

  /// Set a string value by key
  Future<void> setString(String key, String? value);

  /// Remove a value by key
  Future<void> remove(String key);

  /// Get all keys
  Set<String> getKeys();
}
