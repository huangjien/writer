import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/storage_service_provider.dart';

class MockRemoteRepository extends Mock implements RemoteRepository {}

class _ErrorRemoteRepository extends RemoteRepository {
  _ErrorRemoteRepository(this.onGet) : super('http://unit.test/');

  final void Function() onGet;

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool retryUnauthorized = true,
  }) async {
    onGet();
    throw Exception('boom');
  }
}

void main() {
  test('isSignedInProvider is true when session id is set', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    final session = SessionNotifier(storageService);
    await session.setSessionId('sid');
    final container = ProviderContainer(
      overrides: [sessionProvider.overrideWith((ref) => session)],
    );
    addTearDown(container.dispose);
    expect(container.read(isSignedInProvider), isTrue);
    expect(container.read(authStateProvider), 'sid');
  });

  test('isSignedInProvider is false for whitespace session id', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    final session = SessionNotifier(storageService);
    await session.setSessionId('   ');
    final container = ProviderContainer(
      overrides: [sessionProvider.overrideWith((ref) => session)],
    );
    addTearDown(container.dispose);
    expect(container.read(isSignedInProvider), isFalse);
  });

  test('currentUserProvider returns null when signed out', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith((ref) => SessionNotifier(storageService)),
      ],
    );
    addTearDown(container.dispose);
    final user = await container.read(currentUserProvider.future);
    expect(user, isNull);
  });

  test('currentUserProvider maps backend user when signed in', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    final remote = MockRemoteRepository();
    when(() => remote.get('auth/session')).thenAnswer((_) async {
      return {'id': 'u1', 'email': 'a@b.com'};
    });
    final session = SessionNotifier(storageService);
    await session.setSessionId('sid');
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith((ref) => session),
        remoteRepositoryProvider.overrideWithValue(remote),
      ],
    );
    addTearDown(container.dispose);

    final user = await container.read(currentUserProvider.future);
    expect(user, isNotNull);
    expect(user!.id, 'u1');
    expect(user.email, 'a@b.com');
    verify(() => remote.get('auth/session')).called(1);
  });

  test('currentUserProvider returns null for invalid response', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    final remote = MockRemoteRepository();
    when(() => remote.get('auth/session')).thenAnswer((_) async {
      return {'email': 'a@b.com'};
    });
    final session = SessionNotifier(storageService);
    await session.setSessionId('sid');
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith((ref) => session),
        remoteRepositoryProvider.overrideWithValue(remote),
      ],
    );
    addTearDown(container.dispose);

    final user = await container.read(currentUserProvider.future);
    expect(user, isNull);
  });

  test('currentUserProvider propagates remote errors', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    final didCallRemote = Completer<void>();
    final didReceiveError = Completer<Object>();
    final remote = _ErrorRemoteRepository(() {
      if (!didCallRemote.isCompleted) {
        didCallRemote.complete();
      }
    });
    final session = SessionNotifier(storageService);
    await session.setSessionId('sid');
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith((ref) => session),
        remoteRepositoryProvider.overrideWithValue(remote),
      ],
    );
    addTearDown(container.dispose);

    final sub = container.listen<AsyncValue<BackendUser?>>(
      currentUserProvider,
      (previous, next) {
        if (next.hasError && !didReceiveError.isCompleted) {
          didReceiveError.complete(next.error!);
        }
      },
      fireImmediately: true,
    );
    addTearDown(sub.close);

    await didCallRemote.future.timeout(const Duration(seconds: 2));
    final err = await didReceiveError.future.timeout(
      const Duration(seconds: 2),
    );
    expect(err, isA<Exception>());
  });
}
