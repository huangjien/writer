import 'dart:async';
import 'package:flutter/material.dart';
import 'package:writer/theme/design_tokens.dart';
import 'package:writer/shared/widgets/theme_aware_card.dart';
import 'success_animation.dart';

enum EnhancedToastTone { info, success, warning, error }

Future<void> showEnhancedToast(
  BuildContext context, {
  required String message,
  EnhancedToastTone tone = EnhancedToastTone.info,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 3),
}) async {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _EnhancedToastEntry(
      message: message,
      tone: tone,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
      onDismissed: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

class _EnhancedToastEntry extends StatefulWidget {
  const _EnhancedToastEntry({
    required this.message,
    required this.tone,
    required this.duration,
    required this.onDismissed,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final EnhancedToastTone tone;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_EnhancedToastEntry> createState() => _EnhancedToastEntryState();
}

class _EnhancedToastEntryState extends State<_EnhancedToastEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Motion.medium,
      reverseDuration: Motion.fast,
    )..forward();

    _timer = Timer(widget.duration, _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    _timer?.cancel();
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, tint) = _toneVisual(theme, widget.tone);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.m),
        child: Align(
          alignment: Alignment.topCenter,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, -0.25),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Motion.easeOut,
                    reverseCurve: Motion.easeIn,
                  ),
                ),
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _controller,
                curve: Motion.easeInOut,
              ),
              child: Dismissible(
                key: ValueKey('${widget.message}-${widget.tone}'),
                direction: DismissDirection.up,
                onDismissed: (_) => _dismiss(),
                child: ThemeAwareCard(
                  borderRadius: BorderRadius.circular(Radii.l),
                  semanticType: widget.tone == EnhancedToastTone.success
                      ? CardSemanticType.success
                      : widget.tone == EnhancedToastTone.error
                      ? CardSemanticType.error
                      : widget.tone == EnhancedToastTone.warning
                      ? CardSemanticType.warning
                      : CardSemanticType.info,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.l,
                    vertical: Spacing.m,
                  ),
                  child: Row(
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: tint),
                        const SizedBox(width: Spacing.m),
                      ] else if (widget.tone == EnhancedToastTone.success) ...[
                        SuccessAnimation(size: 28, color: tint),
                        const SizedBox(width: Spacing.m),
                      ],
                      Expanded(
                        child: Text(
                          widget.message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (widget.actionLabel != null && widget.onAction != null)
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                widget.onAction!.call();
                                _dismiss();
                              },
                              child: Text(
                                widget.actionLabel!,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).closeButtonTooltip,
                        onPressed: _dismiss,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  (IconData?, Color) _toneVisual(ThemeData theme, EnhancedToastTone tone) {
    switch (tone) {
      case EnhancedToastTone.info:
        return (Icons.info_outline, theme.colorScheme.primary);
      case EnhancedToastTone.success:
        return (null, theme.colorScheme.primary);
      case EnhancedToastTone.warning:
        return (Icons.warning_amber_outlined, AppColors.warning);
      case EnhancedToastTone.error:
        return (Icons.error_outline, theme.colorScheme.error);
    }
  }
}
