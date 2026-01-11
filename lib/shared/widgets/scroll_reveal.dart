import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ScrollReveal extends StatefulWidget {
  const ScrollReveal({
    super.key,
    required this.child,
    this.enabled = true,
    this.once = true,
    this.offset = const Offset(0, 16),
    this.duration = const Duration(milliseconds: 260),
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;
  final bool enabled;
  final bool once;
  final Offset offset;
  final Duration duration;
  final Curve curve;

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  ScrollPosition? _position;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _controller, curve: widget.curve);
    _slide = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newPos = Scrollable.maybeOf(context)?.position;
    if (identical(newPos, _position)) return;
    _position?.removeListener(_maybeReveal);
    _position = newPos;
    _position?.addListener(_maybeReveal);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeReveal());
  }

  @override
  void dispose() {
    _position?.removeListener(_maybeReveal);
    _controller.dispose();
    super.dispose();
  }

  bool _isInViewport() {
    final renderObject = context.findRenderObject();
    final position = _position;
    if (renderObject == null || position == null) return true;

    final viewport = RenderAbstractViewport.maybeOf(renderObject);
    if (viewport == null) return true;

    final reveal = viewport.getOffsetToReveal(renderObject, 0).offset;
    final start = position.pixels;
    final end = start + position.viewportDimension;
    return reveal <= end && reveal + renderObject.paintBounds.height >= start;
  }

  void _maybeReveal() {
    if (!mounted || !widget.enabled) return;
    if (_revealed && widget.once) return;

    if (_isInViewport()) {
      _revealed = true;
      _controller.forward();
      if (widget.once) {
        _position?.removeListener(_maybeReveal);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
