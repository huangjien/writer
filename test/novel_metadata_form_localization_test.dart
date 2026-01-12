import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/features/reader/novel_metadata_editor.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'helpers/test_utils.dart';

class CapturingNovelRepository extends NovelRepository {
  CapturingNovelRepository() : super(RemoteRepository('http://localhost'));
  @override
  Future<Novel?> getNovel(String novelId) async {
    return const Novel(
      id: 'n-3',
      title: '本地化小说',
      author: '作者',
      description: '描述',
      coverUrl: null,
      languageCode: 'zh',
      isPublic: true,
    );
  }
}

void main() {
  testWidgets('Description and Cover URL labels are localized in zh', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final fakeRepo = CapturingNovelRepository();
    final scope = await buildAppScope(
      extraOverrides: [novelRepositoryProvider.overrideWith((ref) => fakeRepo)],
      child: materialAppFor(
        home: const Scaffold(body: NovelMetadataEditor(novelId: 'n-3')),
        locale: const Locale('zh'),
      ),
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    final tile = find.byType(ExpansionTile);
    expect(tile, findsOneWidget);
    await tester.tap(tile);
    await tester.pumpAndSettle();

    // Verify localized labels are shown (labels render via InputDecorator)
    expect(find.text('描述'), findsAtLeastNWidgets(1));
    expect(find.text('封面链接'), findsAtLeastNWidgets(1));
  });
}
