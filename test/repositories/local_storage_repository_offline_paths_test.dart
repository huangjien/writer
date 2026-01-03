import 'package:flutter_test/flutter_test.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/services/storage_service.dart';
import 'package:writer/models/chapter_cache.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/character.dart';
import 'package:writer/models/scene.dart';

class MockStorageService implements StorageService {
  final Map<String, String> _data = {};
  final List<String> setKeys = [];
  final List<String> getKeysLog = [];
  final List<String> removeKeysLog = [];

  @override
  String? getString(String key) {
    getKeysLog.add(key);
    return _data[key];
  }

  @override
  Future<void> setString(String key, String? value) async {
    setKeys.add(key);
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<void> remove(String key) async {
    removeKeysLog.add(key);
    _data.remove(key);
  }

  @override
  Set<String> getKeys() => _data.keys.toSet();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalStorageRepository Offline Paths (Keys) Tests', () {
    late MockStorageService mockStorage;
    late LocalStorageRepository repo;

    setUp(() {
      mockStorage = MockStorageService();
      repo = LocalStorageRepository(mockStorage);
    });

    test('saveChapter uses correct key path', () async {
      final chapter = ChapterCache(
        chapterId: 'ch123',
        novelId: 'nov456',
        idx: 1,
        title: 'Test Chapter',
        content: 'Content',
        lastUpdated: DateTime.now(),
      );
      await repo.saveChapter(chapter);
      expect(mockStorage.setKeys, contains('chapter_ch123'));
    });

    test('getChapter uses correct key path', () async {
      await repo.getChapter('ch123');
      expect(mockStorage.getKeysLog, contains('chapter_ch123'));
    });

    test('saveLibraryNovels uses correct key path', () async {
      await repo.saveLibraryNovels([
        Novel(
          id: 'nov1',
          title: 'N1',
          author: 'A1',
          description: 'D1',
          coverUrl: null,
          languageCode: 'en',
          isPublic: false,
        ),
      ]);
      expect(mockStorage.setKeys, contains('library_novels_cache'));
    });

    test('getLibraryNovels uses correct key path', () async {
      await repo.getLibraryNovels();
      expect(mockStorage.getKeysLog, contains('library_novels_cache'));
    });

    test('saveSummaryText uses correct key path', () async {
      await repo.saveSummaryText('nov1', 'summary');
      expect(mockStorage.setKeys, contains('summary_text_nov1'));
    });

    test('saveCharacterForm uses correct key path', () async {
      final character = Character(
        novelId: 'nov1',
        name: 'Char1',
        role: 'Role',
        bio: 'Bio',
      );
      await repo.saveCharacterForm('nov1', character);
      expect(mockStorage.setKeys, contains('character_form_nov1'));
    });

    test('saveCharacterNoteForm uses correct key path', () async {
      await repo.saveCharacterNoteForm('nov1', title: 'Note1');
      expect(mockStorage.setKeys, contains('character_note_form_nov1'));
    });

    test('saveSceneForm uses correct key path', () async {
      final scene = Scene(
        novelId: 'nov1',
        title: 'Scene1',
        location: 'Loc',
        summary: 'Sum',
      );
      await repo.saveSceneForm('nov1', scene);
      expect(mockStorage.setKeys, contains('scene_form_nov1'));
    });

    test('getDownloadedNovelIds extracts novelIds from chapters', () async {
      final c1 = ChapterCache(
        chapterId: 'ch1',
        novelId: 'novelA',
        idx: 1,
        title: 'T1',
        content: 'C1',
        lastUpdated: DateTime.now(),
      );
      final c2 = ChapterCache(
        chapterId: 'ch2',
        novelId: 'novelB',
        idx: 1,
        title: 'T2',
        content: 'C2',
        lastUpdated: DateTime.now(),
      );
      final c3 = ChapterCache(
        chapterId: 'ch3',
        novelId: 'novelA', // Same novel as c1
        idx: 2,
        title: 'T3',
        content: 'C3',
        lastUpdated: DateTime.now(),
      );
      await repo.saveChapter(c1);
      await repo.saveChapter(c2);
      await repo.saveChapter(c3);

      final ids = await repo.getDownloadedNovelIds();
      expect(ids, containsAll({'novelA', 'novelB'}));
      expect(ids.length, 2);
    });
  });
}
