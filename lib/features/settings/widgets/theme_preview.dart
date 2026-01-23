import 'package:flutter/material.dart';

import '../../../theme/themes.dart';

class ThemePreviewGrid extends StatelessWidget {
  const ThemePreviewGrid({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final AppThemeFamily selected;
  final ValueChanged<AppThemeFamily> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final def in themeFactoryThemes)
          ThemePreviewTile(
            label: def.label,
            family: def.id,
            selected: def.id == selected,
            onTap: () => onSelected(def.id),
          ),
      ],
    );
  }
}

class ThemePreviewTile extends StatelessWidget {
  const ThemePreviewTile({
    super.key,
    required this.label,
    required this.family,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final AppThemeFamily family;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final light = themeForLight(family).colorScheme;
    final dark = themeForDark(family).colorScheme;
    final borderColor = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).dividerColor;

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
          width: 160,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  swatch(light.primary, light.onPrimary),
                  swatch(light.surface, light.onSurface),
                  const SizedBox(width: 6),
                  swatch(dark.primary, dark.onPrimary),
                  swatch(dark.surface, dark.onSurface),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
