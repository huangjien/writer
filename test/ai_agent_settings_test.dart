import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/state/controllers/ai_agent_settings.dart';

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

  testWidgets('AiAgentSettings copyWith updates specified fields', (
    tester,
  ) async {
    const settings = AiAgentSettings(
      preferDeepAgent: true,
      deepAgentFallbackToQa: true,
      deepAgentReflectionMode: DeepAgentReflectionMode.off,
      deepAgentShowDetails: false,
      deepAgentMaxPlanSteps: 6,
      deepAgentMaxToolRounds: 8,
    );

    final updated = settings.copyWith(
      preferDeepAgent: false,
      deepAgentMaxPlanSteps: 10,
    );

    expect(updated.preferDeepAgent, isFalse);
    expect(updated.deepAgentFallbackToQa, isTrue);
    expect(updated.deepAgentReflectionMode, DeepAgentReflectionMode.off);
    expect(updated.deepAgentShowDetails, isFalse);
    expect(updated.deepAgentMaxPlanSteps, 10);
    expect(updated.deepAgentMaxToolRounds, 8);
  });

  testWidgets('DeepAgentReflectionModeCodec fromWireValue handles all cases', (
    tester,
  ) async {
    expect(
      DeepAgentReflectionModeCodec.fromWireValue(null),
      DeepAgentReflectionMode.off,
    );
    expect(
      DeepAgentReflectionModeCodec.fromWireValue('off'),
      DeepAgentReflectionMode.off,
    );
    expect(
      DeepAgentReflectionModeCodec.fromWireValue('on_failure'),
      DeepAgentReflectionMode.onFailure,
    );
    expect(
      DeepAgentReflectionModeCodec.fromWireValue('always'),
      DeepAgentReflectionMode.always,
    );
    expect(
      DeepAgentReflectionModeCodec.fromWireValue('invalid'),
      DeepAgentReflectionMode.off,
    );
  });

  testWidgets(
    'AiAgentSettingsNotifier setDeepAgentFallbackToQa updates state',
    (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final notifier = AiAgentSettingsNotifier(prefs);

      expect(notifier.state.deepAgentFallbackToQa, isTrue);
      await notifier.setDeepAgentFallbackToQa(false);
      expect(notifier.state.deepAgentFallbackToQa, isFalse);

      final stored = prefs.getBool('ai_deep_agent_fallback_to_qa');
      expect(stored, isFalse);
    },
  );

  testWidgets(
    'AiAgentSettingsNotifier setDeepAgentReflectionMode updates state',
    (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final notifier = AiAgentSettingsNotifier(prefs);

      expect(
        notifier.state.deepAgentReflectionMode,
        DeepAgentReflectionMode.off,
      );
      await notifier.setDeepAgentReflectionMode(
        DeepAgentReflectionMode.onFailure,
      );
      expect(
        notifier.state.deepAgentReflectionMode,
        DeepAgentReflectionMode.onFailure,
      );

      await notifier.setDeepAgentReflectionMode(DeepAgentReflectionMode.always);
      expect(
        notifier.state.deepAgentReflectionMode,
        DeepAgentReflectionMode.always,
      );

      final stored = prefs.getString('ai_deep_agent_reflection_mode');
      expect(stored, 'always');
    },
  );

  testWidgets('AiAgentSettingsNotifier setDeepAgentShowDetails updates state', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final notifier = AiAgentSettingsNotifier(prefs);

    expect(notifier.state.deepAgentShowDetails, isFalse);
    await notifier.setDeepAgentShowDetails(true);
    expect(notifier.state.deepAgentShowDetails, isTrue);

    final stored = prefs.getBool('ai_deep_agent_show_details');
    expect(stored, isTrue);
  });

  testWidgets('AiAgentSettingsNotifier clamps values at boundaries', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final notifier = AiAgentSettingsNotifier(prefs);

    await notifier.setDeepAgentMaxPlanSteps(1);
    expect(notifier.state.deepAgentMaxPlanSteps, 1);

    await notifier.setDeepAgentMaxPlanSteps(12);
    expect(notifier.state.deepAgentMaxPlanSteps, 12);

    await notifier.setDeepAgentMaxToolRounds(1);
    expect(notifier.state.deepAgentMaxToolRounds, 1);

    await notifier.setDeepAgentMaxToolRounds(20);
    expect(notifier.state.deepAgentMaxToolRounds, 20);
  });

  testWidgets('AiAgentSettingsNotifier setPreferDeepAgent updates state', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final notifier = AiAgentSettingsNotifier(prefs);

    expect(notifier.state.preferDeepAgent, isTrue);
    await notifier.setPreferDeepAgent(false);
    expect(notifier.state.preferDeepAgent, isFalse);

    final stored = prefs.getBool('ai_prefer_deep_agent');
    expect(stored, isFalse);
  });
}
