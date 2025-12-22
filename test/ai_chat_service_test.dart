import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';
import 'package:writer/repositories/remote_repository.dart';

void main() {
  group('AiChatService', () {
    test('sendMessage returns answer field', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' && request.url.path == '/agents/qa') {
          return http.Response(jsonEncode({'answer': 'ok'}), 200);
        }
        return http.Response('not found', 404);
      });
      final remote = RemoteRepository('http://example.com/', client: client);
      final svc = AiChatService(remote);
      final reply = await svc.sendMessage('hi');
      expect(reply, 'ok');
    });

    test('sendMessage supports reply and response fields', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' && request.url.path == '/agents/qa') {
          return http.Response(jsonEncode({'reply': 'r1'}), 200);
        }
        return http.Response('not found', 404);
      });
      final svc = AiChatService(
        RemoteRepository('http://example.com/', client: client),
      );
      final reply = await svc.sendMessage('hi');
      expect(reply, 'r1');

      final client2 = MockClient((request) async {
        if (request.method == 'POST' && request.url.path == '/agents/qa') {
          return http.Response(jsonEncode({'response': 'r2'}), 200);
        }
        return http.Response('not found', 404);
      });
      final svc2 = AiChatService(
        RemoteRepository('http://example.com/', client: client2),
      );
      final reply2 = await svc2.sendMessage('hi');
      expect(reply2, 'r2');
    });

    test('sendMessage returns fallback when field type is wrong', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' && request.url.path == '/agents/qa') {
          return http.Response(jsonEncode({'answer': 123}), 200);
        }
        return http.Response('not found', 404);
      });
      final svc = AiChatService(
        RemoteRepository('http://example.com/', client: client),
      );
      final reply = await svc.sendMessage('hi');
      expect(reply, 'No response from AI service');
    });

    test('sendMessage handles 401 and 403', () async {
      final client401 = MockClient(
        (request) async => http.Response('unauth', 401),
      );
      final svc401 = AiChatService(
        RemoteRepository('http://example.com', client: client401),
      );
      expect(
        await svc401.sendMessage('x'),
        'Sign in required to use AI service',
      );

      final client403 = MockClient(
        (request) async => http.Response('forbidden', 403),
      );
      final svc403 = AiChatService(
        RemoteRepository('http://example.com', client: client403),
      );
      expect(
        await svc403.sendMessage('x'),
        'Feature not available for your plan',
      );
    });

    test('sendMessage returns error string on 500', () async {
      final client = MockClient((request) async => http.Response('error', 500));
      final svc = AiChatService(
        RemoteRepository('http://example.com', client: client),
      );
      expect(
        await svc.sendMessage('x'),
        contains('Failed to connect to AI service:'),
      );
    });

    test('checkHealth returns true on access_ok', () async {
      final client = MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/health') {
          return http.Response(
            jsonEncode({
              'ai': {'access_ok': true},
            }),
            200,
          );
        }
        return http.Response('not found', 404);
      });
      final svc = AiChatService(
        RemoteRepository('http://example.com/', client: client),
      );
      final ok = await svc.checkHealth();
      expect(ok, isTrue);
    });

    test('checkHealth true on 200 with unparsable body', () async {
      final client = MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/health') {
          return http.Response('ok', 200);
        }
        return http.Response('not found', 404);
      });
      final svc = AiChatService(
        RemoteRepository('http://example.com/', client: client),
      );
      final ok = await svc.checkHealth();
      expect(ok, isTrue);
    });

    test('verifyUser returns parsed map on 200', () async {
      final client = MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/auth/verify') {
          return http.Response(jsonEncode({'user': 'u1'}), 200);
        }
        return http.Response('not found', 404);
      });
      final svc = AiChatService(
        RemoteRepository('http://example.com', client: client),
      );
      final res = await svc.verifyUser();
      expect(res, isNotNull);
      expect(res?['user'], 'u1');
    });

    test('verifyUser returns null on non-200 or non-map body', () async {
      final client = MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/auth/verify') {
          return http.Response(jsonEncode(['not-a-map']), 200);
        }
        return http.Response('bad', 500);
      });
      final svc = AiChatService(
        RemoteRepository('http://example.com', client: client),
      );
      final res = await svc.verifyUser();
      expect(res, isNull);
    });

    test('embed returns vector list', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' && request.url.path == '/vectors/embed') {
          return http.Response(
            jsonEncode({
              'vector': [1, 2.5, 3],
            }),
            200,
          );
        }
        return http.Response('not found', 404);
      });
      final svc = AiChatService(
        RemoteRepository('http://example.com/', client: client),
      );
      final vec = await svc.embed('text');
      expect(vec, [1.0, 2.5, 3.0]);
    });

    test('embed returns null on error or invalid payload', () async {
      final clientErr = MockClient((request) async {
        if (request.method == 'POST' && request.url.path == '/vectors/embed') {
          return http.Response('bad', 400);
        }
        return http.Response('not found', 404);
      });
      final svcErr = AiChatService(
        RemoteRepository('http://example.com/', client: clientErr),
      );
      final vecErr = await svcErr.embed('x');
      expect(vecErr, isNull);

      final clientInvalid = MockClient((request) async {
        if (request.method == 'POST' && request.url.path == '/vectors/embed') {
          return http.Response(jsonEncode({'vector': 'oops'}), 200);
        }
        return http.Response('not found', 404);
      });
      final svcInvalid = AiChatService(
        RemoteRepository('http://example.com', client: clientInvalid),
      );
      final vecInvalid = await svcInvalid.embed('x');
      expect(vecInvalid, isNull);
    });

    test('sendMessage handles baseUrl without trailing slash', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' && request.url.path == '/agents/qa') {
          return http.Response(jsonEncode({'answer': 'ok'}), 200);
        }
        return http.Response('not found', 404);
      });
      final svc = AiChatService(
        RemoteRepository('http://example.com', client: client),
      );
      final reply = await svc.sendMessage('hi');
      expect(reply, 'ok');
    });
    test('betaEvaluateChapter returns evaluation map', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' && request.url.path == '/beta/evaluate') {
          final body = jsonDecode(request.body);
          expect(body['language'], 'en');
          return http.Response(
            jsonEncode({
              'chapter_sha': 'abc',
              'evaluation': {'score': 10},
            }),
            200,
          );
        }
        return http.Response('not found', 404);
      });
      final svc = AiChatService(
        RemoteRepository('http://example.com/', client: client),
      );
      final res = await svc.betaEvaluateChapter(
        novelId: 'n1',
        chapterId: 'c1',
        content: 'txt',
      );
      expect(res, {'score': 10});
    });

    test('betaEvaluateChapter sends language', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' && request.url.path == '/beta/evaluate') {
          final body = jsonDecode(request.body);
          expect(body['language'], 'zh');
          return http.Response(
            jsonEncode({
              'chapter_sha': 'abc',
              'evaluation': {'score': 10},
            }),
            200,
          );
        }
        return http.Response('not found', 404);
      });
      final svc = AiChatService(
        RemoteRepository('http://example.com/', client: client),
      );
      final res = await svc.betaEvaluateChapter(
        novelId: 'n1',
        chapterId: 'c1',
        content: 'txt',
        language: 'zh',
      );
      expect(res, {'score': 10});
    });
  });
}
