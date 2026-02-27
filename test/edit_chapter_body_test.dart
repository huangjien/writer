import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/features/reader/widgets/edit_chapter_body.dart';
import 'package:writer/features/reader/widgets/preview_panel.dart';
import 'package:writer/state/edit_permissions.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'helpers/fake_chapter_port.dart';

void main() {
  testWidgets('EditChapterBody shows form and owner metadata', (tester) async {
    const chapter = Chapter(
      id: 'c1',
      novelId: 'n1',
      idx: 1,
      title: 'One',
      content: 'Alpha\nBeta',
    );
    final app = ProviderScope(
      overrides: [
        editRoleProvider.overrideWith((ref, novelId) async => EditRole.owner),
        chapterRepositoryProvider.overrideWithValue(FakeChapterPort()),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: EditChapterBody(
            novelId: 'n1',
            current: chapter,
            previewMode: false,
          ),
        ),
      ),
    );

    await tester.pumpWidget(app);
    await tester.pump();

    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.text('Chapter Title'), findsOneWidget);
    expect(find.text('Chapter Content'), findsOneWidget);
    expect(find.byType(Scrollable), findsWidgets);
  });

  testWidgets('EditChapterBody shows PreviewPanel when previewMode true', (
    tester,
  ) async {
    const chapter = Chapter(
      id: 'c1',
      novelId: 'n1',
      idx: 1,
      title: 'One',
      content: 'Alpha\nBeta',
    );
    final app = ProviderScope(
      overrides: [
        chapterRepositoryProvider.overrideWithValue(FakeChapterPort()),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: EditChapterBody(
            novelId: 'n1',
            current: chapter,
            previewMode: true,
          ),
        ),
      ),
    );

    await tester.pumpWidget(app);
    await tester.pump();

    expect(find.byType(PreviewPanel), findsOneWidget);
  });
}
