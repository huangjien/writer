import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:writer/features/summary/screens/scenes/scenes_screen.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/template_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/repositories/notes_repository.dart';
import 'package:writer/models/scene.dart';
import 'package:writer/models/scene_template_row.dart';
import 'package:writer/models/scene_note.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/services/storage_service.dart';

class MockStorageService implements StorageService {
  final Map<String, String> _data = {};

  @override
  String? getString(String key) => _data[key];

  @override
  Future<void> setString(String key, String? value) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<void> remove(String key) async {
    _data.remove(key);
  }

  @override
  Set<String> getKeys() => _data.keys.toSet();
}

class MockLocalStorageRepository extends LocalStorageRepository {
  MockLocalStorageRepository() : super(MockStorageService());

  @override
  Future<Scene?> getSceneForm(String novelId, {int? idx}) async {
    return Scene(novelId: novelId, title: 'Draft Scene');
  }

  @override
  Future<List<SceneTemplateRow>> listSceneTemplates({int? limit}) async {
    return [];
  }

  @override
  Future<int> nextSceneIdx(String novelId) async => 1;

  @override
  Future<void> saveSceneForm(String novelId, Scene scene, {int? idx}) async {}
}

class MockNotesRepository extends NotesRepository {
  MockNotesRepository() : super(MockRemoteRepository());

  @override
  Future<List<SceneNote>> listSceneNotes(String novelId) async {
    return [];
  }

  @override
  Future<void> upsertSceneNote({
    required String novelId,
    required int idx,
    String? title,
    String? synopses,
    String? summaries,
    String? languageCode,
  }) async {}
}

class MockTemplateRepository extends TemplateRepository {
  MockTemplateRepository() : super(MockRemoteRepository());
}

class MockRemoteRepository extends RemoteRepository {
  MockRemoteRepository() : super('');
}

class TestLocalStorageRepository extends LocalStorageRepository {
  TestLocalStorageRepository() : super(MockStorageService());

  Scene? sceneForm;
  final Map<int, Scene> scenesByIdx = {};
  int nextIdx = 1;
  Scene? lastSavedScene;
  int? lastSavedIdx;
  List<SceneTemplateRow> templates = const [];
  List<SceneTemplateRow> searchResults = const [];

  @override
  Future<Scene?> getSceneForm(String novelId, {int? idx}) async {
    if (idx != null) {
      final scene = scenesByIdx[idx];
      if (scene != null) return scene;
    }
    return sceneForm ?? Scene(novelId: novelId, title: 'Draft Scene');
  }

  @override
  Future<List<SceneTemplateRow>> listSceneTemplates({int? limit}) async {
    return templates;
  }

  @override
  Future<List<SceneTemplateRow>> searchSceneTemplates(
    String query, {
    int? limit,
    String? languageCode,
  }) async {
    return searchResults;
  }

  @override
  Future<int> nextSceneIdx(String novelId) async => nextIdx;

  @override
  Future<void> saveSceneForm(String novelId, Scene scene, {int? idx}) async {
    lastSavedScene = scene;
    lastSavedIdx = idx;
  }
}

class TestTemplateRepository extends TemplateRepository {
  TestTemplateRepository() : super(MockRemoteRepository());

  List<SceneTemplateRow> templates = const [];
  List<SceneTemplateRow> searchResults = const [];

  @override
  Future<List<SceneTemplateRow>> listSceneTemplates({int limit = 200}) async {
    return templates;
  }

  @override
  Future<List<SceneTemplateRow>> searchSceneTemplates(
    String query, {
    int limit = 10,
    int offset = 0,
    String? languageCode,
  }) async {
    return searchResults;
  }
}

class TestRemoteRepository extends RemoteRepository {
  TestRemoteRepository() : super('');

  @override
  Future<String?> convertScene({
    required String name,
    required String templateContent,
    required String language,
  }) async {
    return 'Converted summary for $name';
  }
}

class CapturingNotesRepository extends NotesRepository {
  CapturingNotesRepository() : super(MockRemoteRepository());

  List<SceneNote> notes = const [];
  int? lastIdx;
  String? lastTitle;
  String? lastSummaries;
  String? lastSynopses;
  String? lastLanguageCode;

  @override
  Future<List<SceneNote>> listSceneNotes(String novelId) async {
    return notes;
  }

  @override
  Future<void> upsertSceneNote({
    required String novelId,
    required int idx,
    String? title,
    String? synopses,
    String? summaries,
    String? languageCode,
  }) async {
    lastIdx = idx;
    lastTitle = title;
    lastSynopses = synopses;
    lastSummaries = summaries;
    lastLanguageCode = languageCode;
  }
}

