import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/features/reader/reader_screen.dart';

void main() {
  testWidgets('ChapterReaderScreen shows title, content, and Speak button', (
    tester,
  ) async {
    // Ensure SharedPreferences works in test via mock channel
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: SizedBox.shrink()),
        ),
      ),
    );

    // Pump the reader screen with simple content and no autostart.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChapterReaderScreen(
            chapterId: 'ch-1',
            title: 'Test Chapter',
            content: 'This is a short chapter content.',
            novelId: 'n-1',
            initialOffset: 0.0,
            initialTtsIndex: 0,
            allChapters: const [],
            currentIdx: 0,
            autoStartTts: false,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Test Chapter'), findsOneWidget);
    expect(find.text('This is a short chapter content.'), findsOneWidget);
    expect(find.byTooltip('Speak'), findsOneWidget);
    // No autoplay inline prompt by default
    expect(find.textContaining('Auto-play'), findsNothing);
  });
}
