import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/features/summary/scenes_screen.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';
import 'package:writer/state/mock_providers.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/scene.dart';

import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/models/scene_template_row.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/features/summary/scene_templates_screen.dart';
import 'package:writer/repositories/template_repository.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/template.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/services/storage_service.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalStorageRepository extends Mock
    implements LocalStorageRepository {}

class _MockStorageService implements StorageService {
  String? _data;

  @override
  String? getString(String key) => _data;

  @override
  Future<void> setString(String key, String? value) async {
    _data = value;
  }

  @override
  Future<void> remove(String key) async {
    _data = null;
  }

  @override
  Set<String> getKeys() => const {};
}

class CapturingLocalRepo extends MockLocalStorageRepository {
  Scene? lastScene;

  @override
  Future<int> nextSceneIdx(String novelId) async {
    return 1;
  }

  @override
  Future<Scene?> getSceneForm(String novelId, {int? idx}) async => null;

  @override
  Future<void> saveSceneForm(String novelId, Scene scene, {int? idx}) async {
    lastScene = scene;
  }
}

class TemplatesLocalRepo extends CapturingLocalRepo {
  @override
  Future<List<SceneTemplateRow>> listSceneTemplates({int? limit}) async {
    return [
      SceneTemplateRow(
        id: 't-1',
        idx: 1,
        title: 'Battle Scene',
        sceneSummaries: 'Template body',
        sceneSynopses: null,
        languageCode: 'en',
        createdBy: 'u-1',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
    ];
  }

  @override
  Future<Scene?> getSceneForm(String novelId, {int? idx}) async {
    return null;
  }
}

class FakeRemoteRepo extends RemoteRepository {
  FakeRemoteRepo() : super('http://test/');

  @override
  Future<String?> convertScene({
    required String name,
    required String templateContent,
    required String language,
  }) async {
    return 'Converted Summary';
  }
}

class FakeAiChatService extends AiChatService {
  FakeAiChatService(this.vectors) : super(RemoteRepository('http://test/'));
  final Map<String, List<double>?> vectors;

  @override
  Future<List<double>?> embed(String input, {String? model}) async {
    return vectors[input];
  }
}

class FakeTemplateRepo extends TemplateRepository {
  FakeTemplateRepo() : super(RemoteRepository('http://test/'));

  final Map<String, SceneTemplateRow> _rows = {};

  @override
  Future<String?> upsertSceneTemplate({
    String? id,
    String? title,
    String? summaries,
    String? synopses,
    String? languageCode,
  }) async {
    final nextId = id ?? 't-${_rows.length + 1}';
    _rows[nextId] = SceneTemplateRow(
      id: nextId,
      idx: _rows.length + 1,
      title: title,
      sceneSummaries: summaries,
      sceneSynopses: synopses,
      languageCode: languageCode ?? 'en',
      createdBy: 'u-1',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );
    return nextId;
  }

  @override
  Future<SceneTemplateRow?> getSceneTemplateById(String id) async {
    return _rows[id];
  }

  @override
  Future<List<SceneTemplateRow>> listSceneTemplates({int? limit}) async {
    return _rows.values.take(limit ?? 200).toList();
  }

  @override
  Future<List<SceneTemplateRow>> searchSceneTemplates(
    String query, {
    int limit = 10,
    int offset = 0,
    String? languageCode,
  }) async {
    final q = query.toLowerCase();
    final filtered = _rows.values
        .where((row) {
          if (languageCode != null && row.languageCode != languageCode) {
            return false;
          }
          return (row.title ?? '').toLowerCase().contains(q);
        })
        .skip(offset);
    return filtered.take(limit).toList();
  }
}

class EndToEndLocalRepo extends LocalStorageRepository {
  final List<SceneTemplateRow> _templates = [];
  Scene? lastScene;

  EndToEndLocalRepo() : super(_MockStorageService());

  @override
  Future<TemplateItem?> getSceneTemplateForm(String novelId) async {
    return null;
  }

