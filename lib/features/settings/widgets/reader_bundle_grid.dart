import 'package:flutter/material.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/theme/reader_bundles.dart';
import 'package:writer/theme/themes.dart';

class ReaderBundleGrid extends StatelessWidget {
  const ReaderBundleGrid({super.key, required this.onApply});
  final ValueChanged<ReaderThemeBundleId> onApply;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String label(ReaderThemeBundleId id) {
      switch (id) {
        case ReaderThemeBundleId.nordCalm:
          return l10n.bundleNordCalm;
        case ReaderThemeBundleId.solarizedFocus:
          return l10n.bundleSolarizedFocus;
        case ReaderThemeBundleId.highContrastReadability:
          return l10n.bundleHighContrastReadability;
      }
    }

    ThemeData preview(ReaderThemeBundleId id) {
      final def = readerThemeBundles[id]!;
      return themeForLight(def.family);
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final id in ReaderThemeBundleId.values)
          _BundleTile(
            label: label(id),
            theme: preview(id),
            onTap: () => onApply(id),
          ),
      ],
    );
  }
}

class _BundleTile extends StatelessWidget {
  const _BundleTile({
    required this.label,
    required this.theme,
    required this.onTap,
  });

  final String label;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    Widget swatch(Color bg, Color fg) => Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Center(
        child: Container(
          width: 10,
          height: 4,
          decoration: BoxDecoration(
            color: fg,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  swatch(cs.primary, cs.onPrimary),
                  swatch(cs.surface, cs.onSurface),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
