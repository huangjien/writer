import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'contrast_monitor.dart';
import '../../../l10n/app_localizations.dart';

class ContrastAlertDialog extends ConsumerWidget {
  final VoidCallback onDismiss;
  final VoidCallback? onApplyPreset;

  const ContrastAlertDialog({
    super.key,
    required this.onDismiss,
    this.onApplyPreset,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final alerts = ref.watch(contrastMonitorProvider);
    final criticalAlerts = alerts.where((alert) => alert.isCritical).toList();

    if (alerts.isEmpty) {
      return _buildNoIssuesDialog(context);
    }

    return AlertDialog(
      title: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.contrastIssuesDetected,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.foundContrastIssues(alerts.length),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  return _buildAlertCard(context, alerts[index], ref);
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: onDismiss, child: Text(l10n.ignore)),
        if (criticalAlerts.isNotEmpty)
          ElevatedButton.icon(
            onPressed: () {
              if (onApplyPreset != null) {
                onApplyPreset!();
              }
              onDismiss();
            },
            icon: const Icon(Icons.auto_fix_high),
            label: Text(l10n.applyBestFix),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }

  Widget _buildNoIssuesDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
          const SizedBox(width: 12),
          Text(l10n.allGood),
        ],
      ),
      content: Text(l10n.allGoodContrast),
      actions: [TextButton(onPressed: onDismiss, child: Text(l10n.close))],
    );
  }

  Widget _buildAlertCard(
    BuildContext context,
    ContrastAlert alert,
    WidgetRef ref,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildSeverityIndicator(alert.severity),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    alert.elementName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                _buildContrastBadge(alert.contrastRatio),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              alert.message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildColorPreview(
                    'Text',
                    alert.foreground,
                    alert.background,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildColorPreview(
                    'Background',
                    alert.background,
                    Colors.white,
                  ),
                ),
              ],
            ),
            if (alert.suggestions.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Suggested Fixes:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              ...alert.suggestions
                  .take(2)
                  .map(
                    (suggestion) => _buildSuggestionItem(
                      context,
                      suggestion,
                      alert.elementName,
                      ref,
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityIndicator(ContrastSeverity severity) {
    Color color;
    IconData icon;

    switch (severity) {
      case ContrastSeverity.error:
        color = Colors.red;
        icon = Icons.error;
        break;
      case ContrastSeverity.warning:
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case ContrastSeverity.ok:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
    }

    return Icon(icon, color: color, size: 20);
  }

  Widget _buildContrastBadge(double ratio) {
    Color color;

    if (ratio < 3.0) {
      color = Colors.red;
    } else if (ratio < 4.5) {
      color = Colors.orange;
    } else if (ratio < 7.0) {
      color = Colors.yellow[700]!;
    } else {
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${ratio.toStringAsFixed(1)}:1',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildColorPreview(String label, Color color, Color background) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          height: 32,
          decoration: BoxDecoration(
            color: background,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.centerLeft,
          child: Text(
            'Sample',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionItem(
    BuildContext context,
    AdjustmentSuggestion suggestion,
    String elementName,
    WidgetRef ref,
  ) {
    return InkWell(
      onTap: () {
        ref
            .read(contrastMonitorProvider.notifier)
            .applySuggestion(suggestion, elementName);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.blue,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.description,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'New ratio: ${suggestion.improvedRatio.toStringAsFixed(1)}:1',
                    style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showContrastAlertDialog(
  BuildContext context, {
  VoidCallback? onApplyPreset,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => ContrastAlertDialog(
      onDismiss: () => Navigator.of(context).pop(),
      onApplyPreset: onApplyPreset,
    ),
  );
}
