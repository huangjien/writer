import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

import 'package:writer/repositories/progress_repository.dart';
import 'package:writer/repositories/remote_repository.dart';

void main() {
  test('lastProgressForNovel returns null when no user', () async {
    final client = MockClient((request) async {
      return http.Response('unauth', 401);
    });
    final repo = ProgressRepository(
      RemoteRepository('http://example.com', client: client),
    );
    final res = await repo.lastProgressForNovel('novel-1');
    expect(res, isNull);
  });

  test('latestProgressForUser returns null when no user', () async {
    final client = MockClient((request) async {
      return http.Response('unauth', 401);
    });
    final repo = ProgressRepository(
      RemoteRepository('http://example.com', client: client),
    );
    final res = await repo.latestProgressForUser();
    expect(res, isNull);
  });
}
