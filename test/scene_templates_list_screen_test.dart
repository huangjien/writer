import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/summary/scene_templates_list_screen.dart';
import 'package:writer/main.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/models/scene_template_row.dart';

class FakeLocalRepo extends LocalStorageRepository {
  List<SceneTemplateRow> items = [
    SceneTemplateRow(
      id: 't-1',
      idx: 1,
      title: 'Battle Scene',
      sceneSummaries: 'High tension',
      sceneSynopses: null,
      languageCode: 'en',
      createdBy: 'u-1',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
  ];
  String? deletedId;
  @override
  Future<List<SceneTemplateRow>> listSceneTemplates({int limit = 200}) async {
    return items;
  }

  @override
  Future<void> deleteSceneTemplate(String id) async {
    deletedId = id;
    items = items.where((e) => e.id != id).toList();
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SceneTemplatesListScreen renders and deletes item', (
    tester,
  ) async {
    final repo = FakeLocalRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [localStorageRepositoryProvider.overrideWith((_) => repo)],
        child: const MaterialApp(
          home: SceneTemplatesListScreen(novelId: 'n-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Scene Templates'), findsOneWidget);
    expect(find.text('Battle Scene'), findsOneWidget);
    expect(find.byTooltip('New'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();
    expect(find.text('Delete Template'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(repo.deletedId, 't-1');
    expect(find.text('Battle Scene'), findsNothing);
  });
}
