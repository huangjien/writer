import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/summary/scenes_screen.dart';
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
}
