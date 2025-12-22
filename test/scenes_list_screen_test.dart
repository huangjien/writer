import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/summary/scenes_list_screen.dart';
import 'package:writer/repositories/notes_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/models/scene_note.dart';
import 'package:writer/state/providers.dart';

class FakeNotesRepo extends NotesRepository {
  FakeNotesRepo() : super(RemoteRepository('http://localhost:5600/'));

  List<SceneNote> items = [
    SceneNote(
      id: 's-1',
      novelId: 'n-1',
      idx: 1,
      title: 'Opening Scene',
      sceneSummaries: 'Introduces journey',
      sceneSynopses: 'Forest',
      languageCode: 'en',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
  ];
  int? deletedIdx;
  String? deletedNovelId;
  @override
  Future<List<SceneNote>> listSceneNotes(String novelId) async {
    return items.where((e) => e.novelId == novelId).toList();
  }

  @override
  Future<void> deleteSceneNoteByIdx(String novelId, int idx) async {
    deletedNovelId = novelId;
    deletedIdx = idx;
    items = items
        .where((e) => !(e.novelId == novelId && e.idx == idx))
        .toList();
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ScenesListScreen renders and deletes item', (tester) async {
    final repo = FakeNotesRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          notesRepositoryProvider.overrideWith((_) => repo),
        ],
        child: const MaterialApp(home: ScenesListScreen(novelId: 'n-1')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Scenes'), findsOneWidget);
    expect(find.text('Opening Scene'), findsOneWidget);
    expect(find.byTooltip('New'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();
    expect(find.text('Delete Scene'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(repo.deletedNovelId, 'n-1');
    expect(repo.deletedIdx, 1);
    expect(find.text('Opening Scene'), findsNothing);
  });
}
