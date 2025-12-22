import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/repositories/local_storage_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'deleteCharacterNoteByIdx removes local cache when cloud sync disabled',
    () async {
      final repo = LocalStorageRepository();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('character_note_form_n1', '{"title":"A"}');
      expect(prefs.getString('character_note_form_n1'), isNotNull);
      await repo.deleteCharacterNoteByIdx('n1', 1);
      expect(prefs.getString('character_note_form_n1'), isNull);
    },
  );

  test(
    'deleteSceneNoteByIdx removes local cache when cloud sync disabled',
    () async {
      final repo = LocalStorageRepository();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('scene_form_n1', '{"title":"S"}');
      expect(prefs.getString('scene_form_n1'), isNotNull);
      await repo.deleteSceneNoteByIdx('n1', 1);
      expect(prefs.getString('scene_form_n1'), isNull);
    },
  );

  test('nextCharacterIdx and nextSceneIdx return 2 offline', () async {
    final repo = LocalStorageRepository();
    final c = await repo.nextCharacterIdx('n1');
    final s = await repo.nextSceneIdx('n1');
    expect(c, 2);
    expect(s, 2);
  });

  test(
    'listCharacterTemplates and listSceneTemplates return empty offline',
    () async {
      final repo = LocalStorageRepository();
      final chars = await repo.listCharacterTemplates();
      final scenes = await repo.listSceneTemplates();
      expect(chars, isEmpty);
      expect(scenes, isEmpty);
    },
  );
}
