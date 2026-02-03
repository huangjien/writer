import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:writer/features/summary/characters_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/character_note.dart';
import 'package:writer/models/character_template_row.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/notes_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/repositories/template_repository.dart';
import 'package:writer/services/storage_service.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/providers.dart';

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
  Future<Map<String, dynamic>?> getCharacterNoteForm(
    String novelId, {
    int? idx,
  }) async {
    return {
      'title': 'Test Character',
      'character_summaries': 'Test Summaries',
      'character_synopses': 'Test Synopses',
    };
  }

  @override
  Future<int> nextCharacterIdx(String novelId) async => 1;

  @override
  Future<void> saveCharacterNoteForm(
    String novelId, {
    int? idx,
    String languageCode = 'en',
    String? summaries,
    String? synopses,
    String? title,
  }) async {}

  @override
  Future<List<CharacterTemplateRow>> listCharacterTemplates() async => [];
}

class MockNotesRepository extends NotesRepository {
  MockNotesRepository() : super(MockRemoteRepository());

  @override
  Future<List<CharacterNote>> listCharacterNotes(String novelId) async {
    return [];
  }

  @override
  Future<void> upsertCharacterNote({
    required String novelId,
    required int idx,
    String? languageCode,
    String? summaries,
    String? synopses,
    String? title,
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

  List<CharacterTemplateRow> templates = const [];
  int nextIdx = 1;
  String? lastSavedTitle;
  String? lastSavedSummaries;
  String? lastSavedSynopses;
  String? lastSavedLanguageCode;
  int? lastSavedIdx;

  @override
  Future<Map<String, dynamic>?> getCharacterNoteForm(
    String novelId, {
    int? idx,
  }) async {
    return {
      'title': 'Test Character',
      'character_summaries': '',
      'character_synopses': '',
      'language_code': 'en',
    };
  }

  @override
  Future<int> nextCharacterIdx(String novelId) async => nextIdx;

  @override
  Future<void> saveCharacterNoteForm(
    String novelId, {
    int? idx,
    String languageCode = 'en',
    String? summaries,
    String? synopses,
    String? title,
  }) async {
    lastSavedTitle = title;
    lastSavedSummaries = summaries;
    lastSavedSynopses = synopses;
    lastSavedLanguageCode = languageCode;
    lastSavedIdx = idx;
  }

  @override
  Future<List<CharacterTemplateRow>> listCharacterTemplates() async =>
      templates;
}

class TestRemoteRepository extends RemoteRepository {
  TestRemoteRepository() : super('');

  @override
  Future<String?> convertCharacter({
    required String name,
    required String templateContent,
    required String language,
  }) async {
    return 'Converted character for $name';
  }
}

class FailingRemoteRepository extends RemoteRepository {
  FailingRemoteRepository() : super('');

  @override
  Future<String?> convertCharacter({
    required String name,
    required String templateContent,
    required String language,
  }) async {
    throw Exception('boom');
  }
}

class CapturingNotesRepository extends NotesRepository {
  CapturingNotesRepository() : super(MockRemoteRepository());

  int? lastIdx;
  String? lastTitle;
  String? lastSummaries;
  String? lastSynopses;
  String? lastLanguageCode;

  @override
  Future<List<CharacterNote>> listCharacterNotes(String novelId) async {
    return [];
  }

  @override
  Future<void> upsertCharacterNote({
    required String novelId,
    required int idx,
    String? languageCode,
    String? summaries,
    String? synopses,
    String? title,
  }) async {
    lastIdx = idx;
    lastTitle = title;
    lastSummaries = summaries;
    lastSynopses = synopses;
    lastLanguageCode = languageCode;
  }
}

void main() {
  testWidgets('CharactersScreen renders and loads draft', (tester) async {
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
          home: CharactersScreen(novelId: 'n1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Characters'), findsOneWidget);
    expect(find.text('Test Novel'), findsOneWidget);
  });

  testWidgets(
    'CharactersScreen supports template selection, convert, preview, save',
    (tester) async {
      const novel = Novel(
        id: 'n1',
        title: 'Test Novel',
        languageCode: 'en',
        isPublic: false,
      );

      final local = TestLocalStorageRepository();
      local.templates = [
        CharacterTemplateRow(
          id: 't1',
          idx: 1,
          title: 'Character Arc',
          characterSummaries: 'Arc template',
          characterSynopses: null,
          languageCode: 'en',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ];

      final notesRepo = CapturingNotesRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            novelProvider('n1').overrideWith((ref) => Future.value(novel)),
            isSignedInProvider.overrideWithValue(true),
            authStateProvider.overrideWithValue('session'),
            localStorageRepositoryProvider.overrideWithValue(local),
            notesRepositoryProvider.overrideWithValue(notesRepo),
            templateRepositoryProvider.overrideWithValue(
              MockTemplateRepository(),
            ),
            remoteRepositoryProvider.overrideWithValue(TestRemoteRepository()),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CharactersScreen(novelId: 'n1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final templateField = find.byType(TextFormField).at(1);
      await tester.enterText(templateField, 'Arc');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Character Arc').last);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.info_outline), findsOneWidget);

      await tester.tap(find.text('AI Convert'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Converted character for'), findsOneWidget);

      await tester.tap(find.text('Preview'));
      await tester.pumpAndSettle();
      expect(find.byType(MarkdownBody), findsOneWidget);

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(find.byType(MarkdownBody), findsNothing);

      final saveButton = find.text('Save');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Saved'), findsOneWidget);
      expect(local.lastSavedTitle, isNotNull);
      expect(local.lastSavedIdx, isNotNull);
      expect(notesRepo.lastIdx, isNotNull);
      expect(notesRepo.lastTitle, isNotNull);
    },
  );

  testWidgets(
    'CharactersScreen shows conversion error and blocks invalid save',
    (tester) async {
      const novel = Novel(
        id: 'n1',
        title: 'Test Novel',
        languageCode: 'en',
        isPublic: false,
      );

      final local = TestLocalStorageRepository();
      local.templates = [
        CharacterTemplateRow(
          id: 't1',
          idx: 1,
          title: 'Character Arc',
          characterSummaries: 'Arc template',
          characterSynopses: null,
          languageCode: 'en',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ];

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
              MockTemplateRepository(),
            ),
            remoteRepositoryProvider.overrideWithValue(
              FailingRemoteRepository(),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CharactersScreen(novelId: 'n1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final templateField = find.byType(TextFormField).at(1);
      await tester.enterText(templateField, 'Arc');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Character Arc').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('AI Convert'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Conversion failed:'), findsOneWidget);

      final titleField = find.byType(TextFormField).first;
      await tester.enterText(titleField, '');
      await tester.pumpAndSettle();

      final saveButton = find.text('Save');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(local.lastSavedIdx, isNull);
    },
  );
}