  @override
  Future<String?> saveSceneTemplateForm(
    String novelId,
    TemplateItem item, {
    String languageCode = 'en',
  }) async {
    final id = 't-${_templates.length + 1}';
    _templates.add(
      SceneTemplateRow(
        id: id,
        idx: _templates.length + 1,
        title: item.name,
        sceneSummaries: item.description,
        sceneSynopses: null,
        languageCode: languageCode,
        createdBy: 'u-1',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
    );
    return id;
  }

  @override
  Future<List<SceneTemplateRow>> listSceneTemplates({int? limit}) async {
    return List<SceneTemplateRow>.from(_templates);
  }

  @override
  Future<SceneTemplateRow?> getSceneTemplateById(String id) async {
    for (final row in _templates) {
      if (row.id == id) return row;
    }
    return null;
  }

  @override
  Future<Scene?> getSceneForm(String novelId, {int? idx}) async {
    return null;
  }

  @override
  Future<int> nextSceneIdx(String novelId) async {
    return 1;
  }

  @override
  Future<void> saveSceneForm(String novelId, Scene scene, {int? idx}) async {
    lastScene = scene;
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ScenesScreen validates and saves', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final repo = CapturingLocalRepo();
    final ai = FakeAiChatService({});
    final novel = const Novel(
      id: 'n-1',
      title: 'Test Novel',
      author: 'Author',
      description: '',
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWith((_) => repo),
          aiChatServiceProvider.overrideWithValue(ai),
          mockNovelsProvider.overrideWith((ref) async => [novel]),
          novelProvider.overrideWith((ref, id) async => novel),
        ],
        child: const MaterialApp(home: ScenesScreen(novelId: 'n-1')),
      ),
    );

    await tester.pumpAndSettle();

    final locField = find.widgetWithText(TextFormField, 'Location');
    await tester.enterText(locField, 'X');
    await tester.pump();

