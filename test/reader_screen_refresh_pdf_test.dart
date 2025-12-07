import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/reader/reader_screen.dart';
import 'package:writer/l10n/app_localizations.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ReaderScreen refresh button shows and hides spinner', (
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
    expect(find.byIcon(Icons.refresh), findsOneWidget);

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('ReaderScreen generates PDF without throwing', (tester) async {
    const MethodChannel printing = MethodChannel('net.nfet.printing');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(printing, (MethodCall methodCall) async {
          if (methodCall.method == 'sharePdf') {
            return true;
          }
          return null;
        });

    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(printing, null);
    });

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
    expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);

    await tester.tap(find.byIcon(Icons.picture_as_pdf));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
  });
}
