import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/main.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/chapter_repository.dart';

void main() {
  test('localStorageRepositoryProvider returns LocalStorageRepository', () {
    final container = ProviderContainer();
    final repo = container.read(localStorageRepositoryProvider);
    expect(repo, isA<LocalStorageRepository>());
  });

  test('chapterRepositoryProvider returns ChapterRepository', () {
    final container = ProviderContainer();
    final repo = container.read(chapterRepositoryProvider);
    expect(repo, isA<ChapterRepository>());
  });
}
