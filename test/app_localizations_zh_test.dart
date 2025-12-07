import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations_zh.dart';

void main() {
  test('Chinese localizations basic strings and placeholders', () {
    final zh = AppLocalizationsZh();
    expect(zh.helloWorld, '你好世界！');
    expect(zh.settings, '设置');
    expect(zh.appTitle, '写手');
    expect(zh.readerBundles, '阅读主题预设');
    expect(zh.reduceMotion, '减少动效');
    expect(zh.reduceMotionDescription, '为舒适体验尽量减少动画');
    expect(zh.ttsVoice, 'TTS 语音');
    expect(zh.ttsSpeechRate, '语速');
    expect(zh.bundleNordCalm, 'Nord Calm');
    expect(zh.bundleSolarizedFocus, 'Solarized Focus');
    expect(zh.bundleHighContrastReadability, '高对比可读性');
    expect(zh.signedInAs('user@example.com'), '已登录为 user@example.com');
    expect(zh.ttsError('网络错误'), 'TTS 错误：网络错误');
    expect(zh.indexOutOfRange(1, 10), '索引必须在 1-10 之间');
    expect(zh.byAuthor('张三'), '作者：张三');
  });
}
