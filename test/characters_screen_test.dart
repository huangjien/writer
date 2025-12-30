import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:writer/features/summary/characters_screen.dart';
import 'package:writer/state/mock_providers.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/models/character_template_row.dart';
import 'package:writer/services/storage_service.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';

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

class CapturingLocalRepo extends LocalStorageRepository {
  CapturingLocalRepo() : super(MockStorageService());

  Map<String, dynamic>? lastNote;
  List<CharacterTemplateRow> templates = [];

  @override
  Future<void> saveCharacterNoteForm(
    String novelId, {
    String? title,
    String? summaries,
    String? synopses,
    String languageCode = 'en',
    int? idx,
  }) async {
    lastNote = {
      'title': title,
      'character_summaries': summaries,
      'character_synopses': synopses,
      'language_code': languageCode,
    };
  }

  @override
  Future<List<CharacterTemplateRow>> listCharacterTemplates() async {
    return templates;
  }

  @override
  Future<int> nextCharacterIdx(String novelId) async => 1;
}

class MockRemoteRepo extends RemoteRepository {
  MockRemoteRepo() : super('http://mock');

  String? convertResult;

  @override
  Future<String?> convertCharacter({
    required String name,
    required String templateContent,
    required String language,
  }) async {
    return convertResult;
  }
}

List<dynamic> createCommonProviderOverrides(SharedPreferences prefs) {
  final appSettings = AppSettingsNotifier(prefs);
  final ttsSettings = TtsSettingsNotifier(prefs);
  final motion = MotionSettingsNotifier(prefs);
  final storageService = LocalStorageService(prefs);

  return [
    sharedPreferencesProvider.overrideWithValue(prefs),
    sessionProvider.overrideWith((ref) => SessionNotifier(storageService)),
    appSettingsProvider.overrideWith((ref) => appSettings),
    ttsSettingsProvider.overrideWith((ref) => ttsSettings),
    motionSettingsProvider.overrideWith((ref) => motion),
    remoteRepositoryProvider.overrideWith(
      (ref) => RemoteRepository('http://localhost:5600/'),
    ),
    aiChatServiceProvider.overrideWith(
      (ref) => AiChatService(ref.read(remoteRepositoryProvider)),
    ),
    isSignedInProvider.overrideWithValue(
      false,
    ), // Disable backend sync for this test
  ];
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('CharactersScreen validates and saves', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final repo = CapturingLocalRepo();
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
          mockNovelsProvider.overrideWith((ref) async => [novel]),
          novelProvider.overrideWith((ref, id) async => novel),
          isSignedInProvider.overrideWithValue(false),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', '')],
          home: const CharactersScreen(novelId: 'n-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Now let's find and interact with the form fields
    // Fill fields and save.
    final titleField = find.widgetWithText(TextFormField, 'Title');
    expect(titleField, findsOneWidget, reason: 'Title field should be found');

    final summariesField = find.ancestor(
      of: find.text('Summaries'),
      matching: find.byType(TextFormField),
    );
    expect(
      summariesField,
      findsOneWidget,
      reason: 'Summaries field should be found',
    );

    final synopsesField = find.widgetWithText(TextFormField, 'Synopses');
    expect(
      synopsesField,
      findsOneWidget,
      reason: 'Synopses field should be found',
    );

    await tester.enterText(titleField, 'Alice');
    await tester.enterText(summariesField, 'Short bio');
    await tester.enterText(synopsesField, 'Long synopsis');
    await tester.pump();

    final saveBtn = find.widgetWithText(ElevatedButton, 'Save');
    expect(saveBtn, findsOneWidget, reason: 'Save button should be found');
    await tester.ensureVisible(saveBtn);
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    expect(repo.lastNote?['title'], 'Alice');
    expect(repo.lastNote?['character_summaries'], 'Short bio');
    expect(repo.lastNote?['character_synopses'], 'Long synopsis');
    expect(repo.lastNote?['language_code'], 'en');
    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets(
    'CharactersScreen saves with selected language and null empty fields',
    (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final repo = CapturingLocalRepo();
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
            mockNovelsProvider.overrideWith((ref) async => [novel]),
            novelProvider.overrideWith((ref, id) async => novel),
            isSignedInProvider.overrideWithValue(false),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', '')],
            home: const CharactersScreen(novelId: 'n-1'),
          ),
        ),
      );
      // Wait for _load to complete
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final titleField = find.widgetWithText(TextFormField, 'Title');
      find.widgetWithText(TextFormField, 'Summaries');
      find.widgetWithText(TextFormField, 'Synopses');

      await tester.enterText(titleField, 'Bob');
      await tester.pumpAndSettle();

      // Leave summaries/synopses empty to verify nulls

      final saveBtn = find.widgetWithText(ElevatedButton, 'Save').first;
      await tester.ensureVisible(saveBtn);

      // Verify button is enabled
      final saveBtnWidget = tester.widget<ElevatedButton>(saveBtn);
      expect(
        saveBtnWidget.onPressed,
        isNotNull,
        reason: 'Save button should be enabled',
      );

      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      if (repo.lastNote == null) {
        // Debug if error occurred
        final errorFinder = find.textContaining('Error');
        if (errorFinder.evaluate().isNotEmpty) {
          fail('Save failed with error: ${errorFinder.evaluate().first}');
        }
      }

      expect(repo.lastNote?['title'], 'Bob');
      expect(repo.lastNote?['character_summaries'], null);
      expect(repo.lastNote?['character_synopses'], null);
      expect(repo.lastNote?['language_code'], 'en');
    },
  );

  testWidgets('CharactersScreen shows templates and converts', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final repo = CapturingLocalRepo();
    repo.templates = [
      CharacterTemplateRow(
        id: 't1',
        idx: 1,
        title: 'Hero',
        characterSummaries: 'A hero template',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    final remoteRepo = MockRemoteRepo();
    remoteRepo.convertResult = 'Generated Profile';

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
          remoteRepositoryProvider.overrideWith((_) => remoteRepo),
          mockNovelsProvider.overrideWith((ref) async => [novel]),
          novelProvider.overrideWith((ref, id) async => novel),
          isSignedInProvider.overrideWithValue(true),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', '')],
          home: const CharactersScreen(novelId: 'n-1'),
        ),
      ),
    );
    // Wait for _load to complete
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Verify Template field exists
    expect(find.text('Template'), findsOneWidget);
    expect(find.byType(Autocomplete<CharacterTemplateRow>), findsOneWidget);

    // Select Template
    final autocomplete = find.byType(Autocomplete<CharacterTemplateRow>);
    await tester.enterText(autocomplete, 'Hero');
    await tester.pumpAndSettle();

    final option = find.text('Hero');
    final heroOption = option.last;
    await tester.tap(heroOption);
    await tester.pumpAndSettle();

    // Enter Name
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Super Bob',
    );
    await tester.pumpAndSettle();

    // Check for AI Convert text
    final aiTextFinder = find.text('AI Convert');
    expect(aiTextFinder, findsOneWidget);

    // Tap the text directly since finding the button seems problematic
    await tester.ensureVisible(aiTextFinder);
    await tester.tap(aiTextFinder);
    await tester.pumpAndSettle(); // Wait for async operation
    await tester.pumpAndSettle();

    // Verify Result in Summaries
    expect(find.text('Generated Profile'), findsOneWidget);

    // Verify Preview Toggle
    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();
    expect(find.text('Edit'), findsOneWidget);
    // In preview mode, text field is hidden, MarkdownBody is shown
    // We can just check that "Generated Profile" is still visible
    expect(find.text('Generated Profile'), findsOneWidget);
  });
}
