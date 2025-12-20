import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  bool throwOnDelete = false;
  @override
  Future<List<SceneTemplateRow>> listSceneTemplates({int limit = 200}) async {
    return items;
  }

  @override
  Future<void> deleteSceneTemplate(String id) async {
    if (throwOnDelete) {
      throw Exception('Delete failed');
    }
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

  testWidgets('Search filters list when supabase disabled', (tester) async {
    final repo = FakeLocalRepo();
    repo.items = [
      repo.items.first,
      SceneTemplateRow(
        id: 't-2',
        idx: 2,
        title: 'Quiet Scene',
        sceneSummaries: 'Low tension',
        sceneSynopses: null,
        languageCode: 'en',
        createdBy: 'u-1',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localStorageRepositoryProvider.overrideWith((_) => repo)],
        child: const MaterialApp(
          home: SceneTemplatesListScreen(novelId: 'n-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Battle Scene'), findsOneWidget);
    expect(find.text('Quiet Scene'), findsOneWidget);

    final search = find.byType(TextField);
    expect(search, findsOneWidget);
    await tester.enterText(search, 'quiet');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Battle Scene'), findsNothing);
    expect(find.text('Quiet Scene'), findsOneWidget);

    final tf = tester.widget<TextField>(search);
    expect(tf.decoration?.suffixText, '1');
  });

  testWidgets('Delete failure shows SnackBar', (tester) async {
    final repo = FakeLocalRepo()..throwOnDelete = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [localStorageRepositoryProvider.overrideWith((_) => repo)],
        child: const MaterialApp(
          home: SceneTemplatesListScreen(novelId: 'n-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Delete failed'), findsOneWidget);
  });

  testWidgets('Edit and add buttons navigate', (tester) async {
    final repo = FakeLocalRepo();
    final router = GoRouter(
      initialLocation: '/novel/n-1/scene-templates',
      routes: [
        GoRoute(
          path: '/novel/:id/scene-templates',
          builder: (context, state) =>
              SceneTemplatesListScreen(novelId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/novel/:id/scene-templates/new',
          builder: (context, state) =>
              const Scaffold(body: Text('New Scene Template')),
        ),
        GoRoute(
          path: '/novel/:id/scene-templates/:tid',
          builder: (context, state) => Scaffold(
            body: Text('Edit Scene Template ${state.pathParameters['tid']}'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localStorageRepositoryProvider.overrideWith((_) => repo)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    expect(find.text('Edit Scene Template t-1'), findsOneWidget);

    router.go('/novel/n-1/scene-templates');
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('New Scene Template'), findsOneWidget);
  });
}
