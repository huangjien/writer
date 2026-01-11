import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'dart:async';

class SpringAnimatedContainer extends StatefulWidget {
  const SpringAnimatedContainer({
    super.key,
    required this.child,
    required this.expanded,
    this.reduceMotion = false,
    this.delay = Duration.zero,
    this.beginScale = 0.94,
    this.endScale = 1.0,
    this.beginOpacity = 0.0,
    this.endOpacity = 1.0,
    this.beginOffset = const Offset(0, 10),
    this.endOffset = Offset.zero,
    this.mass = 1,
    this.stiffness = 420,
    this.damping = 22,
  });

  final Widget child;
  final bool expanded;
  final bool reduceMotion;
  final Duration delay;
  final double beginScale;
  final double endScale;
  final double beginOpacity;
  final double endOpacity;
  final Offset beginOffset;
  final Offset endOffset;
  final double mass;
  final double stiffness;
  final double damping;

  @override
  State<SpringAnimatedContainer> createState() =>
      _SpringAnimatedContainerState();
}

class _SpringAnimatedContainerState extends State<SpringAnimatedContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _delayTimer;

  SpringDescription get _spring => SpringDescription(
    mass: widget.mass,
    stiffness: widget.stiffness,
    damping: widget.damping,
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: 1,
      value: widget.expanded ? 1 : 0,
    );

    if (!widget.reduceMotion && widget.expanded) {
      _animateTo(1);
    }
  }

  @override
  void didUpdateWidget(covariant SpringAnimatedContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reduceMotion) {
      _controller.value = widget.expanded ? 1 : 0;
      return;
    }

    if (oldWidget.expanded != widget.expanded) {
      _animateTo(widget.expanded ? 1 : 0);
    }
  }

  void _animateTo(double target) {
    _delayTimer?.cancel();

    void start() {
      if (!mounted) return;
      final simulation = SpringSimulation(
        _spring,
        _controller.value,
        target,
        0,
      );
      _controller.animateWith(simulation);
    }

    if (widget.delay == Duration.zero) {
      start();
      return;
    }

    _delayTimer = Timer(widget.delay, start);
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reduceMotion) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final opacity =
            widget.beginOpacity + (widget.endOpacity - widget.beginOpacity) * t;
        final scale =
            widget.beginScale + (widget.endScale - widget.beginScale) * t;
        final dx =
            widget.beginOffset.dx +
            (widget.endOffset.dx - widget.beginOffset.dx) * t;
        final dy =
            widget.beginOffset.dy +
            (widget.endOffset.dy - widget.beginOffset.dy) * t;
        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(dx, dy),
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
      child: widget.child,
    );
  }
}
