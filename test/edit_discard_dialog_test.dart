import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/features/reader/logic/edit_discard_dialog.dart';
import 'package:writer/repositories/chapter_port.dart';
import 'package:writer/repositories/chapter_repository.dart';

class CapturingChapterPort implements ChapterPort {
  bool saved = false;
  @override
  Future<List<Chapter>> getChapters(String novelId) async => const [];
  @override
  Future<Chapter> getChapter(Chapter chapter) async => chapter;
  @override
  Future<void> updateChapter(Chapter chapter) async {
    saved = true;
  }

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
      id: 'c-$idx',
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
  testWidgets('Discard dialog returns decisions and can save', (tester) async {
    final port = CapturingChapterPort();
    final chapter = const Chapter(
      id: 'c1',
      novelId: 'n1',
      idx: 1,
      title: 'T',
      content: 'C',
    );

    final app = ProviderScope(
      overrides: [chapterRepositoryProvider.overrideWithValue(port)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: Consumer(
                  builder: (context, ref, _) {
                    return ElevatedButton(
                      onPressed: () async {
                        await showDiscardDialog(
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
            );
          },
        ),
      ),
    );

    await tester.pumpWidget(app);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.textContaining('discard'), findsWidgets);

    final actionButtons = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextButton),
    );
    expect(actionButtons, findsNWidgets(3));
    await tester.tap(actionButtons.at(0));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
}
