import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/shared/widgets/global_shortcuts_wrapper.dart';
import 'package:writer/shared/widgets/keyboard_shortcuts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GlobalShortcutsWrapper', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GlobalShortcutsWrapper(child: Scaffold(body: Text('Test'))),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('works with nested widgets', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GlobalShortcutsWrapper(
            child: Scaffold(
              body: Column(children: [Text('First'), Text('Second')]),
            ),
          ),
        ),
      );

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets('supports Focus widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GlobalShortcutsWrapper(
            child: Scaffold(body: Focus(child: Text('Focused'))),
          ),
        ),
      );

      expect(find.text('Focused'), findsOneWidget);
    });

    testWidgets('preserves theme context', (tester) async {
      final theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const GlobalShortcutsWrapper(
            child: Scaffold(body: Text('Themed')),
          ),
        ),
      );

      expect(find.text('Themed'), findsOneWidget);
    });

    testWidgets('handles multiple children', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GlobalShortcutsWrapper(
            child: Scaffold(
              body: Row(children: [Text('A'), Text('B'), Text('C')]),
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('works with stateful widgets', (tester) async {
      int counter = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: GlobalShortcutsWrapper(
            child: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        counter++;
                      });
                    },
                    child: Text('Count: $counter'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      await tester.tap(find.text('Count: 0'));
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);
    });

    testWidgets('can be used multiple times', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                GlobalShortcutsWrapper(child: Text('Wrapper 1')),
                GlobalShortcutsWrapper(child: Text('Wrapper 2')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Wrapper 1'), findsOneWidget);
      expect(find.text('Wrapper 2'), findsOneWidget);
    });

    testWidgets('works with Navigator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GlobalShortcutsWrapper(child: Scaffold(body: Text('Home'))),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('NavigateSettingsIntent falls back to Navigator.pushNamed', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routes: {
              'settings': (_) =>
                  const Scaffold(body: Text('Settings Destination')),
            },
            home: const GlobalShortcutsWrapper(
              child: Scaffold(body: Text('Home')),
            ),
          ),
        ),
      );

      final context = tester.element(find.text('Home'));
      Actions.invoke(context, const NavigateSettingsIntent());
      await tester.pumpAndSettle();

      expect(find.text('Settings Destination'), findsOneWidget);
    });

    testWidgets('ShowShortcutsHelpIntent opens dialog', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: GlobalShortcutsWrapper(child: Scaffold(body: Text('Home'))),
          ),
        ),
      );

      final context = tester.element(find.text('Home'));
      Actions.invoke(context, const ShowShortcutsHelpIntent());
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('QuickSearchIntent opens quick search modal', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: GlobalShortcutsWrapper(child: Scaffold(body: Text('Home'))),
          ),
        ),
      );

      final context = tester.element(find.text('Home'));
      Actions.invoke(context, const QuickSearchIntent());
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('CloseIntent pops route when possible', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routes: {
              'next': (_) => const GlobalShortcutsWrapper(
                child: Scaffold(body: Text('Next')),
              ),
            },
            home: Builder(
              builder: (context) => GlobalShortcutsWrapper(
                child: Scaffold(
                  body: Column(
                    children: [
                      const Text('Home'),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('next'),
                        child: const Text('Go Next'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go Next'));
      await tester.pumpAndSettle();
      expect(find.text('Next'), findsOneWidget);

      final nextContext = tester.element(find.text('Next'));
      Actions.invoke(nextContext, const CloseIntent());
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
    });

    testWidgets(
      'NavigateHomeIntent pops to first route when GoRouter missing',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routes: {
                'next': (_) => const GlobalShortcutsWrapper(
                  child: Scaffold(body: Text('Next')),
                ),
              },
              home: Builder(
                builder: (context) => GlobalShortcutsWrapper(
                  child: Scaffold(
                    body: Column(
                      children: [
                        const Text('Home'),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('next'),
                          child: const Text('Go Next'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Go Next'));
        await tester.pumpAndSettle();
        expect(find.text('Next'), findsOneWidget);

        final nextContext = tester.element(find.text('Next'));
        Actions.invoke(nextContext, const NavigateHomeIntent());
        await tester.pumpAndSettle();

        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Next'), findsNothing);
      },
    );

    testWidgets('LibraryShortcutsWrapper invokes callbacks for intents', (
      tester,
    ) async {
      var created = false;
      var focused = false;
      var deleted = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: LibraryShortcutsWrapper(
              onCreateNovel: () => created = true,
              onFocusSearch: () => focused = true,
              onDeleteNovel: () => deleted = true,
              child: const Scaffold(body: Text('Library')),
            ),
          ),
        ),
      );

      final ctx = tester.element(find.text('Library'));
      Actions.invoke(ctx, const CreateNovelIntent());
      Actions.invoke(ctx, const FocusSearchIntent());
      Actions.invoke(ctx, const DeleteNovelIntent());
      await tester.pump();

      expect(created, isTrue);
      expect(focused, isTrue);
      expect(deleted, isTrue);
    });

    testWidgets('ChapterListShortcutsWrapper invokes callbacks for intents', (
      tester,
    ) async {
      var created = false;
      var refreshed = false;
      var duplicated = false;
      var deleted = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ChapterListShortcutsWrapper(
              onCreateChapter: () => created = true,
              onRefreshChapters: () => refreshed = true,
              onDuplicateChapter: () => duplicated = true,
              onDeleteChapter: () => deleted = true,
              child: const Scaffold(body: Text('Chapters')),
            ),
          ),
        ),
      );

      final ctx = tester.element(find.text('Chapters'));
      Actions.invoke(ctx, const CreateChapterIntent());
      Actions.invoke(ctx, const RefreshChaptersIntent());
      Actions.invoke(ctx, const DuplicateChapterIntent());
      Actions.invoke(ctx, const DeleteChapterIntent());
      await tester.pump();

      expect(created, isTrue);
      expect(refreshed, isTrue);
      expect(duplicated, isTrue);
      expect(deleted, isTrue);
    });

    testWidgets('SettingsShortcutsWrapper invokes callbacks for intents', (
      tester,
    ) async {
      var app = false;
      var colors = false;
      var type = false;
      var perf = false;
      var tts = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SettingsShortcutsWrapper(
              onFocusAppSettings: () => app = true,
              onFocusColorTheme: () => colors = true,
              onFocusTypography: () => type = true,
              onFocusPerformance: () => perf = true,
              onFocusTTSSettings: () => tts = true,
              child: const Scaffold(body: Text('Settings')),
            ),
          ),
        ),
      );

      final ctx = tester.element(find.text('Settings'));
      Actions.invoke(ctx, const FocusAppSettingsIntent());
      Actions.invoke(ctx, const FocusColorThemeIntent());
      Actions.invoke(ctx, const FocusTypographyIntent());
      Actions.invoke(ctx, const FocusPerformanceIntent());
      Actions.invoke(ctx, const FocusTTSSettingsIntent());
      await tester.pump();

      expect(app, isTrue);
      expect(colors, isTrue);
      expect(type, isTrue);
      expect(perf, isTrue);
      expect(tts, isTrue);
    });
  });
}
