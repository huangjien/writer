import 'package:flutter/material.dart';
import '../../../theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/neumorphic_button.dart';
import '../../../shared/widgets/neumorphic_textfield.dart';

class LibrarySearchBar extends StatefulWidget {
  const LibrarySearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.matchCount,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int? matchCount;

  @override
  State<LibrarySearchBar> createState() => _LibrarySearchBarState();
}

class _LibrarySearchBarState extends State<LibrarySearchBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (_hasText != widget.controller.text.isNotEmpty) {
      setState(() {
        _hasText = widget.controller.text.isNotEmpty;
      });
    }
  }

  void _clear() {
    widget.controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final showMatchCount = widget.matchCount != null;
    final showClear = _hasText;
    final suffix = (!showMatchCount && !showClear)
        ? null
        : Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showMatchCount) ...[
                  Text(
                    '${widget.matchCount}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: Spacing.s),
                ],
                if (showClear)
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: NeumorphicButton(
                      onPressed: _clear,
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(Radii.m),
                      depth: 4,
                      child: Icon(
                        Icons.clear,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          );

    return NeumorphicTextField(
      controller: widget.controller,
      hintText: l10n.searchByTitle,
      prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
      suffixIcon: suffix,
      onChanged: widget.onChanged,
    );
  }
}
