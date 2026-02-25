import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/summary/screens/characters/character_templates_screen.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/repositories/template_repository.dart';
import 'package:writer/models/template.dart';
import 'package:writer/models/character_template_row.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/services/storage_service.dart';

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

  TemplateItem? lastItem;
  @override
  Future<void> saveCharacterTemplateForm(
    String novelId,
    TemplateItem item,
  ) async {
    lastItem = item;
  }

  @override
  Future<TemplateItem?> getCharacterTemplateForm(String novelId) async {
    // Return null to simulate "new" character (clean form)
    return null;
  }
}

class MockRemoteRepo extends RemoteRepository {
  MockRemoteRepo() : super('http://mock');

  String? queryName;
  String? mockResponse;
  bool shouldFail = false;

  @override
  Future<String?> fetchCharacterProfile(String name) async {
    queryName = name;
    await Future.delayed(const Duration(milliseconds: 50));
    if (shouldFail) throw Exception('Network error');
    return mockResponse;
  }

  @override
  Future<Map<String, dynamic>?> generateCharacterTemplate({
    required String title,
    required String templateContent,
    String? name,
    String? languageCode,
  }) async {
    queryName = name;
    await Future.delayed(const Duration(milliseconds: 50));
    if (shouldFail) throw Exception('Network error');
    return {'id': 'test-id-123', 'title': title};
  }
}

class MockTemplateRepo extends TemplateRepository {
  MockTemplateRepo() : super(MockRemoteRepo());

  String? queryName;
  int callCount = 0;

  @override
  Future<Map<String, dynamic>?> generateCharacterTemplate({
    required String title,
    required String templateContent,
    String? name,
    String? languageCode,
  }) async {
    queryName = name;
    await Future.delayed(const Duration(milliseconds: 50));
    callCount = 0;
    return {'id': 'test-id-123', 'title': title};
  }

  @override
  Future<CharacterTemplateRow?> getCharacterTemplateById(String id) async {
    callCount++;
    await Future.delayed(const Duration(milliseconds: 50));
    if (callCount < 2) {
      return CharacterTemplateRow(
        id: id,
        idx: 1,
        title: 'Harry Potter',
        characterSummaries: '',
        characterSynopses: '',
        languageCode: 'en',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    return CharacterTemplateRow(
      id: id,
      idx: 1,
      title: 'Harry Potter',
      characterSummaries:
          '### Archetype: The Hero\n- **Role**: Protagonist\n- **Goal**: Save the world',
      characterSynopses:
          'Harry is a brave hero who must save the world from evil.',
      languageCode: 'en',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

class ThrowingTemplateRepo extends TemplateRepository {
  ThrowingTemplateRepo() : super(MockRemoteRepo());

  @override
  Future<Map<String, dynamic>?> generateCharacterTemplate({
    required String title,
    required String templateContent,
    String? name,
    String? languageCode,
  }) async {
    throw Exception('Network error');
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('CharacterTemplatesScreen validates and saves', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final repo = CapturingLocalRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWith((_) => repo),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CharacterTemplatesScreen(novelId: 'n-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Switch to Edit tab first because Preview is now default
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    final descFieldPre = find.widgetWithText(
      TextFormField,
      'Enter description in Markdown...',
    );
    await tester.enterText(descFieldPre, 'X');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);

    // Fill fields and save.
    final nameField = find.widgetWithText(TextFormField, 'Template Name');

    // Description field is only visible in Edit tab.
    // Note: The hint text is "Enter description in Markdown..."
    final descField = find.widgetWithText(
      TextFormField,
      'Enter description in Markdown...',
    );

    await tester.enterText(nameField, 'Hero Archetype');
    await tester.enterText(descField, 'Brave protagonist setup');
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(repo.lastItem?.name, 'Hero Archetype');
    expect(repo.lastItem?.description, 'Brave protagonist setup');
    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('CharacterTemplatesScreen retrieves profile', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final localRepo = CapturingLocalRepo();
    final remoteRepo = MockRemoteRepo();
    final templateRepo = MockTemplateRepo();
    remoteRepo.mockResponse = '''
### Archetype: The Hero
- **Role**: Protagonist
- **Goal**: Save the world
''';

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWith((_) => localRepo),
          remoteRepositoryProvider.overrideWith((_) => remoteRepo),
          templateRepositoryProvider.overrideWith((_) => templateRepo),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CharacterTemplatesScreen(novelId: 'n-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Switch to Edit tab to verify text field content later
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    final retrieveBtnFinder = find.widgetWithIcon(IconButton, Icons.download);
    expect(retrieveBtnFinder, findsOneWidget);
    expect(tester.widget<IconButton>(retrieveBtnFinder).onPressed, isNull);

    // Enter name
    final nameField = find.widgetWithText(TextFormField, 'Template Name');
    await tester.enterText(nameField, 'Harry Potter');
    await tester.pump(); // Rebuild to enable button

    // Retrieve button enabled
    expect(tester.widget<IconButton>(retrieveBtnFinder).onPressed, isNotNull);

    // Click retrieve
    await tester.tap(retrieveBtnFinder);

    // Pump to start the async operation and show spinner
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Simulate polling - pump enough time for multiple polls
    // Each poll waits 7 seconds, so we need to pump for >7 seconds to get the second poll
    await tester.pump(const Duration(seconds: 8));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Pump again to get the second poll that returns content
    await tester.pump(const Duration(seconds: 8));

    // Wait for everything to finish including snackbar
    await tester.pumpAndSettle();

    // Verify repo called
    expect(templateRepo.queryName, 'Harry Potter');

    // Verify snackbar shown
    expect(find.text('Profile retrieved'), findsOneWidget);
  });

  testWidgets('CharacterTemplatesScreen handles retrieve error', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final remoteRepo = MockRemoteRepo();
    remoteRepo.shouldFail = true;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          remoteRepositoryProvider.overrideWith((_) => remoteRepo),
          templateRepositoryProvider.overrideWith(
            (_) => ThrowingTemplateRepo(),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CharacterTemplatesScreen(novelId: 'n-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final nameField = find.widgetWithText(TextFormField, 'Template Name');
    await tester.enterText(nameField, 'Error Man');
    await tester.pump();

    await tester.tap(find.widgetWithIcon(IconButton, Icons.download));
    await tester.pump(); // Start spinner

    // The polling will run for 26 * 7 seconds, but in test we pump shorter time
    // since ThrowingTemplateRepo throws immediately on generateCharacterTemplate
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Error should be shown
    expect(find.textContaining('Network error'), findsOneWidget);
  });
}
