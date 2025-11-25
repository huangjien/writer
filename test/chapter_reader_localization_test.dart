import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/features/reader/reader_screen.dart';

void main() {
  testWidgets('ChapterReaderScreen shows Speak label in zh locale', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final appSettings = AppSettingsNotifier(prefs);
    appSettings.setLanguage('zh');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appSettingsProvider.overrideWith((_) => appSettings)],
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChapterReaderScreen(
            chapterId: 'c1',
            title: '测试章节',
            content: '你好世界。',
            novelId: 'n1',
            autoStartTts: false,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Chinese translation appears via Tooltip/Semantics label
    expect(find.byTooltip('朗读'), findsOneWidget);
    expect(find.text('测试章节'), findsOneWidget);
    expect(find.text('你好世界。'), findsOneWidget);
  });
}
