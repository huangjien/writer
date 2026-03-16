import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/reader/chapter_reader_screen.dart';
import 'package:writer/features/reader/state/reader_session_notifier.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/features/ai_chat/state/ai_chat_providers.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/state/edit_permissions.dart';
import 'package:writer/features/reader/widgets/reader_bottom_bar_shell.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:writer/features/reader/logic/tts_driver.dart';

class MockReaderSessionNotifier extends Mock implements ReaderSessionNotifier {}

class MockAiContextNotifier extends Mock implements AiContextNotifier {}

class MockThemeController extends Mock implements ThemeController {}

class MockTtsDriver extends Mock implements TtsDriver {}

void main() {
  late MockReaderSessionNotifier mockSessionNotifier;
  late MockAiContextNotifier mockAiContext;
  late MockTtsDriver mockTtsDriver;

  setUp(() {
    mockSessionNotifier = MockReaderSessionNotifier();
    mockAiContext = MockAiContextNotifier();
    mockTtsDriver = MockTtsDriver();

    // Default stubs
    when(() => mockSessionNotifier.loadInitial()).thenAnswer((_) async {});
    when(
      () => mockSessionNotifier.updateScrollProgress(any()),
    ).thenReturn(null);
    when(
      () => mockAiContext.setContextDelegate(
        type: any(named: 'type'),
        loader: any(named: 'loader'),
      ),
    ).thenReturn(null);
    when(() => mockAiContext.clearContextDelegate()).thenReturn(null);
    when(() => mockTtsDriver.stop()).thenAnswer((_) async {});
    when(
      () => mockTtsDriver.configure(
        voiceName: any(named: 'voiceName'),
        voiceLocale: any(named: 'voiceLocale'),
        defaultLocale: any(named: 'defaultLocale'),
      ),
    ).thenAnswer((_) async {});
  });

  Widget buildApp(
    Widget child, {
    bool includeTts = false,
    SharedPreferences? prefs,
  }) {
    return ProviderScope(
      overrides: [
        aiContextProvider.overrideWith((_) => mockAiContext),
        // Mock edit permissions to allow rendering bottom bar without error
        editPermissionsProvider('n1').overrideWith((_) => Future.value(true)),
        if (includeTts && prefs != null) ...[
          ttsDriverProvider.overrideWith((_) => mockTtsDriver),
          appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((_) => TtsSettingsNotifier(prefs)),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets('renders chapter content', (tester) async {
    // Need TTS providers because ReaderSessionNotifier initializes them
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      buildApp(
        const ChapterReaderScreen(
          chapterId: 'c1',
          title: 'Chapter 1',
          content: 'This is the content.',
          novelId: 'n1',
        ),
        includeTts: true,
        prefs: prefs,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chapter 1'), findsOneWidget);
    expect(find.text('This is the content.'), findsOneWidget);
  });

  testWidgets('initializes context delegate on load', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      buildApp(
        const ChapterReaderScreen(
          chapterId: 'c1',
          title: 'Chapter 1',
          content: 'Content',
          novelId: 'n1',
        ),
        includeTts: true,
        prefs: prefs,
      ),
    );
    await tester.pumpAndSettle();

    verify(
      () => mockAiContext.setContextDelegate(
        type: 'chapter',
        loader: any(named: 'loader'),
      ),
    ).called(1);
  });

  testWidgets('handles scroll progress update', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      buildApp(
        const ChapterReaderScreen(
          chapterId: 'c1',
          title: 'Chapter 1',
          content:
              'Line 1\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nLine 2\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nLine 3',
          novelId: 'n1',
        ),
        includeTts: true,
        prefs: prefs,
      ),
    );
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable);
    expect(scrollable, findsOneWidget);

    await tester.drag(scrollable, const Offset(0, -100));
    await tester.pumpAndSettle();
  });

  testWidgets('shows bottom bar', (tester) async {
    // We mock SharedPrefs to provide defaults for ThemeController
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // We use a real ThemeController to avoid mocking issues with complex state/getters
    final realThemeController = ThemeController(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aiContextProvider.overrideWith((_) => mockAiContext),
          editPermissionsProvider('n1').overrideWith((_) => Future.value(true)),
          themeControllerProvider.overrideWith((_) => realThemeController),
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsDriverProvider.overrideWith((_) => mockTtsDriver),
          appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((_) => TtsSettingsNotifier(prefs)),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ChapterReaderScreen(
              chapterId: 'c1',
              title: 'Chapter 1',
              content: 'Content',
              novelId: 'n1',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ReaderBottomBarShell), findsOneWidget);
  });
}