    final btn = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Save'),
    );
    expect(btn.onPressed, isNotNull, reason: 'Save button should be enabled');

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsOneWidget);

    // Fill fields and save.
    final titleField = find.widgetWithText(TextFormField, 'Title');
    final locField2 = find.widgetWithText(TextFormField, 'Location');
    final sumField = find.widgetWithText(TextFormField, 'Description');
    await tester.enterText(titleField, 'Opening Scene');
    await tester.enterText(locField2, 'Forest');
    await tester.enterText(sumField, 'Introduces the journey.');
    await tester.pump();

    final btn2 = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Save'),
    );
    expect(
      btn2.onPressed,
      isNotNull,
      reason: 'Save button should be enabled after filling fields',
    );

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repo.lastScene?.title, 'Opening Scene');
    expect(repo.lastScene?.location, 'Forest');
    expect(repo.lastScene?.summary, 'Introduces the journey.');
    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('ScenesScreen converts scene using template', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = TemplatesLocalRepo();
    final remote = FakeRemoteRepo();
    final ai = FakeAiChatService({'Battle': null});
    final novel = const Novel(
      id: 'n-1',
      title: 'Test Novel',
      author: 'Author',
      description: '',
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWithValue(repo),
          remoteRepositoryProvider.overrideWithValue(remote),
          aiChatServiceProvider.overrideWithValue(ai),
          mockNovelsProvider.overrideWith((ref) async => [novel]),
          novelProvider.overrideWith((ref, id) async => novel),
        ],
        child: const MaterialApp(home: ScenesScreen(novelId: 'n-1')),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'X');
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Location'),
      'Forest',
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Template'),
      'Battle',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Battle Scene').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('AI Convert'));
    await tester.pumpAndSettle();

    expect(find.text('Converted Summary'), findsOneWidget);
  });

  testWidgets('Scene templates to scene conversion flow works', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = EndToEndLocalRepo();
    final remote = FakeRemoteRepo();
    final ai = FakeAiChatService({'Battle': null});
    final templates = FakeTemplateRepo();
    final novel = const Novel(
      id: 'n-1',
      title: 'Test Novel',
      author: 'Author',
      description: '',
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWithValue(repo),
          remoteRepositoryProvider.overrideWithValue(remote),
          aiChatServiceProvider.overrideWithValue(ai),
          templateRepositoryProvider.overrideWithValue(templates),
          isSignedInProvider.overrideWithValue(true),
          mockNovelsProvider.overrideWith((ref) async => [novel]),
          novelProvider.overrideWith((ref, id) async => novel),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SceneTemplatesScreen(novelId: 'n-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Template Name'),
      'Battle Scene',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter description in Markdown...'),
      'Template body',
    );
    await tester.pumpAndSettle();

    final templateSaveButtonFinder = find.widgetWithText(
      ElevatedButton,
      'Save',
    );
    final templateSaveButton = tester.widget<ElevatedButton>(
      templateSaveButtonFinder,
    );
    expect(templateSaveButton.onPressed, isNotNull);
    await tester.ensureVisible(templateSaveButtonFinder);
    await tester.tap(templateSaveButtonFinder);
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsOneWidget);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWithValue(repo),
          remoteRepositoryProvider.overrideWithValue(remote),
          aiChatServiceProvider.overrideWithValue(ai),
          templateRepositoryProvider.overrideWithValue(templates),
          isSignedInProvider.overrideWithValue(true),
          mockNovelsProvider.overrideWith((ref) async => [novel]),
          novelProvider.overrideWith((ref, id) async => novel),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ScenesScreen(novelId: 'n-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'X');
    await tester.pump();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Location'),
      'Forest',
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Template'),
      'Battle',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Battle Scene').last);
    await tester.pumpAndSettle();

    final convertLabelFinder = find.text('AI Convert');
    expect(convertLabelFinder, findsOneWidget);
    final convertButtonFinder = find.ancestor(
      of: convertLabelFinder,
      matching: find.byWidgetPredicate((w) => w is ElevatedButton),
    );
    expect(convertButtonFinder, findsOneWidget);
    await tester.ensureVisible(convertButtonFinder);
    await tester.tap(convertButtonFinder);
    await tester.pumpAndSettle();
    expect(find.text('Converted Summary'), findsOneWidget);

    final saveButtonFinder = find.widgetWithText(ElevatedButton, 'Save');
    final saveButton = tester.widget<ElevatedButton>(saveButtonFinder);
    expect(saveButton.onPressed, isNotNull);
    await tester.ensureVisible(saveButtonFinder);
    saveButton.onPressed!.call();
    await tester.pumpAndSettle();

    expect(repo.lastScene?.title, 'X');
    expect(repo.lastScene?.location, 'Forest');
    expect(repo.lastScene?.summary, 'Converted Summary');
  });

  testWidgets('ScenesScreen template search uses vector results', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final remote = FakeRemoteRepo();
    final ai = FakeAiChatService({
      'Query': [1.0],
    });
    final novel = const Novel(
      id: 'n-1',
      title: 'Test Novel',
      author: 'Author',
      description: '',
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    );

    final repo = _VectorSearchRepo();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWithValue(repo),
          remoteRepositoryProvider.overrideWithValue(remote),
          aiChatServiceProvider.overrideWithValue(ai),
          mockNovelsProvider.overrideWith((ref) async => [novel]),
          novelProvider.overrideWith((ref, id) async => novel),
        ],
        child: const MaterialApp(home: ScenesScreen(novelId: 'n-1')),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'X');
    await tester.enterText(find.widgetWithText(TextFormField, 'Location'), 'L');
    await tester.pumpAndSettle();

    final templateField = find.widgetWithText(TextFormField, 'Template');
    await tester.enterText(templateField, 'Query');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    await tester.enterText(templateField, 'Query ');
    await tester.pumpAndSettle();

    expect(find.text('Vector Pick'), findsOneWidget);
    await tester.tap(find.text('Vector Pick').last);
    await tester.pumpAndSettle();

    final convertFinder = find.text('AI Convert');
    final convertButtonFinder = find.ancestor(
      of: convertFinder,
      matching: find.byWidgetPredicate((w) => w is ElevatedButton),
    );
    final convertButton = tester.widget<ElevatedButton>(convertButtonFinder);
    expect(convertButton.onPressed, isNotNull);
  });

  testWidgets('ScenesScreen language change clears template selection', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final remote = FakeRemoteRepo();
    final ai = FakeAiChatService({'Battle': null, 'Zh': null});
    final novel = const Novel(
      id: 'n-1',
      title: 'Test Novel',
      author: 'Author',
      description: '',
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    );

    final repo = _MultiLangTemplatesRepo();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWithValue(repo),
          remoteRepositoryProvider.overrideWithValue(remote),
          aiChatServiceProvider.overrideWithValue(ai),
          mockNovelsProvider.overrideWith((ref) async => [novel]),
          novelProvider.overrideWith((ref, id) async => novel),
        ],
        child: const MaterialApp(home: ScenesScreen(novelId: 'n-1')),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'X');
    await tester.enterText(find.widgetWithText(TextFormField, 'Location'), 'L');
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Template'),
      'Battle',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Battle Scene').last);
    await tester.pumpAndSettle();

    final convertLabelFinder = find.text('AI Convert');
    final convertButtonFinder = find.ancestor(
      of: convertLabelFinder,
      matching: find.byWidgetPredicate((w) => w is ElevatedButton),
    );
    expect(
      tester.widget<ElevatedButton>(convertButtonFinder).onPressed,
      isNotNull,
    );

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chinese').last);
    await tester.pumpAndSettle();

    expect(
      tester.widget<ElevatedButton>(convertButtonFinder).onPressed,
      isNull,
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Template'),
      'Zh',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zh Scene').last);
    await tester.pumpAndSettle();

    expect(
      tester.widget<ElevatedButton>(convertButtonFinder).onPressed,
      isNotNull,
    );
  });
}

