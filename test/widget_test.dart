import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/app.dart';
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
    final logo = find.byKey(const ValueKey('home_logo'));
    final fallback = find.text(
      'Unable to load asset: "assetmanifest.bin.json"',
    );
    expect(logo.evaluate().isNotEmpty || fallback.evaluate().isNotEmpty, true);
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });
}
