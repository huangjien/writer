import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/models/template.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('save/get CharacterTemplateForm persists locally', () async {
    final repo = LocalStorageRepository();
    final item = TemplateItem(
      novelId: 'n1',
      name: 'Hero',
      description: 'Brave',
    );
    await repo.saveCharacterTemplateForm('n1', item);
    final got = await repo.getCharacterTemplateForm('n1');
    expect(got?.name, 'Hero');
    expect(got?.description, 'Brave');
  });

  test('save/get SceneTemplateForm persists locally', () async {
    final repo = LocalStorageRepository();
    final item = TemplateItem(
      novelId: 'n1',
      name: 'Forest',
      description: 'Dark',
    );
    await repo.saveSceneTemplateForm('n1', item);
    final got = await repo.getSceneTemplateForm('n1');
    expect(got?.name, 'Forest');
    expect(got?.description, 'Dark');
  });

  test('listCharacterTemplates returns empty when supabase disabled', () async {
    final repo = LocalStorageRepository();
    final rows = await repo.listCharacterTemplates();
    expect(rows, isEmpty);
  });

  test('listSceneTemplates returns empty when supabase disabled', () async {
    final repo = LocalStorageRepository();
    final rows = await repo.listSceneTemplates();
    expect(rows, isEmpty);
  });

  test(
    'getCharacterTemplateById returns null when supabase disabled',
    () async {
      final repo = LocalStorageRepository();
      final row = await repo.getCharacterTemplateById('x');
      expect(row, isNull);
    },
  );

  test('getSceneTemplateById returns null when supabase disabled', () async {
    final repo = LocalStorageRepository();
    final row = await repo.getSceneTemplateById('x');
    expect(row, isNull);
  });

  test('updateCharacterTemplate no-op when supabase disabled', () async {
    final repo = LocalStorageRepository();
    await repo.updateCharacterTemplate('id', title: 'T');
  });

  test('updateSceneTemplate no-op when supabase disabled', () async {
    final repo = LocalStorageRepository();
    await repo.updateSceneTemplate('id', title: 'T');
  });

  test('save/get summary text', () async {
    final repo = LocalStorageRepository();
    await repo.saveSummaryText('n1', 'Summary');
    final txt = await repo.getSummaryText('n1');
    expect(txt, 'Summary');
  });
}
