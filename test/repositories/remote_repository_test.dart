import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/models/token_usage.dart';
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

  group('RemoteRepository.fetchSceneProfile', () {
    test('returns profile string on 200 with scene_profile', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' &&
            request.url.path.endsWith('scenes/profile')) {
          final body = jsonEncode({'scene_profile': 'profile'});
          return http.Response(body, 200);
        }
        return http.Response('not found', 404);
      });
      final repo = RemoteRepository('http://example.com/', client: client);
      final res = await repo.fetchSceneProfile('Scene A');
      expect(res, 'profile');
    });

    test('returns null on non-200', () async {
      final client = MockClient((request) async => http.Response('bad', 500));
      final repo = RemoteRepository('http://example.com', client: client);
      final res = await repo.fetchSceneProfile('Scene B');
      expect(res, isNull);
    });
  });

  group('RemoteRepository.convertScene', () {
    test('returns result string on 200 with result', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' &&
            request.url.path.endsWith('scenes/convert')) {
          final body = jsonEncode({'result': 'converted'});
          return http.Response(body, 200);
        }
        return http.Response('not found', 404);
      });
      final repo = RemoteRepository('http://example.com', client: client);
      final res = await repo.convertScene(
        name: 'Opening',
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
      final res = await repo.convertScene(
        name: 'Opening',
        templateContent: 'T',
        language: 'en',
      );
      expect(res, 'ok');
      expect(url.toString(), 'http://example.com/scenes/convert');
    });
  });

  group('RemoteRepository auth headers', () {
    test('adds Authorization header when token is available', () async {
      final client = MockClient((request) async {
        expect(request.headers['X-Session-Id'], 'tok');
        return http.Response(jsonEncode({'result': 'ok'}), 200);
      });
      final repo = RemoteRepository(
        'http://example.com/',
        client: client,
        authToken: () async => 'tok',
      );
      final res = await repo.convertCharacter(
        name: 'Alice',
        templateContent: 'T',
        language: 'en',
      );
      expect(res, 'ok');
    });

    test('omits Authorization header when token getter throws', () async {
      final client = MockClient((request) async {
        expect(request.headers.containsKey('X-Session-Id'), false);
        return http.Response(jsonEncode({'result': 'ok'}), 200);
      });
      final repo = RemoteRepository(
        'http://example.com/',
        client: client,
        authToken: () async {
          throw Exception('token error');
        },
      );
      final res = await repo.convertCharacter(
        name: 'Alice',
        templateContent: 'T',
        language: 'en',
      );
      expect(res, 'ok');
    });
  });

  group('RemoteRepository HTTP methods', () {
    test('get method handles empty response body', () async {
      final client = MockClient((request) async => http.Response('', 204));
      final repo = RemoteRepository('http://example.com/', client: client);
      final result = await repo.get('test');
      expect(result, isNull);
    });

    test('get method with query parameters', () async {
      late Uri capturedUri;
      final client = MockClient((request) async {
        capturedUri = request.url;
        return http.Response(jsonEncode({'result': 'data'}), 200);
      });
      final repo = RemoteRepository('http://example.com/', client: client);
      await repo.get('test', queryParameters: {'param': 'value', 'limit': '10'});
      expect(capturedUri.queryParameters['param'], 'value');
      expect(capturedUri.queryParameters['limit'], '10');
    });

    test('get method throws on error status code', () async {
      final client = MockClient((request) async => http.Response('Not found', 404));
      final repo = RemoteRepository('http://example.com/', client: client);
      expect(
        () => repo.get('test'),
        throwsException,
      );
    });

    test('post method with retryUnauthorized flag', () async {
      late bool capturedRetry;
      final client = MockClient((request) async {
        capturedRetry = request.url.queryParameters.containsKey('retry');
        return http.Response(jsonEncode({'result': 'success'}), 200);
      });
      final repo = RemoteRepository('http://example.com/', client: client);
      await repo.post('test', {'data': 'value'}, retryUnauthorized: true);
      expect(capturedRetry, isFalse); // retryUnauthorized doesn't affect URL
    });

    test('patch method works correctly', () async {
      final client = MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.body, jsonEncode({'data': 'patched'}));
        return http.Response(jsonEncode({'result': 'patched'}), 200);
      });
      final repo = RemoteRepository('http://example.com/', client: client);
      final result = await repo.patch('test', {'data': 'patched'});
      expect(result['result'], 'patched');
    });

    test('delete method works correctly', () async {
      final client = MockClient((request) async {
        expect(request.method, 'DELETE');
        return http.Response('', 204);
      });
      final repo = RemoteRepository('http://example.com/', client: client);
      await repo.delete('test');
    });

    test('delete method with query parameters', () async {
      late Uri capturedUri;
      final client = MockClient((request) async {
        capturedUri = request.url;
        expect(request.method, 'DELETE');
        return http.Response('', 204);
      });
      final repo = RemoteRepository('http://example.com/', client: client);
      await repo.delete('test', queryParameters: {'confirm': 'true'});
      expect(capturedUri.queryParameters['confirm'], 'true');
    });
  });

  group('RemoteRepository auth retry logic', () {
    var unauthorizedCallCount = 0;
    
    setUp(() {
      unauthorizedCallCount = 0;
    });

    test('retries GET request after 401 with auth', () async {
      final client = MockClient((request) async {
        if (unauthorizedCallCount == 0) {
          unauthorizedCallCount++;
          return http.Response('Unauthorized', 401);
        }
        return http.Response(jsonEncode({'result': 'retry-success'}), 200);
      });
      
      var onUnauthorizedCalled = false;
      final repo = RemoteRepository(
        'http://example.com/',
        client: client,
        authToken: () async => 'token',
        onUnauthorized: () async {
          onUnauthorizedCalled = true;
        },
      );
      
      final result = await repo.get('test');
      expect(onUnauthorizedCalled, isTrue);
      expect(result['result'], 'retry-success');
    });

    test('retries POST request after 401 with auth', () async {
      final client = MockClient((request) async {
        if (unauthorizedCallCount == 0) {
          unauthorizedCallCount++;
          return http.Response('Unauthorized', 401);
        }
        return http.Response(jsonEncode({'result': 'retry-success'}), 200);
      });
      
      final repo = RemoteRepository(
        'http://example.com/',
        client: client,
        authToken: () async => 'token',
        onUnauthorized: () async {},
      );
      
      final result = await repo.post('test', {'data': 'value'}, retryUnauthorized: true);
      expect(result['result'], 'retry-success');
    });

    test('does not retry when retryUnauthorized is false', () async {
      final client = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });
      
      final repo = RemoteRepository(
        'http://example.com/',
        client: client,
        authToken: () async => 'token',
        onUnauthorized: () async {},
      );
      
      expect(
        () => repo.post('test', {'data': 'value'}, retryUnauthorized: false),
        throwsException,
      );
    });
  });

  group('RemoteRepository token usage methods', () {
    test('getCurrentMonthUsage returns TokenUsage on success', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'user_id': 'test-user',
            'year': 2024,
            'month': 1,
            'input_tokens': 600,
            'output_tokens': 400,
            'total_tokens': 1000,
            'request_count': 25,
          }),
          200,
        );
      });
      final repo = RemoteRepository('http://example.com/', client: client);
      final usage = await repo.getCurrentMonthUsage();
      expect(usage?.inputTokens, 600);
      expect(usage?.outputTokens, 400);
      expect(usage?.totalTokens, 1000);
      expect(usage?.requestCount, 25);
    });

    test('getCurrentMonthUsage throws on failure', () async {
      final client = MockClient((request) async => http.Response('Error', 500));
      final repo = RemoteRepository('http://example.com/', client: client);
      expect(
        () => repo.getCurrentMonthUsage(),
        throwsException,
      );
    });

    test('getUsageHistory with date parameters', () async {
      final client = MockClient((request) async {
        expect(request.url.queryParameters['start_date'], '2024-01-01');
        expect(request.url.queryParameters['end_date'], '2024-01-31');
        expect(request.url.queryParameters['limit'], '50');
        expect(request.url.queryParameters['offset'], '10');
        return http.Response(
          jsonEncode({
            'records': [
              {
                'operation_type': 'ai_chat',
                'model_name': 'gpt-4',
                'input_tokens': 50,
                'output_tokens': 50,
                'created_at': '2024-01-01T12:00:00Z',
              }
            ],
            'total_count': 1,
          }),
          200,
        );
      });
      final repo = RemoteRepository('http://example.com/', client: client);
      final history = await repo.getUsageHistory(
        startDate: '2024-01-01',
        endDate: '2024-01-31',
        limit: 50,
        offset: 10,
      );
      expect(history, isNotNull);
      expect(history!.records.length, 1);
      expect(history.records.first.operationType, 'ai_chat');
      expect(history.totalCount, 1);
    });

    test('getAdminLogs returns logs string', () async {
      final client = MockClient((request) async {
        expect(request.url.queryParameters['lines'], '500');
        return http.Response(
          jsonEncode({'logs': 'Log line 1\nLog line 2'}),
          200,
        );
      });
      final repo = RemoteRepository('http://example.com/', client: client);
      final logs = await repo.getAdminLogs(lines: 500);
      expect(logs, 'Log line 1\nLog line 2');
    });

    test('getAdminLogs throws on failure', () async {
      final client = MockClient((request) async => http.Response('Error', 500));
      final repo = RemoteRepository('http://example.com/', client: client);
      expect(
        () => repo.getAdminLogs(),
        throwsException,
      );
    });
  });

  group('RemoteRepository URL construction', () {
    test('handles baseUrl without trailing slash', () async {
      late Uri capturedUri;
      final client = MockClient((request) async {
        capturedUri = request.url;
        return http.Response(jsonEncode({'result': 'ok'}), 200);
      });
      final repo = RemoteRepository('http://example.com', client: client);
      await repo.get('api/test');
      expect(capturedUri.toString(), 'http://example.com/api/test');
    });

    test('handles baseUrl with trailing slash', () async {
      late Uri capturedUri;
      final client = MockClient((request) async {
        capturedUri = request.url;
        return http.Response(jsonEncode({'result': 'ok'}), 200);
      });
      final repo = RemoteRepository('http://example.com/', client: client);
      await repo.get('api/test');
      expect(capturedUri.toString(), 'http://example.com/api/test');
    });
  });

  group('RemoteRepository error handling', () {
    test('handles JSON decode errors gracefully', () async {
      final client = MockClient((request) async {
        return http.Response('Invalid JSON {', 200);
      });
      final repo = RemoteRepository('http://example.com/', client: client);
      expect(
        () => repo.get('test'),
        throwsException,
      );
    });

    test('rethrows exceptions from HTTP client', () async {
      final client = MockClient((request) async {
        throw Exception('Network error');
      });
      final repo = RemoteRepository('http://example.com/', client: client);
      expect(
        () => repo.get('test'),
        throwsException,
      );
    });
  });
}
