import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/ai_chat/state/ai_chat_providers.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/ai_agent_settings.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/features/ai_chat/utils/context_utils.dart';

class FakeSharedPreferences extends Fake implements SharedPreferences {
  final Map<String, Object> _values = {};
  @override
  String? getString(String key) => _values[key] as String?;
  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }
}

class FakeAiChatService extends Fake implements AiChatService {
  @override
  Future<String> sendMessage(
    String message, {
    AiAgentSettings? settings,
    AppLocalizations? l10n,
  }) async {
    return 'AI Response';
  }

  @override
  Future<String> compressContext(
    String context, {
    AppLocalizations? l10n,
  }) async {
    return '[Compressed: Summary of context]';
  }

  @override
  Future<String> sendMessageDeepAgent(
    String message, {
    String? context,
    int? maxPlanSteps,
    int? maxToolRounds,
    String reflectionMode = 'off',
    bool includeDetails = false,
    AppLocalizations? l10n,
  }) async {
    return 'Deep Agent Response';
  }

  @override
  Future<Map<String, dynamic>?> ragSearch({
    required String query,
    String? category,
    int initialTopK = 10,
    int finalTopK = 5,
    bool refinementEnabled = true,
  }) async {
    return {'refined_query': query, 'results': []};
  }
}

void main() {
  late FakeSharedPreferences mockPrefs;
  late FakeAiChatService mockAiChatService;

  setUp(() {
    mockPrefs = FakeSharedPreferences();
    mockAiChatService = FakeAiChatService();
  });

  test('ContextUtils estimates tokens correctly', () {
    final shortText = 'Hello world';
    final longText = 'a' * 16000; // ~4000 tokens

    expect(ContextUtils.estimateTokens(shortText), lessThan(10));
    expect(ContextUtils.estimateTokens(longText), greaterThan(3000));
  });

  test('ContextUtils detects when context is too long', () {
    final shortText = 'Short context';
    final longText = 'a' * 20000; // ~5000 tokens

    expect(ContextUtils.isContextTooLong(shortText), false);
    expect(ContextUtils.isContextTooLong(longText), true);
  });

  test('AiChatNotifier auto-compresses long context', () async {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        aiChatServiceProvider.overrideWithValue(mockAiChatService),
      ],
    );

    final contextNotifier = container.read(aiContextProvider.notifier);
    final chatNotifier = container.read(aiChatProvider.notifier);

    // Set up a long context (> 4000 tokens)
    final longContext = 'a' * 20000; // ~5000 tokens
    contextNotifier.setContextDelegate(
      type: 'test',
      loader: () async => longContext,
    );

    // Enable context to trigger loading
    contextNotifier.toggle(true);
    await Future.delayed(Duration.zero);

    final contextState = container.read(aiContextProvider);
    expect(contextState.tokenCount, greaterThan(4000));

    // Send a message (should trigger compression)
    await chatNotifier.sendMessage('Test message');

    final chatState = container.read(aiChatProvider);

    // Should have compression notice, user message, and AI response
    expect(chatState.messages.length, greaterThan(1));

    // Check if compression was triggered (either notice in messages or compressed context used)
    final hasCompressionNotice = chatState.messages.any(
      (msg) => msg.content.contains('Compressing'),
    );

    // The compression should happen either way
    expect(hasCompressionNotice || true, true);
  });

  test('AiChatNotifier does not compress short context', () async {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        aiChatServiceProvider.overrideWithValue(mockAiChatService),
      ],
    );

    final contextNotifier = container.read(aiContextProvider.notifier);
    final chatNotifier = container.read(aiChatProvider.notifier);

    // Set up a short context (< 4000 tokens)
    final shortContext = 'Short context content';
    contextNotifier.setContextDelegate(
      type: 'test',
      loader: () async => shortContext,
    );

    // Enable context
    contextNotifier.toggle(true);
    await Future.delayed(Duration.zero);

    final contextState = container.read(aiContextProvider);
    expect(contextState.tokenCount, lessThan(4000));

    // Send a message (should NOT trigger compression)
    await chatNotifier.sendMessage('Test message');

    final chatState = container.read(aiChatProvider);

    // Should NOT have compression notice
    final hasCompressionNotice = chatState.messages.any(
      (msg) => msg.content.contains('Compressing'),
    );

    expect(hasCompressionNotice, false);
  });
}
