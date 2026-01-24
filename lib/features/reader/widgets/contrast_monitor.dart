import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'contrast_validator.dart';
import '../../../theme/accessibility/contrast_checker.dart';

enum ContrastSeverity { ok, warning, error }

class ContrastAlert {
  final String elementName;
  final Color foreground;
  final Color background;
  final double contrastRatio;
  final ContrastSeverity severity;
  final String message;
  final List<AdjustmentSuggestion> suggestions;

  const ContrastAlert({
    required this.elementName,
    required this.foreground,
    required this.background,
    required this.contrastRatio,
    required this.severity,
    required this.message,
    required this.suggestions,
  });

  bool get isCritical => severity == ContrastSeverity.error;
}

class AdjustmentSuggestion {
  final String description;
  final Color suggestedForeground;
  final Color suggestedBackground;
  final double improvedRatio;

  const AdjustmentSuggestion({
    required this.description,
    required this.suggestedForeground,
    required this.suggestedBackground,
    required this.improvedRatio,
  });
}

class ContrastMonitor {
  static const double warningThreshold = 7.0;
  static const double errorThreshold = 4.5;

  static List<ContrastAlert> monitorReaderColors(ReaderColors colors) {
    final alerts = <ContrastAlert>[];

    final primaryResult = ContrastValidator.validateColors(
      colors.primaryText,
      colors.background,
    );

    if (!primaryResult.isValid) {
      alerts.add(
        _createAlert(
          'Primary Text',
          colors.primaryText,
          colors.background,
          primaryResult.contrastResult,
          ContrastSeverity.error,
        ),
      );
    }

    final secondaryResult = ContrastValidator.validateColors(
      colors.secondaryText,
      colors.background,
    );

    if (!secondaryResult.isValid) {
      alerts.add(
        _createAlert(
          'Secondary Text',
          colors.secondaryText,
          colors.background,
          secondaryResult.contrastResult,
          ContrastSeverity.error,
        ),
      );
    }

    final accentResult = ContrastValidator.validateColors(
      colors.accentText,
      colors.background,
    );

    if (!accentResult.isValid) {
      alerts.add(
        _createAlert(
          'Accent Text',
          colors.accentText,
          colors.background,
          accentResult.contrastResult,
          ContrastSeverity.error,
        ),
      );
    }

    final linkResult = ContrastValidator.validateColors(
      colors.linkText,
      colors.background,
    );

    if (!linkResult.isValid) {
      alerts.add(
        _createAlert(
          'Link Text',
          colors.linkText,
          colors.background,
          linkResult.contrastResult,
          ContrastSeverity.error,
        ),
      );
    }

    return alerts;
  }

  static ContrastAlert _createAlert(
    String elementName,
    Color foreground,
    Color background,
    ContrastResult contrastResult,
    ContrastSeverity severity,
  ) {
    final suggestions = _generateSuggestions(
      foreground,
      background,
      contrastResult.ratio,
    );

    return ContrastAlert(
      elementName: elementName,
      foreground: foreground,
      background: background,
      contrastRatio: contrastResult.ratio,
      severity: severity,
      message: _generateMessage(elementName, contrastResult.ratio),
      suggestions: suggestions,
    );
  }

  static String _generateMessage(String elementName, double ratio) {
    if (ratio < 3.0) {
      return '$elementName contrast is critically low ($ratio:1). Immediate action required.';
    } else if (ratio < 4.5) {
      return '$elementName contrast does not meet WCAG AA standard ($ratio:1).';
    } else if (ratio < 7.0) {
      return '$elementName contrast meets WCAG AA but could be improved ($ratio:1).';
    } else {
      return '$elementName contrast is excellent ($ratio:1).';
    }
  }

  static List<AdjustmentSuggestion> _generateSuggestions(
    Color foreground,
    Color background,
    double currentRatio,
  ) {
    final suggestions = <AdjustmentSuggestion>[];

    final fgSuggestions = ContrastAdjuster.suggestColorAdjustments(
      foreground,
      background,
      adjustForeground: true,
    );

    for (final suggestion in fgSuggestions) {
      suggestions.add(
        AdjustmentSuggestion(
          description: suggestion.reason,
          suggestedForeground: suggestion.suggestedColor,
          suggestedBackground: background,
          improvedRatio: suggestion.newRatio,
        ),
      );
    }

    final bgSuggestions = ContrastAdjuster.suggestColorAdjustments(
      foreground,
      background,
      adjustForeground: false,
    );

    for (final suggestion in bgSuggestions) {
      suggestions.add(
        AdjustmentSuggestion(
          description: suggestion.reason,
          suggestedForeground: foreground,
          suggestedBackground: suggestion.suggestedColor,
          improvedRatio: suggestion.newRatio,
        ),
      );
    }

    final brightness = background.computeLuminance() > 0.5
        ? Brightness.light
        : Brightness.dark;

    final presets = PresetColorScheme.schemesForBrightness(brightness);

    for (final preset in presets) {
      final ratio = ContrastChecker.calculateContrast(
        preset.text,
        preset.background,
      ).ratio;

      if (ratio >= 4.5) {
        suggestions.add(
          AdjustmentSuggestion(
            description: 'Use preset: ${preset.name}',
            suggestedForeground: preset.text,
            suggestedBackground: preset.background,
            improvedRatio: ratio,
          ),
        );
      }
    }

    suggestions.sort((a, b) => b.improvedRatio.compareTo(a.improvedRatio));

    return suggestions.take(5).toList();
  }

