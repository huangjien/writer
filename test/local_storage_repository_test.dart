import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/models/character.dart';
import 'package:writer/models/scene.dart';
import 'package:writer/models/chapter_cache.dart';
import 'package:writer/models/novel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocalStorageRepository character notes', () {
    test('save/get character note form via local storage', () async {
      final repo = LocalStorageRepository();
      await repo.saveCharacterNoteForm(
        'novel1',
        title: 'Protagonist',
        summaries: 'Hero of the story',
        synopses: 'Born in a small village',
        languageCode: 'en',
        idx: 1,
      );
      final form = await repo.getCharacterNoteForm('novel1', idx: 1);
      expect(form, isNotNull);
      expect(form!['title'], 'Protagonist');
      expect(form['character_summaries'], 'Hero of the story');
      expect(form['character_synopses'], 'Born in a small village');
      expect(form['language_code'], 'en');

      final list = await repo.listCharacterNotes('novel1');
      expect(list.length, 1);
      expect(list.first.idx, 1);
      expect(list.first.title, 'Protagonist');

      await repo.deleteCharacterNoteByIdx('novel1', 1);
      final afterDelete = await repo.listCharacterNotes('novel1');
      expect(afterDelete, isEmpty);
    });

    test('character form save/get via local storage', () async {
      final repo = LocalStorageRepository();
      final c = Character(
        novelId: 'n1',
        name: 'Alice',
        role: 'Detective',
        bio: 'Solves mysteries',
      );
      await repo.saveCharacterForm('n1', c, idx: 1);
      final got = await repo.getCharacterForm('n1', idx: 1);
      expect(got, isNotNull);
      expect(got!.name, 'Alice');
      expect(got.role, 'Detective');
      expect(got.bio, 'Solves mysteries');
    });

    test('nextCharacterIdx returns 2 when supabase disabled', () async {
      final repo = LocalStorageRepository();
      final next = await repo.nextCharacterIdx('n1');
      expect(next, 2);
    });
  });

  group('LocalStorageRepository scenes', () {
    test('save/get scene form via local storage', () async {
      final repo = LocalStorageRepository();
      final scene = Scene(
        novelId: 'n1',
        title: 'Opening',
        location: 'Village',
        summary: 'Meet the hero',
      );
      await repo.saveSceneForm('n1', scene, idx: 1);
      final got = await repo.getSceneForm('n1', idx: 1);
      expect(got, isNotNull);
      expect(got!.title, 'Opening');
      expect(got.location, 'Village');
      expect(got.summary, 'Meet the hero');

      final list = await repo.listSceneNotes('n1');
      expect(list.length, 1);
      expect(list.first.idx, 1);
      expect(list.first.title, 'Opening');

      await repo.deleteSceneNoteByIdx('n1', 1);
      final afterDelete = await repo.listSceneNotes('n1');
      expect(afterDelete, isEmpty);
    });

    test('nextSceneIdx returns 2 when supabase disabled', () async {
      final repo = LocalStorageRepository();
      final next = await repo.nextSceneIdx('n1');
      expect(next, 2);
    });
  });

  group('LocalStorageRepository summary and chapters', () {
    test('save/get summary text via local storage', () async {
      final repo = LocalStorageRepository();
      await repo.saveSummaryText('n1', 'Summary text');
      final got = await repo.getSummaryText('n1');
      expect(got, 'Summary text');
    });

    test('save/get/clear ChapterCache via local storage', () async {
      final repo = LocalStorageRepository();
      final cache = ChapterCache(
        chapterId: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'Chapter 1',
        content: 'Once upon a time',
        lastUpdated: DateTime.utc(2025, 1, 1),
      );
      await repo.saveChapter(cache);
      final got = await repo.getChapter('c1');
      expect(got, isNotNull);
      expect(got!.title, 'Chapter 1');

      final removed = await repo.clearChapterCache();
      expect(removed, greaterThanOrEqualTo(1));
      final after = await repo.getChapter('c1');
      expect(after, isNull);
    });
  });

  group('LocalStorageRepository library novels cache', () {
    test('save/get library novels', () async {
      final repo = LocalStorageRepository();
      final novels = [
        Novel(
          id: 'a',
          title: 'Novel A',
          author: 'Author A',
          description: 'Desc A',
          coverUrl: null,
          languageCode: 'en',
          isPublic: true,
        ),
        Novel(
          id: 'b',
          title: 'Novel B',
          author: 'Author B',
          description: 'Desc B',
          coverUrl: null,
          languageCode: 'en',
          isPublic: false,
        ),
      ];
      await repo.saveLibraryNovels(novels);
      final got = await repo.getLibraryNovels();
      expect(got.length, 2);
      expect(got[0].id, 'a');
      expect(got[1].id, 'b');
    });
  });
}
