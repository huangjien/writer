import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../theme/design_tokens.dart';

class LoadingStory extends StatefulWidget {
  const LoadingStory({
    super.key,
    required this.stories,
    this.interval = const Duration(seconds: 3),
    this.textAlign = TextAlign.center,
  });

  final List<String> stories;
  final Duration interval;
  final TextAlign textAlign;

  @override
  State<LoadingStory> createState() => _LoadingStoryState();
}

class _LoadingStoryState extends State<LoadingStory> {
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  @override
  void didUpdateWidget(covariant LoadingStory oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.interval != widget.interval ||
        !listEquals(oldWidget.stories, widget.stories)) {
      _index = 0;
      _restartTimer();
    }
  }

  void _restartTimer() {
    _timer?.cancel();
    if (widget.stories.length <= 1) return;
    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted) return;
      setState(() {
        _index = (_index + 1) % widget.stories.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = widget.stories.isEmpty ? '' : widget.stories[_index];

    return AnimatedSwitcher(
      duration: Motion.medium,
      switchInCurve: Motion.easeOut,
      switchOutCurve: Motion.easeIn,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.15),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Motion.easeOut)),
          child: child,
        ),
      ),
      child: Text(
        text,
        key: ValueKey(text),
        textAlign: widget.textAlign,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        semanticsLabel: text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
          height: 1.45,
        ),
      ),
    );
  }
}
