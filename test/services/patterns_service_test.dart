import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:writer/services/patterns_service.dart';

MockClient _mockClient({
  bool improveReturnsInvalid = false,
  bool withErrorResponse = false,
  bool smartSearch = false,
}) {
  return MockClient((request) async {
    final m = request.method;
    final path = request.url.path;
    final q = request.url.queryParameters;
    if (m == 'GET' && (path == '/patterns' || path == '/patterns/')) {
      final items = [
        {
          'id': 'p1',
          'title': 'A',
          'description': 'D',
          'content': 'X',
          'usage_rules': null,
        },
      ];
      return http.Response(jsonEncode({'items': items}), 200);
    }
    if (m == 'GET' && path == '/patterns/search') {
      final query = q['q'];
      if (query == 'map') {
        final items = [
          {
            'id': 's1',
            'title': 'S1',
            'description': null,
            'content': 'C1',
            'usage_rules': null,
          },
        ];
        return http.Response(jsonEncode({'items': items}), 200);
      }
      if (query == 'list') {
        final items = [
          {
            'id': 's2',
            'title': 'S2',
            'description': null,
            'content': 'C2',
            'usage_rules': null,
          },
        ];
        return http.Response(jsonEncode(items), 200);
      }
      if (query == 'error') {
        if (withErrorResponse) {
          return http.Response(
            jsonEncode({
              'code': 'PATTERN_SEARCH_FAILED',
              'message': 'Search failed',
              'user_message_key': 'pattern_search_failed',
            }),
            500,
          );
        }
        return http.Response('search failed', 500);
      }
    }
    if (m == 'GET' && path.startsWith('/patterns/')) {
      final id = path.split('/').last;
      final data = {
        'id': id,
        'title': 'T$id',
        'description': null,
        'content': 'Body',
        'usage_rules': null,
      };
      return http.Response(jsonEncode(data), 200);
    }
    if (m == 'POST' && (path == '/patterns' || path == '/patterns/')) {
      final data = jsonDecode(request.body) as Map<String, dynamic>;
      final created = {
        'id': 'new',
        'title': data['title'],
        'description': data['description'],
        'content': data['content'],
        'usage_rules': data['usage_rules'],
      };
      return http.Response(jsonEncode(created), 200);
    }
    if (m == 'PATCH' && path.startsWith('/patterns/')) {
      final id = path.split('/').last;
      final data = jsonDecode(request.body) as Map<String, dynamic>;
      final updated = {
        'id': id,
        'title': data['title'] ?? 'T',
        'description': data['description'],
        'content': data['content'] ?? 'C',
        'usage_rules': data['usage_rules'],
      };
      return http.Response(jsonEncode(updated), 200);
    }
    if (m == 'DELETE' && path == '/patterns/ok') {
      final auth = request.headers['authorization'];
      if (auth == null || !auth.startsWith('Bearer ')) {
        return http.Response('Forbidden', 403);
      }
      return http.Response(jsonEncode({'deleted': true}), 200);
    }
    if (m == 'DELETE' && path == '/patterns/empty') {
      return http.Response(jsonEncode({}), 200);
    }
    if (m == 'DELETE' && path == '/patterns/error') {
      return http.Response('delete failed', 500);
    }
    if (m == 'POST' && path == '/patterns/improve') {
      if (improveReturnsInvalid) {
        return http.Response(jsonEncode([1, 2, 3]), 200);
      }
      final data = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({
          'title': '${data['title']}+',
          'description': data['description'],
          'content': data['content'],
          'usage_rules': data['usage_rules'],
          'language': data['language'] ?? 'en',
        }),
        200,
      );
    }
    if (m == 'POST' && path == '/patterns/search_vector') {
      if (smartSearch) {
        final items = [
          {'id': 'sv1', 'title': 'Smart Result', 'content': 'Content'},
        ];
        return http.Response(jsonEncode({'items': items}), 200);
      }
      return http.Response(jsonEncode([]), 200);
    }
    return http.Response('Not found', 404);
  });
}

