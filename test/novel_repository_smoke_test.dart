import 'package:flutter_test/flutter_test.dart';

import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/repositories/remote_repository.dart';

void main() {
  test('NovelRepository constructs', () async {
    final repo = NovelRepository(RemoteRepository('http://localhost'));
    expect(repo, isA<NovelRepository>());
  });
}
