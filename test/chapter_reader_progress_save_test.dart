import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/progress_notifier.dart';
import 'package:writer/repositories/progress_port.dart';
import 'package:writer/features/reader/reader_screen.dart';
import 'package:writer/models/user_progress.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/tts_settings.dart';

class CapturingProgressPort implements ProgressPort {
  int saveCalls = 0;
  @override
  Future<void> upsertProgress(UserProgress progress) async {
    saveCalls += 1;
  }

  @override
  Future<UserProgress?> latestProgressForUser() async => null;

  @override
  Future<UserProgress?> lastProgressForNovel(String novelId) async => null;
}

void main() {
  const MethodChannel ttsChannel = MethodChannel('flutter_tts');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    // Make TTS calls no-op to avoid plugin dependencies in tests.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ttsChannel, (MethodCall call) async => null);
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ttsChannel, null);
  });

  testWidgets('Signed-in but no user: Stop does not call save', (tester) async {
    SharedPreferences.setMockInitialValues({'backend_session_id': 's-1'});

    final prefs = await SharedPreferences.getInstance();
    final appNotifier = AppSettingsNotifier(prefs);
    final fakeRepo = CapturingProgressPort();
    final session = SessionNotifier(prefs);
    final ttsSettings = TtsSettingsNotifier(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => appNotifier),
          progressRepositoryProvider.overrideWith((_) => fakeRepo),
          sessionProvider.overrideWith((_) => session),
          currentUserProvider.overrideWith((ref) async => null),
          ttsSettingsProvider.overrideWith((_) => ttsSettings),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChapterReaderScreen(
            chapterId: 'c1',
            title: 'Progress',
            content: 'Hello world. This is a chapter.',
            novelId: 'n1',
            autoStartTts: false,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byTooltip('Speak'), findsOneWidget);
    await tester.tap(find.byTooltip('Speak'));
    await tester.pump();
    expect(find.byTooltip('Stop TTS'), findsOneWidget);
    await tester.tap(find.byTooltip('Stop TTS'));
    await tester.pumpAndSettle();

    // Without an authenticated user, save should not be called.
    expect(fakeRepo.saveCalls, 0);
  });
}
