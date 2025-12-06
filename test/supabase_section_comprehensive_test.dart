import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/features/settings/widgets/supabase_section.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mocktail/mocktail.dart';

class MockUser extends Mock implements User {}

// Mock GoRouter
class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockGoRouter mockGoRouter;

  setUp(() {
    mockGoRouter = MockGoRouter();
  });

  group('SupabaseSection comprehensive tests', () {
    testWidgets('My Novels navigation works when Supabase is disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [supabaseEnabledProvider.overrideWithValue(false)],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return InheritedGoRouter(
                    goRouter: mockGoRouter,
                    child: const SingleChildScrollView(
                      child: SupabaseSection(user: null),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the section is shown
      expect(find.text('Supabase Settings'), findsOneWidget);
      expect(find.text('Supabase not enabled'), findsOneWidget);

      // Tap on My Novels
      await tester.tap(find.text('My Novels'));
      await tester.pumpAndSettle();

      // Verify navigation was called
      verify(() => mockGoRouter.goNamed('myNovels')).called(1);
    });

    testWidgets('My Novels navigation works when Supabase is enabled', (
      tester,
    ) async {
      final mockUser = MockUser();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supabaseEnabledProvider.overrideWithValue(true),
            novelsProvider.overrideWith((ref) async => []),
            latestUserProgressProvider.overrideWith(
              (ref) => Stream.value(null),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return InheritedGoRouter(
                    goRouter: mockGoRouter,
                    child: SingleChildScrollView(
                      child: SupabaseSection(user: mockUser),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the section is shown
      expect(find.text('Supabase Settings'), findsOneWidget);
      expect(find.text('Fetch from Supabase'), findsOneWidget);

      // Tap on My Novels
      await tester.tap(find.text('My Novels'));
      await tester.pumpAndSettle();

      // Verify navigation was called
      verify(() => mockGoRouter.goNamed('myNovels')).called(1);
    });
  });
}