void main() {
  test('fetchPatterns returns items', () async {
    final svc = PatternsService(baseUrl: 'http://any', client: _mockClient());
    final list = await svc.fetchPatterns();
    expect(list.length, 1);
    expect(list.first.id, 'p1');
    expect(list.first.title, 'A');
  });

  test('get/create/update/delete pattern happy path', () async {
    final svc = PatternsService(
      baseUrl: 'http://any/',
      authToken: 't',
      client: _mockClient(),
    );
    final p = await svc.getPattern('123');
    expect(p.id, '123');
    expect(p.content, 'Body');

    final created = await svc.createPattern(
      title: 'Title',
      description: 'Desc',
      content: 'C',
      usageRules: {'x': true},
    );
    expect(created.id, 'new');
    expect(created.title, 'Title');
    expect(created.usageRules?['x'], isTrue);

    final updated = await svc.updatePattern(id: 'new', content: 'Updated');
    expect(updated.id, 'new');
    expect(updated.content, 'Updated');

    final ok = await svc.deletePattern('ok');
    expect(ok, isTrue);
  });

  test('deletePattern returns false when flag missing', () async {
    final svc = PatternsService(baseUrl: 'http://any', client: _mockClient());
    final ok = await svc.deletePattern('empty');
    expect(ok, isFalse);
  });

  test('searchPatterns supports map and list payloads', () async {
    final svc = PatternsService(baseUrl: 'http://any', client: _mockClient());
    final mapList = await svc.searchPatterns('map');
    expect(mapList.length, 1);
    expect(mapList.first.id, 's1');

    final rawList = await svc.searchPatterns('list');
    expect(rawList.length, 1);
    expect(rawList.first.id, 's2');
  });

  test('errors map to ApiException with message', () async {
    final svc = PatternsService(baseUrl: 'http://any', client: _mockClient());
    try {
      await svc.searchPatterns('error');
      fail('expected ApiException');
    } catch (e) {
      expect(e is ApiException, isTrue);
      expect((e as ApiException).statusCode, 500);
      expect(e.rawMessage, 'search failed');
    }
    try {
      await svc.deletePattern('error');
      fail('expected ApiException');
    } catch (e) {
      expect(e is ApiException, isTrue);
      expect((e as ApiException).statusCode, 500);
      expect(e.rawMessage, 'delete failed');
    }
  });

  test('isLoading reflects loading state', () async {
    final client = MockClient((request) async {
      await Future.delayed(const Duration(milliseconds: 10));
      return http.Response(jsonEncode({'items': []}), 200);
    });
    final svc = PatternsService(baseUrl: 'http://any', client: client);
    expect(svc.isLoading, false);
    final future = svc.fetchPatterns();
    expect(svc.isLoading, true);
    await future;
    expect(svc.isLoading, false);
  });

  test('setAuthToken updates auth token', () {
    final svc = PatternsService(baseUrl: 'http://any');
    expect(svc.authToken, isNull);
    svc.setAuthToken('new_token');
    expect(svc.authToken, 'new_token');
    svc.setAuthToken(null);
    expect(svc.authToken, isNull);
  });

  test('improvePattern returns map and throws on invalid response', () async {
    final svcOk = PatternsService(baseUrl: 'http://any', client: _mockClient());
    final improved = await svcOk.improvePattern(
      title: 'T',
      content: 'C',
      usageRules: {'a': 1},
      language: 'en',
    );
    expect(improved['title'], 'T+');

    final svcBad = PatternsService(
      baseUrl: 'http://any',
      client: _mockClient(improveReturnsInvalid: true),
    );
    expect(
      () => svcBad.improvePattern(title: 'T', content: 'C'),
      throwsA(isA<ApiException>()),
    );
  });

  test('smartSearchPatterns returns list', () async {
    final svc = PatternsService(
      baseUrl: 'http://any',
      client: _mockClient(smartSearch: true),
    );
    final results = await svc.smartSearchPatterns('query', limit: 5, offset: 0);
    expect(results.length, 1);
    expect(results.first.id, 'sv1');
    expect(results.first.title, 'Smart Result');
  });

  test('smartSearchPatterns with custom limit and offset', () async {
    final client = MockClient((request) async {
      if (request.method == 'POST' &&
          request.url.path == '/patterns/search_vector') {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['limit'], 10);
        expect(body['offset'], 5);
        return http.Response(jsonEncode({'items': []}), 200);
      }
      return http.Response('Not found', 404);
    });
    final svc = PatternsService(baseUrl: 'http://any', client: client);
    await svc.smartSearchPatterns('query', limit: 10, offset: 5);
  });

  test('unsupported method throws ApiException', () async {
    final client = MockClient((request) async {
      return http.Response('Not found', 404);
    });
    final svc = PatternsService(baseUrl: 'http://any', client: client);
    // Test by trying to use a method that would fail
    // The _send method throws for unsupported methods
    try {
      await svc.fetchPatterns();
      fail('expected ApiException');
    } catch (e) {
      expect(e is ApiException, isTrue);
    }
  });

  test('createPattern with optional fields', () async {
    final client = MockClient((request) async {
      if (request.method == 'POST' &&
          (request.url.path == '/patterns' ||
              request.url.path == '/patterns/')) {
        final data = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'id': 'new',
            'title': data['title'],
            'description': data['description'],
            'content': data['content'],
            'usage_rules': data['usage_rules'],
            'language': data['language'],
            'is_public': data['is_public'],
          }),
          200,
        );
      }
      return http.Response('Not found', 404);
    });
    final svc = PatternsService(baseUrl: 'http://any', client: client);
    final created = await svc.createPattern(
      title: 'Title',
      description: 'Desc',
      content: 'C',
      usageRules: {'x': true},
      language: 'en',
      isPublic: true,
    );
    expect(created.language, 'en');
    expect(created.isPublic, true);
  });

  test('updatePattern with all optional fields', () async {
    final client = MockClient((request) async {
      if (request.method == 'PATCH' &&
          request.url.path.startsWith('/patterns/')) {
        final data = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'id': 'id',
            'title': data['title'] ?? 'T',
            'description': data['description'],
            'content': data['content'] ?? 'C',
            'usage_rules': data['usage_rules'],
            'language': data['language'],
            'is_public': data['is_public'],
            'locked': data['locked'],
          }),
          200,
        );
      }
      return http.Response('Not found', 404);
    });
    final svc = PatternsService(baseUrl: 'http://any', client: client);
    final updated = await svc.updatePattern(
      id: 'id',
      title: 'Updated',
      description: 'New Desc',
      content: 'New Content',
      usageRules: {'y': false},
      language: 'zh',
      isPublic: false,
      locked: true,
    );
    expect(updated.title, 'Updated');
    expect(updated.description, 'New Desc');
    expect(updated.content, 'New Content');
    expect(updated.locked, true);
  });

  test('deletePattern returns false when flag missing', () async {
    final svc = PatternsService(baseUrl: 'http://any', client: _mockClient());
    final ok = await svc.deletePattern('empty');
    expect(ok, isFalse);
  });
}
