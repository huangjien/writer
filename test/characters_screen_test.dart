import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novel_reader/features/summary/characters_screen.dart';
import 'package:novel_reader/state/mock_providers.dart';
import 'package:novel_reader/state/novel_providers.dart';
import 'package:novel_reader/models/novel.dart';
import 'package:novel_reader/models/character.dart';
import 'package:novel_reader/main.dart';
import 'package:novel_reader/repositories/local_storage_repository.dart';

class CapturingLocalRepo extends LocalStorageRepository {
  Character? lastCharacter;
  @override
  Future<void> saveCharacterForm(String novelId, Character character) async {
    lastCharacter = character;
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

    // Required validation for Name.
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);

    // Fill fields and save.
    final nameField = find.widgetWithText(TextFormField, 'Name');
    final roleField = find.widgetWithText(TextFormField, 'Role');
    final bioField = find.widgetWithText(TextFormField, 'Bio');
    await tester.enterText(nameField, 'Alice');
    await tester.enterText(roleField, 'Protagonist');
    await tester.enterText(bioField, 'Brave and curious.');
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(repo.lastCharacter?.name, 'Alice');
    expect(repo.lastCharacter?.role, 'Protagonist');
    expect(repo.lastCharacter?.bio, 'Brave and curious.');
    expect(find.text('Saved'), findsOneWidget);
  });
}
