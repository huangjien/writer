import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/summary/snowflake_coach_widget.dart';
import 'package:writer/features/summary/snowflake_service.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/snowflake.dart';
import 'package:writer/repositories/remote_repository.dart';

class _FakeSnowflakeService extends SnowflakeService {
  _FakeSnowflakeService(this.result)
    : super(RemoteRepository('http://example.com/'));

  final SnowflakeRefinementOutput? result;
  int calls = 0;

  @override
  Future<SnowflakeRefinementOutput?> refineSummary(
    SnowflakeRefinementInput input,
  ) async {
    calls++;
    return result;
  }
}

void main() {
  testWidgets('SnowflakeCoachWidget shows error when service returns null', (
    tester,
  ) async {
    final fake = _FakeSnowflakeService(null);
    final updates = <String>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [snowflakeServiceProvider.overrideWithValue(fake)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              height: 500,
              child: SnowflakeCoachWidget(
                novelId: 'n1',
                currentSummary: 'S',
                onSummaryUpdated: updates.add,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(fake.calls, 1);
    expect(find.text('Failed to analyze'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
    expect(updates, isEmpty);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));
    await tester.pumpAndSettle();
    expect(fake.calls, 2);
  });
}
