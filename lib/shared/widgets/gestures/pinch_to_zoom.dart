import 'package:flutter/material.dart';
import 'package:writer/shared/widgets/app_buttons.dart';

class PinchToZoom extends StatelessWidget {
  const PinchToZoom({
    super.key,
    required this.child,
    this.minScale = 1.0,
    this.maxScale = 4.0,
    this.boundaryMargin = const EdgeInsets.all(24),
    this.enabled = true,
  });

  final Widget child;
  final double minScale;
  final double maxScale;
  final EdgeInsets boundaryMargin;
  final bool enabled;

  static Future<void> showNetworkImage(
    BuildContext context, {
    required String imageUrl,
    Widget? placeholder,
    Color backgroundColor = Colors.black,
  }) async {
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: backgroundColor.withValues(alpha: 0.92),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Center(
                        child: PinchToZoom(
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return placeholder ??
                                  const SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return placeholder ??
                                  const Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.white70,
                                    size: 40,
                                  );
                            },
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: AppButtons.icon(
                        onPressed: () => Navigator.of(context).maybePop(),
                        iconData: Icons.close,
                        color: Colors.white,
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).closeButtonTooltip,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return InteractiveViewer(
      minScale: minScale,
      maxScale: maxScale,
      boundaryMargin: boundaryMargin,
      child: child,
    );
  }
}
