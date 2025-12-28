import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:writer/services/vector_service.dart';

void main() {
  test('embed returns empty list for empty input', () async {
    var called = false;
    final client = MockClient((request) async {
      called = true;
      return http.Response('{"vector":[1]}', 200);
    });
    final svc = VectorService(baseUrl: 'http://example.com', client: client);
    final v = await svc.embed('   ');
    expect(v, isEmpty);
    expect(called, isFalse);
  });

  test('embed returns vector on 200 response', () async {
    final client = MockClient((request) async {
      if (request.method == 'POST' && request.url.path == '/vectors/embed') {
        return http.Response(
          jsonEncode({
            'vector': [1, 2.5],
          }),
          200,
        );
      }
      return http.Response('not found', 404);
    });

    final svc = VectorService(baseUrl: 'http://example.com/', client: client);
    final v = await svc.embed('hi');
    expect(v, [1.0, 2.5]);
  });

  test('embed returns empty list on non-200 response', () async {
    final client = MockClient((request) async {
      return http.Response('no', 500);
    });

    final svc = VectorService(baseUrl: 'http://example.com/', client: client);
    final v = await svc.embed('hi');
    expect(v, isEmpty);
  });

  test('refreshChapterEmbedding posts refresh endpoint with headers', () async {
    http.Request? captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response('{}', 200);
    });

    final svc = VectorService(
      baseUrl: 'http://example.com',
      sessionId: 'sid',
      authToken: 'tok',
      client: client,
    );
    await svc.refreshChapterEmbedding('c1');
    expect(captured, isNotNull);
    expect(captured!.method, 'POST');
    expect(captured!.url.path, '/chapters/c1/refresh_embedding');
    expect(captured!.headers['x-session-id'], 'sid');
    expect(captured!.headers['Authorization'], 'Bearer tok');
    expect(jsonDecode(captured!.body) as Map<String, dynamic>, {});
  });

  test('searchSceneTemplates returns empty list for empty query', () async {
    final client = MockClient((request) async => http.Response('[]', 200));
    final svc = VectorService(baseUrl: 'http://example.com', client: client);
    final items = await svc.searchSceneTemplates(query: ' ');
    expect(items, isEmpty);
  });

  test('searchSceneTemplates maps list response', () async {
    final client = MockClient((request) async {
      if (request.method == 'POST' &&
          request.url.path == '/templates/scenes/search') {
        return http.Response(
          jsonEncode([
            {'id': 's1'},
          ]),
          200,
        );
      }
      return http.Response('not found', 404);
    });
    final svc = VectorService(baseUrl: 'http://example.com/', client: client);
    final items = await svc.searchSceneTemplates(query: 'q');
    expect(items, [
      {'id': 's1'},
    ]);
  });

  test('searchCharacterTemplates maps list response', () async {
    final client = MockClient((request) async {
      if (request.method == 'POST' &&
          request.url.path == '/templates/characters/search') {
        return http.Response(
          jsonEncode([
            {'id': 'c1'},
          ]),
          200,
        );
      }
      return http.Response('not found', 404);
    });
    final svc = VectorService(baseUrl: 'http://example.com/', client: client);
    final items = await svc.searchCharacterTemplates(query: 'q');
    expect(items, [
      {'id': 'c1'},
    ]);
  });

  test('refreshSceneTemplateEmbedding posts refresh endpoint', () async {
    http.Request? captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response('{}', 200);
    });

    final svc = VectorService(
      baseUrl: 'http://example.com',
      sessionId: 'sid',
      authToken: 'tok',
      client: client,
    );
    await svc.refreshSceneTemplateEmbedding('t1');
    expect(captured, isNotNull);
    expect(captured!.method, 'POST');
    expect(captured!.url.path, '/templates/scenes/t1/refresh_embedding');
    expect(captured!.headers['x-session-id'], 'sid');
    expect(captured!.headers['Authorization'], 'Bearer tok');
    expect(jsonDecode(captured!.body) as Map<String, dynamic>, {});
  });

  test('refreshSceneTemplateEmbedding handles empty id', () async {
    var called = false;
    final client = MockClient((request) async {
      called = true;
      return http.Response('{}', 200);
    });
    final svc = VectorService(baseUrl: 'http://example.com', client: client);
    await svc.refreshSceneTemplateEmbedding('  ');
    expect(called, isFalse);
  });

  test('refreshSceneTemplateEmbedding handles errors silently', () async {
    final client = MockClient((request) async {
      return http.Response('error', 500);
    });
    final svc = VectorService(baseUrl: 'http://example.com', client: client);
    // Should not throw
    await svc.refreshSceneTemplateEmbedding('t1');
  });

  test('refreshCharacterTemplateEmbedding posts refresh endpoint', () async {
    http.Request? captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response('{}', 200);
    });

    final svc = VectorService(
      baseUrl: 'http://example.com',
      sessionId: 'sid',
      authToken: 'tok',
      client: client,
    );
    await svc.refreshCharacterTemplateEmbedding('t1');
    expect(captured, isNotNull);
    expect(captured!.method, 'POST');
    expect(captured!.url.path, '/templates/characters/t1/refresh_embedding');
    expect(captured!.headers['x-session-id'], 'sid');
    expect(captured!.headers['Authorization'], 'Bearer tok');
    expect(jsonDecode(captured!.body) as Map<String, dynamic>, {});
  });

  test('refreshCharacterTemplateEmbedding handles empty id', () async {
    var called = false;
    final client = MockClient((request) async {
      called = true;
      return http.Response('{}', 200);
    });
    final svc = VectorService(baseUrl: 'http://example.com', client: client);
    await svc.refreshCharacterTemplateEmbedding('  ');
    expect(called, isFalse);
  });

  test('refreshCharacterTemplateEmbedding handles errors silently', () async {
    final client = MockClient((request) async {
      return http.Response('error', 500);
    });
    final svc = VectorService(baseUrl: 'http://example.com', client: client);
    // Should not throw
    await svc.refreshCharacterTemplateEmbedding('t1');
  });

  test('searchSceneTemplates with languageCode', () async {
    http.Request? captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response(
        jsonEncode([
          {'id': 's1', 'language_code': 'en'},
        ]),
        200,
      );
    });
    final svc = VectorService(baseUrl: 'http://example.com/', client: client);
    final items = await svc.searchSceneTemplates(
      query: 'q',
      limit: 10,
      offset: 5,
      languageCode: 'en',
    );
    expect(captured, isNotNull);
    final body = jsonDecode(captured!.body) as Map<String, dynamic>;
    expect(body['query'], 'q');
    expect(body['limit'], 10);
    expect(body['offset'], 5);
    expect(body['language_code'], 'en');
    expect(items, [
      {'id': 's1', 'language_code': 'en'},
    ]);
  });

  test('searchCharacterTemplates with languageCode', () async {
    http.Request? captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response(
        jsonEncode([
          {'id': 'c1', 'language_code': 'zh'},
        ]),
        200,
      );
    });
    final svc = VectorService(baseUrl: 'http://example.com/', client: client);
    final items = await svc.searchCharacterTemplates(
      query: 'q',
      limit: 5,
      offset: 0,
      languageCode: 'zh',
    );
    expect(captured, isNotNull);
    final body = jsonDecode(captured!.body) as Map<String, dynamic>;
    expect(body['query'], 'q');
    expect(body['limit'], 5);
    expect(body['offset'], 0);
    expect(body['language_code'], 'zh');
    expect(items, [
      {'id': 'c1', 'language_code': 'zh'},
    ]);
  });

  test('embed with non-numeric vector values', () async {
    final client = MockClient((request) async {
      if (request.method == 'POST' && request.url.path == '/vectors/embed') {
        return http.Response(
          jsonEncode({
            'vector': [1, 2.5, 3.7],
          }),
          200,
        );
      }
      return http.Response('not found', 404);
    });

    final svc = VectorService(baseUrl: 'http://example.com/', client: client);
    final v = await svc.embed('hi');
    expect(v, [1.0, 2.5, 3.7]);
  });

  test('embed handles malformed vector', () async {
    final client = MockClient((request) async {
      if (request.method == 'POST' && request.url.path == '/vectors/embed') {
        return http.Response(
          jsonEncode({
            'vector': ['invalid', 'data'],
          }),
          200,
        );
      }
      return http.Response('not found', 404);
    });

    final svc = VectorService(baseUrl: 'http://example.com/', client: client);
    final v = await svc.embed('hi');
    // Should return empty list when parsing fails (strings can't be cast to num)
    expect(v, isEmpty);
  });

  test('embed handles missing vector field', () async {
    final client = MockClient((request) async {
      if (request.method == 'POST' && request.url.path == '/vectors/embed') {
        return http.Response(jsonEncode({'data': 'no vector field'}), 200);
      }
      return http.Response('not found', 404);
    });

    final svc = VectorService(baseUrl: 'http://example.com/', client: client);
    final v = await svc.embed('hi');
    expect(v, isEmpty);
  });

  test('embed handles non-200 response', () async {
    final client = MockClient((request) async {
      return http.Response('error', 400);
    });

    final svc = VectorService(baseUrl: 'http://example.com/', client: client);
    final v = await svc.embed('hi');
    expect(v, isEmpty);
  });

  test('refreshChapterEmbedding handles empty id', () async {
    var called = false;
    final client = MockClient((request) async {
      called = true;
      return http.Response('{}', 200);
    });
    final svc = VectorService(baseUrl: 'http://example.com', client: client);
    await svc.refreshChapterEmbedding('  ');
    expect(called, isFalse);
  });

  test('refreshChapterEmbedding handles errors silently', () async {
    final client = MockClient((request) async {
      return http.Response('error', 500);
    });
    final svc = VectorService(baseUrl: 'http://example.com', client: client);
    // Should not throw
    await svc.refreshChapterEmbedding('c1');
  });
}
