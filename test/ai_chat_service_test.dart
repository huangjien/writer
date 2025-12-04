import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';

void main() {
  group('AiChatService', () {
    test('sendMessage returns answer field', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' &&
            request.url.path.endsWith('agents/qa')) {
          return http.Response(jsonEncode({'answer': 'ok'}), 200);
        }
        return http.Response('not found', 404);
      });
      final svc = AiChatService('http://example.com/', client: client);
      final reply = await svc.sendMessage('hi');
      expect(reply, 'ok');
    });

    test('sendMessage handles 401 and 403', () async {
      final client401 = MockClient(
        (request) async => http.Response('unauth', 401),
      );
      final svc401 = AiChatService('http://example.com', client: client401);
      expect(
        await svc401.sendMessage('x'),
        'Sign in required to use AI service',
      );

      final client403 = MockClient(
        (request) async => http.Response('forbidden', 403),
      );
      final svc403 = AiChatService('http://example.com', client: client403);
      expect(
        await svc403.sendMessage('x'),
        'Feature not available for your plan',
      );
    });

    test('sendMessage throws on 500', () async {
      final client = MockClient((request) async => http.Response('error', 500));
      final svc = AiChatService('http://example.com', client: client);
      expect(() => svc.sendMessage('x'), throwsA(isA<Exception>()));
    });

    test('checkHealth returns true on access_ok', () async {
      final client = MockClient((request) async {
        if (request.method == 'GET' && request.url.path.endsWith('health')) {
          return http.Response(
            jsonEncode({
              'ai': {'access_ok': true},
            }),
            200,
          );
        }
        return http.Response('not found', 404);
      });
      final svc = AiChatService('http://example.com/', client: client);
      final ok = await svc.checkHealth();
      expect(ok, isTrue);
    });

    test('verifyUser returns parsed map on 200', () async {
      final client = MockClient((request) async {
        if (request.method == 'GET' &&
            request.url.path.endsWith('auth/verify')) {
          return http.Response(jsonEncode({'user': 'u1'}), 200);
        }
        return http.Response('not found', 404);
      });
      final svc = AiChatService('http://example.com', client: client);
      final res = await svc.verifyUser();
      expect(res, isNotNull);
      expect(res?['user'], 'u1');
    });

    test('embed returns vector list', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' &&
            request.url.path.endsWith('vectors/embed')) {
          return http.Response(
            jsonEncode({
              'vector': [1, 2.5, 3],
            }),
            200,
          );
        }
        return http.Response('not found', 404);
      });
      final svc = AiChatService('http://example.com/', client: client);
      final vec = await svc.embed('text');
      expect(vec, [1.0, 2.5, 3.0]);
    });
  });
}
