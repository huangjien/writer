import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/chapter_cache.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/services/storage_service.dart';

class _InMemoryStorageService implements StorageService {
  final Map<String, String?> _store = {};

  @override
  String? getString(String key) => _store[key];

  @override
  Set<String> getKeys() => _store.keys.toSet();

  @override
  Future<void> remove(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> setString(String key, String? value) async {
    _store[key] = value;
  }
}

void main() {
  test('renameChapterId moves cache key', () async {
    final repo = LocalStorageRepository(_InMemoryStorageService());
    await repo.saveChapter(
      ChapterCache(
        chapterId: 'a',
        novelId: 'n1',
        idx: 1,
        title: 'T',
        content: 'C',
        lastUpdated: DateTime.now(),
      ),
    );

    await repo.renameChapterId(from: 'a', to: 'b');

    final old = await repo.getChapter('a');
    final moved = await repo.getChapter('b');
    expect(old, isNull);
    expect(moved, isNotNull);
    expect(moved!.chapterId, 'b');
    expect(moved.content, 'C');
  });
}
