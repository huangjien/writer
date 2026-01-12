import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/features/reader/novel_metadata_editor.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/edit_permissions.dart';

class MockNovelRepository extends Mock implements NovelRepository {}

void main() {
  late MockNovelRepository mockNovelRepository;

  setUp(() {
    mockNovelRepository = MockNovelRepository();
  });

  testWidgets('description text field alignment check', (tester) async {
    final novel = Novel(
      id: 'novel-1',
      title: 'Test Novel',
      author: 'author-1',
      description: 'Test Description',
      languageCode: 'en',
      isPublic: true,
    );

    when(
      () => mockNovelRepository.getNovel('novel-1'),
    ).thenAnswer((_) async => novel);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelRepositoryProvider.overrideWithValue(mockNovelRepository),
          novelProvider('novel-1').overrideWith((ref) async => novel),
          editRoleProvider(
            'novel-1',
          ).overrideWith((ref) async => EditRole.owner),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: NovelMetadataEditor(novelId: 'novel-1')),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final tile = find.byType(ExpansionTile);
    expect(tile, findsOneWidget);
    await tester.tap(tile);
    await tester.pumpAndSettle();

    // Find the TextField with minLines 3 (which is likely the description field)
    final textFieldFinder = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.minLines == 3,
    );

    expect(textFieldFinder, findsOneWidget);

    final TextField textField = tester.widget(textFieldFinder);
    expect(textField.textAlign, TextAlign.start);
  });
}