class _VectorSearchRepo extends LocalStorageRepository {
  _VectorSearchRepo() : super(_MockStorageService());

  @override
  Future<List<SceneTemplateRow>> listSceneTemplates({int? limit}) async {
    return [
      SceneTemplateRow(
        id: 't-1',
        idx: 1,
        title: 'Battle Scene',
        sceneSummaries: 'Template body',
        sceneSynopses: null,
        languageCode: 'en',
        createdBy: 'u-1',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
    ];
  }

  @override
  Future<List<SceneTemplateRow>> searchSceneTemplates(
    String query, {
    int? limit,
    String? languageCode,
  }) async {
    return [
      SceneTemplateRow(
        id: 't-2',
        idx: 2,
        title: 'Vector Pick',
        sceneSummaries: 'Hit',
        sceneSynopses: null,
        languageCode: 'en',
        createdBy: 'u-1',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
    ];
  }

  @override
  Future<Scene?> getSceneForm(String novelId, {int? idx}) async => null;

  @override
  Future<int> nextSceneIdx(String novelId) async => 1;

  @override
  Future<void> saveSceneForm(String novelId, Scene scene, {int? idx}) async {}
}

class _MultiLangTemplatesRepo extends LocalStorageRepository {
  _MultiLangTemplatesRepo() : super(_MockStorageService());

  @override
  Future<List<SceneTemplateRow>> listSceneTemplates({int? limit}) async {
    return [
      SceneTemplateRow(
        id: 't-en',
        idx: 1,
        title: 'Battle Scene',
        sceneSummaries: 'Template body',
        sceneSynopses: null,
        languageCode: 'en',
        createdBy: 'u-1',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
      SceneTemplateRow(
        id: 't-zh',
        idx: 2,
        title: 'Zh Scene',
        sceneSummaries: '模板',
        sceneSynopses: null,
        languageCode: 'zh',
        createdBy: 'u-1',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
    ];
  }

  @override
  Future<Scene?> getSceneForm(String novelId, {int? idx}) async => null;

  @override
  Future<int> nextSceneIdx(String novelId) async => 1;

  @override
  Future<void> saveSceneForm(String novelId, Scene scene, {int? idx}) async {}
}
