import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/features/reader/logic/edit_mode.dart';
import 'package:writer/features/reader/logic/edit_discard_dialog.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/repositories/chapter_port.dart';

class DummyChapterPort implements ChapterPort {
  @override
  Future<List<Chapter>> getChapters(String novelId) async => const [];
  @override
  Future<Chapter> getChapter(Chapter chapter) async => chapter;
  @override
  Future<void> updateChapter(Chapter chapter) async {}
  @override
  Future<int> getNextIdx(String novelId) async => 1;
  @override
  Future<Chapter> createChapter({
    required String novelId,
    required int idx,
    String? title,
    String? content,
  }) async {
    return Chapter(
      id: 'c$idx',
      novelId: novelId,
      idx: idx,
      title: title,
      content: content,
    );
  }

  @override
  Future<void> deleteChapter(String chapterId) async {}
}

void main() {
  testWidgets('isEditDirty returns false by default', (tester) async {
    final chapter = const Chapter(
      id: 'c1',
      novelId: 'n1',
      idx: 1,
      title: 'T',
      content: 'C',
    );
    bool? dirty;
    final app = ProviderScope(
      overrides: [
        chapterRepositoryProvider.overrideWithValue(DummyChapterPort()),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) {
              dirty = isEditDirty(ref, chapter);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    await tester.pumpWidget(app);
    expect(dirty, false);
  });

  testWidgets('showDiscardDialogBridge delegates to showDiscardDialog', (
    tester,
  ) async {
    final chapter = const Chapter(
      id: 'c1',
      novelId: 'n1',
      idx: 1,
      title: 'T',
      content: 'C',
    );
    DiscardDecision? decision;
    final app = ProviderScope(
      overrides: [
        chapterRepositoryProvider.overrideWithValue(DummyChapterPort()),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) {
              return ElevatedButton(
                onPressed: () async {
                  decision = await showDiscardDialogBridge(
                    context: context,
                    ref: ref,
                    current: chapter,
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpWidget(app);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final actionButtons = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextButton),
    );
    await tester.tap(actionButtons.at(0));
    await tester.pumpAndSettle();
    expect(decision, DiscardDecision.keepEditing);
  });
}
