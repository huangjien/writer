import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/features/settings/widgets/supabase_section.dart';
import 'package:writer/state/supabase_config.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/models/novel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mocktail/mocktail.dart';

class MockUser extends Mock implements User {}

void main() {
  testWidgets('SupabaseSection shows disabled info when not enabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(child: SupabaseSection(user: null)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Supabase Settings'), findsOneWidget);
    expect(find.text('Supabase not enabled'), findsOneWidget);
    expect(
      find.text('Supabase is not configured for this build.'),
      findsOneWidget,
    );
    expect(find.text('My Novels'), findsOneWidget);
  }, skip: supabaseEnabled);

  testWidgets('SupabaseSection shows fetch controls when enabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SingleChildScrollView(child: SupabaseSection(user: null)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Supabase Settings'), findsOneWidget);
    expect(find.text('Fetch from Supabase'), findsOneWidget);
    expect(
      find.text('Fetch latest novels and progress from Supabase.'),
      findsOneWidget,
    );
  }, skip: !supabaseEnabled);

  testWidgets(
    'Fetch confirms and invalidates novelsProvider when enabled',
    (tester) async {
      if (!supabaseEnabled) return;

      final mockUser = MockUser();
      var recomputeCount = 0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            novelsProvider.overrideWith((ref) async {
              recomputeCount += 1;
              return const <Novel>[];
            }),
            latestUserProgressProvider.overrideWith((ref) async* {
              yield null;
            }),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: SupabaseSection(user: mockUser),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(recomputeCount, 1);

      await tester.tap(find.text('Fetch from Supabase'));
      await tester.pump();
      expect(find.text('Confirm Fetch'), findsOneWidget);
      await tester.tap(find.text('Fetch'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(recomputeCount >= 2, isTrue);
    },
    skip: !supabaseEnabled,
  );
}
