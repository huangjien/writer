import 'package:flutter/material.dart';

class AnimatedListItem extends StatefulWidget {
  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
    this.staggerDelay = const Duration(milliseconds: 40),
    this.duration = const Duration(milliseconds: 320),
    this.offset = const Offset(0, 0.08),
    this.reduceMotion = false,
  });

  final int index;
  final Widget child;
  final Duration staggerDelay;
  final Duration duration;
  final Offset offset;
  final bool reduceMotion;

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    if (widget.reduceMotion) {
      _controller.value = 1;
      _started = true;
    } else {
      _start();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reduceMotion && !_started) {
      _controller.value = 1;
      _started = true;
    }
  }

  void _start() {
    if (_started) return;
    _started = true;
    final delayMs = widget.staggerDelay.inMilliseconds * widget.index;
    Future<void>.delayed(Duration(milliseconds: delayMs), () {
      if (!mounted) return;
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reduceMotion) return widget.child;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
