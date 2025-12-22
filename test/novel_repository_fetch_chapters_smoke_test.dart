import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/repositories/remote_repository.dart';

void main() {
  test('fetchChaptersByNovel returns a list', () async {
    final client = MockClient((request) async {
      if (request.method == 'GET' &&
          request.url.path == '/novels/any-novel-id/chapters') {
        return http.Response(jsonEncode([]), 200);
      }
      return http.Response('not found', 404);
    });
    final repo = NovelRepository(
      RemoteRepository('http://example.com', client: client),
    );
    final list = await repo.fetchChaptersByNovel('any-novel-id');
    expect(list, isA<List>());
  });
}
