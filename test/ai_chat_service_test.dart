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
        if (request.method == 'POST' &&
            request.url.path == '/agents/deep-agent') {
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
        if (request.method == 'POST' &&
            request.url.path == '/agents/deep-agent') {
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
        if (request.method == 'POST' &&
            request.url.path == '/agents/deep-agent') {
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
        if (request.method == 'POST' &&
            request.url.path == '/agents/deep-agent') {
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
        if (request.method == 'POST' &&
            request.url.path == '/agents/deep-agent') {
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

    test(
      'sendMessage falls back to /agents/qa when deep-agent is unavailable',
      () async {
        final client = MockClient((request) async {
          if (request.method == 'POST' &&
              request.url.path == '/agents/deep-agent') {
            return http.Response('not found', 404);
          }
          if (request.method == 'POST' && request.url.path == '/agents/qa') {
            return http.Response(jsonEncode({'answer': 'fallback'}), 200);
          }
          return http.Response('not found', 404);
        });
        final svc = AiChatService(
          RemoteRepository('http://example.com/', client: client),
        );
        final reply = await svc.sendMessage('hi');
        expect(reply, 'fallback');
      },
    );

    test('sendMessageDeepAgent returns answer field', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' &&
            request.url.path == '/agents/deep-agent') {
          return http.Response(jsonEncode({'answer': 'ok'}), 200);
        }
        return http.Response('not found', 404);
      });
      final svc = AiChatService(
        RemoteRepository('http://example.com/', client: client),
      );
      final reply = await svc.sendMessageDeepAgent('hi');
      expect(reply, 'ok');
    });

    test('sendMessageDeepAgent supports reply and response fields', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' &&
            request.url.path == '/agents/deep-agent') {
          return http.Response(jsonEncode({'reply': 'r1'}), 200);
        }
        return http.Response('not found', 404);
      });
      final svc = AiChatService(
        RemoteRepository('http://example.com/', client: client),
      );
      final reply = await svc.sendMessageDeepAgent('hi');
      expect(reply, 'r1');

      final client2 = MockClient((request) async {
        if (request.method == 'POST' &&
            request.url.path == '/agents/deep-agent') {
          return http.Response(jsonEncode({'response': 'r2'}), 200);
        }
        return http.Response('not found', 404);
      });
      final svc2 = AiChatService(
        RemoteRepository('http://example.com/', client: client2),
      );
      final reply2 = await svc2.sendMessageDeepAgent('hi');
      expect(reply2, 'r2');
    });

    test(
      'sendMessageDeepAgent returns fallback when field type is wrong',
      () async {
        final client = MockClient((request) async {
          if (request.method == 'POST' &&
              request.url.path == '/agents/deep-agent') {
            return http.Response(jsonEncode({'answer': 123}), 200);
          }
          return http.Response('not found', 404);
        });
        final svc = AiChatService(
          RemoteRepository('http://example.com/', client: client),
        );
        final reply = await svc.sendMessageDeepAgent('hi');
        expect(reply, 'No response from AI service');
      },
    );

    test('sendMessageDeepAgent handles 401 and 403', () async {
      final client401 = MockClient(
        (request) async => http.Response('unauth', 401),
      );
      final svc401 = AiChatService(
        RemoteRepository('http://example.com', client: client401),
      );
      expect(
        await svc401.sendMessageDeepAgent('x'),
        'Sign in required to use AI service',
      );

      final client403 = MockClient(
        (request) async => http.Response('forbidden', 403),
      );
      final svc403 = AiChatService(
        RemoteRepository('http://example.com', client: client403),
      );
      expect(
        await svc403.sendMessageDeepAgent('x'),
        'Feature not available for your plan',
      );
    });

    test('sendMessageDeepAgent returns error string on 500', () async {
      final client = MockClient((request) async => http.Response('error', 500));
      final svc = AiChatService(
        RemoteRepository('http://example.com', client: client),
      );
      expect(
        await svc.sendMessageDeepAgent('x'),
        contains('Failed to connect to AI service:'),
      );
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

    test(
      'sendMessageDeepAgent includes details when response is a map',
      () async {
        final client = MockClient((request) async {
          if (request.method == 'POST' &&
              request.url.path == '/agents/deep-agent') {
            return http.Response(
              jsonEncode({
                'answer': 'Main answer',
                'plan': 'Test plan',
                'stop_reason': 'completed',
                'rounds': 3,
              }),
              200,
            );
          }
          return http.Response('not found', 404);
        });
        final svc = AiChatService(
          RemoteRepository('http://example.com/', client: client),
        );
        final reply = await svc.sendMessageDeepAgent(
          'hi',
          includeDetails: true,
        );
        expect(reply, contains('Main answer'));
        expect(reply, contains('Deep Agent'));
        expect(reply, contains('Stop: completed (rounds: 3)'));
      },
    );

    test(
      'sendMessageDeepAgent does not include details when includeDetails is false',
      () async {
        final client = MockClient((request) async {
          if (request.method == 'POST' &&
              request.url.path == '/agents/deep-agent') {
            return http.Response(
              jsonEncode({
                'answer': 'Main answer',
                'plan': 'Test plan',
                'stop_reason': 'completed',
                'rounds': 3,
              }),
              200,
            );
          }
          return http.Response('not found', 404);
        });
        final svc = AiChatService(
          RemoteRepository('http://example.com/', client: client),
        );
        final reply = await svc.sendMessageDeepAgent(
          'hi',
          includeDetails: false,
        );
        expect(reply, 'Main answer');
        expect(reply, isNot(contains('Deep Agent')));
        expect(reply, isNot(contains('Stop:')));
      },
    );

    test('sendMessageDeepAgent handles tool_events in details', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' &&
            request.url.path == '/agents/deep-agent') {
          return http.Response(
            jsonEncode({
              'answer': 'Answer with tools',
              'tool_events': [
                {
                  'round': 1,
                  'tool': 'search',
                  'args': {'query': 'test'},
                },
                {
                  'round': 2,
                  'tool': 'read',
                  'args': {'file': 'doc.txt'},
                },
              ],
            }),
            200,
          );
        }
        return http.Response('not found', 404);
      });
      final svc = AiChatService(
        RemoteRepository('http://example.com/', client: client),
      );
      final reply = await svc.sendMessageDeepAgent('hi', includeDetails: true);
      expect(reply, contains('Answer with tools'));
      expect(reply, contains('Tools:'));
      expect(reply, contains('[1] search'));
      expect(reply, contains('[2] read'));
    });

    test(
      'sendMessageDeepAgent includes plan in details when available',
      () async {
        final client = MockClient((request) async {
          if (request.method == 'POST' &&
              request.url.path == '/agents/deep-agent') {
            return http.Response(
              jsonEncode({
                'answer': 'Planned answer',
                'plan': {
                  'steps': ['Step 1', 'Step 2', 'Step 3'],
                },
              }),
              200,
            );
          }
          return http.Response('not found', 404);
        });
        final svc = AiChatService(
          RemoteRepository('http://example.com/', client: client),
        );
        final reply = await svc.sendMessageDeepAgent(
          'hi',
          includeDetails: true,
        );
        expect(reply, contains('Planned answer'));
        expect(reply, contains('Plan:'));
        expect(reply, contains('- Step 1'));
        expect(reply, contains('- Step 2'));
        expect(reply, contains('- Step 3'));
      },
    );

    test(
      'sendMessageDeepAgent handles non-map response with includeDetails',
      () async {
        final client = MockClient((request) async {
          if (request.method == 'POST' &&
              request.url.path == '/agents/deep-agent') {
            return http.Response(jsonEncode('plain string response'), 200);
          }
          return http.Response('not found', 404);
        });
        final svc = AiChatService(
          RemoteRepository('http://example.com/', client: client),
        );
        final reply = await svc.sendMessageDeepAgent(
          'hi',
          includeDetails: true,
        );
        expect(reply, 'No response from AI service');
      },
    );

    test(
      'sendMessageDeepAgent includes details when stop_reason is present but rounds is null',
      () async {
        final client = MockClient((request) async {
          if (request.method == 'POST' &&
              request.url.path == '/agents/deep-agent') {
            return http.Response(
              jsonEncode({
                'answer': 'Answer with stop reason',
                'stop_reason': 'max_tokens',
              }),
              200,
            );
          }
          return http.Response('not found', 404);
        });
        final svc = AiChatService(
          RemoteRepository('http://example.com/', client: client),
        );
        final reply = await svc.sendMessageDeepAgent(
          'hi',
          includeDetails: true,
        );
        expect(reply, contains('Answer with stop reason'));
        expect(reply, contains('Stop: max_tokens (rounds: -)'));
      },
    );

    test(
      'sendMessageDeepAgent includes details when rounds is present but stop_reason is null',
      () async {
        final client = MockClient((request) async {
          if (request.method == 'POST' &&
              request.url.path == '/agents/deep-agent') {
            return http.Response(
              jsonEncode({'answer': 'Answer with rounds', 'rounds': 5}),
              200,
            );
          }
          return http.Response('not found', 404);
        });
        final svc = AiChatService(
          RemoteRepository('http://example.com/', client: client),
        );
        final reply = await svc.sendMessageDeepAgent(
          'hi',
          includeDetails: true,
        );
        expect(reply, contains('Answer with rounds'));
        expect(reply, contains('Stop: - (rounds: 5)'));
      },
    );

    test('_formatError handles 404 error', () async {
      final client = MockClient(
        (request) async => http.Response('not found', 404),
      );
      final svc = AiChatService(
        RemoteRepository('http://example.com', client: client),
      );
      expect(
        await svc.sendMessageDeepAgent('x'),
        contains('Failed to connect to AI service'),
      );
    });

    test('_formatError handles network errors', () async {
      final client = MockClient((request) async {
        throw Exception('Network unreachable');
      });
      final svc = AiChatService(
        RemoteRepository('http://example.com', client: client),
      );
      expect(
        await svc.sendMessageDeepAgent('x'),
        contains('Failed to connect to AI service'),
      );
    });

    test('compressContext returns compressed text', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' &&
            request.url.path == '/agents/deep-agent') {
          final body = jsonDecode(request.body);
          expect(body['question'], contains('summarize and compress'));
          expect(body['context'], 'Long context to compress');
          expect(body['max_plan_steps'], 3);
          expect(body['max_tool_rounds'], 3);
          expect(body['reflection_mode'], 'off');
          return http.Response(
            jsonEncode({'answer': 'Compressed summary'}),
            200,
          );
        }
        return http.Response('not found', 404);
      });
      final svc = AiChatService(
        RemoteRepository('http://example.com/', client: client),
      );
      final result = await svc.compressContext('Long context to compress');
      expect(result, 'Compressed summary');
    });

    test('compressContext handles errors gracefully', () async {
      final client = MockClient((request) async => http.Response('error', 500));
      final svc = AiChatService(
        RemoteRepository('http://example.com', client: client),
      );
      final result = await svc.compressContext('context');
      expect(result, contains('Failed to connect to AI service'));
    });

    test('compressContext handles 401', () async {
      final client = MockClient(
        (request) async => http.Response('unauth', 401),
      );
      final svc = AiChatService(
        RemoteRepository('http://example.com', client: client),
      );
      final result = await svc.compressContext('context');
      expect(result, 'Sign in required to use AI service');
    });

    test('ragSearch returns search results', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' && request.url.path == '/rag/search') {
          final body = jsonDecode(request.body);
          expect(body['query'], 'test query');
          expect(body['initial_top_k'], 10);
          expect(body['final_top_k'], 5);
          expect(body['refinement_enabled'], true);
          return http.Response(
            jsonEncode({
              'results': [
                {'id': '1', 'text': 'Result 1'},
                {'id': '2', 'text': 'Result 2'},
              ],
            }),
            200,
          );
        }
        return http.Response('not found', 404);
      });
      final svc = AiChatService(
        RemoteRepository('http://example.com/', client: client),
      );
      final result = await svc.ragSearch(query: 'test query');
      expect(result, isNotNull);
      expect(result!['results'], isList);
      expect(result['results'].length, 2);
    });

    test('ragSearch sends category when provided', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' && request.url.path == '/rag/search') {
          final body = jsonDecode(request.body);
          expect(body['category'], 'writing');
          return http.Response(jsonEncode({'results': []}), 200);
        }
        return http.Response('not found', 404);
      });
      final svc = AiChatService(
        RemoteRepository('http://example.com/', client: client),
      );
      final result = await svc.ragSearch(query: 'test', category: 'writing');
      expect(result, isNotNull);
    });

    test('ragSearch sends custom top_k values', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' && request.url.path == '/rag/search') {
          final body = jsonDecode(request.body);
          expect(body['initial_top_k'], 20);
          expect(body['final_top_k'], 10);
          return http.Response(jsonEncode({'results': []}), 200);
        }
        return http.Response('not found', 404);
      });
      final svc = AiChatService(
        RemoteRepository('http://example.com/', client: client),
      );
      final result = await svc.ragSearch(
        query: 'test',
        initialTopK: 20,
        finalTopK: 10,
      );
      expect(result, isNotNull);
    });

    test('ragSearch sends refinement_enabled flag', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' && request.url.path == '/rag/search') {
          final body = jsonDecode(request.body);
          expect(body['refinement_enabled'], false);
          return http.Response(jsonEncode({'results': []}), 200);
        }
        return http.Response('not found', 404);
      });
      final svc = AiChatService(
        RemoteRepository('http://example.com/', client: client),
      );
      final result = await svc.ragSearch(
        query: 'test',
        refinementEnabled: false,
      );
      expect(result, isNotNull);
    });

    test('ragSearch returns null on error', () async {
      final client = MockClient((request) async => http.Response('error', 500));
      final svc = AiChatService(
        RemoteRepository('http://example.com/', client: client),
      );
      final result = await svc.ragSearch(query: 'test');
      expect(result, isNull);
    });

    test('ragSearch returns null on non-Map response', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' && request.url.path == '/rag/search') {
          return http.Response(jsonEncode(['not', 'a', 'map']), 200);
        }
        return http.Response('not found', 404);
      });
      final svc = AiChatService(
        RemoteRepository('http://example.com/', client: client),
      );
      final result = await svc.ragSearch(query: 'test');
      expect(result, isNull);
    });

    test('ragSearch returns null on invalid JSON', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' && request.url.path == '/rag/search') {
          return http.Response('invalid json', 200);
        }
        return http.Response('not found', 404);
      });
      final svc = AiChatService(
        RemoteRepository('http://example.com/', client: client),
      );
      final result = await svc.ragSearch(query: 'test');
      expect(result, isNull);
    });
  });
}
