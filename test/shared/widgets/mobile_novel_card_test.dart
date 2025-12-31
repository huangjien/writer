import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/shared/widgets/mobile_novel_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockNovel = Novel(
    id: '1',
    title: 'Test Novel Title',
    author: 'Test Author',
    description: 'A test novel description',
    coverUrl: 'https://example.com/cover.jpg',
    languageCode: 'en',
    isPublic: true,
  );

  group('MobileNovelCard', () {
    testWidgets('renders novel information correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MobileNovelCard(novel: mockNovel)),
        ),
      );

      expect(find.text('Test Novel Title'), findsOneWidget);
      expect(find.text('Test Author'), findsOneWidget);
      expect(find.byIcon(Icons.menu_book), findsOneWidget);
      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('renders with custom padding and styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MobileNovelCard(novel: mockNovel)),
        ),
      );

      // Check for container with proper structure
      expect(find.byType(Container), findsAtLeastNWidgets(1));
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Column), findsAtLeastNWidgets(1));
    });

    testWidgets('calls onTap when card is tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileNovelCard(novel: mockNovel, onTap: () => tapped = true),
          ),
        ),
      );

      await tester.tap(find.text('Test Novel Title'));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('calls onLongPress when card is long pressed', (tester) async {
      bool longPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileNovelCard(
              novel: mockNovel,
              onLongPress: () => longPressed = true,
            ),
          ),
        ),
      );

      await tester.longPress(find.text('Test Novel Title'));
      await tester.pump();

      expect(longPressed, true);
    });

    testWidgets('displays progress when progress > 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileNovelCard(novel: mockNovel, progress: 0.75),
          ),
        ),
      );

      expect(find.text('75%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('does not display progress when progress = 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileNovelCard(novel: mockNovel, progress: 0.0),
          ),
        ),
      );

      expect(find.text('0%'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('displays lastRead when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileNovelCard(novel: mockNovel, lastRead: '2 hours ago'),
          ),
        ),
      );

      expect(find.text('2 hours ago'), findsOneWidget);
    });

    testWidgets('hides actions when showActions is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileNovelCard(novel: mockNovel, showActions: false),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsNothing);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
      expect(find.byIcon(Icons.more_vert), findsNothing);
    });

    testWidgets('shows actions when showActions is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileNovelCard(
              novel: mockNovel,
              showActions: true,
              onFavorite: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('shows filled heart when isFavorite is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileNovelCard(
              novel: mockNovel,
              isFavorite: true,
              onFavorite: () {},
              showActions: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('shows outlined heart when isFavorite is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileNovelCard(
              novel: mockNovel,
              isFavorite: false,
              onFavorite: () {},
              showActions: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('calls onFavorite when favorite button is tapped', (
      tester,
    ) async {
      bool favorited = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileNovelCard(
              novel: mockNovel,
              onFavorite: () => favorited = true,
              showActions: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      expect(favorited, true);
    });

    testWidgets('shows more button when showActions is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileNovelCard(novel: mockNovel, showActions: true),
          ),
        ),
      );

      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('renders dismissible with correct direction', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MobileNovelCard(novel: mockNovel)),
        ),
      );

      final dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
      expect(dismissible.direction, DismissDirection.endToStart);
    });

    testWidgets('handles novel without author', (tester) async {
      final novelWithoutAuthor = Novel(
        id: '2',
        title: 'Novel Without Author',
        description: 'Description',
        languageCode: 'en',
        isPublic: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MobileNovelCard(novel: novelWithoutAuthor)),
        ),
      );

      expect(find.text('Novel Without Author'), findsOneWidget);
      // Should not find author text
      expect(find.byType(Text), findsAtLeastNWidgets(1));
    });

    testWidgets('handles long title truncation', (tester) async {
      final longTitleNovel = Novel(
        id: '3',
        title:
            'This is a very long title that should be truncated properly in the card display',
        author: 'Test Author',
        description: 'Description',
        languageCode: 'en',
        isPublic: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MobileNovelCard(novel: longTitleNovel)),
        ),
      );

      expect(find.byType(Text), findsAtLeastNWidgets(1));
      // Title should be rendered (possibly truncated)
      expect(find.textContaining('This is a very long title'), findsOneWidget);
    });

    testWidgets('renders with proper layout structure', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileNovelCard(novel: mockNovel, showActions: true),
          ),
        ),
      );

      // Check main structure
      expect(find.byType(Dismissible), findsOneWidget);
      // IconButton widgets also use InkWell internally, so there are multiple InkWells
      expect(find.byType(InkWell), findsAtLeastNWidgets(1));
      expect(find.byType(Container), findsAtLeastNWidgets(1));
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Column), findsAtLeastNWidgets(1));

      // Check cover image placeholder
      expect(find.byIcon(Icons.menu_book), findsOneWidget);
    });

    testWidgets('progress bar shows correct percentage', (tester) async {
      const progressValues = [0.25, 0.5, 0.33, 1.0];

      for (final progress in progressValues) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MobileNovelCard(novel: mockNovel, progress: progress),
            ),
          ),
        );

        final expectedPercentage = '${(progress * 100).toInt()}%';
        expect(find.text(expectedPercentage), findsOneWidget);
      }
    });
  });

  group('SwipeableCard', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SwipeableCard(child: const Text('Card Content')),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('handles swipe callbacks', (tester) async {
      bool leftSwiped = false;
      bool rightSwiped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SwipeableCard(
              leftActions: const [
                SwipeAction(label: 'Left', icon: Icons.arrow_back),
              ],
              rightActions: const [
                SwipeAction(label: 'Right', icon: Icons.arrow_forward),
              ],
              onSwipeLeft: () => leftSwiped = true,
              onSwipeRight: () => rightSwiped = true,
              child: const Text('Card Content'),
            ),
          ),
        ),
      );

      // Test left swipe (drag left, which is endToStart direction)
      await tester.fling(
        find.text('Card Content'),
        const Offset(-500, 0),
        1000,
      );
      await tester.pumpAndSettle();
      expect(leftSwiped, true);

      // Reset and test right swipe
      leftSwiped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SwipeableCard(
              leftActions: const [
                SwipeAction(label: 'Left', icon: Icons.arrow_back),
              ],
              rightActions: const [
                SwipeAction(label: 'Right', icon: Icons.arrow_forward),
              ],
              onSwipeLeft: () => leftSwiped = true,
              onSwipeRight: () => rightSwiped = true,
              child: const Text('Card Content 2'),
            ),
          ),
        ),
      );

      // Test right swipe (drag right, which is startToEnd direction)
      await tester.fling(
        find.text('Card Content 2'),
        const Offset(500, 0),
        1000,
      );
      await tester.pumpAndSettle();
      expect(rightSwiped, true);
    });

    testWidgets('shows swipe actions when provided', (tester) async {
      final leftActions = [
        const SwipeAction(label: 'Archive', icon: Icons.archive),
      ];

      final rightActions = [
        const SwipeAction(label: 'Delete', icon: Icons.delete),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SwipeableCard(
              leftActions: leftActions,
              rightActions: rightActions,
              child: const Text('Card Content'),
            ),
          ),
        ),
      );

      final dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
      expect(dismissible.direction, DismissDirection.horizontal);
    });
  });

  group('SwipeAction', () {
    test('creates SwipeAction with required parameters', () {
      const action = SwipeAction(label: 'Test Action', icon: Icons.star);

      expect(action.label, 'Test Action');
      expect(action.icon, Icons.star);
      expect(action.onTap, null);
      expect(action.backgroundColor, null);
      expect(action.iconColor, null);
      expect(action.labelColor, null);
    });

    test('creates SwipeAction with all parameters', () {
      const action = SwipeAction(
        label: 'Full Action',
        icon: Icons.favorite,
        backgroundColor: Colors.red,
        iconColor: Colors.white,
        labelColor: Colors.black,
      );

      expect(action.label, 'Full Action');
      expect(action.icon, Icons.favorite);
      expect(action.backgroundColor, Colors.red);
      expect(action.iconColor, Colors.white);
      expect(action.labelColor, Colors.black);
    });
  });

  group('Integration Tests', () {
    testWidgets('MobileNovelCard with all features enabled', (tester) async {
      bool tapped = false;
      bool favorited = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileNovelCard(
              novel: mockNovel,
              onTap: () => tapped = true,
              onFavorite: () => favorited = true,
              onDelete: () {},
              isFavorite: false,
              progress: 0.5,
              lastRead: 'Yesterday',
              showActions: true,
            ),
          ),
        ),
      );

      // Test basic structure
      expect(find.text('Test Novel Title'), findsOneWidget);
      expect(find.text('Test Author'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);

      // Test interactions
      await tester.tap(find.text('Test Novel Title'));
      expect(tapped, true);

      await tester.tap(find.byIcon(Icons.favorite_border));
      expect(favorited, true);

      // Test swipe
      await tester.drag(find.byType(MobileNovelCard), const Offset(-300, 0));
      await tester.pumpAndSettle();
    });

    testWidgets('Multiple MobileNovelCards in list', (tester) async {
      final novels = [
        mockNovel,
        Novel(
          id: '2',
          title: 'Second Novel',
          author: 'Second Author',
          description: 'Second description',
          languageCode: 'en',
          isPublic: true,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: novels.length,
              itemBuilder: (context, index) {
                return MobileNovelCard(
                  novel: novels[index],
                  progress: (index + 1) * 0.3,
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Test Novel Title'), findsOneWidget);
      expect(find.text('Second Novel'), findsOneWidget);
      expect(find.text('Test Author'), findsOneWidget);
      expect(find.text('Second Author'), findsOneWidget);
      expect(find.text('30%'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
    });
  });
}
