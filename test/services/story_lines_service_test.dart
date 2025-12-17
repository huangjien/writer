import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:writer/services/story_lines_service.dart';

MockClient _mockClient({
  bool listResponse = false,
  bool improveReturnsInvalid = false,
  bool deleteReturnsFalse = false,
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
}