void main() {
  testWidgets('ScenesScreen renders and loads draft', (tester) async {
    const novel = Novel(
      id: 'n1',
      title: 'Test Novel',
      languageCode: 'en',
      isPublic: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelProvider('n1').overrideWith((ref) => Future.value(novel)),
          isSignedInProvider.overrideWith((ref) => false),
          localStorageRepositoryProvider.overrideWithValue(
            MockLocalStorageRepository(),
          ),
          notesRepositoryProvider.overrideWithValue(MockNotesRepository()),
          templateRepositoryProvider.overrideWithValue(
            MockTemplateRepository(),
          ),
          remoteRepositoryProvider.overrideWithValue(MockRemoteRepository()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ScenesScreen(novelId: 'n1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Scenes'), findsOneWidget);
    expect(find.text('Test Novel'), findsOneWidget);
    expect(find.text('Draft Scene'), findsOneWidget);
  });

  testWidgets('ScenesScreen supports template search, convert, preview, save', (
    tester,
  ) async {
    const novel = Novel(
      id: 'n1',
      title: 'Test Novel',
      languageCode: 'en',
      isPublic: false,
    );

    final local = TestLocalStorageRepository();
    final templates = [
      SceneTemplateRow(
        id: 't1',
        idx: 1,
        title: 'Foreshadowing',
        sceneSummaries: 'Use foreshadowing',
        sceneSynopses: null,
        languageCode: 'en',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    ];
    local.templates = templates;

    final templateRepo = TestTemplateRepository();
    templateRepo.templates = templates;
    templateRepo.searchResults = templates;

    final notesRepo = CapturingNotesRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelProvider('n1').overrideWith((ref) => Future.value(novel)),
          isSignedInProvider.overrideWithValue(true),
          authStateProvider.overrideWithValue('session'),
          localStorageRepositoryProvider.overrideWithValue(local),
          notesRepositoryProvider.overrideWithValue(notesRepo),
          templateRepositoryProvider.overrideWithValue(templateRepo),
          remoteRepositoryProvider.overrideWithValue(TestRemoteRepository()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ScenesScreen(novelId: 'n1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final templateField = find.byType(TextFormField).at(1);
    expect(templateField, findsOneWidget);

    await tester.enterText(templateField, 'Fore');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Foreshadowing').last);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.info_outline), findsOneWidget);

    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();
    expect(find.byType(MarkdownBody), findsOneWidget);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.byType(MarkdownBody), findsNothing);

    await tester.tap(find.text('AI Convert'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Converted summary for'), findsOneWidget);

    final saveButton = find.text('Save');
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Saved'), findsOneWidget);
    expect(local.lastSavedScene, isNotNull);
    expect(local.lastSavedIdx, isNotNull);
    expect(notesRepo.lastIdx, isNotNull);
    expect(notesRepo.lastTitle, isNotNull);
  });

  testWidgets(
    'ScenesScreen falls back template search and shows conversion error',
    (tester) async {
      const novel = Novel(
        id: 'n1',
        title: 'Test Novel',
        languageCode: 'en',
        isPublic: false,
      );

      final local = TestLocalStorageRepository();
      final templates = [
        SceneTemplateRow(
          id: 't1',
          idx: 1,
          title: 'Foreshadowing',
          sceneSummaries: 'Use foreshadowing',
          sceneSynopses: null,
          languageCode: 'en',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ];
      local.templates = templates;
      local.searchResults = templates;

      final failingRemote = _FailingRemoteRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            novelProvider('n1').overrideWith((ref) => Future.value(novel)),
            isSignedInProvider.overrideWithValue(true),
            authStateProvider.overrideWithValue('session'),
            localStorageRepositoryProvider.overrideWithValue(local),
            notesRepositoryProvider.overrideWithValue(
              CapturingNotesRepository(),
            ),
            templateRepositoryProvider.overrideWithValue(
              _FailingTemplateRepository(),
            ),
            remoteRepositoryProvider.overrideWithValue(failingRemote),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ScenesScreen(novelId: 'n1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final templateField = find.byType(TextFormField).at(1);
      await tester.enterText(templateField, 'Fore');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Foreshadowing').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('AI Convert'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Conversion failed:'), findsOneWidget);

      final titleField = find.byType(TextFormField).first;
      await tester.enterText(titleField, '');
      await tester.pumpAndSettle();
      final saveButton = find.text('Save');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton, warnIfMissed: false);
      await tester.pumpAndSettle();
    },
  );
}

class _FailingTemplateRepository extends TemplateRepository {
  _FailingTemplateRepository() : super(MockRemoteRepository());

  @override
  Future<List<SceneTemplateRow>> listSceneTemplates({int limit = 200}) async {
    return [
      SceneTemplateRow(
        id: 't1',
        idx: 1,
        title: 'Foreshadowing',
        sceneSummaries: 'Use foreshadowing',
        sceneSynopses: null,
        languageCode: 'en',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    ];
  }

  @override
  Future<List<SceneTemplateRow>> searchSceneTemplates(
    String query, {
    int limit = 10,
    int offset = 0,
    String? languageCode,
  }) async {
    throw Exception('fail');
  }
}

class _FailingRemoteRepository extends RemoteRepository {
  _FailingRemoteRepository() : super('');

  @override
  Future<String?> convertScene({
    required String name,
    required String templateContent,
    required String language,
  }) async {
    throw Exception('boom');
  }
}
