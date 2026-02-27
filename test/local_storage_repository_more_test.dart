import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/models/template.dart';
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
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('save/get CharacterTemplateForm persists locally', () async {
    final repo = LocalStorageRepository(MockStorageService());
    const item = TemplateItem(
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
    final repo = LocalStorageRepository(MockStorageService());
    const item = TemplateItem(
      novelId: 'n1',
      name: 'Forest',
      description: 'Dark',
    );
    await repo.saveSceneTemplateForm('n1', item);
    final got = await repo.getSceneTemplateForm('n1');
    expect(got?.name, 'Forest');
    expect(got?.description, 'Dark');
  });

  test(
    'listCharacterTemplates returns empty when cloud sync disabled',
    () async {
      final repo = LocalStorageRepository(MockStorageService());
      final rows = await repo.listCharacterTemplates();
      expect(rows, isEmpty);
    },
  );

  test('listSceneTemplates returns empty when cloud sync disabled', () async {
    final repo = LocalStorageRepository(MockStorageService());
    final rows = await repo.listSceneTemplates();
    expect(rows, isEmpty);
  });

  test(
    'getCharacterTemplateById returns null when cloud sync disabled',
    () async {
      final repo = LocalStorageRepository(MockStorageService());
      final row = await repo.getCharacterTemplateById('x');
      expect(row, isNull);
    },
  );

  test('getSceneTemplateById returns null when cloud sync disabled', () async {
    final repo = LocalStorageRepository(MockStorageService());
    final row = await repo.getSceneTemplateById('x');
    expect(row, isNull);
  });

  test('save/get summary text', () async {
    final repo = LocalStorageRepository(MockStorageService());
    await repo.saveSummaryText('n1', 'Summary');
    final txt = await repo.getSummaryText('n1');
    expect(txt, 'Summary');
  });
}
