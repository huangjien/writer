import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/shared/widgets/error_boundary.dart';
import 'package:writer/shared/widgets/error_view.dart';

void main() {
  testWidgets('ErrorBoundary restores ErrorWidget.builder on dispose', (
    tester,
  ) async {
    final previous = ErrorWidget.builder;

    await tester.pumpWidget(
      const MaterialApp(home: ErrorBoundary(child: SizedBox())),
    );

    expect(ErrorWidget.builder, isNot(same(previous)));

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump();

    expect(ErrorWidget.builder, same(previous));
  });

  testWidgets('ErrorBoundary renders fallback and recovers on retry', (
    tester,
  ) async {
    _ThrowOnceWidget.thrown = false;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: ErrorBoundary(child: _ThrowOnceWidget())),
      ),
    );

    expect(tester.takeException(), isNotNull);
    await tester.pump();

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorView), findsNothing);
    expect(find.text('OK'), findsOneWidget);
  });
}

class _ThrowOnceWidget extends StatelessWidget {
  const _ThrowOnceWidget();

  static bool thrown = false;

  @override
  Widget build(BuildContext context) {
    if (!thrown) {
      thrown = true;
      throw StateError('boom');
    }
    return const Text('OK');
  }
}
