import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/l10n/app_localizations.dart';
import 'package:novel_reader/features/settings/widgets/performance_section.dart';

void main() {
  testWidgets('PerformanceSection renders prefetch and clear cache controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(child: PerformanceSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Performance Settings'), findsOneWidget);
    expect(find.text('Prefetch next chapter'), findsOneWidget);
    expect(find.text('Clear offline cache'), findsOneWidget);
  });
}
