import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/ai_chat/state/ai_chat_providers.dart';
import 'package:writer/features/reader/widgets/reader_shortcuts_wrapper.dart';
import 'package:writer/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestApp({required Widget child, List overrides = const []}) {
    return ProviderScope(
      overrides: overrides.cast(),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets('Space triggers toggle when enabled and chat closed', (
    tester,
  ) async {
    int toggle = 0;
    int prev = 0;
    int next = 0;
    int settings = 0;

    await tester.pumpWidget(
      buildTestApp(
        overrides: [aiChatUiProvider.overrideWith((ref) => AiChatUiNotifier())],
        child: ReaderShortcutsWrapper(
          disabled: false,
          onToggleSpeak: () => toggle++,
          onPrev: () => prev++,
          onNext: () => next++,
          onOpenSettings: () => settings++,
          child: const Focus(autofocus: true, child: SizedBox()),
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
      buildTestApp(
        overrides: [
          aiChatUiProvider.overrideWith(
            (ref) => AiChatUiNotifier()..openSidebar(),
          ),
        ],
        child: ReaderShortcutsWrapper(
          disabled: false,
          onToggleSpeak: () => toggle++,
          onPrev: () => prev++,
          onNext: () => next++,
          onOpenSettings: () {},
          child: const Focus(autofocus: true, child: SizedBox()),
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
      buildTestApp(
        overrides: [aiChatUiProvider.overrideWith((ref) => AiChatUiNotifier())],
        child: ReaderShortcutsWrapper(
          disabled: true,
          onToggleSpeak: () => toggle++,
          onPrev: () => prev++,
          onNext: () => next++,
          onOpenSettings: () {},
          child: const Focus(autofocus: true, child: SizedBox()),
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
      buildTestApp(
        overrides: [aiChatUiProvider.overrideWith((ref) => AiChatUiNotifier())],
        child: ReaderShortcutsWrapper(
          disabled: false,
          onToggleSpeak: () {},
          onPrev: () {},
          onNext: () {},
          onOpenSettings: () {},
          child: const Focus(autofocus: true, child: SizedBox()),
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
