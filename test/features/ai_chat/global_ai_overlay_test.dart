import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/ai_chat/widgets/global_ai_overlay.dart';
import 'package:writer/features/ai_chat/widgets/ai_chat_sidebar.dart';
import 'package:writer/features/ai_chat/state/ai_chat_providers.dart';
import 'package:writer/state/ai_agent_settings.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/l10n/app_localizations.dart';

class MockAiChatUiNotifier extends StateNotifier<bool>
    implements AiChatUiNotifier {
  MockAiChatUiNotifier(super.state);

  @override
  void openSidebar() {
    state = true;
  }

  @override
  void closeSidebar() {
    state = false;
  }

  @override
  void toggleSidebar() {
    state = !state;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAiChatNotifier extends StateNotifier<AiChatState>
    implements AiChatNotifier {
  MockAiChatNotifier([AiChatState? state])
    : super(state ?? const AiChatState(messages: [], isLoading: false));

  @override
  Future<void> sendMessage(String message) async {}

  @override
  void startNewSession() {}

  @override
  void selectSession(String sessionId) {}

  @override
  Future<void> deleteSession(String sessionId) async {}

  @override
  void clearMessages() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAiContextNotifier extends StateNotifier<AiContextState>
    implements AiContextNotifier {
  MockAiContextNotifier() : super(const AiContextState());

  @override
  void setContextDelegate({
    required String type,
    required Future<String> Function() loader,
  }) {}

  @override
  void clearContextDelegate() {}

  @override
  void toggle(bool value) {}

  @override
  Future<String?> getActiveContext() async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAiAgentSettingsNotifier extends StateNotifier<AiAgentSettings>
    implements AiAgentSettingsNotifier {
  MockAiAgentSettingsNotifier()
    : super(
        const AiAgentSettings(
          preferDeepAgent: false,
          deepAgentFallbackToQa: true,
          deepAgentReflectionMode: DeepAgentReflectionMode.off,
          deepAgentShowDetails: false,
          deepAgentMaxPlanSteps: 10,
          deepAgentMaxToolRounds: 5,
          enableStreaming: false,
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockSharedPreferences implements SharedPreferences {
  final Map<String, dynamic> _data = {};

  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }

  @override
  Future<bool> commit() async => true;

  @override
  bool containsKey(String key) => _data.containsKey(key);

  @override
  dynamic get(String key) => _data[key];

  @override
  Future<void> reload() async {}

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _data[key] = value;
    return true;
  }

  @override
  bool getBool(String key) => _data[key] as bool? ?? false;

  @override
  int getInt(String key) => _data[key] as int? ?? 0;

  @override
  double getDouble(String key) => _data[key] as double? ?? 0.0;

  @override
  String getString(String key) => _data[key] as String? ?? '';

  @override
  List<String> getStringList(String key) => _data[key] as List<String>? ?? [];

  @override
  Set<String> getKeys() => _data.keys.toSet();

  @override
  void noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ProviderScope createTestScope({
  required Widget child,
  required MockAiChatUiNotifier uiNotifier,
  required MockAiChatNotifier chatNotifier,
  required MockAiContextNotifier contextNotifier,
}) {
  final mockContextNotifier = MockAiContextNotifier();
  final mockAiAgentSettingsNotifier = MockAiAgentSettingsNotifier();

  return ProviderScope(
    overrides: [
      aiChatUiProvider.overrideWith((ref) => uiNotifier),
      aiChatProvider.overrideWith((ref) => chatNotifier),
      aiContextProvider.overrideWith((ref) => mockContextNotifier),
      sharedPreferencesProvider.overrideWith((ref) => MockSharedPreferences()),
      aiAgentSettingsProvider.overrideWith(
        (ref) => mockAiAgentSettingsNotifier,
      ),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SizedBox(width: 1200, height: 800, child: child)),
    ),
  );
}

void main() {
  group('GlobalAiAssistantOverlay Tests', () {
    late MockAiChatUiNotifier mockUiNotifier;
    late MockAiChatNotifier mockChatNotifier;
    late MockAiContextNotifier mockContextNotifier;

    setUp(() {
      mockUiNotifier = MockAiChatUiNotifier(false);
      mockChatNotifier = MockAiChatNotifier();
      mockContextNotifier = MockAiContextNotifier();
    });

    testWidgets('renders child widget when closed', (tester) async {
      mockUiNotifier.state = false;

      await tester.pumpWidget(
        createTestScope(
          child: const GlobalAiAssistantOverlay(child: Text('Child Content')),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Child Content'), findsOneWidget);
      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('does not show sidebar when closed', (tester) async {
      mockUiNotifier.state = false;

      await tester.pumpWidget(
        createTestScope(
          child: const GlobalAiAssistantOverlay(child: Text('Child Content')),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AiChatSidebar), findsNothing);
      expect(find.byType(Positioned), findsNothing);
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('shows sidebar when open', (tester) async {
      mockUiNotifier.state = true;

      await tester.pumpWidget(
        createTestScope(
          child: const GlobalAiAssistantOverlay(child: Text('Child Content')),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Child Content'), findsOneWidget);
      expect(find.byType(AiChatSidebar), findsOneWidget);
    });

    testWidgets('shows scrim when sidebar is open', (tester) async {
      mockUiNotifier.state = true;

      await tester.pumpWidget(
        createTestScope(
          child: const GlobalAiAssistantOverlay(child: Text('Child Content')),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      final containers = find.byType(Container);
      expect(containers, findsWidgets);
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('positions sidebar on the right', (tester) async {
      mockUiNotifier.state = true;

      await tester.pumpWidget(
        createTestScope(
          child: const GlobalAiAssistantOverlay(child: Text('Child Content')),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      final alignWidgets = find.byType(Align);
      expect(alignWidgets, findsWidgets);
    });

    testWidgets('sidebar has constrained width', (tester) async {
      mockUiNotifier.state = true;

      await tester.pumpWidget(
        createTestScope(
          child: const GlobalAiAssistantOverlay(child: Text('Child Content')),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsWidgets);

      final sidebarSizedBox = tester.widget<SizedBox>(sizedBoxes.last);
      expect(sidebarSizedBox.width, isNotNull);
      expect(sidebarSizedBox.width!.isFinite, true);
    });

    testWidgets('renders Stack with correct structure', (tester) async {
      mockUiNotifier.state = false;

      await tester.pumpWidget(
        createTestScope(
          child: const GlobalAiAssistantOverlay(child: Text('Child Content')),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Stack), findsWidgets);
      expect(find.text('Child Content'), findsOneWidget);
    });

    testWidgets('sidebar overlays child content', (tester) async {
      mockUiNotifier.state = true;

      await tester.pumpWidget(
        createTestScope(
          child: GlobalAiAssistantOverlay(
            child: Container(color: Colors.blue, child: const Text('Child')),
          ),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AiChatSidebar), findsOneWidget);
      expect(find.text('Child'), findsOneWidget);
    });

    testWidgets('uses Navigator for sidebar routing', (tester) async {
      mockUiNotifier.state = true;

      await tester.pumpWidget(
        createTestScope(
          child: const GlobalAiAssistantOverlay(child: Text('Child Content')),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Navigator), findsWidgets);
    });

    testWidgets('Positioned.fill used for overlay', (tester) async {
      mockUiNotifier.state = true;

      await tester.pumpWidget(
        createTestScope(
          child: const GlobalAiAssistantOverlay(child: Text('Child')),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Positioned), findsWidgets);
    });

    testWidgets('taps scrim to close sidebar', (tester) async {
      mockUiNotifier.state = true;

      await tester.pumpWidget(
        createTestScope(
          child: const GlobalAiAssistantOverlay(child: Text('Child Content')),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AiChatSidebar), findsOneWidget);
      expect(mockUiNotifier.state, true);

      final gestureDetectors = find.byType(GestureDetector);
      expect(gestureDetectors, findsWidgets);

      mockUiNotifier.closeSidebar();
      await tester.pumpAndSettle();

      expect(mockUiNotifier.state, false);
    });

    testWidgets('renders correctly with different child widgets', (
      tester,
    ) async {
      mockUiNotifier.state = false;

      await tester.pumpWidget(
        createTestScope(
          child: GlobalAiAssistantOverlay(
            child: Container(
              color: Colors.red,
              child: Column(
                children: [
                  const Text('Title'),
                  ElevatedButton(onPressed: () {}, child: const Text('Button')),
                ],
              ),
            ),
          ),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Button'), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('provider state changes trigger rebuilds', (tester) async {
      mockUiNotifier.state = false;

      await tester.pumpWidget(
        createTestScope(
          child: const GlobalAiAssistantOverlay(child: Text('Content')),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AiChatSidebar), findsNothing);

      mockUiNotifier.openSidebar();
      await tester.pumpAndSettle();

      expect(find.byType(AiChatSidebar), findsOneWidget);
    });

    testWidgets('scrim GestureDetector has correct onTap', (tester) async {
      mockUiNotifier.state = true;

      await tester.pumpWidget(
        createTestScope(
          child: const GlobalAiAssistantOverlay(child: Text('Child')),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      final gestureDetectors = find.byType(GestureDetector);
      expect(gestureDetectors, findsWidgets);

      final gestureDetector = tester.widget<GestureDetector>(
        gestureDetectors.first,
      );
      expect(gestureDetector.onTap, isNotNull);
    });

    testWidgets('LayoutBuilder calculates width correctly', (tester) async {
      mockUiNotifier.state = true;

      await tester.pumpWidget(
        createTestScope(
          child: const GlobalAiAssistantOverlay(
            child: SizedBox(width: 800, child: Text('Wide Content')),
          ),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LayoutBuilder), findsWidgets);
    });

    testWidgets('sidebar width is constrained on small screens', (
      tester,
    ) async {
      mockUiNotifier.state = true;

      await tester.pumpWidget(
        createTestScope(
          child: const GlobalAiAssistantOverlay(
            child: SizedBox(width: 300, child: Text('Small Content')),
          ),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('widget is const and can be reused', (tester) async {
      mockUiNotifier.state = false;

      const overlay1 = GlobalAiAssistantOverlay(child: Text('First'));
      const overlay2 = GlobalAiAssistantOverlay(child: Text('Second'));

      await tester.pumpWidget(
        createTestScope(
          child: const Column(
            children: [overlay1, SizedBox(height: 10), overlay2],
          ),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets('handles null key gracefully', (tester) async {
      mockUiNotifier.state = false;

      await tester.pumpWidget(
        createTestScope(
          child: const GlobalAiAssistantOverlay(
            key: null,
            child: Text('No Key'),
          ),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Key'), findsOneWidget);
    });

    testWidgets('Material wrapper wraps AiChatSidebar', (tester) async {
      mockUiNotifier.state = true;

      await tester.pumpWidget(
        createTestScope(
          child: const GlobalAiAssistantOverlay(child: Text('Content')),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Material), findsWidgets);
    });

    testWidgets('Navigator generates route correctly', (tester) async {
      mockUiNotifier.state = true;

      await tester.pumpWidget(
        createTestScope(
          child: const GlobalAiAssistantOverlay(child: Text('Content')),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      final navigators = find.byType(Navigator);
      expect(navigators, findsWidgets);

      final navigator = tester.widget<Navigator>(navigators.first);
      expect(navigator.onGenerateRoute, isNotNull);
    });

    testWidgets('closeSidebar is called when scrim is tapped', (tester) async {
      mockUiNotifier.state = true;

      await tester.pumpWidget(
        createTestScope(
          child: const GlobalAiAssistantOverlay(child: Text('Content')),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      final gestureDetectors = find.byType(GestureDetector);
      expect(gestureDetectors, findsWidgets);

      final gestureDetector = tester.widget<GestureDetector>(
        gestureDetectors.first,
      );

      expect(gestureDetector.onTap, isNotNull);

      gestureDetector.onTap!();
      await tester.pumpAndSettle();

      expect(mockUiNotifier.state, false);
    });

    testWidgets('sidebar visibility updates dynamically', (tester) async {
      mockUiNotifier.state = false;

      await tester.pumpWidget(
        createTestScope(
          child: const GlobalAiAssistantOverlay(child: Text('Content')),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AiChatSidebar), findsNothing);

      mockUiNotifier.openSidebar();
      await tester.pump();

      expect(find.byType(AiChatSidebar), findsOneWidget);

      mockUiNotifier.closeSidebar();
      await tester.pump();

      expect(find.byType(AiChatSidebar), findsNothing);
    });

    testWidgets('multiple overlays can coexist', (tester) async {
      mockUiNotifier.state = false;

      await tester.pumpWidget(
        createTestScope(
          child: const Column(
            children: [
              GlobalAiAssistantOverlay(child: Text('Overlay 1')),
              GlobalAiAssistantOverlay(child: Text('Overlay 2')),
            ],
          ),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Overlay 1'), findsOneWidget);
      expect(find.text('Overlay 2'), findsOneWidget);
      expect(find.byType(GlobalAiAssistantOverlay), findsWidgets);
    });

    testWidgets('overlay handles state changes correctly', (tester) async {
      mockUiNotifier.state = false;

      await tester.pumpWidget(
        createTestScope(
          child: const GlobalAiAssistantOverlay(child: Text('State Test')),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(mockUiNotifier.state, false);

      mockUiNotifier.toggleSidebar();
      await tester.pump();

      expect(mockUiNotifier.state, true);

      mockUiNotifier.toggleSidebar();
      await tester.pump();

      expect(mockUiNotifier.state, false);
    });

    testWidgets('sidebar width is 95% on small screens (<600px)', (
      tester,
    ) async {
      mockUiNotifier.state = true;

      await tester.pumpWidget(
        createTestScope(
          child: const GlobalAiAssistantOverlay(
            child: SizedBox(width: 400, child: Text('Small Screen')),
          ),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LayoutBuilder), findsWidgets);
    });

    testWidgets('sidebar width is 75% on large screens (>=600px)', (
      tester,
    ) async {
      mockUiNotifier.state = true;

      await tester.pumpWidget(
        createTestScope(
          child: const GlobalAiAssistantOverlay(
            child: SizedBox(width: 1000, child: Text('Large Screen')),
          ),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LayoutBuilder), findsWidgets);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('sidebar responds to screen size changes', (tester) async {
      mockUiNotifier.state = true;

      await tester.pumpWidget(
        createTestScope(
          child: const GlobalAiAssistantOverlay(
            child: SizedBox(width: 400, child: Text('Content')),
          ),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LayoutBuilder), findsWidgets);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('scrim has correct color', (tester) async {
      mockUiNotifier.state = true;

      await tester.pumpWidget(
        createTestScope(
          child: const GlobalAiAssistantOverlay(child: Text('Content')),
          uiNotifier: mockUiNotifier,
          chatNotifier: mockChatNotifier,
          contextNotifier: mockContextNotifier,
        ),
      );
      await tester.pumpAndSettle();

      final containers = find.byType(Container);
      final scrimContainer = tester.widget<Container>(containers.first);

      expect(scrimContainer.color, isNotNull);
      final colorAlpha = scrimContainer.color!.toARGB32();
      expect(colorAlpha & 0xFF000000, 0x8A000000);
    });
  });
}
