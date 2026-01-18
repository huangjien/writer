import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/ui_style_controller.dart';
import '../../../theme/ui_styles.dart';

class StyleSettingsSection extends ConsumerWidget {
  const StyleSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final uiStyleState = ref.watch(uiStyleControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.style_outlined),
          title: Row(
            children: [
              Expanded(child: Text('Styles', semanticsLabel: 'UI Styles')),
              DropdownButton<UiStyleFamily>(
                value: uiStyleState.family,
                onChanged: (UiStyleFamily? style) {
                  if (style != null) {
                    ref
                        .read(uiStyleControllerProvider.notifier)
                        .setStyle(style);
                  }
                },
                items: [
                  _buildDropdownMenuItem(
                    UiStyleFamily.glassmorphism,
                    'Glassmorphism',
                    l10n,
                  ),
                  _buildDropdownMenuItem(
                    UiStyleFamily.neumorphism,
                    'Neumorphism',
                    l10n,
                  ),
                  _buildDropdownMenuItem(
                    UiStyleFamily.claymorphism,
                    'Claymorphism',
                    l10n,
                  ),
                  _buildDropdownMenuItem(
                    UiStyleFamily.minimalism,
                    'Minimalism',
                    l10n,
                  ),
                  _buildDropdownMenuItem(
                    UiStyleFamily.brutalism,
                    'Brutalism',
                    l10n,
                  ),
                  _buildDropdownMenuItem(
                    UiStyleFamily.skeuomorphism,
                    'Skeuomorphism',
                    l10n,
                  ),
                  _buildDropdownMenuItem(
                    UiStyleFamily.bentoGrid,
                    'Bento Grid',
                    l10n,
                  ),
                  _buildDropdownMenuItem(
                    UiStyleFamily.responsive,
                    'Responsive',
                    l10n,
                  ),
                  _buildDropdownMenuItem(
                    UiStyleFamily.flatDesign,
                    'Flat Design',
                    l10n,
                  ),
                ],
                underline: const SizedBox.shrink(),
                icon: const Icon(Icons.arrow_drop_down),
                isDense: true,
                borderRadius: BorderRadius.circular(8),
                focusColor: Theme.of(context).focusColor,
                autofocus: false,
                enableFeedback: true,
                dropdownColor: Theme.of(context).colorScheme.surface,
                style: Theme.of(context).textTheme.bodyMedium,
                iconEnabledColor: Theme.of(context).colorScheme.onSurface,
                iconDisabledColor: Theme.of(context).disabledColor,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: StylePreviewGrid(
            selected: uiStyleState.family,
            onSelected: (style) =>
                ref.read(uiStyleControllerProvider.notifier).setStyle(style),
          ),
        ),
      ],
    );
  }

  DropdownMenuItem<UiStyleFamily> _buildDropdownMenuItem(
    UiStyleFamily style,
    String label,
    AppLocalizations l10n,
  ) {
    return DropdownMenuItem<UiStyleFamily>(
      value: style,
      child: Text(label, semanticsLabel: label),
    );
  }
}

class StylePreviewGrid extends StatelessWidget {
  const StylePreviewGrid({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final UiStyleFamily selected;
  final ValueChanged<UiStyleFamily> onSelected;

  @override
  Widget build(BuildContext context) {
    final styles = UiStyleFamily.values;
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 3 : 5;

    return Semantics(
      label: 'Style preview grid',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: styles.length,
        itemBuilder: (context, index) {
          final style = styles[index];
          final isSelected = style == selected;

          return _StylePreviewCard(
            style: style,
            isSelected: isSelected,
            onTap: () => onSelected(style),
          );
        },
      ),
    );
  }
}

class _StylePreviewCard extends StatelessWidget {
  const _StylePreviewCard({
    required this.style,
    required this.isSelected,
    required this.onTap,
  });

  final UiStyleFamily style;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final decoration = _getStyleDecoration(style, colorScheme, isSelected);
    final iconColor = isSelected
        ? colorScheme.primary
        : colorScheme.onSurface.withValues(alpha: 0.6);

    Widget previewContent;
    switch (style) {
      case UiStyleFamily.glassmorphism:
        previewContent = _buildGlassmorphismPreview(
          context,
          colorScheme,
          isSelected,
          iconColor,
        );
        break;
      case UiStyleFamily.neumorphism:
        previewContent = _buildNeumorphismPreview(
          context,
          colorScheme,
          isSelected,
          iconColor,
        );
        break;
      case UiStyleFamily.claymorphism:
        previewContent = _buildClaymorphismPreview(
          context,
          colorScheme,
          isSelected,
          iconColor,
        );
        break;
      case UiStyleFamily.minimalism:
        previewContent = _buildMinimalismPreview(
          context,
          colorScheme,
          isSelected,
          iconColor,
        );
        break;
      case UiStyleFamily.brutalism:
        previewContent = _buildBrutalismPreview(
          context,
          colorScheme,
          isSelected,
          iconColor,
        );
        break;
      case UiStyleFamily.skeuomorphism:
        previewContent = _buildSkeuomorphismPreview(
          context,
          colorScheme,
          isSelected,
          iconColor,
        );
        break;
      case UiStyleFamily.bentoGrid:
        previewContent = _buildBentoGridPreview(
          context,
          colorScheme,
          isSelected,
          iconColor,
        );
        break;
      case UiStyleFamily.responsive:
        previewContent = _buildResponsivePreview(
          context,
          colorScheme,
          isSelected,
          iconColor,
        );
        break;
      case UiStyleFamily.flatDesign:
        previewContent = _buildFlatDesignPreview(
          context,
          colorScheme,
          isSelected,
          iconColor,
        );
        break;
    }

