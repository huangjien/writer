import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations_zh.dart';

void main() {
  test('basic strings non-empty', () {
    final l10n = AppLocalizationsZh();
    expect(l10n.helloWorld.isNotEmpty, true);
    expect(l10n.settings.isNotEmpty, true);
    expect(l10n.appTitle.isNotEmpty, true);
    expect(l10n.about.isNotEmpty, true);
    expect(l10n.prompts.isNotEmpty, true);
    expect(l10n.patterns.isNotEmpty, true);
    expect(l10n.storyLines.isNotEmpty, true);
    expect(l10n.noPrompts.isNotEmpty, true);
    expect(l10n.noPatterns.isNotEmpty, true);
    expect(l10n.noStoryLines.isNotEmpty, true);
    expect(l10n.profileRetrieved.isNotEmpty, true);
    expect(l10n.noProfileFound.isNotEmpty, true);
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
    expect(l10n.confirmDeleteDescription('T'), '将从云端删除“T”。是否确认？');
    expect(l10n.deletedWithTitle('T'), '已删除：T');
    expect(l10n.deleteFailedWithTitle('T'), '删除失败：T');
    expect(l10n.deleteErrorWithMessage('E'), '删除出错：E');
    expect(l10n.retrieveFailed('E'), '获取失败：E');
    expect(l10n.conversionFailed('E'), '转换失败：E');
    expect(l10n.showingCachedPublicData('M'), 'M — 显示缓存/公共数据');
    expect(l10n.charsCount(12), '字符数：12');
    expect(l10n.deletePromptConfirm('k', 'zh'), '删除提示词 "k"（zh）？');
    expect(l10n.makePublicPromptConfirm('k', 'zh'), '将提示 "k"（zh）设为公开？');
  });
}
