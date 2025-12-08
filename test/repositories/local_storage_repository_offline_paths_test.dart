import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/models/scene.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('nextCharacterIdx and nextSceneIdx offline defaults', () async {
    final repo = LocalStorageRepository();
    final c = await repo.nextCharacterIdx('n1');
    final s = await repo.nextSceneIdx('n1');
    expect(c, 2);
    expect(s, 2);
  });

  test('list templates offline empty and delete by id no-op', () async {
    final repo = LocalStorageRepository();
    final chars = await repo.listCharacterTemplates();
    final scenes = await repo.listSceneTemplates();
    expect(chars, isEmpty);
    expect(scenes, isEmpty);
    await repo.deleteCharacterTemplate('x');
    await repo.deleteSceneTemplate('y');
  });

  test('delete by id offline no-op', () async {
    final repo = LocalStorageRepository();
    await repo.deleteCharacterNoteById('c1');
    await repo.deleteSceneNoteById('s1');
  });

  test('delete scene note by idx removes local form', () async {
    final repo = LocalStorageRepository();
    await repo.saveSceneForm('n1', const Scene(novelId: 'n1', title: 'S1'));
    expect((await repo.getSceneForm('n1'))?.title, 'S1');
    await repo.deleteSceneNoteByIdx('n1', 1);
    expect(await repo.getSceneForm('n1'), isNull);
  });
}
