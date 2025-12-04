import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/settings/widgets/ai_configurations_section.dart';
import 'package:writer/features/ai_chat/services/agents_config_service.dart';

class MockAgentsConfigService extends AgentsConfigService {
  MockAgentsConfigService() : super('http://mock');

  final Map<String, Map<String, dynamic>> _saved = {};

  @override
  Future<Map<String, dynamic>?> getEffective(String agentType) async {
    if (_saved.containsKey(agentType)) return _saved[agentType];
    // Return default dummy
    return {
      'model': 'gpt-default',
      'temperature': 0.7,
      'system_prompt': 'default prompt',
    };
  }

  @override
  Future<List<Map<String, dynamic>>> list(String agentType) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>?> saveMyVersion(
    String agentType,
    Map<String, dynamic> payload,
  ) async {
    _saved[agentType] = payload;
    return payload;
  }
}

void main() {
  testWidgets('AiConfigurationsSection renders and updates', (tester) async {
    final mockService = MockAgentsConfigService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [agentsConfigServiceProvider.overrideWithValue(mockService)],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: AiConfigurationsSection()),
          ),
        ),
      ),
    );

    // Wait for async providers to settle
    await tester.pumpAndSettle();

    // Verify sections exist
    expect(find.text('AI Configurations'), findsOneWidget);
    expect(find.text('RESPOND'), findsOneWidget);
    expect(find.text('QA'), findsOneWidget);
    expect(find.text('EMBEDDING'), findsOneWidget);

    // Find model text field under RESPOND
    final modelFinders = find.widgetWithText(TextField, 'Model');
    expect(modelFinders, findsNWidgets(3)); // 3 types

    final tempFinders = find.widgetWithText(TextField, 'Temperature');
    expect(tempFinders, findsNWidgets(3));

    // Verify initial values for the first one (RESPOND)
    final firstModelField = tester.widget<TextField>(modelFinders.first);
    expect(firstModelField.controller!.text, 'gpt-default');

    // Edit fields
    await tester.enterText(modelFinders.first, 'gpt-new');
    await tester.enterText(tempFinders.first, '0.9');

    // Find Save button for the first panel
    final saveButtons = find.text('Save My Version');
    expect(saveButtons, findsNWidgets(3));

    await tester.ensureVisible(saveButtons.first);
    await tester.tap(saveButtons.first);
    await tester.pumpAndSettle();

    // Verify saved in mock service
    final saved = await mockService.getEffective('respond');
    expect(saved!['model'], 'gpt-new');
    expect(saved['temperature'], 0.9);
  });
}
