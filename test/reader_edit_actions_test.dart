import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/l10n/app_localizations.dart';
import 'package:novel_reader/models/chapter.dart';
import 'package:novel_reader/features/reader/widgets/reader_edit_actions.dart';
import 'package:novel_reader/repositories/chapter_port.dart';
import 'package:novel_reader/repositories/chapter_repository.dart';

class CapturingChapterPort implements ChapterPort {
  bool saved = false;
  bool created = false;
  bool deleted = false;
  @override
  Future<List<Chapter>> getChapters(String novelId) async => const [];
  @override
  Future<Chapter> getChapter(Chapter chapter) async => chapter;
  @override
  Future<void> updateChapter(Chapter chapter) async {
    saved = true;
  }

  @override
  Future<int> getNextIdx(String novelId) async => 2;
  @override
  Future<Chapter> createChapter({
    required String novelId,
    required int idx,
    String? title,
    String? content,
  }) async {
    created = true;
    return Chapter(
      id: 'c-$idx',
      novelId: novelId,
      idx: idx,
      title: title,
      content: content,
    );
  }

  @override
  Future<void> deleteChapter(String chapterId) async {
    deleted = true;
  }
}

void main() {
  testWidgets('ReaderEditActions triggers save/create/delete', (tester) async {
    final port = CapturingChapterPort();
    final current = const Chapter(
      id: 'c1',
      novelId: 'n1',
      idx: 1,
      title: 'One',
      content: 'Alpha',
    );

    final app = ProviderScope(
      overrides: [chapterRepositoryProvider.overrideWithValue(port)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ReaderEditActions(
            current: current,
            previewMode: false,
            onTogglePreview: _noop,
            isCompact: true,
            isWideForEdit: false,
            spacing: 8,
            iconSize: 20,
          ),
        ),
      ),
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.save));
    await tester.pump();
    expect(port.saved, isTrue);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(port.created, isTrue);

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();
    expect(port.deleted, isTrue);
  });
}

void _noop() {}
