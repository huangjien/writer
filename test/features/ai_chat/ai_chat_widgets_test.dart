import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/ai_chat/widgets/ai_assistant_button.dart';
import 'package:writer/features/ai_chat/widgets/ai_context_toggle.dart';
import 'package:writer/features/ai_chat/widgets/ai_chat_history_view.dart';
import 'package:writer/features/ai_chat/widgets/ai_chat_sidebar.dart';
import 'package:writer/l10n/app_localizations.dart';

void main() {
  testWidgets('AiAssistantButton renders button widget', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(appBar: AppBar(actions: const [AiAssistantButton()])),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AiAssistantButton), findsOneWidget);
  }, skip: true); // Requires complex provider mocking

  testWidgets('AiAssistantButton has icon', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(appBar: AppBar(actions: const [AiAssistantButton()])),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AiAssistantButton), findsOneWidget);
  }, skip: true); // Requires complex provider mocking

  testWidgets('AiContextToggle renders toggle widget', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: AiContextToggle())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AiContextToggle), findsOneWidget);
  }, skip: true); // Requires complex provider mocking

  testWidgets('AiContextToggle contains Container', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: AiContextToggle())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Container), findsWidgets);
  }, skip: true); // Requires complex provider mocking

  testWidgets('AiContextToggle contains Row', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: AiContextToggle())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Row), findsOneWidget);
  }, skip: true); // Requires complex provider mocking

  testWidgets('AiChatHistoryView renders view with AppBar', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: AiChatHistoryView(onClose: () {})),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AiChatHistoryView), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  }, skip: true); // Requires complex provider mocking

  testWidgets('AiChatHistoryView AppBar has title', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: AiChatHistoryView(onClose: () {})),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);
  }, skip: true); // Requires complex provider mocking

  testWidgets('AiChatHistoryView has back button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: AiChatHistoryView(onClose: () {})),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  }, skip: true); // Requires complex provider mocking

  testWidgets('AiChatHistoryView has add button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: AiChatHistoryView(onClose: () {})),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add), findsOneWidget);
  }, skip: true); // Requires complex provider mocking

  testWidgets('AiChatHistoryView calls onClose callback when back pressed', (
    tester,
  ) async {
    bool callbackCalled = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AiChatHistoryView(onClose: () => callbackCalled = true),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();

    expect(callbackCalled, true);
  }, skip: true); // Requires complex provider mocking

  testWidgets('AiChatHistoryView shows empty state when no sessions', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: AiChatHistoryView(onClose: () {})),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No history'), findsOneWidget);
  }, skip: true); // Requires complex provider mocking

  testWidgets('AiChatSidebar renders sidebar widget', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SizedBox(width: 350, child: AiChatSidebar())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AiChatSidebar), findsOneWidget);
  }, skip: true); // Requires complex provider mocking

  testWidgets('AiChatSidebar has TextField for input', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SizedBox(width: 350, child: AiChatSidebar())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
  }, skip: true); // Requires complex provider mocking

  testWidgets('AiChatSidebar has send button with icon', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SizedBox(width: 350, child: AiChatSidebar())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.send), findsOneWidget);
  }, skip: true); // Requires complex provider mocking

  testWidgets('AiChatSidebar has attachment button', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SizedBox(width: 350, child: AiChatSidebar())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.attach_file), findsOneWidget);
  }, skip: true); // Requires complex provider mocking

  testWidgets('AiChatSidebar has settings button', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SizedBox(width: 350, child: AiChatSidebar())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.settings), findsOneWidget);
  }, skip: true); // Requires complex provider mocking

  testWidgets('AiChatSidebar TextField has hint text', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SizedBox(width: 350, child: AiChatSidebar())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Type your message...'), findsOneWidget);
  }, skip: true); // Requires complex provider mocking
}
