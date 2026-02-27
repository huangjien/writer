import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:writer/theme/design_tokens.dart';
import 'package:writer/shared/widgets/theme_aware_card.dart';

class SuccessAnimation extends StatefulWidget {
  const SuccessAnimation({
    super.key,
    this.size = 56,
    this.color,
    this.duration = const Duration(milliseconds: 650),
  });

  final double size;
  final Color? color;
  final Duration duration;

  @override
  State<SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation>
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
    final color = widget.color ?? theme.colorScheme.primary;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = Curves.easeOut.transform(_controller.value);
          final ringAlpha = 0.08 + 0.22 * (1 - (1 - t) * (1 - t));
          final opacity = 0.92 + 0.08 * t;
          return Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 0.5 + (0.5 * t),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: ringAlpha),
                  ),
                ),
              ),
              Opacity(
                opacity: opacity,
                child: CustomPaint(
                  size: Size.square(widget.size),
                  painter: _CheckPainter(
                    progress: t,
                    color: color,
                    strokeWidth: math.max(3, widget.size * 0.08),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final p1 = Offset(size.width * 0.28, size.height * 0.54);
    final p2 = Offset(size.width * 0.45, size.height * 0.70);
    final p3 = Offset(size.width * 0.74, size.height * 0.34);

    final firstLen = (p2 - p1).distance;
    final secondLen = (p3 - p2).distance;
    final total = firstLen + secondLen;
    final drawLen = total * progress.clamp(0.0, 1.0);

    if (drawLen <= firstLen) {
      final t = drawLen / firstLen;
      canvas.drawLine(p1, Offset.lerp(p1, p2, t)!, paint);
    } else {
      canvas.drawLine(p1, p2, paint);
      final t = (drawLen - firstLen) / secondLen;
      canvas.drawLine(p2, Offset.lerp(p2, p3, t)!, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class SuccessBanner extends StatelessWidget {
  const SuccessBanner({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ThemeAwareCard(
      borderRadius: BorderRadius.circular(Radii.l),
      semanticType: CardSemanticType.success,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.l,
        vertical: Spacing.m,
      ),
      child: Row(
        children: [
          SuccessAnimation(size: 34, color: theme.colorScheme.primary),
          const SizedBox(width: Spacing.m),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: Spacing.m),
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onAction,
                  child: Text(actionLabel!, textAlign: TextAlign.end),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
