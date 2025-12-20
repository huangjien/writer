import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/summary/character_templates_list_screen.dart';
import 'package:writer/main.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/models/character_template_row.dart';

class FakeLocalRepo extends LocalStorageRepository {
  List<CharacterTemplateRow> items = [
    CharacterTemplateRow(
      id: 't-1',
      idx: 1,
      title: 'Hero Archetype',
      characterSummaries: 'Brave protagonist',
      characterSynopses: null,
      languageCode: 'en',
      createdBy: 'u-1',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
  ];
  String? deletedId;
  @override
  Future<List<CharacterTemplateRow>> listCharacterTemplates() async {
    return items;
  }

  @override
  Future<void> deleteCharacterTemplate(String id) async {
    deletedId = id;
    items = items.where((e) => e.id != id).toList();
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('CharacterTemplatesListScreen renders and deletes item', (
    tester,
  ) async {
    final repo = FakeLocalRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [localStorageRepositoryProvider.overrideWith((_) => repo)],
        child: const MaterialApp(
          home: CharacterTemplatesListScreen(novelId: 'n-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Character Templates'), findsOneWidget);
    expect(find.textContaining('Hero Archetype'), findsOneWidget);
    expect(find.byTooltip('New'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();
    expect(find.text('Delete Template'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(repo.deletedId, 't-1');
    expect(find.textContaining('Hero Archetype'), findsNothing);
  });

  testWidgets('Enter on focused row navigates to edit', (tester) async {
    final repo = FakeLocalRepo();
    final router = GoRouter(
      initialLocation: '/novel/n-1/character-templates',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: Text('Home Screen')),
        ),
        GoRoute(
          path: '/novel/:id/character-templates',
          builder: (context, state) => CharacterTemplatesListScreen(
            novelId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/novel/:id/character-templates/new',
          builder: (context, state) =>
              const Scaffold(body: Text('New Character Template')),
        ),
        GoRoute(
          path: '/novel/:id/character-templates/:tid',
          builder: (context, state) => Scaffold(
            body: Text(
              'Edit Character Template ${state.pathParameters['tid']}',
            ),
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

    final focusFinder = find.byWidgetPredicate(
      (w) => w is Focus && w.child is ListTile,
    );
    expect(focusFinder, findsOneWidget);

    final listTileFinder = find.descendant(
      of: focusFinder,
      matching: find.byType(ListTile),
    );
    final tileElement = tester.element(listTileFinder);
    final focusNode = Focus.of(tileElement);
    focusNode.requestFocus();
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(find.text('Edit Character Template t-1'), findsOneWidget);
  });

  testWidgets('Double tap on row navigates to edit', (tester) async {
    final repo = FakeLocalRepo();
    final router = GoRouter(
      initialLocation: '/novel/n-1/character-templates',
      routes: [
        GoRoute(
          path: '/novel/:id/character-templates',
          builder: (context, state) => CharacterTemplatesListScreen(
            novelId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/novel/:id/character-templates/:tid',
          builder: (context, state) => Scaffold(
            body: Text(
              'Edit Character Template ${state.pathParameters['tid']}',
            ),
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

    final row = find.textContaining('Hero Archetype');
    expect(row, findsOneWidget);
    await tester.tap(row);
    await tester.pump(const Duration(milliseconds: 10));
    await tester.tap(row);
    await tester.pumpAndSettle();

    expect(find.text('Edit Character Template t-1'), findsOneWidget);
  });

  testWidgets('Add button navigates to new template screen', (tester) async {
    final repo = FakeLocalRepo();
    final router = GoRouter(
      initialLocation: '/novel/n-1/character-templates',
      routes: [
        GoRoute(
          path: '/novel/:id/character-templates',
          builder: (context, state) => CharacterTemplatesListScreen(
            novelId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/novel/:id/character-templates/new',
          builder: (context, state) =>
              const Scaffold(body: Text('New Character Template')),
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

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('New Character Template'), findsOneWidget);
  });
}
