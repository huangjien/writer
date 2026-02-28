import 'package:flutter/material.dart';
import 'package:writer/utils/language_detector.dart';

class LanguageIndicator extends StatelessWidget {
  const LanguageIndicator({
    super.key,
    required this.text,
    this.icon,
    this.style,
  });

  final String text;
  final Widget? icon;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final detectedLanguage = LanguageDetector.detectLanguage(text);
    final languageName = LanguageDetector.getLanguageName(detectedLanguage);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(width: 4),
        ] else ...[
          Icon(
            Icons.auto_awesome,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
        ],
        Text(
          languageName,
          style: style ?? Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class LiveLanguageIndicator extends StatelessWidget {
  const LiveLanguageIndicator({
    super.key,
    required this.languageNotifier,
    this.icon,
    this.style,
  });

  final ValueNotifier<String> languageNotifier;
  final Widget? icon;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, languageCode, _) {
        final languageName = LanguageDetector.getLanguageName(languageCode);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 4),
            ] else ...[
              Icon(
                Icons.auto_awesome,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              languageName,
              style: style ?? Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        );
      },
    );
  }
}
