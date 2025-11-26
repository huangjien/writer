import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/settings/widgets/performance_section.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/performance_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('PerformanceSection renders correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          performanceSettingsProvider.overrideWith((_) => PerformanceSettingsNotifier(prefs)),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PerformanceSection(),
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
