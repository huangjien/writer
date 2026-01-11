import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../shared/widgets/app_buttons.dart';

class FocusTimerSheet extends StatefulWidget {
  const FocusTimerSheet({super.key});

  @override
  State<FocusTimerSheet> createState() => _FocusTimerSheetState();
}

class _FocusTimerSheetState extends State<FocusTimerSheet> {
  static const Duration _defaultDuration = Duration(minutes: 25);
  Timer? _timer;
  Duration _remaining = _defaultDuration;
  bool _running = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    if (_running) return;
    setState(() => _running = true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining <= const Duration(seconds: 1)) {
        _timer?.cancel();
        setState(() {
          _remaining = Duration.zero;
          _running = false;
        });
        return;
      }
      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _remaining = _defaultDuration;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minutes = _remaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = _remaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final label = '$minutes:$seconds';

    return Padding(
      padding: const EdgeInsets.all(Spacing.l),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: LetterSpacing.display,
            ),
          ),
          const SizedBox(height: Spacing.m),
          LinearProgressIndicator(
            value: 1.0 - (_remaining.inSeconds / _defaultDuration.inSeconds),
            minHeight: 8,
            borderRadius: BorderRadius.circular(Radii.s),
          ),
          const SizedBox(height: Spacing.l),
          Row(
            children: [
              Expanded(
                child: AppButtons.secondary(label: 'Reset', onPressed: _reset),
              ),
              const SizedBox(width: Spacing.m),
              Expanded(
                child: AppButtons.primary(
                  label: _running ? 'Pause' : 'Start',
                  onPressed: _running ? _pause : _start,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
