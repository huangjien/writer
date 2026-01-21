import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:writer/features/summary/scene_templates_list_screen.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/repositories/template_repository.dart';
import 'package:writer/models/scene_template_row.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/l10n/app_localizations.dart';

class FakeTemplateRepo extends TemplateRepository {
  FakeTemplateRepo() : super(RemoteRepository('http://localhost:5600/'));

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
    final repo = FakeTemplateRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          templateRepositoryProvider.overrideWith((ref) => repo),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: SceneTemplatesListScreen(novelId: 'n-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Scene Templates'), findsOneWidget);
    expect(
      find.textContaining('Battle Scene', findRichText: true),
      findsOneWidget,
    );
    expect(find.byTooltip('New'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();
    expect(find.text('Delete Template'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(repo.deletedId, 't-1');
    expect(
      find.textContaining('Battle Scene', findRichText: true),
      findsNothing,
    );
  });

  testWidgets('Search filters list', (tester) async {
    final repo = FakeTemplateRepo();
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
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          templateRepositoryProvider.overrideWith((ref) => repo),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: SceneTemplatesListScreen(novelId: 'n-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Battle Scene', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('Quiet Scene', findRichText: true),
      findsOneWidget,
    );

    final search = find.byType(TextField);
    expect(search, findsOneWidget);
    await tester.enterText(search, 'quiet');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Battle Scene', findRichText: true),
      findsNothing,
    );
    expect(
      find.textContaining('Quiet Scene', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('Delete failure shows SnackBar', (tester) async {
    final repo = FakeTemplateRepo()..throwOnDelete = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          templateRepositoryProvider.overrideWith((ref) => repo),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
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
    final repo = FakeTemplateRepo();
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
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          templateRepositoryProvider.overrideWith((ref) => repo),
        ],
        child: MaterialApp.router(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Wait for data to load and items to appear
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Battle Scene', findRichText: true),
      findsOneWidget,
    );

    // Test edit button
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    expect(find.text('Edit Scene Template t-1'), findsOneWidget);

    // Go back to list
    router.go('/novel/n-1/scene-templates');
    await tester.pumpAndSettle();

    // Test add button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('New Scene Template'), findsOneWidget);
  });
}
