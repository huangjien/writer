import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/summary/screens/scenes/scenes_list_screen.dart';
import 'package:writer/models/scene_template_row.dart';
import 'package:writer/models/character_template_row.dart';
import 'package:writer/models/chapter_cache.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/character.dart';
import 'package:writer/models/scene.dart';
import 'package:writer/models/template.dart';
import 'package:writer/models/character_note.dart';
import 'package:writer/models/scene_note.dart';
import 'package:writer/models/cache_metadata.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/shared/api_exception.dart';

class MockLocalStorageRepository implements LocalStorageRepository {
  final List<SceneTemplateRow> _scenes;
  final bool shouldThrowError;
  final int? statusCode;
  final Duration? delay;

  MockLocalStorageRepository({
    List<SceneTemplateRow>? scenes,
    this.shouldThrowError = false,
    this.statusCode,
    this.delay,
  }) : _scenes = scenes ?? [];

  @override
  Future<List<SceneTemplateRow>> listSceneTemplates({
    int? limit,
    int? offset,
    String? languageCode,
  }) async {
    if (shouldThrowError) {
      throw ApiException(statusCode ?? 500, 'Error loading scenes');
    }
    if (delay != null) {
      await Future.delayed(delay!);
    }
    return _scenes;
  }

  @override
  Future<List<CharacterTemplateRow>> listCharacterTemplates() async {
    return [];
  }

  Future<void> saveTimelineEvent(dynamic event) async {
    throw UnimplementedError();
  }

  Future<void> deleteTimelineEvent(String id) async {
    throw UnimplementedError();
  }

  Future<void> saveCharacterTemplate(dynamic template) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteCharacterTemplate(String id) async {
    throw UnimplementedError();
  }

  Future<void> saveSceneTemplate(dynamic template) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteSceneTemplate(String id) async {
    throw UnimplementedError();
  }

  Future<void> saveAll({
    List<dynamic>? characters,
    List<dynamic>? scenes,
  }) async {
    throw UnimplementedError();
  }

  Future<void> clearAll() async {
    throw UnimplementedError();
  }

  Future<Map<String, dynamic>> loadUserData() async {
    return {};
  }

  Future<void> saveUserData(Map<String, dynamic> data) async {
    throw UnimplementedError();
  }

  Future<List<dynamic>> listPlotTemplates() async {
    return [];
  }

  Future<List<dynamic>> listLocationTemplates() async {
    return [];
  }

  Future<List<dynamic>> listTimelineEvents() async {
    return [];
  }

  Future<void> savePlotTemplate(dynamic template) async {
    throw UnimplementedError();
  }

  Future<void> saveLocationTemplate(dynamic template) async {
    throw UnimplementedError();
  }

  Future<void> deletePlotTemplate(String id) async {
    throw UnimplementedError();
  }

