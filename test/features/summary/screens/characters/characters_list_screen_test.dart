import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/summary/screens/characters/characters_list_screen.dart';
import 'package:writer/models/character_template_row.dart';
import 'package:writer/models/scene_template_row.dart';
import 'package:writer/models/template.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/chapter_cache.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/character.dart';
import 'package:writer/models/character_note.dart';
import 'package:writer/models/scene.dart';
import 'package:writer/models/scene_note.dart';
import 'package:writer/models/cache_metadata.dart';

class MockLocalStorageRepository implements LocalStorageRepository {
  final List<CharacterTemplateRow> _templates;
  final bool shouldThrowError;
  final int? statusCode;

  MockLocalStorageRepository({
    List<CharacterTemplateRow>? templates,
    this.shouldThrowError = false,
    this.statusCode,
  }) : _templates = templates ?? [];

  @override
  Future<List<CharacterTemplateRow>> listCharacterTemplates() async {
    if (shouldThrowError) {
      throw MockApiException(statusCode ?? 500, 'Error loading templates');
    }
    return _templates;
  }

  @override
  Future<List<SceneTemplateRow>> listSceneTemplates({int? limit}) async {
    return [];
  }

  @override
  Future<void> saveChapter(ChapterCache chapter) async {}

  @override
  Future<void> saveChapters(List<ChapterCache> chapters) async {}

  @override
  Future<void> saveLibraryNovels(List<Novel> novels) async {}

  @override
  Future<void> saveSummaryText(String novelId, String text) async {}

  @override
  Future<void> saveCharacterForm(
    String novelId,
    Character character, {
    int? idx,
  }) async {}

  @override
  Future<void> saveCharacterNoteForm(
    String novelId, {
    String? title,
    String? summaries,
    String? synopses,
    String languageCode = 'en',
    int? idx,
  }) async {}

  @override
  Future<void> saveSceneForm(String novelId, Scene scene, {int? idx}) async {}

  @override
  Future<void> saveCharacterTemplateForm(
    String novelId,
    TemplateItem item,
  ) async {}

  @override
  Future<void> saveSceneTemplateForm(
    String novelId,
    TemplateItem item, {
    String languageCode = 'en',
  }) async {}

  @override
  Future<void> clearCacheByNovel(String novelId) async {}

  @override
  Future<int> clearChapterCache() async => 0;

  @override
  Future<void> deleteCharacterForm(String novelId) async {}

  @override
  Future<void> deleteCharacterNoteForm(String novelId) async {}

  @override
  Future<void> deleteSceneForm(String novelId) async {}

  @override
  Future<void> deleteCharacterTemplate(String id) async {}

  @override
  Future<void> deleteSceneTemplate(String id) async {}

  @override
  Future<void> removeChapter(String chapterId) async {}

  @override
  Future<void> removeNovel(String novelId) async {}

  @override
  Future<ChapterCache?> getChapter(String chapterId) async => null;

  @override
  Future<Character?> getCharacterForm(String novelId, {int? idx}) async => null;

  @override
  Future<Map<String, dynamic>?> getCharacterNoteForm(
    String novelId, {
    int? idx,
  }) async => null;

  @override
  Future<Scene?> getSceneForm(String novelId, {int? idx}) async => null;

  @override
  Future<TemplateItem?> getCharacterTemplateForm(String novelId) async => null;

  @override
  Future<TemplateItem?> getSceneTemplateForm(String novelId) async => null;

  @override
  Future<String?> getSummaryText(String novelId) async => null;

  @override
  Future<List<Novel>> getLibraryNovels() async => [];

  @override
  Future<Set<String>> getKeys() async => {};

  @override
  Future<List<Novel>> getNovelsList({String key = 'novels_list'}) async => [];

  @override
  Future<List<ChapterCache>> getChaptersList(String novelId) async => [];

  @override
  Future<Set<String>> getDownloadedNovelIds() async => {};

  @override
  Future<List<CharacterNote>> listCharacterNotes(String novelId) async => [];

  @override
  Future<List<SceneNote>> listSceneNotes(String novelId) async => [];

  @override
  Future<List<SceneTemplateRow>> searchSceneTemplates(
    String query, {
    int? limit,
    String? languageCode,
  }) async => [];

  @override
  Future<void> renameChapterId({
    required String from,
    required String to,
  }) async {}

  @override
  Future<void> saveNovel(Novel novel) async {}

  @override
  Future<void> saveNovelsList(List<Novel> novels, {String? key}) async {}

  @override
  Future<void> saveChaptersList(
    String novelId,
    List<Map<String, dynamic>> chapters,
  ) async {}

  @override
  Future<Novel?> getNovel(String novelId) async => null;

  @override
  Future<int> nextCharacterIdx(String novelId) async => 2;

  @override
  Future<int> nextSceneIdx(String novelId) async => 2;

  @override
  Future<CharacterTemplateRow?> getCharacterTemplateById(String id) async =>
      null;

  @override
  Future<SceneTemplateRow?> getSceneTemplateById(String id) async => null;

  @override
  Future<CacheMetadata?> getCacheMetadata(String key) async => null;
}

class MockApiException implements Exception {
  final int statusCode;
  final String message;
  MockApiException(this.statusCode, this.message);
}

void main() {
  group('CharactersListScreen', () {
    testWidgets('renders character list', (tester) async {
      final characters = [
        CharacterTemplateRow(
          id: '1',
          idx: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          title: 'Hero',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageRepositoryProvider.overrideWithValue(
              MockLocalStorageRepository(templates: characters),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CharactersListScreen(novelId: 'novel-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Hero'), findsOneWidget);
    });

    testWidgets('shows error message on error', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageRepositoryProvider.overrideWithValue(
              MockLocalStorageRepository(shouldThrowError: true),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CharactersListScreen(novelId: 'novel-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows empty state when no characters', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageRepositoryProvider.overrideWithValue(
              MockLocalStorageRepository(),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CharactersListScreen(novelId: 'novel-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
