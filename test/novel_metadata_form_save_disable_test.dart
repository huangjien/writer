import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/features/reader/novel_metadata_editor.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'helpers/test_utils.dart';

class CapturingNovelRepository extends NovelRepository {
  CapturingNovelRepository() : super(RemoteRepository('http://example.com'));
  Map<String, dynamic>? lastUpdate;
  @override
  Future<Novel?> getNovel(String novelId) async {
    return const Novel(
      id: 'n-2',
      title: 'Another Novel',
      author: 'B. Author',
      description: 'Desc',
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
    'Save disabled when clean/invalid, enabled when dirty+valid, disables after save',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final fakeRepo = CapturingNovelRepository();

      final scope = await buildAppScope(
        extraOverrides: [
          novelRepositoryProvider.overrideWith((ref) => fakeRepo),
        ],
        child: materialAppFor(
          home: const Scaffold(body: NovelMetadataEditor(novelId: 'n-2')),
          locale: const Locale('en'),
        ),
      );

      await tester.pumpWidget(scope);
      await tester.pumpAndSettle();

      final coverField = find.widgetWithText(TextFormField, 'Cover URL');
      final saveTextFinder = find.text('Save');
      final saveButtonFinder = find.ancestor(
        of: saveTextFinder,
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      );
      expect(find.text('Cover URL'), findsOneWidget);

      expect(saveTextFinder, findsOneWidget);
      expect(saveButtonFinder, findsOneWidget);
      expect(
        tester.widget<ButtonStyleButton>(saveButtonFinder).onPressed,
        isNull,
        reason: 'Save should be disabled when nothing changed',
      );

      // Enter invalid URL -> Save disabled
      await tester.tap(coverField);
      await tester.pump();
      await tester.enterText(coverField, 'http://bad link');
      await tester.pumpAndSettle();
      expect(
        tester.widget<ButtonStyleButton>(saveButtonFinder).onPressed,
        isNull,
      );
      // Tap Save; invalid input should not call repo
      await tester.tap(saveButtonFinder);
      await tester.pump();
      expect(fakeRepo.lastUpdate, isNull);

      // Fix to valid URL -> Save enabled
      await tester.tap(coverField);
      await tester.pump();
      await tester.enterText(coverField, 'http://valid.example/cover.jpg');
      await tester.pumpAndSettle();
      // Nudge another field to ensure rebuild
      final titleField = find.widgetWithText(TextFormField, 'Title');
      await tester.tap(titleField);
      await tester.pump();
      await tester.enterText(titleField, 'Another Title');
      await tester.pumpAndSettle();
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();
      expect(fakeRepo.lastUpdate, isNotNull);
      expect(
        fakeRepo.lastUpdate!['cover_url'],
        equals('http://valid.example/cover.jpg'),
      );
      expect(
        tester.widget<ButtonStyleButton>(saveButtonFinder).onPressed,
        isNull,
        reason: 'Save should disable again after successful save',
      );

      // Clear the field -> optional (blank is allowed), Save enabled
      await tester.tap(coverField);
      await tester.pump();
      await tester.enterText(coverField, '');
      await tester.pumpAndSettle();
      expect(
        tester.widget<ButtonStyleButton>(saveButtonFinder).onPressed,
        isNotNull,
      );
      await tester.tap(saveButtonFinder);
      await tester.pump();
      expect(fakeRepo.lastUpdate, isNotNull);
      expect(fakeRepo.lastUpdate!['novelId'], equals('n-2'));
      expect(fakeRepo.lastUpdate!['cover_url'], isNull);
    },
  );
}
