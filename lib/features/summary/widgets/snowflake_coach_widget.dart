import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/summary/services/snowflake_service.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import 'package:writer/models/snowflake.dart';
import 'package:writer/shared/api_exception.dart';
import 'package:writer/shared/widgets/particles/confetti_effect.dart';
import 'package:writer/shared/widgets/particles/sparkle_effect.dart';
import 'package:writer/features/summary/widgets/snowflake_coach_chat_view.dart';

class SnowflakeCoachWidget extends ConsumerStatefulWidget {
  final String novelId;
  final String summaryType;
  final String currentSummary;
  final ValueChanged<String> onSummaryUpdated;
  final bool autoAnalyze;
  final Function(SnowflakeRefinementOutput)? onAiCompleted;
  final SnowflakeRefinementOutput? lastOutput;

  const SnowflakeCoachWidget({
    super.key,
    required this.novelId,
    required this.summaryType,
    required this.currentSummary,
    required this.onSummaryUpdated,
    this.autoAnalyze = true,
    this.onAiCompleted,
    this.lastOutput,
  });

  @override
  ConsumerState<SnowflakeCoachWidget> createState() =>
      _SnowflakeCoachWidgetState();
}

class _SnowflakeCoachWidgetState extends ConsumerState<SnowflakeCoachWidget> {
  final _inputController = TextEditingController();
  final _sparkleController = SparkleController();
  final _confettiController = ConfettiController();
  bool _loading = false;
  bool _chatbotVisible = false;
  SnowflakeRefinementOutput? _lastOutput;
  String? _error;
  bool _appliedUpdate = false;
  bool _didCelebrate = false;

  @override
  void initState() {
    super.initState();
    _lastOutput = widget.lastOutput;
    if (widget.autoAnalyze) {
      _chatbotVisible = true;
      _loadChatHistory();
    }
  }

  Future<void> _loadChatHistory() async {
    // Load existing chat history
    try {
      final service = ref.read(snowflakeServiceProvider);
      final history = await service.getChatHistory(
        widget.novelId,
        widget.summaryType,
      );
      if (history != null && mounted) {
        setState(() {
          _lastOutput = history;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _showChatbot() async {
    setState(() {
      _chatbotVisible = true;
      _error = null;
    });

    await _loadChatHistory();
  }

  Future<void> _analyze({String? userResponse}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    _sparkleController.trigger();

    try {
      final service = ref.read(snowflakeServiceProvider);

      final input = SnowflakeRefinementInput(
        novelId: widget.novelId,
        summaryType: widget.summaryType,
        summaryContent: widget.currentSummary,
        userResponse: userResponse,
      );

      final result = await service.refineSummary(input);
      if (result != null) {
        if (mounted) {
          setState(() {
            _lastOutput = result;
            _chatbotVisible = true;
          });
          widget.onSummaryUpdated(result.summaryContent);
          _appliedUpdate = true;
          widget.onAiCompleted?.call(result);
          if (result.status == 'refined' && !_didCelebrate) {
            _didCelebrate = true;
            _confettiController.trigger();
          }
        }
      } else {
        if (mounted) {
          final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
          setState(() => _error = l10n.failedToAnalyze);
        }
      }
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) return;
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _sparkleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SnowflakeCoachWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _appliedUpdate = false;
    if (widget.autoAnalyze) {
      _showChatbot();
    }
  }

  String _formatTimestamps(String? createdAt, String? updatedAt) {
    if (createdAt == null && updatedAt == null) return '';

    final now = DateTime.now();
    final buffer = StringBuffer();

    if (createdAt != null) {
      final created = DateTime.parse(createdAt);
      final diff = now.difference(created);
      buffer.write('Created ${_formatDuration(diff)} ago');
    }

    if (updatedAt != null && updatedAt != createdAt) {
      if (buffer.isNotEmpty) buffer.write(' • ');
      final updated = DateTime.parse(updatedAt);
      final diff = now.difference(updated);
      buffer.write('Updated ${_formatDuration(diff)} ago');
    }

    return buffer.toString();
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  String _getCoachTitle(AppLocalizations l10n) {
    switch (widget.summaryType) {
      case 'sentence':
        return 'AI ${l10n.sentenceSummary}';
      case 'paragraph':
        return 'AI ${l10n.paragraphSummary}';
      case 'page':
        return 'AI ${l10n.pageSummary}';
      case 'expanded':
        return 'AI ${l10n.expandedSummary}';
      default:
        return 'AI Coach';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();

    if (_loading && _lastOutput == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SparkleEffect(
              controller: _sparkleController,
              child: const CircularProgressIndicator(),
            ),
            const SizedBox(height: 8),
            Text(l10n.aiCoachAnalyzing),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(_error!),
            SparkleEffect(
              controller: _sparkleController,
              child: ElevatedButton(
                onPressed: _analyze,
                child: Text(l10n.retry),
              ),
            ),
          ],
        ),
      );
    }

    if (!_chatbotVisible) {
      return Center(
        child: SparkleEffect(
          controller: _sparkleController,
          child: ElevatedButton.icon(
            onPressed: _showChatbot,
            icon: const Icon(Icons.chat),
            label: Text(_getCoachTitle(l10n)),
          ),
        ),
      );
    }

    final output = _lastOutput;
    final isDone = output?.status == 'refined';
    final messages = output?.history ?? const [];
    if (isDone && !_appliedUpdate && output != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onSummaryUpdated(output.summaryContent);
        setState(() {
          _appliedUpdate = true;
        });
      });
    }

    final timestampText = _formatTimestamps(
      _lastOutput?.createdAt,
      _lastOutput?.updatedAt,
    );

    return SnowflakeCoachChatView(
      l10n: l10n,
      sparkleController: _sparkleController,
      confettiController: _confettiController,
      inputController: _inputController,
      loading: _loading,
      autoAnalyze: widget.autoAnalyze,
      coachTitle: _getCoachTitle(l10n),
      output: output,
      messages: messages,
      isDone: isDone,
      timestampText: timestampText,
      onAnalyze: _analyze,
      onSendUserResponse: (val) => _analyze(userResponse: val),
      onSuggestionSelected: (s) {
        _inputController.text = s;
      },
    );
  }
}
