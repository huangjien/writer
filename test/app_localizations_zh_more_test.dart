import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations_zh.dart';

void main() {
  test('basic strings non-empty', () {
    final l10n = AppLocalizationsZh();
    expect(l10n.helloWorld.isNotEmpty, true);
    expect(l10n.settings.isNotEmpty, true);
    expect(l10n.appTitle.isNotEmpty, true);
    expect(l10n.about.isNotEmpty, true);
  });

  test('formatters produce expected output', () {
    final l10n = AppLocalizationsZh();
    expect(l10n.signedInAs('a@b.c'), '已登录为 a@b.c');
    expect(l10n.continueAtChapter('T'), '继续阅读章节 • T');
    expect(l10n.byAuthor('A'), '作者：A');
    expect(l10n.pageOfTotal(2, 10), '第2/10页');
    expect(l10n.indexLabel(3), '第 3 章');
    expect(l10n.indexOutOfRange(1, 9), '索引必须在 1-9 之间');
    expect(l10n.ttsError('X'), 'TTS 错误：X');
    expect(l10n.novelsAndProgressSummary(5, 'ok'), '小说: 5, 进度: ok');
    expect(l10n.languageLabel('zh'), '语言：zh');
    expect(l10n.chaptersCount(2), '章节：2');
    expect(l10n.avgWordsPerChapter(800), '平均每章字数：800');
    expect(l10n.chapterLabel(4), '第4章');
    expect(l10n.chapterWithTitle(1, 'X'), '第1章：X');
    expect(l10n.confirmDeleteDescription('T'), '将从 Supabase 删除“T”。是否确认？');
  });
}