    return Semantics(
      button: true,
      selected: isSelected,
      label: uiStyleDisplayName(style, context),
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: decoration,
          child: previewContent,
        ),
      ),
    );
  }

  Widget _buildGlassmorphismPreview(
    BuildContext context,
    ColorScheme colorScheme,
    bool isSelected,
    Color iconColor,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _getStyleIcon(UiStyleFamily.glassmorphism),
          color: iconColor,
          size: 24,
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            uiStyleDisplayName(UiStyleFamily.glassmorphism, context),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: iconColor),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildNeumorphismPreview(
    BuildContext context,
    ColorScheme colorScheme,
    bool isSelected,
    Color iconColor,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.15),
                offset: const Offset(-2, -2),
                blurRadius: 4,
              ),
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.1),
                offset: const Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Icon(
            _getStyleIcon(UiStyleFamily.neumorphism),
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            uiStyleDisplayName(UiStyleFamily.neumorphism, context),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: iconColor),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildClaymorphismPreview(
    BuildContext context,
    ColorScheme colorScheme,
    bool isSelected,
    Color iconColor,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.2),
                offset: const Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
          child: Icon(
            _getStyleIcon(UiStyleFamily.claymorphism),
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            uiStyleDisplayName(UiStyleFamily.claymorphism, context),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: iconColor),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMinimalismPreview(
    BuildContext context,
    ColorScheme colorScheme,
    bool isSelected,
    Color iconColor,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _getStyleIcon(UiStyleFamily.minimalism),
          color: iconColor,
          size: 24,
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            uiStyleDisplayName(UiStyleFamily.minimalism, context),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: iconColor),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBrutalismPreview(
    BuildContext context,
    ColorScheme colorScheme,
    bool isSelected,
    Color iconColor,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.zero,
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outline,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow,
                blurRadius: 0,
                offset: const Offset(4, 4),
              ),
            ],
          ),
          child: Icon(
            _getStyleIcon(UiStyleFamily.brutalism),
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            uiStyleDisplayName(UiStyleFamily.brutalism, context),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: iconColor),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSkeuomorphismPreview(
    BuildContext context,
    ColorScheme colorScheme,
    bool isSelected,
    Color iconColor,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.25),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Icon(
            _getStyleIcon(UiStyleFamily.skeuomorphism),
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            uiStyleDisplayName(UiStyleFamily.skeuomorphism, context),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: iconColor),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBentoGridPreview(
    BuildContext context,
    ColorScheme colorScheme,
    bool isSelected,
    Color iconColor,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.1),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Icon(
            _getStyleIcon(UiStyleFamily.bentoGrid),
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            uiStyleDisplayName(UiStyleFamily.bentoGrid, context),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: iconColor),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildResponsivePreview(
    BuildContext context,
    ColorScheme colorScheme,
    bool isSelected,
    Color iconColor,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.08),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: Icon(
            _getStyleIcon(UiStyleFamily.responsive),
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            uiStyleDisplayName(UiStyleFamily.responsive, context),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: iconColor),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFlatDesignPreview(
    BuildContext context,
    ColorScheme colorScheme,
    bool isSelected,
    Color iconColor,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _getStyleIcon(UiStyleFamily.flatDesign),
          color: iconColor,
          size: 24,
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            uiStyleDisplayName(UiStyleFamily.flatDesign, context),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: iconColor),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  BoxDecoration _getStyleDecoration(
    UiStyleFamily style,
    ColorScheme colorScheme,
    bool isSelected,
  ) {
    switch (style) {
      case UiStyleFamily.glassmorphism:
        return BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        );
      case UiStyleFamily.neumorphism:
        return BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.2),
              offset: const Offset(-3, -3),
              blurRadius: 6,
            ),
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
          ],
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        );
      case UiStyleFamily.claymorphism:
        return BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        );
      case UiStyleFamily.minimalism:
        return BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        );
      case UiStyleFamily.brutalism:
        return BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.zero,
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 3 : 2,
          ),
        );
      case UiStyleFamily.skeuomorphism:
        return BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.3),
              offset: const Offset(2, 4),
              blurRadius: 4,
            ),
          ],
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        );
      case UiStyleFamily.bentoGrid:
        return BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.15),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        );
      case UiStyleFamily.responsive:
        return BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              offset: const Offset(0, 1),
              blurRadius: 2,
            ),
          ],
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        );
      case UiStyleFamily.flatDesign:
        return BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        );
    }
  }

  IconData _getStyleIcon(UiStyleFamily style) {
    switch (style) {
      case UiStyleFamily.glassmorphism:
        return Icons.blur_on;
      case UiStyleFamily.neumorphism:
        return Icons.invert_colors_off;
      case UiStyleFamily.claymorphism:
        return Icons.bubble_chart;
      case UiStyleFamily.minimalism:
        return Icons.crop_square;
      case UiStyleFamily.brutalism:
        return Icons.widgets;
      case UiStyleFamily.skeuomorphism:
        return Icons.texture;
      case UiStyleFamily.bentoGrid:
        return Icons.dashboard;
      case UiStyleFamily.responsive:
        return Icons.devices;
      case UiStyleFamily.flatDesign:
        return Icons.square;
    }
  }
}
