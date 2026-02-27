import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:writer/theme/design_tokens.dart';

class ErrorAnimation extends StatefulWidget {
  const ErrorAnimation({
    super.key,
    this.size = 56,
    this.color,
    this.duration = const Duration(milliseconds: 180),
  });

  final double size;
  final Color? color;
  final Duration duration;

  @override
  State<ErrorAnimation> createState() => _ErrorAnimationState();
}

class _ErrorAnimationState extends State<ErrorAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.colorScheme.error;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = Curves.easeOut.transform(_controller.value);
          final shake = math.sin(t * math.pi * 4) * (1 - t) * 6;
          final ringAlpha = 0.10 + 0.18 * t;
          return Transform.translate(
            offset: Offset(shake, 0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: ringAlpha),
                  ),
                ),
                Icon(
                  Icons.error_outline,
                  color: color,
                  size: widget.size * 0.62,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class RetryPulse extends StatefulWidget {
  const RetryPulse({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
  });

  final Widget child;
  final Duration duration;

  @override
  State<RetryPulse> createState() => _RetryPulseState();
}

class _RetryPulseState extends State<RetryPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _stopTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _stopTimer = Timer(
      Duration(milliseconds: widget.duration.inMilliseconds * 3),
      () {
        if (!mounted) return;
        _controller.stop();
        _controller.value = 0.0;
      },
    );
  }

  @override
  void dispose() {
    _stopTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final alpha = 0.10 + 0.20 * t;
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: alpha),
                  borderRadius: BorderRadius.circular(Radii.xl),
                ),
              ),
            ),
            widget.child,
          ],
        );
      },
    );
  }
}