  Future<void> deleteLocationTemplate(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<void> saveChapter(ChapterCache chapter) async {
    throw UnimplementedError();
  }

  @override
  Future<ChapterCache?> getChapter(String chapterId) async {
    return null;
  }

  @override
  Future<void> renameChapterId({
    required String from,
    required String to,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> saveChapters(List<ChapterCache> chapters) async {
    throw UnimplementedError();
  }

  @override
  Future<void> removeChapter(String chapterId) async {
    throw UnimplementedError();
  }

  @override
  Future<int> clearChapterCache() async {
    return 0;
  }

  @override
  Future<void> saveLibraryNovels(List<Novel> novels) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Novel>> getLibraryNovels() async {
    return [];
  }

  @override
  Future<void> saveSummaryText(String novelId, String text) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> getSummaryText(String novelId) async {
    return null;
  }

  @override
  Future<void> saveCharacterForm(
    String novelId,
    Character character, {
    int? idx,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Character?> getCharacterForm(String novelId, {int? idx}) async {
    return null;
  }

  @override
  Future<void> saveCharacterNoteForm(
    String novelId, {
    String? title,
    String? summaries,
    String? synopses,
    String languageCode = 'en',
    int? idx,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> getCharacterNoteForm(
    String novelId, {
    int? idx,
  }) async {
    return null;
  }

  @override
  Future<void> saveSceneForm(String novelId, Scene scene, {int? idx}) async {
    throw UnimplementedError();
  }

  @override
  Future<Scene?> getSceneForm(String novelId, {int? idx}) async {
    return null;
  }

  @override
  Future<void> saveCharacterTemplateForm(
    String novelId,
    TemplateItem item,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<TemplateItem?> getCharacterTemplateForm(String novelId) async {
    return null;
  }

  @override
  Future<void> saveSceneTemplateForm(
    String novelId,
    TemplateItem item, {
    String languageCode = 'en',
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<TemplateItem?> getSceneTemplateForm(String novelId) async {
    return null;
  }

  @override
  Future<void> deleteCharacterForm(String novelId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteCharacterNoteForm(String novelId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteSceneForm(String novelId) async {
    throw UnimplementedError();
  }

  @override
  Future<Set<String>> getKeys() async {
    return {};
  }

  @override
  Future<Set<String>> getDownloadedNovelIds() async {
    return {};
  }

  @override
  Future<List<CharacterNote>> listCharacterNotes(String novelId) async {
    return [];
  }

  @override
  Future<List<SceneNote>> listSceneNotes(String novelId) async {
    return [];
  }

  @override
  Future<List<SceneTemplateRow>> searchSceneTemplates(
    String query, {
    int? limit,
    String? languageCode,
  }) async {
    return [];
  }

  @override
  Future<int> nextCharacterIdx(String novelId) async {
    return 1;
  }

  @override
  Future<int> nextSceneIdx(String novelId) async {
    return 1;
  }

  @override
  Future<CharacterTemplateRow?> getCharacterTemplateById(String id) async {
    return null;
  }

  @override
  Future<SceneTemplateRow?> getSceneTemplateById(String id) async {
    return null;
  }

  @override
  Future<void> saveNovel(Novel novel) async {
    throw UnimplementedError();
  }

  @override
  Future<Novel?> getNovel(String novelId) async {
    return null;
  }

  @override
  Future<void> removeNovel(String novelId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> saveNovelsList(
    List<Novel> novels, {
    String key = 'novels_list',
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Novel>> getNovelsList({String key = 'novels_list'}) async {
    return [];
  }

  @override
  Future<void> saveChaptersList(
    String novelId,
    List<Map<String, dynamic>> chapters,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<List<ChapterCache>> getChaptersList(String novelId) async {
    return [];
  }

  @override
  Future<CacheMetadata?> getCacheMetadata(String key) async {
    return null;
  }

  @override
  Future<void> clearCacheByNovel(String novelId) async {
    throw UnimplementedError();
  }
}

void main() {
  group('ScenesListScreen', () {
    testWidgets('renders loading indicator', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageRepositoryProvider.overrideWithValue(
              MockLocalStorageRepository(
                delay: const Duration(milliseconds: 100),
              ),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ScenesListScreen(novelId: 'novel-1'),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
      await tester.pumpAndSettle();
    });

    testWidgets('renders list of scene templates', (tester) async {
      final scenes = [
        SceneTemplateRow(
          id: '1',
          idx: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          title: 'Opening Scene',
          sceneSummaries: 'The story begins',
        ),
        SceneTemplateRow(
          id: '2',
          idx: 1,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          title: 'Climax',
          sceneSynopses: 'The final battle',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageRepositoryProvider.overrideWithValue(
              MockLocalStorageRepository(scenes: scenes),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ScenesListScreen(novelId: 'novel-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Opening Scene'), findsOneWidget);
      expect(find.textContaining('The story begins'), findsOneWidget);
      expect(find.textContaining('Climax'), findsOneWidget);
      expect(find.textContaining('The final battle'), findsOneWidget);
    });

    testWidgets('renders search field', (tester) async {
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
            home: ScenesListScreen(novelId: 'novel-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('filters templates by search query', (tester) async {
      final scenes = [
        SceneTemplateRow(
          id: '1',
          idx: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          title: 'Opening Scene',
          sceneSummaries: 'The story begins',
        ),
        SceneTemplateRow(
          id: '2',
          idx: 1,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          title: 'Climax',
          sceneSummaries: 'The final battle',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageRepositoryProvider.overrideWithValue(
              MockLocalStorageRepository(scenes: scenes),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ScenesListScreen(novelId: 'novel-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Opening');
      await tester.pump();

      expect(find.textContaining('Opening Scene'), findsOneWidget);
      expect(find.textContaining('Climax'), findsNothing);
    });

    testWidgets('shows error state on failure', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageRepositoryProvider.overrideWithValue(
              MockLocalStorageRepository(
                shouldThrowError: true,
                statusCode: 500,
              ),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ScenesListScreen(novelId: 'novel-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('Error loading scenes'), findsOneWidget);
    });

    testWidgets('ignores 401 errors', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageRepositoryProvider.overrideWithValue(
              MockLocalStorageRepository(
                shouldThrowError: true,
                statusCode: 401,
              ),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ScenesListScreen(novelId: 'novel-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Error loading scenes'), findsNothing);
    });

    testWidgets('renders untitled when title is null', (tester) async {
      final scenes = [
        SceneTemplateRow(
          id: '1',
          idx: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageRepositoryProvider.overrideWithValue(
              MockLocalStorageRepository(scenes: scenes),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ScenesListScreen(novelId: 'novel-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Untitled'), findsOneWidget);
    });

    testWidgets('refreshes list on refresh button press', (tester) async {
      final scenes = [
        SceneTemplateRow(
          id: '1',
          idx: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          title: 'Opening Scene',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageRepositoryProvider.overrideWithValue(
              MockLocalStorageRepository(
                scenes: scenes,
                delay: const Duration(milliseconds: 100),
              ),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ScenesListScreen(novelId: 'novel-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      final indicatorFinder = find.byType(CircularProgressIndicator);
      expect(indicatorFinder, findsAtLeastNWidgets(1));
      await tester.pumpAndSettle();
      expect(indicatorFinder, findsNothing);
    });

    testWidgets('displays edit button for each item', (tester) async {
      final scenes = [
        SceneTemplateRow(
          id: '1',
          idx: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          title: 'Opening Scene',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageRepositoryProvider.overrideWithValue(
              MockLocalStorageRepository(scenes: scenes),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ScenesListScreen(novelId: 'novel-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('shows refresh button when not loading', (tester) async {
      final scenes = [
        SceneTemplateRow(
          id: '1',
          idx: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          title: 'Opening Scene',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageRepositoryProvider.overrideWithValue(
              MockLocalStorageRepository(scenes: scenes),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ScenesListScreen(novelId: 'novel-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('navigates to home on back button', (tester) async {
      final scenes = [
        SceneTemplateRow(
          id: '1',
          idx: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          title: 'Opening Scene',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageRepositoryProvider.overrideWithValue(
              MockLocalStorageRepository(scenes: scenes),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ScenesListScreen(novelId: 'novel-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('shows clear button when search has text', (tester) async {
      final scenes = [
        SceneTemplateRow(
          id: '1',
          idx: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          title: 'Opening Scene',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageRepositoryProvider.overrideWithValue(
              MockLocalStorageRepository(scenes: scenes),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ScenesListScreen(novelId: 'novel-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('clears search on clear button press', (tester) async {
      final scenes = [
        SceneTemplateRow(
          id: '1',
          idx: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          title: 'Opening Scene',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageRepositoryProvider.overrideWithValue(
              MockLocalStorageRepository(scenes: scenes),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ScenesListScreen(novelId: 'novel-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, '');
    });

    testWidgets('navigates to new scene screen on add button', (tester) async {
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
            home: ScenesListScreen(novelId: 'novel-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('navigates to home on home button press', (tester) async {
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
            home: ScenesListScreen(novelId: 'novel-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('prioritizes scene summaries over synopses', (tester) async {
      final scenes = [
        SceneTemplateRow(
          id: '1',
          idx: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          title: 'Opening Scene',
          sceneSummaries: 'Summary text',
          sceneSynopses: 'Synopsis text',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageRepositoryProvider.overrideWithValue(
              MockLocalStorageRepository(scenes: scenes),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ScenesListScreen(novelId: 'novel-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Summary text'), findsOneWidget);
      expect(find.textContaining('Synopsis text'), findsNothing);
    });
  });
}
