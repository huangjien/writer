import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/summary/screens/characters/character_templates_screen.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/models/template.dart';
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
    // Add small delay to ensure UI can render loading state
    await Future.delayed(const Duration(milliseconds: 50));
    if (shouldFail) throw Exception('Network error');
    return mockResponse;
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

    // Pump a single frame to allow setState to run and show the spinner
    await tester.pump();
    // Do NOT settle yet, because settle waits for the async task to finish (and spinner to go away)

    // Verify spinner exists
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Now wait for everything to finish
    await tester.pumpAndSettle();

    // Verify repo called
    expect(remoteRepo.queryName, 'Harry Potter');

    // Verify description filled in Edit tab
    final descField = find.widgetWithText(
      TextFormField,
      'Enter description in Markdown...',
    );
    final descText =
        (tester.widget(descField) as TextFormField).controller!.text;

    expect(descText, contains('### Archetype: The Hero'));
    expect(descText, contains('Protagonist'));
    expect(descText, contains('Save the world'));
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
    await tester.pumpAndSettle(); // Finish async

    expect(find.textContaining('Retrieve failed'), findsOneWidget);
  });
}
