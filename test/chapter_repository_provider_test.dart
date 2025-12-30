import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/state/storage_service_provider.dart';

void main() {
  test('chapterRepositoryProvider can be read', () async {
    SharedPreferences.setMockInitialValues({});
    final client = MockClient((request) async => http.Response('[]', 200));
    final remote = RemoteRepository('http://example.com', client: client);
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    final local = LocalStorageRepository(storageService);
    final repo = ChapterRepository(remote, local);
    expect(await repo.getNextIdx('non-existent'), isA<int>());
  });
}
