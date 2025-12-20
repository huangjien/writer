import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:writer/features/summary/scene_templates_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/main.dart';
import 'package:writer/models/template.dart';
import 'package:writer/models/scene_template_row.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalStorageRepository extends Mock
    implements LocalStorageRepository {}

class FakeTemplateItem extends Fake implements TemplateItem {}

void main() {
  late MockLocalStorageRepository mockRepo;

  setUp(() {
    mockRepo = MockLocalStorageRepository();
    registerFallbackValue(FakeTemplateItem());
  });

  Widget createWidget() {
    return ProviderScope(
      overrides: [localStorageRepositoryProvider.overrideWithValue(mockRepo)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SceneTemplatesScreen(novelId: 'novel-1'),
      ),
    );
  }

  testWidgets('SceneTemplatesScreen shows tabs and defaults to Preview', (
    tester,
  ) async {
    when(
      () => mockRepo.getSceneTemplateForm(any()),
    ).thenAnswer((_) async => null);

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    expect(find.text('Preview'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);

    // Check Markdown widget is present in Preview tab (default)
    expect(find.byType(Markdown), findsOneWidget);

    // Check Edit text field hint is NOT visible yet
    expect(find.text('Enter description in Markdown...'), findsNothing);
  });

  testWidgets('SceneTemplatesScreen switches to Edit tab', (tester) async {
    when(
      () => mockRepo.getSceneTemplateForm(any()),
    ).thenAnswer((_) async => null);

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    // Check TextFormField with specific hint is present
    expect(find.text('Enter description in Markdown...'), findsOneWidget);
  });

  testWidgets('SceneTemplatesScreen starts with empty form when creating new', (
    tester,
  ) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    final nameField = tester.widget<TextFormField>(
      find.byType(TextFormField).first,
    );
    expect(nameField.controller?.text ?? '', '');
    expect(find.text('Header'), findsNothing);
    expect(find.text('Content'), findsNothing);
  });

  testWidgets('SceneTemplatesScreen loads existing template by id', (
    tester,
  ) async {
    final row = SceneTemplateRow(
      id: 't-1',
      idx: 1,
      title: 'My Template',
      sceneSummaries: '# Header\nContent',
      sceneSynopses: null,
      languageCode: 'en',
      createdBy: 'u-1',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 2),
    );
    when(
      () => mockRepo.getSceneTemplateById('t-1'),
    ).thenAnswer((_) async => row);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localStorageRepositoryProvider.overrideWithValue(mockRepo)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SceneTemplatesScreen(
            novelId: 'novel-1',
            templateId: 't-1',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextFormField, 'My Template'), findsOneWidget);
    expect(find.text('Header'), findsOneWidget);
    expect(find.text('Content'), findsOneWidget);
  });

  testWidgets('SceneTemplatesScreen saves data', (tester) async {
    when(
      () => mockRepo.getSceneTemplateForm(any()),
    ).thenAnswer((_) async => null);
    when(
      () => mockRepo.saveSceneTemplateForm(
        any(),
        any(),
        languageCode: any(named: 'languageCode'),
      ),
    ).thenAnswer((_) async => 't-1');

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Template Name'),
      'New Name',
    );

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    // Find by hint text
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter description in Markdown...'),
      'New Description',
    );

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    verify(
      () => mockRepo.saveSceneTemplateForm(
        'novel-1',
        any(
          that: isA<TemplateItem>()
              .having((t) => t.name, 'name', 'New Name')
              .having((t) => t.description, 'description', 'New Description'),
        ),
        languageCode: any(named: 'languageCode'),
      ),
    ).called(1);
  });
}
