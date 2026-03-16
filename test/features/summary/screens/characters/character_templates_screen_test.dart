import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/models/character_template_row.dart';
import 'package:writer/features/summary/screens/characters/character_templates_screen.dart';
import 'package:writer/models/template.dart';
import 'package:writer/repositories/template_repository.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/shared/api_exception.dart';
import 'package:writer/features/ai_chat/state/ai_chat_providers.dart';

class MockTemplateRepository extends Mock implements TemplateRepository {}

class MockLocalStorageRepository extends Mock
    implements LocalStorageRepository {}

class MockAiContextNotifier extends Mock implements AiContextNotifier {}

class FakeTemplateItem extends Fake implements TemplateItem {}

void main() {
  late MockTemplateRepository mockTemplateRepo;
  late MockLocalStorageRepository mockLocalRepo;
  late MockAiContextNotifier mockAiContext;

  setUpAll(() {
    registerFallbackValue(FakeTemplateItem());
  });

  setUp(() {
    mockTemplateRepo = MockTemplateRepository();
    mockLocalRepo = MockLocalStorageRepository();
    mockAiContext = MockAiContextNotifier();
  });

  Widget buildApp(Widget child, {bool isSignedIn = true}) {
    return ProviderScope(
      overrides: [
        templateRepositoryProvider.overrideWithValue(mockTemplateRepo),
        localStorageRepositoryProvider.overrideWithValue(mockLocalRepo),
        isSignedInProvider.overrideWithValue(isSignedIn),
        aiContextProvider.overrideWith((ref) => mockAiContext),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  testWidgets('renders form fields', (tester) async {
    await tester.pumpWidget(
      buildApp(const CharacterTemplatesScreen(novelId: 'n1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Character Templates'), findsOneWidget);
    expect(find.byType(TextFormField), findsWidgets);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('loads local template when signed out', (tester) async {
    final template = CharacterTemplateRow(
      id: 't1',
      idx: 0,
      title: 'Local Hero',
      characterSummaries: 'Local Desc',
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );
    when(
      () => mockLocalRepo.getCharacterTemplateById('t1'),
    ).thenAnswer((_) async => template);

    await tester.pumpWidget(
      buildApp(
        const CharacterTemplatesScreen(novelId: 'n1', templateId: 't1'),
        isSignedIn: false,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Local Hero'), findsOneWidget);
    expect(find.text('Local Desc'), findsOneWidget);
  });

  testWidgets('loads remote template when signed in', (tester) async {
    final template = CharacterTemplateRow(
      id: 't1',
      idx: 0,
      title: 'Remote Hero',
      characterSummaries: 'Remote Desc',
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );
    when(
      () => mockTemplateRepo.getCharacterTemplateById('t1'),
    ).thenAnswer((_) async => template);

    await tester.pumpWidget(
      buildApp(
        const CharacterTemplatesScreen(novelId: 'n1', templateId: 't1'),
        isSignedIn: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Remote Hero'), findsOneWidget);
    expect(find.text('Remote Desc'), findsOneWidget);
  });

  testWidgets('saves local template when signed out', (tester) async {
    when(
      () => mockLocalRepo.saveCharacterTemplateForm('n1', any()),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(
      buildApp(
        const CharacterTemplatesScreen(novelId: 'n1'),
        isSignedIn: false,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'New Hero');

    // Switch to Edit tab
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).last, 'New Desc');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    verify(
      () => mockLocalRepo.saveCharacterTemplateForm('n1', any()),
    ).called(1);
    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('saves remote template when signed in', (tester) async {
    when(
      () => mockTemplateRepo.upsertCharacterTemplate(
        title: any(named: 'title'),
        summaries: any(named: 'summaries'),
        languageCode: any(named: 'languageCode'),
      ),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(
      buildApp(const CharacterTemplatesScreen(novelId: 'n1'), isSignedIn: true),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'New Remote Hero');

    // Switch to Edit tab
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).last, 'New Remote Desc');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    verify(
      () => mockTemplateRepo.upsertCharacterTemplate(
        title: 'New Remote Hero',
        summaries: 'New Remote Desc',
        languageCode: any(named: 'languageCode'),
      ),
    ).called(1);
    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('handles 401 error on save', (tester) async {
    when(
      () => mockTemplateRepo.upsertCharacterTemplate(
        title: any(named: 'title'),
        summaries: any(named: 'summaries'),
        languageCode: any(named: 'languageCode'),
      ),
    ).thenThrow(ApiException(401, 'Auth error'));

    await tester.pumpWidget(
      buildApp(const CharacterTemplatesScreen(novelId: 'n1'), isSignedIn: true),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Hero');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify no error snackbar (401 is ignored/handled silently or redirects)
    // The code says: if (401) return;
    expect(find.text('Auth error'), findsNothing);
    expect(find.text('Saved'), findsNothing);
  });

  testWidgets('handles generic error on save', (tester) async {
    when(
      () => mockTemplateRepo.upsertCharacterTemplate(
        title: any(named: 'title'),
        summaries: any(named: 'summaries'),
        languageCode: any(named: 'languageCode'),
      ),
    ).thenThrow(Exception('Generic error'));

    await tester.pumpWidget(
      buildApp(const CharacterTemplatesScreen(novelId: 'n1'), isSignedIn: true),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Hero');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Generic error'), findsOneWidget);
  });
}
