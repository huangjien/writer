import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/ai_chat/state/ai_chat_providers.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';
import 'package:writer/state/ai_agent_settings.dart';
import 'package:writer/state/storage_service_provider.dart';

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
  }) async {
    return 'AI Response';
  }

  @override
  Future<String> sendMessageDeepAgent(
    String message, {
    String? context,
    int? maxPlanSteps,
    int? maxToolRounds,
    String reflectionMode = 'off',
    bool includeDetails = false,
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

  test('AiContextNotifier toggles and loads context', () async {
    final container = ProviderContainer();
    final notifier = container.read(aiContextProvider.notifier);

    expect(container.read(aiContextProvider).isEnabled, false);

    notifier.setContextDelegate(
      type: 'test',
      loader: () async => 'Test Content',
    );

    expect(container.read(aiContextProvider).currentType, 'test');

    // Toggle ON
    notifier.toggle(true);
    expect(container.read(aiContextProvider).isEnabled, true);

    // Wait for async load
    await Future.delayed(Duration.zero);

    final context = await notifier.getActiveContext();
    expect(context, 'Test Content');
  });

  test('AiChatNotifier creates new session on message', () async {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        aiChatServiceProvider.overrideWithValue(mockAiChatService),
      ],
    );

    final notifier = container.read(aiChatProvider.notifier);

    // Send message
    await notifier.sendMessage('Hello');

    final state = container.read(aiChatProvider);
    expect(state.messages.length, 2); // User + AI
    expect(state.currentSessionId, isNotNull);
    expect(state.sessions.length, 1);
    expect(state.sessions.first.messages.length, 2);
  });
}
