import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:novel_reader/l10n/app_localizations.dart';
import 'package:novel_reader/features/reader/reader_screen.dart';
import 'package:novel_reader/state/motion_settings.dart';

void main() {
  const MethodChannel ttsChannel = MethodChannel('flutter_tts');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ttsChannel, (MethodCall call) async => null);
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ttsChannel, null);
  });

  testWidgets('Reader bar AnimatedSwitcher honors Reduce Motion', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reduce_motion_enabled', true);
    final motion = MotionSettingsNotifier(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [motionSettingsProvider.overrideWith((_) => motion)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChapterReaderScreen(
            chapterId: 'c1',
            title: 'Test Chapter',
            content: 'Hello world.',
            novelId: 'n1',
            autoStartTts: false,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final switcherFinder = find.byKey(
      const ValueKey('reader_bar_play_switcher'),
    );
    expect(switcherFinder, findsOneWidget);
    final switcher = tester.widget<AnimatedSwitcher>(switcherFinder);
    expect(switcher.duration, Duration.zero);
    expect(switcher.switchInCurve, Curves.linear);
    expect(switcher.switchOutCurve, Curves.linear);
  });
}
