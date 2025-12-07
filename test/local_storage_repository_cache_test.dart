import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/models/chapter_cache.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/character.dart';
import 'package:writer/models/scene.dart';
import 'package:writer/models/template.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'save/get/remove ChapterCache and clearChapterCache shape filter',
    () async {
      final repo = LocalStorageRepository();
      final c1 = ChapterCache(
        chapterId: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'T1',
        content: 'A',
        lastUpdated: DateTime.utc(2025, 1, 1),
      );
      await repo.saveChapter(c1);
      final got = await repo.getChapter('c1');
      expect(got?.chapterId, 'c1');
      expect(got?.content, 'A');

      final c2 = ChapterCache(
        chapterId: 'c2',
        novelId: 'n1',
        idx: 2,
        title: 'T2',
        content: 'B',
        lastUpdated: DateTime.utc(2025, 1, 2),
      );
      await repo.saveChapters([c2]);
      expect((await repo.getChapter('c2'))?.title, 'T2');

      // Leave a non-chapter JSON to ensure clearChapterCache filters correctly
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('other_key', '{"hello":"world"}');

      final removed = await repo.clearChapterCache();
      expect(removed, 2);
      expect(await repo.getChapter('c1'), isNull);
      expect(await repo.getChapter('c2'), isNull);
      expect(prefs.getString('other_key'), isNotNull);

      await repo.removeChapter('c1'); // no-op after clear
    },
  );

  test('save/get Library novels', () async {
    final repo = LocalStorageRepository();
    final novels = [
      const Novel(
        id: 'n1',
        title: 'A',
        author: 'X',
        description: 'D',
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
      const Novel(
        id: 'n2',
        title: 'B',
        author: 'Y',
        description: 'E',
        coverUrl: null,
        languageCode: 'en',
        isPublic: false,
      ),
    ];
    await repo.saveLibraryNovels(novels);
    final got = await repo.getLibraryNovels();
    expect(got.length, 2);
    expect(got.first.id, 'n1');
  });

  test('character form save/get and note payload save/get', () async {
    final repo = LocalStorageRepository();
    final ch = const Character(
      novelId: 'n1',
      name: 'Alice',
      role: 'hero',
      bio: 'bio',
    );
    await repo.saveCharacterForm('n1', ch, idx: 1);
    final got = await repo.getCharacterForm('n1', idx: 1);
    expect(got?.name, 'Alice');
    expect(got?.role, 'hero');

    await repo.saveCharacterNoteForm(
      'n1',
      title: 'Alice',
      summaries: 'summary',
      synopses: 'synopsis',
      languageCode: 'en',
      idx: 1,
    );
    final note = await repo.getCharacterNoteForm('n1', idx: 1);
    expect(note?['title'], 'Alice');
    expect(note?['character_summaries'], 'summary');
    expect(note?['language_code'], 'en');
  });

  test('scene form save/get and listSceneNotes offline fallback', () async {
    final repo = LocalStorageRepository();
    final scene = const Scene(
      novelId: 'n1',
      title: 'S1',
      location: 'L',
      summary: 'SUM',
    );
    await repo.saveSceneForm('n1', scene, idx: 1);
    final got = await repo.getSceneForm('n1', idx: 1);
    expect(got?.title, 'S1');

    final notes = await repo.listSceneNotes('n1');
    expect(notes.length, 1);
    expect(notes.first.title, 'S1');
  });

  test('template save/get and summary text save/get', () async {
    final repo = LocalStorageRepository();
    final itemC = const TemplateItem(
      novelId: 'n1',
      name: 'Char',
      description: 'Desc',
    );
    await repo.saveCharacterTemplateForm('n1', itemC);
    final gotC = await repo.getCharacterTemplateForm('n1');
    expect(gotC?.name, 'Char');
    expect(gotC?.description, 'Desc');

    final itemS = const TemplateItem(
      novelId: 'n1',
      name: 'Scene',
      description: 'Desc2',
    );
    await repo.saveSceneTemplateForm('n1', itemS);
    final gotS = await repo.getSceneTemplateForm('n1');
    expect(gotS?.name, 'Scene');

    await repo.saveSummaryText('n1', 'Hello');
    final txt = await repo.getSummaryText('n1');
    expect(txt, 'Hello');
  });
}
