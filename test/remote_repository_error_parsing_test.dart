import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:writer/models/api_error_response.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/shared/api_exception.dart';

void main() {
  test('parses standardized error response and request id', () async {
    final remote = RemoteRepository(
      'http://example.com/',
      authToken: () async => null,
      client: MockClient((request) async {
        return http.Response(
          jsonEncode({
            'code': 'validation_error',
            'message': 'Validation failed',
            'user_message_key': 'validation_error',
          }),
          422,
          headers: {'x-request-id': 'rid_1'},
        );
      }),
    );

    try {
      await remote.get('anything');
      fail('expected ApiException');
    } catch (e) {
      expect(e, isA<ApiException>());
      final ex = e as ApiException;
      expect(ex.statusCode, 422);
      expect(ex.errorResponse, isNotNull);
      expect(ex.errorResponse!.code, 'validation_error');
      expect(ex.errorResponse!.requestId, 'rid_1');
    }
  });

  test('keeps raw message when error body is not JSON', () async {
    final remote = RemoteRepository(
      'http://example.com/',
      authToken: () async => null,
      client: MockClient((request) async {
        return http.Response('oops', 500, headers: {'x-request-id': 'rid_2'});
      }),
    );

    try {
      await remote.get('anything');
      fail('expected ApiException');
    } catch (e) {
      final ex = e as ApiException;
      expect(ex.errorResponse, isNull);
      expect(ex.rawMessage, 'oops');
    }
  });

  test('decodes successful JSON responses', () async {
    final remote = RemoteRepository(
      'http://example.com/',
      authToken: () async => null,
      client: MockClient((request) async {
        return http.Response(jsonEncode({'ok': true}), 200);
      }),
    );

    final res = await remote.get('anything');
    expect(res, isA<Map<String, dynamic>>());
    expect((res as Map<String, dynamic>)['ok'], true);
  });

  test('ApiException toString includes requestId when available', () {
    final ex = ApiException(
      400,
      null,
      errorResponse: ApiErrorResponse(
        code: 'validation_error',
        message: 'Validation failed',
        requestId: 'rid_1',
      ),
    );
    expect(ex.toString(), contains('request_id=rid_1'));
  });

  test('ApiException toString omits requestId when missing', () {
    final ex = ApiException(
      400,
      null,
      errorResponse: ApiErrorResponse(
        code: 'validation_error',
        message: 'Validation failed',
        requestId: null,
      ),
    );
    expect(ex.toString(), isNot(contains('request_id=')));
  });

  test('retries GET once after 401 and clears auth header on retry', () async {
    int calls = 0;
    int unauthorizedHandlers = 0;
    final seenHeaders = <Map<String, String>>[];

    final remote = RemoteRepository(
      'http://example.com/',
      authToken: () async => 'sid_1',
      onUnauthorized: () async {
        unauthorizedHandlers++;
      },
      client: MockClient((request) async {
        calls++;
        seenHeaders.add(Map<String, String>.from(request.headers));
        if (calls == 1) {
          return http.Response('unauthorized', 401);
        }
        return http.Response(jsonEncode({'ok': true}), 200);
      }),
    );

    final res = await remote.get('anything');
    expect((res as Map<String, dynamic>)['ok'], true);
    expect(calls, 2);
    expect(unauthorizedHandlers, 1);

    final firstKeys = seenHeaders.first.keys
        .map((k) => k.toLowerCase())
        .toSet();
    final secondKeys = seenHeaders.last.keys
        .map((k) => k.toLowerCase())
        .toSet();
    expect(firstKeys.contains('x-session-id'), true);
    expect(secondKeys.contains('x-session-id'), false);
  });

  test('patch returns null on empty body', () async {
    final remote = RemoteRepository(
      'http://example.com',
      authToken: () async => null,
      client: MockClient((request) async {
        expect(request.url.toString(), 'http://example.com/chapters/c1');
        return http.Response('', 200);
      }),
    );

    final res = await remote.patch('chapters/c1', {'title': 'T'});
    expect(res, isNull);
  });

  test('post can retry on unauthorized when enabled', () async {
    int calls = 0;
    final remote = RemoteRepository(
      'http://example.com',
      authToken: () async => ' sid_1 ',
      onUnauthorized: () async {},
      client: MockClient((request) async {
        calls++;
        if (calls == 1) {
          expect(request.headers['X-Session-Id']?.trim(), 'sid_1');
          return http.Response('unauthorized', 401);
        }
        expect(request.headers.containsKey('X-Session-Id'), false);
        return http.Response("{}", 200);
      }),
    );

    await remote.post('chapters', {'x': 1}, retryUnauthorized: true);
    expect(calls, 2);
  });

  test('delete supports query parameters', () async {
    final remote = RemoteRepository(
      'http://example.com/',
      authToken: () async => null,
      client: MockClient((request) async {
        expect(
          request.url.toString(),
          'http://example.com/chapters/c1?force=true',
        );
        return http.Response('', 204);
      }),
    );

    await remote.delete('chapters/c1', queryParameters: {'force': 'true'});
  });

  test('uses request id header regardless of casing', () async {
    final remote = RemoteRepository(
      'http://example.com/',
      authToken: () async => null,
      client: MockClient((request) async {
        return http.Response(
          jsonEncode({'code': 'bad_gateway', 'message': 'x'}),
          502,
          headers: {'X-Request-Id': 'rid_3'},
        );
      }),
    );

    try {
      await remote.get('anything');
      fail('expected ApiException');
    } catch (e) {
      final ex = e as ApiException;
      expect(ex.errorResponse?.requestId, 'rid_3');
    }
  });

  test('domain helpers decode expected fields', () async {
    final remote = RemoteRepository(
      'http://example.com/',
      authToken: () async => null,
      client: MockClient((request) async {
        final path = request.url.path;
        if (request.method == 'POST' && path.endsWith('/characters/profile')) {
          return http.Response(jsonEncode({'character_profile': 'p1'}), 200);
        }
        if (request.method == 'POST' &&
            path.endsWith('/agents/character-convert')) {
          return http.Response(jsonEncode({'result': 'r1'}), 200);
        }
        if (request.method == 'GET' &&
            path.endsWith('/token-usage/current-month')) {
          return http.Response(
            jsonEncode({
              'user_id': 'u1',
              'year': 2026,
              'month': 1,
              'input_tokens': 1,
              'output_tokens': 2,
              'total_tokens': 3,
              'request_count': 1,
            }),
            200,
          );
        }
        if (request.method == 'GET' && path.endsWith('/token-usage/history')) {
          return http.Response(
            jsonEncode({
              'records': [
                {
                  'operation_type': 'respond',
                  'model_name': 'm',
                  'input_tokens': 1,
                  'output_tokens': 2,
                  'created_at': '2026-01-01T00:00:00Z',
                },
              ],
              'total_count': 1,
            }),
            200,
          );
        }
        if (request.method == 'GET' && path.endsWith('/admin/logs')) {
          return http.Response(jsonEncode({'logs': 'L'}), 200);
        }
        return http.Response('Not Found', 404);
      }),
    );

    expect(await remote.fetchCharacterProfile('A'), 'p1');
    expect(
      await remote.convertCharacter(
        name: 'A',
        templateContent: 'T',
        language: 'en',
      ),
      'r1',
    );

    final usage = await remote.getCurrentMonthUsage();
    expect(usage, isNotNull);
    expect(usage!.totalTokens, 3);

    final history = await remote.getUsageHistory();
    expect(history, isNotNull);
    expect(history!.records, hasLength(1));

    expect(await remote.getAdminLogs(lines: 10), 'L');
  });

  test('continues when authToken getter throws', () async {
    int calls = 0;
    final remote = RemoteRepository(
      'http://example.com/',
      authToken: () async {
        throw StateError('boom');
      },
      client: MockClient((request) async {
        calls++;
        final keys = request.headers.keys.map((k) => k.toLowerCase()).toSet();
        expect(keys.contains('x-session-id'), false);
        return http.Response("{}", 200);
      }),
    );

    await remote.get('anything');
    expect(calls, 1);
  });

  test('get returns null on empty success body', () async {
    final remote = RemoteRepository(
      'http://example.com/',
      authToken: () async => null,
      client: MockClient((request) async => http.Response('', 200)),
    );

    final res = await remote.get('anything');
    expect(res, isNull);
  });

  test('wraps client exceptions as ApiException(0)', () async {
    final remote = RemoteRepository(
      'http://example.com/',
      authToken: () async => null,
      client: MockClient((request) async {
        throw StateError('boom');
      }),
    );

    try {
      await remote.get('anything');
      fail('expected ApiException');
    } catch (e) {
      final ex = e as ApiException;
      expect(ex.statusCode, 0);
    }
  });

  test('ignores exceptions from unauthorized handler', () async {
    int calls = 0;
    final remote = RemoteRepository(
      'http://example.com/',
      authToken: () async => 'sid_1',
      onUnauthorized: () async {
        throw StateError('boom');
      },
      client: MockClient((request) async {
        calls++;
        if (calls == 1) return http.Response('unauthorized', 401);
        return http.Response("{}", 200);
      }),
    );

    final res = await remote.get('anything');
    expect(res, isA<Map<String, dynamic>>());
    expect(calls, 2);
  });

  test('delete retries once after 401 when enabled', () async {
    int calls = 0;
    final seenHeaders = <Map<String, String>>[];

    final remote = RemoteRepository(
      'http://example.com/',
      authToken: () async => 'sid_1',
      onUnauthorized: () async {},
      client: MockClient((request) async {
        calls++;
        seenHeaders.add(Map<String, String>.from(request.headers));
        if (calls == 1) return http.Response('unauthorized', 401);
        return http.Response('', 204);
      }),
    );

    await remote.delete('anything', retryUnauthorized: true);
    expect(calls, 2);

    final firstKeys = seenHeaders.first.keys
        .map((k) => k.toLowerCase())
        .toSet();
    final secondKeys = seenHeaders.last.keys
        .map((k) => k.toLowerCase())
        .toSet();
    expect(firstKeys.contains('x-session-id'), true);
    expect(secondKeys.contains('x-session-id'), false);
  });
}
