import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/services/storage_service.dart';
import 'package:writer/state/storage_service_provider.dart';

class MockStorageService implements StorageService {
  final Map<String, String> _storage = {};

  @override
  String? getString(String key) {
    return _storage[key];
  }

  @override
  Future<void> setString(String key, String? value) async {
    if (value == null) {
      _storage.remove(key);
    } else {
      _storage[key] = value;
    }
  }

  @override
  Future<void> remove(String key) async {
    _storage.remove(key);
  }

  @override
  Set<String> getKeys() {
    return _storage.keys.toSet();
  }
}

void main() {
  group('SessionNotifier', () {
    late MockStorageService mockStorage;
    late SessionNotifier notifier;

    setUp(() {
      mockStorage = MockStorageService();
      notifier = SessionNotifier(mockStorage);
    });

    test('creates with null initial state when storage has no session', () {
      final storage = MockStorageService();
      final sessionNotifier = SessionNotifier(storage);
      expect(sessionNotifier.state, isNull);
    });

    test('creates with initial state from storage', () async {
      final storage = MockStorageService();
      await storage.setString('backend_session_id', 'stored-session');
      final sessionNotifier = SessionNotifier(storage);
      expect(sessionNotifier.state, 'stored-session');
    });

    test('creates with explicit initial state', () {
      final storage = MockStorageService();
      final sessionNotifier = SessionNotifier(storage, 'explicit-session');
      expect(sessionNotifier.state, 'explicit-session');
    });

    test('setSessionId updates state and storage', () async {
      await notifier.setSessionId('new-session');
      expect(notifier.state, 'new-session');
      expect(mockStorage.getString('backend_session_id'), 'new-session');
    });

    test('setSessionId with null clears session', () async {
      notifier.state = 'existing-session';
      await mockStorage.setString('backend_session_id', 'existing-session');

      await notifier.setSessionId(null);

      expect(notifier.state, isNull);
      expect(mockStorage.getString('backend_session_id'), isNull);
    });

    test('setSessionId with empty string clears session', () async {
      notifier.state = 'existing-session';
      await mockStorage.setString('backend_session_id', 'existing-session');

      await notifier.setSessionId('');

      expect(notifier.state, isNull);
      expect(mockStorage.getString('backend_session_id'), isNull);
    });

    test('setSessionId with whitespace clears session', () async {
      notifier.state = 'existing-session';
      await mockStorage.setString('backend_session_id', 'existing-session');

      await notifier.setSessionId('   ');

      expect(notifier.state, isNull);
      expect(mockStorage.getString('backend_session_id'), isNull);
    });

    test('setRefreshToken updates storage', () async {
      await notifier.setRefreshToken('new-refresh-token');
      expect(
        mockStorage.getString('backend_refresh_token'),
        'new-refresh-token',
      );
    });

    test('setRefreshToken with null removes token from storage', () async {
      await mockStorage.setString('backend_refresh_token', 'existing-token');

      await notifier.setRefreshToken(null);

      expect(mockStorage.getString('backend_refresh_token'), isNull);
    });

    test(
      'setRefreshToken with empty string removes token from storage',
      () async {
        await mockStorage.setString('backend_refresh_token', 'existing-token');

        await notifier.setRefreshToken('');

        expect(mockStorage.getString('backend_refresh_token'), isNull);
      },
    );

    test(
      'setRefreshToken with whitespace removes token from storage',
      () async {
        await mockStorage.setString('backend_refresh_token', 'existing-token');

        await notifier.setRefreshToken('   ');

        expect(mockStorage.getString('backend_refresh_token'), isNull);
      },
    );

    test('getRefreshToken returns token from storage', () async {
      await mockStorage.setString('backend_refresh_token', 'stored-token');
      final token = notifier.getRefreshToken();
      expect(token, 'stored-token');
    });

    test('getRefreshToken returns null when no token in storage', () {
      final token = notifier.getRefreshToken();
      expect(token, isNull);
    });

    test('clear clears session and refresh token', () async {
      notifier.state = 'existing-session';
      await mockStorage.setString('backend_session_id', 'existing-session');
      await mockStorage.setString('backend_refresh_token', 'existing-token');

      await notifier.clear();

      expect(notifier.state, isNull);
      expect(mockStorage.getString('backend_session_id'), isNull);
      expect(mockStorage.getString('backend_refresh_token'), isNull);
    });

    test('clear with no session does not error', () async {
      expect(() => notifier.clear(), returnsNormally);
    });
  });

  group('sessionProvider', () {
    test('creates SessionNotifier with storage service', () {
      final storage = MockStorageService();
      final container = ProviderContainer(
        overrides: [storageServiceProvider.overrideWithValue(storage)],
      );

      final sessionNotifier = container.read(sessionProvider.notifier);
      expect(sessionNotifier, isNotNull);
      expect(sessionNotifier, isA<SessionNotifier>());

      container.dispose();
    });

    test('initial state is null when storage has no session', () {
      final storage = MockStorageService();
      final container = ProviderContainer(
        overrides: [storageServiceProvider.overrideWithValue(storage)],
      );

      final state = container.read(sessionProvider);
      expect(state, isNull);

      container.dispose();
    });

    test('initial state is session from storage', () async {
      final storage = MockStorageService();
      await storage.setString('backend_session_id', 'stored-session');
      final container = ProviderContainer(
        overrides: [storageServiceProvider.overrideWithValue(storage)],
      );

      final state = container.read(sessionProvider);
      expect(state, 'stored-session');

      container.dispose();
    });
  });
}
