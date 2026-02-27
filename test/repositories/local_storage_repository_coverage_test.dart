import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/chapter_cache.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/character.dart';
import 'package:writer/models/scene.dart';
import 'package:writer/models/template.dart';
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

  // Helper to inject raw data for testing malformed JSON
  void inject(String key, String value) {
    _data[key] = value;
  }
}

void main() {
  group('LocalStorageRepository Coverage', () {
    late MockStorageService mockStorage;
    late LocalStorageRepository repository;

    setUp(() {
      mockStorage = MockStorageService();
      repository = LocalStorageRepository(mockStorage);
    });

    test('Placeholder methods return expected defaults', () async {
      expect(await repository.listCharacterTemplates(), isEmpty);
      expect(await repository.listSceneTemplates(), isEmpty);
      expect(await repository.searchSceneTemplates('query'), isEmpty);
      expect(await repository.nextCharacterIdx('novel1'), 2);
      expect(await repository.nextSceneIdx('novel1'), 2);
      expect(await repository.getCharacterTemplateById('id'), isNull);
      expect(await repository.getSceneTemplateById('id'), isNull);
    });

    test('Handles malformed JSON gracefully', () async {
      mockStorage.inject('chapter_c1', '{ malformed json');
      expect(await repository.getChapter('c1'), isNull);

      mockStorage.inject('library_novels_cache', '{ malformed json');
      expect(await repository.getLibraryNovels(), isEmpty);
      mockStorage.inject('library_novels_cache', 'not a list');
      expect(await repository.getLibraryNovels(), isEmpty);

      mockStorage.inject('character_form_n1', '{ malformed');
      expect(await repository.getCharacterForm('n1'), isNull);

      mockStorage.inject('character_note_form_n1', '{ malformed');
      expect(await repository.getCharacterNoteForm('n1'), isNull);

      mockStorage.inject('scene_form_n1', '{ malformed');
      expect(await repository.getSceneForm('n1'), isNull);

      mockStorage.inject('character_template_form_n1', '{ malformed');
      expect(await repository.getCharacterTemplateForm('n1'), isNull);

      mockStorage.inject('scene_template_form_n1', '{ malformed');
      expect(await repository.getSceneTemplateForm('n1'), isNull);

      mockStorage.inject('novel_n1', '{ malformed');
      expect(await repository.getNovel('n1'), isNull);

      mockStorage.inject('novels_list', '{ malformed');
      expect(await repository.getNovelsList(), isEmpty);

      mockStorage.inject('chapters_list_n1', '{ malformed');
      expect(await repository.getChaptersList('n1'), isEmpty);

      mockStorage.inject('cache_meta_key', '{ malformed');
      expect(await repository.getCacheMetadata('key'), isNull);
    });

    test('renameChapterId handles edge cases', () async {
      // Empty/invalid inputs
      await repository.renameChapterId(from: '', to: 'to');
      await repository.renameChapterId(from: 'from', to: '');
      await repository.renameChapterId(from: 'same', to: 'same');

      // Source not found
      await repository.renameChapterId(from: 'missing', to: 'target');
      expect(await repository.getChapter('target'), isNull);

      // Success case
      final chapter = ChapterCache(
        chapterId: 'from',
        novelId: 'n1',
        idx: 1,
        title: 'Title',
        content: 'Content',
        lastUpdated: DateTime.now(),
      );
      await repository.saveChapter(chapter);
      await repository.renameChapterId(from: 'from', to: 'to');

      expect(await repository.getChapter('from'), isNull);
      final renamed = await repository.getChapter('to');
      expect(renamed, isNotNull);
      expect(renamed!.chapterId, 'to');
      expect(renamed.title, 'Title');
    });

    test('getDownloadedNovelIds handles malformed data', () async {
      mockStorage.inject('chapter_c1', '{ "novelId": "n1" }'); // Good
      mockStorage.inject('chapter_c2', '{ "novelId": null }'); // Null novelId
      mockStorage.inject('chapter_c3', '{ malformed'); // Malformed
      mockStorage.inject('other_key', 'value'); // Not starting with chapter_

      final ids = await repository.getDownloadedNovelIds();
      expect(ids, contains('n1'));
      expect(ids.length, 1);
    });

    test('listCharacterNotes handles malformed data', () async {
      mockStorage.inject('character_note_form_n1', '{ malformed');
      expect(await repository.listCharacterNotes('n1'), isEmpty);

      mockStorage.inject('character_note_form_n1', 'null');
      expect(await repository.listCharacterNotes('n1'), isEmpty);
    });

    test('listSceneNotes handles malformed data', () async {
      mockStorage.inject('scene_form_n1', '{ malformed');
      expect(await repository.listSceneNotes('n1'), isEmpty);
    });

    test('clearChapterCache removes only chapter keys', () async {
      mockStorage.inject('chapter_c1', '{}');
      mockStorage.inject('chapter_c2', '{}');
      mockStorage.inject('other_key', '{}');

      final removed = await repository.clearChapterCache();
      expect(removed, 2);
      expect(mockStorage.getString('chapter_c1'), isNull);
      expect(mockStorage.getString('other_key'), isNotNull);
    });

    test('saveNovelsList and getNovelsList', () async {
      const novel = Novel(
        id: 'n1',
        title: 'T',
        languageCode: 'en',
        isPublic: true,
      );
      await repository.saveNovelsList([novel]);
      final list = await repository.getNovelsList();
      expect(list.length, 1);
      expect(list.first.id, 'n1');
    });

    test('clearCacheByNovel', () async {
      mockStorage.inject('chapters_list_n1', '{}');
      mockStorage.inject('cache_meta_chapters_list_n1', '{}');

      await repository.clearCacheByNovel('n1');

      expect(mockStorage.getString('chapters_list_n1'), isNull);
      expect(mockStorage.getString('cache_meta_chapters_list_n1'), isNull);
    });

    test('save and get LibraryNovels', () async {
      const novel = Novel(
        id: 'n1',
        title: 'T',
        languageCode: 'en',
        isPublic: true,
      );
      await repository.saveLibraryNovels([novel]);
      final list = await repository.getLibraryNovels();
      expect(list.length, 1);
      expect(list.first.id, 'n1');
    });

    test('save and get SummaryText', () async {
      await repository.saveSummaryText('n1', 'summary');
      expect(await repository.getSummaryText('n1'), 'summary');
    });

    test('save and get CharacterForm', () async {
      const char = Character(novelId: 'n1', name: 'name');
      await repository.saveCharacterForm('n1', char);
      final loaded = await repository.getCharacterForm('n1');
      expect(loaded, isNotNull);
      expect(loaded!.name, 'name');
      await repository.deleteCharacterForm('n1');
      expect(await repository.getCharacterForm('n1'), isNull);
    });

    test('save and get CharacterNoteForm', () async {
      await repository.saveCharacterNoteForm('n1', title: 'T');
      final loaded = await repository.getCharacterNoteForm('n1');
      expect(loaded, isNotNull);
      expect(loaded!['title'], 'T');

      // Also listCharacterNotes
      final list = await repository.listCharacterNotes('n1');
      expect(list.length, 1);
      expect(list.first.title, 'T');

      await repository.deleteCharacterNoteForm('n1');
      expect(await repository.getCharacterNoteForm('n1'), isNull);
    });

    test('save and get SceneForm', () async {
      const scene = Scene(novelId: 'n1', title: 'T');
      await repository.saveSceneForm('n1', scene);
      final loaded = await repository.getSceneForm('n1');
      expect(loaded, isNotNull);
      expect(loaded!.title, 'T');

      // Also listSceneNotes
      final list = await repository.listSceneNotes('n1');
      expect(list.length, 1);
      expect(list.first.title, 'T');

      await repository.deleteSceneForm('n1');
      expect(await repository.getSceneForm('n1'), isNull);
    });

    test('save and get CharacterTemplateForm', () async {
      const t = TemplateItem(novelId: 'n1', name: 'N');
      await repository.saveCharacterTemplateForm('n1', t);
      final loaded = await repository.getCharacterTemplateForm('n1');
      expect(loaded, isNotNull);
      expect(loaded!.name, 'N');

      await repository.deleteCharacterTemplate('n1');
      // deleteCharacterTemplate uses 'character_template_form_$id', same as save.
      expect(await repository.getCharacterTemplateForm('n1'), isNull);
    });

    test('save and get SceneTemplateForm', () async {
      const t = TemplateItem(novelId: 'n1', name: 'N');
      await repository.saveSceneTemplateForm('n1', t);
      final loaded = await repository.getSceneTemplateForm('n1');
      expect(loaded, isNotNull);
      expect(loaded!.name, 'N');

      await repository.deleteSceneTemplate('n1');
      expect(await repository.getSceneTemplateForm('n1'), isNull);
    });

    test('save and get Novel', () async {
      const novel = Novel(
        id: 'n1',
        title: 'T',
        languageCode: 'en',
        isPublic: true,
      );
      await repository.saveNovel(novel);
      final loaded = await repository.getNovel('n1');
      expect(loaded, isNotNull);
      expect(loaded!.title, 'T');

      await repository.removeNovel('n1');
      expect(await repository.getNovel('n1'), isNull);
    });

    test('save and get ChaptersList', () async {
      final list = [
        {'id': 'c1', 'novel_id': 'n1', 'idx': 1, 'title': 'T'},
      ];
      await repository.saveChaptersList('n1', list);
      final loaded = await repository.getChaptersList('n1');
      expect(loaded.length, 1);
      expect(loaded.first.chapterId, 'c1');
    });

    test('getKeys', () async {
      mockStorage.inject('k1', 'v');
      final keys = await repository.getKeys();
      expect(keys, contains('k1'));
    });
  });
}
