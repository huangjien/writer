import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/utils/open_url.dart';

void main() {
  testWidgets('openUrl shows invalid link snackbar for non-http urls', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
    );

    await openUrl(tester.element(find.byType(SizedBox)), 'not-a-url');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Invalid link'), findsOneWidget);
  });

  testWidgets('openUrl shows unable to open snackbar when launch fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
    );

    await openUrl(
      tester.element(find.byType(SizedBox)),
      'https://example.com',
      launcher: (_) async => false,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Unable to open link'), findsOneWidget);
  });
}
