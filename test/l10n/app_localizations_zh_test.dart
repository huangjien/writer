import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

void main() {
  test('Basic zh strings', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    expect(l10n.settings, '设置');
    expect(l10n.appTitle, '写手');
    expect(l10n.supabaseSettings, 'Supabase 设置');
    expect(l10n.supabaseNotEnabled, 'Supabase 未启用');
    expect(l10n.fetchFromSupabase, '从 Supabase 获取');
    expect(l10n.confirmFetch, '确认获取');
    expect(l10n.cancel, '取消');
    expect(l10n.fetch, '获取');
    expect(l10n.ttsSettings, 'TTS 设置');
    expect(l10n.ttsSpeechRate, '语速');
    expect(l10n.ttsSpeechVolume, '音量');
    expect(l10n.themeMode, '主题模式');
    expect(l10n.system, '跟随系统');
    expect(l10n.light, '浅色');
    expect(l10n.dark, '深色');
  });

  test('Placeholders zh', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    expect(l10n.signedInAs('user@example.com'), '已登录为 user@example.com');
    expect(l10n.continueAtChapter('Chapter 5'), '继续阅读章节 • Chapter 5');
    expect(l10n.novelsAndProgressSummary(3, '75%'), '小说: 3, 进度: 75%');
    expect(l10n.indexLabel(7), '第 7 章');
    expect(l10n.ttsError('网络错误'), 'TTS 错误：网络错误');
    expect(l10n.confirmDeleteDescription('我的小说'), '将从 Supabase 删除“我的小说”。是否确认？');
  });
}
