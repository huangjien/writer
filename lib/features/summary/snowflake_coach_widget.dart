import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/summary/snowflake_service.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import 'package:writer/models/snowflake.dart';

class SnowflakeCoachWidget extends ConsumerStatefulWidget {
  final String novelId;
  final String currentSummary;
  final ValueChanged<String> onSummaryUpdated;

  const SnowflakeCoachWidget({
    super.key,
    required this.novelId,
    required this.currentSummary,
    required this.onSummaryUpdated,
  });

  @override
  ConsumerState<SnowflakeCoachWidget> createState() =>
      _SnowflakeCoachWidgetState();
}

class _SnowflakeCoachWidgetState extends ConsumerState<SnowflakeCoachWidget> {
  final _inputController = TextEditingController();
  bool _loading = false;
  SnowflakeRefinementOutput? _lastOutput;
  String? _error;
  bool _appliedUpdate = false;

  @override
  void initState() {
    super.initState();
    _analyze();
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
        summaryContent: widget.currentSummary,
        userResponse: userResponse,
      );
      final result = await service.refineSummary(input);
      if (result != null) {
        if (mounted) {
          setState(() {
            _lastOutput = result;
          });
          widget.onSummaryUpdated(result.summaryContent);
          _appliedUpdate = true;
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
    _analyze();
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
            const Icon(Icons.error_outline, color: Colors.red, size: 32),
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

    if (_lastOutput == null) {
      return Center(
        child: ElevatedButton.icon(
          onPressed: () => _analyze(),
          icon: const Icon(Icons.auto_awesome),
          label: Text(l10n.startAiCoaching),
        ),
      );
    }

    final output = _lastOutput!;
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
        // AI Message Area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.purple),
                    const SizedBox(width: 8),
                    Text(
                      isDone ? l10n.refinementComplete : l10n.coachQuestion,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purple.shade100),
                  ),
                  child: Text(
                    isDone
                        ? (output.critique ?? l10n.summaryLooksGood)
                        : (output.aiQuestion ?? l10n.howToImprove),
                    style: const TextStyle(fontSize: 16),
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
                                ? Colors.blue.shade50
                                : Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: (msg['role'] == 'user')
                                  ? Colors.blue.shade100
                                  : Colors.purple.shade100,
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
                                      ? Colors.blue
                                      : Colors.purple,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    msg['content'] ?? '',
                                    style: const TextStyle(fontSize: 16),
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
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.green.shade100),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    output.critique!,
                                    style: const TextStyle(fontSize: 16),
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
                      return ActionChip(
                        label: Text(s),
                        onPressed: _loading
                            ? null
                            : () {
                                _inputController.text = s;
                              },
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Input Area
        if (!isDone)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      hintText: l10n.reviewSuggestionsHint,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        _analyze(userResponse: val.trim());
                        _inputController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
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
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
