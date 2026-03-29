import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/progress_dashboard/widgets/export_dialog.dart';

void main() {
  group('ExportDialog', () {
    late bool csvExportCalled;
    late bool reportExportCalled;

    setUp(() {
      csvExportCalled = false;
      reportExportCalled = false;
    });

    testWidgets('displays export dialog title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportDialog(onExportCSV: () {}, onExportReport: () {}),
          ),
        ),
      );

      expect(find.text('Export Data'), findsOneWidget);
      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    testWidgets('displays both export options', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportDialog(onExportCSV: () {}, onExportReport: () {}),
          ),
        ),
      );

      expect(find.text('Export as CSV'), findsOneWidget);
      expect(find.text('Generate Summary Report'), findsOneWidget);
    });

    testWidgets('calls onExportCSV when CSV option is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportDialog(
              onExportCSV: () => csvExportCalled = true,
              onExportReport: () {},
            ),
          ),
        ),
      );

      expect(csvExportCalled, false);

      await tester.tap(find.text('Export as CSV'));
      await tester.pump();

      expect(csvExportCalled, true);
    });

    testWidgets('calls onExportReport when Report option is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportDialog(
              onExportCSV: () {},
              onExportReport: () => reportExportCalled = true,
            ),
          ),
        ),
      );

      expect(reportExportCalled, false);

      await tester.tap(find.text('Generate Summary Report'));
      await tester.pump();

      expect(reportExportCalled, true);
    });

    testWidgets('displays CSV description', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportDialog(onExportCSV: () {}, onExportReport: () {}),
          ),
        ),
      );

      expect(
        find.textContaining(
          'Download your writing progress data as a CSV file',
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays report description', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportDialog(onExportCSV: () {}, onExportReport: () {}),
          ),
        ),
      );

      expect(
        find.textContaining('Create a detailed summary report'),
        findsOneWidget,
      );
    });

    testWidgets('displays CSV icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportDialog(onExportCSV: () {}, onExportReport: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.table_chart), findsOneWidget);
    });

    testWidgets('displays report icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportDialog(onExportCSV: () {}, onExportReport: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.description), findsOneWidget);
    });

    testWidgets('has cancel button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportDialog(onExportCSV: () {}, onExportReport: () {}),
          ),
        ),
      );

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('displays descriptive text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportDialog(onExportCSV: () {}, onExportReport: () {}),
          ),
        ),
      );

      expect(find.text('Choose an export format:'), findsOneWidget);
    });

    testWidgets('both options have arrow icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportDialog(onExportCSV: () {}, onExportReport: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward_ios), findsAtLeastNWidgets(2));
    });

    testWidgets('options have colored containers', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportDialog(onExportCSV: () {}, onExportReport: () {}),
          ),
        ),
      );

      expect(find.byType(InkWell), findsAtLeastNWidgets(2));
    });

    testWidgets(
      'shows "compatible with spreadsheet applications" in CSV option',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ExportDialog(onExportCSV: () {}, onExportReport: () {}),
            ),
          ),
        );

        expect(find.textContaining('spreadsheet applications'), findsOneWidget);
      },
    );

    testWidgets('shows "productivity patterns" in report option', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportDialog(onExportCSV: () {}, onExportReport: () {}),
          ),
        ),
      );

      expect(find.textContaining('productivity patterns'), findsOneWidget);
    });

    testWidgets('handles both callbacks being called in sequence', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportDialog(
              onExportCSV: () => csvExportCalled = true,
              onExportReport: () => reportExportCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Export as CSV'));
      await tester.pump();
      expect(csvExportCalled, true);

      await tester.tap(find.text('Generate Summary Report'));
      await tester.pump();
      expect(reportExportCalled, true);
    });
  });
}
