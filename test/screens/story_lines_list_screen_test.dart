import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/story_line.dart';
import 'package:writer/screens/story_lines_list_screen.dart';
import 'package:writer/services/story_lines_service.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/story_line_providers.dart';

class MockGoRouter extends Mock implements GoRouter {}

class FakeStoryLinesService extends StoryLinesService {
  FakeStoryLinesService() : super(baseUrl: 'http://example.com');

  List<StoryLine> items = const [
    StoryLine(
      id: 's1',
      title: 'A',
      description: 'Desc',
      content: 'Content',
      language: 'en',
      locked: true,
    ),
    StoryLine(
      id: 's2',
      title: 'B',
      description: null,
      content: 'Body',
      language: 'zh',
      locked: false,
    ),
  ];

  bool deleteCalled = false;
  String? lastDeleteId;
  bool shouldFailDelete = false;
  bool shouldThrowDelete = false;
  bool shouldThrowSearch = false;
  bool shouldThrowFetch = false;
  List<StoryLine> smartResults = const [];

  @override
  Future<List<StoryLine>> fetchStoryLines() async {
    if (shouldThrowFetch) {
      throw ApiException(500, 'Fetch failed');
    }
    return items;
  }

  @override
  Future<List<StoryLine>> searchStoryLines(String query) async {
    if (shouldThrowSearch) {
      throw ApiException(500, 'Search failed');
    }
    return items
        .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<bool> deleteStoryLine(String id) async {
    if (shouldThrowDelete) {
      throw ApiException(500, 'Delete error');
    }
    if (shouldFailDelete) return false;
    deleteCalled = true;
    lastDeleteId = id;
    return true;
  }

  @override
  Future<List<StoryLine>> smartSearchStoryLines(
    String query, {
    int limit = 10,
    int offset = 0,
  }) async {
    return smartResults;
  }
}

void main() {
  testWidgets('StoryLinesListScreen renders items', (tester) async {
    final fake = FakeStoryLinesService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          storyLinesProvider.overrideWith((ref) async => fake.items),
          storyLinesServiceRefProvider.overrideWith((_) => fake),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StoryLinesListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Story Lines'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('Delete action confirms and calls service', (tester) async {
    final fake = FakeStoryLinesService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          storyLinesProvider.overrideWith((ref) async => fake.items),
          storyLinesServiceRefProvider.overrideWith((_) => fake),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StoryLinesListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pump();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(fake.deleteCalled, isTrue);
    expect(fake.lastDeleteId, 's1');
    expect(find.textContaining('Deleted:'), findsOneWidget);
  });

  testWidgets('Delete failure shows snackbar', (tester) async {
    final fake = FakeStoryLinesService()..shouldFailDelete = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          storyLinesProvider.overrideWith((ref) async => fake.items),
          storyLinesServiceRefProvider.overrideWith((_) => fake),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StoryLinesListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pump();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Delete failed'), findsOneWidget);
  });

  testWidgets('Delete exception shows snackbar with error', (tester) async {
    final fake = FakeStoryLinesService()..shouldThrowDelete = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          storyLinesProvider.overrideWith((ref) async => fake.items),
          storyLinesServiceRefProvider.overrideWith((_) => fake),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StoryLinesListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pump();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Delete error'), findsOneWidget);
  });

  testWidgets('Double-tap on row navigates to edit', (tester) async {
    final fake = FakeStoryLinesService();
    final mockRouter = MockGoRouter();
    when(
      () => mockRouter.push(any(), extra: any(named: 'extra')),
    ).thenAnswer((_) async => null);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          storyLinesProvider.overrideWith((ref) async => fake.items),
          storyLinesServiceRefProvider.overrideWith((_) => fake),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: InheritedGoRouter(
            goRouter: mockRouter,
            child: const StoryLinesListScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final titleCell = find.text('A');
    await tester.tap(titleCell);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(titleCell);
    await tester.pump();
    verify(
      () => mockRouter.push('/story_line_form', extra: any(named: 'extra')),
    ).called(1);
  });

  testWidgets('Search filters items and error renders text', (tester) async {
    final fake = FakeStoryLinesService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          storyLinesProvider.overrideWith((ref) async => fake.items),
          storyLinesServiceRefProvider.overrideWith((_) => fake),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StoryLinesListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'A');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(DataTable), matching: find.text('A')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: find.byType(DataTable), matching: find.text('B')),
      findsNothing,
    );

    fake.shouldThrowSearch = true;
    await tester.enterText(find.byType(TextField), 'B');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.textContaining('Search failed'), findsOneWidget);
  });

  testWidgets('Smart search filters items', (tester) async {
    final fake = FakeStoryLinesService();
    fake.smartResults = [
      const StoryLine(
        id: 's3',
        title: 'Smart Result',
        description: 'AI Found',
        content: 'Content',
        language: 'en',
        locked: false,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          storyLinesProvider.overrideWith((ref) async => fake.items),
          storyLinesServiceRefProvider.overrideWith((_) => fake),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StoryLinesListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Enter text and click AI icon
    await tester.enterText(find.byType(TextField), 'Smart Query');
    await tester.pump();

    final aiIcon = find.byIcon(Icons.auto_awesome);
    expect(aiIcon, findsOneWidget);
    await tester.tap(aiIcon);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Smart Result', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('A'), findsNothing);
  });

  testWidgets('Language filter works', (tester) async {
    final fake = FakeStoryLinesService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          storyLinesProvider.overrideWith((ref) async => fake.items),
          storyLinesServiceRefProvider.overrideWith((_) => fake),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StoryLinesListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chinese').last);
    await tester.pumpAndSettle();

    expect(find.text('A'), findsNothing);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('Locked filter works (tri-state)', (tester) async {
    final fake = FakeStoryLinesService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          storyLinesProvider.overrideWith((ref) async => fake.items),
          storyLinesServiceRefProvider.overrideWith((_) => fake),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StoryLinesListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.filter_alt_off));
    await tester.pumpAndSettle();
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsNothing);

    await tester.tap(
      find.descendant(of: find.byType(Wrap), matching: find.byIcon(Icons.lock)),
    );
    await tester.pumpAndSettle();
    expect(find.text('A'), findsNothing);
    expect(find.text('B'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(Wrap),
        matching: find.byIcon(Icons.lock_open),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('Shows sign-in prompt when signed out', (tester) async {
    final fake = FakeStoryLinesService()..items = [];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storyLinesProvider.overrideWith((ref) async => const []),
          storyLinesServiceRefProvider.overrideWith((_) => fake),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StoryLinesListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Sign in to sync progress across devices.'),
      findsOneWidget,
    );
  });

  testWidgets('Shows No Story Lines message when empty and signed in', (
    tester,
  ) async {
    final fake = FakeStoryLinesService()..items = [];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          storyLinesProvider.overrideWith((ref) async => const []),
          storyLinesServiceRefProvider.overrideWith((_) => fake),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StoryLinesListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No story lines'), findsOneWidget);
  });
}
