import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/settings/widgets/supabase_section.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  testWidgets('shows disabled state when Supabase not enabled', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: SupabaseSection(user: null)),
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

  testWidgets(
    'shows enabled tiles when Supabase enabled and no user',
    (tester) async {
      if (!supabaseEnabled) return;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: SupabaseSection(user: null)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fetch from Supabase'), findsOneWidget);
      expect(
        find.text('Fetch latest novels and progress from Supabase.'),
        findsOneWidget,
      );
      expect(find.text('My Novels'), findsOneWidget);
      expect(find.text('Novels and Progress'), findsOneWidget);
    },
    skip: !supabaseEnabled,
  );

  testWidgets('fetch button disabled when no user logged in', (tester) async {
    if (!supabaseEnabled) return;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: SupabaseSection(user: null)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Fetch tile should be present but disabled (onTap is null)
    final fetchTile = find.ancestor(
      of: find.text('Fetch from Supabase'),
      matching: find.byType(ListTile),
    );
    expect(fetchTile, findsOneWidget);

    // Tapping should not open dialog
    await tester.tap(fetchTile);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  }, skip: !supabaseEnabled);

  testWidgets(
    'shows confirmation dialog when fetch tapped with user',
    (tester) async {
      if (!supabaseEnabled) return;
      // Mock user object
      final mockUser = MockUser();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: SupabaseSection(user: mockUser)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap fetch button
      await tester.tap(find.text('Fetch from Supabase'));
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Confirm Fetch'), findsOneWidget);
      expect(
        find.text('This will overwrite your local data. Are you sure?'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Fetch'), findsOneWidget);
    },
    skip: !supabaseEnabled,
  );

  testWidgets('cancel button closes dialog without action', (tester) async {
    if (!supabaseEnabled) return;
    final mockUser = MockUser();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SupabaseSection(user: mockUser)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open dialog
    await tester.tap(find.text('Fetch from Supabase'));
    await tester.pumpAndSettle();

    // Tap cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Dialog should be closed
    expect(find.byType(AlertDialog), findsNothing);
  }, skip: !supabaseEnabled);

  testWidgets('fetch button closes dialog and invalidates providers', (
    tester,
  ) async {
    if (!supabaseEnabled) return;
    final mockUser = MockUser();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SupabaseSection(user: mockUser)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open dialog
    await tester.tap(find.text('Fetch from Supabase'));
    await tester.pumpAndSettle();

    // Tap fetch
    await tester.tap(find.text('Fetch'));
    await tester.pumpAndSettle();

    // Dialog should be closed
    expect(find.byType(AlertDialog), findsNothing);
  }, skip: !supabaseEnabled);
}

class MockUser extends Mock implements User {}
