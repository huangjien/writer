import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/l10n/app_localizations.dart';
import 'package:novel_reader/features/library/create_novel_screen.dart';
import 'package:novel_reader/state/providers.dart';

// No repository needed for disabled-path gating test.

void main() {
  testWidgets('CreateNovelScreen shows sign-in prompt when disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseEnabledProvider.overrideWith((_) => false),
          supabaseSessionProvider.overrideWith((_) => null),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CreateNovelScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Sign in to sync progress across devices.'),
      findsOneWidget,
    );
    expect(find.text('Sign In'), findsOneWidget);
  });

  // Additional enabled-path submission tests can be added with a real Session
  // object if needed; for now we cover disabled-path gating.
}
