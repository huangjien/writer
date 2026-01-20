import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../mobile_gestures.dart';

class SwipeActionItem {
  const SwipeActionItem({
    required this.label,
    required this.icon,
    required this.onExecute,
    this.backgroundColor,
    this.foregroundColor,
    this.isDestructive = false,
    this.undoMessage,
    this.undoButtonText = 'Undo',
    this.onUndo,
  });

  final String label;
  final IconData icon;
  final FutureOr<void> Function() onExecute;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isDestructive;
  final String? undoMessage;
  final String undoButtonText;
  final VoidCallback? onUndo;
}

class SwipeActions extends StatefulWidget {
  const SwipeActions({
    super.key,
    required this.child,
    this.startActions = const <SwipeActionItem>[],
    this.endActions = const <SwipeActionItem>[],
    this.actionExtent = 72,
    this.openThreshold = 0.28,
    this.closeOnScroll = true,
    this.enabled = true,
  });

  final Widget child;
  final List<SwipeActionItem> startActions;
  final List<SwipeActionItem> endActions;
  final double actionExtent;
  final double openThreshold;
  final bool closeOnScroll;
  final bool enabled;

  @override
  State<SwipeActions> createState() => _SwipeActionsState();
}

class _SwipeActionsState extends State<SwipeActions>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  double _dragDx = 0;
  double _settledDx = 0;
  ScrollPosition? _scrollPosition;

  double get _maxStartExtent =>
      widget.startActions.length * widget.actionExtent;
  double get _maxEndExtent => widget.endActions.length * widget.actionExtent;

  bool get _hasActions =>
      widget.startActions.isNotEmpty || widget.endActions.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.closeOnScroll) return;
    final newPos = Scrollable.maybeOf(context)?.position;
    if (identical(newPos, _scrollPosition)) return;
    _scrollPosition?.removeListener(_onScroll);
    _scrollPosition = newPos;
    _scrollPosition?.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_controller.isAnimating) return;
    if (_currentDx != 0) {
      _close();
    }
  }

  double get _currentDx => _settledDx + _dragDx;

  double _clampDx(double dx) {
    if (!_hasActions) return 0;
    return dx.clamp(-_maxEndExtent, _maxStartExtent);
  }

  void _close() {
    if (!mounted) return;
    _animateTo(0);
  }

  void _openToStart() {
    if (_maxStartExtent <= 0) return;
    _animateTo(_maxStartExtent);
  }

  void _openToEnd() {
    if (_maxEndExtent <= 0) return;
    _animateTo(-_maxEndExtent);
  }

  void _animateTo(double targetDx) {
    final begin = _currentDx;
    final end = _clampDx(targetDx);
    if (begin == end) return;

    _controller
      ..stop()
      ..value = 0;

    final animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    final tween = Tween<double>(begin: begin, end: end).animate(animation);

    void listener() {
      setState(() {
        _settledDx = tween.value;
        _dragDx = 0;
      });
    }

    void statusListener(AnimationStatus status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _controller.removeListener(listener);
        _controller.removeStatusListener(statusListener);
      }
    }

    _controller.addListener(listener);
    _controller.addStatusListener(statusListener);
    _controller.forward();
  }

  Future<void> _runAction(SwipeActionItem action) async {
    _close();
    if (action.isDestructive) {
      MobileGestures.heavyImpact();
    } else {
      MobileGestures.selectionClick();
    }

    await action.onExecute();

    if (action.onUndo != null && action.undoMessage != null) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.hideCurrentSnackBar();
      messenger?.showSnackBar(
        SnackBar(
          content: Text(action.undoMessage!),
          action: SnackBarAction(
            label: action.undoButtonText,
            onPressed: () {
              MobileGestures.selectionClick();
              action.onUndo?.call();
            },
          ),
        ),
      );
    }
  }

  void _onDragStart(DragStartDetails details) {
    _controller.stop();
    _dragDx = 0;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final next = _clampDx(_settledDx + _dragDx + details.delta.dx);
    setState(() {
      _dragDx = next - _settledDx;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final dx = _currentDx;
    final vx = details.velocity.pixelsPerSecond.dx;

    final openingToStart = dx > 0;
    final openingToEnd = dx < 0;

    final maxExtent = openingToStart ? _maxStartExtent : _maxEndExtent;
    final threshold = maxExtent * widget.openThreshold;

    final shouldOpenByDistance = dx.abs() >= threshold && maxExtent > 0;
    final shouldOpenByVelocity = vx.abs() > 800;

    if (!shouldOpenByDistance && !shouldOpenByVelocity) {
      _close();
      return;
    }

    if (shouldOpenByVelocity) {
      if (vx > 0 && _maxStartExtent > 0) {
        _openToStart();
      } else if (vx < 0 && _maxEndExtent > 0) {
        _openToEnd();
      } else {
        _close();
      }
      return;
    }

    if (openingToStart) {
      _openToStart();
    } else if (openingToEnd) {
      _openToEnd();
    } else {
      _close();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || !_hasActions) return widget.child;

    final dx = _clampDx(_currentDx);
    final openProgress = (dx == 0)
        ? 0.0
        : (dx > 0
                  ? dx / math.max(1, _maxStartExtent)
                  : -dx / math.max(1, _maxEndExtent))
              .clamp(0.0, 1.0);

    return Stack(
      children: [
        if (dx != 0)
          Positioned.fill(
            child: Row(
              children: [
                if (widget.startActions.isNotEmpty)
                  _ActionsRow(
                    actions: widget.startActions,
                    actionExtent: widget.actionExtent,
                    alignment: MainAxisAlignment.start,
                    onPressed: _runAction,
                  )
                else
                  const SizedBox.shrink(),
                const Spacer(),
                if (widget.endActions.isNotEmpty)
                  _ActionsRow(
                    actions: widget.endActions,
                    actionExtent: widget.actionExtent,
                    alignment: MainAxisAlignment.end,
                    onPressed: _runAction,
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        Transform.translate(
          offset: Offset(dx, 0),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            child: Opacity(
              opacity: 1 - (0.1 * openProgress),
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionsRow extends StatelessWidget {
  const _ActionsRow({
    required this.actions,
    required this.actionExtent,
    required this.alignment,
    required this.onPressed,
  });

  final List<SwipeActionItem> actions;
  final double actionExtent;
  final MainAxisAlignment alignment;
  final ValueChanged<SwipeActionItem> onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: actions
          .map(
            (a) => _ActionButton(
              action: a,
              width: actionExtent,
              onPressed: () => onPressed(a),
            ),
          )
          .toList(),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.action,
    required this.width,
    required this.onPressed,
  });

  final SwipeActionItem action;
  final double width;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bg =
        action.backgroundColor ??
        (action.isDestructive
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.primaryContainer);

    final fg =
        action.foregroundColor ??
        (action.isDestructive
            ? theme.colorScheme.onErrorContainer
            : theme.colorScheme.onPrimaryContainer);

    return Material(
      color: bg,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: width,
          height: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final showLabel = constraints.maxHeight >= 44;
              final iconSize = showLabel ? 22.0 : 18.0;
              return Center(
                child: showLabel
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(action.icon, color: fg, size: iconSize),
                          const SizedBox(height: 6),
                          Text(
                            action.label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: fg,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )
                    : Icon(action.icon, color: fg, size: iconSize),
              );
            },
          ),
        ),
      ),
    );
  }
}
