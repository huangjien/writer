import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/reader/chapter_reader_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:writer/state/edit_permissions.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'helpers/test_utils.dart';
import 'helpers/fake_chapter_port.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Back press with dirty edit keeps editing when chosen', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final app = await buildAppScope(
      prefs: prefs,
      extraOverrides: [
        chapterRepositoryProvider.overrideWithValue(FakeChapterPort()),
        editPermissionsProvider('n1').overrideWith((ref) async => true),
      ],
      child: materialAppFor(
        home: ChapterReaderScreen(
          chapterId: 'c1',
          title: 'One',
          content: 'Alpha\nBeta',
          novelId: 'n1',
          allChapters: const [
            Chapter(
              id: 'c1',
              novelId: 'n1',
              idx: 1,
              title: 'One',
              content: 'Alpha\nBeta',
            ),
          ],
          currentIdx: 0,
          autoStartTts: false,
        ),
      ),
    );
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Enter Edit Mode'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    expect(fields, findsWidgets);
    await tester.enterText(fields.at(1), 'Changed');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsWidgets);
  });

  testWidgets('Dirty edit discard on Next exits edit mode', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((_) => TtsSettingsNotifier(prefs)),
          chapterRepositoryProvider.overrideWithValue(FakeChapterPort()),
          editPermissionsProvider('n1').overrideWith((ref) async => true),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChapterReaderScreen(
            chapterId: 'c1',
            title: 'One',
            content: 'Alpha\nBeta',
            novelId: 'n1',
            allChapters: [
              Chapter(
                id: 'c1',
                novelId: 'n1',
                idx: 1,
                title: 'One',
                content: 'Alpha\nBeta',
              ),
            ],
            currentIdx: 0,
            autoStartTts: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Enter Edit Mode'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(1), 'Changed');
    await tester.pump();
    expect(find.byKey(const ValueKey('reader_bottom_bar')), findsOneWidget);
    var nextFinder = find.byTooltip('Next chapter');
    if (nextFinder.evaluate().isEmpty) {
      nextFinder = find.byIcon(Icons.skip_next);
    }
    expect(nextFinder, findsOneWidget);
    await tester.tap(nextFinder);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Discard changes'));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNothing);
  });
}
