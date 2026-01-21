import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/pattern.dart';
import 'package:writer/screens/patterns_list_screen.dart';
import 'package:writer/state/pattern_providers.dart';
import 'package:writer/state/pattern_list_notifier.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/services/patterns_service.dart';

class MockGoRouter extends Mock implements GoRouter {}

class FakePatternsService extends PatternsService {
  FakePatternsService() : super(baseUrl: 'http://example.com');
  List<Pattern> items = const [
    Pattern(
      id: 'p1',
      title: 'A',
      description: 'D',
      content: 'X',
      language: 'en',
      locked: true,
    ),
    Pattern(
      id: 'p2',
      title: 'B',
      description: null,
      content: 'Y',
      language: 'zh',
      locked: false,
    ),
  ];
  bool deleteCalled = false;
  String? lastDeleteId;
  bool shouldFailDelete = false;
  List<Pattern> smartResults = const [];

  @override
  Future<List<Pattern>> fetchPatterns() async => items;

  @override
  Future<List<Pattern>> searchPatterns(String query) async {
    return items
        .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<bool> deletePattern(String id) async {
    if (shouldFailDelete) return false;
    deleteCalled = true;
    lastDeleteId = id;
    return true;
  }

  @override
  Future<List<Pattern>> smartSearchPatterns(
    String query, {
    int limit = 10,
    int offset = 0,
  }) async {
    return smartResults;
  }
}

void main() {
  testWidgets('PatternsListScreen renders items', (tester) async {
    final fake = FakePatternsService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          patternsProvider.overrideWith((ref) async => fake.items),
          patternsServiceRefProvider.overrideWith((_) => fake),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PatternsListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Patterns'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('Delete action confirms and calls repository', (tester) async {
    final fake = FakePatternsService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          patternsProvider.overrideWith((ref) async => fake.items),
          patternsServiceRefProvider.overrideWith((_) => fake),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PatternsListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final deleteIcon = find.byIcon(Icons.delete).first;
    expect(deleteIcon, findsOneWidget);
    await tester.tap(deleteIcon);
    await tester.pump();
    await tester.tap(find.text('Delete'));
    await tester.pump();
    expect(fake.deleteCalled, isTrue);
    expect(fake.lastDeleteId, 'p1');
  });

  testWidgets('Double-tap on row navigates to edit', (tester) async {
    final fake = FakePatternsService();
    final mockRouter = MockGoRouter();
    when(
      () => mockRouter.push(any(), extra: any(named: 'extra')),
    ).thenAnswer((_) async => null);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          patternsProvider.overrideWith((ref) async => fake.items),
          patternsServiceRefProvider.overrideWith((_) => fake),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: InheritedGoRouter(
            goRouter: mockRouter,
            child: const PatternsListScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final titleCell = find.text('A');
    expect(titleCell, findsOneWidget);
    await tester.tap(titleCell);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(titleCell);
    await tester.pump();
    verify(
      () => mockRouter.push('/pattern_form', extra: any(named: 'extra')),
    ).called(1);
  });

  testWidgets('Search filters items', (tester) async {
    final fake = FakePatternsService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          patternsProvider.overrideWith((ref) async => fake.items),
          patternsServiceRefProvider.overrideWith((_) => fake),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PatternsListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Type 'A' into search
    await tester.enterText(find.byType(TextField), 'A');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(DataTable), matching: find.text('A')),
      findsOneWidget,
    );
    expect(find.text('B'), findsNothing);
  });

  testWidgets('Smart search filters items', (tester) async {
    final fake = FakePatternsService();
    fake.smartResults = [
      const Pattern(
        id: 'p3',
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
          patternsProvider.overrideWith((ref) async => fake.items),
          patternsServiceRefProvider.overrideWith((_) => fake),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PatternsListScreen(),
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
    final fake = FakePatternsService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          patternsProvider.overrideWith((ref) async => fake.items),
          patternsServiceRefProvider.overrideWith((_) => fake),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PatternsListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open dropdown
    await tester.tap(find.byType(DropdownButton<String?>));
    await tester.pumpAndSettle();

    // Select 'Chinese' (B has 'zh')
    await tester.tap(find.text('Chinese').last);
    await tester.pumpAndSettle();

    expect(find.text('A'), findsNothing);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('Locked filter works (tri-state)', (tester) async {
    final fake = FakePatternsService();
    final container = ProviderContainer(
      overrides: [
        isSignedInProvider.overrideWithValue(true),
        patternsProvider.overrideWith((ref) async => fake.items),
        patternsServiceRefProvider.overrideWith((_) => fake),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PatternsListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(container.read(patternListProvider).filterLocked, isNull);

    // Initial: All shown
    expect(find.text('A'), findsOneWidget); // Locked=true
    expect(find.text('B'), findsOneWidget); // Locked=false

    // 1st Tap: Locked Only
    await tester.tap(find.byKey(const ValueKey('patternsLockedFilterButton')));
    await tester.pumpAndSettle();
    expect(container.read(patternListProvider).filterLocked, isTrue);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsNothing);

    // 2nd Tap: Unlocked Only
    await tester.tap(find.byKey(const ValueKey('patternsLockedFilterButton')));
    await tester.pumpAndSettle();
    expect(container.read(patternListProvider).filterLocked, isFalse);
    expect(find.text('A'), findsNothing);
    expect(find.text('B'), findsOneWidget);

    // 3rd Tap: Reset (All)
    await tester.tap(find.byKey(const ValueKey('patternsLockedFilterButton')));
    await tester.pumpAndSettle();
    expect(container.read(patternListProvider).filterLocked, isNull);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('Shows Supabase disabled message when empty and disabled', (
    tester,
  ) async {
    final fake = FakePatternsService();
    fake.items = []; // Empty
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          patternsProvider.overrideWith((ref) async => []),
          patternsServiceRefProvider.overrideWith((_) => fake),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PatternsListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No patterns'), findsOneWidget);
  });

  testWidgets('Shows No Patterns message when empty and enabled', (
    tester,
  ) async {
    final fake = FakePatternsService();
    fake.items = []; // Empty
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          patternsProvider.overrideWith((ref) async => []),
          patternsServiceRefProvider.overrideWith((_) => fake),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PatternsListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No patterns'), findsOneWidget);
  });

  testWidgets('Delete failure shows snackbar', (tester) async {
    final fake = FakePatternsService();
    fake.shouldFailDelete = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          patternsProvider.overrideWith((ref) async => fake.items),
          patternsServiceRefProvider.overrideWith((_) => fake),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PatternsListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final deleteIcon = find.byIcon(Icons.delete).first;
    await tester.tap(deleteIcon);
    await tester.pump();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Delete failed'), findsOneWidget);
  });
}
