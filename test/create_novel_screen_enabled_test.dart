import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/features/library/create_novel_screen.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/storage_service_provider.dart';

void main() {
  testWidgets('Enabled path renders form and validates cover URL', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    final session = SessionNotifier(storageService);
    await session.setSessionId('test-session-id');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sessionProvider.overrideWith((_) => session)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CreateNovelScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create Novel'), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Author'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Cover URL'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(3), 'http://bad link');
    await tester.pump();
    expect(
      find.text('Enter a valid http(s) URL without spaces.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byType(TextFormField).at(3),
      'https://example.com/img.png',
    );
    await tester.pump();
    expect(
      find.text('Enter a valid http(s) URL without spaces.'),
      findsNothing,
    );
  });

  // Submission path covered in integration; keep this file focused on gating and validation.
}
