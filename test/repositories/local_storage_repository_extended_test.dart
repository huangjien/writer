import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/models/chapter_cache.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/services/storage_service.dart';

class MockStorageService implements StorageService {
  final Map<String, String> _data = {};

  @override
  String? getString(String key) => _data[key];

  @override
  Future<void> setString(String key, String? value) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<void> remove(String key) async {
    _data.remove(key);
  }

  @override
  Set<String> getKeys() => _data.keys.toSet();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocalStorageRepository Extended', () {
    test('saveChapters saves multiple chapters', () async {
      final repo = LocalStorageRepository(MockStorageService());
      final c1 = ChapterCache(
        chapterId: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'C1',
        content: 'Content 1',
        lastUpdated: DateTime.now(),
      );
      final c2 = ChapterCache(
        chapterId: 'c2',
        novelId: 'n1',
        idx: 2,
        title: 'C2',
        content: 'Content 2',
        lastUpdated: DateTime.now(),
      );

      await repo.saveChapters([c1, c2]);

      final savedC1 = await repo.getChapter('c1');
      final savedC2 = await repo.getChapter('c2');

      expect(savedC1, isNotNull);
      expect(savedC1!.title, 'C1');
      expect(savedC2, isNotNull);
      expect(savedC2!.title, 'C2');
    });

    test('removeChapter removes chapter', () async {
      final repo = LocalStorageRepository(MockStorageService());
      final c1 = ChapterCache(
        chapterId: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'C1',
        content: 'Content 1',
        lastUpdated: DateTime.now(),
      );

      await repo.saveChapter(c1);
      expect(await repo.getChapter('c1'), isNotNull);

      await repo.removeChapter('c1');
      expect(await repo.getChapter('c1'), isNull);
    });
  });
}
