import 'package:flutter/material.dart';

typedef ParallaxHeaderBuilder =
    Widget Function(BuildContext context, double shrinkOffset, bool overlaps);

class ParallaxHeader extends StatelessWidget {
  const ParallaxHeader({
    super.key,
    required this.minExtent,
    required this.maxExtent,
    required this.builder,
    this.pinned = true,
  });

  final double minExtent;
  final double maxExtent;
  final ParallaxHeaderBuilder builder;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: pinned,
      delegate: _ParallaxHeaderDelegate(
        minExtent: minExtent,
        maxExtent: maxExtent,
        builder: builder,
      ),
    );
  }
}

class _ParallaxHeaderDelegate extends SliverPersistentHeaderDelegate {
  _ParallaxHeaderDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.builder,
  });

  @override
  final double minExtent;

  @override
  final double maxExtent;

  final ParallaxHeaderBuilder builder;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return builder(context, shrinkOffset, overlapsContent);
  }

  @override
  bool shouldRebuild(_ParallaxHeaderDelegate oldDelegate) {
    return minExtent != oldDelegate.minExtent ||
        maxExtent != oldDelegate.maxExtent ||
        builder != oldDelegate.builder;
  }
}
