import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/features/reader/logic/edit_discard_dialog.dart';
import 'package:writer/state/chapter_edit_controller.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/repositories/chapter_port.dart';

class OkChapterRepo implements ChapterPort {
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
  }) async => Chapter(
    id: 'c$idx',
    novelId: novelId,
    idx: idx,
    title: title,
    content: content,
  );
  @override
  Future<void> deleteChapter(String chapterId) async {}
  @override
  Future<void> updateChapterIdx(String chapterId, int newIdx) async {}

  @override
  Future<void> bulkShiftIdx(String novelId, int fromIdx, int delta) async {}
}

class FailingChapterRepo implements ChapterPort {
  @override
  Future<List<Chapter>> getChapters(String novelId) async => const [];
  @override
  Future<Chapter> getChapter(Chapter chapter) async => chapter;
  @override
  Future<void> updateChapter(Chapter chapter) async => throw Exception('boom');
  @override
  Future<int> getNextIdx(String novelId) async => 1;
  @override
  Future<Chapter> createChapter({
    required String novelId,
    required int idx,
    String? title,
    String? content,
  }) async => Chapter(
    id: 'c$idx',
    novelId: novelId,
    idx: idx,
    title: title,
    content: content,
  );
  @override
  Future<void> deleteChapter(String chapterId) async {}
  @override
  Future<void> updateChapterIdx(String chapterId, int newIdx) async {}

  @override
  Future<void> bulkShiftIdx(String novelId, int fromIdx, int delta) async {}
}

void main() {
  final chapter = const Chapter(
    id: 'c1',
    novelId: 'n1',
    idx: 1,
    title: 'T',
    content: 'C',
  );

  Widget buildHost({
    required ChapterPort repo,
    required void Function(BuildContext, WidgetRef) onOpen,
  }) {
    return ProviderScope(
      overrides: [chapterRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) {
              ref.watch(chapterEditControllerProvider(chapter));
              return Center(
                child: ElevatedButton(
                  onPressed: () => onOpen(context, ref),
                  child: const Text('Open'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  testWidgets('Keep editing returns decision', (tester) async {
    DiscardDecision? result;
    final host = buildHost(
      repo: OkChapterRepo(),
      onOpen: (context, ref) async {
        result = await showDiscardDialog(
          context: context,
          ref: ref,
          current: chapter,
        );
      },
    );
    await tester.pumpWidget(host);
    await tester.tap(find.text('Open'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.widgetWithText(TextButton, 'Keep editing'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(result, DiscardDecision.keepEditing);
  });

  testWidgets('Discard changes returns decision', (tester) async {
    DiscardDecision? result;
    final host = buildHost(
      repo: OkChapterRepo(),
      onOpen: (context, ref) async {
        result = await showDiscardDialog(
          context: context,
          ref: ref,
          current: chapter,
        );
      },
    );
    await tester.pumpWidget(host);
    await tester.tap(find.text('Open'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.widgetWithText(TextButton, 'Discard changes'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(result, DiscardDecision.discard);
  });

  testWidgets('Save & Exit returns decision when save succeeds', (
    tester,
  ) async {
    DiscardDecision? result;
    final host = buildHost(
      repo: OkChapterRepo(),
      onOpen: (context, ref) async {
        result = await showDiscardDialog(
          context: context,
          ref: ref,
          current: chapter,
        );
      },
    );
    await tester.pumpWidget(host);
    await tester.tap(find.text('Open'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.widgetWithText(TextButton, 'Save & Exit'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(result, DiscardDecision.saveAndExit);
  });

  testWidgets('Save & Exit shows snackbar and keeps dialog when save fails', (
    tester,
  ) async {
    DiscardDecision? result;
    final host = buildHost(
      repo: FailingChapterRepo(),
      onOpen: (context, ref) async {
        result = await showDiscardDialog(
          context: context,
          ref: ref,
          current: chapter,
        );
      },
    );
    await tester.pumpWidget(host);
    await tester.tap(find.text('Open'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.widgetWithText(TextButton, 'Save & Exit'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(result, isNull);
    expect(find.byType(AlertDialog), findsOneWidget);
  });
}
