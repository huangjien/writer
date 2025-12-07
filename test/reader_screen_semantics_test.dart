import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/reader/reader_screen.dart';
import 'package:writer/l10n/app_localizations.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ReaderScreen chapter tiles have semantics labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ReaderScreen(novelId: 'novel-001'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Chapter 1: Into the Woods'), findsOneWidget);
    expect(find.bySemanticsLabel('Chapter 2: Hidden Creek'), findsOneWidget);
  });
}
