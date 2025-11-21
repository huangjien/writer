import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novel_reader/features/summary/scenes_screen.dart';
import 'package:novel_reader/state/mock_providers.dart';
import 'package:novel_reader/state/novel_providers.dart';
import 'package:novel_reader/models/novel.dart';
import 'package:novel_reader/models/scene.dart';
import 'package:novel_reader/main.dart';
import 'package:novel_reader/repositories/local_storage_repository.dart';

class CapturingLocalRepo extends LocalStorageRepository {
  Scene? lastScene;
  @override
  Future<void> saveSceneForm(String novelId, Scene scene) async {
    lastScene = scene;
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ScenesScreen validates and saves', (tester) async {
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
        child: const MaterialApp(home: ScenesScreen(novelId: 'n-1')),
      ),
    );

    await tester.pumpAndSettle();

    // Required validation for Title.
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);

    // Fill fields and save.
    final titleField = find.widgetWithText(TextFormField, 'Title');
    final locField = find.widgetWithText(TextFormField, 'Location');
    final sumField = find.widgetWithText(TextFormField, 'Summary');
    await tester.enterText(titleField, 'Opening Scene');
    await tester.enterText(locField, 'Forest');
    await tester.enterText(sumField, 'Introduces the journey.');
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(repo.lastScene?.title, 'Opening Scene');
    expect(repo.lastScene?.location, 'Forest');
    expect(repo.lastScene?.summary, 'Introduces the journey.');
    expect(find.text('Saved'), findsOneWidget);
  });
}
