import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/library/my_novels_screen.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/l10n/app_localizations.dart';

void main() {
  testWidgets('MyNovelsScreen shows noSupabase when disabled', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [supabaseEnabledProvider.overrideWith((_) => false)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MyNovelsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text(
        AppLocalizations.of(tester.element(find.byType(Scaffold)))!.noSupabase,
      ),
      findsOneWidget,
    );
  });
}
