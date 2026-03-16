import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/features/summary/screens/characters/characters_list_screen.dart';
import 'package:writer/models/character_template_row.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/shared/api_exception.dart';

class MockLocalStorageRepository extends Mock
    implements LocalStorageRepository {}

void main() {
  late MockLocalStorageRepository mockRepo;

  setUp(() {
    mockRepo = MockLocalStorageRepository();
  });

  Widget buildApp(Widget child) {
    return ProviderScope(
      overrides: [localStorageRepositoryProvider.overrideWithValue(mockRepo)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  testWidgets('renders list of characters', (tester) async {
    final characters = <CharacterTemplateRow>[
      CharacterTemplateRow(
        id: '1',
        idx: 0,
        title: 'Hero',
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      ),
      CharacterTemplateRow(
        id: '2',
        idx: 1,
        title: 'Villain',
        characterSummaries: 'Summary',
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      ),
    ];

    when(
      () => mockRepo.listCharacterTemplates(),
    ).thenAnswer((_) async => characters);

    await tester.pumpWidget(
      buildApp(const CharactersListScreen(novelId: 'n1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hero'), findsOneWidget);
    expect(find.textContaining('Villain'), findsOneWidget);
    expect(find.textContaining('Summary'), findsOneWidget);
  });

  testWidgets('shows error state on generic error', (tester) async {
    when(
      () => mockRepo.listCharacterTemplates(),
    ).thenThrow(Exception('Failed'));

    await tester.pumpWidget(
      buildApp(const CharactersListScreen(novelId: 'n1')),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Exception: Failed'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('ignores 401 error', (tester) async {
    when(
      () => mockRepo.listCharacterTemplates(),
    ).thenThrow(ApiException(401, 'Auth error'));

    await tester.pumpWidget(
      buildApp(const CharactersListScreen(novelId: 'n1')),
    );
    await tester.pumpAndSettle();

    // Should show empty list (no items) and no error
    expect(find.byType(ListView), findsOneWidget);
    expect(find.textContaining('Auth error'), findsNothing);
  });

  testWidgets('filters list by search query', (tester) async {
    final characters = <CharacterTemplateRow>[
      CharacterTemplateRow(
        id: '1',
        idx: 0,
        title: 'Alice',
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      ),
      CharacterTemplateRow(
        id: '2',
        idx: 1,
        title: 'Bob',
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      ),
    ];
    when(
      () => mockRepo.listCharacterTemplates(),
    ).thenAnswer((_) async => characters);

    await tester.pumpWidget(
      buildApp(const CharactersListScreen(novelId: 'n1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);

    // Enter search query
    await tester.enterText(find.byType(TextField), 'ali');
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsNothing);

    // Clear search
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
  });
}
