import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novel_reader/repositories/local_storage_repository.dart';
import 'package:novel_reader/models/chapter_cache.dart';
import 'package:novel_reader/models/novel.dart';
import 'package:novel_reader/models/character.dart';
import 'package:novel_reader/models/scene.dart';
import 'package:novel_reader/models/template.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('save/get/remove ChapterCache and clearChapterCache works', () async {
    final repo = LocalStorageRepository();
    final cc1 = ChapterCache(
      chapterId: 'c1',
      novelId: 'n1',
      idx: 1,
      title: 'T1',
      content: 'X',
      lastUpdated: DateTime.utc(2024, 1, 1),
    );
    final cc2 = ChapterCache(
      chapterId: 'c2',
      novelId: 'n1',
      idx: 2,
      title: 'T2',
      content: 'Y',
      lastUpdated: DateTime.utc(2024, 1, 2),
    );

    await repo.saveChapter(cc1);
    await repo.saveChapter(cc2);
    final got1 = await repo.getChapter('c1');
    final got2 = await repo.getChapter('c2');
    expect(got1?.title, 'T1');
    expect(got2?.idx, 2);

    final removedCount = await repo.clearChapterCache();
    expect(removedCount, 2);
    expect(await repo.getChapter('c1'), isNull);
    expect(await repo.getChapter('c2'), isNull);

    await repo.saveChapter(cc1);
    await repo.removeChapter('c1');
    expect(await repo.getChapter('c1'), isNull);
  });

  test('save/get library novels cache', () async {
    final repo = LocalStorageRepository();
    final novels = [
      const Novel(
        id: 'n1',
        title: 'A',
        author: 'Auth',
        description: 'Desc',
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
      const Novel(
        id: 'n2',
        title: 'B',
        author: null,
        description: null,
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
    ];
    await repo.saveLibraryNovels(novels);
    final got = await repo.getLibraryNovels();
    expect(got.length, 2);
    expect(got.first.id, 'n1');
  });

  test('character/scene/template forms and summary text', () async {
    final repo = LocalStorageRepository();
    final ch = const Character(novelId: 'n1', name: 'C', role: 'R', bio: 'B');
    await repo.saveCharacterForm('n1', ch);
    final chGot = await repo.getCharacterForm('n1');
    expect(chGot?.name, 'C');

    final sc = const Scene(
      novelId: 'n1',
      title: 'S',
      location: 'L',
      summary: 'U',
    );
    await repo.saveSceneForm('n1', sc);
    final scGot = await repo.getSceneForm('n1');
    expect(scGot?.title, 'S');

    final ti = const TemplateItem(novelId: 'n1', name: 'T', description: 'D');
    await repo.saveCharacterTemplateForm('n1', ti);
    final tiGot = await repo.getCharacterTemplateForm('n1');
    expect(tiGot?.name, 'T');

    await repo.saveSceneTemplateForm('n1', ti);
    final stiGot = await repo.getSceneTemplateForm('n1');
    expect(stiGot?.name, 'T');

    await repo.saveSummaryText('n1', 'Summary text');
    final summary = await repo.getSummaryText('n1');
    expect(summary, 'Summary text');
  });
}
