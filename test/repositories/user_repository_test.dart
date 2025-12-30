import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:writer/repositories/user_repository.dart';

import 'user_repository_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('UserRepository', () {
    late MockClient mockClient;
    late RemoteUserRepository repository;
    const testBaseUrl = 'https://example.com';
    const testSessionId = 'test-session-123';
    const testUserId = 'user-123';
    const testEmail = 'test@example.com';

    setUp(() {
      mockClient = MockClient();
      repository = RemoteUserRepository(
        baseUrl: testBaseUrl,
        client: mockClient,
      );
    });

    test('fetchUser returns user when response is successful', () async {
      final responseData = {
        'id': testUserId,
        'email': testEmail,
        'is_approved': true,
        'is_admin': false,
      };

      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(jsonEncode(responseData), 200));

      final user = await repository.fetchUser(testSessionId);

      expect(user, isNotNull);
      expect(user!.id, equals(testUserId));
      expect(user.email, equals(testEmail));
      expect(user.isApproved, isTrue);
      expect(user.isAdmin, isFalse);

      verify(
        mockClient.get(
          Uri.parse('$testBaseUrl/auth/verify'),
          headers: {'X-Session-Id': testSessionId},
        ),
      ).called(1);
    });

    test('fetchUser returns null when status code is not 200', () async {
      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response('Unauthorized', 401));

      final user = await repository.fetchUser(testSessionId);

      expect(user, isNull);

      verify(
        mockClient.get(
          Uri.parse('$testBaseUrl/auth/verify'),
          headers: {'X-Session-Id': testSessionId},
        ),
      ).called(1);
    });

    test('fetchUser returns null when exception occurs', () async {
      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenThrow(Exception('Network error'));

      final user = await repository.fetchUser(testSessionId);

      expect(user, isNull);

      verify(
        mockClient.get(
          Uri.parse('$testBaseUrl/auth/verify'),
          headers: {'X-Session-Id': testSessionId},
        ),
      ).called(1);
    });

    test('fetchUser handles baseUrl with trailing slash', () async {
      final repositoryWithSlash = RemoteUserRepository(
        baseUrl: '$testBaseUrl/',
        client: mockClient,
      );

      final responseData = {
        'id': testUserId,
        'email': testEmail,
        'is_approved': false,
        'is_admin': false,
      };

      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(jsonEncode(responseData), 200));

      await repositoryWithSlash.fetchUser(testSessionId);

      verify(
        mockClient.get(
          Uri.parse('$testBaseUrl/auth/verify'),
          headers: {'X-Session-Id': testSessionId},
        ),
      ).called(1);
    });

    test('fetchUser handles minimal JSON response', () async {
      final responseData = {'id': testUserId};

      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(jsonEncode(responseData), 200));

      final user = await repository.fetchUser(testSessionId);

      expect(user, isNotNull);
      expect(user!.id, equals(testUserId));
      expect(user.email, isNull);
      expect(user.isApproved, isFalse);
      expect(user.isAdmin, isFalse);
    });

    test('fetchUser handles UTF-8 response correctly', () async {
      final responseData = {
        'id': testUserId,
        'email': 'tëst@example.com',
        'is_approved': true,
        'is_admin': false,
      };

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async =>
            http.Response.bytes(utf8.encode(jsonEncode(responseData)), 200),
      );

      final user = await repository.fetchUser(testSessionId);

      expect(user, isNotNull);
      expect(user!.id, equals(testUserId));
      expect(user.email, equals('tëst@example.com'));
      expect(user.isApproved, isTrue);
      expect(user.isAdmin, isFalse);
    });

    test('fetchUser uses default http.Client when none provided', () {
      final defaultRepository = RemoteUserRepository(baseUrl: testBaseUrl);

      expect(defaultRepository, isA<RemoteUserRepository>());
    });
  });
}
