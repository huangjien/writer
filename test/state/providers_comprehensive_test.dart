import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/services/auth_redirect_service.dart';
import 'package:writer/services/storage_service.dart';
import 'package:writer/state/admin_settings.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/session_state.dart';

class MockRemoteRepository extends Mock implements RemoteRepository {}

class MockAuthRedirectService extends Mock implements AuthRedirectService {}

class MockStorageService extends Mock implements StorageService {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class ManualMockAuthRedirectService implements AuthRedirectService {
  bool called = false;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Future<void> redirectToLogin(Ref ref, {String? currentPath}) async {
    called = true;
  }

  @override
  void navigateBackToOriginal(Ref ref, BuildContext context) {}
}

void main() {
  setUpAll(() {
    registerFallbackValue(const AsyncValue.data(null));
    registerFallbackValue(ProviderContainer());
  });

  group('Providers Comprehensive Tests', () {
    late MockRemoteRepository mockRemote;
    late ManualMockAuthRedirectService mockAuthRedirect;
    late MockStorageService mockStorage;
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockRemote = MockRemoteRepository();
      mockAuthRedirect = ManualMockAuthRedirectService();
      mockStorage = MockStorageService();
      mockPrefs = MockSharedPreferences();

      when(() => mockStorage.getString(any())).thenReturn(null);
      when(
        () => mockStorage.setString(any(), any()),
      ).thenAnswer((_) async => true);
      when(() => mockStorage.remove(any())).thenAnswer((_) async => true);
      when(() => mockPrefs.getString(any())).thenReturn('http://test-ai.com');
      when(
        () => mockPrefs.setString(any(), any()),
      ).thenAnswer((_) async => true);
    });

    group('currentUserProvider', () {
      test('returns null when session is empty', () async {
        final container = ProviderContainer(
          overrides: [
            sessionProvider.overrideWith(
              (ref) => SessionNotifier(mockStorage, null),
            ),
            remoteRepositoryProvider.overrideWithValue(mockRemote),
          ],
        );

        final user = await container.read(currentUserProvider.future);
        expect(user, isNull);
        verifyZeroInteractions(mockRemote);
      });

      test(
        'returns BackendUser when session exists and remote returns valid data',
        () async {
          when(() => mockRemote.get('auth/session')).thenAnswer(
            (_) async => {'id': 'user-123', 'email': 'test@example.com'},
          );

          final container = ProviderContainer(
            overrides: [
              sessionProvider.overrideWith(
                (ref) => SessionNotifier(mockStorage, 'valid-session'),
              ),
              remoteRepositoryProvider.overrideWithValue(mockRemote),
            ],
          );

          final user = await container.read(currentUserProvider.future);
          expect(user, isNotNull);
          expect(user!.id, 'user-123');
          expect(user.email, 'test@example.com');
        },
      );

      test('returns null when remote returns invalid data', () async {
        when(
          () => mockRemote.get('auth/session'),
        ).thenAnswer((_) async => {'invalid': 'data'});

        final container = ProviderContainer(
          overrides: [
            sessionProvider.overrideWith(
              (ref) => SessionNotifier(mockStorage, 'valid-session'),
            ),
            remoteRepositoryProvider.overrideWithValue(mockRemote),
          ],
        );

        final user = await container.read(currentUserProvider.future);
        expect(user, isNull);
      });

      test('returns null when remote returns non-map', () async {
        when(
          () => mockRemote.get('auth/session'),
        ).thenAnswer((_) async => 'string-response');

        final container = ProviderContainer(
          overrides: [
            sessionProvider.overrideWith(
              (ref) => SessionNotifier(mockStorage, 'valid-session'),
            ),
            remoteRepositoryProvider.overrideWithValue(mockRemote),
          ],
        );

        final user = await container.read(currentUserProvider.future);
        expect(user, isNull);
      });
    });

    group('Service Providers', () {
      test('promptsServiceProvider configuration', () {
        final container = ProviderContainer(
          overrides: [
            aiServiceProvider.overrideWith(
              (ref) => AiServiceNotifier(mockPrefs),
            ),
            sessionProvider.overrideWith(
              (ref) => SessionNotifier(mockStorage, 'test-session'),
            ),
          ],
        );

        final service = container.read(promptsServiceProvider);
        expect(service.baseUrl, 'http://test-ai.com');
        expect(service.sessionId, 'test-session');
      });

      test('promptsServiceProvider uses default url on error', () {
        // To test the catch block, we need aiServiceProvider to throw.
        // But aiServiceProvider is a simple provider. If it throws, the watch throws.
        // However, the code has:
        // try { baseUrl = ref.watch(aiServiceProvider); } catch (_) { baseUrl = ... }
        // So if we make the provider throw, it should be caught.

        final container = ProviderContainer(
          overrides: [
            aiServiceProvider.overrideWith((ref) => throw Exception('Fail')),
            sessionProvider.overrideWith(
              (ref) => SessionNotifier(mockStorage, 'test-session'),
            ),
          ],
        );

        final service = container.read(promptsServiceProvider);
        expect(service.baseUrl, 'http://localhost:5600/');
      });

      test('patternsServiceProvider configuration', () {
        final container = ProviderContainer(
          overrides: [
            aiServiceProvider.overrideWith(
              (ref) => AiServiceNotifier(mockPrefs),
            ),
            sessionProvider.overrideWith(
              (ref) => SessionNotifier(mockStorage, 'test-session'),
            ),
          ],
        );

        final service = container.read(patternsServiceProvider);
        expect(service.baseUrl, 'http://test-ai.com');
        expect(service.sessionId, 'test-session');
      });

      test('storyLinesServiceProvider configuration', () {
        final container = ProviderContainer(
          overrides: [
            aiServiceProvider.overrideWith(
              (ref) => AiServiceNotifier(mockPrefs),
            ),
            sessionProvider.overrideWith(
              (ref) => SessionNotifier(mockStorage, 'test-session'),
            ),
          ],
        );

        final service = container.read(storyLinesServiceProvider);
        expect(service.baseUrl, 'http://test-ai.com');
        expect(service.sessionId, 'test-session');
      });

      test(
        'service onUnauthorized callback clears session and redirects',
        () async {
          final sessionNotifier = SessionNotifier(mockStorage, 'test-session');
          // No need to stub ManualMockAuthRedirectService

          final container = ProviderContainer(
            overrides: [
              sessionProvider.overrideWith((ref) => sessionNotifier),
              authRedirectServiceProvider.overrideWithValue(mockAuthRedirect),
            ],
          );

          final service = container.read(promptsServiceProvider);
          expect(service.onUnauthorized, isNotNull);
          await service.onUnauthorized!();

          expect(sessionNotifier.state, isNull);
          expect(mockAuthRedirect.called, isTrue);
        },
      );
    });

    test('isAdminProvider returns false by default', () {
      final container = ProviderContainer(
        overrides: [
          adminModeProvider.overrideWith((ref) => AdminModeNotifier(mockPrefs)),
        ],
      );
      expect(container.read(isAdminProvider), isFalse);
    });
  });
}
