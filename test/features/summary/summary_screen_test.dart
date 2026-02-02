import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/summary/summary_screen.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/template_repository.dart';
import 'package:writer/repositories/notes_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/models/character_note.dart';
import 'package:writer/services/storage_service.dart';
import 'package:writer/state/novel_providers.dart';

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

void main() {
  testWidgets('SummaryScreen renders and loads data', (tester) async {
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
          home: SummaryScreen(novelId: 'n1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Summary'), findsOneWidget);
  });

  testWidgets('SummaryScreen renders sentence tab', (tester) async {
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
          home: SummaryScreen(novelId: 'n1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final mainTabBars = find.byType(TabBar);
    expect(mainTabBars, findsWidgets);

    expect(find.text('Sentence Summary'), findsOneWidget);
    expect(find.text('Paragraph Summary'), findsOneWidget);
    expect(find.text('Page Summary'), findsOneWidget);
    expect(find.text('Expanded Summary'), findsOneWidget);

    await tester.tap(find.text('Sentence Summary'));
    await tester.pumpAndSettle();

    expect(find.text('Preview'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
  });

  testWidgets('SummaryScreen renders paragraph tab', (tester) async {
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
          home: SummaryScreen(novelId: 'n1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Paragraph Summary'));
    await tester.pumpAndSettle();

    expect(find.text('Preview'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
  });

  testWidgets('SummaryScreen renders page tab', (tester) async {
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
          home: SummaryScreen(novelId: 'n1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Page Summary'));
    await tester.pumpAndSettle();

    expect(find.text('Preview'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
  });

  testWidgets('SummaryScreen renders expanded tab', (tester) async {
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
          home: SummaryScreen(novelId: 'n1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Expanded Summary'));
    await tester.pumpAndSettle();

    expect(find.text('Preview'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
  });
}
