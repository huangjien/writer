import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../theme/accessibility/contrast_checker.dart';

class ContrastValidationResult {
  final Color foreground;
  final Color background;
  final ContrastResult contrastResult;
  final bool isValid;

  const ContrastValidationResult({
    required this.foreground,
    required this.background,
    required this.contrastResult,
    required this.isValid,
  });
}

class ContrastValidator {
  static const double minimumContrastRatio = 4.5;

  static ContrastValidationResult validateColors(
    Color foreground,
    Color background,
  ) {
    final contrastResult = ContrastChecker.calculateContrast(
      foreground,
      background,
    );

    return ContrastValidationResult(
      foreground: foreground,
      background: background,
      contrastResult: contrastResult,
      isValid: contrastResult.passesAA,
    );
  }

  static ContrastValidationResult validateTextStyle(
    TextStyle style,
    Color background,
  ) {
    final foregroundColor = style.color ?? Colors.black;
    return validateColors(foregroundColor, background);
  }

  static ContrastValidationResult validateThemeColors(
    BuildContext context,
    Color background, {
    TextStyle? textStyle,
  }) {
    final theme = Theme.of(context);
    final foregroundColor =
        textStyle?.color ?? theme.textTheme.bodyLarge?.color;

    if (foregroundColor == null) {
      final isDark = theme.brightness == Brightness.dark;
      final defaultForeground = isDark ? Colors.white : Colors.black;
      return validateColors(defaultForeground, background);
    }

    return validateColors(foregroundColor, background);
  }

  static List<ContrastValidationResult> validateMultipleTextElements(
    Map<Color, Color> textBackgroundPairs,
  ) {
    return textBackgroundPairs.entries.map((entry) {
      return validateColors(entry.key, entry.value);
    }).toList();
  }

  static ContrastReport generateReport(List<ContrastValidationResult> results) {
    final failed = results.where((r) => !r.isValid).toList();
    final passed = results.where((r) => r.isValid).toList();

    return ContrastReport(
      totalChecks: results.length,
      passed: passed.length,
      failed: failed.length,
      failedResults: failed,
      allPassed: failed.isEmpty,
    );
  }
}

class ContrastReport {
  final int totalChecks;
  final int passed;
  final int failed;
  final List<ContrastValidationResult> failedResults;
  final bool allPassed;

  const ContrastReport({
    required this.totalChecks,
    required this.passed,
    required this.failed,
    required this.failedResults,
    required this.allPassed,
  });

  double get passPercentage =>
      totalChecks > 0 ? (passed / totalChecks) * 100 : 0;

  String get summary {
    if (allPassed) {
      return 'All $totalChecks contrast checks passed!';
    } else {
      return '$failed of $totalChecks contrast checks failed';
    }
  }
}

class ContrastValidationNotifier
    extends StateNotifier<ContrastValidationResult?> {
  ContrastValidationNotifier() : super(null);

  void validate(Color foreground, Color background) {
    state = ContrastValidator.validateColors(foreground, background);
  }

  void reset() {
    state = null;
  }
}

final contrastValidationProvider =
    StateNotifierProvider<
      ContrastValidationNotifier,
      ContrastValidationResult?
    >((ref) => ContrastValidationNotifier());

class ReaderColors {
  final Color background;
  final Color primaryText;
  final Color secondaryText;
  final Color accentText;
  final Color linkText;

  const ReaderColors({
    required this.background,
    required this.primaryText,
    required this.secondaryText,
    required this.accentText,
    required this.linkText,
  });

  factory ReaderColors.fromTheme(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ReaderColors(
      background: theme.colorScheme.surface,
      primaryText:
          theme.textTheme.bodyLarge?.color ??
          (isDark ? Colors.white : Colors.black),
      secondaryText:
          theme.textTheme.bodyMedium?.color ??
          (isDark ? Colors.grey[300]! : Colors.grey[700]!),
      accentText: theme.colorScheme.primary,
      linkText: theme.colorScheme.primary,
    );
  }

  List<ContrastValidationResult> validateAll() {
    final results = <ContrastValidationResult>[
      ContrastValidator.validateColors(primaryText, background),
      ContrastValidator.validateColors(secondaryText, background),
      ContrastValidator.validateColors(accentText, background),
      ContrastValidator.validateColors(linkText, background),
    ];

    return results;
  }

  ContrastReport generateReport() {
    return ContrastValidator.generateReport(validateAll());
  }
}

class ReaderColorsNotifier extends StateNotifier<ReaderColors> {
  ReaderColorsNotifier(BuildContext context)
    : super(ReaderColors.fromTheme(context));

  void updateFromTheme(BuildContext context) {
    state = ReaderColors.fromTheme(context);
  }

  void updateColor({
    Color? background,
    Color? primaryText,
    Color? secondaryText,
    Color? accentText,
    Color? linkText,
  }) {
    state = ReaderColors(
      background: background ?? state.background,
      primaryText: primaryText ?? state.primaryText,
      secondaryText: secondaryText ?? state.secondaryText,
      accentText: accentText ?? state.accentText,
      linkText: linkText ?? state.linkText,
    );
  }

  void applyPresetScheme(PresetColorScheme scheme) {
    state = ReaderColors(
      background: scheme.background,
      primaryText: scheme.text,
      secondaryText: scheme.secondaryText,
      accentText: scheme.text,
      linkText: scheme.text,
    );
  }
}

final readerColorsProvider =
    StateNotifierProvider<ReaderColorsNotifier, ReaderColors>(
      (ref) =>
          throw UnimplementedError('ReaderColorsProvider must be overridden'),
    );
