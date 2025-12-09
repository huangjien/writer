import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:writer/services/prompts_service.dart';

MockClient _mockClient() {
  return MockClient((request) async {
    final m = request.method;
    final path = request.url.path;
    if (m == 'GET' && (path == '/prompts' || path == '/prompts/')) {
      final items = [
        {
          'id': '1',
          'user_id': 'u1',
          'prompt_key': 'system.beta.male',
          'language': 'en',
          'content': 'A',
          'is_public': false,
        },
      ];
      return http.Response(jsonEncode({'items': items}), 200);
    }
    if (m == 'GET' && path == '/prompts/public') {
      final items = [
        {
          'id': '2',
          'user_id': null,
          'prompt_key': 'system.beta.editor',
          'language': 'zh',
          'content': 'B',
          'is_public': true,
        },
      ];
      return http.Response(jsonEncode(items), 200);
    }
    if (m == 'GET' && path.startsWith('/prompts/')) {
      final id = path.split('/').last;
      final data = {
        'id': id,
        'user_id': 'u1',
        'prompt_key': 'system.beta.male',
        'language': 'en',
        'content': 'X',
        'is_public': false,
      };
      return http.Response(jsonEncode(data), 200);
    }
    if (m == 'POST' && (path == '/prompts' || path == '/prompts/')) {
      final data = jsonDecode(request.body) as Map<String, dynamic>;
      final created = {
        'id': 'new',
        'user_id': 'u1',
        'prompt_key': data['prompt_key'],
        'language': data['language'],
        'content': data['content'],
        'is_public': false,
      };
      return http.Response(jsonEncode(created), 200);
    }
    if (m == 'POST' && path == '/prompts/public') {
      final auth = request.headers['authorization'];
      if (auth == null || !auth.startsWith('Bearer ')) {
        return http.Response('Forbidden', 403);
      }
      final data = jsonDecode(request.body) as Map<String, dynamic>;
      final created = {
        'id': 'pub',
        'user_id': null,
        'prompt_key': data['prompt_key'],
        'language': data['language'],
        'content': data['content'],
        'is_public': true,
      };
      return http.Response(jsonEncode(created), 200);
    }
    if (m == 'PATCH' && path.startsWith('/prompts/')) {
      final id = path.split('/').last;
      final data = jsonDecode(request.body) as Map<String, dynamic>;
      final updated = {
        'id': id,
        'user_id': 'u1',
        'prompt_key': 'system.beta.male',
        'language': 'en',
        'content': data['content'],
        'is_public': false,
      };
      return http.Response(jsonEncode(updated), 200);
    }
    if (m == 'DELETE' && path.startsWith('/prompts/')) {
      return http.Response(jsonEncode({'deleted': true}), 200);
    }
    return http.Response('Not found', 404);
  });
}

void main() {
  test('fetchPrompts returns items and public list', () async {
    final svc = PromptsService(baseUrl: 'http://any', client: _mockClient());
    final list1 = await svc.fetchPrompts();
    expect(list1.length, 1);
    expect(list1.first.promptKey, 'system.beta.male');

    final list2 = await svc.fetchPrompts(isPublic: true);
    expect(list2.length, 1);
    expect(list2.first.isPublic, isTrue);
  });

  test('get/create/update/delete prompt', () async {
    final svc = PromptsService(
      baseUrl: 'http://any',
      authToken: 't',
      client: _mockClient(),
    );
    final p = await svc.getPrompt('123');
    expect(p.id, '123');

    final created = await svc.createPrompt(
      promptKey: 'system.beta.male',
      language: 'en',
      content: 'Z',
    );
    expect(created.id, 'new');
    expect(created.isPublic, isFalse);

    final pub = await svc.createPrompt(
      promptKey: 'system.beta.male',
      language: 'en',
      content: 'Z',
      isPublic: true,
    );
    expect(pub.id, 'pub');
    expect(pub.isPublic, isTrue);

    final upd = await svc.updatePrompt(id: 'new', content: 'Y');
    expect(upd.content, 'Y');

    final ok = await svc.deletePrompt('new');
    expect(ok, isTrue);
  });

  test('public create without auth throws ApiException', () async {
    final svc = PromptsService(baseUrl: 'http://any', client: _mockClient());
    try {
      await svc.createPrompt(
        promptKey: 'system.beta.male',
        language: 'en',
        content: 'X',
        isPublic: true,
      );
      fail('expected ApiException');
    } catch (e) {
      expect(e is ApiException, isTrue);
      expect((e as ApiException).statusCode, 403);
    }
  });
}
