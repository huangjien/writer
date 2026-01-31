import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/reader/reader_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/mock_providers.dart';
import 'package:writer/state/novel_providers_v2.dart';
import 'package:writer/features/ai_chat/state/ai_chat_providers.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/state/providers.dart';

void main() {
  const novelId = 'n1';
  final mockChapters = [
    const Chapter(id: 'c1', novelId: novelId, idx: 1, title: 'A', content: 'X'),
    const Chapter(id: 'c2', novelId: novelId, idx: 2, title: 'B', content: 'Y'),
  ];

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('chapterId path shows loading spinner', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
          themeControllerProvider.overrideWith((_) => ThemeController(prefs)),
          sharedPreferencesProvider.overrideWithValue(prefs),
          isSignedInProvider.overrideWith((_) => true),
          authStateProvider.overrideWith((_) => 'test-session'),
          currentUserProvider.overrideWith((_) async => null),
          aiChatUiProvider.overrideWith((_) => AiChatUiNotifier()),
          mockChaptersProvider(novelId).overrideWith(
            (ref) =>
                Future.delayed(const Duration(seconds: 1), () => mockChapters),
          ),
          chaptersProviderV2(novelId).overrideWith(
            (ref) =>
                Future.delayed(const Duration(seconds: 1), () => mockChapters),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ReaderScreen(novelId: novelId, chapterId: 'c2'),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('chapterId path shows error message', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
          themeControllerProvider.overrideWith((_) => ThemeController(prefs)),
          sharedPreferencesProvider.overrideWithValue(prefs),
          isSignedInProvider.overrideWith((_) => true),
          authStateProvider.overrideWith((_) => 'test-session'),
          currentUserProvider.overrideWith((_) async => null),
          aiChatUiProvider.overrideWith((_) => AiChatUiNotifier()),
          mockChaptersProvider(
            novelId,
          ).overrideWith((ref) => Future.error('Load failed')),
          chaptersProviderV2(
            novelId,
          ).overrideWith((ref) => Future.error('Load failed')),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ReaderScreen(novelId: novelId, chapterId: 'c2'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Error:'), findsOneWidget);
  });
}
