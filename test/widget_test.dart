import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/app.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import 'package:writer/state/providers.dart';

void main() {
  testWidgets('App smoke test: shows Library screen', (
    WidgetTester tester,
  ) async {
    // Pump the real app wrapped in ProviderScope.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [supabaseEnabledProvider.overrideWithValue(false)],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify key UI elements from the Library screen are present.
    expect(find.text(AppLocalizationsEn().appTitle), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });
}
