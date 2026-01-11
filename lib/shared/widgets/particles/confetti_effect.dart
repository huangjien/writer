import 'dart:math';

import 'package:flutter/material.dart';

class ConfettiController extends ChangeNotifier {
  int _token = 0;
  int get token => _token;

  void trigger() {
    _token++;
    notifyListeners();
  }
}

class ConfettiEffect extends StatefulWidget {
  const ConfettiEffect({
    super.key,
    required this.controller,
    required this.child,
    this.particleCount = 32,
    this.duration = const Duration(milliseconds: 1200),
  });

  final ConfettiController controller;
  final Widget child;
  final int particleCount;
  final Duration duration;

  @override
  State<ConfettiEffect> createState() => _ConfettiEffectState();
}

class _ConfettiEffectState extends State<ConfettiEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  List<_ConfettiParticle> _particles = const [];
  int _lastToken = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    widget.controller.addListener(_onTrigger);
  }

  @override
  void didUpdateWidget(covariant ConfettiEffect oldWidget) {
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
    _particles = List<_ConfettiParticle>.generate(widget.particleCount, (i) {
      final x = rng.nextDouble();
      final speed = 0.7 + rng.nextDouble() * 0.9;
      final drift = (rng.nextDouble() - 0.5) * 0.6;
      final size = 6 + rng.nextDouble() * 8;
      final rotation = rng.nextDouble() * pi * 2;
      final rotationSpeed = (rng.nextDouble() - 0.5) * 8;
      final colors = <Color>[
        Colors.pinkAccent,
        Colors.amberAccent,
        Colors.lightBlueAccent,
        Colors.lightGreenAccent,
        Colors.deepPurpleAccent,
      ];
      final color = colors[rng.nextInt(colors.length)];
      return _ConfettiParticle(
        x: x,
        speed: speed,
        drift: drift,
        size: size,
        rotation: rotation,
        rotationSpeed: rotationSpeed,
        color: color,
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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                if (_controller.value == 0) return const SizedBox.shrink();
                return CustomPaint(
                  painter: _ConfettiPainter(
                    t: _controller.value,
                    particles: _particles,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfettiParticle {
  const _ConfettiParticle({
    required this.x,
    required this.speed,
    required this.drift,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
  });

  final double x;
  final double speed;
  final double drift;
  final double size;
  final double rotation;
  final double rotationSpeed;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.t, required this.particles});

  final double t;
  final List<_ConfettiParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final fade = (1 - Curves.easeIn.transform(t)).clamp(0.0, 1.0);

    for (final p in particles) {
      final y = (t * p.speed) * size.height;
      final x = (p.x + p.drift * t) * size.width;
      final r = p.rotation + p.rotationSpeed * t;

      paint.color = p.color.withValues(alpha: 0.85 * fade);
      final rect = Rect.fromCenter(
        center: Offset(x, y),
        width: p.size,
        height: p.size * 0.55,
      );
      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.rotate(r);
      canvas.translate(-rect.center.dx, -rect.center.dy);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(p.size * 0.18)),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.particles != particles;
  }
}
