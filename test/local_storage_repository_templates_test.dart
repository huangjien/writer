import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/models/template.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Character templates offline', () {
    test('save/get character template form via local storage', () async {
      final repo = LocalStorageRepository();
      final item = TemplateItem(novelId: 'n1', name: 'Hero', description: 'Brave');
      await repo.saveCharacterTemplateForm('n1', item);
      final got = await repo.getCharacterTemplateForm('n1');
      expect(got, isNotNull);
      expect(got!.name, 'Hero');
      expect(got.description, 'Brave');
    });

    test('list/get/update/delete no-op when supabase disabled', () async {
      final repo = LocalStorageRepository();
      final list = await repo.listCharacterTemplates();
      expect(list, isEmpty);
      final byId = await repo.getCharacterTemplateById('id');
      expect(byId, isNull);
      await repo.updateCharacterTemplate('id', title: 'X');
      await repo.deleteCharacterTemplate('id');
    });
  });

  group('Scene templates offline', () {
    test('save/get scene template form via local storage', () async {
      final repo = LocalStorageRepository();
      final item = TemplateItem(novelId: 'n1', name: 'Battle', description: 'Epic');
      await repo.saveSceneTemplateForm('n1', item);
      final got = await repo.getSceneTemplateForm('n1');
      expect(got, isNotNull);
      expect(got!.name, 'Battle');
      expect(got.description, 'Epic');
    });

    test('list/get/update/delete no-op when supabase disabled', () async {
      final repo = LocalStorageRepository();
      final list = await repo.listSceneTemplates();
      expect(list, isEmpty);
      final byId = await repo.getSceneTemplateById('id');
      expect(byId, isNull);
      await repo.updateSceneTemplate('id', title: 'Y');
      await repo.deleteSceneTemplate('id');
    });
  });
}
