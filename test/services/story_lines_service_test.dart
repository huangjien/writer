import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:writer/services/story_lines_service.dart';

MockClient _mockClient({
  bool listResponse = false,
  bool improveReturnsInvalid = false,
  bool deleteReturnsFalse = false,
  bool withErrorResponse = false,
  bool smartSearch = false,
}) {
  return MockClient((request) async {
    final m = request.method;
    final path = request.url.path;

    if (m == 'GET' && (path == '/story_lines' || path == '/story_lines/')) {
      final items = [
        {
          'id': '1',
          'title': 'A',
          'description': 'D',
          'content': 'C',
          'usage_rules': {'a': 1},
          'language': 'en',
          'is_public': true,
          'locked': false,
        },
      ];
      if (listResponse) {
        return http.Response(jsonEncode(items), 200);
      }
      return http.Response(jsonEncode({'items': items}), 200);
    }

    if (m == 'GET' && path.startsWith('/story_lines/search')) {
      final q = request.url.queryParameters['q'] ?? '';
      final items = [
        {'id': 's-$q', 'title': q, 'content': 'C', 'language': 'en'},
      ];
      return http.Response(jsonEncode({'items': items}), 200);
    }

    if (m == 'GET' && path.startsWith('/story_lines/')) {
      final id = path.split('/').last;
      if (id == 'forbidden') {
        if (withErrorResponse) {
          return http.Response(
            jsonEncode({
              'code': 'STORY_LINE_NOT_FOUND',
              'message': 'Story line not found',
              'user_message_key': 'story_line_not_found',
            }),
            403,
          );
        }
        return http.Response('Forbidden', 403);
      }
      final data = {
        'id': id,
        'title': 'T$id',
        'content': 'C$id',
        'language': 'en',
      };
      return http.Response(jsonEncode(data), 200);
    }

    if (m == 'POST' && (path == '/story_lines' || path == '/story_lines/')) {
      final auth = request.headers['authorization'];
      if (auth == null || !auth.startsWith('Bearer ')) {
        return http.Response('Forbidden', 403);
      }
      final data = jsonDecode(request.body) as Map<String, dynamic>;
      final created = {
        'id': 'new',
        'title': data['title'],
        'description': data['description'],
        'content': data['content'],
        'usage_rules': data['usage_rules'],
        if (data['language'] != null) 'language': data['language'],
        if (data['is_public'] != null) 'is_public': data['is_public'],
      };
      return http.Response(jsonEncode(created), 200);
    }

    if (m == 'PATCH' && path.startsWith('/story_lines/')) {
      final id = path.split('/').last;
      final data = jsonDecode(request.body) as Map<String, dynamic>;
      final updated = {
        'id': id,
        'title': data['title'] ?? 'T$id',
        'description': data['description'],
        'content': data['content'] ?? 'C$id',
        if (data['usage_rules'] != null) 'usage_rules': data['usage_rules'],
        if (data['language'] != null) 'language': data['language'],
        if (data['is_public'] != null) 'is_public': data['is_public'],
        if (data['locked'] != null) 'locked': data['locked'],
      };
      return http.Response(jsonEncode(updated), 200);
    }

    if (m == 'POST' && path == '/story_lines/improve') {
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

    if (m == 'DELETE' && path.startsWith('/story_lines/')) {
      if (deleteReturnsFalse) {
        return http.Response(jsonEncode({'deleted': false}), 200);
      }
      return http.Response(jsonEncode({'deleted': true}), 200);
    }

    if (m == 'POST' && path == '/story_lines/search_vector') {
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
  test('fetchStoryLines supports items wrapper response', () async {
    final svc = StoryLinesService(baseUrl: 'http://any', client: _mockClient());
    final list = await svc.fetchStoryLines();
    expect(list.length, 1);
    expect(list.first.title, 'A');
    expect(list.first.usageRules, {'a': 1});
  });

  test('fetchStoryLines supports list response', () async {
    final svc = StoryLinesService(
      baseUrl: 'http://any',
      client: _mockClient(listResponse: true),
    );
    final list = await svc.fetchStoryLines();
    expect(list.length, 1);
    expect(list.first.id, '1');
  });

  test('get/create/update/delete/search story line', () async {
    final svc = StoryLinesService(
      baseUrl: 'http://any',
      authToken: 't',
      client: _mockClient(),
    );

    final got = await svc.getStoryLine('123');
    expect(got.id, '123');
    expect(got.title, 'T123');

    final created = await svc.createStoryLine(
      title: 'New',
      description: 'Desc',
      content: 'Body',
      usageRules: {'x': true},
      language: 'zh',
      isPublic: false,
    );
    expect(created.id, 'new');
    expect(created.language, 'zh');
    expect(created.isPublic, isFalse);

    final updated = await svc.updateStoryLine(
      id: 'new',
      title: 'Updated',
      locked: true,
    );
    expect(updated.id, 'new');
    expect(updated.title, 'Updated');
    expect(updated.locked, isTrue);

    final ok = await svc.deleteStoryLine('new');
    expect(ok, isTrue);

    final search = await svc.searchStoryLines('abc');
    expect(search.length, 1);
    expect(search.first.id, 's-abc');
  });

  test('improveStoryLine returns map and throws on invalid response', () async {
    final svcOk = StoryLinesService(
      baseUrl: 'http://any',
      client: _mockClient(),
    );
    final improved = await svcOk.improveStoryLine(
      title: 'T',
      content: 'C',
      usageRules: {'a': 1},
      language: 'en',
    );
    expect(improved['title'], 'T+');

    final svcBad = StoryLinesService(
      baseUrl: 'http://any',
      client: _mockClient(improveReturnsInvalid: true),
    );
    expect(
      () => svcBad.improveStoryLine(title: 'T', content: 'C'),
      throwsA(isA<ApiException>()),
    );
  });

  test('non-2xx status throws ApiException with status code', () async {
    final svc = StoryLinesService(baseUrl: 'http://any', client: _mockClient());
    try {
      await svc.getStoryLine('forbidden');
      fail('expected ApiException');
    } catch (e) {
      expect(e, isA<ApiException>());
      expect((e as ApiException).statusCode, 403);
    }
  });

  test(
    'deleteStoryLine returns false when response indicates not deleted',
    () async {
      final svc = StoryLinesService(
        baseUrl: 'http://any',
        client: _mockClient(deleteReturnsFalse: true),
      );
      final ok = await svc.deleteStoryLine('x');
      expect(ok, isFalse);
    },
  );

  test('isLoading reflects loading state', () async {
    final client = MockClient((request) async {
      await Future.delayed(const Duration(milliseconds: 10));
      return http.Response(jsonEncode({'items': []}), 200);
    });
    final svc = StoryLinesService(baseUrl: 'http://any', client: client);
    expect(svc.isLoading, false);
    final future = svc.fetchStoryLines();
    expect(svc.isLoading, true);
    await future;
    expect(svc.isLoading, false);
  });

  test('setAuthToken updates auth token', () {
    final svc = StoryLinesService(baseUrl: 'http://any');
    expect(svc.authToken, isNull);
    svc.setAuthToken('new_token');
    expect(svc.authToken, 'new_token');
    svc.setAuthToken(null);
    expect(svc.authToken, isNull);
  });

  test('smartSearchStoryLines returns list', () async {
    final svc = StoryLinesService(
      baseUrl: 'http://any',
      client: _mockClient(smartSearch: true),
    );
    final results = await svc.smartSearchStoryLines(
      'query',
      limit: 10,
      offset: 0,
    );
    expect(results.length, 1);
    expect(results.first.id, 'sv1');
    expect(results.first.title, 'Smart Result');
  });

  test('smartSearchStoryLines with custom limit and offset', () async {
    final client = MockClient((request) async {
      if (request.method == 'POST' &&
          request.url.path == '/story_lines/search_vector') {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['limit'], 20);
        expect(body['offset'], 10);
        return http.Response(jsonEncode({'items': []}), 200);
      }
      return http.Response('Not found', 404);
    });
    final svc = StoryLinesService(baseUrl: 'http://any', client: client);
    await svc.smartSearchStoryLines('query', limit: 20, offset: 10);
  });

  test('createStoryLine with optional fields', () async {
    final client = MockClient((request) async {
      if (request.method == 'POST' &&
          (request.url.path == '/story_lines' ||
              request.url.path == '/story_lines/')) {
        final auth = request.headers['authorization'];
        if (auth == null || !auth.startsWith('Bearer ')) {
          return http.Response('Forbidden', 403);
        }
        final data = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'id': 'new',
            'title': data['title'],
            'description': data['description'],
            'content': data['content'],
            'usage_rules': data['usage_rules'],
            if (data['language'] != null) 'language': data['language'],
            if (data['is_public'] != null) 'is_public': data['is_public'],
          }),
          200,
        );
      }
      return http.Response('Not found', 404);
    });
    final svc = StoryLinesService(
      baseUrl: 'http://any',
      authToken: 't',
      client: client,
    );
    final created = await svc.createStoryLine(
      title: 'Title',
      description: 'Desc',
      content: 'C',
      usageRules: {'x': true},
      language: 'zh',
      isPublic: true,
    );
    expect(created.language, 'zh');
    expect(created.isPublic, true);
  });

  test('updateStoryLine with all optional fields', () async {
    final client = MockClient((request) async {
      if (request.method == 'PATCH' &&
          request.url.path.startsWith('/story_lines/')) {
        final data = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'id': 'id',
            'title': data['title'] ?? 'T',
            'description': data['description'],
            'content': data['content'] ?? 'C',
            if (data['usage_rules'] != null) 'usage_rules': data['usage_rules'],
            if (data['language'] != null) 'language': data['language'],
            if (data['is_public'] != null) 'is_public': data['is_public'],
            if (data['locked'] != null) 'locked': data['locked'],
          }),
          200,
        );
      }
      return http.Response('Not found', 404);
    });
    final svc = StoryLinesService(baseUrl: 'http://any', client: client);
    final updated = await svc.updateStoryLine(
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

  test('deleteStoryLine without auth throws ApiException', () async {
    final client = MockClient((request) async {
      if (request.method == 'DELETE' &&
          request.url.path.startsWith('/story_lines/')) {
        final auth = request.headers['authorization'];
        if (auth == null || !auth.startsWith('Bearer ')) {
          return http.Response('Forbidden', 403);
        }
        return http.Response(jsonEncode({'deleted': true}), 200);
      }
      return http.Response('Not found', 404);
    });
    final svc = StoryLinesService(baseUrl: 'http://any', client: client);
    try {
      await svc.deleteStoryLine('test');
      fail('expected ApiException');
    } catch (e) {
      expect(e, isA<ApiException>());
      expect((e as ApiException).statusCode, 403);
    }
  });
}
