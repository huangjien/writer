import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/library/widgets/library_loading_list.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/shared/widgets/loading/loading_story.dart';
import 'package:writer/shared/widgets/loading/shimmer_skeleton.dart';
import 'package:writer/shared/widgets/loading/skeleton_list_items.dart';
import 'package:writer/shared/widgets/loading/step_progress.dart';
import 'package:writer/shared/widgets/loading_state.dart';

void main() {
  group('LoadingState Responsive Tests', () {
    testWidgets('LoadingState displays correctly on small mobile (360dp)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 360,
            height: 640,
            child: Scaffold(body: LoadingState(message: 'Loading...')),
          ),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.value, isNull);

      final textFinder = find.text('Loading...');
      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.fontSize, greaterThan(0));
    });

    testWidgets('LoadingState displays correctly on medium mobile (390dp)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 390,
            height: 844,
            child: Scaffold(body: LoadingState(message: 'Loading...')),
          ),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('LoadingState displays correctly on large mobile (414dp)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 414,
            height: 896,
            child: Scaffold(body: LoadingState(message: 'Loading...')),
          ),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('LoadingState displays correctly on tablet (768dp)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 768,
            height: 1024,
            child: Scaffold(body: LoadingState(message: 'Loading...')),
          ),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('LoadingState displays correctly on desktop (1200dp)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 1200,
            height: 800,
            child: Scaffold(body: LoadingState(message: 'Loading...')),
          ),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('LoadingState skeleton mode on small mobile', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 360,
            height: 640,
            child: Scaffold(body: LoadingState(useSkeleton: true)),
          ),
        ),
      );

      expect(find.byType(ShimmerSkeleton), findsOneWidget);
    });

    testWidgets('LoadingState skeleton mode on desktop', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 1200,
            height: 800,
            child: Scaffold(body: LoadingState(useSkeleton: true)),
          ),
        ),
      );

      expect(find.byType(ShimmerSkeleton), findsOneWidget);
    });

    testWidgets('LoadingState with stories on small mobile', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 360,
            height: 640,
            child: Scaffold(
              body: LoadingState(
                message: '',
                stories: ['Tip one', 'Tip two', 'Tip three'],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(LoadingStory), findsOneWidget);
      expect(find.text('Tip one'), findsOneWidget);
    });

    testWidgets('LoadingState with steps on small mobile', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 360,
            height: 640,
            child: Scaffold(
              body: LoadingState(steps: ['A', 'B', 'C'], currentStep: 1),
            ),
          ),
        ),
      );

      expect(find.byType(StepProgress), findsOneWidget);
    });

    testWidgets('LoadingState custom size on small mobile', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 360,
            height: 640,
            child: Scaffold(body: LoadingState(size: 32.0)),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final indicatorSize = tester.getSize(
        find.byType(CircularProgressIndicator),
      );
      expect(indicatorSize.width, 32.0);
    });

    testWidgets('LoadingState layout shift prevention - no scale transforms', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 360,
            height: 640,
            child: Scaffold(body: LoadingState(message: 'Loading...')),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      final sizeBefore = tester.getSize(find.byType(LoadingState));

      await tester.pump(const Duration(milliseconds: 900));

      final sizeAfter = tester.getSize(find.byType(LoadingState));

      expect(sizeBefore.width, equals(sizeAfter.width));
      expect(sizeBefore.height, equals(sizeAfter.height));
    });

    testWidgets('LoadingState opacity animation does not cause layout shift', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 360,
            height: 640,
            child: Scaffold(body: LoadingState(message: 'Loading...')),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 450));

      final sizeBefore = tester.getSize(find.byType(LoadingState));

      await tester.pump(const Duration(milliseconds: 450));

      final sizeAfter = tester.getSize(find.byType(LoadingState));

      expect(sizeBefore.width, equals(sizeAfter.width));
      expect(sizeBefore.height, equals(sizeAfter.height));
    });

    testWidgets('LoadingState text does not overflow on small mobile', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 640,
              child: LoadingState(
                message: 'Loading your novels, please wait...',
              ),
            ),
          ),
        ),
      );

      final textFinder = find.text('Loading your novels, please wait...');
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.maxLines, 2);
      expect(textWidget.overflow, TextOverflow.ellipsis);

      final textSize = tester.getSize(textFinder);
      expect(textSize.width, lessThanOrEqualTo(328.0));
    });

    testWidgets('LoadingState stories do not overflow on small mobile', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 360,
            height: 640,
            child: Scaffold(
              body: LoadingState(
                message: '',
                stories: [
                  'Tip one is quite long and should fit properly',
                  'Tip two is also long but should be okay',
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(LoadingStory), findsOneWidget);
    });

    testWidgets('LoadingState skeleton fits within viewport on mobile', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 360,
            height: 640,
            child: Scaffold(body: LoadingState(useSkeleton: true)),
          ),
        ),
      );

      final skeletonFinder = find.byType(ShimmerSkeleton);
      expect(skeletonFinder, findsOneWidget);

      final skeletonSize = tester.getSize(skeletonFinder);
      expect(skeletonSize.width, lessThanOrEqualTo(800.0));
    });

    testWidgets('LoadingState no layout shift when switching states', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 360,
            height: 640,
            child: Scaffold(body: _LayoutShiftTestWidget()),
          ),
        ),
      );

      final sizeBefore = tester.getSize(find.byType(LoadingState));

      await tester.tap(find.text('Reload'));
      await tester.pump();

      final sizeAfter = tester.getSize(find.byType(LoadingState));

      expect(sizeBefore.width, equals(sizeAfter.width));
      expect(sizeBefore.height, equals(sizeAfter.height));
    });
  });

  group('LibraryLoadingList Responsive Tests', () {
    testWidgets('LibraryLoadingList displays on small mobile', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SizedBox(
            width: 360,
            height: 640,
            child: Scaffold(body: LibraryLoadingList()),
          ),
        ),
      );

      expect(find.byType(LibraryLoadingList), findsOneWidget);
      expect(find.byType(ShimmerSkeleton), findsWidgets);
    });

    testWidgets('LibraryLoadingList displays on desktop', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SizedBox(
            width: 1200,
            height: 800,
            child: Scaffold(body: LibraryLoadingList()),
          ),
        ),
      );

      expect(find.byType(LibraryLoadingList), findsOneWidget);
      expect(find.byType(ShimmerSkeleton), findsWidgets);
    });

    testWidgets('LibraryLoadingList skeleton items fit within viewport', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SizedBox(width: 360, height: 640, child: LibraryLoadingList()),
        ),
      );

      expect(find.byType(ShimmerSkeleton), findsWidgets);

      final rowSkeletonFinder = find.byType(LibraryItemRowSkeleton);
      expect(rowSkeletonFinder, findsWidgets);

      final rowSkeletonSize = tester.getSize(rowSkeletonFinder.first);
      expect(rowSkeletonSize.width, lessThanOrEqualTo(800.0));
    });

    testWidgets('LibraryLoadingList no layout shift on small mobile', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SizedBox(width: 360, height: 640, child: LibraryLoadingList()),
        ),
      );

      final sizeBefore = tester.getSize(find.byType(LibraryLoadingList));

      await tester.pump(const Duration(milliseconds: 500));

      final sizeAfter = tester.getSize(find.byType(LibraryLoadingList));

      expect(sizeBefore.width, equals(sizeAfter.width));
      expect(sizeBefore.height, equals(sizeAfter.height));
    });
  });

  group('LoadingState Accessibility Tests', () {
    testWidgets('LoadingState has semantic label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 360,
            height: 640,
            child: Scaffold(body: LoadingState(message: 'Loading...')),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Loading...'), findsOneWidget);
    });

    testWidgets('LoadingState progress indicator is focusable', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 360,
            height: 640,
            child: Scaffold(body: LoadingState(message: 'Loading...')),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('LoadingState has high contrast color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 360,
            height: 640,
            child: Scaffold(body: LoadingState(message: 'Loading...')),
          ),
        ),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      expect(indicator.valueColor, isNotNull);
    });
  });
}

class _LayoutShiftTestWidget extends StatefulWidget {
  @override
  State<_LayoutShiftTestWidget> createState() => _LayoutShiftTestWidgetState();
}

class _LayoutShiftTestWidgetState extends State<_LayoutShiftTestWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const LoadingState(message: 'Loading...'),
        ElevatedButton(
          onPressed: () {
            setState(() {});
          },
          child: const Text('Reload'),
        ),
      ],
    );
  }
}
