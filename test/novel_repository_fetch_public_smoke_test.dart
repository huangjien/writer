import 'package:flutter_test/flutter_test.dart';

import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/repositories/remote_repository.dart';

void main() {
  test('fetchPublicNovels returns a list', () async {
    final repo = NovelRepository(RemoteRepository('http://localhost'));
    final list = await repo.fetchPublicNovels();
    expect(list, isA<List>());
  }, skip: true);
}
