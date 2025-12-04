import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/summary/characters_list_screen.dart';
import 'package:writer/main.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/models/character_note.dart';

class FakeLocalRepo extends LocalStorageRepository {
  List<CharacterNote> items = [
    CharacterNote(
      id: 'c-1',
      novelId: 'n-1',
      idx: 1,
      title: 'Alice',
      characterSummaries: 'Hero',
      characterSynopses: 'Background',
      languageCode: 'en',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
  ];
  int? deletedIdx;
  String? deletedNovelId;
  @override
  Future<List<CharacterNote>> listCharacterNotes(String novelId) async {
    return items.where((e) => e.novelId == novelId).toList();
  }
  @override
  Future<void> deleteCharacterNoteByIdx(String novelId, int idx) async {
    deletedNovelId = novelId;
    deletedIdx = idx;
    items = items.where((e) => !(e.novelId == novelId && e.idx == idx)).toList();
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('CharactersListScreen renders and deletes item', (tester) async {
    final repo = FakeLocalRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [localStorageRepositoryProvider.overrideWith((_) => repo)],
        child: const MaterialApp(home: CharactersListScreen(novelId: 'n-1')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Characters'), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
    expect(find.byTooltip('New'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();
    expect(find.text('Delete Character'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(repo.deletedNovelId, 'n-1');
    expect(repo.deletedIdx, 1);
    expect(find.text('Alice'), findsNothing);
  });
}
