import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/features/reader/widgets/reader_edit_actions.dart';
import 'package:writer/repositories/chapter_port.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/state/chapter_edit_controller.dart';

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

  @override
  Future<void> updateChapterIdx(String chapterId, int newIdx) async {}

  @override
  Future<void> bulkShiftIdx(String novelId, int fromIdx, int delta) async {}
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

    final container = ProviderContainer(
      overrides: [chapterRepositoryProvider.overrideWithValue(port)],
    );
    addTearDown(container.dispose);

    final app = UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ReaderEditActions(
            current: current,
            previewMode: false,
            onTogglePreview: _noop,
            onCreated: (_) {},
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

    // Save should be disabled initially
    await tester.tap(find.byIcon(Icons.save));
    await tester.pump();
    expect(port.saved, isFalse);

    // Make dirty
    final controller = container.read(
      chapterEditControllerProvider(current).notifier,
    );
    controller.setContent('New content');
    await tester.pump();

    // Now save should work
    await tester.tap(find.byIcon(Icons.save));
    await tester.pump();
    expect(port.saved, isTrue);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(port.created, isTrue);

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pump();
    expect(port.deleted, isTrue);
  });
}

void _noop() {}
