import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/features/library/create_novel_screen.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/theme_controller.dart';

// No repository needed for disabled-path gating test.

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('CreateNovelScreen shows sign-in prompt when disabled', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
          themeControllerProvider.overrideWith((_) => ThemeController(prefs)),
          sharedPreferencesProvider.overrideWithValue(prefs),
          isSignedInProvider.overrideWithValue(false),
          authStateProvider.overrideWithValue(null),
          currentUserProvider.overrideWith((ref) async => null),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CreateNovelScreen(),
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
