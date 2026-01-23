import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/design_tokens.dart';
import '../../theme/theme_extensions.dart';
import 'focus_wrapper.dart';

class NeumorphicSlider extends StatelessWidget {
  const NeumorphicSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.thumbColor,
    this.activeTrackColor,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final Color? thumbColor;
  final Color? activeTrackColor;

  void _updateValue(Offset localPosition, double width, double thumbSize) {
    if (onChanged == null) return;

    final double workableWidth = width - thumbSize;
    double dx = localPosition.dx - (thumbSize / 2);
    dx = dx.clamp(0.0, workableWidth);

    final double percent = dx / workableWidth;
    final double newValue = min + (max - min) * percent;

    if (newValue != value) {
      onChanged!(newValue);
    }
  }

  void _adjustValue(double delta) {
    if (onChanged == null) return;
    final step = (max - min) * 0.05;
    final newValue = (value + delta * step).clamp(min, max);
    onChanged!(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    final effectiveThumbColor = thumbColor ?? primaryColor;
    final effectiveActiveTrackColor = activeTrackColor ?? primaryColor;

    final isEnabled = onChanged != null;
    final resolvedBorder =
        theme.inputBorder ??
        Border.all(color: theme.colorScheme.outlineVariant, width: 1);
    final resolvedTrackColor =
        theme.inputBackgroundColor ?? theme.colorScheme.surface;

    return FocusWrapper(
      enabled: isEnabled,
      borderRadius: BorderRadius.circular(Radii.l),
      child: Semantics(
        slider: true,
        value: value.toStringAsFixed(1),
        enabled: isEnabled,
        child: FocusableActionDetector(
          enabled: isEnabled,
          mouseCursor: isEnabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.forbidden,
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.arrowLeft): _LeftIntent(),
            SingleActivator(LogicalKeyboardKey.arrowRight): _RightIntent(),
          },
          actions: <Type, Action<Intent>>{
            _LeftIntent: CallbackAction<_LeftIntent>(
              onInvoke: (intent) {
                _adjustValue(-1.0);
                return null;
              },
            ),
            _RightIntent: CallbackAction<_RightIntent>(
              onInvoke: (intent) {
                _adjustValue(1.0);
                return null;
              },
            ),
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              if (width.isInfinite) {
                return const SizedBox(height: 32);
              }

              const height = 32.0;
              const thumbSize = 24.0;
              const trackHeight = 8.0;

              final double safeValue = value.clamp(min, max);
              final double percent = (max == min)
                  ? 0.0
                  : (safeValue - min) / (max - min);
              final double workableWidth = width - thumbSize;
              final double thumbLeft = workableWidth * percent;

              return GestureDetector(
                onPanUpdate: (details) =>
                    _updateValue(details.localPosition, width, thumbSize),
                onPanDown: (details) =>
                    _updateValue(details.localPosition, width, thumbSize),
                child: Container(
                  width: width,
                  height: height,
                  color: Colors.transparent,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: width,
                        height: trackHeight,
                        decoration: BoxDecoration(
                          color: resolvedTrackColor,
                          borderRadius: BorderRadius.circular(trackHeight / 2),
                          border: resolvedBorder,
                          boxShadow: theme.styleCardShadows,
                        ),
                      ),
                      Container(
                        width: thumbLeft + (thumbSize / 2),
                        height: trackHeight,
                        decoration: BoxDecoration(
                          color: effectiveActiveTrackColor,
                          borderRadius: BorderRadius.circular(trackHeight / 2),
                        ),
                      ),
                      Positioned(
                        left: thumbLeft + (thumbSize / 2) - 16,
                        top: -20,
                        child: SizedBox(
                          width: 32,
                          child: Text(
                            value.toStringAsFixed(1),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: thumbLeft,
                        child: Container(
                          width: thumbSize,
                          height: thumbSize,
                          decoration: BoxDecoration(
                            color: effectiveThumbColor,
                            shape: BoxShape.circle,
                            boxShadow: theme.buttonShadows,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LeftIntent extends Intent {
  const _LeftIntent();
}

class _RightIntent extends Intent {
  const _RightIntent();
}
