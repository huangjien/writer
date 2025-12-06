import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:writer/repositories/remote_repository.dart';

void main() {
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
  });
}
