import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:writer/services/auth_service.dart';

class MockHttpClient implements http.Client {
  final int statusCode;
  final Map<String, dynamic> responseBody;
  final String? rawBody;
  final Exception? throwException;

  MockHttpClient({
    this.statusCode = 200,
    this.responseBody = const {},
    this.rawBody,
    this.throwException,
  });

  @override
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    if (throwException != null) {
      throw throwException!;
    }
    final bodyContent = rawBody ?? jsonEncode(responseBody);
    return Future.value(http.Response(bodyContent, statusCode));
  }

  @override
  noSuchMethod(Invocation invocation) => Future.value(http.Response('{}', 404));
}

void main() {
  group('SignInResult', () {
    test('success creates result with session ID', () {
      final result = SignInResult.success(
        'session-123',
        refreshToken: 'refresh-abc',
      );
      expect(result.success, true);
      expect(result.sessionId, 'session-123');
      expect(result.refreshToken, 'refresh-abc');
      expect(result.errorMessage, isNull);
    });

    test('success creates result without refresh token', () {
      final result = SignInResult.success('session-123');
      expect(result.success, true);
      expect(result.sessionId, 'session-123');
      expect(result.refreshToken, isNull);
    });

    test('failure creates result with error message', () {
      final result = SignInResult.failure('Invalid credentials');
      expect(result.success, false);
      expect(result.errorMessage, 'Invalid credentials');
      expect(result.sessionId, isNull);
      expect(result.refreshToken, isNull);
    });
  });

  group('RemoteAuthService', () {
    late MockHttpClient mockClient;
    late RemoteAuthService authService;

    setUp(() {
      mockClient = MockHttpClient();
      authService = RemoteAuthService(
        baseUrl: 'https://api.example.com',
        client: mockClient,
      );
    });

    group('signIn', () {
      test(
        'returns success with session and refresh token on successful login',
        () async {
          mockClient = MockHttpClient(
            statusCode: 200,
            responseBody: {
              'session_id': 'session-123',
              'refresh_token': 'refresh-abc',
            },
          );
          authService = RemoteAuthService(
            baseUrl: 'https://api.example.com',
            client: mockClient,
          );

          final result = await authService.signIn(
            'user@example.com',
            'password123',
          );

          expect(result.success, true);
          expect(result.sessionId, 'session-123');
          expect(result.refreshToken, 'refresh-abc');
        },
      );

      test(
        'returns success with session only when refresh token not provided',
        () async {
          mockClient = MockHttpClient(
            statusCode: 200,
            responseBody: {'session_id': 'session-456'},
          );
          authService = RemoteAuthService(
            baseUrl: 'https://api.example.com',
            client: mockClient,
          );

          final result = await authService.signIn(
            'user@example.com',
            'password123',
          );

          expect(result.success, true);
          expect(result.sessionId, 'session-456');
          expect(result.refreshToken, isNull);
        },
      );

      test('returns failure on non-200 status', () async {
        mockClient = MockHttpClient(
          statusCode: 401,
          responseBody: {'detail': 'Invalid credentials'},
        );
        authService = RemoteAuthService(
          baseUrl: 'https://api.example.com',
          client: mockClient,
        );

        final result = await authService.signIn(
          'user@example.com',
          'wrong-password',
        );

        expect(result.success, false);
        expect(result.errorMessage, 'Invalid credentials');
      });

      test(
        'returns default error message on non-200 status without detail',
        () async {
          mockClient = MockHttpClient(statusCode: 500, rawBody: 'Error');
          authService = RemoteAuthService(
            baseUrl: 'https://api.example.com',
            client: mockClient,
          );

          final result = await authService.signIn(
            'user@example.com',
            'password123',
          );

          expect(result.success, false);
          expect(result.errorMessage, 'Sign in failed');
        },
      );

      test(
        'returns failure on invalid response with empty session_id',
        () async {
          mockClient = MockHttpClient(
            statusCode: 200,
            responseBody: {'session_id': ''},
          );
          authService = RemoteAuthService(
            baseUrl: 'https://api.example.com',
            client: mockClient,
          );

          final result = await authService.signIn(
            'user@example.com',
            'password123',
          );

          expect(result.success, false);
          expect(result.errorMessage, 'Invalid response from server');
        },
      );

      test('returns failure on exception', () async {
        mockClient = MockHttpClient(throwException: Exception('Network error'));
        authService = RemoteAuthService(
          baseUrl: 'https://api.example.com',
          client: mockClient,
        );

        final result = await authService.signIn(
          'user@example.com',
          'password123',
        );

        expect(result.success, false);
        expect(result.errorMessage, contains('Exception'));
      });
    });

    group('refresh', () {
      test('returns success with new session and refresh token', () async {
        mockClient = MockHttpClient(
          statusCode: 200,
          responseBody: {
            'session_id': 'new-session',
            'refresh_token': 'new-refresh',
          },
        );
        authService = RemoteAuthService(
          baseUrl: 'https://api.example.com',
          client: mockClient,
        );

        final result = await authService.refresh('old-refresh-token');

        expect(result.success, true);
        expect(result.sessionId, 'new-session');
        expect(result.refreshToken, 'new-refresh');
      });

      test(
        'returns success with session only when refresh token not provided',
        () async {
          mockClient = MockHttpClient(
            statusCode: 200,
            responseBody: {'session_id': 'new-session-only'},
          );
          authService = RemoteAuthService(
            baseUrl: 'https://api.example.com',
            client: mockClient,
          );

          final result = await authService.refresh('old-refresh-token');

          expect(result.success, true);
          expect(result.sessionId, 'new-session-only');
          expect(result.refreshToken, isNull);
        },
      );

      test('returns failure on non-200 status', () async {
        mockClient = MockHttpClient(
          statusCode: 401,
          responseBody: {'detail': 'Invalid token'},
        );
        authService = RemoteAuthService(
          baseUrl: 'https://api.example.com',
          client: mockClient,
        );

        final result = await authService.refresh('invalid-token');

        expect(result.success, false);
        expect(result.errorMessage, 'Invalid token');
      });

      test(
        'returns default error message on non-200 status without detail',
        () async {
          mockClient = MockHttpClient(statusCode: 400, rawBody: 'Error');
          authService = RemoteAuthService(
            baseUrl: 'https://api.example.com',
            client: mockClient,
          );

          final result = await authService.refresh('some-token');

          expect(result.success, false);
          expect(result.errorMessage, 'Refresh failed');
        },
      );

      test(
        'returns failure on invalid response with empty session_id',
        () async {
          mockClient = MockHttpClient(
            statusCode: 200,
            responseBody: {'session_id': ''},
          );
          authService = RemoteAuthService(
            baseUrl: 'https://api.example.com',
            client: mockClient,
          );

          final result = await authService.refresh('token');

          expect(result.success, false);
          expect(result.errorMessage, 'Invalid response from server');
        },
      );

      test('returns failure on exception', () async {
        mockClient = MockHttpClient(
          throwException: Exception('Connection failed'),
        );
        authService = RemoteAuthService(
          baseUrl: 'https://api.example.com',
          client: mockClient,
        );

        final result = await authService.refresh('token');

        expect(result.success, false);
        expect(result.errorMessage, contains('Exception'));
      });
    });
  });
}
