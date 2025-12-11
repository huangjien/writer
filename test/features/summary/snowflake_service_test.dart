import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:writer/features/summary/snowflake_service.dart';
import 'package:writer/models/snowflake.dart';

void main() {
  group('SnowflakeService', () {
    test('refineSummary parses response', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' &&
            request.url.path.endsWith('snowflake/refine')) {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['novel_id'], 'n1');
          expect(body['summary_content'], 'base');
          return http.Response(
            jsonEncode({
              'novel_id': 'n1',
              'summary_content': 'updated',
              'status': 'refining',
              'ai_question': 'Q',
              'suggestions': ['a', 'b'],
              'critique': 'c',
              'history': [
                {'role': 'user', 'content': 'u1'},
              ],
            }),
            200,
          );
        }
        return http.Response('not found', 404);
      });
      final svc = SnowflakeService('http://example.com/', client: client);
      final res = await svc.refineSummary(
        SnowflakeRefinementInput(
          novelId: 'n1',
          summaryContent: 'base',
          userResponse: null,
        ),
      );
      expect(res, isNotNull);
      expect(res!.summaryContent, 'updated');
      expect(res.status, 'refining');
      expect(res.aiQuestion, 'Q');
      expect(res.suggestions, ['a', 'b']);
      expect(res.history?.length, 1);
    });

    test('refineSummary handles baseUrl without trailing slash', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' &&
            request.url.path.endsWith('snowflake/refine')) {
          return http.Response(
            jsonEncode({
              'novel_id': 'n2',
              'summary_content': 's2',
              'status': 'refined',
            }),
            200,
          );
        }
        return http.Response('not found', 404);
      });
      final svc = SnowflakeService('http://example.com', client: client);
      final res = await svc.refineSummary(
        SnowflakeRefinementInput(
          novelId: 'n2',
          summaryContent: 'x',
          userResponse: null,
        ),
      );
      expect(res, isNotNull);
      expect(res!.status, 'refined');
    });

    test('refineSummary returns null on non-200', () async {
      final client = MockClient((request) async => http.Response('bad', 500));
      final svc = SnowflakeService('http://example.com/', client: client);
      final res = await svc.refineSummary(
        SnowflakeRefinementInput(
          novelId: 'n3',
          summaryContent: 'x',
          userResponse: null,
        ),
      );
      expect(res, isNull);
    });
  });

  test('refineSummary returns null on 200 with non-map body', () async {
    final client = MockClient((request) async {
      if (request.method == 'POST' &&
          request.url.path.endsWith('snowflake/refine')) {
        return http.Response(jsonEncode([1, 2, 3]), 200);
      }
      return http.Response('not found', 404);
    });
    final svc = SnowflakeService('http://example.com/', client: client);
    final res = await svc.refineSummary(
      SnowflakeRefinementInput(
        novelId: 'n4',
        summaryContent: 'x',
        userResponse: null,
      ),
    );
    expect(res, isNull);
  });
}
