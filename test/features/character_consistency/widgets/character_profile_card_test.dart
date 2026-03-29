import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/character_consistency/widgets/character_profile_card.dart';
import 'package:writer/models/character_profile.dart';

void main() {
  group('CharacterProfileCard', () {
    testWidgets('should display character information', (tester) async {
      final profile = CharacterProfile(
        id: 'char1',
        name: 'John Doe',
        age: 35,
        role: 'Protagonist',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CharacterProfileCard(
              profile: profile,
              onDelete: () {},
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Protagonist'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('should display traits when available', (tester) async {
      final profile = CharacterProfile(
        id: 'char1',
        name: 'Jane Smith',
        personalityTraits: ['Brave', 'Loyal', 'Cunning'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CharacterProfileCard(
              profile: profile,
              onDelete: () {},
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Brave'), findsOneWidget);
      expect(find.text('Loyal'), findsOneWidget);
      expect(find.text('Cunning'), findsOneWidget);
    });

    testWidgets('should show consistent traits when score is high', (
      tester,
    ) async {
      final profile = CharacterProfile(
        id: 'char1',
        name: 'John',
        personalityTraits: ['Brave'],
        sceneAppearances: [
          SceneAppearance(
            sceneId: 'scene1',
            appearanceDate: DateTime(2026, 3, 29),
            observedTraits: ['Brave'],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CharacterProfileCard(
              profile: profile,
              onDelete: () {},
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should show warning when traits are inconsistent', (
      tester,
    ) async {
      final profile = CharacterProfile(
        id: 'char1',
        name: 'John',
        personalityTraits: ['Brave', 'Loyal'],
        sceneAppearances: [
          SceneAppearance(
            sceneId: 'scene1',
            appearanceDate: DateTime(2026, 3, 29),
            observedTraits: [],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CharacterProfileCard(
              profile: profile,
              onDelete: () {},
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.textContaining('inconsistent trait'), findsOneWidget);
    });

    testWidgets('should call onTap when card is tapped', (tester) async {
      final profile = CharacterProfile(id: 'char1', name: 'John Doe');

      bool tapCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CharacterProfileCard(
              profile: profile,
              onDelete: () {},
              onTap: () => tapCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Card));
      await tester.pump();

      expect(tapCalled, true);
    });

    testWidgets('should call onDelete when delete button is pressed', (
      tester,
    ) async {
      final profile = CharacterProfile(id: 'char1', name: 'John Doe');

      bool deleteCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CharacterProfileCard(
              profile: profile,
              onDelete: () => deleteCalled = true,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(deleteCalled, true);
    });

    testWidgets('should display statistics correctly', (tester) async {
      final profile = CharacterProfile(
        id: 'char1',
        name: 'John',
        personalityTraits: ['Brave'],
        physicalTraits: ['Tall'],
        relationships: {'Jane': 'Friend'},
        sceneAppearances: [
          SceneAppearance(
            sceneId: 'scene1',
            appearanceDate: DateTime(2026, 3, 29),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CharacterProfileCard(
              profile: profile,
              onDelete: () {},
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Appearances'), findsOneWidget);
      expect(find.text('1'), findsWidgets);
      expect(find.text('Traits'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Relationships'), findsOneWidget);
    });
  });
}
