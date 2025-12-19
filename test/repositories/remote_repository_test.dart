import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('remoteRepositoryProvider', () {
    test('falls back when aiServiceProvider is not overridden', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(remoteRepositoryProvider);
      expect(repo.baseUrl, 'http://localhost:5600/');
    });

    test('uses aiServiceProvider when overridden', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ai_service_url', 'http://example.com/');

      final container = ProviderContainer(
        overrides: [
          aiServiceProvider.overrideWith((ref) => AiServiceNotifier(prefs)),
        ],
      );
      addTearDown(container.dispose);

      final repo = container.read(remoteRepositoryProvider);
      expect(repo.baseUrl, 'http://example.com/');
    });
  });

  group('RemoteRepository.fetchCharacterProfile', () {
    test('returns profile string on 200 with character_profile', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' &&
            request.url.path.endsWith('characters/profile')) {
          final body = jsonEncode({'character_profile': 'bio'});
          return http.Response(body, 200);
        }
        return http.Response('not found', 404);
      });
      final repo = RemoteRepository('http://example.com/', client: client);
      final res = await repo.fetchCharacterProfile('Alice');
      expect(res, 'bio');
    });

    test('returns null on non-200', () async {
      final client = MockClient((request) async => http.Response('bad', 500));
      final repo = RemoteRepository('http://example.com', client: client);
      final res = await repo.fetchCharacterProfile('Bob');
      expect(res, isNull);
    });

    test('returns null when body missing key', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' &&
            request.url.path.endsWith('characters/profile')) {
          final body = jsonEncode({'x': 1});
          return http.Response(body, 200);
        }
        return http.Response('not found', 404);
      });
      final repo = RemoteRepository('http://example.com/', client: client);
      final res = await repo.fetchCharacterProfile('Carol');
      expect(res, isNull);
    });

    test('returns null when response is not valid json', () async {
      final client = MockClient(
        (request) async => http.Response('{"character_profile":', 200),
      );
      final repo = RemoteRepository('http://example.com/', client: client);
      final res = await repo.fetchCharacterProfile('Alice');
      expect(res, isNull);
    });

    test('returns null when http client throws', () async {
      final client = MockClient((request) async {
        throw Exception('network');
      });
      final repo = RemoteRepository('http://example.com/', client: client);
      final res = await repo.fetchCharacterProfile('Alice');
      expect(res, isNull);
    });
  });

  group('RemoteRepository.convertCharacter', () {
    test('returns result string on 200 with result', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' &&
            request.url.path.endsWith('agents/character-convert')) {
          final body = jsonEncode({'result': 'converted'});
          return http.Response(body, 200);
        }
        return http.Response('not found', 404);
      });
      final repo = RemoteRepository('http://example.com', client: client);
      final res = await repo.convertCharacter(
        name: 'Alice',
        templateContent: 'T',
        language: 'en',
      );
      expect(res, 'converted');
    });

    test('uses trailing slash baseUrl correctly', () async {
      late Uri url;
      final client = MockClient((request) async {
        url = request.url;
        return http.Response(jsonEncode({'result': 'ok'}), 200);
      });
      final repo = RemoteRepository('http://example.com/', client: client);
      final res = await repo.convertCharacter(
        name: 'Alice',
        templateContent: 'T',
        language: 'en',
      );
      expect(res, 'ok');
      expect(url.toString(), 'http://example.com/agents/character-convert');
    });

    test('returns null on non-200', () async {
      final client = MockClient((request) async => http.Response('bad', 500));
      final repo = RemoteRepository('http://example.com/', client: client);
      final res = await repo.convertCharacter(
        name: 'Bob',
        templateContent: 'T',
        language: 'en',
      );
      expect(res, isNull);
    });

    test('returns null when body missing key', () async {
      final client = MockClient(
        (request) async => http.Response(jsonEncode({'x': 1}), 200),
      );
      final repo = RemoteRepository('http://example.com/', client: client);
      final res = await repo.convertCharacter(
        name: 'Bob',
        templateContent: 'T',
        language: 'en',
      );
      expect(res, isNull);
    });

    test('returns null when response is not valid json', () async {
      final client = MockClient(
        (request) async => http.Response('{"result":', 200),
      );
      final repo = RemoteRepository('http://example.com/', client: client);
      final res = await repo.convertCharacter(
        name: 'Bob',
        templateContent: 'T',
        language: 'en',
      );
      expect(res, isNull);
    });

    test('returns null when http client throws', () async {
      final client = MockClient((request) async {
        throw Exception('network');
      });
      final repo = RemoteRepository('http://example.com/', client: client);
      final res = await repo.convertCharacter(
        name: 'Bob',
        templateContent: 'T',
        language: 'en',
      );
      expect(res, isNull);
    });
  });
}
