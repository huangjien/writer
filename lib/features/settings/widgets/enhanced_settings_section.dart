import 'package:flutter/material.dart';
import 'package:writer/theme/design_tokens.dart';
import 'package:writer/shared/widgets/theme_aware_card.dart';
import 'package:writer/shared/widgets/neumorphic_switch.dart';
import 'package:writer/shared/widgets/neumorphic_dropdown.dart';

/// Enhanced settings section component
/// Features:
/// - Section header with icon
/// - Optional description
/// - Card container for items
/// - Dark mode support
class EnhancedSettingsSection extends StatelessWidget {
  const EnhancedSettingsSection({
    super.key,
    required this.title,
    required this.children,
    this.icon,
    this.description,
  });

  final String title;
  final List<Widget> children;
  final IconData? icon;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.l,
            vertical: Spacing.m,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: Spacing.s),
              ],
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (description != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
            child: Text(
              description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: Spacing.s),
        ],
        // Section content card with transparent ListTiles
        ThemeAwareCard(
          margin: const EdgeInsets.symmetric(horizontal: Spacing.l),
          semanticType: CardSemanticType.default_,
          padding: EdgeInsets.zero,
          child: Theme(
            data: theme.copyWith(
              listTileTheme: theme.listTileTheme.copyWith(
                tileColor: Colors.transparent,
                selectedTileColor: Colors.transparent,
              ),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: children),
          ),
        ),
        const SizedBox(height: Spacing.xl),
      ],
    );
  }
}

/// Settings toggle switch item
class SettingsToggle extends StatelessWidget {
  const SettingsToggle({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.subtitle,
    this.icon,
  });

  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final bool enabled;
  final String? subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: icon != null
          ? Icon(icon, color: theme.colorScheme.onSurface)
          : null,
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: enabled
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: NeumorphicSwitch(
        value: value,
        onChanged: enabled ? onChanged : null,
        isEnabled: enabled,
      ),
    );
  }
}

/// Settings selection item
class SettingsSelection<T> extends StatelessWidget {
  const SettingsSelection({
    super.key,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
    this.subtitle,
    this.icon,
  });

  final String title;
  final T value;
  final List<SettingsOption<T>> options;
  final ValueChanged<T?> onChanged;
  final String? subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: icon != null
          ? Icon(icon, color: theme.colorScheme.onSurface)
          : null,
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: NeumorphicDropdown<T>(
        value: value,
        onChanged: onChanged,
        items: options.map((option) {
          return DropdownMenuItem<T>(
            value: option.value,
            child: Text(option.label),
          );
        }).toList(),
      ),
    );
  }
}

class SettingsOption<T> {
  const SettingsOption({required this.label, required this.value});

  final String label;
  final T value;
}

/// Settings navigation item
class SettingsNavigation extends StatelessWidget {
  const SettingsNavigation({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.icon,
    this.trailing,
  });

  final String title;
  final VoidCallback onTap;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon != null ? Icon(icon) : null,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
