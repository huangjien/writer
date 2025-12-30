import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/models/character.dart';
import 'package:writer/models/scene.dart';
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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocalStorageRepository Additional Tests', () {
    final repo = LocalStorageRepository(MockStorageService());

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
  });
}
