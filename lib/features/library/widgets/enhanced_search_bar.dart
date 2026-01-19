import 'package:flutter/material.dart';
import '../../../theme/design_tokens.dart';
import '../../../shared/widgets/neumorphic_button.dart';
import '../../../shared/widgets/neumorphic_textfield.dart';

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
    // theme was unused

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search input
        NeumorphicTextField(
          controller: _controller,
          hintText: widget.hintText ?? 'Search novels...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _hasText
              ? Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: NeumorphicButton(
                      onPressed: _clear,
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(Radii.m),
                      depth: 4,
                      child: const Icon(Icons.clear, size: 18),
                    ),
                  ),
                )
              : null,
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

    final selectedBg = theme.colorScheme.primary.withValues(alpha: 0.12);
    final selectedFg = theme.colorScheme.primary;
    final fg = theme.colorScheme.onSurfaceVariant;

    return NeumorphicButton(
      onPressed: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.m,
        vertical: Spacing.xs,
      ),
      borderRadius: BorderRadius.circular(Radii.xl),
      color: selected ? selectedBg : null,
      depth: selected ? 3 : 6,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: selected ? selectedFg : fg),
            const SizedBox(width: Spacing.xs),
          ],
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: selected ? selectedFg : fg,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
