import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:writer/repositories/remote_repository.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  group('RemoteRepository', () {
    late MockClient client;
    late RemoteRepository repo;

    setUp(() {
      client = MockClient();
      repo = RemoteRepository('http://test.api', client: client);
      registerFallbackValue(Uri.parse('http://test.api/characters/profile'));
    });

    test('fetchCharacterProfile returns string on success', () async {
      final responseBody = jsonEncode({
        'character_profile': '# Test Profile\nThis is a markdown profile.',
      });

      when(
        () => client.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final result = await repo.fetchCharacterProfile('Test Char');

      expect(result, isNotNull);
      expect(result, contains('# Test Profile'));
      expect(result, contains('markdown profile'));

      verify(
        () => client.post(
          Uri.parse('http://test.api/characters/profile'),
          headers: any(named: 'headers'),
          body: jsonEncode({'name': 'Test Char'}),
        ),
      ).called(1);
    });

    test('fetchCharacterProfile handles 404', () async {
      when(
        () => client.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('Not Found', 404));

      final result = await repo.fetchCharacterProfile('Unknown');
      expect(result, isNull);
    });

    test('fetchCharacterProfile handles exception', () async {
      when(
        () => client.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenThrow(Exception('Network fail'));

      final result = await repo.fetchCharacterProfile('Fail');
      expect(result, isNull);
    });

    test('baseUrl handling with trailing slash', () async {
      repo = RemoteRepository('http://slash.api/', client: client);
      registerFallbackValue(Uri.parse('http://slash.api/characters/profile'));

      when(
        () => client.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('{}', 200));

      await repo.fetchCharacterProfile('Slash');

      verify(
        () => client.post(
          Uri.parse('http://slash.api/characters/profile'),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).called(1);
    });
  });
}
