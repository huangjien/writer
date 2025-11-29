import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/reader/chapter_reader_screen.dart';
import 'package:writer/features/reader/logic/tts_driver.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/edit_permissions.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:writer/theme/font_packs.dart';
import 'package:writer/theme/reader_background.dart';
import 'package:writer/theme/reader_typography.dart';
import 'package:writer/theme/themes.dart';

class MockTtsDriver extends Mock implements TtsDriver {}

class MockAppSettingsNotifier extends Mock implements AppSettingsNotifier {}

class MockThemeController extends Mock implements ThemeController {
  @override
  ThemeState get state => const ThemeState(
    mode: ThemeMode.system,
    family: AppThemeFamily.defaultFamily,
    hasSeparateDark: false,
    familyLight: AppThemeFamily.defaultFamily,
    familyDark: AppThemeFamily.defaultFamily,
    preset: ReaderTypographyPreset.system,
    hasSeparateTypography: false,
    presetLight: ReaderTypographyPreset.system,
    presetDark: ReaderTypographyPreset.system,
    fontPack: ReaderFontPack.system,
    customFontFamily: null,
    fontScale: 1.0,
    readerBgDepth: ReaderBackgroundDepth.medium,
  );
}

void main() {
  late MockTtsDriver mockTtsDriver;
  late SharedPreferences prefs;

  const novelId = 'novel-1';
  const chapterId = 'chapter-1';
  const chapterTitle = 'Test Chapter';
  const chapterContent = 'This is the content of the chapter.';

  setUp(() async {
    mockTtsDriver = MockTtsDriver();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    // Mock TtsDriver defaults
    when(
      () => mockTtsDriver.configure(
        voiceName: any(named: 'voiceName'),
        voiceLocale: any(named: 'voiceLocale'),
        defaultLocale: any(named: 'defaultLocale'),
        onProgress: any(named: 'onProgress'),
        onStart: any(named: 'onStart'),
        onCancel: any(named: 'onCancel'),
        onError: any(named: 'onError'),
        onAllComplete: any(named: 'onAllComplete'),
      ),
    ).thenAnswer((_) async {});

    when(() => mockTtsDriver.setRate(any())).thenAnswer((_) async {});
    when(() => mockTtsDriver.setVolume(any())).thenAnswer((_) async {});
    when(() => mockTtsDriver.stop()).thenAnswer((_) async {});
    when(() => mockTtsDriver.pause()).thenAnswer((_) async {});
    when(
      () => mockTtsDriver.start(
        content: any(named: 'content'),
        startIndex: any(named: 'startIndex'),
      ),
    ).thenAnswer((_) async {});

    // Mock properties
    when(() => mockTtsDriver.speaking).thenReturn(false);
    when(() => mockTtsDriver.index).thenReturn(0);
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    List overrides = const [],
    bool editPermission = true,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
          themeControllerProvider.overrideWith((_) => ThemeController(prefs)),
          ttsSettingsProvider.overrideWith((_) => TtsSettingsNotifier(prefs)),
          ttsDriverProvider.overrideWithValue(mockTtsDriver),
          editPermissionsProvider(
            novelId,
          ).overrideWith((_) async => editPermission),
          ...overrides,
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChapterReaderScreen(
            chapterId: chapterId,
            title: chapterTitle,
            content: chapterContent,
            novelId: novelId,
            allChapters: [],
            currentIdx: 0,
          ),
        ),
      ),
    );
  }

  testWidgets('ChapterReaderScreen renders title and content', (tester) async {
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text(chapterTitle), findsOneWidget);
    expect(find.text(chapterContent), findsOneWidget);
  });

  testWidgets('Play button starts TTS', (tester) async {
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    final playButton = find.byIcon(Icons.play_arrow);
    expect(playButton, findsOneWidget);

    await tester.tap(playButton);
    await tester.pump();

    verify(
      () => mockTtsDriver.start(
        content: any(named: 'content'),
        startIndex: any(named: 'startIndex'),
      ),
    ).called(1);
  });

  testWidgets('Shows bottom bar controls', (tester) async {
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.skip_previous), findsOneWidget);
    expect(find.byIcon(Icons.skip_next), findsOneWidget);
    expect(find.byIcon(Icons.speed), findsOneWidget);
    expect(find.byIcon(Icons.record_voice_over), findsOneWidget);
  });

  testWidgets('Edit button visible when permissions allow', (tester) async {
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit), findsOneWidget);
  });

  testWidgets('Edit button hidden when permissions deny', (tester) async {
    await pumpScreen(tester, editPermission: false);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit), findsNothing);
  });
}
