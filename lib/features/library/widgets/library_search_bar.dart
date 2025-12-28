import 'package:flutter/material.dart';
import '../../../theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';

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
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: l10n.searchByTitle,
        prefixIcon: const Icon(Icons.search),
        suffixText: widget.matchCount != null ? '${widget.matchCount}' : null,
        suffixIcon: _hasText
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _clear,
                tooltip: 'Clear search',
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.s),
        ),
      ),
      onChanged: widget.onChanged,
    );
  }
}
