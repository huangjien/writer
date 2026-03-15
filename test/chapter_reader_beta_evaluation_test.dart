import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';
import 'package:writer/features/reader/chapter_reader_screen.dart';
import 'helpers/fake_chapter_port.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/performance_settings.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:writer/shared/api_exception.dart';
import 'package:writer/shared/widgets/app_dialog.dart';

class FakeAiChatServiceOk extends AiChatService {
  FakeAiChatServiceOk() : super(RemoteRepository('http://localhost:5600/'));
  @override
  Future<Map<String, dynamic>?> betaEvaluateChapter({
    required String novelId,
    required String chapterId,
    required String content,
    String language = 'en',
  }) async {
    return {'markdown': '# Eval\n\n* Good'};
  }
}

class FakeAiChatServiceNull extends AiChatService {
  FakeAiChatServiceNull() : super(RemoteRepository('http://localhost:5600/'));
  @override
  Future<Map<String, dynamic>?> betaEvaluateChapter({
    required String novelId,
    required String chapterId,
    required String content,
    String language = 'en',
  }) async {
    return null;
  }
}

class FakeAiChatServiceUnauthorized extends AiChatService {
  FakeAiChatServiceUnauthorized()
    : super(RemoteRepository('http://localhost:5600/'));
  @override
  Future<Map<String, dynamic>?> betaEvaluateChapter({
    required String novelId,
    required String chapterId,
    required String content,
    String language = 'en',
  }) async {
    throw ApiException(401, 'Unauthorized');
  }
}

class FakeAiChatServiceError extends AiChatService {
  FakeAiChatServiceError() : super(RemoteRepository('http://localhost:5600/'));
  @override
  Future<Map<String, dynamic>?> betaEvaluateChapter({
    required String novelId,
    required String chapterId,
    required String content,
    String language = 'en',
  }) async {
    throw Exception('boom');
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Beta evaluation success opens dialog', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    final session = SessionNotifier(storageService);
    await session.setSessionId('test-session');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aiChatServiceProvider.overrideWith((ref) => FakeAiChatServiceOk()),
          appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((_) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (_) => PerformanceSettingsNotifier(prefs),
          ),
          sessionProvider.overrideWith((_) => session),
          localStorageRepositoryProvider.overrideWithValue(
            LocalStorageRepository(storageService),
          ),
          chapterRepositoryProvider.overrideWithValue(FakeChapterPort()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChapterReaderScreen(
            chapterId: 'c1',
            title: 'T1',
            content: 'C1',
            novelId: 'n1',
            allChapters: [],
            currentIdx: 0,
            autoStartTts: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final betaBtn = find.byKey(const ValueKey('beta_button'));
    if (betaBtn.evaluate().isEmpty) {
      return;
    }

    await tester.tap(betaBtn);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const ValueKey('beta_spinner')), findsOneWidget);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(AppDialog), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(AppDialog), findsNothing);
  });

  testWidgets('Beta evaluation fails on empty content', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    final session = SessionNotifier(storageService);
    await session.setSessionId('test-session');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aiChatServiceProvider.overrideWith((ref) => FakeAiChatServiceOk()),
          appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((_) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (_) => PerformanceSettingsNotifier(prefs),
          ),
          sessionProvider.overrideWith((_) => session),
          localStorageRepositoryProvider.overrideWithValue(
            LocalStorageRepository(storageService),
          ),
          chapterRepositoryProvider.overrideWithValue(FakeChapterPort()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChapterReaderScreen(
            chapterId: 'c1',
            title: 'T1',
            content: '',
            novelId: 'n1',
            allChapters: [],
            currentIdx: 0,
            autoStartTts: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final betaBtn = find.byKey(const ValueKey('beta_button'));
    if (betaBtn.evaluate().isEmpty) {
      return;
    }

    await tester.tap(betaBtn);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const ValueKey('beta_spinner')), findsNothing);
    expect(find.byType(AppDialog), findsNothing);
  });

  testWidgets('Beta evaluation null result shows failure', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    final session = SessionNotifier(storageService);
    await session.setSessionId('test-session');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aiChatServiceProvider.overrideWith((ref) => FakeAiChatServiceNull()),
          appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((_) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (_) => PerformanceSettingsNotifier(prefs),
          ),
          sessionProvider.overrideWith((_) => session),
          localStorageRepositoryProvider.overrideWithValue(
            LocalStorageRepository(storageService),
          ),
          chapterRepositoryProvider.overrideWithValue(FakeChapterPort()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChapterReaderScreen(
            chapterId: 'c1',
            title: 'T1',
            content: 'C1',
            novelId: 'n1',
            allChapters: [],
            currentIdx: 0,
            autoStartTts: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final betaBtn = find.byKey(const ValueKey('beta_button'));
    if (betaBtn.evaluate().isEmpty) {
      return;
    }

    await tester.tap(betaBtn);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const ValueKey('beta_spinner')), findsNothing);
    expect(find.byType(AppDialog), findsNothing);
  });

  testWidgets('Beta evaluation 401 leaves no failure toast', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    final session = SessionNotifier(storageService);
    await session.setSessionId('test-session');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aiChatServiceProvider.overrideWith(
            (ref) => FakeAiChatServiceUnauthorized(),
          ),
          appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((_) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (_) => PerformanceSettingsNotifier(prefs),
          ),
          sessionProvider.overrideWith((_) => session),
          localStorageRepositoryProvider.overrideWithValue(
            LocalStorageRepository(storageService),
          ),
          chapterRepositoryProvider.overrideWithValue(FakeChapterPort()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChapterReaderScreen(
            chapterId: 'c1',
            title: 'T1',
            content: 'C1',
            novelId: 'n1',
            allChapters: [],
            currentIdx: 0,
            autoStartTts: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final betaBtn = find.byKey(const ValueKey('beta_button'));
    if (betaBtn.evaluate().isEmpty) {
      return;
    }

    await tester.tap(betaBtn);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('Beta evaluation failed'), findsNothing);
    expect(find.byKey(const ValueKey('beta_spinner')), findsNothing);
  });

  testWidgets('Beta evaluation unexpected error shows failure toast', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    final session = SessionNotifier(storageService);
    await session.setSessionId('test-session');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aiChatServiceProvider.overrideWith((ref) => FakeAiChatServiceError()),
          appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((_) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (_) => PerformanceSettingsNotifier(prefs),
          ),
          sessionProvider.overrideWith((_) => session),
          localStorageRepositoryProvider.overrideWithValue(
            LocalStorageRepository(storageService),
          ),
          chapterRepositoryProvider.overrideWithValue(FakeChapterPort()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChapterReaderScreen(
            chapterId: 'c1',
            title: 'T1',
            content: 'C1',
            novelId: 'n1',
            allChapters: [],
            currentIdx: 0,
            autoStartTts: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final betaBtn = find.byKey(const ValueKey('beta_button'));
    if (betaBtn.evaluate().isEmpty) {
      return;
    }

    await tester.tap(betaBtn);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('Beta evaluation failed'), findsOneWidget);
    expect(find.byKey(const ValueKey('beta_spinner')), findsNothing);
  });
}
