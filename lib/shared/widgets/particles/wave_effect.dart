import 'package:flutter/material.dart';

class WaveTap extends StatefulWidget {
  const WaveTap({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.color,
    this.duration = const Duration(milliseconds: 520),
    this.maxRadius,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final Duration duration;
  final double? maxRadius;
  final BorderRadius? borderRadius;

  @override
  State<WaveTap> createState() => _WaveTapState();
}

class _WaveTapState extends State<WaveTap> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Offset? _origin;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _start(Offset origin) {
    setState(() => _origin = origin);
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final waveColor =
        widget.color ?? theme.colorScheme.primary.withValues(alpha: 0.35);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxR =
            widget.maxRadius ??
            (Size(constraints.maxWidth, constraints.maxHeight).longestSide *
                0.85);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  if (_controller.value == 0 || _origin == null) {
                    return const SizedBox.shrink();
                  }
                  return ClipRRect(
                    borderRadius: widget.borderRadius ?? BorderRadius.zero,
                    child: CustomPaint(
                      painter: _WavePainter(
                        t: _controller.value,
                        origin: _origin!,
                        color: waveColor,
                        maxRadius: maxR,
                      ),
                    ),
                  );
                },
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (d) => _start(d.localPosition),
              onTap: widget.onTap,
              onLongPress: widget.onLongPress,
              child: widget.child,
            ),
          ],
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({
    required this.t,
    required this.origin,
    required this.color,
    required this.maxRadius,
  });

  final double t;
  final Offset origin;
  final Color color;
  final double maxRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final eased = Curves.easeOutCubic.transform(t);
    final fade = (1 - Curves.easeIn.transform(t)).clamp(0.0, 1.0);
    paint.color = color.withValues(alpha: color.a * fade);
    canvas.drawCircle(origin, maxRadius * eased, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.origin != origin ||
        oldDelegate.color != color ||
        oldDelegate.maxRadius != maxRadius;
  }
}
