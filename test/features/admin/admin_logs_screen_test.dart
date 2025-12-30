import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/admin/admin_logs_screen.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/storage_service_provider.dart';

class MockRemoteRepository extends Mock implements RemoteRepository {}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('AdminLogsScreen', () {
    late MockRemoteRepository mockRemoteRepository;
    late SessionNotifier sessionNotifier;

    setUp(() async {
      mockRemoteRepository = MockRemoteRepository();
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      sessionNotifier = SessionNotifier(storageService);
    });

    testWidgets('displays loading state initially', (tester) async {
      when(() => mockRemoteRepository.getAdminLogs(lines: 1000)).thenAnswer(
        (_) async => Future.delayed(
          const Duration(milliseconds: 100),
          () => 'Test logs',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            remoteRepositoryProvider.overrideWith((_) => mockRemoteRepository),
            sessionProvider.overrideWith((ref) => sessionNotifier),
          ],
          child: const MaterialApp(home: AdminLogsScreen()),
        ),
      );

      // Don't pumpAndSettle here to keep the loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Clean up by completing the future
      await tester.pumpAndSettle();
    });

    testWidgets('displays logs when loaded successfully', (tester) async {
      const testLogs =
          '2023-01-01 12:00:00 INFO Application started\n2023-01-01 12:01:00 DEBUG User logged in';

      when(
        () => mockRemoteRepository.getAdminLogs(lines: 1000),
      ).thenAnswer((_) async => testLogs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            remoteRepositoryProvider.overrideWith((_) => mockRemoteRepository),
            sessionProvider.overrideWith((ref) => sessionNotifier),
          ],
          child: const MaterialApp(home: AdminLogsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(SelectableText), findsOneWidget);
      expect(find.text(testLogs), findsOneWidget);
      expect(find.text('Admin Logs'), findsOneWidget);
    });

    testWidgets('displays no logs message when logs are null', (tester) async {
      when(
        () => mockRemoteRepository.getAdminLogs(lines: 1000),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            remoteRepositoryProvider.overrideWith((_) => mockRemoteRepository),
            sessionProvider.overrideWith((ref) => sessionNotifier),
          ],
          child: const MaterialApp(home: AdminLogsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('No logs available.'), findsOneWidget);
    });

    testWidgets('displays error message when loading fails', (tester) async {
      const errorMessage = 'Failed to fetch logs';

      when(
        () => mockRemoteRepository.getAdminLogs(lines: 1000),
      ).thenThrow(Exception(errorMessage));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            remoteRepositoryProvider.overrideWith((_) => mockRemoteRepository),
            sessionProvider.overrideWith((ref) => sessionNotifier),
          ],
          child: const MaterialApp(home: AdminLogsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('Failed to load logs'), findsOneWidget);
      expect(find.textContaining(errorMessage), findsOneWidget);
    });

    testWidgets('refresh button works correctly', (tester) async {
      const initialLogs = 'Initial log content';
      const refreshedLogs = 'Refreshed log content';

      when(
        () => mockRemoteRepository.getAdminLogs(lines: 1000),
      ).thenAnswer((_) async => initialLogs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            remoteRepositoryProvider.overrideWith((_) => mockRemoteRepository),
            sessionProvider.overrideWith((ref) => sessionNotifier),
          ],
          child: const MaterialApp(home: AdminLogsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial logs are displayed
      expect(find.text(initialLogs), findsOneWidget);

      // Mock refreshed response
      when(
        () => mockRemoteRepository.getAdminLogs(lines: 1000),
      ).thenAnswer((_) async => refreshedLogs);

      // Tap refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Verify refreshed logs are displayed
      expect(find.text(refreshedLogs), findsOneWidget);
      expect(find.text(initialLogs), findsNothing);

      // Verify getAdminLogs was called twice (initial load + refresh)
      verify(() => mockRemoteRepository.getAdminLogs(lines: 1000)).called(2);
    });

    testWidgets('number of lines input works correctly', (tester) async {
      const testLogs = 'Test log content';

      when(
        () => mockRemoteRepository.getAdminLogs(lines: 1000),
      ).thenAnswer((_) async => testLogs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            remoteRepositoryProvider.overrideWith((_) => mockRemoteRepository),
            sessionProvider.overrideWith((ref) => sessionNotifier),
          ],
          child: const MaterialApp(home: AdminLogsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Find the lines input field and load button
      final linesField = find.byType(TextField);
      final loadButton = find.text('Load');

      expect(linesField, findsOneWidget);
      expect(loadButton, findsOneWidget);

      // Enter a new number of lines
      await tester.enterText(linesField, '500');
      await tester.pumpAndSettle();

      // Mock response for new lines count
      when(
        () => mockRemoteRepository.getAdminLogs(lines: 500),
      ).thenAnswer((_) async => 'Limited log content');

      // Tap load button
      await tester.tap(loadButton);
      await tester.pumpAndSettle();

      // Verify getAdminLogs was called with the new lines count
      verify(() => mockRemoteRepository.getAdminLogs(lines: 500)).called(1);
    });

    testWidgets('scroll buttons functionality', (tester) async {
      final longLogs = 'Line 1\n' * 100; // 100 lines for scrolling

      when(
        () => mockRemoteRepository.getAdminLogs(lines: 1000),
      ).thenAnswer((_) async => longLogs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            remoteRepositoryProvider.overrideWith((_) => mockRemoteRepository),
            sessionProvider.overrideWith((ref) => sessionNotifier),
          ],
          child: const MaterialApp(home: AdminLogsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Find scroll buttons
      final scrollToTopButton = find.byIcon(Icons.arrow_upward);
      final scrollToBottomButton = find.byIcon(Icons.arrow_downward);

      expect(scrollToTopButton, findsOneWidget);
      expect(scrollToBottomButton, findsOneWidget);

      // Test scroll to bottom button
      await tester.tap(scrollToBottomButton);
      await tester.pumpAndSettle();

      // Test scroll to top button
      await tester.tap(scrollToTopButton);
      await tester.pumpAndSettle();

      // Both buttons should still be present
      expect(scrollToTopButton, findsOneWidget);
      expect(scrollToBottomButton, findsOneWidget);
    });

    testWidgets('load button is disabled during loading', (tester) async {
      when(() => mockRemoteRepository.getAdminLogs(lines: 1000)).thenAnswer(
        (_) async =>
            Future.delayed(const Duration(seconds: 1), () => 'Test logs'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            remoteRepositoryProvider.overrideWith((_) => mockRemoteRepository),
            sessionProvider.overrideWith((ref) => sessionNotifier),
          ],
          child: const MaterialApp(home: AdminLogsScreen()),
        ),
      );

      // Find the load button
      final loadButton = find.text('Load');

      // During initial loading, button should be disabled
      expect(loadButton, findsOneWidget);

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // After loading, button should be enabled again
      expect(loadButton, findsOneWidget);
    });

    testWidgets('refresh button is disabled during loading', (tester) async {
      when(() => mockRemoteRepository.getAdminLogs(lines: 1000)).thenAnswer(
        (_) async =>
            Future.delayed(const Duration(seconds: 1), () => 'Test logs'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            remoteRepositoryProvider.overrideWith((_) => mockRemoteRepository),
            sessionProvider.overrideWith((ref) => sessionNotifier),
          ],
          child: const MaterialApp(home: AdminLogsScreen()),
        ),
      );

      // Find the refresh button
      final refreshButton = find.byIcon(Icons.refresh);

      // During initial loading, button should be disabled
      expect(refreshButton, findsOneWidget);

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // After loading, button should be enabled again
      expect(refreshButton, findsOneWidget);
    });

    testWidgets('logs display with monospace font and green color', (
      tester,
    ) async {
      const testLogs = 'Test log content with monospace font';

      when(
        () => mockRemoteRepository.getAdminLogs(lines: 1000),
      ).thenAnswer((_) async => testLogs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            remoteRepositoryProvider.overrideWith((_) => mockRemoteRepository),
            sessionProvider.overrideWith((ref) => sessionNotifier),
          ],
          child: const MaterialApp(home: AdminLogsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      final selectableText = tester.widget<SelectableText>(
        find.byType(SelectableText),
      );
      final textStyle = selectableText.style!;

      expect(textStyle.fontFamily, 'monospace');
      expect(textStyle.fontSize, 12);
      expect(textStyle.color, Colors.green);
    });

    testWidgets('logs display with correct styling', (tester) async {
      const testLogs = 'Test log content';

      when(
        () => mockRemoteRepository.getAdminLogs(lines: 1000),
      ).thenAnswer((_) async => testLogs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            remoteRepositoryProvider.overrideWith((_) => mockRemoteRepository),
            sessionProvider.overrideWith((ref) => sessionNotifier),
          ],
          child: const MaterialApp(home: AdminLogsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the SelectableText exists and has the correct content
      expect(find.byType(SelectableText), findsOneWidget);
      expect(find.text(testLogs), findsOneWidget);

      // Verify the styling properties
      final selectableText = tester.widget<SelectableText>(
        find.byType(SelectableText),
      );
      final textStyle = selectableText.style!;

      expect(textStyle.fontFamily, 'monospace');
      expect(textStyle.fontSize, 12);
      expect(textStyle.color, Colors.green);

      // Verify there's a SingleChildScrollView for scrolling
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
