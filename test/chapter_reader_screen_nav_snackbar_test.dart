import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/features/reader/chapter_reader_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';
import 'package:writer/state/ai_agent_settings.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/motion_settings.dart';

class FakeAiChatService extends AiChatService {
  FakeAiChatService() : super(RemoteRepository('http://localhost:5600/'));
  @override
  Future<bool> checkHealth() async => true;
  @override
  Future<String> sendMessage(
    String message, {
    AiAgentSettings? settings,
  }) async => 'ok';
}

void main() {
  const novelId = 'n1';
  // No local chapter list needed; pass constants directly to ChapterReaderScreen

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows snackbar when next pressed at last chapter', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final appSettings = AppSettingsNotifier(prefs);
    final ttsSettings = TtsSettingsNotifier(prefs);
    final motion = MotionSettingsNotifier(prefs);
    final storageService = LocalStorageService(prefs);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWithValue(
            LocalStorageRepository(storageService),
          ),
          sessionProvider.overrideWith(
            (ref) => SessionNotifier(storageService),
          ),
          aiChatServiceProvider.overrideWith((ref) => FakeAiChatService()),
          appSettingsProvider.overrideWith((ref) => appSettings),
          ttsSettingsProvider.overrideWith((ref) => ttsSettings),
          motionSettingsProvider.overrideWith((ref) => motion),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChapterReaderScreen(
            chapterId: 'c2',
            title: 'T2',
            content: 'C2',
            novelId: novelId,
            allChapters: [
              Chapter(
                id: 'c1',
                novelId: novelId,
                idx: 1,
                title: 'T1',
                content: 'C1',
              ),
              Chapter(
                id: 'c2',
                novelId: novelId,
                idx: 2,
                title: 'T2',
                content: 'C2',
              ),
            ],
            currentIdx: 1,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('reader_bottom_bar')), findsOneWidget);
    expect(find.byIcon(Icons.skip_next), findsOneWidget);
    await tester.tap(find.byIcon(Icons.skip_next));
    await tester.pump();
    final l10n = AppLocalizations.of(
      tester.element(find.byType(ChapterReaderScreen)),
    )!;
    expect(find.text(l10n.reachedLastChapter), findsOneWidget);
  });

  testWidgets('shows snackbar when prev pressed at first chapter', (
    tester,
  ) async {
    final prefs2 = await SharedPreferences.getInstance();
    final appSettings = AppSettingsNotifier(prefs2);
    final ttsSettings = TtsSettingsNotifier(prefs2);
    final motion = MotionSettingsNotifier(prefs2);
    final storageService = LocalStorageService(prefs2);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs2),
          localStorageRepositoryProvider.overrideWithValue(
            LocalStorageRepository(storageService),
          ),
          sessionProvider.overrideWith(
            (ref) => SessionNotifier(storageService),
          ),
          aiChatServiceProvider.overrideWith((ref) => FakeAiChatService()),
          appSettingsProvider.overrideWith((ref) => appSettings),
          ttsSettingsProvider.overrideWith((ref) => ttsSettings),
          motionSettingsProvider.overrideWith((ref) => motion),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChapterReaderScreen(
            chapterId: 'c1',
            title: 'T1',
            content: 'C1',
            novelId: novelId,
            allChapters: [
              Chapter(
                id: 'c1',
                novelId: novelId,
                idx: 1,
                title: 'T1',
                content: 'C1',
              ),
              Chapter(
                id: 'c2',
                novelId: novelId,
                idx: 2,
                title: 'T2',
                content: 'C2',
              ),
            ],
            currentIdx: 0,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('reader_bottom_bar')), findsOneWidget);
    expect(find.byIcon(Icons.skip_previous), findsOneWidget);
    await tester.tap(find.byIcon(Icons.skip_previous));
    await tester.pump();
    final l10n = AppLocalizations.of(
      tester.element(find.byType(ChapterReaderScreen)),
    )!;
    expect(find.text(l10n.reachedFirstChapter), findsOneWidget);
  });
}
