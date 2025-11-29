import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/mock_providers.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/features/reader/reader_screen.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/supabase_config.dart';

void main() {
  testWidgets(
    'ReaderScreen lists chapters and navigates to ChapterReaderScreen',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final chapters = <Chapter>[
        const Chapter(
          id: 'c1',
          novelId: 'n1',
          idx: 1,
          title: 'Intro',
          content: 'First paragraph.',
        ),
        const Chapter(
          id: 'c2',
          novelId: 'n1',
          idx: 2,
          title: null,
          content: 'Second content.',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
            if (supabaseEnabled)
              chaptersProvider.overrideWith((ref, novelId) async => chapters)
            else
              mockChaptersProvider.overrideWith(
                (ref, novelId) async => chapters,
              ),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ReaderScreen(novelId: 'n1'),
          ),
        ),
      );

      // Allow async provider to resolve
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(find.text('Intro'), findsOneWidget);
      expect(find.text('Chapter 2'), findsOneWidget);

      // Tap first chapter to navigate
      await tester.tap(find.text('Intro'));
      await tester.pumpAndSettle();

      // New screen shows content
      expect(find.text('First paragraph.'), findsOneWidget);
      expect(find.byTooltip('Speak'), findsOneWidget);
    },
  );
}
