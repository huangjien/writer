import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/services/prompts_service.dart';

class FakeHttpHeaders implements HttpHeaders {
  final Map<String, List<String>> _headers = {};
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    final key = name.toLowerCase();
    _headers.putIfAbsent(key, () => []).add(value.toString());
  }

  @override
  String? value(String name) {
    final key = name.toLowerCase();
    final list = _headers[key];
    return list == null || list.isEmpty ? null : list.last;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  @override
  final int statusCode;
  final String body;
  FakeHttpClientResponse(this.statusCode, this.body);
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final data = utf8.encode(body);
    final stream = Stream<List<int>>.fromIterable([data]);
    return stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHttpClientRequest implements HttpClientRequest {
  @override
  final String method;
  @override
  final Uri uri;
  @override
  final FakeHttpHeaders headers = FakeHttpHeaders();
  final List<int> _buffer = [];
  FakeHttpClientRequest(this.method, this.uri);
  @override
  void add(List<int> data) {
    _buffer.addAll(data);
  }

  @override
  Future<HttpClientResponse> close() async {
    final path = uri.path;
    if (method == 'GET' && path == '/prompts') {
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
      return FakeHttpClientResponse(
        HttpStatus.ok,
        jsonEncode({'items': items}),
      );
    }
    if (method == 'GET' && path == '/prompts/public') {
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
      return FakeHttpClientResponse(HttpStatus.ok, jsonEncode(items));
    }
    if (method == 'GET' && path.startsWith('/prompts/')) {
      final id = path.split('/').last;
      final data = {
        'id': id,
        'user_id': 'u1',
        'prompt_key': 'system.beta.male',
        'language': 'en',
        'content': 'X',
        'is_public': false,
      };
      return FakeHttpClientResponse(HttpStatus.ok, jsonEncode(data));
    }
    if (method == 'POST' && path == '/prompts') {
      final data = jsonDecode(utf8.decode(_buffer)) as Map<String, dynamic>;
      final created = {
        'id': 'new',
        'user_id': 'u1',
        'prompt_key': data['prompt_key'],
        'language': data['language'],
        'content': data['content'],
        'is_public': false,
      };
      return FakeHttpClientResponse(HttpStatus.ok, jsonEncode(created));
    }
    if (method == 'POST' && path == '/prompts/public') {
      final auth = headers.value('authorization');
      if (auth == null || !auth.startsWith('Bearer ')) {
        return FakeHttpClientResponse(HttpStatus.forbidden, 'Forbidden');
      }
      final data = jsonDecode(utf8.decode(_buffer)) as Map<String, dynamic>;
      final created = {
        'id': 'pub',
        'user_id': null,
        'prompt_key': data['prompt_key'],
        'language': data['language'],
        'content': data['content'],
        'is_public': true,
      };
      return FakeHttpClientResponse(HttpStatus.ok, jsonEncode(created));
    }
    if (method == 'PATCH' && path.startsWith('/prompts/')) {
      final id = path.split('/').last;
      final data = jsonDecode(utf8.decode(_buffer)) as Map<String, dynamic>;
      final updated = {
        'id': id,
        'user_id': 'u1',
        'prompt_key': 'system.beta.male',
        'language': 'en',
        'content': data['content'],
        'is_public': false,
      };
      return FakeHttpClientResponse(HttpStatus.ok, jsonEncode(updated));
    }
    if (method == 'DELETE' && path.startsWith('/prompts/')) {
      return FakeHttpClientResponse(
        HttpStatus.ok,
        jsonEncode({'deleted': true}),
      );
    }
    return FakeHttpClientResponse(HttpStatus.notFound, 'Not found');
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHttpClient implements HttpClient {
  @override
  Duration? connectionTimeout;
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return FakeHttpClientRequest(method, url);
  }

  @override
  void close({bool force = false}) {}
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return FakeHttpClient();
  }
}

void main() {
  setUp(() {
    HttpOverrides.global = FakeOverrides();
  });

  test('fetchPrompts returns items and public list', () async {
    final svc = PromptsService(baseUrl: 'http://any');
    final list1 = await svc.fetchPrompts();
    expect(list1.length, 1);
    expect(list1.first.promptKey, 'system.beta.male');

    final list2 = await svc.fetchPrompts(isPublic: true);
    expect(list2.length, 1);
    expect(list2.first.isPublic, isTrue);
  });

  test('get/create/update/delete prompt', () async {
    final svc = PromptsService(baseUrl: 'http://any', authToken: 't');
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
    final svc = PromptsService(baseUrl: 'http://any');
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
