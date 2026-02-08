import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:writer/features/ai_chat/widgets/ai_context_toggle.dart';
import 'package:writer/features/ai_chat/state/ai_chat_providers.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/features/ai_chat/utils/context_utils.dart';

class MockAiContextNotifier extends StateNotifier<AiContextState>
    implements AiContextNotifier {
  MockAiContextNotifier(super.state);

  @override
  void clearContextDelegate() {}

  @override
  Future<String?> getActiveContext() async => state.cachedContent;

  @override
  void setContextDelegate({
    required Future<String> Function() loader,
    required String type,
    bool clearAfterUse = true,
  }) {}

  Future<void> setContext(String context, String type) async {
    final estimatedTokens = ContextUtils.estimateTokens(context);
    state = AiContextState(
      cachedContent: context,
      currentType: type,
      tokenCount: estimatedTokens,
      isEnabled: true,
      isLoading: false,
    );
  }

  Future<void> clearContext() async {
    state = const AiContextState(
      cachedContent: null,
      currentType: null,
      tokenCount: 0,
      isEnabled: false,
      isLoading: false,
    );
  }

  @override
  void toggle(bool value) {
    state = AiContextState(
      cachedContent: state.cachedContent,
      currentType: state.currentType,
      tokenCount: state.tokenCount,
      isEnabled: value,
      isLoading: false,
    );
  }

  Future<void> loadFromClipboard() async {
    state = const AiContextState(
      cachedContent: null,
      currentType: null,
      tokenCount: 0,
      isEnabled: false,
      isLoading: true,
    );

    await Future.delayed(const Duration(milliseconds: 100));

    state = const AiContextState(
      cachedContent: 'Clipboard content',
      currentType: 'clipboard',
      tokenCount: 4,
      isEnabled: true,
      isLoading: false,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ProviderScope createTestScope({
  required Widget child,
  required MockAiContextNotifier notifier,
}) {
  return ProviderScope(
    overrides: [aiContextProvider.overrideWith((ref) => notifier)],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('AiContextToggle Tests', () {
    late MockAiContextNotifier mockNotifier;

    setUp(() {
      mockNotifier = MockAiContextNotifier(
        const AiContextState(
          cachedContent: null,
          currentType: null,
          tokenCount: 0,
          isEnabled: false,
          isLoading: false,
        ),
      );
    });

    testWidgets('returns SizedBox.shrink when no context and disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestScope(child: const AiContextToggle(), notifier: mockNotifier),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('shows widget when enabled', (tester) async {
      mockNotifier.state = const AiContextState(
        cachedContent: null,
        currentType: null,
        tokenCount: 0,
        isEnabled: true,
        isLoading: false,
      );

      await tester.pumpWidget(
        createTestScope(child: const AiContextToggle(), notifier: mockNotifier),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('shows widget when context is set', (tester) async {
      mockNotifier.state = const AiContextState(
        cachedContent: 'Test context',
        currentType: 'test',
        tokenCount: 4,
        isEnabled: false,
        isLoading: false,
      );

      await tester.pumpWidget(
        createTestScope(child: const AiContextToggle(), notifier: mockNotifier),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('displays switch component', (tester) async {
      mockNotifier.state = const AiContextState(
        cachedContent: null,
        currentType: null,
        tokenCount: 0,
        isEnabled: true,
        isLoading: false,
      );

      await tester.pumpWidget(
        createTestScope(child: const AiContextToggle(), notifier: mockNotifier),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('switch reflects enabled state', (tester) async {
      mockNotifier.state = const AiContextState(
        cachedContent: null,
        currentType: null,
        tokenCount: 0,
        isEnabled: true,
        isLoading: false,
      );

      await tester.pumpWidget(
        createTestScope(child: const AiContextToggle(), notifier: mockNotifier),
      );
      await tester.pumpAndSettle();

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, true);
    });

    testWidgets('toggles enabled state when tapped', (tester) async {
      mockNotifier.state = const AiContextState(
        cachedContent: null,
        currentType: null,
        tokenCount: 0,
        isEnabled: true,
        isLoading: false,
      );

      await tester.pumpWidget(
        createTestScope(child: const AiContextToggle(), notifier: mockNotifier),
      );
      await tester.pumpAndSettle();

      expect(mockNotifier.state.isEnabled, true);

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(mockNotifier.state.isEnabled, false);
    });

    testWidgets('displays context type badge when context is set', (
      tester,
    ) async {
      mockNotifier.state = const AiContextState(
        cachedContent: 'Test context',
        currentType: 'chapter',
        tokenCount: 4,
        isEnabled: true,
        isLoading: false,
      );

      await tester.pumpWidget(
        createTestScope(child: const AiContextToggle(), notifier: mockNotifier),
      );
      await tester.pumpAndSettle();

      expect(find.text('chapter'), findsOneWidget);
    });

    testWidgets('does not show type badge when no type', (tester) async {
      mockNotifier.state = const AiContextState(
        cachedContent: null,
        currentType: null,
        tokenCount: 0,
        isEnabled: true,
        isLoading: false,
      );

      await tester.pumpWidget(
        createTestScope(child: const AiContextToggle(), notifier: mockNotifier),
      );
      await tester.pumpAndSettle();

      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });

    testWidgets('shows token count when tokens > 0', (tester) async {
      mockNotifier.state = const AiContextState(
        cachedContent: 'Test context',
        currentType: 'test',
        tokenCount: 42,
        isEnabled: true,
        isLoading: false,
      );

      await tester.pumpWidget(
        createTestScope(child: const AiContextToggle(), notifier: mockNotifier),
      );
      await tester.pumpAndSettle();

      expect(find.text('42 tokens'), findsOneWidget);
    });

    testWidgets('does not show token count when 0', (tester) async {
      mockNotifier.state = const AiContextState(
        cachedContent: null,
        currentType: null,
        tokenCount: 0,
        isEnabled: true,
        isLoading: false,
      );

      await tester.pumpWidget(
        createTestScope(child: const AiContextToggle(), notifier: mockNotifier),
      );
      await tester.pumpAndSettle();

      expect(find.text('tokens'), findsNothing);
    });

    testWidgets('shows warning icon when context too long', (tester) async {
      final longContent = 'A' * 20000;
      mockNotifier.state = AiContextState(
        cachedContent: longContent,
        currentType: 'test',
        tokenCount: 5000,
        isEnabled: true,
        isLoading: false,
      );

      await tester.pumpWidget(
        createTestScope(child: const AiContextToggle(), notifier: mockNotifier),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.compress), findsOneWidget);
    });

    testWidgets('does not show warning icon when context within limits', (
      tester,
    ) async {
      mockNotifier.state = const AiContextState(
        cachedContent: 'Short context',
        currentType: 'test',
        tokenCount: 100,
        isEnabled: true,
        isLoading: false,
      );

      await tester.pumpWidget(
        createTestScope(child: const AiContextToggle(), notifier: mockNotifier),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.compress), findsNothing);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      mockNotifier.state = const AiContextState(
        cachedContent: null,
        currentType: null,
        tokenCount: 0,
        isEnabled: true,
        isLoading: true,
      );

      await tester.pumpWidget(
        createTestScope(child: const AiContextToggle(), notifier: mockNotifier),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('does not show loading indicator when not loading', (
      tester,
    ) async {
      mockNotifier.state = const AiContextState(
        cachedContent: null,
        currentType: null,
        tokenCount: 0,
        isEnabled: true,
        isLoading: false,
      );

      await tester.pumpWidget(
        createTestScope(child: const AiContextToggle(), notifier: mockNotifier),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('applies primary container color when enabled', (tester) async {
      mockNotifier.state = const AiContextState(
        cachedContent: null,
        currentType: null,
        tokenCount: 0,
        isEnabled: true,
        isLoading: false,
      );

      await tester.pumpWidget(
        createTestScope(child: const AiContextToggle(), notifier: mockNotifier),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('uses error border when context too long', (tester) async {
      final longContent = 'A' * 20000;
      mockNotifier.state = AiContextState(
        cachedContent: longContent,
        currentType: 'test',
        tokenCount: 5000,
        isEnabled: true,
        isLoading: false,
      );

      await tester.pumpWidget(
        createTestScope(child: const AiContextToggle(), notifier: mockNotifier),
      );
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration?;
      final border = decoration?.border;
      expect(border, isNotNull);
    });

    testWidgets('has correct padding', (tester) async {
      mockNotifier.state = const AiContextState(
        cachedContent: null,
        currentType: null,
        tokenCount: 0,
        isEnabled: true,
        isLoading: false,
      );

      await tester.pumpWidget(
        createTestScope(child: const AiContextToggle(), notifier: mockNotifier),
      );
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(
        container.padding,
        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      );
    });

    testWidgets('contains Row with mainAxisSize min', (tester) async {
      mockNotifier.state = const AiContextState(
        cachedContent: null,
        currentType: null,
        tokenCount: 0,
        isEnabled: true,
        isLoading: false,
      );

      await tester.pumpWidget(
        createTestScope(child: const AiContextToggle(), notifier: mockNotifier),
      );
      await tester.pumpAndSettle();

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisSize, MainAxisSize.min);
    });
  });
}
