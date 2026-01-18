import 'dart:async';

import 'package:flutter/material.dart';

import '../../../theme/design_tokens.dart';
import '../theme_aware_card.dart';
import '../modern_progress_indicator.dart';

class PullToRefresh extends StatefulWidget {
  const PullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    required this.controller,
    this.triggerDistance = 96,
    this.enabled = true,
  });

  final Future<void> Function() onRefresh;
  final Widget child;
  final ScrollController controller;
  final double triggerDistance;
  final bool enabled;

  @override
  State<PullToRefresh> createState() => _PullToRefreshState();
}

class _PullToRefreshState extends State<PullToRefresh>
    with SingleTickerProviderStateMixin {
  bool _refreshing = false;
  double _pullExtent = 0;

  late final AnimationController _settleController;
  Animation<double>? _settleAnimation;

  @override
  void initState() {
    super.initState();
    _settleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _settleController.dispose();
    super.dispose();
  }

  void _setPullExtent(double value) {
    final next = value.clamp(0.0, widget.triggerDistance * 1.6);
    if (next == _pullExtent) return;
    setState(() => _pullExtent = next);
  }

  void _settleTo(double target) {
    _settleController.stop();
    _settleController.value = 0;
    final anim = Tween<double>(begin: _pullExtent, end: target).animate(
      CurvedAnimation(parent: _settleController, curve: Curves.easeOut),
    );
    _settleAnimation = anim;
    _settleController
      ..removeListener(_onSettleTick)
      ..addListener(_onSettleTick)
      ..forward();
  }

  void _onSettleTick() {
    final anim = _settleAnimation;
    if (anim == null) return;
    _setPullExtent(anim.value);
  }

  bool _isAtTop(ScrollMetrics metrics) {
    return metrics.pixels <= metrics.minScrollExtent + 0.1;
  }

  void _handleNotification(ScrollNotification notification) {
    if (!widget.enabled || _refreshing) return;
    if (!_isAtTop(notification.metrics) &&
        notification.metrics.pixels >= notification.metrics.minScrollExtent) {
      if (_pullExtent != 0) _setPullExtent(0);
      return;
    }

    if (notification is OverscrollNotification) {
      final o = notification.overscroll;
      if (o < 0) {
        _setPullExtent(_pullExtent + (-o));
      } else if (o > 0 && _pullExtent > 0) {
        _setPullExtent(_pullExtent - o);
      }
      return;
    }

    if (notification is ScrollUpdateNotification &&
        notification.dragDetails != null) {
      final delta = notification.scrollDelta ?? 0;
      if (delta > 0 && _pullExtent > 0) {
        _setPullExtent(_pullExtent - delta);
      }
    }

    if (notification is ScrollEndNotification) {
      final shouldTrigger = _pullExtent >= widget.triggerDistance;
      if (shouldTrigger) {
        unawaited(_triggerRefresh());
      } else {
        _settleTo(0);
      }
    }
  }

  Future<void> _triggerRefresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    _settleTo(widget.triggerDistance);
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() => _refreshing = false);
        _settleTo(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visible = _pullExtent > 0 || _refreshing;

    final progress = (_pullExtent / widget.triggerDistance)
        .clamp(0.0, 1.0)
        .toDouble();

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        _handleNotification(n);
        return false;
      },
      child: Stack(
        children: [
          widget.child,
          if (visible)
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: ThemeAwareCard(
                    borderRadius: BorderRadius.circular(Radii.l),
                    semanticType: CardSemanticType.default_,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.m,
                      vertical: Spacing.s,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_refreshing)
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        else
                          ModernProgressIndicator(
                            value: progress,
                            size: 22,
                            strokeWidth: 3,
                            showLabel: false,
                          ),
                        const SizedBox(width: Spacing.s),
                        Text(
                          _refreshing
                              ? 'Refreshing...'
                              : progress >= 1
                              ? 'Release to refresh'
                              : 'Pull to refresh',
                          style: theme.textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
