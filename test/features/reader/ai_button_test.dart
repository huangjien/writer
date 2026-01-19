import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';
import 'package:writer/features/reader/widgets/reader_app_bar.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/shared/widgets/neumorphic_button.dart';

class MockAiChatService extends Mock implements AiChatService {}

void main() {
  group('AI Button Status', () {
    late MockAiChatService mockAiChatService;

    setUp(() {
      mockAiChatService = MockAiChatService();
    });

    testWidgets('AI button is disabled when service is unavailable', (
      tester,
    ) async {
      // Mock health check to return false
      when(
        () => mockAiChatService.checkHealth(),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiChatServiceProvider.overrideWithValue(mockAiChatService),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              appBar: ReaderAppBar(title: 'Test Chapter', onBack: () {}),
            ),
          ),
        ),
      );

      // Wait for async checkHealth to complete and update state
      await tester.pumpAndSettle();

      // Find the AI button
      final aiIcon = find.byIcon(Icons.smart_toy);
      expect(aiIcon, findsOneWidget);

      // Verify it is disabled
      expect(find.byTooltip('AI Service Unavailable'), findsOneWidget);
      final buttonFinder = find.ancestor(
        of: aiIcon,
        matching: find.byType(NeumorphicButton),
      );
      final buttonWidget = tester.widget<NeumorphicButton>(buttonFinder);
      expect(buttonWidget.onPressed, isNull);
    });

    testWidgets('AI button is enabled when service is available', (
      tester,
    ) async {
      // Mock health check to return true
      when(() => mockAiChatService.checkHealth()).thenAnswer((_) async => true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiChatServiceProvider.overrideWithValue(mockAiChatService),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              appBar: ReaderAppBar(title: 'Test Chapter', onBack: () {}),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final aiIcon = find.byIcon(Icons.smart_toy);
      expect(aiIcon, findsOneWidget);

      expect(find.byTooltip('AI Assistant'), findsOneWidget);
      final buttonFinder = find.ancestor(
        of: aiIcon,
        matching: find.byType(NeumorphicButton),
      );
      final buttonWidget = tester.widget<NeumorphicButton>(buttonFinder);
      expect(buttonWidget.onPressed, isNotNull);
    });
  });
}
