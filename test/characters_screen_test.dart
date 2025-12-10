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

class CapturingLocalRepo extends LocalStorageRepository {
  Map<String, dynamic>? lastNote;
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
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);

    // Fill fields and save.
    final titleField = find.widgetWithText(TextFormField, 'Title');
    final summariesField = find.widgetWithText(TextFormField, 'Summaries');
    final synopsesField = find.widgetWithText(TextFormField, 'Synopses');
    await tester.enterText(titleField, 'Alice');
    await tester.enterText(summariesField, 'Short bio');
    await tester.enterText(synopsesField, 'Long synopsis');
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repo.lastNote?['title'], 'Alice');
    expect(repo.lastNote?['character_summaries'], 'Short bio');
    expect(repo.lastNote?['character_synopses'], 'Long synopsis');
    expect(repo.lastNote?['language_code'], 'en');
    expect(find.text('Saved'), findsOneWidget);
  });
}
