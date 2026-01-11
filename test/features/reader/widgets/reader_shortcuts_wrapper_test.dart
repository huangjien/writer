import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/ai_chat/state/ai_chat_providers.dart';
import 'package:writer/features/reader/widgets/reader_shortcuts_wrapper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Space triggers toggle when enabled and chat closed', (
    tester,
  ) async {
    int toggle = 0;
    int prev = 0;
    int next = 0;
    int settings = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [aiChatUiProvider.overrideWith((ref) => AiChatUiNotifier())],
        child: MaterialApp(
          home: Scaffold(
            body: ReaderShortcutsWrapper(
              disabled: false,
              onToggleSpeak: () => toggle++,
              onPrev: () => prev++,
              onNext: () => next++,
              onOpenSettings: () => settings++,
              child: const Focus(autofocus: true, child: SizedBox()),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

    expect(toggle, 1);
    expect(prev, 1);
    expect(next, 1);
    expect(settings, 0);
  });

  testWidgets('Space does nothing when chat is open', (tester) async {
    int toggle = 0;
    int prev = 0;
    int next = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aiChatUiProvider.overrideWith(
            (ref) => AiChatUiNotifier()..openSidebar(),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: ReaderShortcutsWrapper(
              disabled: false,
              onToggleSpeak: () => toggle++,
              onPrev: () => prev++,
              onNext: () => next++,
              onOpenSettings: () {},
              child: const Focus(autofocus: true, child: SizedBox()),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

    expect(toggle, 0);
    expect(prev, 1);
    expect(next, 1);
  });

  testWidgets('Disabled wrapper registers no shortcuts', (tester) async {
    int toggle = 0;
    int prev = 0;
    int next = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [aiChatUiProvider.overrideWith((ref) => AiChatUiNotifier())],
        child: MaterialApp(
          home: Scaffold(
            body: ReaderShortcutsWrapper(
              disabled: true,
              onToggleSpeak: () => toggle++,
              onPrev: () => prev++,
              onNext: () => next++,
              onOpenSettings: () {},
              child: const Focus(autofocus: true, child: SizedBox()),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

    expect(toggle, 0);
    expect(prev, 0);
    expect(next, 0);
  });

  testWidgets('Ctrl+/ opens shortcuts help sheet', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [aiChatUiProvider.overrideWith((ref) => AiChatUiNotifier())],
        child: MaterialApp(
          home: Scaffold(
            body: ReaderShortcutsWrapper(
              disabled: false,
              onToggleSpeak: () {},
              onPrev: () {},
              onNext: () {},
              onOpenSettings: () {},
              child: const Focus(autofocus: true, child: SizedBox()),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.slash);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();

    expect(find.text('Keyboard shortcuts'), findsOneWidget);
    expect(find.text('Space: Play / stop'), findsOneWidget);
  });
}
