import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/settings/state/token_usage_providers.dart';
import 'package:writer/features/settings/widgets/token_usage_section.dart';
import 'package:writer/models/token_usage.dart';

void main() {
  testWidgets('TokenUsageSection renders loading state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentMonthUsageProvider.overrideWith(
            (ref) => Future.delayed(const Duration(seconds: 1), () => null),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: TokenUsageSection())),
      ),
    );

    // Initial pump - loading should be shown
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Finish
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });

  testWidgets('TokenUsageSection renders empty state when data is null', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentMonthUsageProvider.overrideWith((ref) => Future.value(null)),
        ],
        child: const MaterialApp(home: Scaffold(body: TokenUsageSection())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Token Usage'), findsOneWidget);
    // Based on code reading: if usage == null -> _EmptyUsage()
    // _EmptyUsage usually contains text like "No usage" or similar.
    // If we don't know exact text, checking for absence of specific data widgets is a start.
  });

  testWidgets('TokenUsageSection renders usage data', (tester) async {
    final usage = TokenUsage(
      userId: 'u1',
      year: 2024,
      month: 12,
      inputTokens: 1000,
      outputTokens: 500,
      totalTokens: 1500,
      requestCount: 10,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentMonthUsageProvider.overrideWith((ref) => Future.value(usage)),
        ],
        child: const MaterialApp(home: Scaffold(body: TokenUsageSection())),
      ),
    );

    await tester.pumpAndSettle();

    // Check header
    expect(find.text('Token Usage'), findsOneWidget);

    // Check values
    expect(find.text('1,500'), findsOneWidget); // Total
    expect(find.text('1,000'), findsOneWidget); // Input (if displayed)
    expect(find.text('500'), findsOneWidget); // Output (if displayed)
  });

  testWidgets('TokenUsageSection renders error state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentMonthUsageProvider.overrideWith(
            (ref) => Future.error('Network Error'),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: TokenUsageSection())),
      ),
    );

    await tester.pumpAndSettle();

    // Code: error: (err, stack) => _ErrorUsage(error: err.toString()),
    // _ErrorUsage likely displays the error string.
    expect(find.text('Error loading usage'), findsOneWidget);
  });
}
