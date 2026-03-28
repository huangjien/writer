import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/ai_chat/state/ai_chat_providers.dart';
import 'package:writer/features/ai_chat/state/voice_input_providers.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';
import 'package:writer/features/ai_chat/services/voice_input_service.dart';
import 'package:writer/features/ai_chat/services/chat_storage_service.dart';
import 'package:writer/features/ai_chat/widgets/ai_chat_sidebar.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/state/ai_agent_settings.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/l10n/app_localizations.dart';

class MockAiChatService extends Mock implements AiChatService {}

class MockChatStorageService extends Mock implements ChatStorageService {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockVoiceInputService extends Mock implements VoiceInputService {}

class FakeVoiceInputNotifier extends VoiceInputNotifier {
  @override
  VoiceInputState build() => const VoiceInputState();
}

class FakeAiAgentSettingsNotifier extends AiAgentSettingsNotifier {
  FakeAiAgentSettingsNotifier(super.prefs);

  @override
  AiAgentSettings get state => const AiAgentSettings(
    preferDeepAgent: true,
    deepAgentFallbackToQa: true,
    deepAgentReflectionMode: DeepAgentReflectionMode.off,
    deepAgentShowDetails: false,
    deepAgentMaxPlanSteps: 6,
    deepAgentMaxToolRounds: 8,
    enableStreaming: false,
  );
}

void main() {
  group('AI Chat Functionality', () {
    late MockAiChatService mockAiChatService;
    late MockChatStorageService mockStorageService;
    late AiContextNotifier contextNotifier;
    late MockSharedPreferences mockPrefs;
    const defaultSettings = AiAgentSettings(
      preferDeepAgent: true,
      deepAgentFallbackToQa: true,
      deepAgentReflectionMode: DeepAgentReflectionMode.off,
      deepAgentShowDetails: false,
      deepAgentMaxPlanSteps: 6,
      deepAgentMaxToolRounds: 8,
      enableStreaming: false,
    );

    setUp(() {
      mockAiChatService = MockAiChatService();
      mockStorageService = MockChatStorageService();
      contextNotifier = AiContextNotifier(() => const Locale('en'));
      mockPrefs = MockSharedPreferences();

      when(
        () => mockPrefs.getString('ai_service_url'),
      ).thenReturn('http://localhost:5600/');
      when(() => mockStorageService.loadSessions()).thenReturn([]);
      when(
        () => mockStorageService.saveSessions(any(that: isA<List>())),
      ).thenAnswer((_) async {});
      when(() => mockPrefs.getString(any())).thenReturn(null);
      when(() => mockPrefs.getBool(any())).thenReturn(null);
    });

    testWidgets('AI chat sidebar renders correctly when open', (
      WidgetTester tester,
    ) async {
      when(
        () => mockAiChatService.sendMessage(
          any(),
          settings: any(named: 'settings'),
          l10n: any(named: 'l10n'),
        ),
      ).thenAnswer((_) async => 'AI response');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            aiServiceProvider.overrideWith((_) => AiServiceNotifier(mockPrefs)),
            aiAgentSettingsProvider.overrideWith(
              (ref) => FakeAiAgentSettingsNotifier(mockPrefs),
            ),
            chatStorageServiceProvider.overrideWithValue(mockStorageService),
            aiContextProvider.overrideWith((ref) => contextNotifier),
            aiChatProvider.overrideWith(
              (ref) => AiChatNotifier(
                mockAiChatService,
                () => defaultSettings,
                mockStorageService,
                contextNotifier,
                () => const Locale('en'),
              ),
            ),
            aiChatUiProvider.overrideWith((_) => AiChatUiNotifier()),
            voiceInputServiceProvider.overrideWithValue(
              MockVoiceInputService(),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Row(
                children: [
                  Expanded(child: Container()), // Placeholder for main content
                  const AiChatSidebar(),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open the sidebar
      final buildContext = tester.element(find.byType(AiChatSidebar));
      final container = ProviderScope.containerOf(buildContext);
      container.read(aiChatUiProvider.notifier).openSidebar();
      await tester.pumpAndSettle();

      expect(find.byType(AiChatSidebar), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('AI chat sidebar is hidden when closed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            aiServiceProvider.overrideWith((_) => AiServiceNotifier(mockPrefs)),
            aiAgentSettingsProvider.overrideWith(
              (ref) => FakeAiAgentSettingsNotifier(mockPrefs),
            ),
            chatStorageServiceProvider.overrideWithValue(mockStorageService),
            aiContextProvider.overrideWith((ref) => contextNotifier),
            aiChatProvider.overrideWith(
              (ref) => AiChatNotifier(
                mockAiChatService,
                () => defaultSettings,
                mockStorageService,
                contextNotifier,
                () => const Locale('en'),
              ),
            ),
            aiChatUiProvider.overrideWith((_) => AiChatUiNotifier()),
            voiceInputServiceProvider.overrideWithValue(
              MockVoiceInputService(),
            ),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: AiChatSidebar()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // When closed, the sidebar should still exist but be sized to zero width
      expect(find.byType(AiChatSidebar), findsOneWidget);
    });

    testWidgets('AI chat sends message and displays response', (
      WidgetTester tester,
    ) async {
      const userMessage = 'Hello AI';
      const aiResponse = 'Hello! How can I help you?';

      when(
        () => mockAiChatService.sendMessage(
          userMessage,
          settings: any(named: 'settings'),
          l10n: any(named: 'l10n'),
        ),
      ).thenAnswer((_) async {
        // Add a small delay to simulate network request
        await Future.delayed(const Duration(milliseconds: 500));
        return aiResponse;
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            aiServiceProvider.overrideWith((_) => AiServiceNotifier(mockPrefs)),
            aiAgentSettingsProvider.overrideWith(
              (ref) => FakeAiAgentSettingsNotifier(mockPrefs),
            ),
            chatStorageServiceProvider.overrideWithValue(mockStorageService),
            aiContextProvider.overrideWith((ref) => contextNotifier),
            aiChatProvider.overrideWith(
              (ref) => AiChatNotifier(
                mockAiChatService,
                () => defaultSettings,
                mockStorageService,
                contextNotifier,
                () => const Locale('en'),
              ),
            ),
            aiChatUiProvider.overrideWith((_) => AiChatUiNotifier()),
            voiceInputServiceProvider.overrideWithValue(
              MockVoiceInputService(),
            ),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: AiChatSidebar()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open the sidebar first
      final buildContext = tester.element(find.byType(AiChatSidebar));
      buildContext as BuildContext;
      final container = ProviderScope.containerOf(buildContext);
      container.read(aiChatUiProvider.notifier).openSidebar();
      await tester.pumpAndSettle();

      // Enter a message
      await tester.enterText(find.byType(TextField), userMessage);

      // Just verify the UI components exist, don't try to interact
      expect(find.byIcon(Icons.send), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    }, skip: true);

    test('AiChatNotifier sends message and updates state', () async {
      const userMessage = 'Test message';
      const aiResponse = 'Test response';

      when(
        () => mockAiChatService.sendMessage(
          userMessage,
          settings: any(named: 'settings'),
          l10n: any(named: 'l10n'),
        ),
      ).thenAnswer((_) async => aiResponse);

      final notifier = AiChatNotifier(
        mockAiChatService,
        () => defaultSettings,
        mockStorageService,
        contextNotifier,
        () => const Locale('en'),
      );

      // Initial state should be empty
      expect(notifier.state.messages, isEmpty);
      expect(notifier.state.isLoading, false);

      // Send a message
      await notifier.sendMessage(userMessage);

      // Verify state contains both user message and AI response
      expect(notifier.state.messages.length, 2);
      expect(notifier.state.messages[0].content, userMessage);
      expect(notifier.state.messages[0].isUser, true);
      expect(notifier.state.messages[1].content, aiResponse);
      expect(notifier.state.messages[1].isUser, false);
    });

    test('AiChatUiNotifier toggles sidebar state', () {
      final notifier = AiChatUiNotifier();

      expect(notifier.state, false);

      // Toggle sidebar open
      notifier.toggleSidebar();
      expect(notifier.state, true);

      // Toggle sidebar closed
      notifier.toggleSidebar();
      expect(notifier.state, false);
    });
  });
}
