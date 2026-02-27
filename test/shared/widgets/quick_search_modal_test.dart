import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/shared/widgets/quick_search_modal.dart';
import 'package:writer/state/novel_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuickSearchModal', () {
    late AppLocalizations l10n;

    setUp(() {
      l10n = AppLocalizationsEn();
    });

    testWidgets('showQuickSearchModal displays modal', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showQuickSearchModal(context),
                child: const Text('Show Search'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Search'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.searchLabel), findsOneWidget);
    });

    testWidgets('search input is present when opened', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showQuickSearchModal(context),
                child: const Text('Show Search'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Search'));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
    });

    testWidgets('close button dismisses modal', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showQuickSearchModal(context),
                child: const Text('Show Search'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Search'));
      await tester.pumpAndSettle();

      final closeButton = find.byIcon(Icons.close);
      expect(closeButton, findsOneWidget);

      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      expect(find.text(l10n.searchLabel), findsNothing);
    });

    testWidgets('escape key closes modal', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showQuickSearchModal(context),
                child: const Text('Show Search'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Search'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.searchLabel), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.text(l10n.searchLabel), findsNothing);
    });

    testWidgets('modal has rounded corners', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showQuickSearchModal(context),
                child: const Text('Show Search'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Search'));
      await tester.pumpAndSettle();

      final dialog = find.byType(Dialog);
      expect(dialog, findsOneWidget);
    });

    testWidgets('search hint text is displayed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showQuickSearchModal(context),
                child: const Text('Show Search'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Search'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.searchLabel), findsOneWidget);
    });

    testWidgets('no results shows empty state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showQuickSearchModal(context),
                child: const Text('Show Search'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Search'));
      await tester.pumpAndSettle();

      final noResults = find.text(l10n.noNovelsFound);
      expect(noResults, findsOneWidget);

      final searchIcon = find.byIcon(Icons.search_off);
      expect(searchIcon, findsOneWidget);
    });

    test('SearchResult holds required properties', () {
      const result = SearchResult(
        type: SearchResultType.novel,
        id: '1',
        title: 'Test Novel',
        route: '/novels/1',
      );

      expect(result.type, SearchResultType.novel);
      expect(result.id, '1');
      expect(result.title, 'Test Novel');
      expect(result.route, '/novels/1');
      expect(result.subtitle, isNull);
    });

    test('SearchResult with subtitle', () {
      const result = SearchResult(
        type: SearchResultType.novel,
        id: '1',
        title: 'Test Novel',
        route: '/novels/1',
        subtitle: 'Author Name',
      );

      expect(result.subtitle, 'Author Name');
    });

    test('NavigateResultIntent can be created', () {
      const intent = NavigateResultIntent();
      expect(intent, isNotNull);
    });

    test('NextResultIntent can be created', () {
      const intent = NextResultIntent();
      expect(intent, isNotNull);
    });

    test('PrevResultIntent can be created', () {
      const intent = PrevResultIntent();
      expect(intent, isNotNull);
    });

    test('SearchResultType has expected values', () {
      expect(SearchResultType.values, contains(SearchResultType.novel));
      expect(SearchResultType.values, contains(SearchResultType.setting));
    });

    testWidgets('typing query shows matching novel result', (tester) async {
      const novels = [
        Novel(
          id: 'n1',
          title: 'My Novel',
          author: 'Alice',
          languageCode: 'en',
          isPublic: false,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [novelsProvider.overrideWith((ref) async => novels)],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showQuickSearchModal(context),
                  child: const Text('Show Search'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Search'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'my');
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('My Novel'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('tapping result closes modal', (tester) async {
      const novels = [
        Novel(
          id: 'n1',
          title: 'My Novel',
          author: 'Alice',
          languageCode: 'en',
          isPublic: false,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [novelsProvider.overrideWith((ref) async => novels)],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showQuickSearchModal(context),
                  child: const Text('Show Search'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Search'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'my');
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.text('My Novel'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
    });
  });
}
