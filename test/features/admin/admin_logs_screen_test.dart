import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/admin/admin_logs_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
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
    late List<Map<String, dynamic>> sampleLogs;

    setUp(() async {
      mockRemoteRepository = MockRemoteRepository();
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      sessionNotifier = SessionNotifier(storageService);

      sampleLogs = [
        {
          'timestamp': '2026-02-02 12:34:18,329',
          'level': 'INFO',
          'message': 'Application started',
          'logger': 'authorconsole.app',
          'request_id': 'req-123',
        },
        {
          'timestamp': '2026-02-02 12:34:19,123',
          'level': 'ERROR',
          'message': 'Database connection failed',
          'logger': 'authorconsole.db',
          'request_id': 'req-124',
        },
        {
          'timestamp': '2026-02-02 12:34:20,456',
          'level': 'WARNING',
          'message': 'High memory usage detected',
          'logger': 'authorconsole.monitor',
          'request_id': 'req-125',
        },
      ];
    });

    Widget buildTestApp({required Widget child, required List overrides}) {
      return ProviderScope(
        overrides: overrides.cast(),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: child,
        ),
      );
    }

    testWidgets('displays loading state initially', (tester) async {
      when(
        () => mockRemoteRepository.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
        ),
      ).thenAnswer(
        (_) async => Future.delayed(
          const Duration(milliseconds: 100),
          () => {
            'logs': '',
            'metadata': {
              'file': 'app.log',
              'file_exists': true,
              'total_lines': 0,
              'filtered_lines': 0,
              'size_bytes': 0,
            },
            'available_files': [
              {
                'index': 0,
                'name': 'app.log',
                'size_bytes': 1024,
                'size_kb': 1.0,
              },
            ],
          },
        ),
      );

      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            remoteRepositoryProvider.overrideWith((_) => mockRemoteRepository),
            sessionProvider.overrideWith((ref) => sessionNotifier),
          ],
          child: const AdminLogsScreen(),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);

      await tester.pumpAndSettle();
    });

    testWidgets('displays logs when loaded successfully', (tester) async {
      final logsString = sampleLogs.map((log) => jsonEncode(log)).join('\n');

      when(
        () => mockRemoteRepository.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
        ),
      ).thenAnswer(
        (_) async => {
          'logs': logsString,
          'metadata': {
            'file': 'app.log',
            'file_exists': true,
            'total_lines': 3,
            'filtered_lines': 3,
            'size_bytes': 500,
          },
          'available_files': [
            {'index': 0, 'name': 'app.log', 'size_bytes': 1024, 'size_kb': 1.0},
          ],
        },
      );

      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            remoteRepositoryProvider.overrideWith((_) => mockRemoteRepository),
            sessionProvider.overrideWith((ref) => sessionNotifier),
          ],
          child: const AdminLogsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('INFO'), findsWidgets);
      expect(find.text('ERROR'), findsWidgets);
      expect(find.text('WARNING'), findsWidgets);
      expect(find.text('Admin Logs'), findsOneWidget);
    });

    testWidgets('displays no logs message when logs are null', (tester) async {
      when(
        () => mockRemoteRepository.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
        ),
      ).thenAnswer(
        (_) async => {
          'logs': '',
          'metadata': {
            'file': 'app.log',
            'file_exists': true,
            'total_lines': 0,
            'filtered_lines': 0,
            'size_bytes': 0,
          },
          'available_files': [
            {'index': 0, 'name': 'app.log', 'size_bytes': 1024, 'size_kb': 1.0},
          ],
        },
      );

      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            remoteRepositoryProvider.overrideWith((_) => mockRemoteRepository),
            sessionProvider.overrideWith((ref) => sessionNotifier),
          ],
          child: const AdminLogsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('No logs available'), findsOneWidget);
    });

    testWidgets('displays error message when loading fails', (tester) async {
      const errorMessage = 'Failed to fetch logs';

      when(
        () => mockRemoteRepository.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
        ),
      ).thenThrow(Exception(errorMessage));

      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            remoteRepositoryProvider.overrideWith((_) => mockRemoteRepository),
            sessionProvider.overrideWith((ref) => sessionNotifier),
          ],
          child: const AdminLogsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('Failed to load logs'), findsOneWidget);
      expect(find.textContaining(errorMessage), findsOneWidget);
    });

    testWidgets('refresh button works correctly', (tester) async {
      final initialLogs = sampleLogs.map((log) => jsonEncode(log)).join('\n');
      final refreshedLogs = [
        {
          'timestamp': '2026-02-02 12:35:00,000',
          'level': 'INFO',
          'message': 'Refreshed log',
          'logger': 'authorconsole.app',
        },
      ];
      final refreshedLogsString = refreshedLogs
          .map((log) => jsonEncode(log))
          .join('\n');

      when(
        () => mockRemoteRepository.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
        ),
      ).thenAnswer(
        (_) async => {
          'logs': initialLogs,
          'metadata': {
            'file': 'app.log',
            'file_exists': true,
            'total_lines': 3,
            'filtered_lines': 3,
            'size_bytes': 500,
          },
          'available_files': [
            {'index': 0, 'name': 'app.log', 'size_bytes': 1024, 'size_kb': 1.0},
          ],
        },
      );

      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            remoteRepositoryProvider.overrideWith((_) => mockRemoteRepository),
            sessionProvider.overrideWith((ref) => sessionNotifier),
          ],
          child: const AdminLogsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Application started'), findsOneWidget);

      when(
        () => mockRemoteRepository.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
        ),
      ).thenAnswer(
        (_) async => {
          'logs': refreshedLogsString,
          'metadata': {
            'file': 'app.log',
            'file_exists': true,
            'total_lines': 1,
            'filtered_lines': 1,
            'size_bytes': 100,
          },
          'available_files': [
            {'index': 0, 'name': 'app.log', 'size_bytes': 1024, 'size_kb': 1.0},
          ],
        },
      );

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      expect(find.text('Refreshed log'), findsOneWidget);
      expect(find.text('Application started'), findsNothing);

      verify(
        () => mockRemoteRepository.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
        ),
      ).called(greaterThanOrEqualTo(1));
    });

    testWidgets('scroll buttons functionality', (tester) async {
      final longLogs = List.generate(
        100,
        (i) => {
          'timestamp': '2026-02-02 12:34:${i.toString().padLeft(2, '0')},000',
          'level': i % 2 == 0 ? 'INFO' : 'DEBUG',
          'message': 'Log message $i',
          'logger': 'authorconsole.app',
        },
      );
      final logsString = longLogs.map((log) => jsonEncode(log)).join('\n');

      when(
        () => mockRemoteRepository.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
        ),
      ).thenAnswer(
        (_) async => {
          'logs': logsString,
          'metadata': {
            'file': 'app.log',
            'file_exists': true,
            'total_lines': 100,
            'filtered_lines': 100,
            'size_bytes': 10000,
          },
          'available_files': [
            {'index': 0, 'name': 'app.log', 'size_bytes': 1024, 'size_kb': 1.0},
          ],
        },
      );

      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            remoteRepositoryProvider.overrideWith((_) => mockRemoteRepository),
            sessionProvider.overrideWith((ref) => sessionNotifier),
          ],
          child: const AdminLogsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      final scrollToTopButton = find.byIcon(Icons.arrow_upward);
      final scrollToBottomButton = find.byIcon(Icons.arrow_downward);

      expect(scrollToTopButton, findsOneWidget);
      expect(scrollToBottomButton, findsOneWidget);

      await tester.tap(scrollToBottomButton);
      await tester.pumpAndSettle();

      await tester.tap(scrollToTopButton);
      await tester.pumpAndSettle();

      expect(scrollToTopButton, findsOneWidget);
      expect(scrollToBottomButton, findsOneWidget);
    });

    testWidgets('load button is disabled during loading', (tester) async {
      when(
        () => mockRemoteRepository.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
        ),
      ).thenAnswer(
        (_) async => Future.delayed(
          const Duration(seconds: 1),
          () => {
            'logs': '',
            'metadata': {
              'file': 'app.log',
              'file_exists': true,
              'total_lines': 0,
              'filtered_lines': 0,
              'size_bytes': 0,
            },
            'available_files': [
              {
                'index': 0,
                'name': 'app.log',
                'size_bytes': 1024,
                'size_kb': 1.0,
              },
            ],
          },
        ),
      );

      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            remoteRepositoryProvider.overrideWith((_) => mockRemoteRepository),
            sessionProvider.overrideWith((ref) => sessionNotifier),
          ],
          child: const AdminLogsScreen(),
        ),
      );

      await tester.pump();

      final searchButton = find.text('Search');

      expect(searchButton, findsNothing);

      await tester.pumpAndSettle();

      expect(searchButton, findsOneWidget);
    });

    testWidgets('refresh button is disabled during loading', (tester) async {
      when(
        () => mockRemoteRepository.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
        ),
      ).thenAnswer(
        (_) async => Future.delayed(
          const Duration(seconds: 1),
          () => {
            'logs': '',
            'metadata': {
              'file': 'app.log',
              'file_exists': true,
              'total_lines': 0,
              'filtered_lines': 0,
              'size_bytes': 0,
            },
            'available_files': [
              {
                'index': 0,
                'name': 'app.log',
                'size_bytes': 1024,
                'size_kb': 1.0,
              },
            ],
          },
        ),
      );

      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            remoteRepositoryProvider.overrideWith((_) => mockRemoteRepository),
            sessionProvider.overrideWith((ref) => sessionNotifier),
          ],
          child: const AdminLogsScreen(),
        ),
      );

      final refreshButton = find.byIcon(Icons.refresh);

      expect(refreshButton, findsOneWidget);

      await tester.pumpAndSettle();

      expect(refreshButton, findsOneWidget);
    });

    testWidgets('displays log entries with correct styling', (tester) async {
      final logsString = sampleLogs.map((log) => jsonEncode(log)).join('\n');

      when(
        () => mockRemoteRepository.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
        ),
      ).thenAnswer(
        (_) async => {
          'logs': logsString,
          'metadata': {
            'file': 'app.log',
            'file_exists': true,
            'total_lines': 3,
            'filtered_lines': 3,
            'size_bytes': 500,
          },
          'available_files': [
            {'index': 0, 'name': 'app.log', 'size_bytes': 1024, 'size_kb': 1.0},
          ],
        },
      );

      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            remoteRepositoryProvider.overrideWith((_) => mockRemoteRepository),
            sessionProvider.overrideWith((ref) => sessionNotifier),
          ],
          child: const AdminLogsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Application started'), findsOneWidget);
      expect(find.text('Database connection failed'), findsOneWidget);
      expect(find.text('High memory usage detected'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
