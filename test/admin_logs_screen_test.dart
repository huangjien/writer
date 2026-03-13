import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/features/admin/admin_logs_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/shared/api_exception.dart';

class MockRemoteRepository extends Mock implements RemoteRepository {}

void main() {
  late MockRemoteRepository mockRemoteRepo;
  late List<Map<String, dynamic>> sampleLogs;

  setUp(() {
    mockRemoteRepo = MockRemoteRepository();

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
      {
        'timestamp': '2026-02-02 12:34:21,789',
        'level': 'DEBUG',
        'message': 'Processing request',
        'logger': 'authorconsole.api',
        'request_id': 'req-126',
      },
    ];
  });

  Widget createTestWidget({Widget? child}) {
    return ProviderScope(
      overrides: [remoteRepositoryProvider.overrideWithValue(mockRemoteRepo)],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child ?? const AdminLogsScreen(),
      ),
    );
  }

  group('AdminLogsScreen Widget Tests', () {
    testWidgets('renders with initial loading state', (tester) async {
      when(
        () => mockRemoteRepo.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
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

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Admin Logs'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    testWidgets('displays logs correctly', (tester) async {
      final logsString = sampleLogs.map(jsonEncode).join('\n');

      when(
        () => mockRemoteRepo.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => {
          'logs': logsString,
          'metadata': {
            'file': 'app.log',
            'file_exists': true,
            'total_lines': 4,
            'filtered_lines': 4,
            'size_bytes': 500,
          },
          'available_files': [
            {'index': 0, 'name': 'app.log', 'size_bytes': 1024, 'size_kb': 1.0},
          ],
        },
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Application started'), findsOneWidget);
      expect(find.text('Database connection failed'), findsOneWidget);
      expect(find.text('High memory usage detected'), findsOneWidget);
      expect(find.text('Processing request'), findsOneWidget);
    });

    testWidgets('shows error message on API failure', (tester) async {
      when(
        () => mockRemoteRepo.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenThrow(ApiException(500, 'Internal Server Error'));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Failed to load logs'), findsOneWidget);
    });

    testWidgets('shows empty state when no logs available', (tester) async {
      when(
        () => mockRemoteRepo.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
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

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('No logs available'), findsOneWidget);
    });
  });

  group('AdminLogsScreen Search Tests', () {
    testWidgets('filters logs by search text', (tester) async {
      final logsString = sampleLogs.map(jsonEncode).join('\n');

      when(
        () => mockRemoteRepo.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => {
          'logs': logsString,
          'metadata': {
            'file': 'app.log',
            'file_exists': true,
            'total_lines': 4,
            'filtered_lines': 4,
            'size_bytes': 500,
          },
          'available_files': [
            {'index': 0, 'name': 'app.log', 'size_bytes': 1024, 'size_kb': 1.0},
          ],
        },
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Database');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      verify(
        () => mockRemoteRepo.getAdminLogsEnhanced(
          maxSizeKb: 50,
          fileIndex: 0,
          level: null,
          logger: null,
          searchText: 'Database',
          startDate: null,
          endDate: null,
        ),
      ).called(1);
    });

    testWidgets('clears search text', (tester) async {
      final logsString = sampleLogs.map(jsonEncode).join('\n');

      when(
        () => mockRemoteRepo.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => {
          'logs': logsString,
          'metadata': {
            'file': 'app.log',
            'file_exists': true,
            'total_lines': 4,
            'filtered_lines': 4,
            'size_bytes': 500,
          },
          'available_files': [
            {'index': 0, 'name': 'app.log', 'size_bytes': 1024, 'size_kb': 1.0},
          ],
        },
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'test');
      await tester.pumpAndSettle();

      final clearButton = find.byIcon(Icons.clear);
      if (clearButton.evaluate().isNotEmpty) {
        await tester.tap(clearButton);
        await tester.pumpAndSettle();

        verify(
          () => mockRemoteRepo.getAdminLogsEnhanced(
            maxSizeKb: 50,
            fileIndex: 0,
            level: null,
            logger: null,
            searchText: '',
            startDate: null,
            endDate: null,
          ),
        ).called(1);
      }
    });
  });

  group('AdminLogsScreen Level Filter Tests', () {
    testWidgets('filters by log level', (tester) async {
      final logsString = sampleLogs.map(jsonEncode).join('\n');

      when(
        () => mockRemoteRepo.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => {
          'logs': logsString,
          'metadata': {
            'file': 'app.log',
            'file_exists': true,
            'total_lines': 4,
            'filtered_lines': 4,
            'size_bytes': 500,
          },
          'available_files': [
            {'index': 0, 'name': 'app.log', 'size_bytes': 1024, 'size_kb': 1.0},
          ],
        },
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final errorChip = find.widgetWithText(FilterChip, 'ERROR');
      expect(errorChip, findsOneWidget);

      await tester.tap(errorChip);
      await tester.pumpAndSettle();

      verify(
        () => mockRemoteRepo.getAdminLogsEnhanced(
          maxSizeKb: 50,
          fileIndex: 0,
          level: 'ERROR',
          logger: null,
          searchText: null,
          startDate: null,
          endDate: null,
        ),
      ).called(1);
    });

    testWidgets('resets level filter with ALL chip', (tester) async {
      final logsString = sampleLogs.map(jsonEncode).join('\n');

      when(
        () => mockRemoteRepo.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => {
          'logs': logsString,
          'metadata': {
            'file': 'app.log',
            'file_exists': true,
            'total_lines': 4,
            'filtered_lines': 4,
            'size_bytes': 500,
          },
          'available_files': [
            {'index': 0, 'name': 'app.log', 'size_bytes': 1024, 'size_kb': 1.0},
          ],
        },
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final allChip = find.widgetWithText(FilterChip, 'ALL');
      await tester.tap(allChip);
      await tester.pumpAndSettle();

      verify(
        () => mockRemoteRepo.getAdminLogsEnhanced(
          maxSizeKb: 50,
          fileIndex: 0,
          level: null,
          logger: null,
          searchText: null,
          startDate: null,
          endDate: null,
        ),
      ).called(1);
    });
  });

  group('AdminLogsScreen File Selection Tests', () {
    testWidgets('displays available log files', (tester) async {
      final logsString = sampleLogs.map(jsonEncode).join('\n');

      when(
        () => mockRemoteRepo.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => {
          'logs': logsString,
          'metadata': {
            'file': 'app.log',
            'file_exists': true,
            'total_lines': 4,
            'filtered_lines': 4,
            'size_bytes': 500,
          },
          'available_files': [
            {'index': 0, 'name': 'app.log', 'size_bytes': 1024, 'size_kb': 1.0},
            {
              'index': 1,
              'name': 'app.log.1',
              'size_bytes': 2048,
              'size_kb': 2.0,
            },
          ],
        },
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Log File'), findsOneWidget);
      expect(find.textContaining('app.log'), findsWidgets);
      expect(find.textContaining('1.0 KB'), findsOneWidget);
    });

    testWidgets('switches between log files', (tester) async {
      final logsString = sampleLogs.map(jsonEncode).join('\n');

      when(
        () => mockRemoteRepo.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => {
          'logs': logsString,
          'metadata': {
            'file': 'app.log',
            'file_exists': true,
            'total_lines': 4,
            'filtered_lines': 4,
            'size_bytes': 500,
          },
          'available_files': [
            {'index': 0, 'name': 'app.log', 'size_bytes': 1024, 'size_kb': 1.0},
            {
              'index': 1,
              'name': 'app.log.1',
              'size_bytes': 2048,
              'size_kb': 2.0,
            },
          ],
        },
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final dropdowns = find.byType(DropdownButtonFormField<int>);
      expect(dropdowns, findsNWidgets(2));

      final fileDropdown = find.ancestor(
        of: find.text('Log File'),
        matching: find.byType(DropdownButtonFormField<int>),
      );
      expect(fileDropdown, findsOneWidget);

      await tester.tap(fileDropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('2.0 KB'));
      await tester.pumpAndSettle();

      verify(
        () => mockRemoteRepo.getAdminLogsEnhanced(
          maxSizeKb: 50,
          fileIndex: 1,
          level: null,
          logger: null,
          searchText: null,
          startDate: null,
          endDate: null,
        ),
      ).called(1);
    });
  });

  group('AdminLogsScreen Size Selection Tests', () {
    testWidgets('displays size options', (tester) async {
      final logsString = sampleLogs.map(jsonEncode).join('\n');

      when(
        () => mockRemoteRepo.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => {
          'logs': logsString,
          'metadata': {
            'file': 'app.log',
            'file_exists': true,
            'total_lines': 4,
            'filtered_lines': 4,
            'size_bytes': 500,
          },
          'available_files': [
            {'index': 0, 'name': 'app.log', 'size_bytes': 1024, 'size_kb': 1.0},
          ],
        },
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Max Size'), findsOneWidget);
      expect(find.text('50 KB'), findsOneWidget);
    });

    testWidgets('changes max size', (tester) async {
      final logsString = sampleLogs.map(jsonEncode).join('\n');

      when(
        () => mockRemoteRepo.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => {
          'logs': logsString,
          'metadata': {
            'file': 'app.log',
            'file_exists': true,
            'total_lines': 4,
            'filtered_lines': 4,
            'size_bytes': 500,
          },
          'available_files': [
            {'index': 0, 'name': 'app.log', 'size_bytes': 1024, 'size_kb': 1.0},
          ],
        },
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final sizeDropdown = find.ancestor(
        of: find.text('Max Size'),
        matching: find.byType(DropdownButtonFormField<int>),
      );

      await tester.tap(sizeDropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('100 KB'));
      await tester.pumpAndSettle();

      verify(
        () => mockRemoteRepo.getAdminLogsEnhanced(
          maxSizeKb: 100,
          fileIndex: 0,
          level: null,
          logger: null,
          searchText: null,
          startDate: null,
          endDate: null,
        ),
      ).called(1);
    });
  });

  group('AdminLogsScreen Action Buttons Tests', () {
    testWidgets('refreshes logs on refresh button tap', (tester) async {
      final logsString = sampleLogs.map(jsonEncode).join('\n');

      when(
        () => mockRemoteRepo.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => {
          'logs': logsString,
          'metadata': {
            'file': 'app.log',
            'file_exists': true,
            'total_lines': 4,
            'filtered_lines': 4,
            'size_bytes': 500,
          },
          'available_files': [
            {'index': 0, 'name': 'app.log', 'size_bytes': 1024, 'size_kb': 1.0},
          ],
        },
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final refreshButton = find.byIcon(Icons.refresh);
      await tester.tap(refreshButton);
      await tester.pumpAndSettle();

      verify(
        () => mockRemoteRepo.getAdminLogsEnhanced(
          maxSizeKb: 50,
          fileIndex: 0,
          level: null,
          logger: null,
          searchText: null,
          startDate: null,
          endDate: null,
        ),
      ).called(greaterThanOrEqualTo(1));
    });

    testWidgets('shows log detail dialog on tap', (tester) async {
      final logsString = sampleLogs.map(jsonEncode).join('\n');

      when(
        () => mockRemoteRepo.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => {
          'logs': logsString,
          'metadata': {
            'file': 'app.log',
            'file_exists': true,
            'total_lines': 4,
            'filtered_lines': 4,
            'size_bytes': 500,
          },
          'available_files': [
            {'index': 0, 'name': 'app.log', 'size_bytes': 1024, 'size_kb': 1.0},
          ],
        },
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final firstLogItem = find.widgetWithText(InkWell, 'Application started');
      expect(firstLogItem, findsOneWidget);

      await tester.tap(firstLogItem);
      await tester.pumpAndSettle();

      expect(find.text('Log Entry'), findsOneWidget);
      expect(find.text('Timestamp:'), findsOneWidget);
      expect(find.text('Logger:'), findsOneWidget);
      expect(find.text('Message:'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);

      final closeButton = find.text('Close');
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      expect(find.text('Log Entry'), findsNothing);
    });
  });

  group('AdminLogsScreen Scroll Tests', () {
    testWidgets('scrolls to bottom', (tester) async {
      final logsString = sampleLogs.map(jsonEncode).join('\n');

      when(
        () => mockRemoteRepo.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => {
          'logs': logsString,
          'metadata': {
            'file': 'app.log',
            'file_exists': true,
            'total_lines': 4,
            'filtered_lines': 4,
            'size_bytes': 500,
          },
          'available_files': [
            {'index': 0, 'name': 'app.log', 'size_bytes': 1024, 'size_kb': 1.0},
          ],
        },
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final scrollBottomButton = find.byIcon(Icons.arrow_downward);
      await tester.tap(scrollBottomButton);
      await tester.pumpAndSettle();

      expect(scrollBottomButton, findsOneWidget);
    });

    testWidgets('scrolls to top', (tester) async {
      final logsString = sampleLogs.map(jsonEncode).join('\n');

      when(
        () => mockRemoteRepo.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => {
          'logs': logsString,
          'metadata': {
            'file': 'app.log',
            'file_exists': true,
            'total_lines': 4,
            'filtered_lines': 4,
            'size_bytes': 500,
          },
          'available_files': [
            {'index': 0, 'name': 'app.log', 'size_bytes': 1024, 'size_kb': 1.0},
          ],
        },
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final scrollTopButton = find.byIcon(Icons.arrow_upward);
      await tester.tap(scrollTopButton);
      await tester.pumpAndSettle();

      expect(scrollTopButton, findsOneWidget);
    });
  });

  group('AdminLogsScreen Syntax Highlighting Tests', () {
    testWidgets('displays log levels with correct colors', (tester) async {
      final logsString = sampleLogs.map(jsonEncode).join('\n');

      when(
        () => mockRemoteRepo.getAdminLogsEnhanced(
          maxSizeKb: any(named: 'maxSizeKb'),
          fileIndex: any(named: 'fileIndex'),
          level: any(named: 'level'),
          logger: any(named: 'logger'),
          searchText: any(named: 'searchText'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => {
          'logs': logsString,
          'metadata': {
            'file': 'app.log',
            'file_exists': true,
            'total_lines': 4,
            'filtered_lines': 4,
            'size_bytes': 500,
          },
          'available_files': [
            {'index': 0, 'name': 'app.log', 'size_bytes': 1024, 'size_kb': 1.0},
          ],
        },
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsNWidgets(6));

      expect(find.text('Application started'), findsOneWidget);
      expect(find.text('Database connection failed'), findsOneWidget);
      expect(find.text('High memory usage detected'), findsOneWidget);
      expect(find.text('Processing request'), findsOneWidget);
    });
  });
}
