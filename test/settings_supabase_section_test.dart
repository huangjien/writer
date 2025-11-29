import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/settings/widgets/supabase_section.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/supabase_config.dart';

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
}
