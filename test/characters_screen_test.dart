import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/summary/characters_screen.dart';
import 'package:writer/state/mock_providers.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/main.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/models/character_template_row.dart';

class CapturingLocalRepo extends LocalStorageRepository {
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
  MockRemoteRepo() : super('');

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

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('CharactersScreen validates and saves', (tester) async {
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
          localStorageRepositoryProvider.overrideWith((_) => repo),
          mockNovelsProvider.overrideWith((ref) async => [novel]),
          novelProvider.overrideWith((ref, id) async => novel),
        ],
        child: const MaterialApp(home: CharactersScreen(novelId: 'n-1')),
      ),
    );

    await tester.pumpAndSettle();

    final summariesFieldPre = find.widgetWithText(TextFormField, 'Summaries');
    await tester.enterText(summariesFieldPre, 'X');
    await tester.pump();
    // Scroll to find Save button if needed
    final saveBtn = find.widgetWithText(ElevatedButton, 'Save').first;
    await tester.ensureVisible(saveBtn);
    await tester.tap(saveBtn);
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);

    // Fill fields and save.
    final titleField = find.widgetWithText(TextFormField, 'Title');
    final summariesField = find.widgetWithText(TextFormField, 'Summaries');
    final synopsesField = find.widgetWithText(TextFormField, 'Synopses');
    await tester.enterText(titleField, 'Alice');
    await tester.enterText(summariesField, 'Short bio');
    await tester.enterText(synopsesField, 'Long synopsis');

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
            localStorageRepositoryProvider.overrideWith((_) => repo),
            mockNovelsProvider.overrideWith((ref) async => [novel]),
            novelProvider.overrideWith((ref, id) async => novel),
          ],
          child: const MaterialApp(home: CharactersScreen(novelId: 'n-1')),
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
          localStorageRepositoryProvider.overrideWith((_) => repo),
          remoteRepositoryProvider.overrideWith((_) => remoteRepo),
          mockNovelsProvider.overrideWith((ref) async => [novel]),
          novelProvider.overrideWith((ref, id) async => novel),
        ],
        child: const MaterialApp(home: CharactersScreen(novelId: 'n-1')),
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

    final option = find.text('Hero').last;
    await tester.tap(option);
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

    // Wait for async operation
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
