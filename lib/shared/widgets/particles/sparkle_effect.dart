import 'dart:math';

import 'package:flutter/material.dart';

class SparkleController extends ChangeNotifier {
  int _token = 0;
  int get token => _token;

  void trigger() {
    _token++;
    notifyListeners();
  }
}

class SparkleEffect extends StatefulWidget {
  const SparkleEffect({
    super.key,
    required this.controller,
    required this.child,
    this.color,
    this.sparkleCount = 10,
    this.duration = const Duration(milliseconds: 650),
    this.radius = 18,
  });

  final SparkleController controller;
  final Widget child;
  final Color? color;
  final int sparkleCount;
  final Duration duration;
  final double radius;

  @override
  State<SparkleEffect> createState() => _SparkleEffectState();
}

class _SparkleEffectState extends State<SparkleEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  List<_Sparkle> _sparkles = const [];
  int _lastToken = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    widget.controller.addListener(_onTrigger);
  }

  @override
  void didUpdateWidget(covariant SparkleEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTrigger);
      widget.controller.addListener(_onTrigger);
    }
  }

  void _onTrigger() {
    final token = widget.controller.token;
    if (token == _lastToken) return;
    _lastToken = token;

    final rng = Random(token);
    _sparkles = List<_Sparkle>.generate(widget.sparkleCount, (i) {
      final angle = rng.nextDouble() * pi * 2;
      final distance = rng.nextDouble() * widget.radius;
      final size = 1.8 + rng.nextDouble() * 2.8;
      final t0 = rng.nextDouble() * 0.25;
      final speed = 0.55 + rng.nextDouble() * 0.45;
      return _Sparkle(
        angle: angle,
        distance: distance,
        size: size,
        startT: t0,
        speed: speed,
      );
    });

    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTrigger);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        widget.child,
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              if (_controller.value == 0) return const SizedBox.shrink();
              return CustomPaint(
                painter: _SparklePainter(
                  t: _controller.value,
                  sparkles: _sparkles,
                  color: color,
                ),
                size: const Size.square(1),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Sparkle {
  const _Sparkle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.startT,
    required this.speed,
  });

  final double angle;
  final double distance;
  final double size;
  final double startT;
  final double speed;
}

class _SparklePainter extends CustomPainter {
  _SparklePainter({
    required this.t,
    required this.sparkles,
    required this.color,
  });

  final double t;
  final List<_Sparkle> sparkles;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final s in sparkles) {
      final localT = ((t - s.startT) / s.speed).clamp(0.0, 1.0);
      if (localT <= 0) continue;
      final eased = Curves.easeOutCubic.transform(localT);
      final fade = (1 - Curves.easeIn.transform(localT)).clamp(0.0, 1.0);

      final dx = cos(s.angle) * s.distance * eased;
      final dy = sin(s.angle) * s.distance * eased;
      final center = Offset(dx, dy);

      paint.color = color.withValues(alpha: 0.85 * fade);
      final path = _starPath(center, s.size * (0.9 + 0.25 * (1 - localT)));
      canvas.drawPath(path, paint);
    }
  }

  Path _starPath(Offset center, double r) {
    const points = 5;
    final inner = r * 0.45;
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final isOuter = i.isEven;
      final rr = isOuter ? r : inner;
      final angle = (-pi / 2) + (pi / points) * i;
      final p = center + Offset(cos(angle) * rr, sin(angle) * rr);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.sparkles != sparkles ||
        oldDelegate.color != color;
  }
}
