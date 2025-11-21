import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/app.dart';
import 'package:novel_reader/l10n/app_localizations_en.dart';

void main() {
  testWidgets('App smoke test: shows Library screen', (
    WidgetTester tester,
  ) async {
    // Pump the real app wrapped in ProviderScope.
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    // Verify key UI elements from the Library screen are present.
    expect(find.text(AppLocalizationsEn().appTitle), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });
}
