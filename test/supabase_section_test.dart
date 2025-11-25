import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/features/settings/widgets/supabase_section.dart';
import 'package:writer/state/supabase_config.dart';

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
}
