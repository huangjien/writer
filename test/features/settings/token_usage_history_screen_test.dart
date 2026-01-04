import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/settings/token_usage_history_screen.dart';
import 'package:writer/features/settings/state/token_usage_providers.dart';
import 'package:writer/models/token_usage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:writer/l10n/app_localizations.dart';

void main() {
  testWidgets('TokenUsageHistoryScreen shows loading indicator initially', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          usageHistoryProvider(
            UsageHistoryParams(limit: 50, offset: 0),
          ).overrideWith((ref) => Future.value(null)),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: TokenUsageHistoryScreen(),
        ),
      ),
    );

    // Verify loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('TokenUsageHistoryScreen shows list of records', (tester) async {
    final history = TokenUsageHistory(
      records: [
        TokenUsageRecord(
          operationType: 'chat',
          modelName: 'gpt-4',
          inputTokens: 10,
          outputTokens: 20,
          createdAt: DateTime(2023, 1, 1, 10, 0),
        ),
        TokenUsageRecord(
          operationType: 'completion',
          modelName: 'gpt-3.5',
          inputTokens: 5,
          outputTokens: 5,
          createdAt: DateTime(2023, 1, 1, 11, 0),
        ),
      ],
      totalCount: 2,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          usageHistoryProvider(
            UsageHistoryParams(limit: 50, offset: 0),
          ).overrideWith((ref) => Future.value(history)),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: TokenUsageHistoryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('gpt-4'), findsOneWidget);
    expect(find.text('gpt-3.5'), findsOneWidget);
    // 30 total tokens for first record
    expect(find.textContaining('30'), findsOneWidget);
    // 10 total tokens for second record, plus '10' in date, plus '10' input tokens in first record?
    // First record: input 10.
    // Second record: total 10.
    // Date: 10:00:00.
    expect(find.textContaining('10'), findsAtLeastNWidgets(1));
  });

  testWidgets('TokenUsageHistoryScreen shows empty state when no records', (
    tester,
  ) async {
    final history = TokenUsageHistory(records: [], totalCount: 0);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          usageHistoryProvider(
            UsageHistoryParams(limit: 50, offset: 0),
          ).overrideWith((ref) => Future.value(history)),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: TokenUsageHistoryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('gpt-4'), findsNothing);
    expect(find.byIcon(Icons.history), findsOneWidget);
  });

  testWidgets('TokenUsageHistoryScreen shows error state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          usageHistoryProvider(
            UsageHistoryParams(limit: 50, offset: 0),
          ).overrideWith((ref) => Future.error('Network error')),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: TokenUsageHistoryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Network error'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('TokenUsageHistoryScreen refreshes on button press', (
    tester,
  ) async {
    // Initial state: empty
    var returnData = false;

    final container = ProviderContainer(
      overrides: [
        usageHistoryProvider(
          UsageHistoryParams(limit: 50, offset: 0),
        ).overrideWith((ref) {
          if (returnData) {
            return Future.value(
              TokenUsageHistory(
                records: [
                  TokenUsageRecord(
                    operationType: 'chat',
                    modelName: 'gpt-4',
                    inputTokens: 10,
                    outputTokens: 20,
                    createdAt: DateTime.now(),
                  ),
                ],
                totalCount: 1,
              ),
            );
          }
          return Future.value(TokenUsageHistory(records: [], totalCount: 0));
        }),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: TokenUsageHistoryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.history), findsOneWidget);

    // Update flag to return data on next call
    returnData = true;

    // Tap refresh
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();

    // Should now show the record
    expect(find.text('gpt-4'), findsOneWidget);
  });
}
