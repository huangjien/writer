import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/features/summary/screens/scenes/scene_templates_list_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/scene_template_row.dart';
import 'package:writer/repositories/template_repository.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/shared/widgets/app_dialog.dart';

class MockTemplateRepository extends Mock implements TemplateRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockTemplateRepository mockRepo;
  late GoRouter router;

  setUp(() {
    mockRepo = MockTemplateRepository();
    router = GoRouter(
      initialLocation: '/novel/n1/scene-templates',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: '/novel/:novelId/scene-templates/new',
          builder: (context, state) =>
              const Scaffold(body: Text('New Template')),
        ),
        GoRoute(
          path: '/novel/:novelId/scene-templates/:templateId',
          builder: (context, state) =>
              const Scaffold(body: Text('Edit Template')),
        ),
        GoRoute(
          path: '/novel/:novelId/scene-templates',
          builder: (context, state) => SceneTemplatesListScreen(
            novelId: state.pathParameters['novelId']!,
          ),
        ),
      ],
    );
  });

  testWidgets('loads templates when signed in and supports local search', (
    tester,
  ) async {
    final items = <SceneTemplateRow>[
      SceneTemplateRow(
        id: 't1',
        idx: 1,
        title: 'Alpha',
        sceneSummaries: 'First line\nSecond line',
        sceneSynopses: null,
        languageCode: 'en',
        createdBy: 'u1',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      ),
      SceneTemplateRow(
        id: 't2',
        idx: 2,
        title: 'Beta',
        sceneSummaries: '**Bold** subtitle',
        sceneSynopses: null,
        languageCode: 'en',
        createdBy: 'u1',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      ),
    ];

    when(() => mockRepo.listSceneTemplates()).thenAnswer((_) async => items);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          templateRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Alpha'), findsOneWidget);
    expect(find.textContaining('Beta'), findsOneWidget);
    expect(find.textContaining('First line'), findsOneWidget);
    expect(find.textContaining('Bold subtitle'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'alp');
    await tester.pumpAndSettle();
    expect(find.textContaining('Alpha'), findsOneWidget);
    expect(find.textContaining('Beta'), findsNothing);
  });

  testWidgets('smart search shows snackbar when signed out', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(false),
          templateRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'anything');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.auto_awesome));
    await tester.pumpAndSettle();

    expect(find.text('Please sign in to use smart search'), findsOneWidget);
    verifyNever(
      () => mockRepo.searchSceneTemplates(any(), limit: any(named: 'limit')),
    );
  });

  testWidgets('smart search queries repository when signed in', (tester) async {
    when(() => mockRepo.listSceneTemplates()).thenAnswer((_) async => const []);
    when(() => mockRepo.searchSceneTemplates('hero', limit: 5)).thenAnswer(
      (_) async => [
        SceneTemplateRow(
          id: 's1',
          idx: 1,
          title: 'Hero',
          sceneSummaries: null,
          sceneSynopses: null,
          languageCode: 'en',
          createdBy: 'u1',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          templateRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'hero');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.auto_awesome));
    await tester.pumpAndSettle();

    verify(() => mockRepo.searchSceneTemplates('hero', limit: 5)).called(1);
    expect(find.text('Hero'), findsOneWidget);
  });

  testWidgets('delete confirms then reloads list', (tester) async {
    var items = <SceneTemplateRow>[
      SceneTemplateRow(
        id: 't1',
        idx: 1,
        title: 'Alpha',
        sceneSummaries: null,
        sceneSynopses: null,
        languageCode: 'en',
        createdBy: 'u1',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
      SceneTemplateRow(
        id: 't2',
        idx: 2,
        title: 'Beta',
        sceneSummaries: null,
        sceneSynopses: null,
        languageCode: 'en',
        createdBy: 'u1',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
    ];

    when(() => mockRepo.listSceneTemplates()).thenAnswer((_) async => items);
    when(() => mockRepo.deleteSceneTemplate(any())).thenAnswer((inv) async {
      final id = inv.positionalArguments.first as String;
      items = items.where((e) => e.id != id).toList();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          templateRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Alpha'), findsOneWidget);
    expect(find.textContaining('Beta'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();

    final ctx = tester.element(find.byType(AppDialog));
    final l10n = AppLocalizations.of(ctx)!;
    expect(find.text(l10n.deleteTemplateTitle), findsOneWidget);

    await tester.tap(find.text(l10n.delete));
    await tester.pumpAndSettle();

    verify(() => mockRepo.deleteSceneTemplate('t1')).called(1);
    expect(find.textContaining('Alpha'), findsNothing);
    expect(find.textContaining('Beta'), findsOneWidget);
  });
}
