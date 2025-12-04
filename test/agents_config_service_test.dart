import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:writer/features/ai_chat/services/agents_config_service.dart';

void main() {
  group('AgentsConfigService', () {
    test('getEffective returns config map', () async {
      final client = MockClient((request) async {
        if (request.method == 'GET' &&
            request.url.path.endsWith('configs/agents/writer/effective')) {
          return http.Response(jsonEncode({'temperature': 0.7}), 200);
        }
        return http.Response('not found', 404);
      });
      final svc = AgentsConfigService('http://example.com/', client: client);
      final res = await svc.getEffective('writer');
      expect(res, isNotNull);
      expect(res?['temperature'], 0.7);
    });

    test('list returns array of maps', () async {
      final client = MockClient((request) async {
        if (request.method == 'GET' &&
            request.url.path.endsWith('configs/agents/writer')) {
          return http.Response(
            jsonEncode([
              {'id': 'a', 'temperature': 0.5},
              {'id': 'b', 'temperature': 0.8},
            ]),
            200,
          );
        }
        return http.Response('not found', 404);
      });
      final svc = AgentsConfigService('http://example.com', client: client);
      final res = await svc.list('writer');
      expect(res.length, 2);
      expect(res[0]['id'], 'a');
    });

    test('saveMyVersion posts payload and returns map', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' &&
            request.url.path.endsWith('configs/agents/writer')) {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(jsonEncode(body..addAll({'id': 'x'})), 200);
        }
        return http.Response('not found', 404);
      });
      final svc = AgentsConfigService('http://example.com/', client: client);
      final res = await svc.saveMyVersion('writer', {'temperature': 0.6});
      expect(res?['id'], 'x');
      expect(res?['temperature'], 0.6);
    });

    test('updateMyVersion puts payload and returns map', () async {
      final client = MockClient((request) async {
        if (request.method == 'PUT' &&
            request.url.path.endsWith('configs/agents/123')) {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(jsonEncode(body..addAll({'id': '123'})), 200);
        }
        return http.Response('not found', 404);
      });
      final svc = AgentsConfigService('http://example.com', client: client);
      final res = await svc.updateMyVersion('123', {'temperature': 0.9});
      expect(res?['id'], '123');
      expect(res?['temperature'], 0.9);
    });

    test('resetToPublic returns true for 204', () async {
      final client = MockClient((request) async {
        if (request.method == 'DELETE' &&
            request.url.path.endsWith('configs/agents/123')) {
          return http.Response('', 204);
        }
        return http.Response('not found', 404);
      });
      final svc = AgentsConfigService('http://example.com/', client: client);
      final ok = await svc.resetToPublic('123');
      expect(ok, isTrue);
    });
  });
}
