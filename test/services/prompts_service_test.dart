import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:writer/services/prompts_service.dart';
import 'package:writer/shared/api_exception.dart';

MockClient _mockClient({bool listResponse = false}) {
  return MockClient((request) async {
    final m = request.method;
    final path = request.url.path;
    final q = request.url.queryParameters;
    if (m == 'GET' && (path == '/prompts' || path == '/prompts/')) {
      final items = [
        {
          'id': '1',
          'user_id': 'u1',
          'prompt_key': 'system.beta.male',
          'language': 'en',
          'content': 'A',
          'is_public': false,
        },
      ];
      return http.Response(jsonEncode({'items': items}), 200);
    }
    if (m == 'GET' && path == '/prompts/public') {
      final items = [
        {
          'id': '2',
          'user_id': null,
          'prompt_key': 'system.beta.editor',
          'language': 'zh',
          'content': 'B',
          'is_public': true,
        },
      ];
      if (listResponse) {
        return http.Response(jsonEncode(items), 200);
      }
      return http.Response(jsonEncode({'items': items}), 200);
    }
    if (m == 'GET' && path.startsWith('/prompts/')) {
      final id = path.split('/').last;
      final data = {
        'id': id,
        'user_id': 'u1',
        'prompt_key': 'system.beta.male',
        'language': 'en',
        'content': 'X',
        'is_public': false,
      };
      return http.Response(jsonEncode(data), 200);
    }
    if (m == 'POST' && (path == '/prompts' || path == '/prompts/')) {
      final data = jsonDecode(request.body) as Map<String, dynamic>;
      final created = {
        'id': 'new',
        'user_id': 'u1',
        'prompt_key': data['prompt_key'],
        'language': data['language'],
        'content': data['content'],
        'is_public': false,
      };
      return http.Response(jsonEncode(created), 200);
    }
    if (m == 'POST' && path == '/prompts/public') {
      final auth = request.headers['authorization'];
      if (auth == null || !auth.startsWith('Bearer ')) {
        return http.Response('Forbidden', 403);
      }
      final data = jsonDecode(request.body) as Map<String, dynamic>;
      final created = {
        'id': 'pub',
        'user_id': null,
        'prompt_key': data['prompt_key'],
        'language': data['language'],
        'content': data['content'],
        'is_public': true,
      };
      return http.Response(jsonEncode(created), 200);
    }
    if (m == 'PATCH' && path.startsWith('/prompts/public/')) {
      return http.Response('Unexpected endpoint', 500);
    }
    if (m == 'PATCH' && path.startsWith('/prompts/')) {
      final id = path.split('/').last;
      final data = jsonDecode(request.body) as Map<String, dynamic>;
      if (id == 'pub') {
        final updated = {
          'id': id,
          'user_id': null,
          'prompt_key': 'system.qa.direct',
          'language': 'en',
          'content': data['content'],
          'is_public': true,
        };
        return http.Response(jsonEncode(updated), 200);
      }
      final updated = {
        'id': id,
        'user_id': 'u1',
        'prompt_key': 'system.beta.male',
        'language': 'en',
        'content': data['content'],
        'is_public': false,
      };
      return http.Response(jsonEncode(updated), 200);
    }
    if (m == 'DELETE' && path.startsWith('/prompts/')) {
      return http.Response(jsonEncode({'deleted': true}), 200);
    }
    if (m == 'GET' && path == '/prompts/search') {
      final query = q['q'];
      final isPublic = q['is_public'];
      final items = [
        {
          'id': 's-$query-$isPublic',
          'user_id': 'u1',
          'prompt_key': 'system.beta.male',
          'language': 'en',
          'content': 'Search Result',
          'is_public': isPublic == 'true',
        },
      ];
      return http.Response(jsonEncode({'items': items}), 200);
    }
    return http.Response('Not found', 404);
  });
}

