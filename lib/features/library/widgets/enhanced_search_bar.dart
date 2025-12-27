import 'package:flutter/material.dart';
import '../../../theme/design_tokens.dart';

/// Enhanced search bar with filter chips
/// Features:
/// - Modern input design
/// - Filter chips for quick filtering
/// - Clear button
/// - Dark mode support
class EnhancedSearchBar extends StatefulWidget {
  const EnhancedSearchBar({
    super.key,
    required this.onChanged,
    this.hintText,
    this.onClear,
    this.showFilters = false,
    this.filters,
  });

  final ValueChanged<String> onChanged;
  final String? hintText;
  final VoidCallback? onClear;
  final bool showFilters;
  final List<Widget>? filters;

  @override
  State<EnhancedSearchBar> createState() => _EnhancedSearchBarState();
}

class _EnhancedSearchBarState extends State<EnhancedSearchBar> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
    widget.onChanged(_controller.text);
  }

  void _clear() {
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search input
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(Radii.m),
          ),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: widget.hintText ?? 'Search novels...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _hasText
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: _clear)
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Spacing.m,
                vertical: Spacing.m,
              ),
            ),
          ),
        ),
        // Filters
        if (widget.showFilters && widget.filters != null) ...[
          const SizedBox(height: Spacing.m),
          Wrap(
            spacing: Spacing.s,
            runSpacing: Spacing.s,
            children: widget.filters!,
          ),
        ],
      ],
    );
  }
}

/// Filter chip for search bar
class LibraryFilterChip extends StatelessWidget {
  const LibraryFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.xl),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.m,
          vertical: Spacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(Radii.xl),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: Spacing.xs),
            ],
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: selected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
