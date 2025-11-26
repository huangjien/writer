import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/settings/widgets/supabase_section.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/supabase_config.dart';

void main() {
  testWidgets('SupabaseSection renders correctly when Supabase is disabled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SupabaseSection(user: null)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    if (!supabaseEnabled) {
      final l10n = AppLocalizations.of(
        tester.element(find.byType(SupabaseSection)),
      )!;
      expect(find.text(l10n.supabaseNotEnabled), findsOneWidget);
    }
  });
}
