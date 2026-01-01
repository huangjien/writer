import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/summary/snowflake_service.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import 'package:writer/models/snowflake.dart';

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
  bool _loading = false;
  bool _chatbotVisible = false;
  SnowflakeRefinementOutput? _lastOutput;
  String? _error;
  bool _appliedUpdate = false;

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
        }
      } else {
        if (mounted) {
          final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
          setState(() => _error = l10n.failedToAnalyze);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
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
            const CircularProgressIndicator(),
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
            ElevatedButton(
              onPressed: () => _analyze(),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (!_chatbotVisible) {
      return Center(
        child: ElevatedButton.icon(
          onPressed: _showChatbot,
          icon: const Icon(Icons.chat),
          label: Text(_getCoachTitle(l10n)),
        ),
      );
    }

    final output = _lastOutput;
    if (output == null) {
      // Show empty chatbot interface when no history exists
      return Column(
        children: [
          // Top bar with analyze button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.chat,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getCoachTitle(l10n),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _loading ? null : () => _analyze(),
                  icon: const Icon(Icons.analytics, size: 16),
                  label: Text('Analyze'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Empty state
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_outlined,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No chat history yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Click "Analyze" to start improving your summary',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final isDone = output.status == 'refined';
    final messages = output.history ?? const [];
    if (isDone && !_appliedUpdate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onSummaryUpdated(output.summaryContent);
        setState(() {
          _appliedUpdate = true;
        });
      });
    }

    return Column(
      children: [
        // Top bar with regenerate button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isDone ? l10n.refinementComplete : l10n.coachQuestion,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              if (!widget.autoAnalyze)
                ElevatedButton.icon(
                  onPressed: _loading ? null : () => _analyze(),
                  icon: const Icon(Icons.analytics, size: 16),
                  label: Text('Analyze'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // AI Message Area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    isDone
                        ? (output.critique ?? l10n.summaryLooksGood)
                        : (output.aiQuestion ?? l10n.howToImprove),
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                if (messages.isNotEmpty) ...[
                  for (final msg in messages) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: (msg['role'] == 'user')
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: (msg['role'] == 'user')
                                ? Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest
                                : Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: (msg['role'] == 'user')
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.outline.withValues(alpha: 0.3)
                                  : Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  (msg['role'] == 'user')
                                      ? Icons.person
                                      : Icons.auto_awesome,
                                  color: (msg['role'] == 'user')
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant
                                      : Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    msg['content'] ?? '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: (msg['role'] == 'user')
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant
                                          : Theme.of(
                                              context,
                                            ).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () async {
                                    final content = msg['content'] ?? '';
                                    if (content.isNotEmpty) {
                                      await Clipboard.setData(
                                        ClipboardData(text: content),
                                      );
                                      if (mounted) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Copied to clipboard',
                                              ),
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                  child: Icon(
                                    Icons.copy,
                                    size: 16,
                                    color: (msg['role'] == 'user')
                                        ? Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant
                                              .withValues(alpha: 0.6)
                                        : Theme.of(context).colorScheme.primary
                                              .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (isDone && (output.critique?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    output.critique!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
                // Timestamps
                if (_lastOutput?.createdAt != null ||
                    _lastOutput?.updatedAt != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatTimestamps(
                            _lastOutput?.createdAt,
                            _lastOutput?.updatedAt,
                          ),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Suggestions
                if (!isDone && (output.suggestions?.isNotEmpty ?? false)) ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n.suggestionsLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: output.suggestions!.map((s) {
                      return GestureDetector(
                        onTap: _loading
                            ? null
                            : () {
                                _inputController.text = s;
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _loading
                                ? Theme.of(context).colorScheme.surfaceContainer
                                : Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _loading
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.outline.withValues(alpha: 0.2)
                                  : Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.3),
                            ),
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width - 100,
                            ),
                            child: Text(
                              s,
                              style: TextStyle(
                                color: _loading
                                    ? Theme.of(context).colorScheme.onSurface
                                          .withValues(alpha: 0.5)
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                fontSize: 14,
                              ),
                              softWrap: true,
                              maxLines: null,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Input Area - always visible when chatbot is shown
        if (_chatbotVisible)
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isDone) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Chat completed - Start a new analysis or ask questions',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                TextField(
                  controller: _inputController,
                  decoration: InputDecoration(
                    hintText: isDone
                        ? 'Ask a follow-up question or start new analysis...'
                        : l10n.reviewSuggestionsHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: IconButton(
                        onPressed: _loading
                            ? null
                            : () {
                                final val = _inputController.text.trim();
                                if (val.isNotEmpty) {
                                  _analyze(userResponse: val);
                                  _inputController.clear();
                                }
                              },
                        icon: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send),
                      ),
                    ),
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      _analyze(userResponse: val.trim());
                      _inputController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}
