import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/remote_repository.dart';

void main() {
  test('ChapterRepository constructs and getNextIdx returns int', () async {
    SharedPreferences.setMockInitialValues({});
    final client = MockClient((request) async {
      if (request.method == 'GET' &&
          request.url.path == '/novels/non-existent/chapters') {
        return http.Response(jsonEncode([]), 200);
      }
      return http.Response('not found', 404);
    });
    final remote = RemoteRepository('http://example.com', client: client);
    final local = LocalStorageRepository();
    final repo = ChapterRepository(remote, local);
    expect(await repo.getNextIdx('non-existent'), isA<int>());
  });
}
