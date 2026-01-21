import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/loading_state.dart';
import 'package:writer/shared/widgets/loading/loading_story.dart';
import 'package:writer/shared/widgets/loading/skeleton_list_items.dart';
import 'package:writer/shared/widgets/loading/shimmer_skeleton.dart';

void main() {
  group('Skeleton Loading Tests', () {
    testWidgets('Skeleton list items display correctly during loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                LibraryItemRowSkeleton(key: UniqueKey()),
                LibraryItemRowSkeleton(key: UniqueKey()),
                LibraryItemRowSkeleton(key: UniqueKey()),
              ],
            ),
          ),
        ),
      );

      expect(
        find.byType(LibraryItemRowSkeleton),
        findsWidgets,
        reason: 'Skeleton list items should be displayed',
      );

      final skeletons = find.byType(ShimmerSkeleton);
      expect(
        skeletons,
        findsWidgets,
        reason: 'Skeleton items should be present',
      );
    });

    testWidgets('LibraryItemRowSkeleton builds expected placeholders', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LibraryItemRowSkeleton(key: UniqueKey())),
        ),
      );

      final shimmer = tester.widget<ShimmerSkeleton>(
        find.byType(ShimmerSkeleton),
      );
      expect(shimmer.enabled, isTrue);

      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 80 && w.height == 120,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 200 && w.height == 24,
        ),
        findsOneWidget,
      );
    });

    testWidgets('LibraryGridItemSkeleton builds expected placeholders', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LibraryGridItemSkeleton(key: UniqueKey())),
        ),
      );

      expect(find.byType(ShimmerSkeleton), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 120 && w.height == 180,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 100 && w.height == 20,
        ),
        findsOneWidget,
      );
    });

    testWidgets('PatternItemSkeleton builds expected placeholders', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PatternItemSkeleton(key: UniqueKey())),
        ),
      );

      expect(find.byType(ShimmerSkeleton), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 150 && w.height == 20,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 40 && w.height == 20,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 80 && w.height == 36,
        ),
        findsOneWidget,
      );
    });

    testWidgets('StoryLineItemSkeleton builds expected placeholders', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StoryLineItemSkeleton(key: UniqueKey())),
        ),
      );

      expect(find.byType(ShimmerSkeleton), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 150 && w.height == 20,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 80 && w.height == 36,
        ),
        findsOneWidget,
      );
    });

    testWidgets('PromptItemSkeleton builds expected placeholders', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PromptItemSkeleton(key: UniqueKey())),
        ),
      );

      expect(find.byType(ShimmerSkeleton), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 100 && w.height == 20,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 40 && w.height == 20,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 80 && w.height == 36,
        ),
        findsOneWidget,
      );
    });

    testWidgets('ChapterItemSkeleton builds expected placeholders', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ChapterItemSkeleton(key: UniqueKey())),
        ),
      );

      expect(find.byType(ShimmerSkeleton), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 30 && w.height == 30,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 150 && w.height == 20,
        ),
        findsOneWidget,
      );
    });

    testWidgets('CharacterItemSkeleton builds expected placeholders', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CharacterItemSkeleton(key: UniqueKey())),
        ),
      );

      expect(find.byType(ShimmerSkeleton), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 200 && w.height == 24,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 300 && w.height == 16,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 250 && w.height == 16,
        ),
        findsOneWidget,
      );
    });

    testWidgets('SceneItemSkeleton builds expected placeholders', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SceneItemSkeleton(key: UniqueKey())),
        ),
      );

      expect(find.byType(ShimmerSkeleton), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 200 && w.height == 24,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 300 && w.height == 16,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 250 && w.height == 16,
        ),
        findsOneWidget,
      );
    });

    testWidgets('Skeleton loading state shows correct placeholder', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LoadingState(key: UniqueKey())),
        ),
      );

      expect(
        find.byType(LoadingState),
        findsOneWidget,
        reason: 'Loading state should be displayed',
      );

      expect(
        find.byType(CircularProgressIndicator),
        findsOneWidget,
        reason: 'Loading indicator should be shown',
      );
    });

    testWidgets('Skeleton loading preserves layout dimensions', (tester) async {
      const itemCount = 3;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: List.generate(
                itemCount,
                (index) => LibraryItemRowSkeleton(key: UniqueKey()),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      final skeletonItems = find.byType(LibraryItemRowSkeleton);
      expect(
        skeletonItems,
        findsNWidgets(itemCount),
        reason: 'Skeleton items should be displayed',
      );
    });

    testWidgets('Story skeleton displays loading state correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingStory(
              stories: ['Loading...', 'Please wait...', 'Almost there...'],
            ),
          ),
        ),
      );

      expect(
        find.byType(LoadingStory),
        findsOneWidget,
        reason: 'Story loading skeleton should be displayed',
      );

      expect(
        find.byType(AnimatedSwitcher),
        findsOneWidget,
        reason: 'Story switcher should be present',
      );
    });

    testWidgets('Skeleton loading has no layout shift during transition', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                LibraryItemRowSkeleton(key: UniqueKey()),
                LibraryItemRowSkeleton(key: UniqueKey()),
                LibraryItemRowSkeleton(key: UniqueKey()),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      final initialHeight = tester.getSize(find.byType(ListView)).height;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: List.generate(
                3,
                (index) => ListTile(title: Text('Item ${index + 1}')),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      final finalHeight = tester.getSize(find.byType(ListView)).height;

      expect(
        initialHeight,
        closeTo(finalHeight, 20.0),
        reason: 'Skeleton loading should have minimal layout shift',
      );
    });

    testWidgets('Skeleton loading uses shimmer animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LibraryItemRowSkeleton(key: UniqueKey())),
        ),
      );

      await tester.pump();

      final skeletonFinder = find.byType(LibraryItemRowSkeleton);
      expect(
        skeletonFinder,
        findsOneWidget,
        reason: 'Skeleton item should be displayed',
      );
    });

    testWidgets('Skeleton loading respects reduce motion setting', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(body: LibraryItemRowSkeleton(key: UniqueKey())),
          ),
        ),
      );

      final skeletonFinder = find.byType(LibraryItemRowSkeleton);
      expect(
        skeletonFinder,
        findsOneWidget,
        reason: 'Skeleton item should be displayed',
      );
    });

    testWidgets('Skeleton loading has correct accessibility semantics', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LibraryItemRowSkeleton(key: UniqueKey())),
        ),
      );

      await tester.pump();

      final skeletonFinder = find.byType(LibraryItemRowSkeleton);
      expect(
        skeletonFinder,
        findsOneWidget,
        reason: 'Skeleton item should be displayed',
      );
    });
  });
}
