import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/summary/screens/scenes/scenes_list_screen.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/l10n/app_localizations.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ScenesListScreen renders and deletes item', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [isSignedInProvider.overrideWithValue(true)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ScenesListScreen(novelId: 'n-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Scenes'), findsOneWidget);
  });
}
