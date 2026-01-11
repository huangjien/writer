import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

class CoverPlaceholder extends StatelessWidget {
  const CoverPlaceholder({
    super.key,
    required this.seed,
    this.borderRadius,
    this.icon = Icons.menu_book,
  });

  final int seed;
  final BorderRadius? borderRadius;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final hue = (seed % 360).abs().toDouble();
    final gradientColors = [
      HSLColor.fromAHSL(0.85, hue, 0.7, 0.58).toColor(),
      HSLColor.fromAHSL(0.90, (hue + 60) % 360.0, 0.8, 0.48).toColor(),
    ];

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(Radii.s),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
          ),
          CustomPaint(painter: _CoverPatternPainter(seed: seed)),
          Center(
            child: Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.92),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class BlurUpNetworkImage extends StatelessWidget {
  const BlurUpNetworkImage({
    super.key,
    required this.imageUrl,
    required this.placeholderSeed,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.width,
    this.height,
  });

  final String imageUrl;
  final int placeholderSeed;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final r = borderRadius ?? BorderRadius.circular(Radii.s);

    return ClipRRect(
      borderRadius: r,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CoverPlaceholder(seed: placeholderSeed, borderRadius: r),
            Image.network(
              imageUrl,
              fit: fit,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (frame == null) return const SizedBox.shrink();
                return TweenAnimationBuilder<double>(
                  duration: Motion.medium,
                  curve: Motion.easeOut,
                  tween: Tween(begin: 10.0, end: 0.0),
                  builder: (context, sigma, _) {
                    return ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: sigma,
                        sigmaY: sigma,
                      ),
                      child: AnimatedOpacity(
                        duration: Motion.medium,
                        curve: Motion.easeOut,
                        opacity: 1.0,
                        child: child,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverPatternPainter extends CustomPainter {
  _CoverPatternPainter({required this.seed});

  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final count = 10 + (seed.abs() % 6);
    for (int i = 0; i < count; i++) {
      final t = (i + 1) / (count + 1);
      final y = size.height * t;
      final xOffset = (seed % 17) - 8.0;
      final p1 = Offset(-size.width * 0.2, y + xOffset);
      final p2 = Offset(size.width * 1.2, y - xOffset);
      canvas.drawLine(p1, p2, paint);
    }

    final dotPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;
    final dots = 14 + (seed.abs() % 10);
    for (int i = 0; i < dots; i++) {
      final fx = ((seed * (i + 3)) % 997) / 997.0;
      final fy = ((seed * (i + 7)) % 991) / 991.0;
      final r = 0.9 + ((seed + i) % 3) * 0.4;
      canvas.drawCircle(Offset(size.width * fx, size.height * fy), r, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CoverPatternPainter oldDelegate) {
    return oldDelegate.seed != seed;
  }
}
