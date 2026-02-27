import 'package:flutter/material.dart';
import 'package:writer/theme/design_tokens.dart';
import 'shimmer_skeleton.dart';

class LibraryItemRowSkeleton extends StatelessWidget {
  const LibraryItemRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerSkeleton(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.l,
          vertical: Spacing.s,
        ),
        child: Row(
          children: [
            SizedBox(width: 80, height: 120),
            SizedBox(width: Spacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24, width: 200),
                  SizedBox(height: Spacing.s),
                  SizedBox(height: 16, width: 150),
                  SizedBox(height: Spacing.s),
                  SizedBox(height: 16, width: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LibraryGridItemSkeleton extends StatelessWidget {
  const LibraryGridItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerSkeleton(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, height: 180),
          SizedBox(height: Spacing.s),
          SizedBox(height: 20, width: 100),
          SizedBox(height: Spacing.xs),
          SizedBox(height: 16, width: 80),
        ],
      ),
    );
  }
}

class PatternItemSkeleton extends StatelessWidget {
  const PatternItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerSkeleton(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Spacing.s),
        child: Row(
          children: [
            SizedBox(width: 150, height: 20),
            SizedBox(width: Spacing.l),
            Expanded(child: SizedBox(height: 16, width: 200)),
            SizedBox(width: Spacing.l),
            SizedBox(width: 40, height: 20),
            SizedBox(width: Spacing.l),
            SizedBox(width: 80, height: 36),
          ],
        ),
      ),
    );
  }
}

class StoryLineItemSkeleton extends StatelessWidget {
  const StoryLineItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerSkeleton(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Spacing.s),
        child: Row(
          children: [
            SizedBox(width: 150, height: 20),
            SizedBox(width: Spacing.l),
            Expanded(child: SizedBox(height: 16, width: 200)),
            SizedBox(width: Spacing.l),
            SizedBox(width: 40, height: 20),
            SizedBox(width: Spacing.l),
            SizedBox(width: 80, height: 36),
          ],
        ),
      ),
    );
  }
}

class PromptItemSkeleton extends StatelessWidget {
  const PromptItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerSkeleton(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Spacing.s),
        child: Row(
          children: [
            SizedBox(width: 100, height: 20),
            SizedBox(width: Spacing.l),
            SizedBox(width: 40, height: 20),
            SizedBox(width: Spacing.l),
            Expanded(child: SizedBox(height: 16, width: 150)),
            SizedBox(width: Spacing.l),
            SizedBox(width: 80, height: 36),
          ],
        ),
      ),
    );
  }
}

class ChapterItemSkeleton extends StatelessWidget {
  const ChapterItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerSkeleton(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.l,
          vertical: Spacing.m,
        ),
        child: Row(
          children: [
            SizedBox(width: 30, height: 30),
            SizedBox(width: Spacing.m),
            Expanded(child: SizedBox(height: 20, width: 150)),
          ],
        ),
      ),
    );
  }
}

class CharacterItemSkeleton extends StatelessWidget {
  const CharacterItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerSkeleton(
      child: Padding(
        padding: EdgeInsets.all(Spacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24, width: 200),
            SizedBox(height: Spacing.s),
            SizedBox(height: 16, width: 300),
            SizedBox(height: Spacing.s),
            SizedBox(height: 16, width: 250),
          ],
        ),
      ),
    );
  }
}

class SceneItemSkeleton extends StatelessWidget {
  const SceneItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerSkeleton(
      child: Padding(
        padding: EdgeInsets.all(Spacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24, width: 200),
            SizedBox(height: Spacing.s),
            SizedBox(height: 16, width: 300),
            SizedBox(height: Spacing.s),
            SizedBox(height: 16, width: 250),
          ],
        ),
      ),
    );
  }
}
