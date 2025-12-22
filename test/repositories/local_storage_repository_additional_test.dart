import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/models/character.dart';
import 'package:writer/models/scene.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocalStorageRepository Additional Tests', () {
    final repo = LocalStorageRepository();

    test('saveChapterForm and getChapterForm (Character)', () async {
      const novelId = 'n1';
      const char = Character(
        novelId: novelId,
        name: 'Char1',
        role: 'Role',
        bio: 'Bio',
      );

      await repo.saveCharacterForm(novelId, char);

      final saved = await repo.getCharacterForm(novelId);
      expect(saved, isNotNull);
      expect(saved!.name, 'Char1');
      expect(saved.role, 'Role');
      expect(saved.bio, 'Bio');
    });

    test('saveSceneForm and getSceneForm', () async {
      const novelId = 'n1';
      const scene = Scene(
        novelId: novelId,
        title: 'Scene1',
        summary: 'Sum',
        location: 'Loc',
      );

      await repo.saveSceneForm(novelId, scene);

      final saved = await repo.getSceneForm(novelId);
      expect(saved, isNotNull);
      expect(saved!.title, 'Scene1');
      expect(saved.summary, 'Sum');
      expect(saved.location, 'Loc');
    });

    test('saveCharacterNoteForm and getCharacterNoteForm (Map)', () async {
      const novelId = 'n1';
      await repo.saveCharacterNoteForm(
        novelId,
        title: 'Note1',
        summaries: 'S',
        synopses: 'Sy',
      );

      final saved = await repo.getCharacterNoteForm(novelId);
      expect(saved, isNotNull);
      expect(saved!['title'], 'Note1');
      expect(saved['character_summaries'], 'S');
    });

    test('listCharacterNotes returns cached note', () async {
      const novelId = 'n1';
      await repo.saveCharacterNoteForm(novelId, title: 'Note1');

      final notes = await repo.listCharacterNotes(novelId);
      expect(notes, hasLength(1));
      expect(notes.first.title, 'Note1');
    });

    test('deleteCharacterNoteByIdx (offline)', () async {
      const novelId = 'n1';
      await repo.saveCharacterNoteForm(novelId, title: 'Note1');
      await repo.deleteCharacterNoteByIdx(novelId, 1);
      final saved = await repo.getCharacterNoteForm(novelId);
      // Deletion removes the key
      expect(saved, isNull);
    });

    test('deleteSceneNoteByIdx (offline)', () async {
      const novelId = 'n1';
      await repo.saveSceneForm(
        novelId,
        const Scene(novelId: 'n1', title: 'S1'),
      );
      await repo.deleteSceneNoteByIdx(novelId, 1);
      final saved = await repo.getSceneForm(novelId);
      expect(saved, isNull);
    });
  });
}