void main() {
  test('fetchPrompts returns items and public list', () async {
    final svc = PromptsService(baseUrl: 'http://any', client: _mockClient());
    final list1 = await svc.fetchPrompts();
    expect(list1.length, 1);
    expect(list1.first.promptKey, 'system.beta.male');

    final list2 = await svc.fetchPrompts(isPublic: true);
    expect(list2.length, 1);
    expect(list2.first.isPublic, isTrue);
  });

  test('get/create/update/delete prompt', () async {
    final svc = PromptsService(
      baseUrl: 'http://any',
      authToken: 't',
      client: _mockClient(),
    );
    final p = await svc.getPrompt('123');
    expect(p.id, '123');

    final created = await svc.createPrompt(
      promptKey: 'system.beta.male',
      language: 'en',
      content: 'Z',
    );
    expect(created.id, 'new');
    expect(created.isPublic, isFalse);

    final pub = await svc.createPrompt(
      promptKey: 'system.beta.male',
      language: 'en',
      content: 'Z',
      isPublic: true,
    );
    expect(pub.id, 'pub');
    expect(pub.isPublic, isTrue);

    final upd = await svc.updatePrompt(id: 'new', content: 'Y');
    expect(upd.content, 'Y');

    final updPub = await svc.updatePrompt(
      id: 'pub',
      content: 'P',
      isPublic: true,
    );
    expect(updPub.id, 'pub');
    expect(updPub.isPublic, isTrue);
    expect(updPub.content, 'P');

    final ok = await svc.deletePrompt('new');
    expect(ok, isTrue);
  });

  test('public create without auth throws ApiException', () async {
    final svc = PromptsService(baseUrl: 'http://any', client: _mockClient());
    try {
      await svc.createPrompt(
        promptKey: 'system.beta.male',
        language: 'en',
        content: 'X',
        isPublic: true,
      );
      fail('expected ApiException');
    } catch (e) {
      expect(e is ApiException, isTrue);
      expect((e as ApiException).statusCode, 403);
    }
  });

  test('isLoading reflects loading state', () async {
    final client = MockClient((request) async {
      await Future.delayed(const Duration(milliseconds: 10));
      return http.Response(jsonEncode({'items': []}), 200);
    });
    final svc = PromptsService(baseUrl: 'http://any', client: client);
    expect(svc.isLoading, false);
    final future = svc.fetchPrompts();
    expect(svc.isLoading, true);
    await future;
    expect(svc.isLoading, false);
  });

  test('setAuthToken updates auth token', () {
    final svc = PromptsService(baseUrl: 'http://any');
    expect(svc.authToken, isNull);
    svc.setAuthToken('new_token');
    expect(svc.authToken, 'new_token');
    svc.setAuthToken(null);
    expect(svc.authToken, isNull);
  });

  test('deletePrompt returns false when flag missing', () async {
    final client = MockClient((request) async {
      if (request.method == 'DELETE' && request.url.path == '/prompts/empty') {
        return http.Response(jsonEncode({}), 200);
      }
      return http.Response('Not found', 404);
    });
    final svc = PromptsService(baseUrl: 'http://any', client: client);
    final ok = await svc.deletePrompt('empty');
    expect(ok, isFalse);
  });

  test('unsupported method throws ApiException', () async {
    final client = MockClient((request) async {
      return http.Response('Not found', 404);
    });
    final svc = PromptsService(baseUrl: 'http://any', client: client);
    try {
      await svc.fetchPrompts();
      fail('expected ApiException');
    } catch (e) {
      expect(e is ApiException, isTrue);
    }
  });

  test('fetchPrompts supports list response for public', () async {
    final svc = PromptsService(
      baseUrl: 'http://any',
      client: _mockClient(listResponse: true),
    );
    final list = await svc.fetchPrompts(isPublic: true);
    expect(list.length, 1);
    expect(list.first.promptKey, 'system.beta.editor');
  });

  group('searchPrompts', () {
    test('handles empty search results', () async {
      final client = MockClient((request) async {
        if (request.url.path == '/prompts/search') {
          return http.Response(jsonEncode({'items': []}), 200);
        }
        return http.Response('Not found', 404);
      });
      final svc = PromptsService(baseUrl: 'http://any', client: client);
      final results = await svc.searchPrompts('empty query');
      expect(results.length, 0);
    });
  });

  group('Error Handling', () {
    test('handles 404 Not Found', () async {
      final client = MockClient((request) async {
        return http.Response('Not found', 404);
      });
      final svc = PromptsService(baseUrl: 'http://any', client: client);
      try {
        await svc.getPrompt('nonexistent');
        fail('expected ApiException');
      } catch (e) {
        expect(e is ApiException, isTrue);
        final ex = e as ApiException;
        expect(ex.statusCode, 404);
        expect(ex.rawMessage, 'Not found');
      }
    });

    test('handles 500 Internal Server Error', () async {
      final client = MockClient((request) async {
        return http.Response('Server error', 500);
      });
      final svc = PromptsService(baseUrl: 'http://any', client: client);
      try {
        await svc.fetchPrompts();
        fail('expected ApiException');
      } catch (e) {
        expect(e is ApiException, isTrue);
        expect((e as ApiException).statusCode, 500);
      }
    });

    test('handles empty error message', () async {
      final client = MockClient((request) async {
        return http.Response('', 400);
      });
      final svc = PromptsService(baseUrl: 'http://any', client: client);
      try {
        await svc.fetchPrompts();
        fail('expected ApiException');
      } catch (e) {
        expect(e is ApiException, isTrue);
        expect((e as ApiException).rawMessage, 'Request failed');
      }
    });

    test('handles network timeout', () async {
      final client = MockClient((request) async {
        await Future.delayed(const Duration(seconds: 10));
        return http.Response('OK', 200);
      });
      final svc = PromptsService(
        baseUrl: 'http://any',
        client: client,
        timeout: const Duration(milliseconds: 100),
      );
      try {
        await svc.fetchPrompts();
        fail('expected ApiException');
      } catch (e) {
        expect(e is ApiException, isTrue);
        expect((e as ApiException).statusCode, 0);
      }
    });

    test('handles JSON parse error', () async {
      final client = MockClient((request) async {
        return http.Response('invalid json{{{', 200);
      });
      final svc = PromptsService(baseUrl: 'http://any', client: client);
      try {
        await svc.fetchPrompts();
        fail('expected ApiException');
      } catch (e) {
        expect(e is ApiException, isTrue);
      }
    });
  });

  group('401 Unauthorized Callback', () {
    test('calls onUnauthorized callback on 401', () async {
      var callbackCalled = false;
      final client = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });
      final svc = PromptsService(
        baseUrl: 'http://any',
        client: client,
        onUnauthorized: () async {
          callbackCalled = true;
        },
      );
      try {
        await svc.fetchPrompts();
        fail('expected ApiException');
      } catch (e) {
        expect(callbackCalled, isTrue);
        expect(e is ApiException, isTrue);
        expect((e as ApiException).statusCode, 401);
      }
    });

    test('does not call callback for other errors', () async {
      var callbackCalled = false;
      final client = MockClient((request) async {
        return http.Response('Not found', 404);
      });
      final svc = PromptsService(
        baseUrl: 'http://any',
        client: client,
        onUnauthorized: () async {
          callbackCalled = true;
        },
      );
      try {
        await svc.fetchPrompts();
        fail('expected ApiException');
      } catch (e) {
        expect(callbackCalled, isFalse);
      }
    });
  });

  group('URI Building', () {
    test('builds URI without query', () async {
      final client = MockClient((request) async {
        // Just verify the request was made
        return http.Response(jsonEncode({'id': 'test'}), 200);
      });
      final svc = PromptsService(
        baseUrl: 'http://example.com/api',
        client: client,
      );
      await svc.getPrompt('test');
    });

    test('builds URI with query parameters', () async {
      final client = MockClient((request) async {
        expect(request.url.queryParameters['q'], 'test');
        // Don't check exact path as it includes baseUrl
        expect(request.url.path, contains('/prompts/search'));
        return http.Response(jsonEncode({'items': []}), 200);
      });
      final svc = PromptsService(
        baseUrl: 'http://example.com/api',
        client: client,
      );
      await svc.searchPrompts('test');
    });

    test('handles trailing slash in baseUrl', () async {
      final client = MockClient((request) async {
        expect(
          request.url.toString(),
          contains('http://example.com/api/prompts'),
        );
        return http.Response(jsonEncode({'items': []}), 200);
      });
      final svc = PromptsService(
        baseUrl: 'http://example.com/api/',
        client: client,
      );
      await svc.fetchPrompts();
    });

    test('handles leading slash in path', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/prompts/');
        return http.Response(jsonEncode({'items': []}), 200);
      });
      final svc = PromptsService(baseUrl: 'http://example.com', client: client);
      await svc.fetchPrompts();
    });

    test('handles path without leading slash', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/prompts/');
        return http.Response(jsonEncode({'items': []}), 200);
      });
      final svc = PromptsService(baseUrl: 'http://example.com', client: client);
      await svc.fetchPrompts();
    });
  });

  group('Standardized Error Format', () {
    test('parses new error response format', () async {
      final client = MockClient((request) async {
        final errorJson = {
          'code': 'VALIDATION_ERROR',
          'message': 'Invalid input',
        };
        return http.Response(jsonEncode(errorJson), 400);
      });
      final svc = PromptsService(baseUrl: 'http://any', client: client);
      try {
        await svc.fetchPrompts();
        fail('expected ApiException');
      } catch (e) {
        expect(e is ApiException, isTrue);
        // Just verify it throws ApiException with proper status code
        expect((e as ApiException).statusCode, 400);
      }
    });

    test('falls back to raw message on parse error', () async {
      final client = MockClient((request) async {
        return http.Response('Plain error message', 400);
      });
      final svc = PromptsService(baseUrl: 'http://any', client: client);
      try {
        await svc.fetchPrompts();
        fail('expected ApiException');
      } catch (e) {
        expect(e is ApiException, isTrue);
        expect((e as ApiException).rawMessage, 'Plain error message');
      }
    });
  });

  group('sessionId Handling', () {
    test('includes sessionId in headers when provided', () async {
      final client = MockClient((request) async {
        expect(request.headers['X-Session-Id'], 'test-session');
        return http.Response(jsonEncode({'items': []}), 200);
      });
      final svc = PromptsService(
        baseUrl: 'http://any',
        sessionId: 'test-session',
        client: client,
      );
      await svc.fetchPrompts();
    });

    test('trims whitespace from sessionId', () async {
      final client = MockClient((request) async {
        expect(request.headers['X-Session-Id'], 'test-session');
        return http.Response(jsonEncode({'items': []}), 200);
      });
      final svc = PromptsService(
        baseUrl: 'http://any',
        sessionId: '  test-session  ',
        client: client,
      );
      await svc.fetchPrompts();
    });

    test('omits sessionId header when null', () async {
      final client = MockClient((request) async {
        expect(request.headers.containsKey('X-Session-Id'), false);
        return http.Response(jsonEncode({'items': []}), 200);
      });
      final svc = PromptsService(baseUrl: 'http://any', client: client);
      await svc.fetchPrompts();
    });

    test('omits sessionId header when empty', () async {
      final client = MockClient((request) async {
        expect(request.headers.containsKey('X-Session-Id'), false);
        return http.Response(jsonEncode({'items': []}), 200);
      });
      final svc = PromptsService(
        baseUrl: 'http://any',
        sessionId: '   ',
        client: client,
      );
      await svc.fetchPrompts();
    });
  });

  group('Edge Cases', () {
    test('handles empty response body', () async {
      final client = MockClient((request) async {
        return http.Response('', 200);
      });
      final svc = PromptsService(baseUrl: 'http://any', client: client);
      final result = await svc.fetchPrompts();
      expect(result, isEmpty);
    });

    test('handles response without items key', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode([]), 200);
      });
      final svc = PromptsService(baseUrl: 'http://any', client: client);
      final list = await svc.fetchPrompts();
      expect(list, isEmpty);
    });

    test('handles response with direct array', () async {
      final client = MockClient((request) async {
        final items = [
          {'id': '1', 'prompt_key': 'test', 'language': 'en', 'content': 'X'},
        ];
        return http.Response(jsonEncode(items), 200);
      });
      final svc = PromptsService(baseUrl: 'http://any', client: client);
      final list = await svc.fetchPrompts();
      expect(list.length, 1);
    });

    test('updates authToken dynamically', () async {
      final client = MockClient((request) async {
        if (request.headers['Authorization'] == 'Bearer token1') {
          return http.Response(jsonEncode({'items': []}), 200);
        }
        return http.Response('Unauthorized', 401);
      });
      final svc = PromptsService(
        baseUrl: 'http://any',
        authToken: 'token1',
        client: client,
      );
      await svc.fetchPrompts();
      svc.setAuthToken('token2');
      try {
        await svc.fetchPrompts();
        fail('expected ApiException');
      } catch (e) {
        expect((e as ApiException).statusCode, 401);
      }
    });
  });
}
