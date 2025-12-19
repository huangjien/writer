import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/features/settings/widgets/supabase_section.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/user_progress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/models/novel.dart';

void main() {
  GoRouter createRouter({required User? user}) {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: SingleChildScrollView(child: SupabaseSection(user: user)),
          ),
        ),
        GoRoute(
          path: '/my-novels',
          name: 'myNovels',
          builder: (context, state) =>
              const Scaffold(body: Text('My Novels Screen')),
        ),
      ],
    );
  }

  testWidgets('SupabaseSection renders correctly when Supabase is disabled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [supabaseEnabledProvider.overrideWith((ref) => false)],
        child: MaterialApp.router(
          routerConfig: createRouter(user: null),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Supabase not enabled'), findsOneWidget);

    await tester.tap(find.text('My Novels'));
    await tester.pumpAndSettle();
    expect(find.text('My Novels Screen'), findsOneWidget);
  });

  testWidgets('SupabaseSection shows summary when enabled', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseEnabledProvider.overrideWith((ref) => true),
          novelsProvider.overrideWith((ref) async {
            return const <Novel>[
              Novel(
                id: 'n1',
                title: 'One',
                author: null,
                description: null,
                coverUrl: null,
                languageCode: 'en',
                isPublic: true,
              ),
              Novel(
                id: 'n2',
                title: 'Two',
                author: null,
                description: null,
                coverUrl: null,
                languageCode: 'en',
                isPublic: true,
              ),
            ];
          }),
          latestUserProgressProvider.overrideWith((ref) async* {
            yield UserProgress(
              userId: 'u',
              novelId: 'n1',
              chapterId: 'c',
              scrollOffset: 0,
              ttsCharIndex: 0,
              updatedAt: DateTime.now(),
            );
          }),
        ],
        child: MaterialApp.router(
          routerConfig: createRouter(user: null),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Supabase Settings'), findsOneWidget);
    expect(find.text('Novels and Progress'), findsOneWidget);
    expect(find.text('Novels: 2, Progress: n1'), findsOneWidget);
  });

  testWidgets('Fetch disabled when no user', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [supabaseEnabledProvider.overrideWith((ref) => true)],
        child: MaterialApp.router(
          routerConfig: createRouter(user: null),
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final fetchTile = find.ancestor(
      of: find.text('Fetch from Supabase'),
      matching: find.byType(ListTile),
    );
    expect(fetchTile, findsOneWidget);
    await tester.tap(fetchTile);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Shows confirm dialog when user present', (tester) async {
    final mockUser = MockUser();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [supabaseEnabledProvider.overrideWith((ref) => true)],
        child: MaterialApp.router(
          routerConfig: createRouter(user: mockUser),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fetch from Supabase'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Confirm Fetch'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Fetch'), findsOneWidget);
  });

  testWidgets('Fetch closes dialog and invalidates novelsProvider', (
    tester,
  ) async {
    final mockUser = MockUser();
    var recomputeCount = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseEnabledProvider.overrideWith((ref) => true),
          novelsProvider.overrideWith((ref) async {
            recomputeCount += 1;
            return const <Novel>[];
          }),
          latestUserProgressProvider.overrideWith((ref) async* {
            yield null;
          }),
        ],
        child: MaterialApp.router(
          routerConfig: createRouter(user: mockUser),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(recomputeCount, 1);
    await tester.tap(find.text('Fetch from Supabase'));
    await tester.pump();
    await tester.tap(find.text('Fetch'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(recomputeCount >= 2, isTrue);
    expect(find.byType(AlertDialog), findsNothing);
  });
}

class MockUser extends Mock implements User {}
