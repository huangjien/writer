import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:writer/features/reader/novel_metadata_editor.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'helpers/test_utils.dart';

class CapturingNovelRepository extends NovelRepository {
  CapturingNovelRepository() : super(RemoteRepository('http://localhost'));
  Map<String, dynamic>? lastUpdate;
  @override
  Future<Novel?> getNovel(String novelId) async {
    return const Novel(
      id: 'n-1',
      title: 'Test Novel',
      author: 'A. Author',
      description: 'Test description',
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    );
  }

  @override
  Future<void> updateNovelMetadata(
    String novelId, {
    String? title,
    String? description,
    String? coverUrl,
    String? languageCode,
    bool? isPublic,
  }) async {
    lastUpdate = {
      'novelId': novelId,
      'title': title,
      'description': description,
      'cover_url': coverUrl,
      'language_code': languageCode,
      'is_public': isPublic,
    };
  }
}

void main() {
  testWidgets(
    'Cover URL validator shows error and disables Save for invalid URL',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final fakeRepo = CapturingNovelRepository();

      final app = ProviderScope(
        overrides: [novelRepositoryProvider.overrideWith((ref) => fakeRepo)],
        child: materialAppFor(
          home: const Scaffold(body: NovelMetadataEditor(novelId: 'n-1')),
          locale: const Locale('en'),
        ),
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final tile = find.byType(ExpansionTile);
      expect(tile, findsOneWidget);
      await tester.tap(tile);
      await tester.pumpAndSettle();

      // Initial render shows the editor; exact field count can vary

      // Enter an invalid URL (wrong scheme and contains space)
      final coverField = find.widgetWithText(TextFormField, 'Cover URL').first;
      expect(find.text('Cover URL'), findsWidgets);
      await tester.tap(coverField);
      await tester.pump();
      await tester.enterText(coverField, 'ftp://bad link');
      await tester.pumpAndSettle();

      // Error appears and Save should be disabled; tapping Save should not call repo
      expect(
        find.text('Enter a valid http(s) URL without spaces.'),
        findsOneWidget,
      );
      final saveIcon = find.byIcon(Icons.save);
      expect(saveIcon, findsOneWidget);
      await tester.tap(saveIcon);
      await tester.pump();
      expect(fakeRepo.lastUpdate, isNull);

      // Enter a valid URL
      await tester.tap(coverField);
      await tester.pump();
      await tester.enterText(coverField, 'https://example.com/cover.png');
      await tester.pumpAndSettle();

      // Error disappears and Save becomes enabled
      expect(
        find.text('Enter a valid http(s) URL without spaces.'),
        findsNothing,
      );
      // Touch another field to trigger a rebuild cycle
      final titleField = find.byType(TextFormField).first;
      await tester.tap(titleField);
      await tester.pump();
      await tester.enterText(titleField, 'Edited Title');
      await tester.pumpAndSettle();
      // Sanity-check the form is valid now
      final formFinder = find.byType(Form);
      expect(formFinder, findsOneWidget);
      final formState = tester.state<FormState>(formFinder);
      expect(formState.validate(), isTrue);
      await tester.tap(saveIcon);
      await tester.pumpAndSettle();
      expect(fakeRepo.lastUpdate, isNotNull);
      expect(
        fakeRepo.lastUpdate!['cover_url'],
        equals('https://example.com/cover.png'),
      );
    },
  );
}
