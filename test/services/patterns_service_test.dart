import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:writer/services/patterns_service.dart';

MockClient _mockClient() {
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
      expect(e.message, 'search failed');
    }
    try {
      await svc.deletePattern('error');
      fail('expected ApiException');
    } catch (e) {
      expect(e is ApiException, isTrue);
      expect((e as ApiException).statusCode, 500);
      expect(e.message, 'delete failed');
    }
  });
}
