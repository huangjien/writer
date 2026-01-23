import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/storage_service_provider.dart';

class MockHttpClient extends Mock implements http.Client {}

class _MockUri extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(_MockUri());
  });

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
    final client = MockHttpClient();
    final session = SessionNotifier(storageService);
    await session.setSessionId('sid');

    when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer((
      invocation,
    ) async {
      final uri = invocation.positionalArguments[0] as Uri;
      if (uri.toString() != 'http://localhost:5600/auth/session') {
        return http.Response(jsonEncode({'detail': 'not found'}), 404);
      }
      return http.Response(jsonEncode({'id': 'u1', 'email': 'a@b.com'}), 200);
    });

    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith((ref) => session),
        httpClientProvider.overrideWithValue(client),
      ],
    );
    addTearDown(container.dispose);

    final user = await container.read(currentUserProvider.future);
    expect(user, isNotNull);
    expect(user!.id, 'u1');
    expect(user.email, 'a@b.com');
    verify(
      () => client.get(
        Uri.parse('http://localhost:5600/auth/session'),
        headers: any(named: 'headers'),
      ),
    ).called(1);
  });

  test('currentUserProvider returns null for invalid response', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    final client = MockHttpClient();
    when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer((
      _,
    ) async {
      return http.Response(jsonEncode({'email': 'a@b.com'}), 200);
    });
    final session = SessionNotifier(storageService);
    await session.setSessionId('sid');
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith((ref) => session),
        httpClientProvider.overrideWithValue(client),
      ],
    );
    addTearDown(container.dispose);

    final user = await container.read(currentUserProvider.future);
    expect(user, isNull);
  });

  test('currentUserProvider returns null for remote errors', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    final didCallRemote = Completer<void>();
    final client = MockHttpClient();

    when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer((
      _,
    ) async {
      if (!didCallRemote.isCompleted) {
        didCallRemote.complete();
      }
      throw Exception('boom');
    });

    final session = SessionNotifier(storageService);
    await session.setSessionId('sid');
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith((ref) => session),
        httpClientProvider.overrideWithValue(client),
      ],
    );
    addTearDown(container.dispose);

    final future = container.read(currentUserProvider.future);
    await didCallRemote.future.timeout(const Duration(seconds: 2));
    final user = await future;
    expect(user, isNull);
  });
}
