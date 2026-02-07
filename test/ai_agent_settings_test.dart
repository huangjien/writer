import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/state/ai_agent_settings.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('AiAgentSettingsNotifier initializes with defaults', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final notifier = AiAgentSettingsNotifier(prefs);

    expect(notifier.state.preferDeepAgent, isTrue);
    expect(notifier.state.deepAgentFallbackToQa, isTrue);
    expect(notifier.state.deepAgentReflectionMode, DeepAgentReflectionMode.off);
    expect(notifier.state.deepAgentShowDetails, isFalse);
    expect(notifier.state.deepAgentMaxPlanSteps, 6);
    expect(notifier.state.deepAgentMaxToolRounds, 8);
  });

  testWidgets('AiAgentSettingsNotifier loads persisted values', (tester) async {
    SharedPreferences.setMockInitialValues({
      'ai_prefer_deep_agent': false,
      'ai_deep_agent_fallback_to_qa': false,
      'ai_deep_agent_reflection_mode': 'always',
      'ai_deep_agent_show_details': true,
      'ai_deep_agent_max_plan_steps': 3,
      'ai_deep_agent_max_tool_rounds': 12,
    });

    final prefs = await SharedPreferences.getInstance();
    final notifier = AiAgentSettingsNotifier(prefs);

    expect(notifier.state.preferDeepAgent, isFalse);
    expect(notifier.state.deepAgentFallbackToQa, isFalse);
    expect(
      notifier.state.deepAgentReflectionMode,
      DeepAgentReflectionMode.always,
    );
    expect(notifier.state.deepAgentShowDetails, isTrue);
    expect(notifier.state.deepAgentMaxPlanSteps, 3);
    expect(notifier.state.deepAgentMaxToolRounds, 12);
  });

  testWidgets('AiAgentSettingsNotifier clamps plan steps and tool rounds', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final notifier = AiAgentSettingsNotifier(prefs);

    await notifier.setDeepAgentMaxPlanSteps(999);
    await notifier.setDeepAgentMaxToolRounds(0);

    expect(notifier.state.deepAgentMaxPlanSteps, 12);
    expect(notifier.state.deepAgentMaxToolRounds, 1);
  });
}
