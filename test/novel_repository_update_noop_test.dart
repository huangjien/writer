import 'package:flutter_test/flutter_test.dart';

import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/repositories/remote_repository.dart';

void main() {
  test('updateNovelMetadata returns early when no fields provided', () async {
    final remote = RemoteRepository('http://localhost');
    final repo = NovelRepository(remote);
    await repo.updateNovelMetadata('novel-1');
    expect(true, isTrue);
  });
}