  static ContrastSeverity determineSeverity(double ratio) {
    if (ratio < errorThreshold) {
      return ContrastSeverity.error;
    } else if (ratio < warningThreshold) {
      return ContrastSeverity.warning;
    } else {
      return ContrastSeverity.ok;
    }
  }
}

class ContrastMonitorNotifier extends StateNotifier<List<ContrastAlert>> {
  ReaderColors? _currentColors;

  ContrastMonitorNotifier() : super([]);

  void setColors(ReaderColors colors) {
    _currentColors = colors;
    _validate();
  }

  void updateColor({
    Color? background,
    Color? primaryText,
    Color? secondaryText,
    Color? accentText,
    Color? linkText,
  }) {
    if (_currentColors == null) return;

    _currentColors = ReaderColors(
      background: background ?? _currentColors!.background,
      primaryText: primaryText ?? _currentColors!.primaryText,
      secondaryText: secondaryText ?? _currentColors!.secondaryText,
      accentText: accentText ?? _currentColors!.accentText,
      linkText: linkText ?? _currentColors!.linkText,
    );

    _validate();
  }

  void _validate() {
    if (_currentColors == null) return;

    state = ContrastMonitor.monitorReaderColors(_currentColors!);
  }

  bool get hasAlerts => state.any((alert) => alert.isCritical);

  List<ContrastAlert> get criticalAlerts =>
      state.where((alert) => alert.isCritical).toList();

  void applySuggestion(AdjustmentSuggestion suggestion, String elementName) {
    if (_currentColors == null) return;

    switch (elementName) {
      case 'Primary Text':
        _currentColors = ReaderColors(
          background: suggestion.suggestedBackground,
          primaryText: suggestion.suggestedForeground,
          secondaryText: _currentColors!.secondaryText,
          accentText: _currentColors!.accentText,
          linkText: _currentColors!.linkText,
        );
        break;
      case 'Secondary Text':
        _currentColors = ReaderColors(
          background: suggestion.suggestedBackground,
          primaryText: _currentColors!.primaryText,
          secondaryText: suggestion.suggestedForeground,
          accentText: _currentColors!.accentText,
          linkText: _currentColors!.linkText,
        );
        break;
      case 'Accent Text':
        _currentColors = ReaderColors(
          background: suggestion.suggestedBackground,
          primaryText: _currentColors!.primaryText,
          secondaryText: _currentColors!.secondaryText,
          accentText: suggestion.suggestedForeground,
          linkText: _currentColors!.linkText,
        );
        break;
      case 'Link Text':
        _currentColors = ReaderColors(
          background: suggestion.suggestedBackground,
          primaryText: _currentColors!.primaryText,
          secondaryText: _currentColors!.secondaryText,
          accentText: _currentColors!.accentText,
          linkText: suggestion.suggestedForeground,
        );
        break;
    }

    _validate();
  }
}

final contrastMonitorProvider =
    StateNotifierProvider<ContrastMonitorNotifier, List<ContrastAlert>>(
      (ref) => ContrastMonitorNotifier(),
    );

class ContrastWidget extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onContrastIssue;

  const ContrastWidget({super.key, required this.child, this.onContrastIssue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(contrastMonitorProvider);
    final hasAlerts = alerts.any((alert) => alert.isCritical);

    if (hasAlerts) {
      onContrastIssue?.call();
    }

    return Stack(
      children: [
        child,
        if (hasAlerts)
          Positioned(
            top: 8,
            right: 8,
            child: _buildAlertBadge(context, alerts),
          ),
      ],
    );
  }

  Widget _buildAlertBadge(BuildContext context, List<ContrastAlert> alerts) {
    final criticalCount = alerts.where((a) => a.isCritical).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            '$criticalCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
