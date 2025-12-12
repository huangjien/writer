import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/pattern.dart';
import 'package:writer/screens/patterns_list_screen.dart';
import 'package:writer/state/pattern_providers.dart';
import 'package:writer/repositories/pattern_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockGoRouter extends Mock implements GoRouter {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class FakePatternRepository extends PatternRepository {
  FakePatternRepository() : super(MockSupabaseClient());
  List<Pattern> items = const [
    Pattern(id: 'p1', title: 'A', description: 'D', content: 'X'),
    Pattern(id: 'p2', title: 'B', description: null, content: 'Y'),
  ];
  bool deleteCalled = false;
  String? lastDeleteId;
  @override
  Future<List<Pattern>> listPatterns({int limit = 200}) async => items;
  @override
  Future<void> deletePattern(String id) async {
    deleteCalled = true;
    lastDeleteId = id;
  }
}

void main() {
  testWidgets('PatternsListScreen renders items', (tester) async {
    final fake = FakePatternRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          patternsProvider.overrideWith((ref) async => fake.items),
          patternRepositoryProvider.overrideWith((_) => fake),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PatternsListScreen(),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Patterns'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('Delete action confirms and calls repository', (tester) async {
    final fake = FakePatternRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          patternsProvider.overrideWith((ref) async => fake.items),
          patternRepositoryProvider.overrideWith((_) => fake),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PatternsListScreen(),
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
    final fake = FakePatternRepository();
    final mockRouter = MockGoRouter();
    when(
      () => mockRouter.push(any(), extra: any(named: 'extra')),
    ).thenAnswer((_) async => null);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          patternsProvider.overrideWith((ref) async => fake.items),
          patternRepositoryProvider.overrideWith((_) => fake),
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
}
