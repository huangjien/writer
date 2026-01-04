import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import 'package:writer/features/summary/scene_templates_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/template.dart';
import 'package:writer/models/scene_template_row.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/template_repository.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/services/storage_service.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockStorageService implements StorageService {
  String? _sessionId;

  @override
  String? getString(String key) =>
      key == 'backend_session_id' ? _sessionId : null;

  @override
  Future<void> setString(String key, String? value) async {
    if (key == 'backend_session_id') {
      _sessionId = value;
    }
  }

  @override
  Future<void> remove(String key) async {
    if (key == 'backend_session_id') {
      _sessionId = null;
    }
  }

  @override
  Set<String> getKeys() => {'backend_session_id'};
}

class MockLocalStorageRepository extends Mock
    implements LocalStorageRepository {}

class MockTemplateRepository extends Mock implements TemplateRepository {}

class FakeTemplateItem extends Fake implements TemplateItem {}

void main() {
  late MockLocalStorageRepository mockRepo;
  late MockTemplateRepository mockTemplateRepo;

  setUp(() {
    mockRepo = MockLocalStorageRepository();
    mockTemplateRepo = MockTemplateRepository();
    registerFallbackValue(FakeTemplateItem());
  });

  Widget createWidget() {
    return ProviderScope(
      overrides: [
        localStorageRepositoryProvider.overrideWithValue(mockRepo),
        templateRepositoryProvider.overrideWithValue(mockTemplateRepo),
      ],
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
        overrides: [
          localStorageRepositoryProvider.overrideWithValue(mockRepo),
          storageServiceProvider.overrideWithValue(MockStorageService()),
        ],
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
      () => mockTemplateRepo.upsertSceneTemplate(
        id: any(named: 'id'),
        title: any(named: 'title'),
        summaries: any(named: 'summaries'),
        synopses: any(named: 'synopses'),
        languageCode: any(named: 'languageCode'),
      ),
    ).thenAnswer((_) async => 't-1');
    when(
      () => mockTemplateRepo.getSceneTemplateById(any()),
    ).thenAnswer((_) async => null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageRepositoryProvider.overrideWithValue(mockRepo),
          templateRepositoryProvider.overrideWithValue(mockTemplateRepo),
          sessionProvider.overrideWith(
            (_) => SessionNotifier(MockStorageService())..state = 's-1',
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SceneTemplatesScreen(novelId: 'novel-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Template Name'),
      'New Name',
    );

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter description in Markdown...'),
      'New Description',
    );

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    verify(
      () => mockTemplateRepo.upsertSceneTemplate(
        id: any(named: 'id'),
        title: 'New Name',
        summaries: 'New Description',
        synopses: any(named: 'synopses'),
        languageCode: any(named: 'languageCode'),
      ),
    ).called(1);
  });
}
