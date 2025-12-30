import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:writer/services/auth_service.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('SignInResult', () {
    test('creates successful result', () {
      const sessionId = 'test-session-123';
      final result = SignInResult.success(sessionId);

      expect(result.success, isTrue);
      expect(result.sessionId, equals(sessionId));
      expect(result.errorMessage, isNull);
    });

    test('creates failure result', () {
      const errorMessage = 'Invalid credentials';
      final result = SignInResult.failure(errorMessage);

      expect(result.success, isFalse);
      expect(result.sessionId, isNull);
      expect(result.errorMessage, equals(errorMessage));
    });
  });

  group('RemoteAuthService', () {
    late MockClient mockClient;
    late RemoteAuthService authService;
    const testBaseUrl = 'https://example.com';
    const testEmail = 'test@example.com';
    const testPassword = 'password123';
    const testSessionId = 'session-123';

    setUp(() {
      mockClient = MockClient();
      authService = RemoteAuthService(baseUrl: testBaseUrl, client: mockClient);
    });

    test('signIn returns success when response is valid', () async {
      final responseData = {'session_id': testSessionId};

      when(
        mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response(jsonEncode(responseData), 200));

      final result = await authService.signIn(testEmail, testPassword);

      expect(result.success, isTrue);
      expect(result.sessionId, equals(testSessionId));
      expect(result.errorMessage, isNull);

      verify(
        mockClient.post(
          Uri.parse('$testBaseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': testEmail, 'password': testPassword}),
        ),
      ).called(1);
    });

    test('signIn returns failure when status code is not 200', () async {
      when(
        mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response('Unauthorized', 401));

      final result = await authService.signIn(testEmail, testPassword);

      expect(result.success, isFalse);
      expect(result.sessionId, isNull);
      expect(result.errorMessage, equals('Sign in failed'));
    });

    test('signIn returns failure with error message from response', () async {
      final errorResponse = {'detail': 'Invalid email or password'};

      when(
        mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response(jsonEncode(errorResponse), 401));

      final result = await authService.signIn(testEmail, testPassword);

      expect(result.success, isFalse);
      expect(result.sessionId, isNull);
      expect(result.errorMessage, equals('Invalid email or password'));
    });

    test('signIn returns failure when session_id is missing', () async {
      final responseData = {'other_field': 'value'};

      when(
        mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response(jsonEncode(responseData), 200));

      final result = await authService.signIn(testEmail, testPassword);

      expect(result.success, isFalse);
      expect(result.sessionId, isNull);
      expect(result.errorMessage, equals('Invalid response from server'));
    });

    test('signIn returns failure when session_id is empty string', () async {
      final responseData = {'session_id': ''};

      when(
        mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response(jsonEncode(responseData), 200));

      final result = await authService.signIn(testEmail, testPassword);

      expect(result.success, isFalse);
      expect(result.sessionId, isNull);
      expect(result.errorMessage, equals('Invalid response from server'));
    });

    test('signIn returns failure when session_id is not a string', () async {
      final responseData = {'session_id': 123};

      when(
        mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response(jsonEncode(responseData), 200));

      final result = await authService.signIn(testEmail, testPassword);

      expect(result.success, isFalse);
      expect(result.sessionId, isNull);
      expect(result.errorMessage, equals('Invalid response from server'));
    });

    test('signIn returns failure when exception occurs', () async {
      when(
        mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenThrow(Exception('Network error'));

      final result = await authService.signIn(testEmail, testPassword);

      expect(result.success, isFalse);
      expect(result.sessionId, isNull);
      expect(result.errorMessage, equals('Exception: Network error'));
    });

    test('signIn handles malformed JSON response', () async {
      when(
        mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response('Invalid JSON', 401));

      final result = await authService.signIn(testEmail, testPassword);

      expect(result.success, isFalse);
      expect(result.sessionId, isNull);
      expect(result.errorMessage, equals('Sign in failed'));
    });

    test('signIn handles UTF-8 response correctly', () async {
      final responseData = {'session_id': 'sëssion-123'};

      when(
        mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer(
        (_) async =>
            http.Response.bytes(utf8.encode(jsonEncode(responseData)), 200),
      );

      final result = await authService.signIn(testEmail, testPassword);

      expect(result.success, isTrue);
      expect(result.sessionId, equals('sëssion-123'));
      expect(result.errorMessage, isNull);
    });

    test('signIn uses default http.Client when none provided', () {
      final defaultAuthService = RemoteAuthService(baseUrl: testBaseUrl);

      expect(defaultAuthService, isA<RemoteAuthService>());
    });
  });
}
